local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local FOLDER_NAME = "AxverExecutor_Data"
local SAVE_FOLDER = FOLDER_NAME.."/SavedScripts"

if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end

-- ==================== CONSOLE SYSTEM ====================
local ConsoleMessages = {}
local ConsoleVisible = false

local function AddConsoleMessage(msg, msgType)
    msgType = msgType or "info"
    local time = os.date("%H:%M:%S")
    table.insert(ConsoleMessages, 1, {text = tostring(msg), type = msgType, time = time})
    if #ConsoleMessages > 200 then table.remove(ConsoleMessages) end
end

-- ==================== FE BYPASS ====================
local function FEBypass()
    AddConsoleMessage("Attempting FE Bypass...", "warn")
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function()
                local oldFire = v.FireServer
                v.FireServer = function(self, ...)
                    return oldFire(self, ...)
                end
            end)
        end
        if v:IsA("RemoteFunction") then
            pcall(function()
                local oldInvoke = v.InvokeServer
                v.InvokeServer = function(self, ...)
                    return oldInvoke(self, ...)
                end
            end)
        end
    end
    AddConsoleMessage("FE Bypass attempted!", "info")
end

-- ==================== SCRIPTBLox FIXED ====================
local function SearchScriptBlox(query, callback)
    AddConsoleMessage("Searching ScriptBlox for: " .. query, "info")
    local url = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query)
    local success, res = pcall(function() return game:HttpGet(url) end)
    if success and res then
        local data = HttpService:JSONDecode(res)
        local results = {}
        if data.result and data.result.scripts then
            for _, v in pairs(data.result.scripts) do
                table.insert(results, {
                    title = v.title,
                    script = v.script,
                    game = v.game and v.game.name or "Unknown",
                    views = v.views or 0
                })
            end
        end
        AddConsoleMessage("Found " .. #results .. " scripts", "info")
        callback(results)
    else
        AddConsoleMessage("Failed to fetch from ScriptBlox: " .. tostring(res), "error")
        callback({})
    end
end

-- ==================== EXECUTOR CORE ====================
local function RunCode(code, isServerMode)
    if code == nil or code == "" then 
        AddConsoleMessage("No script to execute!", "error")
        return 
    end
    
    if isServerMode then
        AddConsoleMessage("Executing in SERVER mode...", "warn")
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then 
                pcall(function() 
                    v:FireServer(code)
                    v:FireServer("loadstring", code)
                end)
            end
            if v:IsA("RemoteFunction") then
                pcall(function() v:InvokeServer(code) end)
            end
        end
        AddConsoleMessage("Server execution attempted", "info")
    else
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then 
                func()
                AddConsoleMessage("Script executed successfully!", "info")
            else
                AddConsoleMessage("Invalid script syntax!", "error")
            end
        end)
        if not success then
            AddConsoleMessage("Execution error: " .. tostring(err), "error")
        end
    end
end

