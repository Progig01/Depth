--Import required modules
local tile = require('lib/tile')
local wg = require('lib/worldgen')
--Create our module
local m = {}

	m.cellMeta = {}
	function m.cellMeta:getScreenPos() --gets the current screen position of the cell for drawing and other stuff
		local world = self.parent.parent
		local grid = self.parent 
		local gridSizeInPixels = world.tileScale * world.gridScale

		local drawX = (gridSizeInPixels * (grid.x-1)) + (world.tileScale * (self.x-1))
		local drawY = (gridSizeInPixels * (grid.y-1)) + (world.tileScale * (self.y-1))

		return drawX, drawY
	end

	function m.cellMeta:isWithin(x,y,z) --Checks if a given x,y,z position is within this cell
		local world = self.parent.parent

		local minX, minY = self:getScreenPos()
		local maxX, maxY = minX+world.tileScale, minY+world.tileScale
		local minZ, maxZ = 1, world.worldDepth

		if x >= minX and x <= maxX then
			if y >= minY and y <= maxY then
				if z >= minZ and z <= maxZ then
					return true
				end
			end
		end
		return false
	end

	function m.cellMeta:traverse(direction) --Returns the neighboring cell in the given direction
		local x,y = self:getScreenPos()
		local ts = self.parent.parent.tileScale

		if direction=="n" 	then return self.parent.parent:getCellAt(x+00, y-ts) end --North
		if direction=="ne" 	then return self.parent.parent:getCellAt(x+ts, y-ts) end --Northeast
		if direction=="e" 	then return self.parent.parent:getCellAt(x+ts, y+00) end --East
		if direction=="se" 	then return self.parent.parent:getCellAt(x+ts, y+ts) end --Southeast
		if direction=="s" 	then return self.parent.parent:getCellAt(x+00, y+ts) end --South
		if direction=="sw" 	then return self.parent.parent:getCellAt(x-ts, y+ts) end --Southwest
		if direction=="w" 	then return self.parent.parent:getCellAt(x-ts, y+00) end --West
		if direction=="nw" 	then return self.parent.parent:getCellAt(x-ts, y-ts) end --Northwest
		return nil
	end

	function m.cellMeta:getNeighbors()
		local neighbors = {}

		neighbors[1]=self:traverse("nw")
		neighbors[2]=self:traverse("n")
		neighbors[3]=self:traverse("ne")
		neighbors[4]=self:traverse("w")
		neighbors[5]=self:traverse("e")
		neighbors[6]=self:traverse("sw")
		neighbors[7]=self:traverse("s")
		neighbors[8]=self:traverse("se")

		return neighbors
	end

	function m.cellMeta:render(solidTransparency) --Render the cells contents
		--Get our local variables set up
		local spriteCache = self.parent.parent.spriteCache
		local dX,dY = self:getScreenPos()
		local solidTransparency = solidTransparency or false
		local drawable = nil

		--Handle tiles with normal sprites
		if self.contents ~= nil and self.contents.hasSprite then
			if spriteCache[self.contents.spritePath] == nil then --then check if the sprite is already stored in the world spriteCache
				spriteCache[self.contents.spritePath] = love.graphics.newImage(self.contents.spritePath) --if not, cache it
			end
			drawable = spriteCache[self.contents.spritePath] --Set it as our thing to draw
		end

		--Handle tiles with procedural materials
		if self.contents ~= nil and self.contents.isMaterial then
			if self.matSprite == nil then --See if we've already stored its sampled texture
				local sample = love.image.newImageData(self.parent.parent.tileScale, self.parent.parent.tileScale) --If not, do so
				for x=0, self.parent.parent.tileScale-1 do
					for y=0, self.parent.parent.tileScale-1 do
						local r,g,b = sampleMaterial(self.contents.materialName, dX+x, dY+y)
						sample:setPixel(x,y,r,g,b,1)
					end
				end
				self.matSprite = love.graphics.newImage(sample) --And store the sample
			end
			drawable = self.matSprite --Set it as our thing to draw
		end

		--Handle solid-transparency cases
		if drawable ~= nil then
			if solidTransparency then
				if not self.contents.solid then
					local r,g,b,a = love.graphics.getColor()
					love.graphics.setColor(1,1,1,1)
					love.graphics.draw(drawable, dX, dY) --Draw it with solid-transparency, solid-transparent
					love.graphics.setColor(r,g,b,a)
				else
					love.graphics.draw(drawable, dX, dY) --Draw it with solid-transparency, solid
				end
			else
				love.graphics.draw(drawable, dX, dY) --Draw it without solid-transparency
			end
		end

	end

	function m.cellMeta:debugRender() --Renders an outline of a cell to the screen
		local dX, dY = self:getScreenPos()
		local tileScale = self.parent.parent.tileScale
		local r,g,b,a = love.graphics.getColor()

		love.graphics.setColor(128,128,128,128)
		if self.debugHighlight then love.graphics.setColor(1, 0, 0, 1) end
		love.graphics.rectangle("line", dX, dY, tileScale,tileScale)
		love.graphics.setColor(r, g, b, a)
	end

	function m.newCell(x, y, parent)
		--Create a table to be our cell
		local cell = {
			id = 0,
			x = x,
			y = y,
			contents = {},
			debugHighlight = false,
			parent = parent
		}

		--Attach meta and return our cell
		setmetatable(cell, {__index = m.cellMeta})
		return cell
	end

	m.gridMeta = {} --Metatable to hold functions used by all grid objects
	function m.gridMeta:generate() --Populate the empty cells with air (TODO: Real world gen, dumbass)
		local tileNames = {"tile_air", "tile_grass"}
		for i=1, #self.cells do
			for k,v in pairs(self.cells[i]) do
				self.isGenerated = true
				v.contents = tile.createTile(tileNames[math.random(#tileNames)], self)
			end
		end
	end

	function m.gridMeta:renderCells(solidTransparency) --Render the contents of all the cells in the grid
		for i=1, #self.cells do
			for k,v in pairs(self.cells[i]) do
				if v.render ~= nil then v:render(solidTransparency) end
			end
		end
	end

	function m.gridMeta:debugRender() --Render outlines of all the cells in the grid
		for i=1, #self.cells do
			for k,v in pairs(self.cells[i]) do
				if v.debugRender ~= nil then v:debugRender() end
			end
		end
	end


	function m.newGrid(gX, gY, gZ, parent)
		--Create a table to be our grid
		local grid = {
			id = 0,
			x = gX,
			y = gY,
			z = gZ,
			isGenerated = false,
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

		--Assign meta and return our grid
		setmetatable(grid, {__index = m.gridMeta})

		return grid
	end

	function m.newWorld(wW, wH, wD)
		--Create a table to be our world
		local world = {
			id = 0,
			name = "world",
			worldWidth = wW or 1,
			worldHeight = wH or 1,
			worldDepth = wD or 8,
			gridScale = 32,
			tileScale = 32,
			grids = {},
			spriteCache = {}
		}

		--Populate our world with grids
		for gX=1, world.worldWidth do
			world.grids[gX] = {}
			for gY=1, world.worldHeight do
				world.grids[gX][gY] = {}
				for gZ = 1, world.worldDepth do
					world.grids[gX][gY][gZ] = m.newGrid(gX, gY, gZ, world)
				end
			end
		end

		--FUNCTIONS
		function world:getBounds()
			local x = (world.tileScale * world.gridScale) * self.worldWidth
			local y = (world.tileScale * world.gridScale) * self.worldWidth
			local z = world.worldDepth
			return x, y, z
		end

		function world:getCellAt(x,y,z) --Takes a world X Y position and returns the grid and cell at that location
			local maxX, maxY, maxZ = self:getBounds()
			local x,y,z = x,y,z or 1
			if x >= 0 and x < maxX and y >= 0 and y < maxY and z >= 1 and z < maxZ then
				local gridSizeInPixels = self.gridScale * self.tileScale

				local gridX = math.floor(x/gridSizeInPixels)
				local gridY = math.floor(y/gridSizeInPixels)
				local cellX = math.floor((x-(gridSizeInPixels*gridX))/self.tileScale)+1
				local cellY = math.floor((y-(gridSizeInPixels*gridY))/self.tileScale)+1
				gridX, gridY = gridX+1, gridY+1

				local rGrid = self.grids[gridX][gridY][z]
				local rCell = rGrid.cells[cellX][cellY]

				return rCell
			end
			return nil
		end

		function world:renderCells(referencePoint, camera) --Renders cells less shittily
			local vD = referencePoint.z or 1 --The Z depth of the tiles that should be rendered as foreground

			--Figure out which cells we should actually be drawing
			local cx1, cy1, _,_,_,_, cx4, cy4 = camera:getVisibleCorners() --Get the visible corners
			local tlGrid = self:getCellAt(cx1, cy1).parent --Topleft most visible grid
			local brGrid = self:getCellAt(cx4, cy4).parent --Bottomright most visible grid

			--Set the start and end positions for our for loop
			local startX, startY = tlGrid.x, tlGrid.y
			local endX, endY = brGrid.x, brGrid.y

			--Store the old draw color
			local r,g,b,a = love.graphics.getColor()
			--Set the color for the cells one under view depth (floor)
			love.graphics.setColor(1,1,1,1)
			for x = startX, endX do
				for y = startY, endY do
					local v = self.grids[x][y][vD+1]
					if v ~= nil and v.renderCells ~= nil then v:renderCells(false) end
				end
			end
			--Set the color for the cells at view depth (walls)
			love.graphics.setColor(0.18,0.18,0.18,1)
			for x = startX, endX do
				for y = startY, endY do
					local v = self.grids[x][y][vD]
					if v ~= nil and v.renderCells ~= nil then v:renderCells(true) end
				end
			end

			love.graphics.setColor(r, g, b, a) --return to old color
		end

		function world:debugRender() --Renders an outline of all cells in all grids in the world
			for x=1, #self.grids do
				for y=1, #self.grids[x] do
					for _,v in pairs(self.grids[x][y]) do
						if v.debugRender ~= nil then v:debugRender() end
					end
				end
			end
		end

		--Assign meta and return our world
		--setmetatable(world, m.gridMeta)
		return world
	end

--Return our module
return m 