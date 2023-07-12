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
		d.tile_ladder = { --Less ass ladders?
			name = "ladder",
			localizedName = {en="Ladder"},
			solid = true,
			breakable = true,
			hardness = 4,
			hasSprite = true, 
			spritePath = "assets/img/tile/static_ladderDown.png",
			isINTE = true,
			inteFunc = function(self, entity)
				
			end,
			hasPlacementConstraints = true,
			placementConstraints = {function(self, tileManager)
				--Convenience assignments
				local cell = self.parent
				local grid = self.parent.parent
				local world = self.parent.parent.parent

				--Create a ladder cache, if the world does not already have one
				if world.cache.ladder == nil then
					world.cache.ladder = {}
				end

				--Store the ladder to the cache
				local cacheAddress = grid.x .. grid.y .. cell.x .. cell.y
				local cache = world.cache.ladder
				if cache[cacheAddress] == nil then
					cache[cacheAddress] = {}
				end
				cache[cacheAddress][cell.z] = cell


				function self:getTop()
					local highest = nil
					for k,v in pairs(cache[cacheAddress]) do
						if highest == nil then
							highest = k 
						elseif k < highest then
							highest = k
						end
					end
					return cache[cacheAddress][highest]
				end

				function self:getBottom()
					local lowest = nil
					for k,v in pairs(cache[cacheAddress]) do
						if highest == nil then
							lowest = k 
						elseif k > lowest then
							lowest = k
						end
					end
					return cache[cacheAddress][lowest]
				end

				--If the ladder is at the bottom of a column, set the isBottom state
				if cell ~= nil and cell:traverse('d') ~= nil then
					if cell:traverse('d').contents.name ~= ladder then
						self.isBottom = true
					else
					    self.isBottom = false
					end
				end

				--If the column is only one tall, place one underneath it (if breakable)
				print(self.isBottom, self.isTop)

				if self.isBottom and self.isTop and not cell:traverse('d').contents.solid then
					cell:traverse('d').contents = tileManager.createTile("tile_ladder", cell:traverse('d'))
					return true
				else
					return false
				end
			end}
		}

--Return the definitions list
return d