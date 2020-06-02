
local RADIANS_TO_DEGREES = 180 / math.pi
local DEGREES_TO_RADIANS = math.pi / 180
local m_rad = math.rad or error("unsupported function", 0)
local m_deg = math.deg or error("unsupported function", 0)
local m_sin = math.sin or error("unsupported function", 0)
local m_cos = math.cos or error("unsupported function", 0)
local m_tan = math.tan or error("unsupported function", 0)
local m_asin = math.asin or error("unsupported function", 0)
local m_acos = math.acos or error("unsupported function", 0)
local m_atan = math.atan or error("unsupported function", 0)
local m_exp = math.exp or error("unsupported function", 0)
local m_log = math.log or error("unsupported function", 0)
local m_sqrt = math.sqrt or error("unsupported function", 0)
local m_abs = math.abs or error("unsupported function", 0)
local m_floor = math.floor or error("unsupported function", 0)
local m_ceil = math.ceil or error("unsupported function", 0)
local m_min = math.min or error("unsupported function", 0)
local m_max = math.max or error("unsupported function", 0)
local m_pow = math.pow or error("unsupported function", 0)

local function m_exp2(v) return 2^v end
local function m_log2(v) return m_log(v) / m_log(2) end
local function m_isqrt(v) return 1/m_sqrt(v) end
local function m_sign(v) if v > 0 then return 1 elseif v == 0 then return 0 else return 1 end end
local function m_fract(v) return v % 1 end
local function m_clamp(v, a, b) if v < a then return a elseif v > b then return b else return v end end

local function apply_num_t(f, v, ...)
	if type(v) == "number" then
		return f(v, ...)
	elseif #v == 1 then
		return { f(v[1], ...) }
	elseif #v == 2 then
		return { f(v[1], ...), f(v[2], ...) }
	elseif #v == 3 then
		return { f(v[1], ...), f(v[2], ...), f(v[3], ...) }
	elseif #v == 4 then
		return { f(v[1], ...), f(v[2], ...), f(v[3], ...), f(v[4], ...) }
	end
end

-- @internal-export
local sl = {}

-- texel_rgba(texture_type.(bfc_)?vec4, uv)
-- texel_rgb (texture_type.(bfc_)?vec[34], uv)
-- texel_vec4(texture_type.(bfc_)?vec4, uv)
-- texel_vec3(texture_type.(bfc_)?vec[34], uv)
-- texel_vec2(texture_type.vec[234], uv)
-- texel_vec1(texture_type.vec[1234], uv)
-- texel_int(texture_type.(bfc_)?int, uv)
-- texel_bc_rgba(texture_type.bfc_vec[34], uv)
-- texel_fc_rgba(texture_type.bfc_vec[34], uv)
-- texel_bc_rgb(texture_type.bfc_vec3, uv)
-- texel_fc_rgb(texture_type.bfc_vec3, uv)
-- texel_bc_int(texture_type.bfc_int, uv)
-- texel_fc_int(texture_type.bfc_int, uv)
-- texel_char(texture_type.bfc_*, uv)

-- TODO: texel variants

function sl.radians(vecN) return apply_num_t(m_rad, vecN) end -- (num_t) -> num_t
function sl.degrees(vecN) return apply_num_t(m_deg, vecN) end -- (num_t) -> num_t
function sl.sin(vecN) return apply_num_t(m_sin, vecN) end -- (num_t) -> num_t
function sl.cos(vecN) return apply_num_t(m_cos, vecN) end -- (num_t) -> num_t
function sl.tan(vecN) return apply_num_t(m_tan, vecN) end -- (num_t) -> num_t
function sl.asin(vecN) return apply_num_t(m_asin, vecN) end -- (num_t) -> num_t
function sl.acos(vecN) return apply_num_t(m_acos, vecN) end -- (num_t) -> num_t
function sl.atan(vecN) return apply_num_t(m_atan, vecN) end -- (num_t) -> num_t
function sl.exp(vecN) return apply_num_t(m_exp, vecN) end -- (num_t) -> num_t
function sl.log(vecN) return apply_num_t(m_log, vecN) end -- (num_t) -> num_t
function sl.exp2(vecN) return apply_num_t(m_exp2, vecN) end -- (num_t) -> num_t
function sl.log2(vecN) return apply_num_t(m_log2, vecN) end -- (num_t) -> num_t
function sl.sqrt(vecN) return apply_num_t(m_sqrt, vecN) end -- (num_t) -> num_t
function sl.isqrt(vecN) return apply_num_t(m_isqrt, vecN) end -- (num_t) -> num_t
function sl.abs(vecN) return apply_num_t(m_abs, vecN) end -- (num_t) -> num_t
function sl.sign(vecN) return apply_num_t(m_sign, vecN) end -- (num_t) -> num_t
function sl.floor(vecN) return apply_num_t(m_floor, vecN) end -- (num_t) -> num_t
function sl.ceil(vecN) return apply_num_t(m_ceil, vecN) end -- (num_t) -> num_t
function sl.fract(vecN) return apply_num_t(m_fract, vecN) end -- (num_t) -> num_t

