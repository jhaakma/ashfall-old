local this = {}
this.faders = {}

local function faderSetup()
    this.faders.freezing = tes3fader.new()
    this.faders.freezing:setTexture("Textures/survival/faders/freeze_static.dds")
    this.faders.freezing:setColor({ color = { 0.5, 0.5, 0.5 }, flag = false })

    for _, fader in pairs( this.faders ) do
        event.register("enterFrame", 
            function()
                fader:update()
            end
        )
    end
end

function this.fadeOut(fader)
    fader:fadeOut({ duration = 1.5 })
end

function this.fadeIn(fader)
    fader:fadeTo({ value = 0.5, duration = 1.5 })
end


event.register("fadersCreated", faderSetup)

return this