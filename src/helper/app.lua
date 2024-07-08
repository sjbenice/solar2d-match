local Utils = require("src.helper.utils")
-- Define a module for utility functions
local App = {}

function App.getMaxLevel()
    return 4
end

function App.setPreferenceMusic(isOn)
    Utils.setPreferenceBoolean("music", isOn)
end

function App.setPreferenceEffect(isOn)
    Utils.setPreferenceBoolean("effect", isOn)
end

function App.setPreferenceVibro(isOn)
    Utils.setPreferenceBoolean("vibro", isOn)
end

function App.getPreferenceMusic()
    return Utils.getPreferenceBoolean( "music", true)
end

function App.getPreferenceEffect()
    return Utils.getPreferenceBoolean( "effect", true)
end

function App.getPreferenceScore()
    return Utils.getPreferenceNumber( "score", 0)
end

function App.setPreferenceScore(value)
    Utils.setPreferenceNumber("score", value)
end

function App.getPrimaryTextColor()
    return { 1, 0.76, 0.5 }
end

-- Return the module
return App
