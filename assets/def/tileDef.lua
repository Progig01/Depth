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
			solid = false,					--Does this tile have collision?
			breakable = false,				--Can you break this tile?
			hardness = 1  					--	How hard is it to break?
		}

		d.tile_dirt = {
			name = "tile_dirt",
			localizedName = {en="Dirt"},
			isTileEntity = false,
			tickFunction = nil,
			hasSprite = true,
			spritePath = "assets/img/tile/static_dirt_1.png",
			solid = true,
			breakable = true,
			hardness = 1
		}

		d.tile_grass = {
				name =  "tile_grass",
				localizedName = {en="Grass"},
				isTileEntity = false,
				tickFunction = nil,
				hasSprite = true,
				spritePath = "assets/img/tile/static_grass_1.png",
				solid = true,
				breakable = true,
				hardness = 2
		}

		d.tile_gravel = {
				name =  "tile_gravel",
				localizedName = {en="Gravel"},
				isTileEntity = false,
				tickFunction = nil,
				hasSprite = true,
				spritePath = "assets/img/tile/static_gravel_1.png",
				solid = true,
				breakable = true,
				hardness = 4
		}

		d.tile_lava = {
				name =  "tile_lava",
				localizedName = {en="Lava"},
				isTileEntity = false,
				tickFunction = nil,
				hasSprite = true,
				spritePath = "assets/img/tile/static_lava_1.png",
				solid = false,
				breakable = false,
				hardness = 6
		}

		d.tile_metal = {
				name =  "tile_metal",
				localizedName = {en="Metal Deck"},
				isTileEntity = false,
				tickFunction = nil,
				hasSprite = true,
				spritePath = "assets/img/tile/static_metal_1.png",
				solid = true,
				breakable = true,
				hardness = 12
		}

		d.tile_stone = {
				name =  "tile_stone",
				localizedName = {en="Stone"},
				isTileEntity = false,
				tickFunction = nil,
				hasSprite = true,
				spritePath = "assets/img/tile/static_stone_1.png",
				solid = true,
				breakable = true,
				hardness = 8
		}

--Return the definitions list
return d