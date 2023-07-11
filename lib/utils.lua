--Create our module
local m = {}

	function m.newUUID(seed, tag)
		local seed = seed or love.timer.getTime()
		math.randomseed(seed)
		local tag = tag or 't'
		local template = 'xxxxxxxx-xxxx-' .. tag .. 'xxx-yxxx-xxxxxxxxxxxx'
		return string.gsub(template, '[xy]', function(char)
			local v = (char =='x') and math.random(0, 0xf) or math.random(8,0xb)
			return string.format('%x', v)
		end)
	end

--Return our module
return m