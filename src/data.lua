
-- @export
local function vector(...)
	return { ... }
end

-- @export
local function matrix(...)
	return { ... }
end

-- @export
local function rgb(r, g, b)
	return { r, g or r, b or r }
end

-- @export
local function rgba(r, g, b, a)
	return { r, g or r, b or r, a or 1 }
end

-- @export
local function vec2(x, y)
	return { x, y or x }
end

-- @export
local function vec3(x, y, z)
	return { x, y or x, z or x }
end

-- @export
local function vec4(x, y, z, w)
	return { x, y or x, z or x, w or 1 }
end

-- @export
local function mat22(c1r1, c2r1, c1r2, c2r2)
	return { c1r1, c2r1, c1r2, c2r2 }
end

-- @export
local function mat33(c1r1, c2r1, c3r1, c1r2, c2r2, c3r2, c1r3, c2r3, c3r3)
	return { c1r1, c2r1, c3r1, c1r2, c2r2, c3r2, c1r3, c2r3, c3r3 }
end

-- @export
local function mat44(c1r1, c2r1, c3r1, c4r1, c1r2, c2r2, c3r2, c4r2, c1r3, c2r3, c3r3, c4r3, c1r4, c2r4, c3r4, c4r4)
	return { c1r1, c2r1, c3r1, c4r1, c1r2, c2r2, c3r2, c4r2, c1r3, c2r3, c3r3, c4r3, c1r4, c2r4, c3r4, c4r4 }
end

-- @export
local mat22_identity = { 1, 0, 0, 1 }

-- @export
local mat33_identity = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }

-- @export
local mat44_identity = { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 }
