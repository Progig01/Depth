--Import required modules
local tile = require('lib/tile')
--Create our module
local m = {}

	function m.newCell(x, y, parent)
		--Create a table to be our cell
		local cell = {
			id = 0,
			x = x,
			y = y,
			contents = {},
			parent = parent
		}


		--FUNCTIONS
		function cell:getScreenPos() --gets the current screen position of the cell for drawing and other stuff
			local world = self.parent.parent
			local grid = self.parent 
			local gridSizeInPixels = world.tileScale * world.gridScale

			local drawX = (gridSizeInPixels * (grid.x-1)) + (world.tileScale * (self.x-1))
			local drawY = (gridSizeInPixels * (grid.y-1)) + (world.tileScale * (self.y-1))

			return drawX, drawY
		end

		function cell:traverse(direction) --Returns the neighboring cell in the given direction
			local x,y = self:getScreenPos()

			if direction=="n" 	then return self.parent.parent:getCellAt(x+0, y-1) end --North
			if direction=="ne" 	then return self.parent.parent:getCellAt(x+1, y-1) end --Northeast
			if direction=="e" 	then return self.parent.parent:getCellAt(x+1, y+0) end --East
			if direction=="se" 	then return self.parent.parent:getCellAt(x+1, y+1) end --Southeast
			if direction=="s" 	then return self.parent.parent:getCellAt(x+0, y+1) end --South
			if direction=="sw" 	then return self.parent.parent:getCellAt(x-1, y+1) end --Southwest
			if direction=="w" 	then return self.parent.parent:getCellAt(x-1, y+0) end --West
			if direction=="nw" 	then return self.parent.parent:getCellAt(x-1, y-1) end --Northwest
			return nil
		end

		function cell:getNeighbors()
			local x = (self.x-1) * self.parent.parent.tileScale
			local y = (self.y-1) * self.parent.parent.tileScale 

			local neighbors = {
				self.parent.parent:getCellAt(x-1, y-1),
				self.parent.parent:getCellAt(x+0, y-1),
				self.parent.parent:getCellAt(x+1, y-1),
				self.parent.parent:getCellAt(x-1, y+0),
				self.parent.parent:getCellAt(x+1, y+0),
				self.parent.parent:getCellAt(x-1, y+1),
				self.parent.parent:getCellAt(x+0, y+1),
				self.parent.parent:getCellAt(x+1, y+1)
			}

			return neighbors
		end

		function cell:render() --Render the cells contents
			local spriteCache = self.parent.parent.spriteCache
			local dX,dY = self:getScreenPos()

			--Check if the cell has a tile, and if the tile has a sprite
			if self.contents ~= nil and self.contents.hasSprite then
				if spriteCache[self.contents.spritePath] == nil then --then check if the sprite is already stored in the world spriteCache
					spriteCache[self.contents.spritePath] = love.graphics.newImage(self.contents.spritePath) --if not, cache it
				end

				local r,g,b,a = love.graphics.getColor()
				love.graphics.setColor(1,1,1,1)
				love.graphics.draw(spriteCache[self.contents.spritePath], dX, dY)
				love.graphics.setColor(r,g,b,a)
			end
		end

		function cell:debugRender() --Renders an outline of a cell to the screen
			local dX, dY = self:getScreenPos()
			local tileScale = self.parent.parent.tileScale
			local r,g,b,a = love.graphics.getColor()
			love.graphics.setColor(128,128,128,128)
			love.graphics.rectangle("line", dX, dY, tileScale,tileScale)
			love.graphics.setColor(r, g, b, a)
		end

		--Return our cell
		return cell
	end

	function m.newGrid(gX, gY, parent)
		--Create a table to be our grid
		local grid = {
			id = 0,
			x = gX,
			y = gY,
			cells = {},
			parent = parent
		}

		--Populate our grid with cells
		for cX=1, grid.parent.gridScale do
			grid.cells[cX] = {}
			for cY=1, grid.parent.gridScale do
				grid.cells[cX][cY] = m.newCell(cX, cY, grid)
			end
		end

		--FUNCTIONS
		function grid:generate() --Generates the cells within the grid (TODO: actual fuckin worldgen, dweeb)
			local tileNames = {"tile_air", "tile_dirt"}
			for i=1, #self.cells do
				for k,v in pairs(self.cells[i]) do
					v.contents = tile.createTile(tileNames[math.random(#tileNames)])
				end
			end
		end

		function grid:renderCells() --Renders the contents of all the cells in a grid
			for i=1, #self.cells do
				for k,v in pairs(self.cells[i]) do
					if v.render ~= nil then v:render() end
				end
			end
		end

		function grid:debugRender() --Renders an outline of all the cells in a grid
			for i=1, #self.cells do
				for k,v in pairs(self.cells[i]) do
					if v.debugRender ~= nil then v:debugRender() end
				end
			end
		end

		--Return our grid
		return grid
	end

	function m.newWorld(wW, wH)
		--Create a table to be our world
		local world = {
			id = 0,
			name = "world",
			worldWidth = wW or 1,
			worldHeight = wH or 1,
			gridScale = 16,
			tileScale = 32,
			grids = {},
			spriteCache = {}
		}

		--Populate our world with grids
		for gX=1, world.worldWidth do
			world.grids[gX] = {}
			for gY=1, world.worldHeight do
				world.grids[gX][gY] = m.newGrid(gX, gY, world)
			end
		end

		--FUNCTIONS
		function world:getBounds()
			local x = (world.tileScale * world.gridScale) * self.worldWidth
			local y = (world.tileScale * world.gridScale) * self.worldWidth
			return x, y
		end

		function world:getCellAt(x,y) --Takes a world X Y position and returns the grid and cell at that location
			local maxX, maxY = self:getBounds()
			if x >= 0 and x < maxX and y >= 0 and y < maxY then
				local gridSizeInPixels = self.gridScale * self.tileScale

				local gridX = math.floor(x/gridSizeInPixels)
				local gridY = math.floor(y/gridSizeInPixels)
				local cellX = math.floor((x-(gridSizeInPixels*gridX))/self.tileScale)+1
				local cellY = math.floor((y-(gridSizeInPixels*gridY))/self.tileScale)+1
				gridX, gridY = gridX+1, gridY+1

				local rGrid = self.grids[gridX][gridY]
				local rCell = rGrid.cells[cellX][cellY]

				return rCell
			end
			return nil
		end

		function world:renderCells() --Renders all the cells in all the grids in the world (for now)
			for i=1, #self.grids do
				for k,v in pairs(self.grids[i]) do
					if v.renderCells ~= nil then v:renderCells() end
				end
			end
		end

		function world:debugRender() --Renders an outline of all cells in all grids in the world
			for i=1, #self.grids do
				for k,v in pairs(self.grids[i]) do
					if v.debugRender ~= nil then v:debugRender() end
				end
			end
		end

		--Return our world
		return world
	end

--Return our module
return m 