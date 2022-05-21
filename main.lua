local grid_s = 30
local chat_buffer = "deer are cute"
local keepalivetimer = 0

function love.load()
	love.window.setMode(800, 800, {resizable=true, vsync=false, minwidth=300, minheight=300})

	network = require("owo")
	network.join('bleat :3', 'owo')
end


function love.update(dt)
	network.poll()
	if keepalivetimer then
		keepalivetimer = keepalivetimer + dt
		if keepalivetimer > 5 then
			network.chat(chat_buffer~='' and chat_buffer or 'beep')
			keepalivetimer = 0
		end
	end
end


function love.draw()
	love.graphics.setColor(1,1,1)

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("Chat: "..chat_buffer, 10, 25, 0)

	local width, height = love.graphics.getDimensions()

	width = width<height and width or height

	local x_screen_pixel = width/grid_s
	local y_screen_pixel = height/grid_s
	
	y_screen_pixel = x_screen_pixel

	-- draw grid
	if true then
		love.graphics.setColor(0.1,0.1,0.1)
		love.graphics.setLineWidth(1)
		for x=0, grid_s, 1 do
			love.graphics.line(x*x_screen_pixel, 0, x*x_screen_pixel, width)
		end
		for y=0, grid_s, 1 do
			love.graphics.line(0, y*y_screen_pixel, height, y*y_screen_pixel )
		end
	end

	-- draw player
	if game_data.pos_x then
		love.graphics.setColor(1,1,1)
		local x_screen_pos = x_screen_pixel * game_data.pos_x
		local y_screen_pos = y_screen_pixel * game_data.pos_y

		love.graphics.ellipse("fill", x_screen_pos+x_screen_pixel/2, y_screen_pos+y_screen_pixel/2, x_screen_pixel/2, y_screen_pixel/2)

		-- draw nearby walls
		love.graphics.setLineWidth(3)

		love.graphics.setColor(0,1,0)
		if game_data.wall_up then love.graphics.line(x_screen_pos, y_screen_pos, x_screen_pos+x_screen_pixel, y_screen_pos) end
		if game_data.wall_right then love.graphics.line(x_screen_pos+x_screen_pixel, y_screen_pos+y_screen_pixel, x_screen_pos+x_screen_pixel, y_screen_pos) end
		if game_data.wall_down then love.graphics.line(x_screen_pos, y_screen_pos+y_screen_pixel, x_screen_pos+x_screen_pixel, y_screen_pos+y_screen_pixel) end
		if game_data.wall_left then love.graphics.line(x_screen_pos, y_screen_pos, x_screen_pos, y_screen_pos+y_screen_pixel) end
	end

	-- draw other walls
	if game_data.x_walls then
		love.graphics.setLineWidth(1)
		for _, coords in pairs(game_data.x_walls) do
			love.graphics.line(coords.x*x_screen_pixel, coords.y*y_screen_pixel, coords.x*x_screen_pixel+x_screen_pixel, coords.y*y_screen_pixel)
		end
	
		for _, coords in pairs(game_data.y_walls) do
			love.graphics.line(coords.x*x_screen_pixel, coords.y*y_screen_pixel, coords.x*x_screen_pixel, coords.y*y_screen_pixel+y_screen_pixel)
		end
	end

	if game_data.goal_x then

		local x_screen_goal = x_screen_pixel * (game_data.goal_x or 1)
		local y_screen_goal = y_screen_pixel * (game_data.goal_y or 1)

		love.graphics.setColor(1,0,0)
		love.graphics.rectangle("fill", x_screen_goal+x_screen_pixel/4, y_screen_goal+y_screen_pixel/4, x_screen_pixel/2, y_screen_pixel/2)
	end

	if game_data.start_x then
		local x_screen_start = x_screen_pixel * (game_data.start_x or 1)
		local y_screen_start = y_screen_pixel * (game_data.start_y or 1)

		love.graphics.setColor(0,0,1)
		love.graphics.rectangle("fill", x_screen_start+x_screen_pixel/4, y_screen_start+y_screen_pixel/4, x_screen_pixel/2, y_screen_pixel/2)
	end
end

function love.keypressed(k)
	--print(k)
	if k == 'escape' or k == 'q' then
		love.event.push('quit')
	elseif k == 'return' then
		network.chat(chat_buffer)
		chat_buffer = ''
	elseif k == 'backspace' then
		chat_buffer = chat_buffer:sub(1,-2)
	elseif k == 'up' or k == 'right' or k == 'down' or k == 'left' then
		network.move(k)
	elseif k == 'unknown' then
		if keepalivetimer then keepalivetimer = nil else keepalivetimer = 0 end
		log((keepalivetimer and 'Enabling' or 'Disabling') .. ' auto chat', 'INFO')
	else
		chat_buffer = chat_buffer .. k
	end
end
