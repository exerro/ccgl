
require "/mesh/mesh-build/include/core"
require "/mesh/mesh-build/include/lua"

require "./common-build-tasks"

tasks.setup:extends_from "mesh::copy"
tasks.setup.config {
	from = MESH_ROOT_PATH / "src",
	to = MESH_ROOT_PATH / "build/src",
}

tasks.check_syntax:extends_from "lua::check_syntax"
tasks.check_syntax:depends_on(tasks.setup)
tasks.check_syntax.config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
}

tasks.check:extends_from "ccgl::check-todos"
tasks.check:depends_on(tasks.check_syntax)
tasks.check.config {
	include = MESH_ROOT_PATH / "build/src/**.lua",
}

tasks.preprocess:extends_from "ccgl::preprocess"
tasks.preprocess:depends_on(tasks.check)
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

tasks.clean:extends_from "mesh::clean" {
	path = MESH_ROOT_PATH / "build"
}
