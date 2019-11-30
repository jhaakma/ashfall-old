
local this = {}

local logLevels = {
    DEBUG = 1,
    INFO = 2,
    ERROR = 3,
    NONE = 4
}

local params = {
    modName = "Ashfall",
    configPath = "ashfall",
    default = "INFO"
}

--[[
    Checks if the current log level is high enough to log the message
]]
local function doLog(logLevel)
    local config =  mwse.loadConfig(params.configPath)
    local currentLogLevel = config.logLevel or params.default
    return logLevels[currentLogLevel] <= logLevels[logLevel]
end

function this.debug(str, ...)
    if doLog("DEBUG") then
        print( "[" .. params.modName .. ": DEBUG]" .. tostring(str):format(...))
    end
end

function this.info(str, ...)
    if doLog("INFO") then
        print( "[" .. params.modName .. ": INFO]" .. tostring(str):format(...))
    end
end

function this.error(str, ...)
    if doLog("ERROR") then
        print( "[" .. params.modName .. ": ERROR]" .. tostring(str):format(...))
        error(tostring(str):format(...))
    end
end

return this