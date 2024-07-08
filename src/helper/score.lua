---@diagnostic disable: deprecated, undefined-global
-- Score lib

local M = {}

-- local/module based variables

function M.new(options)
    -- default options for instance
    options = options or {}
    local label = options.label or ""
    local x,y = options.x or 0, options.y or 0
    local font = options.font or "Assets/PoetsenOne.ttf"
    local size = options.size or 56
    local align = options.align or "center"
    local color = options.color or {1, 1, 1, 1}

    --  create display group to hold visuals

    local score
    local num = options.score or 0
    local textOptions = { x=x, y=y, text=num, font=font, fontSize=size, align=align }

    score = display.newText(textOptions)
    score.num = num
    score.target = num

    score:setFillColor( unpack(color) )

    function score:add(points)
        score.target = self.target + (points or 10)
        local function countUp()
            local diff = math.ceil((score.target - score.num) / 12)
            score.num = score.num + diff
            if score.num > score.target then
                score.num = score.target
                timer.cancel(score.timer)
                score.timer = nil
            end
            score.text = (score.num or 0)
        end
        if not score.timer then
            score.timer = timer.performWithDelay(30, countUp, -1)
        end
    end

    function score:get() return score.target or 0 end

    function score:finalize()
    -- on remove cleanup instance
        if score and score.timer then timer.cancel(score.timer) end
    end

    score:addEventListener('finalize')

    -- return instance
    return score
end

-- return module
return M