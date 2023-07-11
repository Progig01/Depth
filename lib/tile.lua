--Create the module
local m = {}

	--Import our tile definitions
	tileDefinitions = require('assets/def/tileDef')

	function m.createTile(tile, parent) --Creates a new tile based on a tile definition
		local t = {} --Empty table to copy the definition into

		local nilToFalse = { --Table of fields to convert from nil to false
			"isTileEntity", "isINTE", "hasSprite", "isMaterial", "solid", "wall", "breakable"
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

		return t --...and ship it out
	end


--Return the module
return m