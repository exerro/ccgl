
-- TODO: _alpha variant

-- @export
local function _texture_fill_poly(texture, points, join_to_start, ...)
	local tw, th = texture.width, texture.height
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local min_y_all = 100000000
	local max_y_all = -1
	local xs = {}
	local xs_len = {}
	local num_points = #points

	for i = 1, num_points - (join_to_start and 1 or 3), 2 do
		local x0 = points[i]
		local y0 = points[i + 1]
		local x1 = points[(i + 1) % num_points + 1]
		local y1 = points[(i + 2) % num_points + 1]

		if y0 ~= y1 then
			if y0 > y1 then
				y0, y1 = y1, y0
				x0, x1 = x1, x0
			end

			local m = (x1 - x0) / (y1 - y0)
			local c = x0 - m * y0
			local y0f = math_floor(y0 + 0.5)
			local y1f = math_floor(y1 + 0.5)

			if y0f < min_y_all then min_y_all = y0f end
			if y1f > max_y_all then max_y_all = y1f end

			for y = y0f, y1f do
				local y_min = y - 0.5
				local y_max = y + 0.5
				local xs_idx = xs_len[y]

				if y_min < y0 then y_min = y0 end
				if y_max > y1 then y_max = y1 end

				local x_min = m * y_min + c
				local x_max = m * y_max + c
				local drawing_down = true -- TODO: change to signed number and multiply on test

				if x_min > x_max then
					x_min, x_max = x_max, x_min
					drawing_down = false
				end

				if not xs_idx then
					xs[y] = { { x_min, x_max, drawing_down } }
					xs_len[y] = 1
				else
					local t = xs[y]
					xs_idx = xs_idx + 1
					t[xs_idx] = { x_min, x_max, drawing_down }
					xs_len[y] = xs_idx
				end
			end
		end
	end

	if min_y_all < 0 then
		min_y_all = 0
	end

	if max_y_all >= th then
		max_y_all = th - 1
	end

	for y = min_y_all, max_y_all do
		local y_base_index = y * tw
		local xs = xs[y]
		local i = 1
		local xs_len = #xs
		table_sort(xs, function(a, b) return a[1] < b[1] or a[1] == b[1] and a[2] < b[2] end)

		while i <= xs_len do
			local min = xs[i]
			local min_x = min[1]
			local min_dir = min[3]
			i = i + 1

			while true do
				local max = xs[i]
				if max then
					local max_x = max[2]
					if min_x ~= max_x or min_dir == max[3] then
						min_x = math_floor(min_x + 0.5)
						max_x = math_floor(max_x + 0.49)

						if min_x < 0 then min_x = 0 end
						if max_x >= tw then max_x = tw - 1 end

						local index = (y_base_index + min_x) * data_length

						for x = 1, max_x - min_x + 1 do
							for j = 1, data_length do
								index = index + 1
								texture[index] = pixel_data[j]
							end
						end
						break
					else
						i = i + 1
					end
				else
					break
				end
			end
		end
	end
end

-- @export
local function _texture_outline_poly(texture, points, join_to_start, ...)
	local tw, th = texture.width, texture.height
	local pixel_data, data_length = texture_pixel_data(texture.format, ...)
	local min_y_all = 100000000
	local max_y_all = -1
	local xs = {}
	local xs_len = {}
	local num_points = #points

	for i = 1, num_points - (join_to_start and 1 or 3), 2 do
		local x0 = points[i]
		local y0 = points[i + 1]
		local x1 = points[(i + 1) % num_points + 1]
		local y1 = points[(i + 2) % num_points + 1]

		if y0 == y1 then
			local y = math_floor(y0)
			local xs_idx = xs_len[y]

			if x0 > x1 then x0, x1 = x1, x0 end

			if not xs_idx then
				xs[y] = { { x0, x1 } }
				xs_len[y] = 1
			else
				local t = xs[y]
				xs_idx = xs_idx + 1
				t[xs_idx] = { x0, x1 }
				xs_len[y] = xs_idx
			end
		else
			if y0 > y1 then
				y0, y1 = y1, y0
				x0, x1 = x1, x0
			end

			local m = (x1 - x0) / (y1 - y0)
			local c = x0 - m * y0
			local y0f = math_floor(y0 + 0.5)
			local y1f = math_floor(y1 + 0.5)

			if y0f < min_y_all then min_y_all = y0f end
			if y1f > max_y_all then max_y_all = y1f end

			for y = y0f, y1f do
				local y_min = y - 0.5
				local y_max = y + 0.5
				local xs_idx = xs_len[y]

				if y_min < y0 then y_min = y0 end
				if y_max > y1 then y_max = y1 end

				local x_min = m * y_min + c
				local x_max = m * y_max + c

				if x_min > x_max then x_min, x_max = x_max, x_min end

				if not xs_idx then
					xs[y] = { { x_min, x_max } }
					xs_len[y] = 1
				else
					local t = xs[y]
					xs_idx = xs_idx + 1
					t[xs_idx] = { x_min, x_max }
					xs_len[y] = xs_idx
				end
			end
		end
	end

	if min_y_all < 0 then
		min_y_all = 0
	end

	if max_y_all >= th then
		max_y_all = th - 1
	end

	for y = min_y_all, max_y_all do
		local y_base_index = y * tw
		local xs = xs[y]

		for i = 1, #xs do
			local range = xs[i]
			local min_x = math_floor(range[1] + 0.5)
			local max_x = math_floor(range[2] + 0.49)
			local index = (y_base_index + min_x) * data_length

			for x = 1, max_x - min_x + 1 do
				for j = 1, data_length do
					index = index + 1
					texture[index] = pixel_data[j]
				end
			end
		end
	end
end
