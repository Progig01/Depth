--Create a table to store the definitions list
local d = {}
		--Tile definitions
		d.tile_air = { --This one has ALL the fields, if you don't need it, don't add it.
			name = "tile_air",				--Name of the tile, for reference in code
			localizedName = {en="Air"},	--	Localized name(s) for the tile, displayed to player
			isTileEntity = false,			--If this tile is a tileEntity
			tickFunction = nil,				--	The update function for it goes here
			isINTE = false,					--Is this tile a INTERACTABLE-NON-TILE-ENTITY(INTE)?
			inteFunc = nil,					--	If so, what do we do when you interact with it?
			hasSprite = false,				--Does this tile have a sprite to render?
			spritePath = nil,				--	If so, where is it?
			isMaterial = false,				--Is this tile a procedurally textured material?
			materialName = nil,				--	If so, whats the material called?
			solid = false,					--Does this tile have collision?
			breakable = false,				--Can you break this tile?
			hardness = 1  					--	How hard is it to break?
		}

		--Boring material shit
		d.tile_dirt = {
			name = "tile_dirt",
			localizedName = {en="Dirt"},
			isTileEntity = false,
			hasSprite = false,
			isMaterial = true,
			materialName = 'dirt',
			solid = true,
			breakable = true,
			hardness = 1
		}

		d.tile_grass = {
			name = "tile_grass",
			localizedName = {en="Grass"},
			isTileEntity = false,
			hasSprite = false,
			isMaterial = true,
			materialName = 'grass',
			solid = true,
			breakable = true,
			hardness = 2
		}

		--Interactable Non-Tile-Entities (They do something when you interact, but not every tick)
		d.tile_ladderUp = {
			name = "tile_ladderUp",
			localizedName = {en="Ladder (Up)"},
			isTileEntity = false,
			isINTE = true,
			inteFunc = function(entity) --The entity interacting with the INTE
				local et = entity.transform
				if self.parent:isWithin(et.x, et.y, et.z) then --If we're inside the tile
					if et.z > 2 then
						et.z = et.z - 1 --Go up
					end
				end
			end,
			hasSprite = true,
			spritePath = "assets/img/tile/static_ladderUp.png",
			isMaterial = false,
			solid = false,
			breakable = true,
			hardness = 4
		}

--Return the definitions list
return d