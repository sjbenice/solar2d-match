---@diagnostic disable: undefined-global, deprecated
local composer = require( "composer" )
local Utils = require("src.helper.utils")
local App = require("src.helper.app")
local scoring = require ("src.helper.score")
local watcher = require ("src.helper.watch")
local Item = require ("src.helper.item")

local scene = composer.newScene()

local musicSound
local effectSound
local soundEffect
local backgroundMusicChannel = nil
local isStarted = false
local boardGroup = nil
local gap = 30
local rows
local cols = 6
local score
local watch

local boardLeft
local boardRight
local boardTop
local boardBottom

local itemSize
local cells = nil
local MAX_ITEM = 7
local processTimer = nil

local INVALID_TYPE = 0
local MATCH_COUNT = 3
local DIR_RIGHT = 1
local DIR_BOTTOM = 2
local DIR_RIGHT_TOP = 3
local DIR_RIGHT_BOT = 4

local function onBtnMenu()
    if processTimer == nil then
        composer.gotoScene( "src.menu", { effect="slideLeft", time=200 } )
    end
end

local function onBtnSettings(event)
    if processTimer == nil then
        composer.gotoScene( "src.settings", { effect="fromRight", time=200 } )
    end
end

local function onShowScore(score)
    watch:stop()

    local parameter = {}
    parameter["score"] = score:get()

    composer.gotoScene( "src.win", { effect="fromRight", time=200, params = parameter } )
end

local function local2Item(x, y)
    local i = math.floor((x - boardLeft) / itemSize) + 1
    local j = math.floor((y - boardTop) / itemSize) + 1
    if i <= 0 or i > cols then
        i = 0
    end
    if j <= 0 or j > rows then
        j = 0
    end
    return i, j
end

local function item2Local(x, y)
    local posX = boardLeft + itemSize * (x - 0.5)
    local posY = boardTop + itemSize * (y - 0.5)

    return posX, posY
end

local function removeCell(x, y)
    if cells ~= nil then
        local cell = cells[y][x];
        if cell ~= nil then
            cell:removeSelf()
            cells[y][x] = nil
        end
    end
end

local function addCell(cells, x, y)
    if cells ~= nil then
        local cell = cells[y][x];
        if cell == nil then
            local pos_x, pos_y = item2Local(x, y)
            cell = Item.new(boardGroup, math.random(MAX_ITEM), itemSize * 0.8, pos_x, pos_y)
        else
            print("ERROR: cell is already created in "..x..","..y..","..type)
        end

        return cell
    end
    return nil
end

local function createTable(rows, cols)
    local tbl = {}
    for y = 1, rows do
        tbl[y] = {}
        for x = 1, cols do
            tbl[y][x] = addCell(tbl, x, y) -- initialize each element with zero
        end
    end
    return tbl
end

