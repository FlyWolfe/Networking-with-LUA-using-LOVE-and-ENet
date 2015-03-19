--Client
require 'enet'
local uuid = require 'libs/UUID'
local pent = require 'libs/serpent'
local AdvTileLoader = require("libs/AdvTiledLoader.Loader")
require("libs/camera")

local clients = {}
local client = {}
local me = {}


function menu()
	require 'states/menu'
end

function playing( ip, name, Color1, Color2, Color3 )
	require 'states/playing'
	load( ip, name, Color1, Color2, Color3 )
end

function love.load()
	--love.window.setFullscreen(true)
	menu()
end