
local __storage_type_value = 0

local function storage_type_base()
	local mt = {}
	function mt.__index(self, m)
		if type(m) ~= "number" then
			return errorfn("storage type[N] expects a number N, got (%s)", 2, tostring(m))
		end
		local s = {}
		for i = 1, #self.structure do
			s[i] = self.structure[i]
		end
		s[#s + 1] = m
		return { __ccgl_type = self.__ccgl_type, base = self, structure = s, size = self.size * m }
	end
	return setmetatable({ __ccgl_type = __storage_type_value, base = {}, structure = {}, size = 1 }, mt)
end

-- @internal-export
local int = storage_type_base()

-- @internal-export
local num = storage_type_base()

-- @internal-export
local bool = storage_type_base()

-- @export
local float = num

--------------------------------------------------------------------------------

-- @export
local vec1_t = num[1]

-- @export
local vec2_t = num[2]

-- @export
local vec3_t = num[3]

-- @export
local vec4_t = num[4]

-- @export
local mat22_t = num[2][2]

-- @export
local mat33_t = num[3][3]

-- @export
local mat44_t = num[4][4]

-- @export
local vec1i_t = int[1]

-- @export
local vec2i_t = int[2]

-- @export
local vec3i_t = int[3]

-- @export
local vec4i_t = int[4]

-- @export
local vec1b_t = bool[1]

-- @export
local vec2b_t = bool[2]

-- @export
local vec3b_t = bool[3]

-- @export
local vec4b_t = bool[4]
