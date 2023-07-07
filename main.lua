local gamera = require('lib/third_party/gamera')
local dBug = require('debugMain')

function love.load()
	love.window.setVSync(0)
	dBug.load()
end

function love.keypressed(key, scancode, isrepeat)
	dBug.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	dBug.keyreleased(key, scancode)
end

function love.update(dt)
	dBug.update(dt)
end

function love.draw()
    mainCamera:draw(dBug.draw)
    --dBug.draw()
end