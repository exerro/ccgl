
-- @export
local function _create_buffer(storage_type)
	return {
		__ccgl_type = ccgl_type.buffer,
		storage_type = storage_type,
		raw_size = 0
	}
end

-- @export
local function create_buffer(st)
	if get_ccgl_type(st) ~= ccgl_type.storage then return errorf("storage type given ('%s') is not a storage type", tostring(st)) end
	if st.size < 1 then return errorf("storage type size ('%d') < 1", st.size) end
	
	return _create_buffer(st)
end

--------------------------------------------------------------------------------

-- @export
local function _buffer_data(buffer, data, length, offset)
	local idx = 1
	local s = buffer.storage_type.size

	length = length or #data
	offset = offset or 1

	for i = offset, offset + length - 1 do
		local v = data[i]
		for j = 1, s do
			buffer[idx] = v[j]
			idx = idx + 1
		end
	end

	buffer.raw_size = length * s
end

local function _buffer_sub_data(buffer, data, buffer_offset, length, offset)
	local idx = (buffer_offset or 0) + 1
	local s = buffer.storage_type.size

	length = length or #data
	offset = offset or 0

	for i = offset + 1, offset + length do
		local v = data[i]
		for j = 1, s do
			buffer[idx] = v[j]
			idx = idx + 1
		end
	end
end
