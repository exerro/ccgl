
-- @todo: optimise
-- @export
local function _texture_blit(aID, bID, dx, dy)
	dx = dx or 0
	dy = dy or 0

	local a = ccgl_objects[aID]
	local b = ccgl_objects[bID]
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
