local world = require('lib/world')
local entity = require('lib/entity')
local input = require('lib/input')
local gamera = require('lib/third_party/gamera')

function love.load()
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	math.randomseed(111211811)
	--math.randomseed(os.time())

	myWorld = world.newWorld(4,4)
	--myWorld.grids[1][1]:generate()
	testCell = myWorld.grids[1][1].cells[4][4]

	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(100,100)
	myEntity.transform:setScale(4)

	myHandler = input.newInputHandler()
	myHandler:setActiveMapping("test_mapping")
	myHandler:setActiveState("assets/state/testState")
	myHandler.controlEntity = myEntity

	myCamera = gamera.new(0,0,2048,2048)
	myCamera:setScale(2.0)

	--require('lib/worldgen')
end

function love.keypressed(key, scancode, isrepeat)
	myHandler:keyPressed(key)
end

function love.keyreleased(key, scancode)
	myHandler:keyReleased(key)
end

function love.update(dt)
	myHandler:update(dt)
	myCamera:setPosition(myEntity.transform.x, myEntity.transform.y)
	--print(myEntity.transform:getPosition())
	--print("FPS: " .. 1/dt .. "  TICK: " .. dt*1000 .. "ms")
	local cX, cY = myCamera:toWorld(love.mouse.getX(), love.mouse.getY())
	local cell = myWorld:getCellAt(cX, cY)
	print(cell.x, cell.y)
end

function cameraDraw()
	myWorld:debugRender()
    myWorld:renderCells()
    myEntity.renderer:debugRender()
    --love.graphics.draw(image, 100, 100)
end

function love.draw()
    myCamera:draw(cameraDraw)
end