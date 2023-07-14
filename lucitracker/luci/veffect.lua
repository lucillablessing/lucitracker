luci.veffect = {}


local function move_up(t, c)
	if t[0] == 0 then
		c.move_y, c.move_y_p, c.move_y_u = nil
	else
		if t[1] == 0 then
			c.y = c.y - t[0]
		else
			c.move_y   = -t[0]
			c.move_y_p =  t[1]
			c.move_y_u =  frame
		end
	end
end


local function move_left(t, c)
	if t[0] == 0 then
		c.move_x, c.move_x_p, c.move_x_u = nil
	else
		if t[1] == 0 then
			c.x = c.x - t[0]
		else
			c.move_x   = -t[0]
			c.move_x_p =  t[1]
			c.move_x_u =  frame
		end
	end
end


local function move_down(t, c)
	if t[0] == 0 then
		c.move_y, c.move_y_p, c.move_y_u = nil
	else
		if t[1] == 0 then
			c.y = c.y + t[0]
		else
			c.move_y   =  t[0]
			c.move_y_p =  t[1]
			c.move_y_u =  frame
		end
	end
end


local function move_right(t, c)
	if t[0] == 0 then
		c.move_x, c.move_x_p, c.move_x_u = nil
	else
		if t[1] == 0 then
			c.x = c.x + t[0]
		else
			c.move_x   =  t[0]
			c.move_x_p =  t[1]
			c.move_x_u =  frame
		end
	end
end


local function travel_up(t, c)
	if t[0] == 0 then
		c.travel_y, c.travel_y_p, c.travel_y_u = nil
	else
		if t[1] == 0 then
			c.image_y = c.image_y - t[0]
		else
			c.travel_y   = -t[0]
			c.travel_y_p =  t[1]
			c.travel_y_u =  frame
		end
	end
end


local function travel_left(t, c)
	if t[0] == 0 then
		c.travel_x, c.travel_x_p, c.travel_x_u = nil
	else
		if t[1] == 0 then
			c.image_x = c.image_x - t[0]
		else
			c.travel_x   = -t[0]
			c.travel_x_p =  t[1]
			c.travel_x_u =  frame
		end
	end
end


local function travel_down(t, c)
	if t[0] == 0 then
		c.travel_y, c.travel_y_p, c.travel_y_u = nil
	else
		if t[1] == 0 then
			c.image_y = c.image_y + t[0]
		else
			c.travel_y   =  t[0]
			c.travel_y_p =  t[1]
			c.travel_y_u =  frame
		end
	end
end


local function travel_right(t, c)
	if t[0] == 0 then
		c.travel_x, c.travel_x_p, c.travel_x_u = nil
	else
		if t[1] == 0 then
			c.image_x = c.image_x + t[0]
		else
			c.travel_x   =  t[0]
			c.travel_x_p =  t[1]
			c.travel_x_u =  frame
		end
	end
end


local function increment_frame(t, c)
	if t[0] == 0 then
		c.image_n, c.image_i_p, c.image_i_u = nil
	else
		c.image_n   = t[0]
		c.image_i_p = t[1]
		c.image_i_u = frame
	end
end


local function set_frame(t, c)
	c.image_i = hext(t, 0, 1)
	c.image = c.image_t[c.image_i]
	c.w, c.h = c.image:getDimensions()
end


local function set_x(t, c)
	c.x = hext(t, 0, 1)
end


local function set_y(t, c)
	c.y = hext(t, 0, 1)
end


local function crop(t, c)
	c.image_x = hext(t, 0, 1)
	c.image_y = hext(t, 2, 3)
	c.image_w = hext(t, 4, 5)
	c.image_h = hext(t, 6, 7)
end


luci.veffect.table = {
	W = move_up;           -- make sprite move up by X pixels every Y time units
	A = move_left;         -- ~ left
	S = move_down;         -- ~ down
	D = move_right;        -- ~ right
	I = travel_up;         -- make quad move up by X pixels every Y time units
	J = travel_left;       -- ~ left
	K = travel_down;       -- ~ down
	L = travel_right;      -- ~ right
	N = increment_frame;   -- auto increment animation by X frames every Y time units
	M = set_frame;         -- set animation frame offset
	X = set_x;             -- set x position
	Y = set_y;             -- set y position
	C = crop;              -- set x, y, width, height for quad to draw from texture
}