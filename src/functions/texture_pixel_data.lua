
-- @internal
local function texture_pixel_data(format, ...)
	local pixel_data = {}
	local bc, fc, ch = ...
	local data_length = 0
	local is_text = false

	if format == texture_format.bfc_rgb then
		local br = bc[1]
		local bg = bc[2] or br
		local bb = bc[3] or bg
		local fr = fc[1]
		local fg = fc[2] or fr
		local fb = fc[3] or fg
		pixel_data = { br, bg, bb, fr, fg, fb, ch }
		data_length = 7
		is_text = true
	elseif format == texture_format.bfc_rgba then
		local br = bc[1]
		local bg = bc[2] or br
		local bb = bc[3] or bg
		local ba = bc[4] or 1
		local fr = fc[1]
		local fg = fc[2] or fr
		local fb = fc[3] or fg
		local fa = fc[4] or 1
		pixel_data = { br, bg, bb, fr, fg, fb, ch }
		pixel_data = { br, bg, bb, ba, fr, fg, fb, fa, ch }
		data_length = 9
		is_text = true
	elseif format == texture_format.bfc_int then
		pixel_data = { bc * TEXTURE_FORMAT_BFC_INT_MULTIPLIER + fc, ch }
		data_length = 2
		is_text = true
	elseif format == texture_format.rgb then
		pixel_data = bc
		data_length = 3
	elseif format == texture_format.rgba then
		pixel_data = bc
		data_length = 4
	elseif format == texture_format.int or format == texture_format.vec1 then
		pixel_data = type(bc) == "table" and bc or { bc }
		data_length = 1
	elseif format == texture_format.vec2 then
		pixel_data = bc
		data_length = 2
	elseif format == texture_format.vec3 then
		pixel_data = bc
		data_length = 3
	elseif format == texture_format.vec4 then
		pixel_data = bc
		data_length = 4
	end

	return pixel_data, data_length, is_text
end
