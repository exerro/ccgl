
package.path = package.path .. ";/?.lua"

local ccgl = require "ccgl"

local width, height = 20, 10
local texture = ccgl._create_texture(ccgl.texture_format.bfc_int, width, height)

ccgl._texture_write(texture, 3, 1, " Hello world! ", 7, 9)
ccgl._texture_blit_term(texture, term)
