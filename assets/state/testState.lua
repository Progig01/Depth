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
				--Store our initial position before the update
				local oldX = entity.transform.x
				local oldY = entity.transform.y

				--Get the cell our initial position is in
				local oldCell = entity.world:getCellAt(oldX, oldY)

				--Figure out where we should be based on speed and input
				local newX = entity.transform.x + ((xVec/len)*speed)
				local newY = entity.transform.y + ((yVec/len)*speed)

				--Make sure the new position isn't outside the bounds of the world
				local maxX, maxY = entity.world:getBounds()
				if newX < 0 then entity.transform.x = 0 end
				if newX > maxX then entity.transform.x = maxX end
				if newY < 0 then entity.transform.y = 0 end
				if newY > maxY then entity.transform.y = maxY end

				--Make sure the new position doesn't place us inside a solid block
				local testCell = entity.world:getCellAt(newX, newY)
				if testCell == nil or testCell.contents.solid then
					newX, newY = oldX, oldY
				end

				--Make sure the new position didn't skip over a diagonal wall
				local neighbors = oldCell:getNeighbors()

				print(neighbors[1].x, neighbors[1].y)

				--if newX > oldX and newY > oldY then --If we're moving southeast....
					if neighbors[7].contents.solid and neighbors[5].contents.solid then --and the tiles to the south and east are solid...
						if testCell.x == neighbors[8].x and testCell.y == neighbors[8].y then --and the position is in the tile blocked by them...
							print("EEEE") --We did the thing
							newX, newY = oldX, oldY
						end
					end
				--end

				--Update the position
				entity.transform.x, entity.transform.y = newX, newY
			end
		end
	end

--Return the state
return s