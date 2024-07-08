---@diagnostic disable: undefined-global
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer = require("composer")
local Utils = require("src.helper.utils")

-- Your code here
display.setStatusBar( display.HiddenStatusBar )
-- Seed the random number generator
math.randomseed( os.time() )

local bg = display.newImageRect("Assets/back1.png", display.actualContentWidth, display.actualContentHeight)
bg.x = display.contentCenterX 
bg.y = display.contentCenterY

local loadingTxt = Utils.createImage( nil, "Assets/loading.png", display.actualContentWidth * 0.5, nil, display.contentCenterX, display.contentCenterY )
-- local loadingTxt = Utils.createText(nil, "LOADING...", 35, display.contentCenterX, display.contentCenterY)
-- loadingTxt:setFillColor( 0.98, 0.984, 0.45 )
-- loadingTxt.strokeWidth = 3
-- loadingTxt:setStrokeColor(1, 0, 0)

-- local function httpRequest(url, callback)
--     network.request(url, "GET", function(event)
--         if (event.isError) then
--             callback(nil)
--         else
--             callback(event.response)
--         end
--     end)
-- end

-- local function createWebView(data)
--     local webView = native.newWebView(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
--     webView:request(data)
-- end

-- local function loadDataAndCreateWebView()
--     local url = "https://google.com"
--     httpRequest(url, function(data)
--         loadingTxt:removeSelf()
--         bg:removeSelf()

--         if data and #data > 100 then
--             createWebView(url)
--         else
--             composer.gotoScene( "src.menu", { effect="fade", time=500 } )        
--         end
--     end)
-- end

-- loadDataAndCreateWebView()
loadingTxt:removeSelf()
bg:removeSelf()
composer.gotoScene( "src.menu", { effect="fade", time=200 } )        
