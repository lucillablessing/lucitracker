luci.read = {}


function luci.read.input()
	local arg = love.arg.parseGameArguments(arg)[1]
	if love.filesystem.isFused() then
		if arg then
			local filename = arg:gsub("\\", "/"):match(".*%/([^%/]*)")
			local file = io.open(arg, "rb"):read("a")
			local data = love.filesystem.newFileData(file, filename)
			love.filesystem.mount(data, "data")
		else
			love.event.quit()
		end
	end
end


function luci.read.beats()
	local l = love.filesystem.lines("data/config/beats.txt")
	min_frametime = 1 / tonumber(l())
	frames_per_beat = tonumber(l())
	frame = tonumber(l())
	frametime = min_frametime * frames_per_beat
	draw_channels = {}
	draw_channels.n = tonumber(l())
	for i = 0, draw_channels.n - 1 do
		draw_channels[i] = { quad = love.graphics.newQuad(0, 0, 64, 64, 64, 64) }
	end
end


function luci.read.channels()
	channels = {}
	local i = 0
	for line in love.filesystem.lines("data/config/channels.txt") do
		local l = line:gmatch("%S+")
		local c = {}
		local s = {}
		local type = l(); c.type = type
		c.effects = tonumber(l())
		c.vol_mod = tonumber(l())
		c.o_mod   = tonumber(l())
		c.env_i   = tonumber(l())
		c.timbre  = tonumber(l())
		if type == "noise" then
			for j = 0, 15 do
				s[j] = love.audio.newSource(noises[j])
			end
		elseif type == "sample" then
			local j = 0
			while samples[j] do
				local source = love.audio.newSource(samples[j])
				s[j] = source
				if samples_loop[j] then source:setLooping(true) end
				j = j + 1
			end
		elseif type == "tone" then
			for l = 0, wave_indices.n - 1 do
				local octaves = {}
				for k = 0, 7 do
					local source = love.audio.newSource(waves[k][wave_indices[l]])
					source:setLooping(true)
					octaves[k] = source
				end
				s[l] = octaves
			end
		else error() end
		c.sources = s
		c.o_adj = 0
		c.vol_g = 15
		c.vol_h = 15
		channels[i] = c
		i = i + 1
	end
	channels.n = i
end


function luci.read.envelopes()
	envelopes = {}
	local i = 0
	for line in love.filesystem.lines("data/config/envelopes.txt") do
		local l = line:gmatch("%S+")
		local e = {}
		local j = 0
		while true do
			local frame = l()
			if not frame then break end
			e[j] = tonumber(frame)
			j = j + 1
		end
		envelopes[i] = e
		i = i + 1
	end
end


function luci.read.images()
	image_indices = {}
	for line in love.filesystem.lines("data/config/images.txt") do
		local s = line:find("#")
		local b = line
		local t
		if s then
			b = line:sub(1, s - 1)
			local frames = tonumber(line:sub(s + 1))
			t = {}
			for i = 0, frames - 1 do
				t[i] = love.graphics.newImage("data/image/" .. b .. "_" .. i .. ".png")
				t[i]:setWrap("repeat")
			end
		else
			t = love.graphics.newImage("data/image/" .. line .. ".png")
			t:setWrap("repeat")
		end
		image_indices[b] = t
	end
end


function luci.read.samples()
	samples = {}
	samples_loop = {}
	local i = 0
	for line in love.filesystem.lines("data/config/samples.txt") do
		local looping = false
		if line:sub(1, 1) == "*" then
			looping = true
			line = line:sub(2)
		end
		samples[i] = love.sound.newSoundData("data/sound/" .. line .. ".wav")
		samples_loop[i] = looping
		i = i + 1
	end
end


