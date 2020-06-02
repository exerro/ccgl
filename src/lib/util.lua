
-- @internal
local function errorf(fmt, ...)
	return error(fmt:format(...))
end

-- @internal
local function errorfn(fmt, n, ...)
	return error(fmt:format(...), n)
end

-- @internal
local function blame(fmt, ...)
	error(fmt:format(...), 3)
end

-- @internal
local function check_is_enum(object, enum)
	for _, v in pairs(enum) do
		if object == v then
			return true
		end
	end
	return false
end

-- @internal-export
local function get_ccgl_type(objectID)
	return ccgl_types[objectID]
end
