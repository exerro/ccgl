
-- @export
local function _texture_int_subpixel_shrink(sourceID, destinationID, palette)
	local source = ccgl_objects[sourceID]
	local destination = ccgl_objects[destinationID]
	local sw = source.width
	local dw, dh = destination.width, destination.height
	local dest_idx = 1
	local src_idx = 1
	local src_row_delta = sw * 1
	local src_line_delta = sw * 2
	local colour_table = {}
	local no_palette = not palette

	for y = 1, dh do
		for x = 1, dw do
			local row1 = src_idx + src_row_delta
			local row2 = row1 + src_row_delta
			local col0 = source[src_idx]
			local col1 = source[src_idx + 1]
			local col2 = source[row1]
			local col3 = source[row1 + 1]
			local col4 = source[row2]
			local col5 = source[row2 + 1]
			local all_same = col0 == col5 and col1 == col4 and col0 == col3 and col1 == col2 and col0 == col1

			if all_same then
				destination[dest_idx] = col0 * TEXTURE_FORMAT_BFC_INT_MULTIPLIER
				destination[dest_idx + 1] = BYTE_SPACE
			else
				local count0, count1, count2, count3, count4, count5 = 1, 0, 0, 0, 0, 0
				
				if col1 == col0 then count0 = 2
				else count1 = 1 end

				if col2 == col0 then count0 = count0 + 1
				elseif col2 == col1 then count1 = 2
				else count2 = 1 end

				if col3 == col0 then count0 = count0 + 1
				elseif col3 == col1 then count1 = count1 + 1
				elseif col3 == col2 then count2 = 2
				else count3 = 1 end

				if col4 == col0 then count0 = count0 + 1
				elseif col4 == col1 then count1 = count1 + 1
				elseif col4 == col2 then count2 = count2 + 1
				elseif col4 == col3 then count3 = 2
				else count4 = 1 end

				if col5 == col0 then count0 = count0 + 1
				elseif col5 == col1 then count1 = count1 + 1
				elseif col5 == col2 then count2 = count2 + 1
				elseif col5 == col3 then count3 = count3 + 1
				elseif col5 == col4 then count4 = 2
				else count5 = 1 end

				-- local colour_ptr = 1
				-- local max_count0, max_count1 = count0, 0
				-- local max_col0, max_col1 = col0, nil

				-- if count1 > 0 then
				-- 	if max_count1 == 0 then max_count1 = count1; max_col1 = col1
				-- 	elseif count1 > max_count0 and max_count0 < max_count1 then
				-- 		colour_table[colour_ptr] = max_col0; colour_ptr = colour_ptr + 1
				-- 		max_count0 = count1; max_col0 = col1
				-- 	elseif count1 > max_count1 then
				-- 		colour_table[colour_ptr] = max_col1; colour_ptr = colour_ptr + 1
				-- 		max_count1 = count1; max_col1 = col1
				-- 	else colour_table[colour_ptr] = col1; colour_ptr = colour_ptr + 1 end
				-- end

				-- if count2 > 0 then
				-- 	if max_count1 == 0 then max_count1 = count2; max_col1 = col2
				-- 	elseif count2 > max_count0 and max_count0 < max_count1 then
				-- 		colour_table[colour_ptr] = max_col0; colour_ptr = colour_ptr + 1
				-- 		max_count0 = count2; max_col0 = col2
				-- 	elseif count2 > max_count1 then
				-- 		colour_table[colour_ptr] = max_col1; colour_ptr = colour_ptr + 1
				-- 		max_count1 = count2; max_col1 = col2
				-- 	else colour_table[colour_ptr] = col2; colour_ptr = colour_ptr + 1 end
				-- end

				-- if count3 > 0 then
				-- 	if max_count1 == 0 then max_count1 = count3; max_col1 = col3
				-- 	elseif count3 > max_count0 and max_count0 < max_count1 then
				-- 		colour_table[colour_ptr] = max_col0; colour_ptr = colour_ptr + 1
				-- 		max_count0 = count3; max_col0 = col3
				-- 	elseif count3 > max_count1 then
				-- 		colour_table[colour_ptr] = max_col1; colour_ptr = colour_ptr + 1
				-- 		max_count1 = count3; max_col1 = col3
				-- 	else colour_table[colour_ptr] = col3; colour_ptr = colour_ptr + 1 end
				-- end

				-- if count4 > 0 then
				-- 	if max_count1 == 0 then max_count1 = count4; max_col1 = col4
				-- 	elseif count4 > max_count0 and max_count0 < max_count1 then
				-- 		colour_table[colour_ptr] = max_col0; colour_ptr = colour_ptr + 1
				-- 		max_count0 = count4; max_col0 = col4
				-- 	elseif count4 > max_count1 then
				-- 		colour_table[colour_ptr] = max_col1; colour_ptr = colour_ptr + 1
				-- 		max_count1 = count4; max_col1 = col4
				-- 	else colour_table[colour_ptr] = col4; colour_ptr = colour_ptr + 1 end
				-- end

				-- if count5 > 0 then
				-- 	if max_count1 == 0 then max_count1 = count5; max_col1 = col5
				-- 	elseif count5 > max_count0 and max_count0 < max_count1 then
				-- 		colour_table[colour_ptr] = max_col0; colour_ptr = colour_ptr + 1
				-- 		max_count0 = count5; max_col0 = col5
				-- 	elseif count5 > max_count1 then
				-- 		colour_table[colour_ptr] = max_col1; colour_ptr = colour_ptr + 1
				-- 		max_count1 = count5; max_col1 = col5
				-- 	else colour_table[colour_ptr] = col5; colour_ptr = colour_ptr + 1 end
				-- end

				local max_count0, max_count1 = count0, 0
				local max_col0, max_col1 = col0, nil

				if count1 > 0 then
					if count1 > max_count0 then
						max_count0 = count1; max_col0 = col1
					elseif count1 > max_count1 then
						max_count1 = count1; max_col1 = col1
					end
				end

				if count2 > 0 then
					if count2 > max_count0 and max_count0 < max_count1 then
						max_count0 = count2; max_col0 = col2
					elseif count2 > max_count1 then
						max_count1 = count2; max_col1 = col2
					end
				end

				if count3 > 0 then
					if count3 > max_count0 and max_count0 < max_count1 then
						max_count0 = count3; max_col0 = col3
					elseif count3 > max_count1 then
						max_count1 = count3; max_col1 = col3
					end
				end

				if count4 > 0 then
					if count4 > max_count0 and max_count0 < max_count1 then
						max_count0 = count4; max_col0 = col4
					elseif count4 > max_count1 then
						max_count1 = count4; max_col1 = col4
					end
				end

				if count5 > 0 then
					if count5 > max_count0 and max_count0 < max_count1 then
						max_count0 = count5; max_col0 = col5
					elseif count5 > max_count1 then
						max_count1 = count5; max_col1 = col5
					end
				end

				if colour_ptr == 1 or no_palette then
					local ch = 128
					if col5 == max_col1 then max_col0, max_col1 = max_col1, max_col0 end
					if col0 == max_col1 then ch = 129 end
					if col1 == max_col1 then ch = ch + 2 end
					if col2 == max_col1 then ch = ch + 4 end
					if col3 == max_col1 then ch = ch + 8 end
					if col4 == max_col1 then ch = ch + 16 end

					destination[dest_idx] = max_col0 * TEXTURE_FORMAT_BFC_INT_MULTIPLIER + (max_col1 or 0)
					destination[dest_idx + 1] = ch
				else
					error("TODO") -- reduce colour set and draw
				end
			end

			src_idx = src_idx + 2
			dest_idx = dest_idx + 2
		end
		src_idx = src_idx + src_line_delta
	end
end

-- TODO: texture_rgb[a]_subpixel_shrink
