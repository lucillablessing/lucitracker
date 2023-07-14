luci.effect = {}


local function pitch_up(c, l, r)
	if r == 0 then
		c.pitch_e = nil
		c.pitch_s = nil
	else
		c.pitch_e = math.huge
		c.pitch_s = r
	end
end


local function pitch_down(c, l, r)
	if r == 0 then
		c.pitch_e = nil
		c.pitch_s = nil
	else
		c.pitch_e = 0
		c.pitch_s = r
	end
end


local function portamento(c, l, r)
	local s = hexr(l, r)
	if s == 0 then
		c.port = nil
	else
		c.port = s / 2
	end
end


local function vibrato(c, l, r)
	if l == 0 then
		c.vib_i = nil
		c.vib_s = nil
	else
		c.vib_i = r
		c.vib_s = l
	end
end


local function speed(c, l, r)
	frames_per_beat = hexr(l, r)
	frametime = min_frametime * frames_per_beat
end


local function tempo(c, l, r)
	min_frametime = 1 / hexr(l, r)
	frametime = min_frametime * frames_per_beat
end


local function slide_up(c, l, r)
	c.pitch_e = tuning_values[tuning_center + r] * c.pitch_n
	c.pitch_s = l
end


local function slide_down(c, l, r)
	c.pitch_e = tuning_values[tuning_center - r] * c.pitch_n
	c.pitch_s = l
end


local function cut(c, l, r)
	c.cut = hexr(l, r)
end


local function instrument_change(c, l, r)
	c.env_i = l
	if c.type == "tone" then c.timbre = r end
end


local function octave_change(c, l, r)
	local o_mod = hexr(l, r)
	if o_mod >= 128 then o_mod = o_mod - 256 end
	c.o_mod = o_mod
end


luci.effect.table = {
	U = pitch_up;            -- slide pitch up indefinitely
	D = pitch_down;          -- slide pitch down indefinitely
	P = portamento;          -- automatically slide to new notes
	V = vibrato;             -- control vibrato
	S = speed;               -- change number of ticks per frame
	T = tempo;               -- change number of ticks per second
	Q = slide_up;            -- slide up by a few edosteps
	R = slide_down;          -- slide down by a few edosteps
	C = cut;                 -- cut sound after a few ticks
	I = instrument_change;   -- change envelope and timbre
	O = octave_change;       -- change octave offset
}