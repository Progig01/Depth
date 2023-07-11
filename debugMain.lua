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
	--Make a camera
	mainCamera = gamera.new(0,0,2048,2048)
	mainCamera:setScale(3.0)

	--Make a world
	myWorld = world.newWorld(2,2,16)
	myWorld.seed = 111211811
	myWorld:generate()

	--Make a player, attached to the world
	myEntity = entity.createEntity("playerEntity", myWorld)
	myEntity.transform:setPosition(100,100, 1)
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