local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")

local scene = composer.newScene()
local scoreTxt
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local function onBtnPlayGame()
    composer.gotoScene( "src.play", { effect="fromLeft", time=200 } )
end

local function onBtnExit()
    composer.gotoScene( "src.exit", { effect="fromTop", time=200 } )
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

    local bgTiger = Utils.createImage( nil, "Assets/tiger.png", display.actualContentWidth * 0.8, nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( bgTiger )

    local btn_exit = Utils.createImage( nil, "Assets/btn_exit.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_exit.y = Utils.getBottomInScreen() - btn_exit.contentHeight * 2
    sceneGroup:insert( btn_exit )

    btn_exit:addEventListener("tap", onBtnExit)

    local btn_play = Utils.createImage( nil, "Assets/btn_play.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, btn_exit.y - btn_exit.contentHeight * 1.5)
    sceneGroup:insert( btn_play )
    btn_play:addEventListener("tap", onBtnPlayGame)

    local your_score = Utils.createImage( nil, "Assets/your_score.png", 120, nil, display.contentCenterX, 0)
    your_score.y = Utils.getTopInScreen() + your_score.contentHeight * 2
    sceneGroup:insert( your_score )

    local fontSize = 60
    scoreTxt = Utils.createText(nil, "0", fontSize, display.contentCenterX, your_score.y + fontSize)
    sceneGroup:insert( scoreTxt )
end
 
 
-- show()
function scene:show( event )
 
    local phase = event.phase
 
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
        scoreTxt.text =  App.getPreferenceScore()
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------
 
return scene