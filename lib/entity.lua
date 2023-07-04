--Create the module
local m = {}

	--Import component and entity definitions
	m.componentDefinitions = require('assets/def/componentDef')
	m.entityDefinitions = require('assets/def/entityDef')

	--Create components and attach them to an entity
	function m.createComponent(component, parentEntity)
		local c = {} --Empty table to copy the definition into
		for k,v in pairs(m.componentDefinitions[component]) do
			c[k] = v
		end
		c.parentEntity = parentEntity
		return c
	end

	function m.createEntity(entity, world) --Creates a new entity based on an entity definition and attaches it to a world
		local e = {} 								--Empty table to copy the definition into
		local eDef = m.entityDefinitions[entity]	--Shortcut to the definition

		--Copy values from definition
		for k,v in pairs(eDef) do
			e[k] = v
			e.world = world
		end

		--Attach components
		for i=1, #eDef.components do
			local componentName = eDef.components[i]
			e.components[componentName] = m.createComponent(componentName, e)
			e[componentName] = e.components[componentName]
		end

		return e --ship it out
	end

	
--Return the module
return m