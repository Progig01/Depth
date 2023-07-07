--Leave actual main.lua alone, do the dumb shit here
--Import some shit
local world = require('lib/world')
local entity = require('lib/entity')
local input = require('lib/input')
local gamera = require('lib/third_party/gamera')

--Module time
local m = {}

function m.load()
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	math.randomseed(111211811)
	--math.randomseed(os.time())

	myWorld = world.newWorld(4,4)
	myWorld.grids[1][1]:generate()
	testCell = myWorld.grids[1][1].cells[4][4]

	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(100,100)
	myEntity.transform:setScale(4)

	myHandler = input.newInputHandler()
	myHandler:setActiveMapping("test_mapping")
	myHandler:setActiveState("assets/state/testState")
	myHandler.controlEntity = myEntity

	mainCamera = gamera.new(0,0,2048,2048)
	mainCamera:setScale(3.0)

	--require('lib/worldgen')
end

function m.keypressed(key, scanecode, isrepeat)
	myHandler:keyPressed(key)
end

function m.keyreleased(key, scancode)
	myHandler:keyReleased(key)
end

function m.update(dt)
	myHandler:update(dt)
	mainCamera:setPosition(myEntity.transform.x, myEntity.transform.y)
	print("FPS: " .. 1/dt .. "  TICK: " .. dt*1000 .. "ms")
end

function m.draw()
	--myWorld:debugRender()
    myWorld:renderCells()
    myEntity.renderer:debugRender()
end

return m