-- ==================== DRAG SYSTEM FIXED ====================
local function MakeDraggable(frame, dragButton)
    local dragging = false
    local dragStart, startPos
    
    dragButton = dragButton or frame
    
    dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, 200)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, 200)
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- ==================== MAIN HUB ====================
local function LaunchHub()
    if game.CoreGui:FindFirstChild("AxverExecutorHub") then
        game.CoreGui.AxverExecutorHub:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "AxverExecutorHub"
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    -- Click Sound
    local ClickSound = Instance.new("Sound", ScreenGui)
    ClickSound.SoundId = "rbxassetid://17208361335"
    ClickSound.Volume = 1
    local function PlayClick() ClickSound:Play() end

    -- Blur Effect
    local Blur = Instance.new("BlurEffect", game:GetService("Lighting"))
    Blur.Enabled = false
    Blur.Size = 12

    -- Overlay
    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.Visible = false
    Overlay.Active = true 

    -- Main Frame - SMALLER SIZE (500x350)
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
    MainFrame.Position = UDim2.new(0.5, -250, 0.4, -175)
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 2
    MainStroke.Color = Color3.fromRGB(0, 120, 255)

    -- Pages
    local Pages = Instance.new("Frame", MainFrame)
    Pages.Size = UDim2.new(1, 0, 1, 0)
    Pages.BackgroundTransparency = 1

    -- Executor Page
    local ExecutorPage = Instance.new("Frame", Pages)
    ExecutorPage.Size = UDim2.new(1, 0, 1, 0)
    ExecutorPage.BackgroundTransparency = 1

    -- Console Page
    local ConsolePage = Instance.new("Frame", Pages)
    ConsolePage.Size = UDim2.new(1, 0, 1, 0)
    ConsolePage.BackgroundTransparency = 1
    ConsolePage.Visible = false

    -- ScriptBlox Page
    local ScriptBloxPage = Instance.new("Frame", Pages)
    ScriptBloxPage.Size = UDim2.new(1, 0, 1, 0)
    ScriptBloxPage.BackgroundTransparency = 1
    ScriptBloxPage.Visible = false

    -- Title Bar (for dragging)
    local TitleBar = Instance.new("Frame", MainFrame)
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundTransparency = 1
    TitleBar.ZIndex = 10
    
    local Title = Instance.new("TextLabel", TitleBar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.04, 0, 0, 5)
    Title.Size = UDim2.new(0, 150, 0, 25)
    Title.Font = "FredokaOne"
    Title.Text = "Axver Executor"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 18
    Title.TextXAlignment = "Left"

    -- Close Button
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = "GothamBold"
    CloseBtn.TextSize = 22
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    -- Make draggable
    MakeDraggable(MainFrame, TitleBar)

    -- Control Hub
    local ControlHub = Instance.new("Frame", MainFrame)
    ControlHub.Size = UDim2.new(1, -10, 0, 28)
    ControlHub.Position = UDim2.new(0, 5, 0, 40)
    ControlHub.BackgroundTransparency = 1

    local ControlLayout = Instance.new("UIListLayout", ControlHub)
    ControlLayout.FillDirection = "Horizontal"
    ControlLayout.Padding = UDim.new(0, 5)

    local function QuickBtn(text, size, color, func)
        local b = Instance.new("TextButton", ControlHub)
        b.Size = size
        b.BackgroundColor3 = color
        b.Text = text
        b.Font = "FredokaOne"
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 11
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function() PlayClick(); if func then func(b) end end)
        return b
    end

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame", ExecutorPage)
    TabContainer.Size = UDim2.new(0.96, 0, 0, 30)
    TabContainer.Position = UDim2.new(0.02, 0, 0.14, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.FillDirection = "Horizontal"
    TabList.Padding = UDim.new(0, 4)

    -- Code Editor - SMALLER
    local CodeEditor = Instance.new("TextBox", ExecutorPage)
    CodeEditor.BackgroundColor3 = Color3.fromRGB(5, 15, 25)
    CodeEditor.Position = UDim2.new(0.02, 0, 0.22, 0)
    CodeEditor.Size = UDim2.new(0.96, 0, 0, 130)
    CodeEditor.MultiLine = true
    CodeEditor.PlaceholderText = "Paste script here..."
    CodeEditor.Text = ""
    CodeEditor.TextColor3 = Color3.new(1, 1, 1)
    CodeEditor.Font = "Code"
    CodeEditor.TextSize = 12
    CodeEditor.TextXAlignment = "Left"
    CodeEditor.TextYAlignment = "Top"
    CodeEditor.ClearTextOnFocus = false
    Instance.new("UICorner", CodeEditor).CornerRadius = UDim.new(0, 6)

    -- Tabs Data
    local currentTab = ""
    local tabsData = {}

    local function SaveTabs()
        pcall(function() writefile(FOLDER_NAME.."/tabs.json", HttpService:JSONEncode(tabsData)) end)
    end

    local function SwitchTab(name)
        if tabsData[currentTab] then tabsData[currentTab].content = CodeEditor.Text end
        currentTab = name
        CodeEditor.Text = tabsData[name].content
        for _, v in pairs(TabContainer:GetChildren()) do 
            if v:IsA("Frame") then 
                v.BackgroundColor3 = (v.Name == name) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 40, 80)
            end 
        end
        SaveTabs()
    end

    local function CreateTabUI(name)
        local f = Instance.new("Frame", TabContainer)
        f.Name = name
        f.Size = UDim2.new(0, 120, 1, 0)
        f.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        
        local b = Instance.new("TextBox", f)
        b.Size = UDim2.new(0.65, 0, 1, 0)
        b.Position = UDim2.new(0, 4, 0, 0)
        b.BackgroundTransparency = 1
        b.Text = name
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = "FredokaOne"
        b.TextSize = 9
        b.ClearTextOnFocus = false
        b.Focused:Connect(function() PlayClick(); SwitchTab(f.Name) end)
        
        local close = Instance.new("TextButton", f)
        close.Size = UDim2.new(0, 18, 0, 18)
        close.Position = UDim2.new(1, -22, 0.5, -9)
        close.Text = "×"
        close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        close.TextColor3 = Color3.new(1,1,1)
        close.TextSize = 14
        Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)
        close.MouseButton1Click:Connect(function()
            if #TabContainer:GetChildren() <= 1 then return end
            tabsData[f.Name] = nil
            f:Destroy()
            SwitchTab(next(tabsData))
        end)
        
        TabContainer.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X, 0, 0)
    end

    local function AddNewTab(name, content)
        local newName = name or ("Tab "..(tick()%1000//1))
        tabsData[newName] = {content = content or ""}
        CreateTabUI(newName)
        SwitchTab(newName)
    end

    -- Mode Selection
    local isServerMode = false
    local ModeBtn = QuickBtn("CLIENT", UDim2.new(0, 75, 1, 0), Color3.fromRGB(0, 120, 255), function(b)
        isServerMode = not isServerMode
        b.Text = isServerMode and "SERVER" or "CLIENT"
        b.BackgroundColor3 = isServerMode and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(0, 120, 255)
    end)

    QuickBtn("NEW TAB", UDim2.new(0, 70, 1, 0), Color3.fromRGB(0, 150, 100), function() AddNewTab() end)
    QuickBtn("FE BYPASS", UDim2.new(0, 80, 1, 0), Color3.fromRGB(200, 100, 0), function() FEBypass() end)
    QuickBtn("SCRIPTBLOX", UDim2.new(0, 85, 1, 0), Color3.fromRGB(0, 150, 200), function()
        ExecutorPage.Visible = false
        ScriptBloxPage.Visible = true
    end)
    QuickBtn("CONSOLE", UDim2.new(0, 75, 1, 0), Color3.fromRGB(0, 100, 180), function()
        ConsoleVisible = true
        ExecutorPage.Visible = false
        ConsolePage.Visible = true
    end)

    -- ==================== CONSOLE PAGE ====================
    local ConsoleFrame = Instance.new("Frame", ConsolePage)
    ConsoleFrame.Size = UDim2.new(0.96, 0, 0.7, 0)
    ConsoleFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    Instance.new("UICorner", ConsoleFrame).CornerRadius = UDim.new(0, 6)

    local ConsoleList = Instance.new("ScrollingFrame", ConsoleFrame)
    ConsoleList.Size = UDim2.new(1, -10, 1, -10)
    ConsoleList.Position = UDim2.new(0, 5, 0, 5)
    ConsoleList.BackgroundTransparency = 1
    ConsoleList.ScrollBarThickness = 4
    ConsoleList.AutomaticCanvasSize = "Y"

    local ConsoleLayout = Instance.new("UIListLayout", ConsoleList)
    ConsoleLayout.Padding = UDim.new(0, 2)

    local function RefreshConsole()
        for _, child in pairs(ConsoleList:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        for i, entry in ipairs(ConsoleMessages) do
            local color = entry.type == "error" and Color3.fromRGB(255, 80, 80) 
                        or (entry.type == "warn" and Color3.fromRGB(255, 200, 80)) 
                        or Color3.fromRGB(100, 200, 255)
            local line = Instance.new("TextLabel", ConsoleList)
            line.Size = UDim2.new(1, 0, 0, 18)
            line.BackgroundTransparency = 1
            line.Text = string.format("[%s] %s", entry.time, entry.text)
            line.TextColor3 = color
            line.TextXAlignment = "Left"
            line.Font = "Code"
            line.TextSize = 10
        end
        ConsoleList.CanvasSize = UDim2.new(0, 0, 0, ConsoleList.AbsoluteContentSize.Y)
    end

    local ClearConsole = Instance.new("TextButton", ConsolePage)
    ClearConsole.Size = UDim2.new(0, 100, 0, 30)
    ClearConsole.Position = UDim2.new(0.02, 0, 0.85, 0)
    ClearConsole.Text = "CLEAR"
    ClearConsole.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    ClearConsole.TextColor3 = Color3.new(1,1,1)
    ClearConsole.Font = "FredokaOne"
    Instance.new("UICorner", ClearConsole).CornerRadius = UDim.new(0, 4)
    ClearConsole.MouseButton1Click:Connect(function()
        PlayClick()
        for i = #ConsoleMessages, 1, -1 do table.remove(ConsoleMessages, i) end
        RefreshConsole()
    end)

    local BackConsole = Instance.new("TextButton", ConsolePage)
    BackConsole.Size = UDim2.new(0, 80, 0, 30)
    BackConsole.Position = UDim2.new(0.85, 0, 0.85, 0)
    BackConsole.Text = "BACK"
    BackConsole.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    BackConsole.TextColor3 = Color3.new(1,1,1)
    BackConsole.Font = "FredokaOne"
    Instance.new("UICorner", BackConsole).CornerRadius = UDim.new(0, 4)
    BackConsole.MouseButton1Click:Connect(function()
        ConsolePage.Visible = false
        ExecutorPage.Visible = true
        RefreshConsole()
    end)

    -- ==================== SCRIPTBLOX PAGE FIXED ====================
    local SearchBox = Instance.new("TextBox", ScriptBloxPage)
    SearchBox.Size = UDim2.new(0.6, 0, 0, 35)
    SearchBox.Position = UDim2.new(0.02, 0, 0.08, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(5, 15, 25)
    SearchBox.PlaceholderText = "Search scripts..."
    SearchBox.TextColor3 = Color3.new(1,1,1)
    SearchBox.Font = "FredokaOne"
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    local SearchBtn = Instance.new("TextButton", ScriptBloxPage)
    SearchBtn.Size = UDim2.new(0, 80, 0, 35)
    SearchBtn.Position = UDim2.new(0.64, 0, 0.08, 0)
    SearchBtn.Text = "SEARCH"
    SearchBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SearchBtn.TextColor3 = Color3.new(1,1,1)
    SearchBtn.Font = "FredokaOne"
    Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 4)

    local BackSB = Instance.new("TextButton", ScriptBloxPage)
    BackSB.Size = UDim2.new(0, 80, 0, 35)
    BackSB.Position = UDim2.new(0.75, 0, 0.08, 0)
    BackSB.Text = "BACK"
    BackSB.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    BackSB.TextColor3 = Color3.new(1,1,1)
    BackSB.Font = "FredokaOne"
    Instance.new("UICorner", BackSB).CornerRadius = UDim.new(0, 4)
    BackSB.MouseButton1Click:Connect(function()
        ScriptBloxPage.Visible = false
        ExecutorPage.Visible = true
    end)

    local ResultsScroll = Instance.new("ScrollingFrame", ScriptBloxPage)
    ResultsScroll.Size = UDim2.new(0.96, 0, 0.7, 0)
    ResultsScroll.Position = UDim2.new(0.02, 0, 0.2, 0)
    ResultsScroll.BackgroundTransparency = 1
    ResultsScroll.ScrollBarThickness = 4
    ResultsScroll.AutomaticCanvasSize = "Y"

    local ResultsLayout = Instance.new("UIListLayout", ResultsScroll)
    ResultsLayout.Padding = UDim.new(0, 6)

    local function AddScriptResult(title, script, gameName, views)
        local frame = Instance.new("Frame", ResultsScroll)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local titleLabel = Instance.new("TextLabel", frame)
        titleLabel.Size = UDim2.new(0.45, 0, 0, 22)
        titleLabel.Position = UDim2.new(0.01, 0, 0.03, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title:sub(1, 45)
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = "FredokaOne"
        titleLabel.TextSize = 11
        titleLabel.TextXAlignment = "Left"
        
        local infoLabel = Instance.new("TextLabel", frame)
        infoLabel.Size = UDim2.new(0.45, 0, 0, 18)
        infoLabel.Position = UDim2.new(0.01, 0, 0.45, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = string.format("🎮 %s  |  👁️ %s", gameName:sub(1, 25), tostring(views))
        infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        infoLabel.Font = "FredokaOne"
        infoLabel.TextSize = 9
        infoLabel.TextXAlignment = "Left"
        
        local function Btn(txt, pos, col, fn)
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.new(0, 70, 0, 28)
            b.Position = pos
            b.Text = txt
            b.BackgroundColor3 = col
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = "FredokaOne"
            b.TextSize = 10
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function() PlayClick(); fn() end)
            return b
        end
        
        Btn("RUN", UDim2.new(1, -225, 0.5, -14), Color3.fromRGB(0, 120, 255), function()
            RunCode(script, false)
            AddConsoleMessage("Executed: " .. title, "info")
        end)
        
        Btn("COPY", UDim2.new(1, -150, 0.5, -14), Color3.fromRGB(0, 80, 160), function()
            setclipboard(script)
            AddConsoleMessage("Copied: " .. title, "info")
        end)
        
        Btn("+ TAB", UDim2.new(1, -75, 0.5, -14), Color3.fromRGB(0, 150, 200), function()
            AddNewTab(title:sub(1, 15), script)
            ScriptBloxPage.Visible = false
            ExecutorPage.Visible = true
            AddConsoleMessage("Added to tab: " .. title, "info")
        end)
    end

    SearchBtn.MouseButton1Click:Connect(function()
        if SearchBox.Text == "" then return end
        for _, child in pairs(ResultsScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local loading = Instance.new("TextLabel", ResultsScroll)
        loading.Size = UDim2.new(1, 0, 0, 30)
        loading.Text = "🔍 Searching..."
        loading.BackgroundTransparency = 1
        loading.TextColor3 = Color3.fromRGB(0, 200, 255)
        loading.Font = "FredokaOne"
        
        SearchScriptBlox(SearchBox.Text, function(results)
            loading:Destroy()
            if #results == 0 then
                local noResult = Instance.new("TextLabel", ResultsScroll)
                noResult.Size = UDim2.new(1, 0, 0, 30)
                noResult.Text = "❌ No results found"
                noResult.BackgroundTransparency = 1
                noResult.TextColor3 = Color3.fromRGB(255, 100, 100)
                noResult.Font = "FredokaOne"
            else
                for _, r in pairs(results) do
                    AddScriptResult(r.title, r.script, r.game, r.views)
                end
            end
        end)
    end)

    -- ==================== EXECUTOR BUTTONS ====================
    local function MainBtn(txt, pos, col, fn)
        local b = Instance.new("TextButton", ExecutorPage)
        b.Size = UDim2.new(0, 150, 0, 38)
        b.Position = pos
        b.Text = txt
        b.BackgroundColor3 = col
        b.Font = "FredokaOne"
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 14
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function() PlayClick(); fn() end)
        return b
    end

    MainBtn("▶ EXECUTE", UDim2.new(0.02, 0, 0.82, 0), Color3.fromRGB(0, 100, 200), function()
        RunCode(CodeEditor.Text, isServerMode)
    end)
    
    MainBtn("🗑 CLEAR", UDim2.new(0.28, 0, 0.82, 0), Color3.fromRGB(50, 50, 50), function()
        CodeEditor.Text = ""
        AddConsoleMessage("Editor cleared", "warn")
    end)
    
    MainBtn("📋 COPY", UDim2.new(0.54, 0, 0.82, 0), Color3.fromRGB(0, 80, 160), function()
        setclipboard(CodeEditor.Text)
        AddConsoleMessage("Copied to clipboard", "info")
    end)

    -- Icon Button
    local IconBtn = Instance.new("ImageButton", ScreenGui)
    IconBtn.Size = UDim2.new(0, 55, 0, 55)
    IconBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    IconBtn.Image = "rbxassetid://116766438673467"
    IconBtn.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    IconBtn.ZIndex = 1000000
    Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(1, 0)
    
    -- Icon drag
    local iconDragging = false
    local iconDragStart, iconStartPos
    
    IconBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = true
            iconDragStart = input.Position
            iconStartPos = IconBtn.Position
        end
    end)
    
    IconBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - iconDragStart
            local newX = math.clamp(iconStartPos.X.Offset + delta.X, 0, ScreenGui.AbsoluteSize.X - 55)
            local newY = math.clamp(iconStartPos.Y.Offset + delta.Y, 0, ScreenGui.AbsoluteSize.Y - 55)
            IconBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Toggle UI
    local function ToggleUI(state)
        PlayClick()
        if state then
            MainFrame.Visible = true
            Overlay.Visible = true
            Blur.Enabled = true
            IconBtn.Visible = false
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play()
            TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.85}):Play()
        else
            IconBtn.Visible = true
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)})
            TweenService:Create(Overlay, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            t:Play()
            t.Completed:Connect(function()
                if not state then
                    MainFrame.Visible = false
                    Overlay.Visible = false
                    Blur.Enabled = false
                end
            end)
        end
    end

    IconBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
    CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

    -- Load saved tabs
    if isfile(FOLDER_NAME.."/tabs.json") then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(FOLDER_NAME.."/tabs.json")) end)
        tabsData = (s and d) or {["Main"] = {content = ""}}
    else
        tabsData = {["Main"] = {content = ""}}
    end
    
    for n,_ in pairs(tabsData) do CreateTabUI(n) end
    SwitchTab(next(tabsData))
    
    AddConsoleMessage("Axver Executor Ready!", "info")
    AddConsoleMessage("Client mode | Drag to move", "info")
end

-- ==================== LAUNCH ====================
LaunchHub()