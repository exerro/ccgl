
local sizes = {
	26, 20,
	39, 13,
	51, 19,
	162, 80,
	162 * 2, 80 * 3,
}

local modes = {
	"dirty_alt",
	"dirty    ",
	"clean    ",
}

local formats = {
	"bfc",
	" bg",
}

-- @export
local function benchmark(duration)
	local tests = {}
	local labels = {}
	local test_map = {}
	local label_map = {}
	local iterations = 5

	duration = tonumber(duration or "1")

	for i = 1, #sizes, 2 do
		local test = "(${sizes[i]} x ${sizes[i + 1]})"
		test_map[test] = { sizes[i], sizes[i + 1] }
		table.insert(tests, test)
	end

	for j = 1, #formats do
		for i = 1, #modes do
			local mode = modes[i]
			local format = ccgl.texture_format[(formats[j] .. "_int"):gsub(" bg_int", "int")]
			local label = "${formats[j]}: $mode"
			label_map[label] = { mode, format }
			table.insert(labels, label)
		end
	end

	local results = run_benchmarks("Benchmark", labels, tests, function(label, test)
		print("Running $label at $test")
		local size = test_map[test]
		local mode_and_format = label_map[label]
		local mode = mode_and_format[1]
		local format = mode_and_format[2]
		local texture = ccgl._create_texture(format, size[1], size[2])

		if mode == "dirty_alt" then
			local stride = format == ccgl.texture_format.bfc_int and 2 or 1
			for i = 1, #texture, stride do
				if stride == 2 then
					texture[i] = (1 + (i - 1) / 2 % 2) * ccgl.TEXTURE_FORMAT_BFC_INT_MULTIPLIER
					texture[i + 1] = 98
				else
					texture[i] = 1 + (i - 1) % 2
				end
			end
		end

		return duration, iterations,
		       format == ccgl.texture_format.int and ccgl._texture_int_blit_term or ccgl._texture_bfc_int_blit_term,
		       texture, term.native(), 0, 0, mode == "clean" and texture
	end)

	print_results(results)
	save_results("ccgl/benchmark/results/functions/texture_blit_term.txt", results)
end
