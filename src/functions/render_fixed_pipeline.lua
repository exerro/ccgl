
-- TODO: @todo:

-- @export
local function _render_fixed_pipeline(options)
	local transform = options.transform or { 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 }
	local vertex_buffer = options.vertex_buffer
	local uv_buffer = options.uv_buffer or nil
	local colour_buffer = options.colour_buffer or nil
	local texture = options.texture or nil
	local count = m_min(options.count or vertex_buffer.raw_size / 3, vertex_buffer.raw_size / 3)
	local offset = options.offset or 0
	local elements = options.elements
	local sample_texture = options.sample_texture or nil
	local depth_texture = options.depth_texture or nil
	local colour_transform = options.colour or nil
	local lighting_direction = options.lighting_direction or nil
	local colour_components = colour_buffer and colour_buffer.storage_type.size
	local linear_sampling = options.linear_sampling or false
	local enable_texture_sample = sample_texture and uv_buffer

	if elements == nil then
		elements = {}

		for i = 1, count do
			elements[i] = i - 1
		end
	end

	local txx, txy = transform[01], transform[02]
	local txz, txw = transform[03], transform[04]
	local tyx, tyy = transform[05], transform[06]
	local tyz, tyw = transform[07], transform[08]
	local tzx, tzy = transform[09], transform[10]
	local tzz, tzw = transform[11], transform[12]
	local twx, twy = transform[13], transform[14]
	local twz, tww = transform[15], transform[16]

	local transform_vertex_buffer = {}
	local vertex_buffer_ptr = offset * 3

	for i = 1, count * 4, 4 do
		local x = vertex_buffer[vertex_buffer_ptr]
		local y = vertex_buffer[vertex_buffer_ptr + 1]
		local z = vertex_buffer[vertex_buffer_ptr + 2]

		transform_vertex_buffer[i    ] = (txx * x + txy * y + txz * z + txw)
		transform_vertex_buffer[i + 1] = (tyx * x + tyy * y + tyz * z + tyw)
		transform_vertex_buffer[i + 2] = (tzx * x + tzy * y + tzz * z + tzw)
		transform_vertex_buffer[i + 3] = (twx * x + twy * y + twz * z + tww)

		vertex_buffer_ptr = vertex_buffer_ptr + 3
	end

	for i = 1, #elements, 3 do
		-- get vertex data
		local element0 = elements[i]
		local element1 = elements[i + 1]
		local element2 = elements[i + 2]
		local vertex0_index = element0 * 4
		local vertex1_index = element1 * 4
		local vertex2_index = element2 * 4
		local w0 = transform_vertex_buffer[vertex0_index + 3]
		local z0 = transform_vertex_buffer[vertex0_index + 2]
		local y0 = transform_vertex_buffer[vertex0_index + 1]
		local x0 = transform_vertex_buffer[vertex0_index]
		local w1 = transform_vertex_buffer[vertex1_index + 3]
		local z1 = transform_vertex_buffer[vertex1_index + 2]
		local y1 = transform_vertex_buffer[vertex1_index + 1]
		local x1 = transform_vertex_buffer[vertex1_index]
		local w2 = transform_vertex_buffer[vertex2_index + 3]
		local z2 = transform_vertex_buffer[vertex2_index + 2]
		local y2 = transform_vertex_buffer[vertex2_index + 1]
		local x2 = transform_vertex_buffer[vertex2_index]
		local u0, v0, r0, g0, b0, a0 = 0, 0, 1, 1, 1, 1
		local u1, v1, r1, g1, b1, a1 = 0, 0, 1, 1, 1, 1
		local u2, v2, r2, g2, b2, a2 = 0, 0, 1, 1, 1, 1
		local x0_clip, y0_clip, z0_clip, w0_clip, u0_clip, v0_clip, r0_clip, g0_clip, b0_clip, a0_clip
		local x1_clip, y1_clip, z1_clip, w1_clip, u1_clip, v1_clip, r1_clip, g1_clip, b1_clip, a1_clip
		local x2_clip, y2_clip, z2_clip, w2_clip, u2_clip, v2_clip, r2_clip, g2_clip, b2_clip, a2_clip
		local x3_clip, y3_clip, z3_clip, w3_clip, u3_clip, v3_clip, r3_clip, g3_clip, b3_clip, a3_clip
		local clip_triangles = 0

		if uv_buffer then
			local uv0_index = element0 * 2
			local uv1_index = element1 * 2
			local uv2_index = element2 * 2
			u0, v0 = uv_buffer[uv0_index], uv_buffer[uv0_index + 1]
			u1, v1 = uv_buffer[uv1_index], uv_buffer[uv1_index + 1]
			u2, v2 = uv_buffer[uv2_index], uv_buffer[uv2_index + 1]
		end

		if colour_buffer then
			local colour0_index = element0 * colour_components
			local colour1_index = element1 * colour_components
			local colour2_index = element2 * colour_components
			r0, g0 = colour_buffer[colour0_index], colour_buffer[colour0_index + 1]
			b0, a0 = colour_buffer[colour0_index + 2], colour_buffer[colour0_index + 3] or 1
			r1, g1 = colour_buffer[colour1_index], colour_buffer[colour1_index + 1]
			b1, a1 = colour_buffer[colour1_index + 2], colour_buffer[colour1_index + 3] or 1
			r2, g2 = colour_buffer[colour2_index], colour_buffer[colour2_index + 1]
			b2, a2 = colour_buffer[colour2_index + 2], colour_buffer[colour2_index + 3] or 1
		end

		-- clip vertices

		if z0 < -1 and z1 < -1 and z2 < -1 then
			-- do nothing
		else
			-- reorder vertices such that the first N vertices are within the clipping volume
			-- there is at least one vertex within the clipping volume
			if z0 < -1 then
				-- z0-, z1?, z2?
				-- swap z0 and z2 -> z0?, z1?, z2-
				x0, y0, z0, w0, u0, v0, r0, g0, b0, a0,
				x2, y2, z2, w2, u2, v2, r2, g2, b2, a2 =
				x2, y2, z2, w2, u2, v2, r2, g2, b2, a2,
				x0, y0, z0, w0, u0, v0, r0, g0, b0, a0

				if z0 < -1 then
					-- z0-, z1?, z2- => z0-, z1+, z2-
					-- swap z0 and z1 -> z0+, z1-, z2-
					x0, y0, z0, w0, u0, v0, r0, g0, b0, a0,
					x1, y1, z1, w1, u1, v1, r1, g1, b1, a1 =
					x1, y1, z1, w1, u1, v1, r1, g1, b1, a1,
					x0, y0, z0, w0, u0, v0, r0, g0, b0, a0
				end
			else
				-- z0+, z1?, z2?
				if z1 < -1 then
					-- z0+, z1-, z2?
					-- swap z1 and z2 -> z0+, z1?, z2-
					x1, y1, z1, w1, u1, v1, r1, g1, b1, a1,
					x2, y2, z2, w2, u2, v2, r2, g2, b2, a2 =
					x2, y2, z2, w2, u2, v2, r2, g2, b2, a2,
					x1, y1, z1, w1, u1, v1, r1, g1, b1, a1
				else
					-- z0+, z1+, z2?
				end
			end

			-- for all cases, z0+
			-- for all cases, z1- => z2-
			-- for all cases, z2+ => z1+

			if z1 < -1 then
				-- 1 point inside clipping volume -> 1 triangle in clip space
				-- TODO: find points of intersection on Z=-1 plane between z0-z1 and z0-z2
				-- write clip values [z0, z0-z1, z0-z2]
			elseif z2 < -1 then
				-- 2 points inside clipping volume -> 2 triangles in clip space
				-- TODO: find points of intersection on Z=-1 plane between z0-z2 and z1-z2
				-- write clip values [z0, z0-z2, z1-z2, z1]
			else
				-- 3 points inside clipping volume -> 1 triangle in clip space
				local x0_clip, y0_clip, z0_clip, w0_clip, u0_clip, v0_clip, r0_clip, g0_clip, b0_clip, a0_clip = x0, y0, z0, w0, u0, v0, r0, g0, b0, a0
				local x1_clip, y1_clip, z1_clip, w1_clip, u1_clip, v1_clip, r1_clip, g1_clip, b1_clip, a1_clip = x1, y1, z1, w1, u1, v1, r1, g1, b1, a1
				local x2_clip, y2_clip, z2_clip, w2_clip, u2_clip, v2_clip, r2_clip, g2_clip, b2_clip, a2_clip = x2, y2, z2, w2, u2, v2, r2, g2, b2, a2
			end
		end

		if clip_triangles ~= 0 then
			-- TODO: add raster data for first triangle [0, 1, 2]
		end

		if clip_triangles == 2 then
			-- TODO: add raster data for second triangle [0, 2, 3]
		end
	end

	-- TODO: triangle raster data should be written by lines above
	--       rasterise the data, do depth tests, lighting colour and texture colour transforms, then write to output texture

	--[[
	texture
	depth_texture
	colour_transform
	lighting_direction
	colour_components
	linear_sampling
	enable_texture_sample
	]]
end
