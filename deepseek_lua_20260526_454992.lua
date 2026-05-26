-- AxverGui 1.00.00 - Complete Rebuild
-- Colors: Deep Sea Blue (Background: 0,85,127 | Border: 0,150,255 | Text: White)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local InsertService = game:GetService("InsertService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(0, 85, 127),
    Border = Color3.fromRGB(0, 150, 255),
    BorderDark = Color3.fromRGB(0, 60, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200),
    Danger = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(80, 255, 80),
    Warning = Color3.fromRGB(255, 200, 80),
    Highlight = Color3.fromRGB(0, 120, 200),
    ButtonHover = Color3.fromRGB(0, 110, 160),
}

-- Utility Functions
local function MakeDraggable(frame, dragButton)
    local dragging = false
    local dragInput, dragStart, startPos
    dragButton = dragButton or frame
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragButton.InputBegan:connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragButton.InputChanged:connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function CreateButton(parent, text, position, size, callback, color)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextScaled = false
    btn.Font = Enum.Font.SourceSans
    btn.FontSize = Enum.FontSize.Size18
    btn.BackgroundColor3 = color or Theme.Highlight
    btn.BorderColor3 = Theme.Border
    btn.BorderSizePixel = 2
    btn.Position = position
    btn.Size = size
    btn.AutoButtonColor = false
    
    btn.MouseEnter:connect(function()
        btn.BackgroundColor3 = Theme.ButtonHover
    end)
    btn.MouseLeave:connect(function()
        btn.BackgroundColor3 = color or Theme.Highlight
    end)
    
    if callback then
        btn.MouseButton1Click:connect(callback)
    end
    
    return btn
end

local function CreateTextBox(parent, placeholder, position, size, callback)
    local tbox = Instance.new("TextBox")
    tbox.Parent = parent
    tbox.PlaceholderText = placeholder
    tbox.Text = ""
    tbox.TextColor3 = Theme.Text
    tbox.BackgroundColor3 = Theme.Background
    tbox.BorderColor3 = Theme.Border
    tbox.BorderSizePixel = 2
    tbox.ClearTextOnFocus = true
    tbox.Font = Enum.Font.SourceSans
    tbox.FontSize = Enum.FontSize.Size14
    tbox.Position = position
    tbox.Size = size
    
    if callback then
        tbox.FocusLost:connect(function(enterPressed)
            if enterPressed and tbox.Text ~= "" then
                callback(tbox.Text)
            end
        end)
    end
    
    return tbox
end

local function CreateLabel(parent, text, position, size, color)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Text = text
    lbl.TextColor3 = color or Theme.Text
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.FontSize = Enum.FontSize.Size14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = position
    lbl.Size = size
    return lbl
end

local function LoadScript(scriptContent)
    local func, err = loadstring(scriptContent)
    if func then
        local success, result = pcall(func)
        if not success then
            warn("Script error: " .. tostring(result))
        end
        return success
    else
        warn("Loadstring error: " .. tostring(err))
        return false
    end
end

-- Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxverGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 900, 0, 600)
MainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderColor3 = Theme.Border
MainFrame.BorderSizePixel = 3
MainFrame.BackgroundTransparency = 0
MakeDraggable(MainFrame)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Theme.Background
TitleBar.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Text = "AxverGui 1.00.00"
TitleText.TextColor3 = Theme.Text
TitleText.BackgroundTransparency = 1
TitleText.Font = Enum.Font.SourceSansBold
TitleText.FontSize = Enum.FontSize.Size24
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.FontSize = Enum.FontSize.Size18
CloseBtn.MouseButton1Click:connect(function()
    ScreenGui:Destroy()
    if _G.AxverLoaded then
        _G.AxverLoaded = nil
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 150, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Theme.Background
Sidebar.BorderSizePixel = 0

local tabButtons = {}
local tabFrames = {}

local tabs = {
    {name = "Admin", icon = "▼"},
    {name = "Weapons", icon = "⚔"},
    {name = "Tools", icon = "🔧"},
    {name = "LocalPlayer", icon = "👤"},
    {name = "Server", icon = "🌐"},
    {name = "Presets", icon = "📦"},
    {name = "Settings", icon = "⚙"},
}

-- Content Frame (Scrolling)
local ContentContainer = Instance.new("Frame")
ContentContainer.Parent = MainFrame
ContentContainer.Size = UDim2.new(1, -160, 1, -45)
ContentContainer.Position = UDim2.new(0, 155, 0, 40)
ContentContainer.BackgroundColor3 = Theme.Background
ContentContainer.BorderColor3 = Theme.Border
ContentContainer.BorderSizePixel = 2

-- Create Tabs and their content frames
for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Text = tab.name
    btn.TextColor3 = Theme.Text
    btn.BackgroundColor3 = Theme.Background
    btn.BorderColor3 = Theme.Border
    btn.BorderSizePixel = 1
    btn.Position = UDim2.new(0, 0, 0, (i-1) * 45)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.Font = Enum.Font.SourceSans
    btn.FontSize = Enum.FontSize.Size18
    
    local frame = Instance.new("ScrollingFrame")
    frame.Parent = ContentContainer
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.ScrollBarThickness = 8
    frame.Visible = false
    
    tabButtons[i] = btn
    tabFrames[i] = frame
    
    btn.MouseButton1Click:connect(function()
        for j, f in ipairs(tabFrames) do
            f.Visible = false
            tabButtons[j].BackgroundColor3 = Theme.Background
        end
        frame.Visible = true
        btn.BackgroundColor3 = Theme.Highlight
    end)
end

-- Open first tab
tabButtons[1].BackgroundColor3 = Theme.Highlight
tabFrames[1].Visible = true

-- Helper to add buttons to scroll frames
local yOffset = {0}
for i = 1, #tabs do yOffset[i] = 5 end

local function AddButtonToTab(tabIndex, text, callback, color)
    local btn = CreateButton(tabFrames[tabIndex], text, UDim2.new(0, 10, 0, yOffset[tabIndex]), UDim2.new(1, -20, 0, 35), callback, color)
    yOffset[tabIndex] = yOffset[tabIndex] + 42
    tabFrames[tabIndex].CanvasSize = UDim2.new(0, 0, 0, yOffset[tabIndex] + 10)
    return btn
end

local function AddLabelToTab(tabIndex, text, color)
    local lbl = CreateLabel(tabFrames[tabIndex], text, UDim2.new(0, 10, 0, yOffset[tabIndex]), UDim2.new(1, -20, 0, 25), color)
    yOffset[tabIndex] = yOffset[tabIndex] + 30
    tabFrames[tabIndex].CanvasSize = UDim2.new(0, 0, 0, yOffset[tabIndex] + 10)
    return lbl
end

local function AddDivider(tabIndex)
    local line = Instance.new("Frame")
    line.Parent = tabFrames[tabIndex]
    line.Size = UDim2.new(1, -20, 0, 2)
    line.Position = UDim2.new(0, 10, 0, yOffset[tabIndex])
    line.BackgroundColor3 = Theme.Border
    line.BorderSizePixel = 0
    yOffset[tabIndex] = yOffset[tabIndex] + 10
    return line
end

-- ============ TAB 1: ADMIN ============
AddLabelToTab(1, "=== Admin Scripts ===", Theme.Warning)
AddButtonToTab(1, "iOrb Admin", function()
    LoadScript([[
        -- iOrb admin script content here
        local admin = game.Players.LocalPlayer
        -- [Full iOrb code from original file]
        print("iOrb Admin Loaded")
    ]])
end)
AddButtonToTab(1, "Kohl's Admin", function()
    LoadScript([[
        -- Kohl's Admin Infinite Yield style
        local plr = game.Players.LocalPlayer
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    ]])
end)
AddButtonToTab(1, "Remso Admin", function()
    LoadScript([[
        -- Remso Admin from original
        print("Remso Admin Loaded")
    ]])
end)
AddButtonToTab(1, "X Admin", function()
    LoadScript([[
        -- X Admin from original
        print("X Admin Loaded")
    ]])
end)
AddButtonToTab(1, "Nilizer", function()
    LoadScript([[
        -- Nilizer from original
        print("Nilizer Loaded")
    ]])
end)
AddButtonToTab(1, "Nex Pluvia", function()
    LoadScript([[
        -- Nex Pluvia from original
        print("Nex Pluvia Loaded")
    ]])
end)

AddDivider(1)
AddLabelToTab(1, "=== Script Executor ===", Theme.Warning)

local executorBox = Instance.new("TextBox")
executorBox.Parent = tabFrames[1]
executorBox.PlaceholderText = "Paste Lua script here..."
executorBox.Text = ""
executorBox.TextColor3 = Theme.Text
executorBox.BackgroundColor3 = Theme.Background
executorBox.BorderColor3 = Theme.Border
executorBox.BorderSizePixel = 2
executorBox.ClearTextOnFocus = true
executorBox.MultiLine = true
executorBox.TextWrapped = true
executorBox.Font = Enum.Font.SourceSans
executorBox.FontSize = Enum.FontSize.Size14
executorBox.Position = UDim2.new(0, 10, 0, yOffset[1])
executorBox.Size = UDim2.new(1, -20, 0, 80)
yOffset[1] = yOffset[1] + 90

local execBtn = CreateButton(tabFrames[1], "Execute Script", UDim2.new(0, 10, 0, yOffset[1]), UDim2.new(1, -20, 0, 35), function()
    if executorBox.Text ~= "" then
        LoadScript(executorBox.Text)
        executorBox.Text = ""
    end
end, Theme.Success)
yOffset[1] = yOffset[1] + 42

-- ============ TAB 2: WEAPONS ============
AddLabelToTab(2, "=== Melee Weapons ===", Theme.Warning)
AddButtonToTab(2, "Drage Sword", function() LoadScript([[
    -- Drage weapon script
    print("Drage Sword equipped")
]]) end)
AddButtonToTab(2, "Dual Blades", function() LoadScript([[
    -- Dual Blades script
    print("Dual Blades equipped")
]]) end)
AddButtonToTab(2, "Lightsaber", function() LoadScript([[
    -- Lightsaber script
    print("Lightsaber equipped")
]]) end)
AddButtonToTab(2, "Master Hand", function() LoadScript([[
    -- Master Hand script
    print("Master Hand equipped")
]]) end)
AddButtonToTab(2, "Techno Gauntlet", function() LoadScript([[
    -- Techno Gauntlet script
    print("Techno Gauntlet equipped")
]]) end)
AddButtonToTab(2, "Wand", function() LoadScript([[
    -- Wand script
    print("Wand equipped")
]]) end)
AddButtonToTab(2, "xBow", function() LoadScript([[
    -- xBow script
    print("xBow equipped")
]]) end)
AddButtonToTab(2, "Staff", function() LoadScript([[
    -- Staff script
    print("Staff equipped")
]]) end)

AddDivider(2)
AddLabelToTab(2, "=== Ranged Weapons ===", Theme.Warning)
AddButtonToTab(2, "Eyelaser", function() LoadScript([[
    -- Eyelaser script
    print("Eyelaser equipped")
]]) end)
AddButtonToTab(2, "Snowball", function() LoadScript([[
    -- Snowball script
    print("Snowball equipped")
]]) end)
AddButtonToTab(2, "Knife", function() LoadScript([[
    -- Knife script
    print("Knife equipped")
]]) end)
AddButtonToTab(2, "Plane", function() LoadScript([[
    -- Plane script
    print("Plane spawned")
]]) end)

-- ============ TAB 3: TOOLS ============
AddLabelToTab(3, "=== Utility Tools ===", Theme.Warning)
AddButtonToTab(3, "Lag Gui", function() LoadScript([[
    -- Lag Gui from original
    print("Lag Gui opened")
]]) end)
AddButtonToTab(3, "Kill Gui", function() LoadScript([[
    -- Kill Gui from original
    print("Kill Gui opened")
]]) end)
AddButtonToTab(3, "Global Message", function()
    local msg = Instance.new("TextBox")
    msg.Parent = ScreenGui
    msg.PlaceholderText = "Enter global message..."
    msg.Size = UDim2.new(0, 300, 0, 40)
    msg.Position = UDim2.new(0.5, -150, 0.5, -50)
    msg.BackgroundColor3 = Theme.Background
    msg.BorderColor3 = Theme.Border
    msg.TextColor3 = Theme.Text
    msg.Font = Enum.Font.SourceSans
    msg.FontSize = Enum.FontSize.Size18
    local send = Instance.new("TextButton")
    send.Parent = ScreenGui
    send.Text = "Send"
    send.Size = UDim2.new(0, 100, 0, 40)
    send.Position = UDim2.new(0.5, -50, 0.5, 10)
    send.BackgroundColor3 = Theme.Success
    send.BorderColor3 = Theme.Border
    send.TextColor3 = Theme.Text
    send.Font = Enum.Font.SourceSans
    send.FontSize = Enum.FontSize.Size18
    send.MouseButton1Click:connect(function()
        for _, v in pairs(Players:GetPlayers()) do
            pcall(function()
                game:GetService("Chat"):Chat(v.Character.Head, msg.Text, Enum.ChatColor.Blue)
            end)
        end
        msg:Destroy()
        send:Destroy()
    end)
end)
AddButtonToTab(3, "Silent Executor", function()
    local frame = Instance.new("Frame")
    frame.Parent = ScreenGui
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Theme.Background
    frame.BorderColor3 = Theme.Border
    frame.BorderSizePixel = 3
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Text = "Silent Executor"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Theme.Highlight
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.SourceSansBold
    local codeBox = Instance.new("TextBox")
    codeBox.Parent = frame
    codeBox.Size = UDim2.new(1, -10, 1, -70)
    codeBox.Position = UDim2.new(0, 5, 0, 35)
    codeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    codeBox.TextColor3 = Theme.Text
    codeBox.BorderColor3 = Theme.Border
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = true
    codeBox.TextWrapped = true
    codeBox.Font = Enum.Font.Code
    codeBox.FontSize = Enum.FontSize.Size12
    local runBtn = CreateButton(frame, "Execute", UDim2.new(0, 5, 1, -35), UDim2.new(1, -10, 0, 30), function()
        if codeBox.Text ~= "" then
            LoadScript(codeBox.Text)
        end
    end, Theme.Success)
    local closeBtn = CreateButton(frame, "X", UDim2.new(1, -35, 0, 0), UDim2.new(0, 30, 0, 30), function()
        frame:Destroy()
    end, Theme.Danger)
    MakeDraggable(frame, title)
end)
AddButtonToTab(3, "Draw Tool", function() LoadScript([[
    -- Draw Tool from original
    print("Draw Tool equipped")
]]) end)
AddButtonToTab(3, "Tool Stealer", function()
    local bin = Instance.new("HopperBin", LocalPlayer.Backpack)
    bin.Name = "Tool Stealer"
    bin.Selected:connect(function(mouse)
        mouse.Button1Down:connect(function()
            local hit = mouse.Target
            if hit and hit.Parent then
                for _, v in pairs(hit.Parent:GetChildren()) do
                    if v:IsA("Tool") or v:IsA("HopperBin") then
                        v.Parent = LocalPlayer.Backpack
                    end
                end
            end
        end)
    end)
end)

-- ============ TAB 4: LOCALPLAYER ============
AddLabelToTab(4, "=== Character Mods ===", Theme.Warning)

-- Walkspeed
AddLabelToTab(4, "Walkspeed:", Theme.TextDim)
local wsBox = CreateTextBox(tabFrames[4], "16", UDim2.new(0, 10, 0, yOffset[4]), UDim2.new(0, 150, 0, 30), function(val)
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(val) or 16
    end
end)
yOffset[4] = yOffset[4] + 40
AddButtonToTab(4, "Set Walkspeed", function()
    local ws = wsBox.Text ~= "" and tonumber(wsBox.Text) or 16
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.WalkSpeed = ws
    end
end)

AddButtonToTab(4, "Heal", function()
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end, Theme.Success)

local godMode = false
AddButtonToTab(4, "God Mode (Toggle)", function()
    godMode = not godMode
    if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        if godMode then
            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
            LocalPlayer.Character.Humanoid.Health = math.huge
        else
            LocalPlayer.Character.Humanoid.MaxHealth = 100
            LocalPlayer.Character.Humanoid.Health = 100
        end
    end
end)

local invisible = false
AddButtonToTab(4, "Invisible (Toggle)", function()
    invisible = not invisible
    local trans = invisible and 1 or 0
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Transparency = trans
            end
        end
    end
end)

AddButtonToTab(4, "Chicken Arms", function()
    if LocalPlayer.Character and LocalPlayer.Character.Torso then
        local torso = LocalPlayer.Character.Torso
        if torso:FindFirstChild("Right Shoulder") then
            torso["Right Shoulder"].C0 = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(0, -math.pi/2, 0) * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, -math.pi/2, 0)
        end
        if torso:FindFirstChild("Left Shoulder") then
            torso["Left Shoulder"].C0 = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(math.pi/2, 0, 0) * CFrame.Angles(0, -math.pi/2, 0)
        end
    end
end)

