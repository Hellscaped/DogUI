print("DogUI v1.0")
print("By Hellscaped")
local ni = peripheral.find("neuralInterface")
local ctx = ni.canvas()
ctx.clear()

UUID = "983d9c4a-8e17-44be-af7b-f0f162c4ffa6"

print("Preloading UI...")
UI = {
    DogUI = {
        ClassName = "Frame",
        pos = {0, 0},
        pos2 = {65, 25},
        color = 0x00000064
    },
    Title = {
        ClassName = "Text",
        pos = {5, 5},
        Text = "DogUI",
        color = 0xFFFFFFFF,
        Size = 2
    }
}

print("Loading Modules...")
Modules = {}
local rows = 0
local cols = 0
local maxrows = 6
local maxcols = 10
for _,v in pairs(fs.list("modules")) do
    local module = dofile("modules/"..v)
    for i, v in pairs(module) do
        Modules[i] = v
        local color = 0xFF000064
        if v.Enabled then
            color = 0x00FF0064
        end
        UI[i] = {
            ClassName = "Button",
            pos = {10 + (cols * 60), 30 + (rows * 30)},
            pos2 = {50, 20},
            color = color,
            Text = i,
            TextColor = 0xFFFFFFFF,
            TextSize = 1,
            Enabled = module[i].Enabled,
            onClick = function()
                UI[i].Enabled = not UI[i].Enabled
                if UI[i].Enabled then
                    Modules[i].Enabled = true
                    UI[i].color = 0x00FF0064
                else
                    Modules[i].Enabled = false
                    UI[i].color = 0xFF000064
                end
            end
        }
        rows = rows + 1
        if rows >= maxrows then
            rows = 0
            cols = cols + 1
        end
    end
end
for i, v in pairs(Modules) do
    print("Loaded Module: " .. i .. " by " .. v.Author)
end
OpenedClickGui = false
Debounce = false
CloseDebounce = false
Vmouse = {0, 0}
MoveVector = {0, 0}
HeldKeys = {
    [keys.up] = false,
    [keys.down] = false,
    [keys.left] = false,
    [keys.right] = false
}
function EventLoop()
    while true do
        local event, key = os.pullEvent()
        if event == "key" then
            if key == keys.rightShift then
                Debounce = true
                OpenedClickGui = not OpenedClickGui
                Debounce = false
            elseif key == keys.rightCtrl then 
                if OpenedClickGui then
                    for rect in pairs(UI) do
                        if UI[rect].ClassName == "Button" then
                            local pos = UI[rect].pos
                            local size = UI[rect].pos2
                            local endPos = {pos[1] + size[1], pos[2] + size[2]}
                            if Vmouse[1] >= pos[1] and Vmouse[1] <= endPos[1] and Vmouse[2] >= pos[2] and Vmouse[2] <= endPos[2] then
                                local oldColor = UI[rect].color
                                UI[rect].color = 0x00FF0064
                                sleep(0.1)
                                UI[rect].color = oldColor
                                UI[rect]:onClick()
                            end
                        end
                    end
                end
            elseif key == keys.up then
                HeldKeys[key] = true
            elseif key == keys.down then
                HeldKeys[key] = true
            elseif key == keys.left then
                HeldKeys[key] = true
            elseif key == keys.right then
                HeldKeys[key] = true
            end
            for i, v in pairs(Modules) do
                if v.Enabled then
                    for _, keybind in pairs(v.keys) do
                        if key == keybind then
                            v.onKey(ni)
                        end
                    end
                end
            end
        elseif event == "key_up" then
            if key == keys.up then
                HeldKeys[key] = false
            elseif key == keys.down then
                HeldKeys[key] = false
            elseif key == keys.left then
                HeldKeys[key] = false
            elseif key == keys.right then
                HeldKeys[key] = false
            end
        end
        for i, v in pairs(Modules) do
            if v.Enabled then
                for _, eve in pairs(v.events) do
                    if eve == event then
                        v[event](ni,UUID)
                    end
                end
            end
        end
    end 
end

Sensitivity = 2.5
function RenderLoop()
    while true do
        if OpenedClickGui and not Debounce then
            MoveVector = {
                (HeldKeys[keys.right] and 1 or 0) - (HeldKeys[keys.left] and 1 or 0),
                (HeldKeys[keys.up] and 1 or 0) - (HeldKeys[keys.down] and 1 or 0)
            }
            Vmouse = {
                Vmouse[1] + (MoveVector[1] * Sensitivity),
                Vmouse[2] - (MoveVector[2] * Sensitivity)
            }
            ctx.clear()
            for i, v in pairs(UI) do
                if v.ClassName == "Frame" then
                    ctx.addRectangle(v.pos[1], v.pos[2], v.pos2[1], v.pos2[2], v.color)
                elseif v.ClassName == "Text" then
                    ctx.addText(v.pos, v.Text, v.color, v.Size)
                elseif v.ClassName == "Button" then
                    ctx.addRectangle(v.pos[1], v.pos[2], v.pos2[1], v.pos2[2], v.color)
                    local midpoint = {v.pos[1] + (v.pos2[1] / 2) - string.len(v.Text)*3, v.pos[2] + (v.pos2[2] / 2)-4}
                    ctx.addText(midpoint, v.Text, v.TextColor, v.TextSize)
                end
            end
            ctx.addTriangle(
                {Vmouse[1], Vmouse[2]},
                {Vmouse[1] + 7, Vmouse[2] + 7},
                {Vmouse[1], Vmouse[2] + 10},
                0xFFFFFFFF
            )
            ctx.addTriangle(
                {Vmouse[1]+1, Vmouse[2]+1},
                {Vmouse[1] + 6, Vmouse[2] + 7},
                {Vmouse[1]+1, Vmouse[2] + 9},
                0x000000FF
            )
            sleep(0.0001)
        else
            ctx.clear()
            sleep(0.1)
        end
    end                                                 
end

parallel.waitForAny(EventLoop, RenderLoop)