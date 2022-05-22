local M = {}

local last_dir = "up"

past_moves = {}
past_places = {}

mode = "forward"

backtrack_index = 1

local function move(dir)
	table.insert(past_moves, {x=network.data.pos_x,y=network.data.pos_y, dir=dir})
	
	past_places[network.data.pos_x .. '|'..network.data.pos_y] = #past_moves
	--table.insert(past_places, {x=network.data.pos_x,y=network.data.pos_y, dir=dir})

	backtrack_index = #past_moves

	last_dir = dir

	network.move(dir)
end


local function nextDir(dir)
	if dir == 'up' then    return 'right' end
	if dir == 'down' then  return 'left' end
	if dir == 'right' then return 'down' end
	if dir == 'left' then  return 'up' end
end

local function flipDir(dir)
	if dir == 'up' then    return 'down' end
	if dir == 'down' then  return 'up' end
	if dir == 'right' then return 'left' end
	if dir == 'left' then  return 'right' end
end

-- have we been at x,y
local function checkPast(x,y)
	return past_places[x..'|'..y] ~= nil

	--for k,v in ipairs(past_places) do
	--	if v.x == x and v.y == y then return true end
	--end
	--return false
end

-- would going in d put us where we have been
local function notBeenInDir(dir)
	local x, y = network.data.pos_x, network.data.pos_y

	if dir == 'up' then y=y-1 end
	if dir == 'down' then y=y+1 end
	if dir == 'right' then x=x+1 end
	if dir == 'left' then x=x-1 end

	return not checkPast(x,y)
end

local function corridor()
	local wallcount = 0
	local working_way

	for k,v in pairs(network.data.walls) do
		if v then wallcount = wallcount+1
		else working_way = k
		end
	end
	return wallcount, working_way
end

local function decideMove()

log('deciding move..', 'Info')

--table.insert(past_places, {x=network.data.pos_x,y=network.data.pos_y})
past_places[network.data.pos_x .. '|'..network.data.pos_y] = true

	local wallcount, way_out = corridor()

	if wallcount == 3 then
		log("dead end, going back")
		if #past_moves > 1 then
			mode = 'back'

			--hack so backtracking starts
			table.insert(past_moves, {x=network.data.pos_x,y=network.data.pos_y, dir=dir})

			print('back baybeeee')
		else
			print('one way to start. letsgo')
			move(way_out) return
		end
	end

	if mode == 'forward' then

		dir = last_dir
		--local i = math.floor(math.random()*4)
		--
		--for k=0, i do
		--	dir = next(network.data.walls, dir)
		--end
		--
		--if not dir then dir = "up" end
		--
		--print("random dir: "..dir)

	print(dir)
		while network.data.walls[dir] ~= false do
			dir = nextDir(dir)
		end --until network.data.walls[dir] == false


	print(dir)

		if dir == flipDir(last_dir) then
			print(dir..' is just going back, getting next dir')
			dir = nextDir(dir)
		end


	print(dir)

		if not notBeenInDir(dir) then
			print(' we have been to '..dir..', getting next dir')

			dir = nextDir(dir)
			while network.data.walls[dir] ~= false do
				dir = nextDir(dir)
			end --until network.data.walls[dir] == false
		end


	print(dir)


	else
		log("backtracking!")

		local wallcout, way_out = corridor()
		if wallcount == 2 then

		end

		for k,v in pairs(network.data.walls) do
			if not v and notBeenInDir(k) then
				mode = 'forward'
				log('found new way! ('..k..')')

				past_moves = subset_fn(past_moves, 1, backtrack_index)

				move(k)
				return
			end
		end

		dir = flipDir(past_moves[backtrack_index].dir)

		--dir = flipDir(last_dir)
		print(last_dir .. ' '.. past_moves[backtrack_index].dir)

		backtrack_index = backtrack_index -1

		--table.remove(past_moves)
		log(string.format("went %s, let's go %s", last_dir, dir))
		last_dir = dir
		network.move(dir)
		return
	end

	move(dir)
end

M.decide = decideMove

return M
