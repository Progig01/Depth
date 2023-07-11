--Leave actual main.lua alone, do the dumb shit here
--Import some shit
local world = require('lib/world')
local entity = require('lib/entity')
local input = require('lib/input')
local gamera = require('lib/third_party/gamera')
local tile = require("lib/tile")

--Module time
local m = {}


function m.load()
	--Make a world
	myWorld = world.newWorld(2,2,4)
	myWorld.seed = 111211811
	myWorld:generate()

	for x=1, #myWorld.grids do
		for y=1, #myWorld.grids[x] do
			for x2=1, #myWorld.grids[x][y][1].cells do
				for y2=1, #myWorld.grids[x][y][1].cells[x2] do
					myWorld.grids[x][y][1].cells[x2][y2].contents = tile.createTile("tile_air")
				end
			end
		end
	end
	
	testCell = myWorld.grids[1][1][3].cells[4][4]
	testCell2 = myWorld.grids[1][1][2].cells[4][5]
	testCell3 = myWorld.grids[1][1][4].cells[4][4]

	--testCell.contents = tile.createTile("tile_ladderUp", testCell) --FIX THE LADDERS AFTER YOU FIGURE OUT WHY NEIGHBORS NOT RETURNING UP AND DOWN
	--testCell2.contents = tile.createTile("tile_ladderUp", testCell2)


	--Make a camera
	local cameraBoundX = (myWorld.worldWidth * (myWorld.tileScale * myWorld.gridScale))-1
	local cameraBoundY = (myWorld.worldHeight * (myWorld.tileScale * myWorld.gridScale))-1
	mainCamera = gamera.new(0,0, cameraBoundX, cameraBoundY)
	mainCamera:setScale(3.0)
	myWorld.mainCamera = mainCamera

	--Make a player, attached to the world
	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(128, 128, 1)
	myEntity.transform:setScale(4)

	--Set the input manager to an appropriate mapping and state, attach the player as the control entit
	input:setActiveMapping("test_mapping")
	input:setActiveState("assets/state/testState")
	input:setControlEntity(myEntity)


end

function m.update(dt)
	--Update the input handler
	input:update(dt)

	--Temporary testing garbage
	mainCamera:setPosition(myEntity.transform.x, myEntity.transform.y)
	mainCamera:setScale(1.0*input.mapping.scrollValue.y)
	--print("FPS: " .. 1/dt .. "  TICK: " .. dt*1000 .. "ms")
end

function m.draw()
	--Render the world
    myWorld:renderCells(myEntity.transform, mainCamera, false)
    myEntity.renderer:debugRender()
end

return m