---@diagnostic disable: undefined-global
local Utils = require("src.helper.utils")
local M = {}

function M.new(parent, type, size, x, y)
    local item = display.newImageRect(parent, "Assets/"..type..".png", size, size)
    item.x = x
    item.y = y
    item.type = type

    transition.from( item, { time = math.random(300, 500), xScale = 0.01, yScale = 0.01, y = Utils.getTopInScreen(), transition=easing.outBounce } )

    function item:explode()
        transition.cancel(self)

        local function destroy()
            item:removeSelf()
        end

        transition.to(self, { time = 500, yScale = 1.5, xScale = 1.5, alpha = 0, transition = easing.outQuad, 
            onComplete = destroy }
            )
    end

    function item:finalize()
        transition.cancel(self)
    end

    function item:moveTo(x, y, duration)
        local time = duration or 300
        transition.cancel(self)
        transition.to(self, { time = math.random(time, time * 1.5), x = x, y = y, transition = easing.outQuad})
    end

    item:addEventListener("finalize")

    return item
end

return M