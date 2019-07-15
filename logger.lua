
local this = {}

local modName = "Ashfall"
local configPath = "ashfall/config"

local logLevels = {
    DEBUG = 1,
    INFO = 2,
    ERROR = 3,
    NONE = 4
}

--[[
    Checks if the current log level is high enough to log the message
]]
local function doLog(logLevel)
    local currentLogLevel = mwse.loadConfig(configPath) and mwse.loadConfig(configPath).logLevel or "INFO"
    return logLevels[currentLogLevel] <= logLevels[logLevel]
end

function this.debug(str, ...)
    if doLog("DEBUG") then
        print( modName .. ": DEBUG]" .. tostring(str):format(...))
    end
end

function this.info(str, ...)
    if doLog("INFO") then
        print( modName .. ": INFO]" .. tostring(str):format(...))
    end
end

function this.error(str, ...)
    if doLog("ERROR") then
        print( modName .. ": ERROR]" .. tostring(str):format(...))
    end
end

return this