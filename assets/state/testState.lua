--Create the state
local s = {}

	function s:update(dt)
		local speed = 3
		local entity = self.parent.controlEntity
		local controller = self.parent.mapping.vButtons
		local cEnt = self.parent.controlEntity

		if entity ~= nil and entity.transform ~= nil then
			local xVec, yVec = 0,0

			if controller.up then yVec = -1 elseif controller.down then yVec = 1 end
			if controller.left then xVec = -1 elseif controller.right then xVec = 1 end

			local len = math.sqrt(math.pow(xVec,2) + math.pow(yVec,2))
			if len ~= 0 then
				--Get some stuff we're gonna use a loooot
				local t = entity.transform
				local scale = t.s

				--Store our initial position before the update
				local oldX, oldY = t.x, t.y

				--Get the cell our initial position is in
				local oldCell = entity.world:getCellAt(oldX, oldY)

				--Figure out where we should be based on speed and input
				local newX = t.x + ((xVec/len)*speed)
				local newY = t.y + ((yVec/len)*speed)
				--print(newX, newY)

				--Make sure the new position isn't outside the bounds of the world
				local maxX, maxY = entity.world:getBounds()
				if newX < 0 + scale then newX = 0 + scale end
				if newY < 0 + scale then newY = 0 + scale end
				if newX > maxX - scale then newX = maxX - scale end
				if newY > maxY - scale then newY = maxY - scale end

				--Make sure the new position doesn't place us inside a solid block
				local testCell = entity.world:getCellAt(newX, newY) --Make sure we have a fallback
				local positive = true --If the movement was in a positive direction or not

				--This block is flawed as fuck, but I haven't the attention span to fix it right now ------------
				if xVec > 0 or yVec > 0 then
					testCell = entity.world:getCellAt(newX+scale, newY+scale)
					positive = true
				elseif xVec < 0 or yVec < 0 then
					testCell = entity.world:getCellAt(newX-scale, newY-scale)
					positive = false
				end
				--End scuffed shit ------------------------------------------------------------------------------

				if testCell == nil or testCell.contents.solid then
					newX, newY = oldX, oldY
				end

				--Make sure the new position didn't skip over a diagonal wall
				local neighbors = oldCell:getNeighbors()

				--Make sure we aren't clipping through corners...
				if neighbors[7] ~= nil and neighbors[5] ~= nil and neighbors[8] ~=nil then
					if neighbors[7].contents.solid and neighbors[5].contents.solid and testCell == neighbors[8] then --SE corner
						newX, newY = oldX, oldY
					end
				end
				if neighbors[7] ~= nil and neighbors[4] ~= nil and neighbors[6] ~=nil then
					if neighbors[7].contents.solid and neighbors[4].contents.solid and testCell == neighbors[6] then --SW corner
						newX, newY = oldX, oldY
					end
				end
				if neighbors[2] ~= nil and neighbors[4] ~= nil and neighbors[1] ~=nil then
					if neighbors[2].contents.solid and neighbors[4].contents.solid and testCell == neighbors[1] then --NW corner
						newX, newY = oldX, oldY
					end
				end
				if neighbors[2] ~= nil and neighbors[5] ~= nil and neighbors[3] ~=nil then
					if neighbors[2].contents.solid and neighbors[5].contents.solid and testCell == neighbors[3] then --NE corner
						newX, newY = oldX, oldY
					end
				end


				--Update the position
				t.x, t.y = newX, newY
			end
		end
	end

--Return the state
return s