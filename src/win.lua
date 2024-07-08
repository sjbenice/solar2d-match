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
    composer.gotoScene( "src.play", { effect="slideLeft", time=200 } )
end

local function onBtnMenu()
    composer.gotoScene( "src.menu", { effect="slideLeft", time=200 } )
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

    local bgTiger = Utils.createImage( nil, "Assets/tiger.png", display.actualContentWidth * 1.2, nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( bgTiger )

    local gradient = Utils.createImage( nil, "Assets/gradient.png", display.actualContentWidth * 1.2, nil, display.contentCenterX, 0 )
    gradient.y = Utils.getBottomInScreen() - gradient.contentHeight / 2
    sceneGroup:insert( gradient )

    local dlgBg = Utils.createImage( nil, "Assets/rect2.png", display.actualContentWidth * 0.8, nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( dlgBg )

    local your_score = Utils.createImage( nil, "Assets/your_score.png", 120, nil, display.contentCenterX, 0)
    your_score.y = display.contentCenterY - your_score.contentHeight
    sceneGroup:insert( your_score )

    local fontSize = 60
    scoreTxt = Utils.createText(nil, "0", fontSize, display.contentCenterX, display.contentCenterY + fontSize / 2)
    sceneGroup:insert( scoreTxt )

    local btn_2menu = Utils.createImage( nil, "Assets/btn_2menu.png", 50, nil, 0, 0 )
    btn_2menu.x = display.contentCenterX - btn_2menu.contentWidth / 2 - 5
    btn_2menu.y = dlgBg.y + dlgBg.contentHeight / 2
    sceneGroup:insert( btn_2menu )
    btn_2menu:addEventListener("tap", onBtnMenu)

    local btn_restart = Utils.createImage( nil, "Assets/btn_restart.png", btn_2menu.contentWidth, nil, display.contentCenterX + btn_2menu.contentWidth / 2 + 5, btn_2menu.y )
    sceneGroup:insert( btn_restart )
    btn_restart:addEventListener("tap", onBtnPlayGame)
end
 
-- show()
function scene:show( event )
    local phase = event.phase
 
    if ( phase == "will" ) then
        if event.params ~= nil then
            if event.params.score ~= nil then
                scoreTxt.text = event.params.score
                local max = App.getPreferenceScore()
                if max < event.params.score then
                    App.setPreferenceScore(event.params.score)
                end
            end
        end
    elseif ( phase == "did" ) then
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------
 
return scene