local function findClusters()
    if cells == nil then
        return nil
    end
    local clusters = {}
    for j = 1, rows do
        local matchLength = 1
        for i = 1, cols do
            local checkClusters = false
            if i == cols then
                checkClusters = true
            else
                if cells[j][i] ~= nil and cells[j][i].type > INVALID_TYPE and cells[j][i + 1] ~= nil and cells[j][i].type == cells[j][i + 1].type then
                    matchLength = matchLength + 1
                else
                    checkClusters = true
                end
            end

            if checkClusters then
                if matchLength >= MATCH_COUNT then
                    clusters[#clusters + 1] = { column=i + 1 - matchLength, row=j, length=matchLength, direction=DIR_RIGHT }
                end
                matchLength = 1
            end
        end
    end

    for i = 1, cols do
        local matchLength = 1
        for j = 1, rows do
            local checkClusters = false
            if j == rows then
                checkClusters = true
            else
                if cells[j][i] ~= nil and cells[j][i].type > INVALID_TYPE and cells[j + 1][i] ~= nil and cells[j][i].type == cells[j + 1][i].type then
                    matchLength = matchLength + 1
                else
                    checkClusters = true
                end
            end
            if checkClusters then
                if matchLength >= MATCH_COUNT then
                    clusters[#clusters + 1] = { column=i, row=j + 1 - matchLength, length=matchLength, direction=DIR_BOTTOM }
                end
                matchLength = 1
            end
        end
    end

    for i = 1, cols - MATCH_COUNT + 1 do
        local matchLength = 0
        for j = 1, rows - MATCH_COUNT + 1 do
            if cells[j][i] ~= nil and cells[j][i].type > INVALID_TYPE then
                matchLength = 1
                local pos = 1
                while true do
                    if i + pos <= cols and j + pos <= rows then
                        if cells[j + pos][i + pos] ~= nil and cells[j][i].type == cells[j + pos][i + pos].type then
                            matchLength = matchLength + 1
                            pos = pos + 1
                        else
                            break
                        end
                    else
                        break
                    end
                end
                if matchLength >= MATCH_COUNT then
                    clusters[#clusters + 1] = { column=i, row=j, length=matchLength, direction=DIR_RIGHT_BOT }
                end
            end
        end

        for j = rows, MATCH_COUNT, -1 do
            if cells[j][i] ~= nil and cells[j][i].type > INVALID_TYPE then
                matchLength = 1
                local pos = 1
                while true do
                    if i + pos <= cols and j - pos > 0 then
                        if cells[j - pos][i + pos] ~= nil and cells[j][i].type == cells[j - pos][i + pos].type then
                            matchLength = matchLength + 1
                            pos = pos + 1
                        else
                            break
                        end
                    else
                        break;
                    end
                end
                if matchLength >= MATCH_COUNT then
                    clusters[#clusters + 1] = { column=i, row=j, length=matchLength, direction=DIR_RIGHT_TOP }
                end
            end
        end
    end

    return clusters
end

local function createExplosionEffect(x, y)
    local dx = 20
    local p = "Assets/icon_coin.png"
    local emitterParams = {
            startParticleSizeVariance = dx/2,
            startColorAlpha = 0.61,
            startColorGreen = 0.3031555,
            startColorRed = 0.08373094,
            yCoordFlipped = 0,
            blendFuncSource = 770,
            blendFuncDestination = 1,
            rotatePerSecondVariance = 0,
            particleLifespan = 0.7237,
            tangentialAcceleration = -144.74,
            startParticleSize = dx,
            textureFileName = p,
            startColorVarianceAlpha = 1,
            maxParticles = 40,
            finishParticleSize = dx/3,
            duration = 0.3,
            finishColorRed = 0.078,
            finishColorAlpha = 0.75,
            finishColorBlue = 0.3699196,
            finishColorGreen = 0.5443883,
            maxRadiusVariance = 0,
            finishParticleSizeVariance = dx/2,
            gravityy = 0,
            speedVariance = 100,
            tangentialAccelVariance = 0,
            angleVariance = 0,
            angle = 0
        }
    if boardGroup ~= nil then
        local emitter = display.newEmitter(emitterParams )
        emitter.x = x
        emitter.y = y
        emitter:start()
        boardGroup:insert(emitter)
        local function removeAuto()
            emitter:removeSelf()
        end
        timer.performWithDelay(300, removeAuto)
    end
end
  
local function deleteClusters(clusters)
    if cells == nil then
        return
    end

    local price = 0
    for i = 1, #clusters do
        local cluster = clusters[i]
        price = price + cluster.length * 10

        local coffset = 0
        local roffset = 0
        for j = 1, cluster.length do
            local x = cluster.column + coffset
            local y = cluster.row + roffset
            
            local cell = cells[y][x]
            if cell ~= nil then
                createExplosionEffect(cell.x, cell.y)
                -- cell:explode()
                cell:removeSelf()
                cells[y][x] = nil
            end

            if cluster.direction == DIR_RIGHT then
                coffset = coffset + 1
            elseif cluster.direction == DIR_BOTTOM then
                roffset = roffset + 1
            elseif cluster.direction == DIR_RIGHT_BOT then
                coffset = coffset + 1
                roffset = roffset + 1
            else
                coffset = coffset + 1
                roffset = roffset - 1
            end
        end
    end

    if price > 0 then
        if effectSound ~= nil and soundEffect then
            audio.play(effectSound)
        end
        score:add(price)
    end
end

local function dropCells()
    if cells == nil then
        return
    end

    for i = 1, cols do
        local drops = 0
        for j = rows, 1, -1 do
            local cell = cells[j][i]
            if cell == nil then
                drops = drops + 1
            elseif drops > 0 then
                local x, y = item2Local(i, j + drops)
                cell:moveTo(x, y)
                cells[j][i] = nil
                cells[j + drops][i] = cell
            end
        end
    end

    for i = 1, cols do
        for j = 1, rows do
            if cells[j][i] == nil then
                cells[j][i] = addCell(cells, i, j)
            end
        end
    end
end

local function swapCells(startX, startY, endX, endY, isTest)
    if cells ~= nil then
        local cell1 = cells[startY][startX]
        local cell2 = cells[endY][endX]
        if not isTest then
            cell1:moveTo(cell2.x, cell2.y, 200)
            cell2:moveTo(cell1.x, cell1.y, 200)
        end
        cells[startY][startX] = cell2
        cells[endY][endX] = cell1
    end
end

local function processBoard()
    if isStarted then
        local function processOne()
            local clusters = findClusters()
            if #clusters <= 0 and processTimer ~= nil then
                timer.cancel(processTimer)
                processTimer = nil
                return
            end
            deleteClusters(clusters)

            dropCells()
        end
        processTimer = timer.performWithDelay(500, processOne, -1)
    end
end

local function onBtnRestart()
    if boardGroup ~= nil then
        boardGroup:removeSelf()
        boardGroup = nil
    end
    score:add(-score:get())
    watch:restart()

    boardGroup = display.newGroup()
    scene.view:insert(boardGroup)

    cells = createTable(rows, cols)

    isStarted = true

    processBoard()
end

local function onTouch( event )
    if processTimer ~= nil or not isStarted or cells == nil then
        return
    end

    if event.phase == "began" then
    elseif event.phase == "ended" then
        local dx, dy = event.x - event.xStart, event.y - event.yStart
        local startX, startY = local2Item(event.xStart, event.yStart)
        local endX, endY = 0, 0
        if startX > 0 and startY > 0 then
            if math.abs(dx) >= itemSize then
                if dx > 0 then
                    endX = startX + 1
                else
                    endX = startX - 1
                end
                endY = startY
            elseif math.abs(dy) >= itemSize then
                endX = startX
                if dy > 0 then
                    endY = startY + 1
                else
                    endY = startY - 1
                end
            end
            if endX > 0 and endX <= cols and endY > 0 and endY <= rows then
                swapCells(startX, startY, endX, endY, true)
                local clusters = findClusters()
                swapCells(startX, startY, endX, endY, true)
                if #clusters > 0 then
                    swapCells(startX, startY, endX, endY, false)
                    processBoard()
                end
            end
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
    musicSound = audio.loadSound( "Assets/music.wav" )
    effectSound = audio.loadSound( "Assets/effect.wav" )

    local sceneGroup = self.view
 
    local bg = display.newImageRect("Assets/back1.png", display.actualContentWidth, display.actualContentHeight)
    bg.x = display.contentCenterX 
    bg.y = display.contentCenterY
    sceneGroup:insert( bg )

    local btn_2menu = Utils.createImage( nil, "Assets/btn_2menu.png", 50, nil, 0, 0 )
    btn_2menu.x = Utils.getLeftInScreen() + btn_2menu.contentWidth
    btn_2menu.y = Utils.getTopInScreen() + btn_2menu.contentHeight
    sceneGroup:insert( btn_2menu )
    btn_2menu:addEventListener("tap", onBtnMenu)

    local btn_settings = Utils.createImage( nil, "Assets/btn_setting.png", 50, nil, Utils.getRightInScreen() - btn_2menu.contentWidth, btn_2menu.y )
    sceneGroup:insert( btn_settings )
    btn_settings:addEventListener("tap", onBtnSettings)

    local btn_tryagain = Utils.createImage( nil, "Assets/btn_tryagain.png", Utils.getPrimaryButtonWidth(), nil, display.contentCenterX, 0 )
    btn_tryagain.y = Utils.getBottomInScreen() - btn_tryagain.contentHeight
    sceneGroup:insert( btn_tryagain )
    btn_tryagain:addEventListener("tap", onBtnRestart)

    local fontSize = 20
    local bgTimer = Utils.createImage( nil, "Assets/rect.png", fontSize * 6, nil, display.contentCenterX, 0 )
    bgTimer.y = btn_tryagain.y - btn_tryagain.contentHeight / 2 - bgTimer.contentHeight / 2 - fontSize
    sceneGroup:insert( bgTimer )

    watch = watcher.new({size=bgTimer.contentHeight * 0.6, x=bgTimer.x, y = bgTimer.y})
    sceneGroup:insert( watch )

    local boardGap = btn_2menu.contentWidth / 2
    boardLeft = Utils.getLeftInScreen() + boardGap
    boardRight = Utils.getRightInScreen() - boardGap
    boardBottom = bgTimer.y - bgTimer.contentHeight / 2 - boardGap
    boardTop = btn_2menu.y + boardGap * 2

    itemSize = (boardRight - boardLeft) / cols
    rows = math.floor((boardBottom - boardTop) / itemSize)
    boardTop = boardBottom - itemSize * rows

    local boardBg = display.newRoundedRect( (boardRight + boardLeft) /2, (boardBottom + boardTop) / 2, (boardRight - boardLeft), (boardBottom - boardTop), itemSize / 2 )
    boardBg.strokeWidth = 6
    boardBg:setFillColor( { type="gradient", color1={0.98,0.984,0.455}, color2={0.988,0.74,0.294}, direction="down" } )
    boardBg:setStrokeColor( 0.364, 0.004, 0.016 )
    sceneGroup:insert( boardBg )

    local bgScore = Utils.createImage( nil, "Assets/btn.png", boardBg.contentWidth / 2, nil, boardBg.x, 0  )
    bgScore.y = boardBg.y - boardBg.contentHeight / 2 - bgScore.contentHeight * 0.3
    sceneGroup:insert( bgScore )

    score = scoring.new({size=bgScore.contentHeight * 0.7, x=bgScore.x, y=bgScore.y})
    sceneGroup:insert( score )

    bg:addEventListener( "touch", onTouch )
end

-- show()
function scene:show( event )
 
    local phase = event.phase
 
    if ( phase == "will" ) then
        if not isStarted then
            onBtnRestart()
        end
        soundEffect = App.getPreferenceEffect()
    elseif ( phase == "did" ) then
        if App.getPreferenceMusic() then
            backgroundMusicChannel = audio.play( musicSound, { loops=-1 } )
        end
        watch:resume()
    end
end

-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        local max = App.getPreferenceScore()
        if max < score:get() then
            App.setPreferenceScore(score:get())
        end
        -- Code here runs when the scene is on screen (but is about to go off screen)
        if backgroundMusicChannel ~= nil then
            audio.stop(backgroundMusicChannel)
            backgroundMusicChannel = nil
        end
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        watch:pause()
    end
end

-- destroy()
function scene:destroy( event )
    if processTimer ~= nil then
        timer.cancel(processTimer)
        processTimer = nil
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene