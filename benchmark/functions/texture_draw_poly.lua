
local functions = {
	"Triangle outline", "_texture_outline_poly", { { 0, 0, 9, 1, 2, 8 }, true },
	"Triangle outline with horizontal edge", "_texture_outline_poly", { { 1, 1, 11, 1, 6, 8 }, true },
	"Triangle outline with left vertex", "_texture_outline_poly", { { 1, 10, 11, 1, 11, 16 }, true },
	"Quad outline", "_texture_outline_poly", { { 1, 1, 11, 3, 11, 15, 3, 12 }, true },
	"Octogon outline", "_texture_outline_poly", { { 20, 2, 30, 2, 35, 6, 35, 12, 30, 16, 20, 16, 15, 12, 15, 6 }, true },
	"Triangle", "_texture_fill_poly", { { 0, 0, 9, 1, 2, 8 }, true },
	"Triangle with horizontal edge", "_texture_fill_poly", { { 1, 1, 11, 1, 6, 8 }, true },
	"Triangle with left vertex", "_texture_fill_poly", { { 1, 10, 11, 1, 11, 16 }, true },
	"Quad", "_texture_fill_poly", { { 1, 1, 11, 3, 11, 15, 3, 12 }, true },
	"Octogon", "_texture_fill_poly", { { 20, 2, 30, 2, 35, 6, 35, 12, 30, 16, 20, 16, 15, 12, 15, 6 }, true },
}

local formats = {
	"int", { 1 },
	"bfc_int", { 2, 4, ("a"):byte() },
	"vec4", { { 1, 2, 3, 4 } },
}

-- @export
local function benchmark(duration)
	local hlabels = {}
	local vlabels = {}
	local hlabel_map = {}
	local vlabel_map = {}
	local iterations = 5
	local texture_width = 51
	local texture_height = 19

	duration = tonumber(duration or "1")

	for i = 1, #formats, 2 do
		local hlabel = formats[i]
		hlabel_map[hlabel] = { formats[i], formats[i + 1] }
		table.insert(hlabels, hlabel)
	end

	for i = 1, #functions, 3 do
		local label = functions[i]
		vlabel_map[label] = { functions[i + 1], functions[i + 2] }
		table.insert(vlabels, label)
	end

	local results = run_benchmarks("Benchmark", vlabels, hlabels, function(vlabel, hlabel)
		print("Running $vlabel on $hlabel")
		local format_data = hlabel_map[hlabel]
		local function_data = vlabel_map[vlabel]
		local format = ccgl.texture_format[format_data[1]]
		local texture = ccgl._create_texture(format, texture_width, texture_height)
		local data = {}

		for i = 1, #function_data[2] do
			data[i] = function_data[2][i]
		end

		for i = 1, #format_data[2] do
			table.insert(data, format_data[2][i])
		end

		if format_data[1]:find "int" then
			ccgl[function_data[1]](texture, table.unpack(data))
			ccgl._texture_blit_term(texture, term)
		end

		return duration, iterations,
		       ccgl[function_data[1]],
		       texture, table.unpack(data)
	end)

	-- term.setCursorPos(1, 1)
	-- term.clear()

	print()
	print()
	print_results(results)
	save_results("ccgl/benchmark/results/functions/texture_draw_poly.txt", results)
end
