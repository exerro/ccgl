
local PERCEPTION_SCALER_R = 1
local PERCEPTION_SCALER_G = 1
local PERCEPTION_SCALER_B = 1

-- @export
local function _texture_evaluate_palette(texture, palette_size, fixed_colours, blacklist, blacklist_threshold)
	local delta1, delta2
	local format = texture.format
	local texture_len = texture.width * texture.height
	local blacklist_len = blacklist and #blacklist or 0
	local max_group_count = palette_size - blacklist_len / 3

	blacklist_threshold = blacklist_threshold or 0.064

	if format == texture_format.bfc_rgb then
		delta1, delta2 = 3, 4
		texture_len = texture_len * 7
	elseif format == texture_format.bfc_rgba then
		delta1, delta2 = 4, 5
		texture_len = texture_len * 9
	elseif format == texture_format.rgb then
		delta1, delta2 = 3, 3
		texture_len = texture_len * 3
	elseif format == texture_format.rgba then
		delta1, delta2 = 4, 4
		texture_len = texture_len * 4
	end

	local r0 = texture[1]
	local g0 = texture[2]
	local b0 = texture[3]
	local min_r, min_g, min_b = r0, g0, b0
	local max_r, max_g, max_b = r0, g0, b0
	local tot_r, tot_g, tot_b = r0, g0, b0
	local colour_count = 1
	local idx = 1 + delta1
	local delta1it, delta2it = delta2, delta1

	while idx < texture_len do -- TODO: this doesn't account for the blacklist
		local r = texture[idx]
		local g = texture[idx + 1]
		local b = texture[idx + 2]

		if r < min_r then min_r = r end
		if g < min_g then min_g = g end
		if b < min_b then min_b = b end
		if r > max_r then max_r = r end
		if g > max_g then max_g = g end
		if b > max_b then max_b = b end

		tot_r = tot_r + r
		tot_g = tot_g + g
		tot_b = tot_b + b

		colour_count = colour_count + 1
		idx = idx + delta1it
		delta1it, delta2it = delta2it, delta1it
	end

	local delta_r = (max_r - min_r) * PERCEPTION_SCALER_R
	local delta_g = (max_g - min_g) * PERCEPTION_SCALER_G
	local delta_b = (max_b - min_b) * PERCEPTION_SCALER_B
	local splitting_on = 2
	local selected_mean

	if delta_r > delta_g and delta_r > delta_b then
		splitting_on = 0
		selected_mean = tot_r / colour_count
	elseif delta_g > delta_g and delta_g > delta_b then
		splitting_on = 1
		selected_mean = tot_g / colour_count
	else
		selected_mean = tot_b / colour_count
	end

	local g1, g2 = {}, {}
	local groups = { g1, g2 }
	local g1idx = 1
	local g2idx = 1
	local ass_g1, ass_g2 = false, false
	local tot_g1r, tot_g1g, tot_g1b = 0, 0, 0
	local tot_g2r, tot_g2g, tot_g2b = 0, 0, 0
	local min_g1r, min_g1g, min_g1b
	local min_g2r, min_g2g, min_g2b
	local max_g1r, max_g1g, max_g1b
	local max_g2r, max_g2g, max_g2b

	idx = 1; delta1it = delta1; delta2it = delta2 -- reset iterator parameters

	while idx < texture_len do
		local r = texture[idx]
		local g = texture[idx + 1]
		local b = texture[idx + 2]
		local not_blacklisted = true

		for i = 1, blacklist_len, 3 do
			local d0 = r - blacklist[i]
			local d1 = g - blacklist[i + 1]
			local d2 = b - blacklist[i + 2]

			if d0 * d0 + d1 * d1 + d2 * d2 > blacklist_threshold then
				not_blacklisted = false
				break
			end
		end

		if not_blacklisted then
			local selected_value = r

			if splitting_on == 1 then
				selected_value = g
			elseif splitting_on == 2 then
				selected_value = b
			end

			if selected_value <= selected_mean then
				g1[g1idx] = r
				g1[g1idx + 1] = g
				g1[g1idx + 2] = b
				g1idx = g1idx + 3
				tot_g1r = tot_g1r + r
				tot_g1g = tot_g1g + g
				tot_g1b = tot_g1b + b

				if ass_g1 then
					if r < min_g1r then min_g1r = r end
					if g < min_g1g then min_g1g = g end
					if b < min_g1b then min_g1b = b end
					if r > max_g1r then max_g1r = r end
					if g > max_g1g then max_g1g = g end
					if b > max_g1b then max_g1b = b end
				else
					min_g1r, min_g1g, min_g1b, max_g1r, max_g1g, max_g1b = r, g, b, r, g, b
					ass_g1 = true
				end
			else
				g2[g2idx] = r
				g2[g2idx + 1] = g
				g2[g2idx + 2] = b
				g2idx = g2idx + 3
				tot_g2r = tot_g2r + r
				tot_g2g = tot_g2g + g
				tot_g2b = tot_g2b + b

				if ass_g2 then
					if r < min_g2r then min_g2r = r end
					if g < min_g2g then min_g2g = g end
					if b < min_g2b then min_g2b = b end
					if r > max_g2r then max_g2r = r end
					if g > max_g2g then max_g2g = g end
					if b > max_g2b then max_g2b = b end
				else
					min_g2r, min_g2g, min_g2b, max_g2r, max_g2g, max_g2b = r, g, b, r, g, b
					ass_g2 = true
				end
			end
		end

		idx = idx + delta1it
		delta1it, delta2it = delta2it, delta1it
	end

	local group_delta = {
		(max_g1r - min_g1r) * PERCEPTION_SCALER_R,
		(max_g1g - min_g1g) * PERCEPTION_SCALER_G,
		(max_g1b - min_g1b) * PERCEPTION_SCALER_B,
		ass_g2 and (max_g2r - min_g2r) * PERCEPTION_SCALER_R or nil,
		ass_g2 and (max_g2g - min_g2g) * PERCEPTION_SCALER_G or nil,
		ass_g2 and (max_g2b - min_g2b) * PERCEPTION_SCALER_B or nil
	}
	g1idx, g2idx = (g1idx - 1) / 3, (g2idx - 1) / 3
	local group_size = { g1idx, ass_g2 and g2idx or nil }
	g1idx, g2idx = 1/g1idx, 1/g2idx
	local group_mean = {
		tot_g1r * g1idx, tot_g1g * g1idx, tot_g1b * g1idx,
		ass_g2 and tot_g2r * g2idx or nil, ass_g2 and tot_g2g * g2idx or nil, ass_g2 and tot_g2b * g2idx or nil
	}
	local group_count = ass_g2 and 2 or 1

	while group_count < max_group_count do
		local group_index = 0
		local splitting_on = 2
		local selected_mean = 0
		local max_delta = 0

		for g = 1, group_count do
			local idx = g * 3
			local dr = group_delta[idx - 2]
			local dg = group_delta[idx - 1]
			local db = group_delta[idx]

			if dr > max_delta then
				if dr > dg then
					if dr > db then
						splitting_on = 0
						selected_mean = group_mean[idx - 2]
						max_delta = dr
					else
						splitting_on = 2
						selected_mean = group_mean[idx]
						max_delta = db
					end
				elseif dg > db then
					splitting_on = 1
					selected_mean = group_mean[idx - 1]
					max_delta = dg
				else
					splitting_on = 2
					selected_mean = group_mean[idx]
					max_delta = db
				end
				group_index = g
			elseif dg > max_delta then
				if dg > db then
					splitting_on = 1
					selected_mean = group_mean[idx - 1]
					max_delta = dg
				else
					splitting_on = 2
					selected_mean = group_mean[idx]
					max_delta = db
				end
				group_index = g
			elseif db > max_delta then
				splitting_on = 2
				selected_mean = group_mean[idx]
				max_delta = db
				group_index = g
			end
		end

		if group_index == 0 then break end

		local group = groups[group_index]

		g1, g2 = {}, {}
		g1idx, g2idx = 1, 1
		ass_g1, ass_g2 = false, false
		tot_g1r, tot_g1g, tot_g1b = 0, 0, 0
		tot_g2r, tot_g2g, tot_g2b = 0, 0, 0
		group_count = group_count + 1
		groups[group_index] = g1
		groups[group_count] = g2

		for idx = 1, group_size[group_index] * 3, 3 do
			local r = group[idx]
			local g = group[idx + 1]
			local b = group[idx + 2]
			local selected_value = r

			if splitting_on == 1 then
				selected_value = g
			elseif splitting_on == 2 then
				selected_value = b
			end

			if selected_value <= selected_mean then
				g1[g1idx] = r
				g1[g1idx + 1] = g
				g1[g1idx + 2] = b
				g1idx = g1idx + 3
				tot_g1r = tot_g1r + r
				tot_g1g = tot_g1g + g
				tot_g1b = tot_g1b + b

				if ass_g1 then
					if r < min_g1r then min_g1r = r end
					if g < min_g1g then min_g1g = g end
					if b < min_g1b then min_g1b = b end
					if r > max_g1r then max_g1r = r end
					if g > max_g1g then max_g1g = g end
					if b > max_g1b then max_g1b = b end
				else
					min_g1r, min_g1g, min_g1b, max_g1r, max_g1g, max_g1b = r, g, b, r, g, b
					ass_g1 = true
				end
			else
				g2[g2idx] = r
				g2[g2idx + 1] = g
				g2[g2idx + 2] = b
				g2idx = g2idx + 3
				tot_g2r = tot_g2r + r
				tot_g2g = tot_g2g + g
				tot_g2b = tot_g2b + b

				if ass_g2 then
					if r < min_g2r then min_g2r = r end
					if g < min_g2g then min_g2g = g end
					if b < min_g2b then min_g2b = b end
					if r > max_g2r then max_g2r = r end
					if g > max_g2g then max_g2g = g end
					if b > max_g2b then max_g2b = b end
				else
					min_g2r, min_g2g, min_g2b, max_g2r, max_g2g, max_g2b = r, g, b, r, g, b
					ass_g2 = true
				end
			end
		end

		local g1i = (group_index - 1) * 3
		local g2i = (group_count - 1) * 3

		group_delta[g1i + 1] = (max_g1r - min_g1r) * PERCEPTION_SCALER_R
		group_delta[g1i + 2] = (max_g1g - min_g1g) * PERCEPTION_SCALER_G
		group_delta[g1i + 3] = (max_g1b - min_g1b) * PERCEPTION_SCALER_B
		group_delta[g2i + 1] = (max_g2r - min_g2r) * PERCEPTION_SCALER_R
		group_delta[g2i + 2] = (max_g2g - min_g2g) * PERCEPTION_SCALER_G
		group_delta[g2i + 3] = (max_g2b - min_g2b) * PERCEPTION_SCALER_B
		g1idx, g2idx = (g1idx - 1) / 3, (g2idx - 1) / 3
		group_size[group_index] = g1idx
		group_size[group_count] = g2idx
		g1idx, g2idx = 1/g1idx, 1/g2idx
		group_mean[g1i + 1] = tot_g1r * g1idx
		group_mean[g1i + 2] = tot_g1g * g1idx
		group_mean[g1i + 3] = tot_g1b * g1idx
		group_mean[g2i + 1] = tot_g2r * g2idx
		group_mean[g2i + 2] = tot_g2g * g2idx
		group_mean[g2i + 3] = tot_g2b * g2idx
	end

	local group_average = {}

	for i = 1, group_count do
		local group = groups[i]
		local tot_r, tot_g, tot_b = 0, 0, 0
		local size = group_size[i]
		local size_inv = 1/size
		local idx = (i - 1) * 3

		for j = 1, size * 3, 3 do
			local r, g, b = group[j], group[j + 1], group[j + 2]
			tot_r = tot_r + r * r
			tot_g = tot_g + g * g
			tot_b = tot_b + b * b
			-- for no gamma correction:
			-- tot_r = tot_r + r
			-- tot_g = tot_g + g
			-- tot_b = tot_b + b
		end

		group_average[idx + 1] = math_sqrt(tot_r * size_inv)
		group_average[idx + 2] = math_sqrt(tot_g * size_inv)
		group_average[idx + 3] = math_sqrt(tot_b * size_inv)
		-- for no gamma correction:
		-- group_average[idx + 1] = tot_r * size_inv
		-- group_average[idx + 2] = tot_g * size_inv
		-- group_average[idx + 3] = tot_b * size_inv
	end

	for i = 1, #group_average, 3 do
		local r, g, b = group_average[i], group_average[i + 1], group_average[i + 2]
	end

	return group_average
end
