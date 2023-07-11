--Create the module
local m = {}

	--Import our tile definitions
	tileDefinitions = require('assets/def/tileDef')

	function m.createTile(tile, parent) --Creates a new tile based on a tile definition
		local t = {} --Empty table to copy the definition into
		local conCheck = true --Set to false if any constraints fail

		local nilToFalse = { --Table of fields to convert from nil to false
			"isTileEntity", "isINTE", "hasSprite", "isMaterial", "solid", "wall", "breakable", "hasPlacementConstraints"
		}

		for k,v in pairs(tileDefinitions[tile]) do --Copy the definition into a new table...
			t[k] = v
			t.parent = parent
		end

		for i=1, #nilToFalse do --If an essential field is nil, default it to false to prevent definition bloat.
			if t[nilToFalse[i]] == nil then
				t[nilToFalse[i]] = false
			end
		end

		if tileDefinitions[tile].hasPlacementConstraints then
			local con = tileDefinitions[tile].placementConstraints --Load the constraint functions from these strings	
			for i=1, #con do
				local cFunc = assert(loadstring(con[i]))()
				conCheck = cFunc(m, t)
				if not conCheck then return end
			end
		end

		if conCheck then --If it meets all constraint criteria...
			return t --Ship it out
		else
			return nil --Or don't.
		end
	end


--Return the module
return m