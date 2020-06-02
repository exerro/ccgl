
-- @internal
local BYTE_SPACE = (" "):byte()

-- @internal-export
local TEXTURE_FORMAT_BFC_INT_MULTIPLIER = 256

--------------------------------------------------------------------------------

-- @export
local function _create_texture(format, width, height)
	local texture_format_size = _texture_format_size(format)
	local texture, id = allocate(TYPE_TEXTURE)

	texture.width = width
	texture.height = height
	texture.format = format

	for i = 1, width * height * texture_format_size do
		texture[i] = 0
	end

	return id
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
