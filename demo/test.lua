
local b = ccgl.create_buffer(ccgl.num[2])

ccgl._buffer_data(b, { { 1, 2 }, { 3, 4 }, { 5, 6 } })

print(table.concat(b, ", "))

local d = ccgl._buffer_read_data(b, 1, 2)

print(d[1][1], d[1][2], d[2][1], d[2][2])
