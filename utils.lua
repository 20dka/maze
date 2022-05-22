local logTypes = {}


function log(string, heading, debug)
	heading = heading or ""
	debug = debug or false

	local out = ("[" .. os.date("%d/%m/%Y %X", os.time())):gsub("/0","/"):gsub("%[0","["):gsub("%[","[" .. color(90)) .. color(0) ..  "]"
	--local out = ""

	if logTypes[heading] then
		if logTypes[heading].conditonFunc == nil or logTypes[heading].conditonFunc() then
			out = out .. "[" .. logTypes[heading].headingColor .. heading .. color(0) .. "] " .. logTypes[heading].stringColor
		end
	elseif heading ~= "" then
		out = out .. "[" .. color(94) .. heading .. color(0) .. "] "
	end

	out = out .. tostring(string) .. color(0)

	print(out)
	return out
end

function setLogType(heading, headingColor, conditonFunc, stringColor)
	headingColor = headingColor or 94
	stringColor = stringColor or 0
	logTypes[heading] = {}
	
	logTypes[heading].headingColor = color(headingColor)
	logTypes[heading].stringColor = color(stringColor)

	if conditonFunc then
		logTypes[heading].conditonFunc = conditonFunc
	end
end

function color(fg,bg)
	--if (config == nil or config.enableColors.value == true) and true then
	if true then
		if bg then
			return string.char(27) .. '[' .. tostring(fg) .. ';' .. tostring(bg) .. 'm'
		else
			return string.char(27) .. '[' .. tostring(fg) .. 'm'
		end
	else
		return ""
	end
end

function split_fn(s, sep)
	local fields = {}

	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

	return fields
end

function subset_fn(t, from, to)
	return { unpack(t, from, to) }
end
