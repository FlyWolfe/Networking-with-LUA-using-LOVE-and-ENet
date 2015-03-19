--Client
require 'enet'
local uuid = require 'libs/UUID'
local pent = require 'libs/serpent'

local clients = {}
local client = {}
local me = {}
local R = 5
local G = 5
local B = 5
local chatting = false
local chat = ""
local bulletMoving = false
local DT = 0
local timeLeft = 0
local removebullets = false




local function dump(tab)
	return pent.dump(tab, ignors)
end

function client.init( ip, name, Color1, Color2, Color3 )
	me.x, me.y, me.name, me.h, me.w, me.chat, me.bullets = 400, 300, name, 32, 32, "", {}
	me.color = { Color1, Color2, Color3 }
	R = Color1
	G = Color2
	B = Color3
	client.fname = "user:" .. me.name
	client.host = enet.host_create()
	client.server = client.host:connect('142.105.238.54:4444')
end

function client.draw(self)
	if not self then
		for k,v in pairs(clients) do
			client.draw(v)
		end
		client.draw(me)
		--bulletDraw(me)
		love.graphics.print(client.connected .. "ms", 0, 0)
		if client.error then love.graphics.print(client.error, 400,300) end
	else
		function love.keypressed(key)
			if chatting == false then
				if key == "return" then
					chatting = true
					self.chat = ""
				end
			elseif chatting == true then
				if key == "return" then
					chatting = false
				elseif key == 'backspace' then
					self.chat = string.sub(self.chat, 1, string.len( self.chat ) - 1)
				else
					self.chat = self.chat .. key
				end
			end
		end
		camera:set()
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x - self.w/2, self.y - self.h/2, self.w, self.h)
		--love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)
		drawP()
		bulletDraw(self)
		love.graphics.setColor(self.color)
		love.graphics.print(self.name, self.x - (love.graphics.getFont():getWidth(self.name)/2), self.y - (love.graphics.getFont():getHeight()) - 24)
		love.graphics.print(self.chat, self.x - (love.graphics.getFont():getWidth(self.chat)/2), self.y - (love.graphics.getFont():getHeight()) - 35)
		camera:unset()
	end
end


function client.update(dt, self)
	updateP(dt)
	bulletUpdate(dt, me)
	DT = dt
	timeLeft = timeLeft - dt
	if not self then
		self = client
		me.y = player:getY()
		me.x = player:getX()
		local event = client.host:service()
		if event then
			if event.type == 'connect' then
				event.peer:send("connect=" .. dump(me))
				client.peer = event.peer
			elseif event.type == 'receive' then
				local msg = event.data:sub(1,8)
				if msg == 'message=' then
					local d = assert(loadstring(event.data:sub(9)))
					local client = d()
					clients[client.name] = client
				elseif msg == 'discone=' then
					clients[event.data:sub(9)] = nil
				else

				end
			end
		end
		if timeLeft <= 0 then
			if client.peer then
				client.peer:send("message=" .. dump(me))
				timeLeft = 0.04
			end
		end
		client.server:ping()
		client.connected = client.server:round_trip_time()
		if client.connected >= 500 then
			client.error = "DISCONNECTED"
		else
			client.error = nil
		end
	end
end

function client.quit()
	if client.peer then
		client.peer:send("discone=" .. me.name)
	end
	local event = client.host:service(100)

	client.server:disconnect_later()
	client.host:flush()
end


function load( ip, name, Color1, Color2, Color3)
	client.init( ip, name, Color1, Color2, Color3 )
	love.draw, love.update, love.quit = client.draw, client.update, client.quit
	loadOthers()
	bulletLoad()
end







--RoPG Stuff
local AdvTileLoader = require("libs/AdvTiledLoader.Loader")
require("libs/camera")

love.graphics.setBackgroundColor(220, 220, 255)
AdvTileLoader.path = "libs/maps/"
map = AdvTileLoader.load("map2.tmx")
map:setDrawRange(0, 0, map.width * map.tileWidth, map.height * map.tileHeight)

camera:setBounds(0, 0, map.width * map.tileWidth - love.graphics.getWidth(), map.height * map.tileHeight - love.graphics.getHeight())

world =          {
				 gravity = 1536,
				 ground = 512,
				 }
player =         {
				 x = 255,
				 y = 255,
				 x_vel = 0,
				 y_vel = 0,
				 jump_vel = -1024,
				 speed = 512,
				 flySpeed = 700,
				 state = "",
				 h = 32,
				 w = 32,
				 standing = false,
				 }