function luci.read.sequence()
	sequence = {}
	local lengths = {tone = 3, noise = 1, sample = 2}
	local i = 0
	for line in love.filesystem.lines("data/sequence.txt") do
		local s = {}
		for j = 0, channels.n - 1 do
			local c = channels[j]
			local t, e = c.type, c.effects
			local length = lengths[t]
			if not length then error() end
			local offset = length + 2 + 3 * e
			s[j] = luci.read.sequence_line(line, length, e)
			line = line:sub(offset)
		end
		sequence[i] = s
		i = i + 1
	end
end


function luci.read.sequence_line(l, n, e)
	local s = {}
	local
		note,
		octave,
		volume,
		effect,
		left,
		right,
		effect_,
		left_,
		right_

	if n >= 3 then
		if l:sub(1, n) == "---" then
			note = -1
		elseif l:sub(1, n) ~= "   " then
			octave = hex(l:sub(3, 3))
			note = tuning_values[tuning_notes[l:sub(1, 2)]]
		end
	else
		note = (l:sub(1, 1) == "-") and -1 or hex(l:sub(1, n))
	end
	volume = hex(l:sub(n + 1, n + 1))
	effect = luci.effect.table[l:sub(n + 2, n + 2)]
	if effect then
		left  = hex(l:sub(n + 3, n + 3))
		right = hex(l:sub(n + 4, n + 4))
	end
	if e == 2 then
		effect_ = luci.effect.table[l:sub(n + 5, n + 5)]
		if effect_ then
			left_  = hex(l:sub(n + 6, n + 6))
			right_ = hex(l:sub(n + 7, n + 7))
		end
	end
	return {
		note    = note;
		octave  = octave;
		volume  = volume;
		effect  = effect;
		left    = left;
		right   = right;
		effect_ = effect_;
		left_   = left_;
		right_  = right_;
	}
end


function luci.read.tuning()
	tuning_notes = {}
	tuning_values = {}
	local i = 0
	for line in love.filesystem.lines("data/config/tuning.txt") do
		local l = line:gmatch("%S+")
		local value = tonumber(l())
		if value == 1 then tuning_center = i end
		tuning_values[i] = value
		while true do
			local note = l()
			if not note then break end
			tuning_notes[note] = i
		end
		i = i + 1
	end
end


function luci.read.video()
	video = {}
	for line in love.filesystem.lines("data/video.txt") do
		local video_i = {}
		line = line:gsub("%s+", "")
		if line ~= "" and line:sub(1, 1) ~= "@" then
			local l = line:gmatch("[^,]+")
			local frame = tonumber(l())
			while true do
				local chunk = l()
				if not chunk then break end
				local channel = hex(chunk:sub(1, 1))
				local m = chunk:gmatch("[%!%#%-][^%!%#%-]+")
				local s = {}
				while true do
					local thing = m()
					if not thing then break end
					s = luci.read.video_line(s, thing)
				end
				video_i[channel] = s
			end
			video[frame] = video_i
		end
	end
end


function luci.read.video_line(s, t)
	local prefix = t:sub(1, 1)
	if prefix == "!" then
		return {
			x     = hex(t:sub(2, 3));
			y     = hex(t:sub(4, 5));
			image = image_indices[t:sub(6)];
		}
	elseif prefix == "#" then
		local red, green, blue =
			hex(t:sub(2, 3)),
			hex(t:sub(4, 5)),
			hex(t:sub(6, 7))
		if red == 222 and green == 202 and blue == 222
		then return { none = true }
		else return {
			red   = red   / 255;
			green = green / 255;
			blue  = blue  / 255;
			color = true;
		}
		end
	else
		local effect = luci.veffect.table[t:sub(2, 2)]
		if effect then
			s.effects = s.effects or { n = 0 }
			local e = { id = effect }
			for i = 2, #t - 1 do e[i - 2] = hex(t:sub(i + 1, i + 1)) end
			s.effects[s.effects.n] = e
			s.effects.n = s.effects.n + 1
			return s
		end
	end
end


function luci.read.waves()
	wave_indices = {}
	local i = 0
	for line in love.filesystem.lines("data/config/waves.txt") do
		wave_indices[i] = line
		i = i + 1
	end
	wave_indices.n = i
end