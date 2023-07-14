luci.video = {}


function luci.video.frame()
	luci.video.always()
	if not video[frame] then return end
	for i = 0, draw_channels.n - 1 do
		local c = draw_channels[i]
		local v = video[frame][i]
		if v then luci.video.channel(c, v) end
	end
end


function luci.video.always()
	for i = 0, draw_channels.n - 1 do
		local c = draw_channels[i]
		if c.image then
			if c.image_n
			and (frame - c.image_i_u) % c.image_i_p == 0
			then
				c.image_i = (c.image_i + c.image_n) % (#c.image_t + 1)
				c.image = c.image_t[c.image_i]
				c.w, c.h = c.image:getDimensions()
			end
			if c.move_x
			and (frame - c.move_x_u) % c.move_x_p == 0
			then c.x = c.x + c.move_x
			end
			if c.move_y
			and (frame - c.move_y_u) % c.move_y_p == 0
			then c.y = c.y + c.move_y
			end
			if c.travel_x
			and (frame - c.travel_x_u) % c.travel_x_p == 0
			then c.image_x = c.image_x + c.travel_x
			end
			if c.travel_y
			and (frame - c.travel_y_u) % c.travel_y_p == 0
			then c.image_y = c.image_y + c.travel_y
			end
			c.quad:setViewport(c.image_x, c.image_y, c.image_w, c.image_h, c.w, c.h)
		end
	end
end


function luci.video.channel(c, v)
	if v.image then
		if type(v.image) == "table" then
			c.image_t = v.image
			c.image_i = 0
			c.image   = c.image_t[c.image_i]
		else
			c.image = v.image
		end
		c.x, c.y = v.x, v.y
		c.w, c.h = c.image:getDimensions()
		c.image_x, c.image_y = 0, 0
		c.image_w, c.image_h = c.w, c.h
	elseif v.color or v.none then
		c.image  = nil
		c.x, c.y = nil
		c.w, c.h = nil
		c.image_x, c.image_y = nil
		c.image_w, c.image_h = nil
	end
	if v.color then
		c.color = v.color
		c.red, c.green, c.blue = v.red, v.green, v.blue
	elseif v.image or v.none then
		c.color = nil
		c.red, c.green, c.blue = nil
	end
	c.effects = v.effects
	if c.effects then
		for i = 0, c.effects.n - 1 do
			c.effects[i]:id(c)
		end
	end
	if c.image then
		c.quad:setViewport(c.image_x, c.image_y, c.image_w, c.image_h, c.w, c.h)
	end
end