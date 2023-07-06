io.stdout:setvbuf("no") --Console output stuff

function love.conf(t) --Framework config stuff
 	t.version = "11.4"

 	t.window.title = "Depth"
 	t.window.width = 1280
 	t.window.height = 720


 	t.accelerometerjoystick = false
 	t.gammecorrect = true
 	t.identity = "depth"
 end