function loadOthers()

                     
    function player:jump()
        if player.standing then
            player.y_vel = player.jump_vel
            player.standing = false
        end
    end
    function player:right()
        player.x_vel = player.speed
    end
    function player:left()
        player.x_vel = -1 * player.speed
    end
    function player:stop()
        player.x_vel = 0
    end
    function player:collide(event)
        if event == "floor" then
            player.y_vel = 0
            player.standing = true
        end
        if event == "ceiling" then
            player.y_vel = 0
        end
    end
    function player:update(dt)
        local halfX = player.w / 2
        local halfY = player.h / 2
        
        player.y_vel = player.y_vel + (world.gravity * dt)
        
        player.x_vel = math.clamp(player.x_vel, -player.speed, player.speed)
        player.y_vel = math.clamp(player.y_vel, -player.flySpeed, player.flySpeed)
        
        local nextY = player.y + (player.y_vel*dt)
        if player.y_vel < 0 then
            if not (player:isColliding(map, player.x - halfX, nextY - halfY))
            and not (player:isColliding(map, player.x + halfX - 1, nextY - halfY)) then
                player.y = nextY
                player.standing = false
            else
                player.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
                player:collide("ceiling")
            end
        end
        if self.y_vel > 0 then
            if not (player:isColliding(map, player.x - halfX, nextY + halfY))
            and not (player:isColliding(map, player.x + halfX - 1, nextY + halfY)) then
                player.y = nextY
                player.standng = false
            else
                player.y = nextY - ((nextY + halfY) % map.tileHeight)
                player:collide("floor")
            end
        end
        
        local nextX = player.x + (player.x_vel * dt)
        if player.x_vel > 0 then
            if not (player:isColliding(map, nextX + halfX, player.y - halfY))
            and not (player:isColliding(map, nextX + halfX, player.y + halfY - 1)) then
                player.x = nextX
            else
                player.x = nextX - ((nextX + halfX) % map.tileWidth)
            end
        elseif player.x_vel < 0 then
            if not (player:isColliding(map, nextX - halfX, player.y - halfY))
            and not (player:isColliding(map, nextX - halfX, player.y + halfY - 1)) then
                player.x = nextX
            else
                player.x = nextX + map.tileWidth - ((nextX - halfX) % map.tileWidth)
            end
        end
        
        player.state = player:getState()
    end
	
	function player:getX()
		return player.x
	end
	function player:getY()
		return player.y
	end
	
    function player:isColliding(map, x, y)
        local layer = map.tl["Solid"]
        local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
        local tile = layer.tileData(tileX, tileY)
        return not(tile == nil)
    end
    function player:getState()
        local tempState = ""
        if player.standing then
            if player.x_vel > 0 then
                tempState = "right"
            elseif player.x_vel < 0 then
                tempState = "left"
            else
                tempState = "stand"
            end
        end
        if player.y_vel > 0 then
            tempState = "fall"
        elseif player.y_vel < 0 then
            tempState = "jump"
        end
        return tempState
    end
    
                     
end

function updateP(dt)
    if dt > 0.05 then
        dt = 0.05
    end
	if chatting == false then
		if love.keyboard.isDown("d") then
			player:right()
		end
		if love.keyboard.isDown("a") then
			player:left()
		end
		if love.keyboard.isDown(" ") and not(hasJumped) then
			player:jump()
		end
	end
    player:update(dt)
    
    camera:setPosition(player.x - (love.graphics.getWidth()/2), player.y - (love.graphics.getHeight()/2))
end

function love.keyreleased(key)
    if (key == "a") or (key == "d")then
        player.x_vel = 0
    end
end

function drawP()
    --love.graphics.setColor(R, G, B)
    --love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)
	
    love.graphics.setColor(255, 255, 255)
    map:draw()
end





--Bullet Stuff
function bulletLoad()
    --love.graphics.setBackgroundColor(54, 172, 248)
    
    bulletSpeed = 1200
end

function bulletDraw(self)
    --love.graphics.setColor(255, 255, 255)
    --love.graphics.rectangle("fill",  player.x, player.y, player.width, player.height)
    
    love.graphics.setColor(200, 10, 10)
    for i,v in ipairs(self.bullets) do
        love.graphics.circle("fill", v.x, v.y, 3)
    end
end

function bulletUpdate(dt, self)
	local tempMoving = false
    for i,v in ipairs(self.bullets) do
        v.x = v.x + (v.dx * dt)
        v.y = v.y + (v.dy * dt)
		if v.x > map.width * map.tileWidth or v.y > map.height * map.tileHeight or v.x <= 0 or v.y <= 0 or hasCollided(map, v.x, v.y) then
			v.remove = true
			self.bullets[i] = nil
		end
    end
	function love.mousepressed(x, y, button)
		local canUpdate = true
	    for i,v in ipairs(self.bullets) do
			if self.bullets[i] == nil then
			else
				canUpdate = false
			end
		end
		if button == "l" and canUpdate == true then
			local startX = player.x-16 + player.w / 2
			local startY = player.y-16 + player.h / 2
			local mouseX = x + camera.x
			local mouseY = y + camera.y
			
			local angle = math.atan2((mouseY - startY), (mouseX - startX))
			
			local bulletDx = bulletSpeed * math.cos(angle)
			local bulletDy = bulletSpeed * math.sin(angle)
			
			table.insert(self.bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
		end
	end
end

function hasCollided(map, x, y)
        local layer = map.tl["Solid"]
        local tileX, tileY = math.floor(x / map.tileWidth), math.floor(y / map.tileHeight)
        local tile = layer.tileData(tileX, tileY)
        return not(tile == nil)
end