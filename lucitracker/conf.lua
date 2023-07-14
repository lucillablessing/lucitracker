function love.conf(t)
	t.identity          = "LuciTracker"

	t.window.title      = "LuciTracker"
	t.window.icon       = "lucitracker.png"
	t.window.width      = 512
	t.window.height     = 512
	t.window.resizable  = false
	t.window.borderless = false

	t.modules.joystick  = false
	t.modules.physics   = false
	t.modules.touch     = false
end