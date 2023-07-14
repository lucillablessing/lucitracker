luci.play = {}


function luci.play.cut(c, s)
	if c.cut then
		if c.cut == 0 then
			s:stop()
			c.cut = nil
		else
			c.cut = c.cut - 1
		end
	end
end


function luci.play.envelope_start(c, s, e)
	local env = envelopes[e]
	c.env_n = 0
	c.vol_h = env[0]
	luci.play.volume_step(c, s)
end


function luci.play.envelope_step(c, s, e)
	local env = envelopes[e]
	local n = c.env_n
	if n then
		local next = env[n + 1]
		if next then
			c.env_n = n + 1
			c.vol_h = next
			luci.play.volume_step(c, s)
		else
			c.env_n = nil
		end
	end
end


function luci.play.pitch_pre(c, v)
	if v.note and v.note >= 0 then
		if not c.playing then c.o_adj = v.octave end
		c.pitch_n = v.note * 2 ^ (v.octave + c.o_mod - c.o_adj)
	else
		c.pitch_n = c.pitch
	end
end


function luci.play.pitch_start(c, s)
	if c.port then
		c.pitch_s = c.port
		c.pitch_e = c.pitch_n
		c.pitch = c.pitch or c.pitch_n
	else
		c.pitch = c.pitch_n
	end
	c.pitch_n = nil
	s:setPitch(c.pitch)
	s:play()
	c.playing = true
end


function luci.play.slide_step(c, s)
	if c.pitch_s then
		if c.pitch_e > c.pitch then
			c.pitch = c.pitch * dpitch_s ^ c.pitch_s
			if c.pitch_e <= c.pitch then
				c.pitch = c.pitch_e
				c.pitch_e = nil
				c.pitch_s = nil
			end
		else
			c.pitch = c.pitch / dpitch_s ^ c.pitch_s
			if c.pitch_e >= c.pitch then
				c.pitch = c.pitch_e
				c.pitch_e = nil
				c.pitch_s = nil
			end
		end
	end
	s:setPitch(c.pitch * c.vib_p)
end


function luci.play.timbre_pre(c, v)
	if v.note and v.note >= 0 then c.timbre = v.note end
end


function luci.play.timbre_start(c, s)
	s:play()
	c.playing = true
end


function luci.play.vibrato_step(c)
	if c.vib_s then
		if not c.vib then c.vib = 0 end
		c.vib_p = dpitch_v ^ (c.vib_i * math.sin(tau * c.vib_s * c.vib * min_frametime))
		c.vib = c.vib + 1
	else
		c.vib_p = 1
	end
end


function luci.play.volume_start(c, s, v)
	if v then
		c.vol_g = v
		luci.play.volume_step(c, s)
	end
end


function luci.play.volume_step(c, s)
	local volume = c.vol_g * c.vol_h * c.vol_mod / 256
	s:setVolume(volume)
	if c.type == "noise" and volume == 0 then
		s:stop()
		c.playing = nil
	end
end