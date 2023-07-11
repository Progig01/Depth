--Create a table to store the definitions list
local d = {}

	d.playerEntity = {
		name = "playerEntity",			--The name of the entity in code reference
		localizedName = {en="Player"},	--The localized name of the entity, displayed to the player
		world = nil,					--The world the entity is currently attached to/in
		componentsAttached = false,		--Have components been attached since the last time one was added to the list?
		components = {"transform", "renderer", "playerCore"},		--A list of components that this entity should have, to be replaced with actual components on creation
		tickFunction = nil              --A function called every time this entity ticks
	}

--Return the definitions list
return d