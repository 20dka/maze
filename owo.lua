local M = {}

game_data = {x_walls={}, y_walls={}}
local name, pass = "deer", "meow"

local socket = require("socket")
require('utils')

setLogType("ERROR",31,false,31)
setLogType("WIN",33)
setLogType("MOTD",35)
setLogType("Incoming",32)


local client = socket.tcp()
log('meow :3')

--client:connect('94.45.252.34',4000)
client:connect('gpn-mazing.v6.rocks',4000)
do
	local peer, port = client:getpeername()

	client:settimeout(0.01)

	if peer then
		log('connected to: "' .. peer..'"', 'INFO')
	else
		log('failed to connect!', 'ERROR')
	end
end

function setCreds(n, p)
	name, pass = n, p
end

function join_game()
	--local _, err = client:send("join|deer|meow\n")
	local _, err = client:send('join|'..name..'|'..pass..'\n')
	if err then log('failed to join: '..err, 'ERROR') end
	log('joined game!', 'INFO')
end

local function clear_field()
	game_data.x_walls = {}
	game_data.y_walls = {}
	game_data.start_x = nil
	game_data.start_y = nil
end


function process_walls()
	if game_data.wall_up then table.insert(game_data.x_walls, {x=game_data.pos_x, y=game_data.pos_y}) end
	if game_data.wall_down then table.insert(game_data.x_walls, {x=game_data.pos_x, y=game_data.pos_y+1}) end
	if game_data.wall_left then table.insert(game_data.y_walls, {x=game_data.pos_x, y=game_data.pos_y}) end
	if game_data.wall_right then table.insert(game_data.y_walls, {x=game_data.pos_x+1, y=game_data.pos_y}) end
end

function process_incoming(str)
	local split = split_fn(str, '|')
	--log('packet type: '..split[1])
	
	if split[1] == 'error' then
		log('Error packet: '..split[2], 'ERROR')

	elseif split[1] == 'motd' then
		log(split[2], 'MOTD')
		join_game()
	elseif split[1] == 'goal' then
		log('goal is: '..str, 'Incoming')
		game_data.goal_x = tonumber(split[2])
		game_data.goal_y = tonumber(split[3])
	elseif split[1] == 'pos' then
		log('pos is: '..str, 'Incoming')
		game_data.pos_x = tonumber(split[2])
		game_data.pos_y = tonumber(split[3])
		game_data.wall_up    = split[4] == '1'
		game_data.wall_right = split[5] == '1'
		game_data.wall_down  = split[6] == '1'
		game_data.wall_left  = split[7] == '1'
		process_walls()

		if not game_data.start_x then game_data.start_x=game_data.pos_x; game_data.start_y=game_data.pos_y end

	elseif split[1] == 'win' then
		log('POGGERS: '..split[2].. '|' ..split[3], "WIN")
		clear_field()
	elseif split[1] == 'lose' then
		log('unpog: '..split[2].. '|' ..split[3])
		clear_field()
	end
end

local function poll()
	local rec, err, partial = client:receive()
	--log(rec)

	if not rec or err then
		if err ~= 'timeout' then log("socket error: "..tostring(err), 'ERROR') end
		if err == "closed" or err == "Socket is not connected" then os.exit() end
	else
		process_incoming(rec)
	end
end

local function sendMove(dir)
	local _, err = client:send('move|'..dir..'\n')
	if err then log('failed to send move: '..err, 'ERROR') end
	log('sent move', 'INFO')
end

local function sendChat(msg)
	--msg = msg:gsub('[_%w%g]')

	local _, err = client:send('chat|'..msg..'\n')
	if err then log('failed to send chat: '..err, 'ERROR') end
	log('sent chat '..msg, 'INFO')
end

M.move = sendMove
M.chat = sendChat
M.poll = poll
M.join = setCreds
return M
