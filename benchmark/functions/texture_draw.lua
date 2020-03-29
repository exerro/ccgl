
local functions = {
	"Fill rect 10x10", "_texture_fill_rect", { 1, 1, 10, 10 },
	"Fill rect 20x15", "_texture_fill_rect", { 5, 3, 20, 15 },
	"Outline rect 10x10", "_texture_outline_rect", { 1, 1, 10, 10 },
	"Outline rect 20x15", "_texture_outline_rect", { 5, 3, 20, 15 },
	"Outline rect out-bounds", "_texture_outline_rect", { 5, -1, 30, 5 },
	"Horizontal line 1", "_texture_hline", { 5, 3, 51 },
	"Horizontal line 2", "_texture_hline", { -5, 5, 51 },
	"Vertical line 1", "_texture_vline", { 3, -5, 19 },
	"Vertical line 2", "_texture_vline", { 5, 5, 19 },
	"Write short", "_texture_write", { 5, 5, "Hello world" },
	"Write long", "_texture_write", { -1, 5, "I am a super duper long string that will get trimmed by a few characters hoorah" },
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

	term.setCursorPos(1, 1)
	term.clear()

	local texture = ccgl._create_texture(ccgl.texture_format.int, 8, 10)
	ccgl._texture_fill_rect(texture, 1, 1, 6, 6, 1)
	ccgl._texture_fill_rect(texture, 2, 2, 5, 4, 2)
	ccgl._texture_blit_term(texture, term)
	ccgl._texture_fill_rect(texture, 0, 0, texture.width, texture.height, 0)
	ccgl._texture_fill_rect(texture, -1, 1, 15, 5, 3)
	ccgl._texture_blit_term(texture, term, texture.width + 1)
	ccgl._texture_outline_rect(texture, 1, 1, 6, 6, 1)
	ccgl._texture_outline_rect(texture, 2, 2, 5, 4, 2)
	ccgl._texture_blit_term(texture, term, texture.width * 2 + 2)
	ccgl._texture_fill_rect(texture, 0, 0, texture.width, texture.height, 0)
	ccgl._texture_outline_rect(texture, -1, 1, 15, 5, 3)
	ccgl._texture_blit_term(texture, term, texture.width * 3 + 3)
	print(); print()
	print_results(results)
	save_results("ccgl/benchmark/results/functions/texture_draw.txt", results)
end
