--Create a table to store the definitions list
local d = {}

	d.test_mapping = {
		keyboard = {
			w = "up",
			up = "up",
			s = "down",
			down = "down",
			a = "left", 
			left = "left",
			d = "right",
			right = "right"
		},

		mouse = {

		},

		vButtons = {
			up = false,
			down = false,
			left = false,
			right = false,
		}
	}

--Return the definitions list
return d