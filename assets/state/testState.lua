--Create the state
local s = {}

	function s:update(dt)
		--Get some useful interfaces to things in the game
		local entity = self.parent.controlEntity
		local world = entity.world
		local controller = self.parent.mapping.vButtons

		--Handle movement
		if entity ~= nil and entity.transform ~= nil then
			local speed = 80
			local xVec, yVec = 0,0

			if controller.up then yVec = -1 elseif controller.down then yVec = 1 end
			if controller.left then xVec = -1 elseif controller.right then xVec = 1 end

			local len = math.sqrt(math.pow(xVec,2) + math.pow(yVec,2))
			if len ~= 0 then
				--Get some stuff we're gonna use a loooot
				local t = entity.transform
				local scale = t.s

				--Store our initial position before the update
				local oldX, oldY, oldZ = t.x, t.y, t.z

				--Get the cell our initial position is in
				local oldCell = entity.world:getCellAt(oldX, oldY, oldZ)

				--Figure out where we should be based on speed and input
				local newX = t.x + (((xVec/len)*speed)*dt)
				local newY = t.y + (((yVec/len)*speed)*dt)
				--print(newX, newY)

				--Make sure the new position isn't outside the bounds of the world
				local maxX, maxY = entity.world:getBounds()
				if newX < 0 + scale then newX = 0 + scale end
				if newY < 0 + scale then newY = 0 + scale end
				if newX > maxX - scale then newX = maxX - scale end
				if newY > maxY - scale then newY = maxY - scale end

				--Make sure the new position doesn't place us inside a solid block
				local testCell = entity.world:getCellAt(newX, newY, oldZ) --Make sure we have a fallback
				local positive = true --If the movement was in a positive direction or not

				--This block is flawed as fuck, but I haven't the attention span to fix it right now ------------
				if xVec > 0 or yVec > 0 then
					testCell = entity.world:getCellAt(newX+scale, newY+scale, oldZ)
					positive = true
				elseif xVec < 0 or yVec < 0 then
					testCell = entity.world:getCellAt(newX-scale, newY-scale, oldZ)
					positive = false
				end
				--End scuffed shit ------------------------------------------------------------------------------

				if testCell == nil or testCell.contents == nil or testCell.contents.wall then
					newX, newY = oldX, oldY
				end

				--Make sure the new position didn't skip over a diagonal wall
				local neighbors = oldCell:getNeighbors()

				--Make sure we aren't clipping through corners...
				if neighbors.s ~= nil and neighbors.e ~= nil and neighbors.se ~=nil then
					if neighbors.s.contents ~= nil and neighbors.e.contents ~= nil and neighbors.se.contents ~=nil then
						if neighbors.s.contents.wall and neighbors.e.contents.wall and testCell == neighbors.se then --SE corner
							newX, newY = oldX, oldY
						end
					end
				end
				if neighbors.s ~= nil and neighbors.w ~= nil and neighbors.sw ~=nil then
					if neighbors.s.contents ~= nil and neighbors.w.contents ~= nil and neighbors.sw.contents ~=nil then
						if neighbors.s.contents.wall and neighbors.w.contents.wall and testCell == neighbors.sw then --SW corner
							newX, newY = oldX, oldY
						end
					end
				end
				if neighbors.n ~= nil and neighbors.w ~= nil and neighbors.nw ~=nil then
					if neighbors.n.contents ~= nil and neighbors.w.contents ~= nil and neighbors.nw.contents ~=nil then
						if neighbors.n.contents.wall and neighbors.w.contents.wall and testCell == neighbors.nw then --NW corner
							newX, newY = oldX, oldY
						end
					end
				end
				if neighbors.n ~= nil and neighbors.e ~= nil and neighbors.ne ~=nil then
					if neighbors.n.contents ~= nil and neighbors.e.contents ~= nil and neighbors.ne.contents ~=nil then
						if neighbors.n.contents.wall and neighbors.e.contents.wall and testCell == neighbors.ne then --NE corner
							newX, newY = oldX, oldY
						end
					end
				end


				--Update the position
				t.x, t.y = newX, newY

				--Is the player standing on anything? Should they fall?
				local ftc = world:getCellAt(t.x, t.y, t.z) -- FTC for Fall Test Cell
				local fallZ = t.z
				if ftc:traverse("d").contents ~= nil and not ftc:traverse("d").contents.solid then
					while ftc:traverse("d") ~= nil and not ftc:traverse("d").contents.solid do
						fallZ = fallZ + 1
						ftc = world:getCellAt(t.x, t.y, fallZ)
						if ftc:traverse("d").contents == nil then return end
					end
					t.z = fallZ
				end
				
			end 
		end

		--Handle interaction
		if entity ~= nil and world ~= nil then

			--This whole block ensures we only interact once when we release the key
			iThisFrame = false
			if controller.interact then
				iThisFrame = true
			elseif not controller.interact then
				iThisFrame = false
			end

			if not iThisFrame and iLastFrame then --This is when we actually interact
				local mX, mY = world.mainCamera:toWorld(love.mouse.getPosition())
				local iCell = world:getCellAt(mX, mY, entity.transform.z)

				if iCell ~= nil and iCell.contents.isINTE and iCell.contents ~= nil then
					if iCell.contents.inteFunc ~= nil then
						iCell.contents:inteFunc(entity)
					end
				end
			end
			iLastFrame = iThisFrame
		end

	end

--Return the state
return s