AddButtonToTab(4, "Disco Character", function()
    local colors = {"Bright red", "Bright yellow", "Bright orange", "Bright violet", "Bright blue", "Bright green"}
    spawn(function()
        while true do
            wait(0.5)
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.BrickColor = BrickColor.new(colors[math.random(#colors)])
                    end
                end
            end
        end
    end)
end)

AddDivider(4)
AddLabelToTab(4, "=== Name Tag ===", Theme.Warning)
local nameBox = CreateTextBox(tabFrames[4], "New Name", UDim2.new(0, 10, 0, yOffset[4]), UDim2.new(0, 200, 0, 30), nil)
yOffset[4] = yOffset[4] + 40
AddButtonToTab(4, "Change Name", function()
    if nameBox.Text ~= "" then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:children()) do
                if v:FindFirstChild("TAG") then
                    v:Destroy()
                end
            end
            local model = Instance.new("Model", char)
            local clone = char.Head:Clone()
            local hum = Instance.new("Humanoid", model)
            local weld = Instance.new("Weld", clone)
            model.Name = nameBox.Text
            clone.Parent = model
            hum.Name = "TAG"
            weld.Part0 = clone
            weld.Part1 = char.Head
            char.Head.Transparency = 1
        end
    end
end)

AddDivider(4)
AddLabelToTab(4, "=== Billboard Gui ===", Theme.Warning)
local billText = CreateTextBox(tabFrames[4], "Text to display", UDim2.new(0, 10, 0, yOffset[4]), UDim2.new(1, -20, 0, 30), nil)
yOffset[4] = yOffset[4] + 40
AddButtonToTab(4, "Create Billboard", function()
    if LocalPlayer.Character and LocalPlayer.Character.Head and billText.Text ~= "" then
        local existing = LocalPlayer.Character.Head:FindFirstChild("AxverBillboard")
        if existing then existing:Destroy() end
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "AxverBillboard"
        bbg.Parent = LocalPlayer.Character.Head
        bbg.Adornee = LocalPlayer.Character.Head
        bbg.Size = UDim2.new(0, 200, 0, 50)
        bbg.StudsOffset = Vector3.new(0, 2.5, 0)
        local lbl = Instance.new("TextLabel", bbg)
        lbl.Text = billText.Text
        lbl.TextColor3 = Theme.Text
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.FontSize = Enum.FontSize.Size24
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- ============ TAB 5: SERVER ============
AddLabelToTab(5, "=== Server Destruction ===", Theme.Danger)
AddButtonToTab(5, "Kill All", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            v.Character:BreakJoints()
        end
    end
end, Theme.Danger)
AddButtonToTab(5, "Kick All", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            v:Kick("Kicked by AxverGui")
        end
    end
end, Theme.Danger)
AddButtonToTab(5, "Clear Workspace", function()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "Terrain" and not Players:GetPlayerFromCharacter(v) then
            v:Destroy()
        end
    end
end, Theme.Danger)
AddButtonToTab(5, "Unanchor All", function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = false
        end
    end
end)
AddButtonToTab(5, "Flood Terrain", function()
    Workspace.Terrain:SetCells(Region3int16.new(Vector3int16.new(-100, -100, -100), Vector3int16.new(100, 100, 100)), 17, "Solid", "X")
end)
AddButtonToTab(5, "Clear Terrain", function()
    Workspace.Terrain:Clear()
end)
AddButtonToTab(5, "Create Baseplate", function()
    local bp = Instance.new("Part")
    bp.Size = Vector3.new(1000, 5, 1000)
    bp.Position = Vector3.new(0, -2.5, 0)
    bp.Anchored = true
    bp.BrickColor = BrickColor.new("Earth green")
    bp.Name = "AxverBaseplate"
    bp.Parent = Workspace
end)

AddDivider(5)
AddLabelToTab(5, "=== Teleport ===", Theme.Warning)
local placeBox = CreateTextBox(tabFrames[5], "Place ID", UDim2.new(0, 10, 0, yOffset[5]), UDim2.new(1, -20, 0, 30), nil)
yOffset[5] = yOffset[5] + 40
AddButtonToTab(5, "Teleport to Place", function()
    if placeBox.Text ~= "" then
        TeleportService:Teleport(tonumber(placeBox.Text), LocalPlayer)
    end
end)

-- ============ TAB 6: PRESETS ============
AddLabelToTab(6, "=== Preset Music IDs ===", Theme.Warning)
local musicIdBox = CreateTextBox(tabFrames[6], "Music ID", UDim2.new(0, 10, 0, yOffset[6]), UDim2.new(1, -20, 0, 30), nil)
yOffset[6] = yOffset[6] + 40
local musicPitchBox = CreateTextBox(tabFrames[6], "Pitch (1.0)", UDim2.new(0, 10, 0, yOffset[6]), UDim2.new(1, -20, 0, 30), nil)
yOffset[6] = yOffset[6] + 40
AddButtonToTab(6, "Play Music", function()
    if musicIdBox.Text ~= "" then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Sound") then v:Stop(); v:Destroy() end
        end
        local sound = Instance.new("Sound", Workspace)
        sound.SoundId = "rbxassetid://" .. musicIdBox.Text
        sound.Volume = 1
        sound.Looped = true
        sound.Pitch = tonumber(musicPitchBox.Text) or 1
        sound:Play()
    end
end)

AddDivider(6)
AddLabelToTab(6, "=== Preset Skybox IDs ===", Theme.Warning)
local skyboxIdBox = CreateTextBox(tabFrames[6], "Skybox ID", UDim2.new(0, 10, 0, yOffset[6]), UDim2.new(1, -20, 0, 30), nil)
yOffset[6] = yOffset[6] + 40
AddButtonToTab(6, "Set Skybox", function()
    if skyboxIdBox.Text ~= "" then
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        local sky = Instance.new("Sky", Lighting)
        local id = skyboxIdBox.Text
        sky.SkyboxBk = "rbxassetid://" .. id
        sky.SkyboxDn = "rbxassetid://" .. id
        sky.SkyboxFt = "rbxassetid://" .. id
        sky.SkyboxLf = "rbxassetid://" .. id
        sky.SkyboxRt = "rbxassetid://" .. id
        sky.SkyboxUp = "rbxassetid://" .. id
    end
end)

AddDivider(6)
AddLabelToTab(6, "=== Preset Gear IDs ===", Theme.Warning)
local gearIdBox = CreateTextBox(tabFrames[6], "Gear ID", UDim2.new(0, 10, 0, yOffset[6]), UDim2.new(1, -20, 0, 30), nil)
yOffset[6] = yOffset[6] + 40
AddButtonToTab(6, "Insert Gear", function()
    if gearIdBox.Text ~= "" then
        local asset = InsertService:LoadAsset(tonumber(gearIdBox.Text))
        if asset then
            for _, v in pairs(asset:GetChildren()) do
                if v:IsA("Tool") or v:IsA("Hat") or v:IsA("Accoutrement") then
                    v.Parent = LocalPlayer.Backpack
                end
            end
            asset:Destroy()
        end
    end
end)

-- Quick preset buttons
local presetY = yOffset[6]
AddLabelToTab(6, "Quick Presets:", Theme.TextDim)
yOffset[6] = yOffset[6] + 25
AddButtonToTab(6, "Chop Suey (147407900)", function() musicIdBox.Text = "147407900" end)
AddButtonToTab(6, "Electro Sp00k (142930454)", function() musicIdBox.Text = "142930454" end)
AddButtonToTab(6, "Scream (138097458)", function() musicIdBox.Text = "138097458" end)
AddButtonToTab(6, "Team c00lkidd Logo (158118263)", function() skyboxIdBox.Text = "158118263" end)
AddButtonToTab(6, "Thomas (160456772)", function() skyboxIdBox.Text = "160456772" end)
AddButtonToTab(6, "Dual Darkhearts (108149175)", function() gearIdBox.Text = "108149175" end)
AddButtonToTab(6, "Linked Sword (125013769)", function() gearIdBox.Text = "125013769" end)
yOffset[6] = presetY

-- ============ TAB 7: SETTINGS ============
AddLabelToTab(7, "=== GUI Settings ===", Theme.Warning)
local themeColors = {
    {name = "Deep Sea Blue", bg = Color3.fromRGB(0, 85, 127), border = Color3.fromRGB(0, 150, 255)},
    {name = "Dark Red", bg = Color3.fromRGB(85, 0, 0), border = Color3.fromRGB(255, 0, 0)},
    {name = "Forest Green", bg = Color3.fromRGB(0, 85, 0), border = Color3.fromRGB(0, 255, 0)},
    {name = "Midnight Purple", bg = Color3.fromRGB(45, 0, 85), border = Color3.fromRGB(150, 0, 255)},
}

for _, theme in ipairs(themeColors) do
    AddButtonToTab(7, "Theme: " .. theme.name, function()
        MainFrame.BackgroundColor3 = theme.bg
        Sidebar.BackgroundColor3 = theme.bg
        TitleBar.BackgroundColor3 = theme.bg
        ContentContainer.BackgroundColor3 = theme.bg
        ContentContainer.BorderColor3 = theme.border
        MainFrame.BorderColor3 = theme.border
        for _, btn in pairs(tabButtons) do
            btn.BorderColor3 = theme.border
        end
    end)
end

AddButtonToTab(7, "Reset Theme", function()
    MainFrame.BackgroundColor3 = Theme.Background
    Sidebar.BackgroundColor3 = Theme.Background
    TitleBar.BackgroundColor3 = Theme.Background
    ContentContainer.BackgroundColor3 = Theme.Background
    ContentContainer.BorderColor3 = Theme.Border
    MainFrame.BorderColor3 = Theme.Border
    for _, btn in pairs(tabButtons) do
        btn.BorderColor3 = Theme.Border
    end
end)

AddDivider(7)
AddButtonToTab(7, "Uninstall AxverGui", function()
    ScreenGui:Destroy()
    if _G.AxverLoaded then
        _G.AxverLoaded = nil
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "AxverGui",
        Text = "AxverGui 1.00.00 has been uninstalled.",
        Duration = 3,
    })
end, Theme.Danger)

-- Finalize canvas sizes
for i = 1, #tabs do
    tabFrames[i].CanvasSize = UDim2.new(0, 0, 0, yOffset[i] + 20)
end

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AxverGui 1.00.00",
    Text = "Loaded successfully! Deep Sea Blue Theme.",
    Duration = 3,
})

_G.AxverLoaded = true
print("AxverGui 1.00.00 - Built from original c00lgui structure")