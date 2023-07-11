--Create a table to store the definitions list
local d = {}

	d.transform = { --Contains an entities position, rotation, scale, and related functions. No requirements
		requirements = {}, parentEntity = nil,
		--Fields & Default Values
		x=0, y=0, z=1, r=0, s=1, --Position(XYZ), rotation(Radians), Size(Radius in pixels)

		--Getter/Setter Functions
		getPosition = function(self) return self.x, self.y, self.z end, 					--Position getter
		getScale = function(self) return self.sX, self.sY end, 								--Scale getter
		setScale = function(self, s) self.s = s end, 										--Scale setter
		setPosition = function(self, x, y, z) self.x=x self.y=y self.z=z or self.z end,		--Position setter
		--Actual functions
		getHeadingVector = function(self)	--Get the heading vector from the rotation angle
			return math.cos(self.r), math.sin(self.r)
		end,
		getDistancePlanar = function(self, x, y) --Get the distance of the entity from a point
			return math.sqrt(math.pow(x - self.x,2) + math.pow(y - self.y,2)) 
		end,
		isColliding = function(self, x, y, z) --Check if a point is colliding with the entity
			if z == self.z then
				if self:getDistancePlanar(x, y) < self.s then
					return true
				else
					return false
				end
			end
		end
	}

	d.renderer = { --Contains an entities position, rotation, scale, and related functions. Requires transform
		requirements = {"transform"}, parentEntity = nil,
		--Getter/Setter functions
		--Actual functions
		debugRender = function(self)
			local r,g,b,a = love.graphics.getColor()
			local transform = self.parentEntity.components.transform
			love.graphics.setColor(1,1,1,1)
			love.graphics.circle("line", transform.x, transform.y, transform.s)
			love.graphics.setColor(r,g,b,a)
		end
	}

	d.playerCore = { --Contains player-specific information, like harvest
		requirements = {}, parentEntity = nil,
		--Fields & Default Values
		health, maxHealth, alive = 100,100,true, --Current and maximum HP, and living status
		canHarvest, harvestPower = true,1, --If the player can currently break blocks, and how effectively
		movementSpeed, maxMovementSpeed = 100,100, --The players movement speed and max movement speed in pixels/second
		size = 4, --The players size (radius in pixels)

		--Getter functions ----------------------------------------------------------------
		getHealth 			= function(self) return self.health 			end,
		getMaxHealth 		= function(self) return self.maxHealth 			end,
		getAlive			= function(self) return self.alive				end,
		getCanHarvest 		= function(self) return self.canHarvest 		end,
		getHarvestPower 	= function(self) return self.harvestPower 		end,
		getMovementSpeed 	= function(self) return self.movementSpeed 		end,
		getMaxMovementSpeed = function(self) return self.maxMovementSpeed 	end,
		getSize 			= function(self) return self.size 				end, 
		--Setter functions ---------------------------------------------------------------
		setHealth 			= function(self, hp) 	self.health = hp 				end,
		setMaxHealth 		= function(self, hp) 	self.maxHealth = hp 			end,
		setAlive			= function(self, alive) self.alive = alive				end,
		setCanHarvest 		= function(self, state) self.canHarvest = state 		end,
		setHarvestPower 	= function(self, pow) 	self.harvestPower = pow 		end,
		setMovementSpeed 	= function(self, speed) self.movementSpeed = speed 		end,
		setMaxMovementSpeed = function(self, speed) self.maxMovementSpeed = speed 	end,
		setSize 			= function(self, size) 	self.size = size 				end, 
 		--Actual functions ---------------------------------------------------------------
 		damage = function(self, damage) --Handle damaging the player
 			if damage > 0 then
	 			if self:getHealth() - damage <= 0 then
	 				self:setHealth(0)
	 				self:setAlive(false)
	 			else
	 				self:setHealth(self:getHealth() - damage)
	 			end
	 		end
 		end,
 		heal = function (self, heal) --Handle healing the player
 			if heal > 0 then
 				if self:getHealth() + heal > self:getMaxHealth() then
 					self.setHealth(self:getMaxHealth())
 				else
 					self.setHealth(self:getHealth() + heal)
 				end
 			end
 		end
	}

--Return the definitions list
return d