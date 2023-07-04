--Create the module
local m = {}

	--Import control mappings
	mappings = require('assets/def/mappingDef')

	function m.newInputHandler()
		local handler = { --Create an empty table to be our input handler object
			state = nil,
			mapping = nil,
			controlEntity = nil
		}


		--Set an input mapping as active so button presses can be filtered accordingly
		function handler:setActiveMapping(mappingName)
			self.mapping = mappings[mappingName]
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
		function handler:keyPressed(key)
			if self.mapping.keyboard[key] ~= nil then
				self.mapping.vButtons[self.mapping.keyboard[key]] = true
			end
		end

		--Virtual button handler for keyreleases
		function handler:keyReleased(key)
			if self.mapping.keyboard[key] ~= nil then
				self.mapping.vButtons[self.mapping.keyboard[key]] = false
			end
		end


		return handler --Ship it out
	end


--Return the module
return m