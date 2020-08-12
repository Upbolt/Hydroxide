local TweenService = game:GetService("TweenService")

local TabSelector = {}

local Base = import("rbxassetid://5042109928").Base
local Tabs = Base.Tabs.Container
local Pages = Base.Body.Pages

local MessageBox, MessageType = import("ui/controls/MessageBox")

local requiredMethods = {
    ConstantScanner = import("modules/ConstantScanner").RequiredMethods,
    UpvalueScanner = import("modules/UpvalueScanner").RequiredMethods,
    ScriptScanner = import("modules/ScriptScanner").RequiredMethods,
    ModuleScanner = import("modules/ModuleScanner").RequiredMethods,
    ClosureSpy = import("modules/ClosureSpy").RequiredMethods,
    RemoteSpy = import("modules/RemoteSpy").RequiredMethods
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    tabSelected = Color3.fromRGB(45, 45, 45),
    iconSelected = Color3.fromRGB(255, 255, 255),
    tabUnselected = Color3.fromRGB(20, 20, 20),
    iconUnselected = Color3.fromRGB(127, 127, 127)
}

local selectedTab 
local selectedPage = Pages.Home

local function methodsCheck(methods)
    local globalMethods = oh.Methods
    local missingMethods = ""

    for methodName in pairs(methods) do
        if not globalMethods[methodName] then
            missingMethods = missingMethods .. methodName .. ", "
        end
    end

    return (missingMethods ~= "" and missingMethods:sub(1, -3)) or nil
end

local animationCache = {}
local function selectTab(tabName)
    local methodsFound = requiredMethods[tabName]
    local missingMethods = methodsFound and methodsCheck(methodsFound)

    if missingMethods then
        return MessageBox.Show(
            "Your exploit does not support this section",
            "The following functions are missing from your exploit: " .. missingMethods,
            MessageType.OK
        )
    end

    local tab = Tabs:FindFirstChild(tabName)
    local page = Pages:FindFirstChild(tabName)

    if selectedTab then
        local tabAnimation = animationCache[selectedTab]
        tabAnimation.unselected:Play()
        tabAnimation.iconUnselected:Play()
    end

    selectedPage.Visible = false
    page.Visible = true
    tab.ImageColor3 = constants.tabSelected
    tab.Icon.ImageColor3 = constants.iconSelected

    oh.setStatus(page.Name:sub(1, 1) .. page.Name:sub(2):gsub('%u', function(c) return ' ' .. c end))
    
    selectedTab = tab
    selectedPage = page
    return true
end

for _i, tab in pairs(Tabs:GetChildren()) do
    if tab:IsA("ImageButton") then
        local selected = TweenService:Create(tab, constants.fadeLength, { ImageColor3 = constants.tabSelected })
        local unselected = TweenService:Create(tab, constants.fadeLength, { ImageColor3 = constants.tabUnselected })
        local iconSelected = TweenService:Create(tab.Icon, constants.fadeLength, { ImageColor3 = constants.iconSelected })
        local iconUnselected = TweenService:Create(tab.Icon, constants.fadeLength, { ImageColor3 = constants.iconUnselected })

        animationCache[tab] = {
            selected = selected,
            unselected = unselected,
            iconSelected = iconSelected,
            iconUnselected = iconUnselected
        }

        tab.MouseButton1Click:Connect(function()
            if selectedTab ~= tab and Tabs:FindFirstChild(tab.Name) then
                selectTab(tab.Name)
            end
        end)

        tab.MouseEnter:Connect(function()
            if selectedPage ~= Pages:FindFirstChild(tab.Name) then
                selected:Play()
                iconSelected:Play()
            end
        end)

        tab.MouseLeave:Connect(function()
            if selectedPage ~= Pages:FindFirstChild(tab.Name) then
                unselected:Play()
                iconUnselected:Play()
            end
        end)
    end
end

TabSelector.SelectTab = selectTab
return TabSelector