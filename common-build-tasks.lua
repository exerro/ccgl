
--- maps `local a = "hello $name"` to `local a = ("hello " .. (name))`
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

local function retrieve_exports_and_internals(lines, internal_exports, internals)
	local marked_as_export = false
	local marked_as_internal = false
	local lines_out = {}

	for i = 1, #lines do
		local line = lines[i]

		if marked_as_export or marked_as_internal then
			line = line
				:gsub("local ([%w_]+)(%s*=)", function(name, ws)
					if marked_as_internal then table.insert(internals, name) end

					if marked_as_export then
						if marked_as_internal then
							table.insert(internal_exports, name)
						else
							name = "__libdata." .. name
						end
					end

					return name .. ws
				end)
				:gsub("local function ([%w_]+)", function(name)
					if marked_as_internal then table.insert(internals, name) end

					if marked_as_export then
						if marked_as_internal then
							table.insert(internal_exports, name)
						else
							name = "__libdata." .. name
						end
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

	return lines_out
end

-- --[[ Annotate regions ]]--------------------------------------------------------

-- local global_lines = {}
-- local global_regions = {}
-- local region_offset = 0

-- local function annotate_regions(lines, region_0)
-- 	local annotated_lines = {}

-- 	if #lines > 0 and lines[1]:find("%-%-%s*@region") then
-- 		local region_name = lines[1]:match "%-%-%s*@region%s+(.*)"
-- 		local line = lines[1]:gsub("%-%-%s*@region%s+.*", "", 1)
-- 		annotated_lines[1] = { line, "begin_region", region_name }
-- 	else
-- 		annotated_lines[1] = { lines[1], "begin_region", region_0 }
-- 	end

-- 	for i = 2, #lines do
-- 		if lines[i]:find("%-%-%s*@region") then
-- 			local region_name = lines[i]:match "%-%-%s*@region%s+(.*)"
-- 			local line = lines[i]:gsub("%-%-%s*@region%s+.*", "", 1)
-- 			annotated_lines[i] = { line, "begin_region", region_name }
-- 		elseif lines[i]:find("%-%-%s*@end%-?region") then
-- 			local line = lines[i]:gsub("%-%-%s*@end%-?region", "", 1)
-- 			annotated_lines[i] = { line, "end_region" }
-- 		else
-- 			annotated_lines[i] = { lines[i] }
-- 		end
-- 	end

-- 	return annotated_lines
-- end

-- -- TODO: fix this
-- local function build_region_map(lines)
-- 	local stack = {}

-- 	for i, line in ipairs(lines) do
-- 		global_lines[region_offset + i] = line[1]

-- 		if line[2] == "begin_region" then
-- 			if #stack > 0 then
-- 				table.insert(global_regions, { stack[#stack][1], i - 1, stack[#stack][2], stack[#stack][3] })
-- 			end
-- 			table.insert(stack, { i, line[3], 0 })
-- 		end
-- 		if (line[2] == "end_region" or i == #lines) and #stack > 0 then
-- 			table.insert(global_regions, { stack[#stack][1], i, stack[#stack][2], stack[#stack][3] })
-- 			table.remove(stack)
-- 			if #stack > 0 then
-- 				stack[#stack][3] = i + stack[#stack][3] + 2 - stack[#stack][1]
-- 				stack[#stack][1] = i + 1
-- 			end
-- 		end
-- 	end
-- end

-- for _, file in ipairs(files_to_read) do
-- 	local contents = file_contents[file]
-- 	build_region_map(annotate_regions(contents, file))
-- 	region_offset = region_offset + #contents
-- end

-- for i = 1, #global_regions do
-- 	global_regions[i] = ("{%d,%d,%q,%d}"):format(table.unpack(global_regions[i]))
-- end

--------------------------------------------------------------------------------

tasks["ccgl::check-todos"] = function(self)
	for file in self.config.include.find_iterator() do
		local i = 1
		for line in file.lines_iterator() do
			local todo = line:match "^%s*%-%-%s*@todo:?%s+(.*)$"
			if todo then
				print_warning("TODO in " .. tostring(file) .. ":" .. i .. ": " .. todo)
			end
			i = i + 1
		end
	end
end

tasks["ccgl::check-todos"].config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
}

----------------------------------------------------------------

tasks["ccgl::preprocess"] = function(self)
	local internal_exports, internals = {}, {}
	local header_content = {}

	for file in self.config.include.find_iterator() do
		print_info("Preprocessing " .. tostring(file))

		local lines = file.lines()

		lines = apply_string_interpolation_transformation(lines)
		lines = apply_enum_transformation(lines)
		lines = retrieve_exports_and_internals(lines, internal_exports, internals)

		file.write(table.concat(lines, "\n"))
	end

	table.insert(header_content, "local __regions = $REGIONS")
	table.insert(header_content, "local __libdata = {}")
	table.insert(header_content, "local " .. table.concat(internals, ","))
	table.insert(header_content, "$CONTENT")

	for _, ie in ipairs(internal_exports) do
		table.insert(header_content, "__libdata." .. ie .. " = " .. ie)
	end

	table.insert(header_content, "return __libdata")

	self.config.header_path.write(table.concat(header_content, "\n"))

	print_info("Found " .. #internals .. " internal variables")
end

tasks["ccgl::preprocess"].config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
	header_path = MESH_ROOT_PATH / "build/header.lua",
}

----------------------------------------------------------------

tasks["ccgl::build"] = function(self)
	print_info("Merging files '" .. tostring(self.config.include) .. "' into '" .. tostring(self.config.output_path) .. "' using header '" .. tostring(self.config.header_path) .. "'")

	local content = self.config.header_path.read()
	local regions_string = "{}"
	local global_lines = {}

	for file in self.config.include.find_iterator() do
		for line in file.lines_iterator() do
			table.insert(global_lines, line)
		end
	end

	local content_string = table.concat(global_lines, "\n")

	content = content:gsub("$REGIONS", { ["$REGIONS"] = regions_string }, 1)
	content = content:gsub("$CONTENT", { ["$CONTENT"] = content_string }, 1)

	self.config.output_path.write(content)
end

tasks["ccgl::build"].config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
	header_path = MESH_ROOT_PATH / "build/header.lua",
	output_path = MESH_ROOT_PATH / "build/ccgl.lua",
}
