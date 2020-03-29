
--[[ Read command line input ]]-------------------------------------------------

local args = { ... }
local input_file
local input_directory
local output_file
local file_inclusions = {}
local file_exclusions = {}

if #args == 1 then
	input_file = args[1]
else
	for i = 1, #args, 2 do
		if args[i] == "-f" then
			input_file = args[i + 1]
		elseif args[i] == "-d" then
			input_directory = args[i + 1]
		elseif args[i] == "-o" then
			output_file = args[i + 1]
		elseif args[i] == "-i" then
			table.insert(file_inclusions, args[i + 1])
		elseif args[i] == "-x" then
			table.insert(file_exclusions, args[i + 1])
		else
			return error(("unknown option '%s'"):format(args[i]), 0)
		end
	end
end

if not input_file and not input_directory then
	return error("no input file(s) specified", 0)
end

if input_directory and not fs.isDir(input_directory) then
	return error(("input directory '%s' does not exist"):format(input_directory), 0)
end

if input_file and (not fs.exists(input_file) or fs.isDir(input_file)) then
	if fs.exists(input_file .. ".lua") and not fs.isDir(input_file .. ".lua") then
		input_file = input_file .. ".lua"
	else
		return error(("input file '%s' is not a file"):format(input_file), 0)
	end
end

if not output_file then
	if input_file and input_file:find("%.lua") then
		output_file = input_file:gsub("%.lua$", ".out.lua", 1)
	elseif input_file then
		output_file = input_file .. ".out"
	elseif input_directory then
		output_file = input_directory .. ".lua"
	end
end

--[[ Get files to read ]]-------------------------------------------------------

local function matcher_to_pattern(matcher)
	return matcher
	:gsub("[%.%+%-%*%?%(%)[%]%%]", "%%%1")
	:gsub("/%%%*%%%*", "/.*")
	:gsub("/%%%*", "/[^/]%*")
	:gsub("^%%%*%%%*", "%.%*")
	:gsub("^%%%*", "[^/]%*") or ".*"
end

local pattern_inclusions = {}
local pattern_exclusions = {}
local files_to_read

for i = 1, #file_inclusions do
	pattern_inclusions[i] = matcher_to_pattern(file_inclusions[i])
end

for i = 1, #file_exclusions do
	pattern_exclusions[i] = matcher_to_pattern(file_exclusions[i])
end

local function enumerateDirectory(dir)
	local files = fs.list(dir)
	local results = {}

	for i = 1, #files do
		if fs.isDir(dir .. "/" .. files[i]) then
			local sub_files = enumerateDirectory(dir .. "/" .. files[i])

			for i = 1, #sub_files do
				table.insert(results, sub_files[i])
			end
		else
			table.insert(results, dir .. "/" .. files[i])
		end
	end

	return results
end

if input_directory then
	files_to_read = enumerateDirectory(input_directory)
end

if input_file then
	files_to_read = files_to_read or {}
	table.insert(files_to_read, input_file)
end

for i = 1, #files_to_read do
	files_to_read[i] = "/" .. files_to_read[i]:gsub("^/+", "")
end

for i = #files_to_read, 1, -1 do
	local any = false
	
	for j = 1, #pattern_inclusions do
		if files_to_read[i]:find(pattern_inclusions[j]) then
			any = true
			break
		end
	end

	if not any then
		table.remove(files_to_read, i)
	end
end

for i = #files_to_read, 1, -1 do
	for j = 1, #pattern_exclusions do
		if files_to_read[i]:find(pattern_exclusions[j]) then
			table.remove(files_to_read, i)
			break
		end
	end
end

term.setTextColour(colours.lightGrey)
print("collected files")

for i = 1, #files_to_read do
	term.setTextColour(colours.grey)
	write(" - ")
	term.setTextColour(colours.cyan)
	print(files_to_read[i])
end

term.setTextColour(colours.white)

--[[ Preprocess files and apply basic transformations ]]------------------------

local file_contents = {}
local all_exports = {}
local all_internals = {}

local function read_file(file)
	local h = io.open(file, "r")
	local contents = h:read("*a")
	h:close()

	return contents
