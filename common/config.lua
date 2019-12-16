local configPath = "ashfall"
local defaultValues = {
    logLevel = "INFO",
    blocked = {},
    warmthCache = {
        armor = {},
        clothing = {}
    }
}

--Our in-memory cache of the config file
local cache = mwse.loadConfig(configPath)
for key, val in pairs(defaultValues) do
    if cache[key] == nil then
        cache[key] = val
    end
end

local config = {
    save = function()
        mwse.saveConfig(configPath, cache)
    end
}

local meta = {
    __index = function(_, key)
        return cache[key]
    end
}

return setmetatable(config, meta)