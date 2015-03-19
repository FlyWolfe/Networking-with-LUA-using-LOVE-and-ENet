local name = ""
local ip = "128.153.220.77"
local flag = 1
local Color1 = 5
local Color2 = 5
local Color3 = 5

function love.draw()
	love.graphics.print("ip: " .. ip, 10, 10)
	love.graphics.print("name: " .. name, 10, 30 )
	love.graphics.print("Red: " .. Color1, 10, 50 )
	love.graphics.print("Green: " .. Color2, 10, 70 )
	love.graphics.print("Blue: " .. Color3, 10, 90 )
end

function love.keypressed( key )
	if key == 'return' then
		if flag == 1 then
			flag = 2
		elseif flag == 2 then
			flag = 3
		elseif flag == 3 then
			flag = 4
		elseif flag == 4 then
			flag = 5
		elseif flag == 5 then
			playing( ip, name, Color1, Color2, Color3 )
		end
	elseif key == 'backspace' then
		if flag == 1 then
			ip = string.sub(ip, 1, string.len( ip ) - 1)
		elseif flag == 2 then
			name = string.sub(name, 1, string.len( name ) - 1)
		elseif flag == 3 then
			Color1 = string.sub(Color1, 1, string.len( Color1 ) - 1)
		elseif flag == 4 then
			Color2 = string.sub(Color2, 1, string.len( Color2 ) - 1)
		elseif flag == 5 then
			Color3 = string.sub(Color3, 1, string.len( Color3 ) - 1)
		end
	else
		if flag == 1 then
			ip = ip .. key
		elseif flag == 2 then
			name = name .. key
		elseif flag == 3 then
			Color1 = Color1 .. key
		elseif flag == 4 then
			Color2 = Color2 .. key
		elseif flag == 5 then
			Color3 = Color3 .. key
		end
	end
end