end

local function split_lines(text)
	local lines = {}
	local lastLine = 1
	local nextLine = text:find "\n"

	while nextLine do
		table.insert(lines, text:sub(lastLine, nextLine - 1))
		lastLine = nextLine + 1
		nextLine = text:find("\n", lastLine)
	end

	table.insert(lines, text:sub(lastLine))

	return lines
end

-- maps `local a = "hello $name"` to `local a = ("hello " .. (name))`
local function apply_string_interpolation_transformation(lines)
	local lines_out = {}

	for i, line in ipairs(lines) do
		local in_string = false
		local string_closer = nil
		local escaped = false
		local last_segment = 1
		local segments = {}

		for c = 1, #line do
			local char = line:sub(c, c)

			if in_string then
				if not escaped then
					if char == string_closer then
						table.insert(segments, line:sub(last_segment, c))
						in_string = false
						last_segment = c + 1
					elseif char == "\\" then
						escaped = true
					end
				end
			else
				if char == "\"" or char == "'" then
					table.insert(segments, line:sub(last_segment, c - 1))
					string_closer = char
					in_string = true
					escaped = false
					last_segment = c
				end
			end
		end

		table.insert(segments, line:sub(last_segment))

		for i = 2, #segments, 2 do
			local segment_out = "("
			local raw_segment = segments[i]:gsub("$([%w_]+)", "${%1}")
			local index = raw_segment:find("${")
			local last_index = 1

			while index do
				local close = raw_segment:find("}", index)

				segment_out = segment_out .. raw_segment:sub(last_index, index - 1)
				segment_out = segment_out .. "\" .. (" .. raw_segment:sub(index + 2, close - 1) .. ") .. \""

				last_index = close + 1
				index = raw_segment:find("${", last_index)
			end

			segments[i] = segment_out .. raw_segment:sub(last_index) .. ")"
		end

		lines_out[i] = table.concat(segments)
	end

	return lines_out
end

local function apply_enum_transformation(lines)
	local enum_counter = 0
	local lines_out = {}

	for i, line in ipairs(lines) do
		local line = lines[i]
		if line:find("%-%-%s*@enum%-?member%s+[%w_]+") then
			local member = line:match("%-%-%s*@enum%-?member%s+([%w_]+)")
			line = line:gsub("%-%-%s*@enum%-?member%s+[%w_]+", member .. " = " .. enum_counter .. ",")
			enum_counter = enum_counter + 1
		elseif line:find("%-%-%s*@enum") then
			line = line:gsub("%-%-%s*@enum", "")
			enum_counter = 0
		end
		lines_out[i] = line
	end

	return lines_out
end

local function retrieve_exports_and_internals(lines)
	local exports = {}
	local internals = {}
	local marked_as_export = false
	local marked_as_internal = false
	local lines_out = {}

	for i = 1, #lines do
		local line = lines[i]

		if marked_as_export or marked_as_internal then
			line = line
				:gsub("local ([%w_]+)(%s*=)", function(name, ws)
					if marked_as_internal then table.insert(internals, name) end
					if marked_as_internal then
						if marked_as_export then table.insert(exports, name) end
					else
						name = "__libdata." .. name
					end
					return name .. ws
				end)
				:gsub("local function ([%w_]+)", function(name)
					if marked_as_internal then table.insert(internals, name) end
					if marked_as_internal then
						if marked_as_export then table.insert(exports, name) end
					else
						name = "__libdata." .. name
					end
					return name .. " = function"
				end)
		end

		if line:find("%-%-%s*@internal%-?export") then
			marked_as_internal = true
			marked_as_export = true
			line = line:gsub("%-%-%s*@internal%-?export", "")
		elseif line:find("%-%-%s*@export") then
			marked_as_export = true
			marked_as_internal = false
			line = line:gsub("%-%-%s*@export", "")
		elseif line:find("%-%-%s*@internal") then
			marked_as_internal = true
			marked_as_export = false
			line = line:gsub("%-%-%s*@internal", "")
		else
			marked_as_export = false
			marked_as_internal = false
		end

		lines_out[i] = line
	end

	return lines_out, exports, internals
