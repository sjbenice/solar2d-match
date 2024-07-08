---@diagnostic disable: undefined-global
-- Define a module for utility functions
local Utils = {}

local categoryName = "app"

function Utils.createText(parentGroup, content, size, posX, posY)
    local txt = {
        parent = parentGroup,
        x=posX, y=posY,
        text=content,
        font="Assets/PoetsenOne.ttf",
        fontSize=size }
    local item = display.newText(txt)
    item:setFillColor( 1, 1, 1 )
    return item
end

function Utils.createImage(parent, imageName, width, height, x, y)
    local image
    if width ~= nil and height ~= nil then
        if parent ~= nil then
            image = display.newImage(parent, imageName, width, height)
        else
            image = display.newImage(imageName, width, height)
        end
    else
        local scaleFactor
        if parent ~= nil then
            image = display.newImage(parent, imageName)
        else
            image = display.newImage(imageName)
        end
        if width ~= nil then
            scaleFactor = width / image.width
        end
        if height ~= nil then
            scaleFactor = height / image.height
        end
        image:scale(scaleFactor, scaleFactor)
    end
    
    -- Center the image on the screen
    image.x = x
    image.y = y

    return image
end

function Utils.createButtonTouchHandler(event)
    return function(event)
        local button = event.target -- Get the button object

        if event.phase == "began" then
            -- Scale up the button when touched
            button:scale(1.05, 1.05)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            -- Scale down the button when touch released
            button:scale(1 / 1.05, 1 / 1.05)
            -- If touch ends outside the button, reset scale
            if event.phase == "cancelled" then
                button:scale(1, 1)
            else
                -- Trigger tap event with parameter
                button.onTap(event)
            end
        end
    
        return true -- Return true to prevent touch propagation to underlying objects
    end
end

function Utils.getTopInScreen()
    return - (display.actualContentHeight - display.contentHeight) / 2
end

function Utils.getBottomInScreen()
    return display.contentHeight + (display.actualContentHeight - display.contentHeight) / 2
end

function Utils.getLeftInScreen()
    return - (display.actualContentWidth - display.contentWidth) / 2
end

function Utils.getRightInScreen()
    return display.contentWidth + (display.actualContentWidth - display.contentWidth) / 2
end

function Utils.getPrimaryButtonWidth()
    return 200
end

function Utils.setPreferenceBoolean(key, value)
    local save = 0
    if value then
        save = 1
    end
    Utils.setPreferenceNumber(key, save)
end

function Utils.getPreferenceBoolean(key, default)
---@diagnostic disable-next-line: undefined-global
    local value = system.getPreference( categoryName, key, "number")
    if value == nil then
        return default
    end

    return value == 1
end

function Utils.setPreferenceNumber(key, value)
    local appPreferences = {}
    appPreferences[key] = value

    system.setPreferences( categoryName, appPreferences )
end

function Utils.getPreferenceNumber(key, default)
    local value = system.getPreference( categoryName, key, "number")
    if value == nil then
        return default
    end

    return value
end

function Utils.copyTable(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

-- Return the module
return Utils
