luci.init = {}


function luci.init.constants()
	tau      = 2 * math.pi   -- Circle constant
	dpitch_s = 1.01          -- Pitch increment for sliding
	dpitch_v = 1.005         -- Pitch increment for vibrato
	warning  = true          -- Whether to display flashing lights warning
end


function luci.init.init()

	luci.waves.noises()
	luci.waves.waves()

	luci.read.input()
	luci.read.beats()
	luci.read.tuning()
	luci.read.waves()
	luci.read.images()
	luci.read.samples()
	luci.read.envelopes()
	luci.read.channels()
	luci.read.sequence()
	luci.read.video()

	tick = 0
	song_is_playing = false
end