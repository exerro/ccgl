
-- @enum
-- @internal-export
local texture_format = {
	-- @enum-member rgbrgbc   -- (num, num, num, num, num, num, int)
	-- @enum-member rgbargbac -- (num, num, num, num, num, num, num, num, int)
	-- @enum-member pix2c     -- (int*int, int)
	-- @enum-member rgb       -- (num, num, num)
	-- @enum-member rgba      -- (num, num, num, num)
	-- @enum-member pix       -- (int)
	-- @enum-member vec1      -- (num)
	-- @enum-member vec2      -- (num, num)
	-- @enum-member vec3      -- (num, num, num)
	-- @enum-member vec4      -- (num, num, num, num)
}

-- legacy texture format names
texture_format.bfc_rgb  = texture_format.rgbrgbc
texture_format.bfc_rgba = texture_format.rgbargbac
texture_format.bfc_int  = texture_format.pix2c
texture_format.int      = texture_format.pix

-- @internal-export
local function _texture_format_size(format)
	if format == texture_format.bfc_rgb then
		return 7
	elseif format == texture_format.bfc_rgba then
		return 9
	elseif format == texture_format.bfc_int then
		return 2
	elseif format == texture_format.rgb then
		return 3
	elseif format == texture_format.rgba then
		return 4
	elseif format == texture_format.int then
		return 1
	elseif format == texture_format.vec1 then
		return 1
	elseif format == texture_format.vec2 then
		return 2
	elseif format == texture_format.vec3 then
		return 3
	elseif format == texture_format.vec4 then
		return 4
	end
end