end

for _, file in ipairs(files_to_read) do
	file_contents[file] = split_lines(read_file(file))
end

for file, contents in pairs(file_contents) do
	local file_exports

	contents = apply_string_interpolation_transformation(contents)
	contents = apply_enum_transformation(contents)
	contents, file_exports, file_internals = retrieve_exports_and_internals(contents)
	file_contents[file] = contents

	for _, export in ipairs(file_exports) do
		table.insert(all_exports, export)
	end

	for _, internal in ipairs(file_internals) do
		table.insert(all_internals, internal)
	end
end

--[[ Annotate regions ]]--------------------------------------------------------

local global_lines = {}
local global_regions = {}
local region_offset = 0

local function annotate_regions(lines, region_0)
	local annotated_lines = {}

	if #lines > 0 and lines[1]:find("%-%-%s*@region") then
		local region_name = lines[1]:match "%-%-%s*@region%s+(.*)"
		local line = lines[1]:gsub("%-%-%s*@region%s+.*", "", 1)
		annotated_lines[1] = { line, "begin_region", region_name }
	else
		annotated_lines[1] = { lines[1], "begin_region", region_0 }
	end

	for i = 2, #lines do
		if lines[i]:find("%-%-%s*@region") then
			local region_name = lines[i]:match "%-%-%s*@region%s+(.*)"
			local line = lines[i]:gsub("%-%-%s*@region%s+.*", "", 1)
			annotated_lines[i] = { line, "begin_region", region_name }
		elseif lines[i]:find("%-%-%s*@end%-?region") then
			local line = lines[i]:gsub("%-%-%s*@end%-?region", "", 1)
			annotated_lines[i] = { line, "end_region" }
		else
			annotated_lines[i] = { lines[i] }
		end
	end

	return annotated_lines
end

-- TODO: fix this
local function build_region_map(lines)
	local stack = {}

	for i, line in ipairs(lines) do
		global_lines[region_offset + i] = line[1]

		if line[2] == "begin_region" then
			if #stack > 0 then
				table.insert(global_regions, { stack[#stack][1], i - 1, stack[#stack][2], stack[#stack][3] })
			end
			table.insert(stack, { i, line[3], 0 })
		end
		if (line[2] == "end_region" or i == #lines) and #stack > 0 then
			table.insert(global_regions, { stack[#stack][1], i, stack[#stack][2], stack[#stack][3] })
			table.remove(stack)
			if #stack > 0 then
				stack[#stack][3] = i + stack[#stack][3] + 2 - stack[#stack][1]
				stack[#stack][1] = i + 1
			end
		end
	end
end

for file, contents in pairs(file_contents) do
	build_region_map(annotate_regions(contents, file))
	region_offset = region_offset + #contents
end

--[[ Build file output ]]-------------------------------------------------------

local template = [[
local __regions = $REGIONS
local __libdata = {}
$INTERNALS

$CONTENT

$INTERNAL_EXPORTS

return __libdata
]]

local function write_file(file, content)
	local h = io.open(file, "w")
	h:write(content)
	h:close()
end

for i = 1, #global_regions do
	global_regions[i] = ("{%d,%d,%q,%d}"):format(table.unpack(global_regions[i]))
end

local internals_string = ""
local internal_exports = {}

if #all_internals > 0 then
	internals_string = "local " .. table.concat(all_internals, ", ")
end

for i = 1, #all_exports do
	internal_exports[i] = "__libdata." .. all_exports[i] .. " = " .. all_exports[i]
end

local regions_string = "{" .. table.concat(global_regions, ",") .. "}"
local locals_string = table.concat(all_exports, ", ")
local content_string = table.concat(global_lines, "\n")
local internal_exports_string = table.concat(internal_exports, "\n")

local content = template:gsub("$([%w_]+)", function(name)
	if name == "REGIONS" then
		return regions_string
	elseif name == "INTERNALS" then
		return internals_string
	elseif name == "CONTENT" then
		return content_string
	elseif name == "INTERNAL_EXPORTS" then
		return internal_exports_string
	end
end)

write_file(output_file, content)
