
local sizes = {
	5, 5,
	10, 10,
	20, 10,
	10, 20,
	51, 19,
	162, 80,
}

local tests = {
	"int", "_texture_int_subpixel_shrink", { palette },
	-- "rgb", "_texture_rgb_subpixel_shrink", { ... },
	-- "rgba", "_texture_rgba_subpixel_shrink", { ... },
}

-- @export
local function benchmark(duration)
	local hlabels = {}
	local vlabels = {}
	local hlabel_map = {}
	local vlabel_map = {}
	local iterations = 5

	duration = tonumber(duration or "1")

	for i = 1, #tests, 3 do
		local vlabel = pad(tests[i], 4) .. ": " .. tests[i + 1]:gsub(".+_", "")
		vlabel_map[vlabel] = { tests[i], tests[i + 1], tests[i + 2] }
		table.insert(vlabels, vlabel)
	end

	for i = 1, #sizes, 2 do
		local hlabel = "(${sizes[i]} x ${sizes[i + 1]})"
		hlabel_map[hlabel] = { sizes[i], sizes[i + 1] }
		table.insert(hlabels, hlabel)
	end

	local results = run_benchmarks("Benchmark", vlabels, hlabels, function(vlabel, hlabel)
		print("Running $vlabel at $hlabel")
		local test_data = vlabel_map[vlabel]
		local size = hlabel_map[hlabel]
		local source_format = ccgl.texture_format[test_data[1]]
		local dest_format = ccgl.texture_format["bfc_" .. test_data[1]]
		local source_texture = ccgl._create_texture(source_format, size[1] * 2, size[2] * 3)
		local dest_texture = ccgl._create_texture(dest_format, size[1], size[2])

		-- ccgl._texture_fill_rect(source_texture, 4, 16, 7, 7, 1)

		ccgl._texture_fill_poly(source_texture, { 1, 1, size[1] * 2 - 2, size[2] * 3 - 2, size[1] * 2 - 5, 5 }, true, 1)
		ccgl._texture_fill_poly(source_texture, { 3, size[2] * 3 - 3, size[1] * 2 - 2, size[2] * 3 - 2, size[1] * 2 - 5, 5 }, true, 2)

		if test_data[1] == "int" then
			ccgl[test_data[2]](source_texture, dest_texture, table.unpack(test_data[3]))
			ccgl._texture_blit_term(dest_texture, term)
			-- ccgl._texture_blit_term(dest_texture, term, source_texture.width + 1)
			-- ccgl._texture_blit_term(source_texture, term)
		end

		return duration, iterations,
		       ccgl[test_data[2]],
		       source_texture, dest_texture, table.unpack(test_data[3])
	end)

	-- term.setCursorPos(1, 1)
	-- term.clear()

	print()
	print()
	print_results(results)
	save_results("ccgl/benchmark/results/functions/texture_subpixel_convert.txt", results)
end
