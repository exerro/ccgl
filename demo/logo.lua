
local w, h = term.getSize()
w = w - 2
h = h - 2
w = 51
h = 19
local texture = ccgl._create_texture(ccgl.texture_format.bfc_int, w, h)
local name_subpixel_texture = ccgl._create_texture(ccgl.texture_format.int, 30, 12)
local name_full_texture = ccgl._create_texture(ccgl.texture_format.bfc_int, 15, 4)

local palette = {
	0.120, 0.160, 0.170, -- dark grey
	0.250, 0.560, 0.670, -- cyan
	0.750, 0.760, 0.770, -- light grey
}

for i = 1, 5 do
	local t = i / 5
	local r_cyan = math.sqrt(palette[1] ^ 2 * t + palette[4] ^ 2 * (1 - t))
	local g_cyan = math.sqrt(palette[2] ^ 2 * t + palette[5] ^ 2 * (1 - t))
	local b_cyan = math.sqrt(palette[3] ^ 2 * t + palette[6] ^ 2 * (1 - t))
	local r_grey = math.sqrt(palette[1] ^ 2 * t + palette[7] ^ 2 * (1 - t))
	local g_grey = math.sqrt(palette[2] ^ 2 * t + palette[8] ^ 2 * (1 - t))
	local b_grey = math.sqrt(palette[3] ^ 2 * t + palette[9] ^ 2 * (1 - t))
	palette[i * 6 + 4] = r_cyan
	palette[i * 6 + 5] = g_cyan
	palette[i * 6 + 6] = b_cyan
	palette[i * 6 + 7] = r_grey
	palette[i * 6 + 8] = g_grey
	palette[i * 6 + 9] = b_grey
end

local text = {
	-- C
	6,  2, 1, true,
	5,  1, 1, true,
	4,  1, 1, true,
	3,  1, 1, true,
	2,  1, 1, true,
	1,  2, 1, true,
	0,  3, 1, true,
	0,  4, 1, true,
	0,  5, 1, true,
	0,  6, 1, true,
	0,  7, 1, true,
	0,  8, 1, true,
	1,  9, 1, true,
	2, 10, 1, true,
	3, 10, 1, true,
	4, 10, 1, true,
	5, 10, 1, true,
	6,  9, 1, true,
	-- C
	14,  2, 1, true,
	13,  1, 1, true,
	12,  1, 1, true,
	11,  1, 1, true,
	10,  1, 1, true,
	 9,  2, 1, true,
	 8,  3, 1, true,
	 8,  4, 1, true,
	 8,  5, 1, true,
	 8,  6, 1, true,
	 8,  7, 1, true,
	 8,  8, 1, true,
	 9,  9, 1, true,
	10, 10, 1, true,
	11, 10, 1, true,
	12, 10, 1, true,
	13, 10, 1, true,
	14,  9, 1, true,
	-- G
	22,  2, 1, false,
	21,  1, 1, false,
	20,  1, 1, false,
	19,  1, 1, false,
	18,  1, 1, false,
	17,  2, 1, false,
	16,  3, 1, false,
	16,  4, 1, false,
	16,  5, 1, false,
	16,  6, 1, false,
	16,  7, 1, false,
	16,  8, 1, false,
	17,  9, 1, false,
	18, 10, 1, false,
	19, 10, 1, false,
	20, 10, 1, false,
	21, 10, 1, false,
	22,  9, 1, false,
	22,  8, 1, false,
	22,  7, 1, false,
	21,  7, 1, false,
	20,  7, 1, false,
	-- L
	24,  1, 1, false,
	24,  2, 1, false,
	24,  3, 1, false,
	24,  4, 1, false,
	24,  5, 1, false,
	24,  6, 1, false,
	24,  7, 1, false,
	24,  8, 1, false,
	24,  9, 1, false,
	24, 10, 1, false,
	25, 10, 1, false,
	26, 10, 1, false,
	27, 10, 1, false,
	28, 10, 1, false,
	29, 10, 1, false,
}

for i = 1, #palette, 3 do
	term.setPaletteColour(2 ^ ((i - 1) / 3), palette[i], palette[i + 1], palette[i + 2])
end

term.clear()

local t = 0
local tstart = 18 -- 3
local tmax = 3
local fadew = 30
local ch = 0

local function get_colour_offset(x)
	local r = math.max(0, math.min(1, (x - x % 2) / fadew - t * 8 + tstart))
	return math.floor(r * 5 + 0.5)
end

local name_dx = math.floor(w / 2 - 7.5 + 0.5)
local name_dy = math.floor(h / 2 - 2 + 0.5) - 1
local text_dx = math.floor(w / 2 - 15)

while t <= tmax do
	for x = 0, name_subpixel_texture.width - 1 do
		local r_clamped = get_colour_offset(x)
		local col = r_clamped == 0 and 0 or 12 - r_clamped * 2
		ccgl._texture_vline(name_subpixel_texture, x, 0, name_subpixel_texture.height, col)
	end
	for x = 0, texture.width - 1 do
		local r_clamped = get_colour_offset(x * 2 - name_dx * 2)
		local col = r_clamped == 0 and 0 or 12 - r_clamped * 2
		ccgl._texture_vline(texture, x, 0, texture.height, col, 0, 0)
	end
	for x = text_dx, text_dx + 29 do
		local r_clamped = get_colour_offset(x * 2 - name_dx * 2)
		local col = r_clamped == 0 and 0 or 12 - r_clamped * 2
		ccgl._texture_write(texture, x, name_dy + 5, ("ComputerCraft Graphics Library"):sub(1 + x - text_dx):sub(1, 1), col, 2)
	end
	-- ccgl._texture_fill_rect(name_subpixel_texture, 0, 0, name_subpixel_texture.width, name_subpixel_texture.height, 0)

	for i = 1, math.min(ch * 4, #text), 4 do
		for j = 0, text[i + 2] - 1 do
			local x = text[i] + j
			local r_clamped = get_colour_offset(x)
			local col = (text[i + 3] and 1 or 2) + r_clamped * 2
			ccgl._texture_set_pixel(name_subpixel_texture, x, text[i + 1], col)
		end
	end

	ccgl._texture_int_subpixel_shrink(name_subpixel_texture, name_full_texture)
	ccgl._texture_blit(name_full_texture, texture, name_dx, name_dy)
	ccgl._texture_blit_term(texture, term, 1, 1)
	if ch == 0 then
		os.pullEvent("key")
	else
		sleep(0.05)
	end
	t = t + 0.05
	ch = ch + 2
end
print()
