luci.update = {}


function luci.update.all()
	if song_is_playing then
		luci.update.always()
		tick = tick + 1
		if tick == frames_per_beat then
			tick = 0
			frame = frame + 1
			luci.update.frame()
			luci.video.frame()
		end
	end
end


function luci.update.always()
	for i = 0, channels.n - 1 do
		local c = channels[i]
		if c.playing then
			local is_tone = c.type == "tone"
			local source = is_tone and c.sources[c.timbre][c.o_adj] or c.sources[c.timbre]
			luci.play.envelope_step(c, source, c.env_i)
			if is_tone then
				luci.play.vibrato_step(c)
				luci.play.slide_step(c, source)
			end
			luci.play.cut(c, source)
		end
	end
end


function luci.update.channel(c, v)
	local is_tone = c.type == "tone"

	local old_timbre = c.timbre
	local old_o_adj
	if is_tone then
		old_o_adj = c.o_adj
		luci.play.pitch_pre(c, v)
	else
		luci.play.timbre_pre(c, v)
	end

	if v.effect  then v.effect (c, v.left,  v.right ) end
	if v.effect_ then v.effect_(c, v.left_, v.right_) end

	local source = is_tone and c.sources[c.timbre][c.o_adj] or c.sources[c.timbre]
	luci.play.volume_start(c, source, v.volume)

	if v.note then
		local old_source = is_tone and c.sources[old_timbre][old_o_adj] or c.sources[old_timbre]
		if v.note >= 0 then
			if c.timbre ~= old_timbre then old_source:stop() end
			luci.play.envelope_start(c, source, c.env_i)
			if is_tone then
				luci.play.pitch_start(c, source)
			else
				luci.play.timbre_start(c, source)
			end
		else
			old_source:stop()
			c.playing = nil
		end
	end
end


function luci.update.frame()
	if not sequence[frame] then
		song_is_playing = false
		frame = 0
		return
	end
	for i = 0, channels.n - 1 do
		local c = channels[i]
		local v = sequence[frame][i]
		luci.update.channel(c, v)
	end
end