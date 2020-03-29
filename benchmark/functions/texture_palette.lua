
local function map_texture(texture, fn)
	for y = 1, texture.height do
		for x = 1, texture.width do
			local i = ((y-1) * texture.width + x - 1) * 3
			local nx = (x - 1) / (texture.width - 1)
			local ny = (y - 1) / (texture.height - 1)
			local r, g, b = fn(nx, ny)

			texture[i + 1] = r
			texture[i + 2] = g
			texture[i + 3] = b
		end
	end
end

local function clamp(a, b, v)
	return math.max(a, math.min(b, v))
end

local function write_hsv_texture(texture)
	return map_texture(texture, function(nx, ny)
		local r = clamp(0, 1, (clamp(0, 1, math.abs(nx * 6 - 3) - 1) - 1) * ny + 1)
		local g = clamp(0, 1, (clamp(0, 1, 2 - math.abs(nx * 6 - 2)) - 1) * ny + 1)
		local b = clamp(0, 1, (clamp(0, 1, 2 - math.abs(nx * 6 - 4)) - 1) * ny + 1)

		return r, g, b
	end)
end

local function write_noise_texture(texture)
	return map_texture(texture, function(nx, ny)
		return math.random(), math.random(), math.random()
	end)
end

local function write_uv_texture(texture)
	return map_texture(texture, function(nx, ny)
		return nx, ny, 1
	end)
end

local function write_wheel_texture(texture)
	return map_texture(texture, function(nx, ny)
		local dx, dy = (nx - 0.5) * 1.5, ny - 0.5
    	local angle = math.atan2(dy, dx)
    	local radius = clamp(0, 1, math.sqrt(dx * dx + dy * dy) * 2)
    	local h = angle / (2 * math.pi) + 0.5
	    local r = clamp(0, 1, (clamp(0, 1, math.abs(h * 6 - 3) - 1) - 1) * radius + 1)
	    local g = clamp(0, 1, (clamp(0, 1, 2 - math.abs(h * 6 - 2)) - 1) * radius + 1)
	    local b = clamp(0, 1, (clamp(0, 1, 2 - math.abs(h * 6 - 4)) - 1) * radius + 1)

    	return r, g, b
	end)
end

local function map_palette(source_texture, dest_texture, palette)
	local idx = 1
	local didx = 1
	local tw = source_texture.width
	local palette_size = #palette / 3
	for y = 1, source_texture.height do
		for x = 1, tw do
			local r, g, b = source_texture[idx], source_texture[idx + 1], source_texture[idx + 2]
			local min_idx = 0
			local min_value = 1000
			local pidx = 1

			for p = 1, palette_size do
				local pr, pg, pb = palette[pidx], palette[pidx + 1], palette[pidx + 2]
				local dr, dg, db = r - pr, g - pg, b - pb
				local dist = dr * dr + dg * dg + db * db

				if dist < min_value then
					min_idx = p - 1
					min_value = dist
				end

				pidx = pidx + 3
			end

			dest_texture[didx] = min_idx
			idx = idx + 3
			didx = didx + 1
		end
	end
end

local original_palette = {}

for i = 0, 15 do
	original_palette[i + 1] = { term.getPaletteColor(2 ^ i) }
end

local sizes = {
	10, 10,
	25, 6,
	26, 20,
	39, 13,
	162, 80,
	51, 19,
}

local functions = {
	write_hsv_texture, "HSV",
	write_uv_texture, "UV",
	write_wheel_texture, "Wheel",
	write_noise_texture, "Noise",
}

local palette_sizes = {
	2, 4, 8, 12, 16,
	-- 16,
}

-- @export
local function benchmark(duration, f)
	local hlabels = {}
	local vlabels = {}
	local hlabel_map = {}
	local vlabel_map = {}
	local iterations = 5

	duration = tonumber(duration or "1")

	for i = 1, #sizes, 2 do
		local label = "(${sizes[i] * 2} x ${sizes[i + 1] * 3})"
		table.insert(hlabels, label)
		hlabel_map[label] = { sizes[i], sizes[i + 1] }
	end

	for j = 1, #palette_sizes do
		for i = 1, #functions, 2 do
			local label = "${functions[i + 1]} [${pad(tostring(palette_sizes[j]), 2)}]"
			table.insert(vlabels, label)
			vlabel_map[label] = { functions[i], palette_sizes[j] }
		end
	end

	local results = run_benchmarks("Benchmark", vlabels, hlabels, function(vlabel, hlabel)
		print("Running $vlabel at $hlabel")
		local size = hlabel_map[hlabel]
		local function_and_palette_size = vlabel_map[vlabel]
		local palette_size = function_and_palette_size[2]
		local texture_width = size[1] * 2
		local texture_height = size[2] * 3
		local texture_raw = ccgl._create_texture(ccgl.texture_format.rgb, texture_width, texture_height)
		local texture_int = ccgl._create_texture(ccgl.texture_format.int, texture_width, texture_height)
		local texture_draw = ccgl._create_texture(ccgl.texture_format.bfc_int, size[1], size[2])
		local is_long_compute = palette_size > 8 and texture_height * texture_width > 10000

		function_and_palette_size[1](texture_raw)
		local palette = ccgl._texture_evaluate_palette(texture_raw, palette_size)
		map_palette(texture_raw, texture_int, palette)
		ccgl._texture_int_subpixel_shrink(texture_int, texture_draw)

		for i = 1, #palette, 3 do
			term.setPaletteColor(2 ^ ((i - 1) / 3), palette[i], palette[i + 1], palette[i + 2])
		end

		term.clear()
		ccgl._texture_blit_term(texture_draw, term)

		return is_long_compute and duration * 2 or duration, is_long_compute and 2 or iterations, function()
			local palette = ccgl._texture_evaluate_palette(texture_raw, palette_size)
			map_palette(texture_raw, texture_int, palette)
		end
	end)

	if not f then
		os.pullEvent("mouse_click")
	end

	term.setCursorPos(1, 1)
	term.clear()

	for i = 0, 15 do
		term.setPaletteColor(2 ^ i, table.unpack(original_palette[i + 1]))
	end

	print()
	print()
	print_results(results)
	if f then save_results("ccgl/benchmark/results/functions/texture_palette.txt", results) end
end
