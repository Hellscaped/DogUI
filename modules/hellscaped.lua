-- feel free to use as template

Exports = {
    Speed = {
        Enabled = false,
        keys = {keys.w},
        events = {},
        onKey = function(ni)
            local plr = ni.getMetaOwner()
            ni.launch(plr.yaw, 5, 4)
        end,
        Author = "Hellscaped"
    },
    LaserAura = {
        Enabled = false,
        keys = {},
        events = {"timer"},
        Author = "Hellscaped",
        timer = function(ni,UUID)
            local whitelist = {"minecraft:player","minecraft:sheep"}
            for i, v in pairs(ni.sense()) do
                if  v.id ~= UUID then
                    for _, ent in pairs(whitelist) do
                        if v.key == ent then
                            local d = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
                            local x = v.x
                            local y = v.y-0.25
                            local z = v.z
                            local yaw = -math.deg(math.atan2(x,z))
                            local pitch = -math.deg(math.atan2(y,math.sqrt(x*x+z*z)))
                            ni.fire(yaw, pitch, 5)
                        end
                    end
                end
            end
        end
    }
    
}
return Exports