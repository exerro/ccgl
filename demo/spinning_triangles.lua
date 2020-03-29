
local w, h = term.getSize()
w = w - 2
h = h - 2
term.clear()
local screen_texture = ccgl._create_texture(ccgl.texture_format.bfc_int, w, h)
local draw_texture = ccgl._create_texture(ccgl.texture_format.int, w * 2, h * 3)
local t = ccemux.nanoTime() / 1000000000
local eventTimer = 1

local polys = {
	{ 1, 1.5, 0, 0, 0, 0.9, -0.6, -0.4, 0.6, -0.4 },
	{ 2, -1.6, 1, 0, 0, 0.4, -0.3, -0.2, 0.3, -0.2 },
	{ 3, 1, 0, 0, 0.5, 0.6, -0.1, -0.5, 1.1, -0.5 },
	{ 4, -2, 0, 0, -1, -0.8, -1.6, 0.3, -0.4, 0.3 },
	{ 5, 3, -1, -0.5, 0, 0, 0.3, 0.3, 0.3, 0 },
	{ 6, -3, -1, -0.5, 0, 0, 0.3, 0.3, 0, 0.3 },
}

while true do
	ccgl._texture_fill_rect(draw_texture, 0, 0, w * 2, h * 3, 0)

	for i = 1, #polys do
		local points = {}
		for j = 5, #polys[i], 2 do
			local s = 1 + math.sin(t * 4) * 0.3
			local st = math.sin(t * polys[i][2]) * s
			local ct = math.cos(t * polys[i][2]) * s
			local x_raw = polys[i][j]
			local y_raw = polys[i][j + 1]
			points[j - 4] = w / 2 * 2 + (polys[i][3] + ct * x_raw - st * y_raw) * h / 2 * 3
			points[j - 3] = h / 2 * 3 + (polys[i][4] + st * x_raw + ct * y_raw) * h / 2 * 3

			-- print("${points[j-1]}, ${points[j]}")
		end
		ccgl._texture_fill_poly(draw_texture, points, true, polys[i][1])
		-- ccgl._texture_fill_poly(draw_texture, points, true, polys[i][1])
		-- ccgl._texture_outline_poly(draw_texture, points, true, polys[i][1] + 8)
		-- ccgl._texture_outline_poly(draw_texture, points, true, 13)
	end

	ccgl._texture_int_subpixel_shrink(draw_texture, screen_texture)
	ccgl._texture_blit_term(screen_texture, term, 1, 1)

	local t0 = ccemux.nanoTime() / 1000000000
	local dt = t0 - t
	t = t0

	-- print(dt / 1000000000)

	eventTimer = eventTimer - dt

	if eventTimer <= 0 then
		os.queueEvent("_")
		os.pullEvent("_")
		eventTimer = 1
	end
end
