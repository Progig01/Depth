local gamera = require('lib/third_party/gamera')
local dBug = require('debugMain')

function love.load()
	love.window.setVSync(0)
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	math.randomseed(111211811)
	dBug.load()
end

function love.update(dt)
	dBug.update(dt)
end

function love.draw()
    mainCamera:draw(dBug.draw)
    --dBug.draw()
end