
-- @internal
local function pad(s, l)
    return (" "):rep(l - #s) .. s
end

-- @internal
local function time(duration, iterations, f, ...)
	local count = 0
	local clock = os.clock
	local t0 = clock()

	while clock() - t0 < duration do
		for _ = 1, iterations do
			f(...)
		end
		count = count + iterations
	end

	return count / (clock() - t0)
end

-- @internal
local function run_benchmarks(name, vlabels, hlabels, get_time_params)
	local results = { { name, table.unpack(hlabels) } }

	for i = 1, #vlabels do
		results[i + 1] = { vlabels[i] }
		for j = 1, #hlabels do
			local result = time(get_time_params(vlabels[i], hlabels[j]))
			local fmt = string.format("%.01d/s", math.floor(result * 10) / 10)
			results[i + 1][j + 1] = fmt
			os.queueEvent("")
			os.pullEvent()
		end
	end

	return results
end

-- @internal
local function print_results(results)
	local colmax = {}

	for i = 1, #results do
	    for j = 1, #results[i] do
	        colmax[j] = math.max(colmax[j] or 0, #results[i][j])
	    end
	end

	for i = 1, #results do
	    for j = 1, #results[i] do
	        term.setTextColour((i == 1 or j == 1) and colours.lightGrey or colours.cyan)
	        write(pad(results[i][j], colmax[j] + 2))
	    end
	    print()
	    if i == 1 then
	        term.setTextColour(colours.grey)
	        for j = 1, #colmax do
	            write(("-"):rep(colmax[j]))
	        end
	        print(("-"):rep(2 * #results[i]))
	    end
	end
end

-- @internal
local function save_results(file, results)
	local colmax = {}
	local text = {}

	for i = 1, #results do
	    for j = 1, #results[i] do
	        colmax[j] = math.max(colmax[j] or 0, #results[i][j])
	    end
	end

	for i = 1, #results do
	    for j = 1, #results[i] do
	        term.setTextColour((i == 1 or j == 1) and colours.lightGrey or colours.cyan)
	        table.insert(text, pad(results[i][j], colmax[j] + 2))
	    end
	    table.insert(text, "\n")
	    if i == 1 then
	        term.setTextColour(colours.grey)
	        for j = 1, #colmax do
	            table.insert(text, ("-"):rep(colmax[j]))
	        end
	        table.insert(text, ("-"):rep(2 * #results[i]) .. "\n")
	    end
	end

	local h = io.open(file, "w")
	h:write(table.concat(text))
	h:close()
end

-- @internal
local function delay()
	os.queueEvent("")
	coroutine.yield()
end
