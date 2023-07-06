--Create an empty table to be our module
local m = {}

	--Make an image
	local w, h = 128, 128
	sample = love.image.newImageData(w,h)
	--Fill the image with noise from generator
	for x=0, w-1 do
		for y=0, h-1 do
			local c1 = love.math.noise(x, y)
			sample:setPixel(x, y, c1, c1, 1)
		end
	end
	--Convert values to tiles in some nice way?
	image = love.graphics.newImage(sample)
	

--Return our module
return m