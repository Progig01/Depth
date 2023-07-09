--Create the module
local m = {}

	--Import control mappings
	mappings = require('assets/def/mappingDef')

	function m.newInputHandler()
		local handler = { --Create an empty table to be our input handler object
			state = nil,
			mapping = nil,
			mappingName = nil,
			controlEntity = nil
		}


		--Set an input mapping as active so button presses can be filtered accordingly
		function handler:setActiveMapping(mappingName)
			self.mapping = mappings[mappingName]
			self.mappingName = mappingName
		end

		function handler:getActiveMapping()
			return self.mappingName
		end

		--Set an active state, states check the virtual controller and perform actions in game accordingly
		function handler:setActiveState(stateFile)
			handler.state = require(stateFile)
			handler.state.parent = self
		end

		--Execute commands from the state file
		function handler:update(dt)
			handler.state:update(dt)
		end

		--Handlers for taking input from loves event-based control system and making a virtual gamepad for checking button-downs
		--Virtual button handler for keypresses
		function handler:keypressed(key)
			if self.mapping.keyboard[key] ~= nil then
				self.mapping.vButtons[self.mapping.keyboard[key]] = true
			end
		end

		--Virtual button handler for keyreleases
		function handler:keyreleased(key)
			if self.mapping.keyboard[key] ~= nil then
				self.mapping.vButtons[self.mapping.keyboard[key]] = false
			end
		end

		--Virtual button handler for mousepresses
		function handler:mousepressed(x, y, button, istouch, presses)
			if self.mapping.mouse[button] ~= nil then
				self.mapping.vButtons[self.mapping.mouse[button]] = true
			end
		end

		--Virtual button handler for mousereleases
		function handler:mousereleased(x, y, button, istouch, presses)
			if self.mapping.mouse[button] ~= nil then
				self.mapping.vButtons[self.mapping.mouse[button]] = false
			end
		end

		--Virtual button handler for scroll wheel movement
		function handler:wheelmoved(x, y)
			local sv = self.mapping.scrollValue
			sv.x, sv.y = sv.x+x, sv.y+y
		end


		return handler --Ship it out
	end




--Attach the handlers to the love module callbacks
local inputHandler = m.newInputHandler()
m = inputHandler

function love.keypressed(key, scancode, isrepeat) inputHandler:keypressed(key, scancode, isrepeat) end
function love.keyreleased(key, scancode) inputHandler:keyreleased(key, scancode) end
function love.mousepressed(x, y, button, istouch, presses) inputHandler:mousepressed(x,y,button,istouch,presses) end
function love.mousereleased(x, y, button, istouch, presses)	inputHandler:mousereleased(x,y,button,istouch,presses) end
function love.wheelmoved(x, y) inputHandler:wheelmoved(x,y) end


--Return the module
return m

