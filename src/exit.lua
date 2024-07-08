---@diagnostic disable: undefined-global
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnYes()
    if system.getInfo("platform") == "android" then
        native.requestExit() -- Exit the application on Android
    else
        os.exit() -- Exit the application on other platforms
    end
end

local function onBtnNo()
    composer.gotoScene( "src.menu", { effect="slideUp", time=200 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
 
    local bg = display.newImageRect("Assets/back2.png", display.actualContentWidth, display.actualContentHeight)
    bg.x = display.contentCenterX 
    bg.y = display.contentCenterY
    sceneGroup:insert( bg )

    local btn_yes = Utils.createImage( nil, "Assets/btn_yes.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    btn_yes.y = display.contentCenterY - btn_yes.contentHeight * 0.6;
    sceneGroup:insert( btn_yes )

    btn_yes:addEventListener("tap", onBtnYes)

    local btn_no = Utils.createImage( nil, "Assets/btn_no.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY + btn_yes.contentHeight * 0.6 )
    sceneGroup:insert( btn_no )

    btn_no:addEventListener("tap", onBtnNo)

    local exit = Utils.createText(nil, "EXIT?", 35, display.contentCenterX, btn_yes.y - btn_yes.contentHeight)
    sceneGroup:insert( exit )
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
-- -----------------------------------------------------------------------------------
 
return scene