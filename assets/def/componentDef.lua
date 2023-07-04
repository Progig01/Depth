--Create a table to store the definitions list
local d = {}

	d.transform = { --Contains an entities position, rotation, scale, and related functions. No requirements
		x=0, y=0, r=0, sX=1, sY=1, requirements={}, parentEntity = nil
	}
		--Getter/Setter functions
		function d.transform:getPosition() return self.x, self.y  end 			--Position getter
		function d.transform:getScale() return self.sX, self.sY end 			--Scale getter
		function d.transform:setPosition(x, y) self.x, self.y = x, y 	 end 	--Position setter
		function d.transform:setScale(sX, sY) self.sX, self.sY = sX, sY end 	--Scale setter
		--Actual functions
		function d.transform:getHeadingVector()	--Get the heading vector from the rotation angle
			return math.cos(self.r), math.sin(self.r)
		end

	d.renderer = { --Contains an entities position, rotation, scale, and related functions. Requires transform
		requirements = {"transform"}, parentEntity = nil
	}
		--Getter/Setter functions
		--Actual functions
		function d.renderer:debugRender()
			local r,g,b,a = love.graphics.getColor()
			local transform = self.parentEntity.components.transform
			love.graphics.setColor(1,1,1,1)
			love.graphics.circle("line", transform.x, transform.y, transform.sX)
			love.graphics.setColor(r,g,b,a)
		end

--Return the definitions list
return d