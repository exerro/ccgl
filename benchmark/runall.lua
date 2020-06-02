
local all = {
	"functions/texture_blit_term",
	-- "functions/texture_draw",
	"functions/texture_draw_poly",
	"functions/texture_palette",
	"functions/texture_subpixel_convert"
}

local file = ...

shell.run("/ccgl/bin/build")

_ENV.ccgl = dofile("/ccgl.lua")

for i = 1, #all do
	local file = all[i]
	shell.run("/ccgl/bin/preprocess -d /ccgl/benchmark -i /ccgl/benchmark/common.lua -i /ccgl/benchmark/" .. file .. ".lua -o /.benchmark_to_run.lua")
	assert(loadfile("/.benchmark_to_run.lua", _ENV))().benchmark(0.1)
end
