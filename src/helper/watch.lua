---@diagnostic disable: deprecated, undefined-global
-- Score lib

local M = {}

-- local/module based variables

function M.new(options)
    -- default options for instance
    options = options or {}
    local x,y = options.x or 0, options.y or 0
    local font = options.font or "Assets/PoetsenOne.ttf"
    local size = options.size or 56
    local align = options.align or "center"
    local color = options.color or {1, 1, 1, 1}

    --  create display group to hold visuals

    local textOptions = { x=x, y=y, text="00:00", font=font, fontSize=size, align=align }

    local watch = display.newText(textOptions)
    watch.seconds = 0
    watch.isStarted = false
    watch.isPaused = false

    watch:setFillColor( unpack(color) )

    function watch:restart(points)
        watch.seconds = 0
        watch.isStarted = true
        watch.isPaused = false
        local function countUp()
            if watch.isStarted and not watch.isPaused then
                watch.seconds = watch.seconds + 1
                local sec = math.floor(watch.seconds) % 60;
                local min = math.floor(watch.seconds / 60) % 60;
                local str = ""
                if min < 10 then
                    str = "0"
                end
                str = str..min..":"
                if sec < 10 then
                    str = str.."0"
                end
                watch.text = str..sec
            end
        end
        if not watch.timer then
            watch.timer = timer.performWithDelay(1000, countUp, -1)
        end
    end

    function watch:get() return watch.seconds or 0 end
    function watch:pause() watch.isPaused = true end
    function watch:resume() watch.isPaused = false end
    function watch:stop() watch.isStarted = false end

    function watch:finalize()
    -- on remove cleanup instance
        if watch and watch.timer then timer.cancel(watch.timer) end
    end

    watch:addEventListener('finalize')

    -- return instance
    return watch
end

-- return module
return M