--Create the module
local m = {}

	--Import our tile definitions
	tileDefinitions = require('assets/def/tileDef')

	function m.createTile(tile, parent) --Creates a new tile based on a tile definition
		local t = {} --Empty table to copy the definition into

		for k,v in pairs(tileDefinitions[tile]) do --Copy the definition into a new table...
			t[k] = v
			t.parent = parent
		end

		return t --...and ship it out
	end


--Return the module
return m