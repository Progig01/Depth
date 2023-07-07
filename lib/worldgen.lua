--Create an empty table to be our module
local m = {}

	function sampleMaterial(material, sX, sY)
		if material == 'dirt' then
			local c1 = love.math.noise(sX, sY, sX+sY)
			local c2 = love.math.noise(sX*2, sY*2, sX+sY)
			local c3 = love.math.noise(sX/2, sY/2, sX+sY)
			local c4 = love.math.noise(sX, sY, sX+sY)

			local r = (064/255) * (((c1 + c2 + c3 + c4)/4)*2)
			local g = (041/255) * (((c1 + c2 + c3 + c4)/4)*2)
			local b = (005/255) * (((c1 + c2 + c3 + c4)/4)*2)

			return r,g,b
		end

		if material == 'grass' then
			local c1 = love.math.noise(sX/2, sY/2, sX+sY)
			local c2 = love.math.noise(sX/4, sY/4, sX+sY)
			local c3 = love.math.noise(sX/8, sY/8, sX+sY)
			local c4 = love.math.noise(sX/16, sY/16, sX+sY)/32

			local r = (000/255) * (((c1 + c2 + c3 + c4)/4)*2)
			local g = (154/255) * (((c1 + c2 + c3 + c4)/4)*2)
			local b = (023/255) * (((c1 + c2 + c3 + c4)/4)*2)

			return r,g,b
		end
	end

	--Make an image
	local w, h = 32,32
	sample = love.image.newImageData(w, h)
	--Fill the image with noise from generator
	for x=0, w-1 do
		for y=0, h-1 do
			local r,g,b = sampleMaterial('dirt', x, y)
			sample:setPixel(x, y, r,g,b,1)
		end
	end
	--Convert values to tiles in some nice way?
	image = love.graphics.newImage(sample)



	

--Return our module
return m