-- (num_t, num_t) -> num_t
-- (num_t, num) -> num_t
function sl.pow(v, n)
	if type(n) == "number" then
		return apply_num_t(m_pow, v, n)
	else
		if #v == 2 then
			return { v[1] ^ n[1], v[2] ^ n[2] }
		elseif #v == 3 then
			return { v[1] ^ n[1], v[2] ^ n[2], v[3] ^ n[3] }
		elseif #v == 4 then
			return { v[1] ^ n[1], v[2] ^ n[2], v[3] ^ n[3], v[4] ^ n[4] }
		end
	end
end

-- (num_t, num_t) -> num_t
-- (num_t, num) -> num_t
function sl.mod(v, n)
	if type(n) == "number" then
		if type(v) == "number" then
			return v % n
		elseif #v == 2 then
			return { v[1] % n, v[2] % n }
		elseif #v == 3 then
			return { v[1] % n, v[2] % n, v[3] % n }
		elseif #v == 4 then
			return { v[1] % n, v[2] % n, v[3] % n, v[4] % n }
		end
	else
		if #v == 2 then
			return { v[1] % n[1], v[2] % n[2] }
		elseif #v == 3 then
			return { v[1] % n[1], v[2] % n[2], v[3] % n[3] }
		elseif #v == 4 then
			return { v[1] % n[1], v[2] % n[2], v[3] % n[3], v[4] % n[4] }
		end
	end
end

-- (num_t, num_t, num_t) -> num_t
-- (num_t, num, num) -> num_t
function sl.clamp(v, a, b)
	if type(a) == "number" then
		return apply_num_t(v, m_clamp, a, b)
	else
		if #v == 2 then
			return { m_clamp(v[1], a[1], b[1]), m_clamp(v[2], a[2], b[2]) }
		elseif #v == 3 then
			return { m_clamp(v[1], a[1], b[1]), m_clamp(v[2], a[2], b[2]), m_clamp(v[3], a[3], b[3]) }
		elseif #v == 4 then
			return { m_clamp(v[1], a[1], b[1]), m_clamp(v[2], a[2], b[2]), m_clamp(v[3], a[3], b[3]), m_clamp(v[4], a[4], b[4]) }
		end
	end
end

function sl.min(v, n) return apply_num_t(v, m_min, n) end -- (num_t, num) -> num_t
function sl.max(v, n) return apply_num_t(v, m_max, n) end -- (num_t, num) -> num_t

-- mix(num_t, num_t, num_t): num_t
-- mix(num_t, num_t, num): num_t
-- step(num_t, num_t): num_t
-- step(num_t, num): num_t
-- length(num_t): num
-- distance(num_t, num_t): num

function sl.dot(a, b)
	if type(a) == "number" then
		return a * b
	else
		local total = 0
		for i = 1, #a do
			total = total + a[i] * b[i]
		end
		return total
	end
end

-- cross(vec3, vec3): vec3
-- normalise(num_t): num_t
-- reflect(num_t, num_t): num_t
-- refract(num_t, num_t, num): num_t
-- any(bool_t): bool
-- all(bool_t): bool
-- mcompmult(mat_t, mat_t): mat_t
-- transpose(mat_t): mat_t
-- ? inverse(mat_t): mat_t

-- vec2(num): vec2
-- vec3(num): vec3
-- vec4(num): vec4

-- vec2(num, num): vec2
-- vec3(num, num, num): vec3
-- vec4(num, num, num): vec4
-- vec4(num, num, num, num): vec4

-- vec3(num, vec2): vec3
-- vec3(vec2, num): vec3

-- vec4(num, num, vec2): vec4
-- vec4(num, vec2, num): vec4
-- vec4(vec2, num, num): vec4
-- vec4(num, vec3): vec4
-- vec4(vec3, num): vec4
-- vec4(vec3): vec4

-- mat2(vec2, vec2): mat2
-- mat3(vec3, vec3, vec3): mat3
-- mat4(vec4, vec4, vec4, vec4): mat4
