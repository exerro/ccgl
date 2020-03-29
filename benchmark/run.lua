
local file = ...

shell.run("preprocess -d /ccgl/benchmark -i /ccgl/benchmark/common.lua -i /ccgl/benchmark/" .. file .. ".lua -o /benchmark_to_run.lua")
shell.run("/ccgl/bin/build.lua")
_ENV.ccgl = dofile("/ccgl.lua")
assert(loadfile("/benchmark_to_run.lua", _ENV))().benchmark(select(2, ...))
