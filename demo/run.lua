
local file = ...

shell.run("/ccgl/bin/preprocess -d /ccgl/demo -i /ccgl/demo/" .. file .. ".lua -o /.demo_to_run.lua")
shell.run("/ccgl/bin/build")
_ENV.ccgl = dofile("/ccgl.lua")
assert(loadfile("/.demo_to_run.lua", _ENV))(select(2, ...))
