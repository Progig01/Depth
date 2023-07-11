--Create a table to store the definitions list
local d = {}
		--Tile definitions
		d.tile_air = { --This one has ALL the fields, if you don't need it (false or nil), don't add it.
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
			solid = false,					--Is this tile solid?
			wall = false,					--Can we walk through this tile?
			breakable = false,				--Can you break this tile?
			hardness = 1,  					--	How hard is it to break?
			hasPlacementConstraints = false,--Are there rules to where this can be placed?
			placementConstraints = {}		--	Table of constraints this tile has
		}

		--Boring material shit
		d.tile_dirt = {
			name = "tile_dirt",
			localizedName = {en="Dirt"},
			isMaterial = true,
			materialName = 'dirt',
			solid = true,
			wall = true,
			breakable = true,
			hardness = 1
		}

		d.tile_grass = {
			name = "tile_grass",
			localizedName = {en="Grass"},
			isTileEntity = false,
			isMaterial = true,
			materialName = 'grass',
			solid = true,
			wall = true,
			breakable = true,
			hardness = 2
		}

		--Interactable Non-Tile-Entities (They do something when you interact, but not every tick)
		d.tile_ladderUp = {
			name = "tile_ladderUp",
			localizedName = {en="Ladder (Up)"},
			solid = true,
			isINTE = true,
			inteFunc = function(self, entity)
				local et = entity.transform
				if self.parent:isWithin(et.x, et.y, et.z) then --If we're inside the tile
					if et.z >= 2 then
						et.z = et.z - 1 --Go up
					end
				end
			end,
			hasSprite = true,
			spritePath = "assets/img/tile/static_ladderUp.png",
			breakable = true,
			hardness = 4,
			hasPlacementConstraints = true,
			placementConstraints = {
				"return function(tileManager, tile) \n"..
					"local cellNeighbors = tile.parent:getNeighbors() \n"..
					"print(cellNeighbors.u.x) \n"..

					"if cellNeighbors.u.contents.breakable then \n"..
						"cellNeighbors.u.contents = tileManager.createTile('tile_ladderDown', cellNeighbors.u) \n"..
						"return true \n"..
					"else \n"..
						"return false \n"..
					"end \n"..
				"end"
			}
		}

		d.tile_ladderDown = {
			name = "tile_ladderDown",
			localizedName = {en="Ladder (Down)"},
			solid = true,
			isINTE = true,
			inteFunc = function(self, entity)
				local et = entity.transform
				if self.parent:isWithin(et.x, et.y, et.z) then --If we're inside the tile
					if et.z < entity.world.worldDepth then
						et.z = et.z + 1 --Go down
					end
				end
			end,
			hasSprite = true,
			spritePath = "assets/img/tile/static_ladderDown.png",
			breakablle = true,
			hardness = 4,
			hasPlacementConstraints = true,
			placementConstraints = {
				"return function(tileManager, tile) \n"..
					"local cellNeighbors = tile.parent:getNeighbors() \n"..
					"if tile.paircheck == nil then tile.paircheck = false end \n"..

					"if cellNeighbors.d.contents.breakable and not tile.paircheck then \n"..
						"cellNeighbors.d.paircheck = true \n"..
						"tile.paircheck = true \n"..
						"cellNeighbors.d.contents = tileManager.createTile('tile_ladderUp', cellNeighbors.d) \n"..
						"return true \n"..
					"else \n"..
						"return false \n"..
					"end \n"..
				"end"
			},
			placementConstraints = {}
		}

--Return the definitions list
return d