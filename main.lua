local world = require('lib/world')
local entity = require('lib/entity')
local input = require('lib/input')

function love.load()
	math.randomseed(111211811)

	myWorld = world.newWorld(2,2)
	myWorld.grids[1][1]:generate()

	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(100,100)

	myHandler = input.newInputHandler()
	myHandler:setActiveMapping("test_mapping")
	myHandler:setActiveState("assets/state/testState")
	myHandler.controlEntity = myEntity
end

function love.keypressed(key, scancode, isrepeat)
	myHandler:keyPressed(key)
end

function love.keyreleased(key, scancode)
	myHandler:keyReleased(key)
end

function love.update(dt)
	myHandler:update(dt)
	--print(myEntity.transform:getPosition())
	--print("FPS: " .. 1/dt .. "  TICK: " .. dt*1000 .. "ms")
	--print(myWorld:getCellAt(love.mouse.getX(), love.mouse.getY()))
end

function love.draw()
    myWorld:debugRender()
    myWorld:renderCells()
    myEntity.renderer:debugRender()
end