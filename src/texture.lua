
-- @internal
local BYTE_SPACE = (" "):byte()

-- @internal-export
local TEXTURE_FORMAT_BFC_INT_MULTIPLIER = 256

--------------------------------------------------------------------------------

-- @export
local function _create_texture(format, width, height)
	local texture_format_size = _texture_format_size(format)
	local texture_data
	local texture = {
		__ccgl_type = ccgl_type.texture,
		width = width,
		height = height,
		format = format
	}

	if format == texture_format.bfc_rgb then
		texture_data = { 0, 0, 0, 0, 0, 0, BYTE_SPACE }
	elseif format == texture_format.bfc_rgba then
		texture_data = { 0, 0, 0, 0, 0, 0, 0, 0, BYTE_SPACE }
	elseif format == texture_format.bfc_int then
		texture_data = { 0, BYTE_SPACE }
	elseif format == texture_format.rgb then
		texture_data = { 0, 0, 0 }
	elseif format == texture_format.rgba then
		texture_data = { 0, 0, 0, 0 }
	elseif format == texture_format.int then
		texture_data = { 0 }
	elseif format == texture_format.vec1 then
		texture_data = { 0 }
	elseif format == texture_format.vec2 then
		texture_data = { 0, 0 }
	elseif format == texture_format.vec3 then
		texture_data = { 0, 0, 0 }
	elseif format == texture_format.vec4 then
		texture_data = { 0, 0, 0, 0 }
	end

	for i = 0, width * height * texture_format_size - 1, texture_format_size do
		for j = 1, texture_format_size do
			texture[i + j] = texture_data[j]
		end
	end

	return texture
end

-- @export
local function create_texture(width, height, format)
	if not check_is_enum(format, texture_format) then return errorf("format given ('%s') is not a texture format", tostring(format)) end
	if type(width) ~= "number" then return errorf("width given (%s) is not a number", tostring(width)) end
	if type(height) ~= "number" then return errorf("height given (%s) is not a number", tostring(height)) end
	if width < 0 then return errorf("width given (%d) is less than 0", tonumber(width)) end
	if height < 0 then return errorf("height given (%d) is less than 0", tonumber(height)) end

	return _create_texture(math.floor(width), math.floor(height), format)
end

--------------------------------------------------------------------------------

-- @todo: optimise
-- @export
local function _texture_blit(a, b, dx, dy)
	dx = dx or 0
	dy = dy or 0

	local aw, ah = a.width, a.height
	local bw, bh = b.width, b.height
	local minw = math_min(bw - dx, aw)
	local minh = math_min(bh - dy, ah)
	local size = _texture_format_size(a.format)
	local minws = minw * size
	local a_idx0 = aw * size
	local b_idx0 = (dx - 1) * size

	for y = 0, minh - 1 do
		local a_idx = y * a_idx0 - size
		local b_idx = ((y + dy) * bw) * size + b_idx0

		for x = size, minws, size do
			for i = 1 + x, size + x do
				b[b_idx + i] = a[a_idx + i]
			end
		end
	end
end

-- _texture_map_rgb_int    - blit between formats
-- _texture_map_int_rgb    - blit between formats
-- _texture_map_rgb        - blit between RGB formats
-- _texture_map_rgb_alpha  - blit between RGB formats with alpha
