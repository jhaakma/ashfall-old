local this = {}

local configPath = "ashfall"
local cache
function this.get()
    return cache or mwse.loadConfig(configPath)
end

function this.save(newConfig)
    cache = newConfig
    mwse.saveConfig(configPath, newConfig)
end

function this.getValue(value)
    local config = this.get()
    if config then
        return config[value]
    else
        return nil
    end
end

function this.saveValue(key, val)
    local config = this.get()
    if config then
        config[key] = val
        mwse.saveConfig(configPath, config)
    end
end