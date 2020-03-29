
-- TODO: _alpha variant

-- @export
local function _texture_fill_rect(texture, x0, y0, w, h, ...)
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local tw, th = texture.width, texture.height

	if x0 < 0 then w = w + x0; x0 = 0 end
	if y0 < 0 then h = h + y0; y0 = 0 end
	if x0 + w > tw then w = tw - x0 end
	if y0 + h > th then h = th - y0 end

	local xm = x0 + w - 1
	local idx = (y0 * tw + x0) * data_length
	local y_inc = (tw - w) * data_length

	for y = 1, h do
		for x = x0, xm do
			for i = 1, data_length do
				idx = idx + 1
				texture[idx] = pixel_data[i]
			end
		end
		idx = idx + y_inc
	end
end

-- @export
local function _texture_outline_rect(texture, x0, y0, w, h, ...)
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local tw, th = texture.width, texture.height

	local top_line_in = y0 >= 0 and y0 < th
	local bottom_line_in = y0 + h > 0 and y0 + h <= th
	local left_line_in = x0 >= 1 and x0 < tw - 1
	local right_line_in = x0 + w > 1 and x0 + w <= tw - 1

	if top_line_in or bottom_line_in then
		local h_x0, h_w = x0, w
		if h_x0 < 0 then h_w = h_w + h_x0; h_x0 = 0 end
		if h_x0 + h_w > tw then h_w = tw - h_x0 end

		if top_line_in then
			local idx = (y0 * tw + h_x0) * data_length

			for x = 1, h_w do
				for i = 1, data_length do
					idx = idx + 1
					texture[idx] = pixel_data[i]
				end
			end
		end

		if bottom_line_in then
			local idx = ((y0 + h - 1) * tw + h_x0) * data_length

			for x = 0, h_w - 1 do
				for i = 1, data_length do
					idx = idx + 1
					texture[idx] = pixel_data[i]
				end
			end
		end
	end

	if left_line_in or right_line_in then
		local v_y0, v_h = y0 + 1, h - 2
		if v_y0 < 0 then v_h = v_h + v_y0; v_y0 = 0 end
		if v_y0 + v_h > th then v_h = th - v_y0 end
		local delta = tw * data_length

		if left_line_in then
			local idx = (v_y0 * tw + x0) * data_length

			for y = 1, v_h do
				for i = 1, data_length do
					texture[idx + i] = pixel_data[i]
				end
				idx = idx + delta
			end
		end

		if right_line_in then
			local idx = (v_y0 * tw + x0 + w - 1) * data_length

			for y = 1, v_h do
				for i = 1, data_length do
					texture[idx + i] = pixel_data[i]
				end
				idx = idx + delta
			end
		end
	end
end

-- @export
local function _texture_hline(texture, x0, y0, w, ...)
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local tw, th = texture.width, texture.height

	if y0 >= 0 and y0 < th then
		if x0 < 0 then w = w + x0; x0 = 0 end
		if x0 + w > tw then w = tw - x0 end

		local idx = (y0 * tw + x0) * data_length

		for x = 1, w do
			for i = 1, data_length do
				idx = idx + 1
				texture[idx] = pixel_data[i]
			end
		end
	end
end

-- @export
local function _texture_vline(texture, x0, y0, h, ...)
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local tw, th = texture.width, texture.height

	if x0 >= 0 and x0 < tw then
		if y0 < 0 then h = h + y0; y0 = 0 end
		if y0 + h > th then h = th - y0 end

		local delta = tw * data_length
		local idx = (y0 * tw + x0) * data_length

		for y = 1, h do
			for i = 1, data_length do
				texture[idx + i] = pixel_data[i]
			end
			idx = idx + delta
		end
	end
end

-- @export
local function _texture_set_pixel(texture, x0, y0, ...)
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local tw, th = texture.width, texture.height

	if x0 >= 0 and x0 < tw and y0 >= 0 and y0 < th then
		local idx = (y0 * tw + x0) * data_length
		for i = 1, data_length do
			texture[idx + i] = pixel_data[i]
		end
	end
end

-- @export
local function _texture_write(texture, x0, y0, text, ...)
	local pixel_data, data_length, is_text = texture_pixel_data(texture.format, ...)
	if not is_text then return end
	local tw, th = texture.width, texture.height
	local w = #text

	if y0 >= 0 and y0 < th then
		local text_byte_offset = 0
		if x0 < 0 then
			text_byte_offset = -x0
			w = w + x0
			x0 = 0
		end
		if x0 + w > tw then w = tw - x0 end

		local idx = (y0 * tw + x0) * data_length

		for x = 1 + text_byte_offset, w + text_byte_offset do
			local ch = string_byte(text, x)
			for i = 1, data_length - 1 do
				idx = idx + 1
				texture[idx] = pixel_data[i]
			end
			idx = idx + 1
			texture[idx] = ch
		end
	end
end
