local gamera = require('lib/third_party/gamera')
local dBug = require('debugMain')

local PROFILE = false
function love.load()
	love.window.setVSync(0)
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	math.randomseed(111211811)
	dBug.load()

	if PROFILE then
		love.profiler = require("lib/third_party/profile")
	end
end

if PROFILE then
	love.frame = 0
	love.profiling = false
end

function love.update(dt)
	if PROFILE then
		love.frame = love.frame + 1
		if love.frame%100 == 0 and love.profiling == false then
			love.profiler.start()
			love.profiling = true
	  	elseif love.frame%100 == 0 and love.profiling == true then
	  		love.report = love.profiler.report(20)
	  		love.profiler.reset()
	  	end
	end

	dBug.update(dt)
end

function love.draw()
    mainCamera:draw(dBug.draw)
    love.graphics.print("DEPTH: " .. myEntity.transform.z, 0,0)
    
    if PROFILE then
    	love.graphics.print(love.report or "Please wait...")
    end
end