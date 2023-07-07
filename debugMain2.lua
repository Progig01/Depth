--Leave actual main.lua alone, do the dumb shit here
--Import some shit
local world = require('lib/world')
local entity = require('lib/entity')
local input = require('lib/input')
--local wGen = require('lib/worldgen')
local gamera = require('lib/third_party/gamera')

--Module time
local m = {}

function m.load()
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	mainCamera = gamera.new(0,0,2048,2048)
	mainCamera:setScale(8.0)
	mainCamera:setPosition(0,0)

	require('lib/worldgen')

end

function m.update(dt)

end

function m.draw()
	love.graphics.draw(image, 0,0)
end

return m