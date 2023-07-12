--Import required modules
local tile = require('lib/tile')
local wg = require('lib/worldgen')
local utils = require('lib/utils')
--Create our module
local m = {}

	m.cellMeta = {}
	function m.cellMeta:getScreenPos() --gets the current screen position of the cell for drawing and other stuff
		local world = self.parent.parent
		local grid = self.parent 
		local gsip = world.tileScale * world.gridScale

		if grid.x > 1 then
			drawX = (gsip*grid.x) + (world.tileScale*self.x)
		else
			drawX = world.tileScale*self.x
		end

		if grid.y > 1 then
			drawY = (gsip*grid.y) + (world.tileScale*self.y)
		else
			drawY = world.tileScale*self.y
		end

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
		local world = self.parent.parent
		local ts = world.tileScale

		if direction=="n" 	then return world:getCellAt(x+00, y-ts, self.z) end --North
		if direction=="ne" 	then return world:getCellAt(x+ts, y-ts, self.z) end --Northeast
		if direction=="e" 	then return world:getCellAt(x+ts, y+00, self.z) end --East
		if direction=="se" 	then return world:getCellAt(x+ts, y+ts, self.z) end --Southeast
		if direction=="s" 	then return world:getCellAt(x+00, y+ts, self.z) end --South
		if direction=="sw" 	then return world:getCellAt(x-ts, y+ts, self.z) end --Southwest
		if direction=="w" 	then return world:getCellAt(x-ts, y+00, self.z) end --West
		if direction=="nw" 	then return world:getCellAt(x-ts, y-ts, self.z) end --Northwest
		if direction=="u"	then return world:getCellAt(x   ,    y, self.z-1) end --Up
		if direction=="d"	then return world:getCellAt(x   ,    y, self.z+1) end --Down
	end

	function m.cellMeta:assignNeighbors()
		if self.neighbors == nil then
			self.neighbors = {}
			self.neighbors.nw=self:traverse("nw")
			self.neighbors.n=self:traverse("n")
			self.neighbors.ne=self:traverse("ne")
			self.neighbors.w=self:traverse("w")
			self.neighbors.e=self:traverse("e")
			self.neighbors.sw=self:traverse("sw")
			self.neighbors.s=self:traverse("s")
			self.neighbors.se=self:traverse("se")
			self.neighbors.u=self:traverse("u")
			self.neighbors.d=self:traverse("d") or "WHAT THE FUCK"
			return true
		else
			return false
		end
	end

	function m.cellMeta:getNeighbors()
		if self.neighbors == nil then
			self:assignNeighbors()
		end

		return self.neighbors
	end

	function m.cellMeta:render(solidTransparency, debugRender) --Render the cells contents
		--Get our local variables set up
		local spriteCache = self.parent.parent.spriteCache
		local dX,dY = self:getScreenPos()
		local solidTransparency = solidTransparency or false
		local drawable = nil

		if not debugRender then --NORMAL RENDERING CASE
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
					if not self.contents.solid or not self.contents.wall then
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
		elseif debugRender then --DEBUG RENDER CASE
			local tileScale = self.parent.parent.tileScale
			local r,g,b,a = love.graphics.getColor()

			love.graphics.setColor(128,128,128,128)
			if self.debugHighlight then love.graphics.setColor(1, 0, 0, 1) end

			if self.contents ~= nil and self.contents.solid then
				love.graphics.rectangle("fill", dX, dY, tileScale, tileScale)
			else
				love.graphics.rectangle("line", dX, dY, tileScale,tileScale)
			end


			love.graphics.setColor(r, g, b, a)
		end

	end

	function m.newCell(x, y, z, parent)
		--Create a table to be our cell
		local cell = {
			id = 0,
			x = x,
			y = y,
			z = z,
			contents = {},
			debugHighlight = false,
			parent = parent
		}

		--Generate a unique id for our cell, and add the reference to the world lookup table
		cell.id = utils.newUUID(cell.parent.parent.seed * 100 * cell.x + cell.y, 'c')
		cell.parent.parent.idReferences[cell.id] = cell

		--Attach meta and return our cell
		setmetatable(cell, {__index = m.cellMeta})
		return cell
	end

	m.gridMeta = {} --Metatable to hold functions used by all grid objects
	function m.gridMeta:generate() --Populate the empty cells with air (TODO: Real world gen, dumbass)
		local tileNames = {"tile_grass", "tile_dirt"}
		for i=1, #self.cells do
			for k,v in pairs(self.cells[i]) do
				self.isGenerated = true
				v.contents = tile.createTile(tileNames[math.random(#tileNames)], self)
			end
		end
	end

	function m.gridMeta:renderCells(solidTransparency, debugRender) --Render the contents of all the cells in the grid
		if not debugRender then --NORMAL RENDER CASE
			for i=1, #self.cells do
				for k,v in pairs(self.cells[i]) do
					if v.render ~= nil then v:render(solidTransparency) end
				end
			end
		elseif debugRender then --DEBUG RENDER CASE
			for i=1, #self.cells do
				for k,v in pairs(self.cells[i]) do
					if v.render ~= nil then v:render(false, true) end
				end
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

		--Generate a unique id for our grids, and add the reference to the world lookup table
		grid.id = utils.newUUID(grid.parent.seed * grid.x + grid.y, 'g')
		grid.parent.idReferences[grid.id] = grid

		--Populate our grid with cells
		for cX=1, grid.parent.gridScale do
			grid.cells[cX] = {}
			for cY=1, grid.parent.gridScale do
				grid.cells[cX][cY] = m.newCell(cX, cY, grid.z, grid)
			end
		end

		--Assign meta and return our grid
		setmetatable(grid, {__index = m.gridMeta})

		return grid
	end

	function m.newWorld(wW, wH, wD, seed)
		--Create a table to be our world
		local world = {
			id = 0,
			name = "world",
			seed = seed or 0,
			worldWidth = wW or 1,
			worldHeight = wH or 1,
			worldDepth = wD or 8,
			gridScale = 32,
			tileScale = 32,
			grids = {},
			spriteCache = {},
			cache = {}
		}

		--Make a table to have references to every object in the grid via ID
		world.idReferences = {}

		--Generate a unique ID for our world
		world.id = utils.newUUID(world.seed, 'w')
		world[world.id] = world --Add it to the world references table

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
		function world:generate() --Call the generate method for all grids in the world. TODO: generation range
			for x=1, #self.grids do
				for y=1, #self.grids[x] do
					for z=1, #self.grids[x][y] do
						if self.grids[x][y][z].generate ~= nil then
							self.grids[x][y][z]:generate()
						end
					end
				end
			end
		end

		function world:getById(id)
			if self.idReferences[id] ~= nil then
				return self.idReferences[id]
			else
				return 'No object with this id'
			end
		end

		function world:getBounds()
			local x = (world.tileScale * world.gridScale) * self.worldWidth
			local y = (world.tileScale * world.gridScale) * self.worldHeight
			local z = world.worldDepth
			return x, y, z
		end

		function world:getCellAt(x,y,z)--Takes a world XYZ position and returns the grid and cell at that location
			local maxX, maxY, maxZ = self:getBounds()

			if x >= 0 and x < maxX and y >= 0 and y < maxY and z >= 1 and z <= maxZ then
				local gsip = self.gridScale * self.tileScale --gsip = Grid Size In Pixels

				local gX = math.ceil(x/gsip)
				local gY = math.ceil(y/gsip)
				local cX = math.ceil((x%gsip)/self.tileScale)
				local cY = math.ceil((y%gsip)/self.tileScale)

				if x > gsip then
					local tgx = x-(gsip*gX)
					cX = math.floor(tgx/self.tileScale)
				else
					cX = math.floor(x/self.tileScale)
				end

				if y > gsip then
					local tgy = y-(gsip*gX)
					cY = math.floor(tgy/self.tileScale)
				else
					cY = math.floor(y/self.tileScale)
				end

				if gX <= 0 or gX == nil then gX = 1 end
				if gY <= 0 or gY == nil then gY = 1 end
				if cX <= 0 or cX == nil then cX = 1 end
				if cY <= 0 or cY == nil then cY = 1 end

				--print("INPUT:",x,y)
				--print("OUTPUT :: GRID:",gX, gY, "CELL:",cX, cY)

				return self.grids[gX][gY][z].cells[cX][cY]		
			end
		end




		function world:renderCells(referencePoint, camera, debugRender) --Renders cells less shittily
			local vD = referencePoint.z or 1 --The Z depth of the tiles that should be rendered as foreground
			local debugRender = debugRender or false

			--Figure out which cells we should actually be drawing
			local cx1,cy1,cx2,cy2,cx3,cy3,cx4,cy4 = camera:getVisibleCorners() --Get the visible corners
			if cx1 < 0 then cx1=0 end
			if cy1 < 0 then cy1=0 end
			if cx3 > (self.worldWidth * (self.gridScale*self.tileScale)) - 1 then cx3 = self.gridScale*self.tileScale - 1 end
			if cy3 > (self.worldHeight * (self.gridScale*self.tileScale)) - 1 then cy3 = self.gridScale*self.tileScale - 1 end

			local tlCell = self:getCellAt(cx1, cy1, vD) --Topleft most visible cell
			local brCell = self:getCellAt(cx3-1, cy3-1, vD) --Bottomright most visible cell

			local tlGrid = tlCell.parent --Grid of the Topleft most visible cell
			local brGrid = brCell.parent --Grid of the Bottomright most visible cell

			--Set the start and end positions for our for loop
			local startX, startY = tlGrid.x, tlGrid.y
			local endX, endY = brGrid.x, brGrid.y

			if not debugRender then --NORMAL RENDER CASE
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
			elseif debugRender then --DEBUG RENDER CASE
				for x = startX, endX do
					for y = startY, endY do
						local v = self.grids[x][y][referencePoint.z]
						if v ~= nil and v.renderCells ~= nil then v:renderCells(false, true) end
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