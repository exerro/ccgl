
local CHAR_0 = (string_byte or string.byte)("0")
local CHAR_A_10 = (string_byte or string.byte)("A") - 10
local FB_COL = 240
local TEX_BLANK_CHAR = (string_byte or string.byte)(" ")

-- @internal-export
local function _texture_bfc_int_blit_term(texture, term, dx, dy, cache_texture)
	local bc = {}
	local fc = {}
	local ch = {}
	local tw = texture.width
	local setCursorPos = term.setCursorPos
	local blit = term.blit
	local tx_idx = 1

	dx = dx or 0
	dy = dy or 0

	if cache_texture then
		local last_col, last_bc, last_fc

		for y = 1, texture.height do
			local dirty = false
			local write_offset = 1
			local write_idx = 1

			for x = 1, tw do
				local col = texture[tx_idx]
				local chr = texture[tx_idx + 1]

				if not dirty and (cache_texture[tx_idx] ~= col or cache_texture[tx_idx + 1] ~= chr) then
					write_offset = x
					dirty = true
				end

				if dirty then
					if last_col ~= col then
						local fc_v = col % TEXTURE_FORMAT_BFC_INT_MULTIPLIER
						local bc_v = col / TEXTURE_FORMAT_BFC_INT_MULTIPLIER
						last_bc = (bc_v < 10 and CHAR_0 or CHAR_A_10) + bc_v
						last_fc = (fc_v < 10 and CHAR_0 or CHAR_A_10) + fc_v
						last_col = col
					end

					bc[write_idx] = last_bc
					fc[write_idx] = last_fc
					ch[write_idx] = chr
					write_idx = write_idx + 1
					cache_texture[tx_idx] = col
					cache_texture[tx_idx + 1] = chr
				end

				tx_idx = tx_idx + 2
			end

			if dirty then
				local len = tw - write_offset + 1
				local ch_s = string_char(table_unpack(ch, 1, len))
				local fc_s = string_char(table_unpack(fc, 1, len))
				local bc_s = string_char(table_unpack(bc, 1, len))

				setCursorPos(write_offset + dx, y + dy)
				blit(ch_s, fc_s, bc_s)
			end
		end
	else
		local last_col, last_bc, last_fc
		
		for y = 1, texture.height do
			for x = 1, tw do
				local col = texture[tx_idx]
				local chr = texture[tx_idx + 1]

				if last_col ~= col then
					local fc_v = col % TEXTURE_FORMAT_BFC_INT_MULTIPLIER
					local bc_v = col / TEXTURE_FORMAT_BFC_INT_MULTIPLIER
					last_bc = (bc_v < 10 and CHAR_0 or CHAR_A_10) + bc_v
					last_fc = (fc_v < 10 and CHAR_0 or CHAR_A_10) + fc_v
					last_col = col
				end

				bc[x] = last_bc
				fc[x] = last_fc
				ch[x] = chr
				tx_idx = tx_idx + 2
			end

			local ch_s = string_char(table_unpack(ch, 1, tw))
			local fc_s = string_char(table_unpack(fc, 1, tw))
			local bc_s = string_char(table_unpack(bc, 1, tw))

			setCursorPos(1 + dx, y + dy)
			blit(ch_s, fc_s, bc_s)
		end
	end
end

-- @internal-export
local function _texture_int_blit_term(texture, term, dx, dy, cache_texture)
	local bc = {}
	local tw = texture.width
	local setCursorPos = term.setCursorPos
	local blit = term.blit
	local tx_idx = 1
	local fc_s_global = string_rep("0", tw)
	local ch_s_global = string_rep(" ", tw)

	dx = dx or 0
	dy = dy or 0

	if cache_texture then
		for y = 1, texture.height do
			local dirty = false
			local write_offset = 1
			local write_idx = 1

			for x = 1, tw do
				local col = texture[tx_idx]

				if not dirty and cache_texture[tx_idx] ~= col then
					write_offset = x
					dirty = true
				end

				if dirty then
					bc[write_idx] = (col < 10 and CHAR_0 or CHAR_A_10) + col
					write_idx = write_idx + 1
					cache_texture[tx_idx] = col
				end

				tx_idx = tx_idx + 1
			end

			if dirty then
				local len = tw - write_offset + 1
				local bc_s = string_char(table_unpack(bc, 1, len))

				setCursorPos(write_offset + dx, y + dy)
				blit(ch_s_global, fc_s_global, bc_s)
			end
		end
	else
		for y = 1, texture.height do
			for x = 1, tw do
				local col = texture[tx_idx]
				bc[x] = (col < 10 and CHAR_0 or CHAR_A_10) + col
				tx_idx = tx_idx + 1
			end

			local bc_s = string_char(table_unpack(bc, 1, tw))

			setCursorPos(1 + dx, y + dy)
			blit(ch_s_global, fc_s_global, bc_s)
		end
	end
end

-- @export
local function _texture_blit_term(texture, term, dx, dy, cache_texture)
	if texture.format == texture_format.bfc_int then
		_texture_bfc_int_blit_term(texture, term, dx, dy, cache_texture)
	else
		_texture_int_blit_term(texture, term, dx, dy, cache_texture)
	end
end
