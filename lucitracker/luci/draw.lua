luci.draw = {}


function luci.draw.all()
	if song_is_playing and tick == 0 then
		love.graphics.setCanvas(canvas)
		for i = 0, draw_channels.n - 1 do
			local c = draw_channels[i]
			if c.image then
				love.graphics.draw(c.image, c.quad, c.x, c.y)
			elseif c.color then
				love.graphics.clear(c.red, c.green, c.blue)
			end
		end
		love.graphics.setCanvas()
		love.graphics.draw(canvas, 0, 0, 0, 8, 8)
		love.graphics.present()
	end
end


function luci.draw.clear()
	love.graphics.setCanvas(canvas)
	if warning then
		local image = love.graphics.newImage("resources/image/warning.png")
		love.graphics.draw(image, 0, 0)
	else
		love.graphics.clear(0, 0, 0, 1)
	end
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, 8, 8)
	love.graphics.present()
end


function luci.draw.loading()
	love.graphics.setBackgroundColor(0, 0, 0, 1)
	love.graphics.setDefaultFilter("nearest", "nearest")
	canvas = love.graphics.newCanvas(64, 64)
	local image = love.graphics.newImage("resources/image/loading.png")
	love.graphics.setCanvas(canvas)
	love.graphics.draw(image, 0, 0)
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, 8, 8)
	love.graphics.present()
end