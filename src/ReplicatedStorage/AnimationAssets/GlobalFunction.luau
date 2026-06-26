local TS = game:GetService('TweenService')
local RS = game:GetService('ReplicatedStorage')

local sounds = RS:WaitForChild('AnimationAssets'):WaitForChild('Sounds')
    
local abbreviations = {
    "K", -- 4 digits
    "M", -- 7 digits
    "B", -- 10 digits
    "T", -- 13 digits
    "QD", -- 16 digits
    "QT", -- 19 digits
    "SXT", -- 22 digits
    "SEPT", -- 25 digits
    "OCT", -- 28 digits
    "NON", -- 31 digits
    "DEC", -- 34 digits
    "UDEC", -- 37 digits
    "DDEC", -- 40 digits
}

local module = {}

function module.abreviatenumber(x,decimals)
    local formatted = x
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

function module.add_animations(obj,uiscale)
    obj.MouseEnter:Connect(function()
        if not obj:GetAttribute('Clicked') then
            TS:Create(uiscale,TweenInfo.new(0.2),{Scale = 1.03}):Play()
        end
    end)
    obj.MouseLeave:Connect(function()
        if not obj:GetAttribute('Clicked') then
            TS:Create(uiscale,TweenInfo.new(0.2),{Scale = 1}):Play()
        end
    end)
    obj:GetAttributeChangedSignal('Clicked'):Connect(function()
        if obj:GetAttribute('Clicked') then
            sounds.ui_click:Play()
            TS:Create(uiscale,TweenInfo.new(0.1),{Scale = 0.8}):Play()
            task.wait(0.1)
            TS:Create(uiscale,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Scale = 1}):Play()
        end
    end)
end

function module.check_enum(enumtype,enumname)
    local success,data = pcall(function()
        return Enum[enumtype][enumname]
    end)
    if success then
        return true
    end
end

function module.combine_Dictionaries(dictionary1,dictionary2)
    for i, v in pairs(dictionary2) do
        dictionary1[i] = v
    end
    return dictionary1
end

return module
