---@diagnostic disable: undefined-global
-- switch.lua
local Utils = require("src.helper.utils")

local M = {} -- Module table

function M.new(params)
    local switchGroup = display.newGroup() -- Create a display group for the switch

    -- Create switch images
    local switchOnImage = Utils.createImage(switchGroup, params.onImage, params.width,  params.height, params.x, params.y)
    local switchOffImage = Utils.createImage(switchGroup, params.offImage, params.width,  params.height, params.x, params.y)
    switchOffImage.isVisible = false -- Initially hide the "on" switch image

    -- Function to toggle the switch state
    function switchGroup:toggle()
        switchOnImage.isVisible = not switchOnImage.isVisible
        switchOffImage.isVisible = not switchOffImage.isVisible
    end

    function switchGroup:getState()
        return switchOnImage.isVisible
    end

    function switchGroup:setState(isOn)
        if self:getState() ~= isOn then
            self:toggle()
        end
    end

    -- Touch event listener for the switch
    local function onTap()
        switchGroup:toggle() -- Toggle the switch state
        if params.onStateChanged then
            params.onStateChanged(switchOnImage.isVisible) -- Call the callback function
        end
    end

    -- Add touch event listener to the switch
    switchOnImage:addEventListener("tap", onTap)
    switchOffImage:addEventListener("tap", onTap)

    return switchGroup
end

return M -- Return the module
