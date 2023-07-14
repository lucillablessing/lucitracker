function love.run()

	function love.keypressed(_)
		if not song_is_playing then
			luci.update.frame()
			luci.video.frame()
			song_is_playing = true
		end
	end

	luci = {}

	require "luci.draw"

	luci.draw.loading()

	require "luci.init"
	require "luci.effect"
	require "luci.misc"
	require "luci.play"
	require "luci.read"
	require "luci.update"
	require "luci.veffect"
	require "luci.video"
	require "luci.waves"

	luci.init.constants()
	luci.init.init()
	luci.draw.clear()

	local next_time = love.timer.getTime()
	local time

	return function()

		love.timer.step()
		next_time = next_time + min_frametime

		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		luci.update.all()
		luci.draw.all()

		time = love.timer.getTime()
		if next_time <= time then
			next_time = time
			return
		end
		love.timer.sleep(next_time - time)
	end
end