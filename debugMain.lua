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
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	math.randomseed(111211811)
	--math.randomseed(os.time())

	myWorld = world.newWorld(2,2,16)
	myWorld.grids[1][1][2]:generate()
	myWorld.grids[1][2][2]:generate()
	myWorld.grids[2][1][2]:generate()
	myWorld.grids[2][2][2]:generate()
	testCell = myWorld.grids[1][1][3].cells[4][4]
	testCell.contents = tile.createTile("tile_ladderUp", testCell)

	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(100,100, 1)
	myEntity.transform:setScale(4)

	input:setActiveMapping("test_mapping")
	input:setActiveState("assets/state/testState")
	input.controlEntity = myEntity

	mainCamera = gamera.new(0,0,2048,2048)
	mainCamera:setScale(3.0)

	--require('lib/worldgen')
end

function m.update(dt)
	input:update(dt)
	mainCamera:setPosition(myEntity.transform.x, myEntity.transform.y)
	mainCamera:setScale(1.0*input.mapping.scrollValue.y)
	--print("FPS: " .. 1/dt .. "  TICK: " .. dt*1000 .. "ms")
end

function m.draw()
	--myWorld:debugRender()
    myWorld:renderCells(myEntity.transform, mainCamera)
    myEntity.renderer:debugRender()
end

return m