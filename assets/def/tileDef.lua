--Create a table to store the definitions list
local d = {}
		--Tile definitions
		d.tile_air = {
			name = "tile_air",				--Name of the tile, for reference in code
			localizedName = {en="Air"},	--	Localized name(s) for the tile, displayed to player
			isTileEntity = false,			--If this tile is a tileEntity
			tickFunction = nil,				--	The update function for it goes here
			hasSprite = false,				--Does this tile have a sprite to render?
			spritePath = nil,				--	If so, where is it?
			isMaterial = false,				--Is this tile a procedurally textured material?
			materialName = nil,				--	If so, whats the material called?
			solid = false,					--Does this tile have collision?
			breakable = false,				--Can you break this tile?
			hardness = 1  					--	How hard is it to break?
		}

		d.tile_dirt = {
			name = "tile_dirt",
			localizedName = {en="Dirt"},
			isTileEntity = false,
			tickFunction = nil,
			hasSprite = false,
			spritePath = nil,
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
			tickFunction = nil,
			hasSprite = false,
			spritePath = nil,
			isMaterial = true,
			materialName = 'grass',
			solid = true,
			breakable = true,
			hardness = 2
		}

--Return the definitions list
return d