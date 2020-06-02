
-- @internal
local ccgl_objects = setmetatable({}, { __mode = "k" })

-- @internal
local ccgl_types = setmetatable({}, { __mode = "k" })

-- @internal
local TYPE_TEXTURE = "texture"

-- @internal
local function allocate(type)
	local id = {}
	local value = {}
	ccgl_objects[id] = value
	ccgl_types[id] = type
	return value, id
end

-- @export
local function _object_data(id)
	return ccgl_objects[id]
end

--------------------------------------------------------------------------------

-- @internal
local math_min = math.min

-- @internal
local math_max = math.max

-- @internal
local math_floor = math.floor

-- @internal
local math_sqrt = math.sqrt

-- @internal
local table_concat = table.concat

-- @internal
local table_unpack = table.unpack

-- @internal
local table_sort = table.sort

-- @internal
local string_char = string.char

-- @internal
local string_byte = string.byte

-- @internal
local string_rep = string.rep
