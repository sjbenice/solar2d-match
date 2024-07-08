---@diagnostic disable: deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local switch = require("src.helper.switch")
local App = require("src.helper.app")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local musicSwitch, effectSwitch

local function onBtnBack()
    composer.gotoScene( "src.play", { effect="slideRight", time=200 } )
end

local function onBtnSave()
    App.setPreferenceMusic(musicSwitch:getState())
    App.setPreferenceEffect(effectSwitch:getState())

    onBtnBack()
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

    local dlg = Utils.createImage( nil, "Assets/rect5.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, display.contentCenterY )
    sceneGroup:insert( dlg )

    local caption = Utils.createImage( nil, "Assets/options.png", display.actualContentWidth * 0.5, nil, display.contentCenterX, display.contentCenterY - dlg.contentHeight / 2 - 40 )
    -- local caption = Utils.createText(nil, "SETTINGS", 35, display.contentCenterX, display.contentCenterY - dlg.contentHeight / 2 - 40)
    sceneGroup:insert( caption )

    local fontSize = 25
    local music = Utils.createText(nil, "MUSIC", fontSize, display.contentCenterX, display.contentCenterY - fontSize)
    sceneGroup:insert( music )

    musicSwitch = switch.new({
        width = nil,
        height = fontSize,
        x = display.contentCenterX,
        y = music.y - fontSize * 1.5,
        onImage = "Assets/music_on.png",
        offImage = "Assets/music_off.png",
    })
    sceneGroup:insert( musicSwitch )

    effectSwitch = switch.new({
        width = nil,
        height = fontSize,
        x = display.contentCenterX,
        y = display.contentCenterY + fontSize,
        onImage = "Assets/effect_on.png",
        offImage = "Assets/effect_off.png",
    })
    sceneGroup:insert( effectSwitch )

    local effect = Utils.createText(nil, "EFFECT", fontSize, display.contentCenterX, display.contentCenterY + fontSize * 2.5)
    sceneGroup:insert( effect )

    local btn_save = Utils.createImage( nil, "Assets/btn_save.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_save.y = Utils.getBottomInScreen() - btn_save.contentHeight
    sceneGroup:insert( btn_save )

    btn_save:addEventListener("tap", onBtnSave)
end

-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Read the preferences that were written to storage above
        musicSwitch:setState(App.getPreferenceMusic())
        effectSwitch:setState(App.getPreferenceEffect())
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