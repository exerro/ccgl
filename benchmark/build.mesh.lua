
local file = MESH_ARGS[1] or error("Expected a benchmark to run!")

require "/mesh/mesh-build/include/core"
require "/mesh/mesh-build/include/lua"

require "../common-build-tasks"

function tasks:setup_ccgl()
	local root = (MESH_ROOT_PATH / "..").absolute_path()
	local build_file = (MESH_ROOT_PATH / "../build.mesh.lua").absolute_path()
	mesh_get_parent_environment().shell.run("mesh-build -b " .. build_file .. " -r " .. root)
end

tasks.setup_common:extends_from "mesh::copy"
tasks.setup_common.config {
	from = MESH_ROOT_PATH / "common.lua",
	to = MESH_ROOT_PATH / "build/src/common.lua",
}

tasks.setup_benchmark:extends_from "mesh::copy"
tasks.setup_benchmark.config {
	from = MESH_ROOT_PATH / file,
	to = MESH_ROOT_PATH / "build/src/benchmark.lua",
}

tasks.setup:depends_on(tasks.setup_ccgl)
tasks.setup:depends_on(tasks.setup_common)
tasks.setup:depends_on(tasks.setup_benchmark)

tasks.preprocess:extends_from "ccgl::preprocess"
tasks.preprocess:depends_on(tasks.setup)
tasks.preprocess.config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
	header_path = MESH_ROOT_PATH / "build/header.lua",
}

tasks.build:extends_from "ccgl::build"
tasks.build:depends_on(tasks.preprocess)
tasks.build.config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
	header_path = MESH_ROOT_PATH / "build/header.lua",
	output_path = MESH_ROOT_PATH / "build/benchmark.lua",
}

function tasks:run()
	local env = setmetatable({}, { __index = mesh_get_parent_environment() })
	env.ccgl = mesh_get_parent_environment().dofile((MESH_ROOT_PATH / "../build/ccgl.lua").absolute_path())
	env.RESULTS_PATH = (MESH_ROOT_PATH / "results" / file).absolute_path()
	assert(load(self.config.script_path.read(), tostring(self.config.script_path), nil, env))().benchmark(table.unpack(MESH_ARGS, 2))
end

tasks.run:depends_on(tasks.build)
tasks.run.config {
	script_path = MESH_ROOT_PATH / "build/benchmark.lua"
}

tasks.clean:extends_from "mesh::clean" {
	path = MESH_ROOT_PATH / "build"
}
