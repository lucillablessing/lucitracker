luci.waves = {}


function luci.waves.noises()
	noises = {}
	for i = 0, 15 do
		noises[i] = love.sound.newSoundData("resources/sound/" .. i .. ".wav")
	end
end


function luci.waves.pulse(r, l, p)
	local sound_data = love.sound.newSoundData(l, r, 8, 1)
	for i = 0, p - 1 do
		sound_data:setSample(i, 1)
	end
	for i = p, l - 1 do
		sound_data:setSample(i, -1)
	end
	return sound_data
end


function luci.waves.sawtooth(r, l)
	local sound_data = love.sound.newSoundData(l, r, 8, 1)
	for i = 0, l - 1 do
		sound_data:setSample(i, 2 * (i / l) - 1)
	end
	return sound_data
end


function luci.waves.triangle(r, l)
	local sound_data = love.sound.newSoundData(l, r, 8, 1)
	local h = l / 4
	for i = 0, h - 1 do
		sound_data:setSample(i, i / h)
	end
	for i = h, 3 * h - 1 do
		sound_data:setSample(i, (2 * h - i) / h)
	end
	for i = 3 * h, l - 1 do
		sound_data:setSample(i, (i - l) / h)
	end
	return sound_data
end


function luci.waves.waves()
	waves = {}
	local rate   = 88000
	local length = 1600
	for i = 0, 7 do
		local l = 1600 * 2 ^ -i
		local w = {
			pulse_1_16 = luci.waves.pulse(rate, l, l * 1 / 16);
			pulse_1_8  = luci.waves.pulse(rate, l, l * 1 / 8);
			pulse_3_16 = luci.waves.pulse(rate, l, l * 3 / 16);
			pulse_1_4  = luci.waves.pulse(rate, l, l * 1 / 4);
			pulse_5_16 = luci.waves.pulse(rate, l, l * 5 / 16);
			pulse_3_8  = luci.waves.pulse(rate, l, l * 3 / 8);
			pulse_7_16 = luci.waves.pulse(rate, l, l * 7 / 16);
			pulse_1_2  = luci.waves.pulse(rate, l, l * 1 / 2);
			sawtooth   = luci.waves.sawtooth(rate, l);
			triangle   = luci.waves.triangle(rate, l);
		}
		waves[i] = w
	end
end