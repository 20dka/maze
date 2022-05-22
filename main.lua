local chat_buffer = "trans rights"
local keepalivetimer = 0

function love.load()
	love.window.setMode(800, 800, {resizable=true, vsync=false, minwidth=300, minheight=300, x=50, y=50})

	network = require("owo")
	network.join('bleat :3', 'owo')
	controller = require("controller")
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

	local width, height = love.graphics.getDimensions()

	width = width<height and width or height

	if not network.data.map_x then return end

	local x_screen_pixel = width/network.data.map_x
	local y_screen_pixel = height/network.data.map_y
	
	y_screen_pixel = x_screen_pixel

	-- draw grid
	if true then
		love.graphics.setColor(0.1,0.1,0.1)
		love.graphics.setLineWidth(1)
		for x=0, network.data.map_x, 1 do
			love.graphics.line(x*x_screen_pixel, 0, x*x_screen_pixel, width)
		end
		for y=0, network.data.map_y, 1 do
			love.graphics.line(0, y*y_screen_pixel, height, y*y_screen_pixel )
		end
	end

	-- draw past places
	if #past_moves > 0 then
		love.graphics.setColor(0.2,0,0)
		for place, i in pairs(past_places) do
			--if i == backtrack_index then love.graphics.setColor(1,0,0) end
			local coords = split_fn(place, '|')
			love.graphics.rectangle('fill', coords[1]*x_screen_pixel, coords[2]*y_screen_pixel, x_screen_pixel, y_screen_pixel)
		end
	end

	-- draw other walls
	if network.data.x_walls then
	
		love.graphics.setColor(1,1,1)
		love.graphics.setLineWidth(1)
		for _, coords in pairs(network.data.x_walls) do
			love.graphics.line(coords.x*x_screen_pixel, coords.y*y_screen_pixel, coords.x*x_screen_pixel+x_screen_pixel, coords.y*y_screen_pixel)
		end
	
		for _, coords in pairs(network.data.y_walls) do
			love.graphics.line(coords.x*x_screen_pixel, coords.y*y_screen_pixel, coords.x*x_screen_pixel, coords.y*y_screen_pixel+y_screen_pixel)
		end
	end

	-- draw past moves
	if #past_moves > 0 then
		love.graphics.setColor(0,1,1)
		love.graphics.setLineWidth(3)
		for i=1, #past_moves-1 do
			if i == backtrack_index then love.graphics.setColor(1,0,0) end
			love.graphics.line(past_moves[i].x*x_screen_pixel+x_screen_pixel/2, past_moves[i].y*y_screen_pixel+y_screen_pixel/2, past_moves[i+1].x*x_screen_pixel+x_screen_pixel/2, past_moves[i+1].y*y_screen_pixel+y_screen_pixel/2)
		end
		local last_move = past_moves[#past_moves]
		love.graphics.line(last_move.x*x_screen_pixel+x_screen_pixel/2, last_move.y*y_screen_pixel+y_screen_pixel/2, network.data.pos_x*x_screen_pixel+x_screen_pixel/2, network.data.pos_y*y_screen_pixel+y_screen_pixel/2)
	end

	-- draw player
	if network.data.pos_x then
		love.graphics.setColor(1,1,1)
		local x_screen_pos = x_screen_pixel * network.data.pos_x
		local y_screen_pos = y_screen_pixel * network.data.pos_y

		love.graphics.ellipse("fill", x_screen_pos+x_screen_pixel/2, y_screen_pos+y_screen_pixel/2, x_screen_pixel/2, y_screen_pixel/2)

		-- draw nearby walls
		love.graphics.setColor(0,1,0)
		love.graphics.setLineWidth(3)

		if network.data.walls.up then love.graphics.line(x_screen_pos, y_screen_pos, x_screen_pos+x_screen_pixel, y_screen_pos) end
		if network.data.walls.right then love.graphics.line(x_screen_pos+x_screen_pixel, y_screen_pos+y_screen_pixel, x_screen_pos+x_screen_pixel, y_screen_pos) end
		if network.data.walls.down then love.graphics.line(x_screen_pos, y_screen_pos+y_screen_pixel, x_screen_pos+x_screen_pixel, y_screen_pos+y_screen_pixel) end
		if network.data.walls.left then love.graphics.line(x_screen_pos, y_screen_pos, x_screen_pos, y_screen_pos+y_screen_pixel) end
	end


	if network.data.goal_x then

		local x_screen_goal = x_screen_pixel * (network.data.goal_x or 1)
		local y_screen_goal = y_screen_pixel * (network.data.goal_y or 1)

		love.graphics.setColor(1,0,0)
		love.graphics.rectangle("fill", x_screen_goal+x_screen_pixel/4, y_screen_goal+y_screen_pixel/4, x_screen_pixel/2, y_screen_pixel/2)
	end

	if network.data.start_x then
		local x_screen_start = x_screen_pixel * (network.data.start_x or 1)
		local y_screen_start = y_screen_pixel * (network.data.start_y or 1)

		love.graphics.setColor(0,0,1)
		love.graphics.rectangle("fill", x_screen_start+x_screen_pixel/4, y_screen_start+y_screen_pixel/4, x_screen_pixel/2, y_screen_pixel/2)
	end

	love.graphics.setColor(1,1,1)

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
	love.graphics.print("Chat: "..chat_buffer, 10, 30, 0)

	love.graphics.print("mode: "..mode, 10, 50, 0)
	love.graphics.print("backtrack_index: "..backtrack_index, 10, 70, 0)

	if #past_moves > 1 then
		for i, move in ipairs(past_moves) do
			if i == backtrack_index then love.graphics.setColor(1,0,0) end
			love.graphics.print(move.dir, 10+50*math.floor(i/20), 90+(i%20)*20)
		end
	end

end

function love.keypressed(k)
	--print(k)
	if k == 'escape' or k == 'q' then
		network.disconnect()
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
		--chat_buffer = chat_buffer .. k
		if controller then controller.decide() end
	end
end
