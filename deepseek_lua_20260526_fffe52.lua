local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local FOLDER_NAME = "AxverExecutor_Data"
local SAVE_FOLDER = FOLDER_NAME.."/SavedScripts"

if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end

-- ==================== CONSOLE SYSTEM ====================
local ConsoleVisible = false
local ConsoleMessages = {}

local function AddConsoleMessage(msg, msgType)
    msgType = msgType or "info"
    local time = os.date("%H:%M:%S")
    table.insert(ConsoleMessages, 1, {
        text = tostring(msg),
        type = msgType,
        time = time
    })
    if #ConsoleMessages > 200 then table.remove(ConsoleMessages) end
    if ConsoleVisible and ConsoleFrame then
        pcall(function() RefreshConsole() end)
    end
end

local function RefreshConsole()
    if not ConsoleFrame or not ConsoleList then return end
    for _, child in pairs(ConsoleList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for i, entry in ipairs(ConsoleMessages) do
        local color = entry.type == "error" and Color3.fromRGB(255, 80, 80) 
                    or (entry.type == "warn" and Color3.fromRGB(255, 200, 80)) 
                    or Color3.fromRGB(100, 200, 255)
        local line = Instance.new("TextLabel", ConsoleList)
        line.Size = UDim2.new(1, 0, 0, 20)
        line.BackgroundTransparency = 1
        line.Text = string.format("[%s] %s", entry.time, entry.text)
        line.TextColor3 = color
        line.TextXAlignment = "Left"
        line.Font = "Code"
        line.TextSize = 11
        line.TextWrapped = true
        line.Size = UDim2.new(1, 0, 0, line.TextBounds.Y + 4)
        -- Fade in animation
        line.BackgroundTransparency = 1
        TweenService:Create(line, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end
    ConsoleList.CanvasSize = UDim2.new(0, 0, 0, ConsoleList.AbsoluteContentSize.Y)
end

-- ==================== EXECUTOR CORE ====================
local function RunCode(code, isServerMode)
    if isServerMode then
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then 
                pcall(function() 
                    v:FireServer("loadstring", code) 
                    v:FireServer(code) 
                end)
            end
        end
        AddConsoleMessage("Executed in SERVER mode (attempt)", "info")
    else
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then 
                func()
                AddConsoleMessage("Script executed successfully", "info")
            else
                AddConsoleMessage("Failed to load script: Invalid syntax", "error")
            end
        end)
        if not success then
            AddConsoleMessage("Execution error: " .. tostring(err), "error")
        end
    end
end

-- ==================== SCRIPTBLOX INTEGRATION ====================
local function SearchScriptBlox(query, callback)
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
        callback(results)
    else
        callback({})
        AddConsoleMessage("Failed to fetch from ScriptBlox", "error")
    end
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

    -- Pulse animation for blur
    local function AnimateBlur()
        while Blur.Enabled do
            for i = 8, 16, 1 do
                TweenService:Create(Blur, TweenInfo.new(0.15), {Size = i}):Play()
                task.wait(0.05)
            end
            for i = 16, 8, -1 do
                TweenService:Create(Blur, TweenInfo.new(0.15), {Size = i}):Play()
                task.wait(0.05)
            end
        end
    end

    -- Overlay
    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.Visible = false
    Overlay.Active = true 

    -- Main Frame
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
    MainFrame.Position = UDim2.new(0.5, -350, 0.38, -160)
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
    
    -- Gradient background
    local UIGradient = Instance.new("UIGradient", MainFrame)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 20, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 30, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 40))
    })
    
    -- Animated gradient
    local gradientOffset = 0
    RunService.RenderStepped:Connect(function(dt)
        if not MainFrame.Visible then return end
        gradientOffset = (gradientOffset + dt * 0.5) % 2
        UIGradient.Offset = Vector2.new(gradientOffset, 0)
    end)
    
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 3
    MainStroke.Color = Color3.fromRGB(0, 120, 255)
    
    -- Animated border pulse
    local function AnimateBorder()
        while MainFrame.Visible do
            for i = 0, 1, 0.05 do
                local r = 0.5 + math.sin(i * math.pi) * 0.5
                MainStroke.Color = Color3.fromRGB(0, 120 + 50 * r, 255 - 50 * r)
                task.wait(0.02)
            end
        end
    end

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

    -- Title with animation
    local Title = Instance.new("TextLabel", MainFrame)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0.04, 0, 0, 10)
    Title.Size = UDim2.new(0, 180, 0, 35)
    Title.Font = "FredokaOne"
    Title.Text = "Axver Executor"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 20
    Title.TextXAlignment = "Left"
    
    -- Title glow effect
    local TitleGlow = Instance.new("TextLabel", Title)
    TitleGlow.BackgroundTransparency = 1
    TitleGlow.Position = UDim2.new(0, 2, 0, 2)
    TitleGlow.Size = UDim2.new(1, 0, 1, 0)
    TitleGlow.Font = "FredokaOne"
    TitleGlow.Text = "Axver Executor"
    TitleGlow.TextColor3 = Color3.fromRGB(0, 120, 255)
    TitleGlow.TextSize = 20
    TitleGlow.TextXAlignment = "Left"
    TitleGlow.TextTransparency = 0.6
    TitleGlow.ZIndex = 0

    -- Close Button with hover animation
    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    CloseBtn.Position = UDim2.new(1, -42, 0, 12)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = "GothamBold"
    CloseBtn.TextSize = 28
    Instance.new("UICorner", CloseBtn)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 35, 0, 35)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 60, 120)}):Play()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 30, 0, 30)}):Play()
    end)

    -- Control Hub
    local ControlHub = Instance.new("Frame", MainFrame)
    ControlHub.Size = UDim2.new(0, 520, 0, 26)
    ControlHub.Position = UDim2.new(1, -575, 0, 14)
    ControlHub.BackgroundTransparency = 1

    local ControlLayout = Instance.new("UIListLayout", ControlHub)
    ControlLayout.FillDirection = "Horizontal"
    ControlLayout.HorizontalAlignment = "Right"
    ControlLayout.Padding = UDim.new(0, 8)

    local function QuickBtn(text, size, color, func)
        local b = Instance.new("TextButton", ControlHub)
        b.Size = size
        b.BackgroundColor3 = color
        b.Text = text
        b.Font = "FredokaOne"
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 10
        Instance.new("UICorner", b)
        
        -- Hover animation
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {Size = UDim2.new(size.X.Scale + 0.01, size.X.Offset + 5, 1, 0)}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {Size = size}):Play()
        end)
        
        b.MouseButton1Click:Connect(function() 
            PlayClick()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
            task.wait(0.1)
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            if func then func(b) end
        end)
        return b
    end

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame", ExecutorPage)
    TabContainer.Size = UDim2.new(0.92, 0, 0, 32)
    TabContainer.Position = UDim2.new(0.04, 0, 0.14, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.FillDirection = "Horizontal"
    TabList.Padding = UDim.new(0, 6)

    -- Code Editor
    local CodeEditor = Instance.new("TextBox", ExecutorPage)
    CodeEditor.BackgroundColor3 = Color3.fromRGB(5, 15, 25)
    CodeEditor.Position = UDim2.new(0.04, 0, 0.26, 0)
    CodeEditor.Size = UDim2.new(0.92, 0, 0, 150)
    CodeEditor.MultiLine = true
    CodeEditor.PlaceholderText = "Paste script here..."
    CodeEditor.Text = ""
    CodeEditor.TextColor3 = Color3.new(1, 1, 1)
    CodeEditor.Font = "Code"
    CodeEditor.TextSize = 13
    CodeEditor.TextXAlignment = "Left"
    CodeEditor.TextYAlignment = "Top"
    CodeEditor.ClearTextOnFocus = false
    Instance.new("UICorner", CodeEditor).CornerRadius = UDim.new(0, 8)
    
    -- Code editor focus animation
    CodeEditor.Focused:Connect(function()
        TweenService:Create(CodeEditor, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(10, 25, 35)}):Play()
    end)
    CodeEditor.FocusLost:Connect(function()
        TweenService:Create(CodeEditor, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(5, 15, 25)}):Play()
    end)

    -- Tabs Data
    local currentTab = ""
    local tabsData = {}

    local function SaveTabs()
        pcall(function() 
            writefile(FOLDER_NAME.."/tabs.json", HttpService:JSONEncode(tabsData)) 
        end)
    end

    local function SwitchTab(name)
        if tabsData[currentTab] then 
            tabsData[currentTab].content = CodeEditor.Text 
        end
        currentTab = name
        -- Fade animation for content change
        TweenService:Create(CodeEditor, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
        task.wait(0.05)
        CodeEditor.Text = tabsData[name].content
        TweenService:Create(CodeEditor, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        
        for _, v in pairs(TabContainer:GetChildren()) do 
            if v:IsA("Frame") then 
                local newColor = (v.Name == name) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 40, 80)
                TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
            end 
        end
        SaveTabs()
    end

    local function CreateTabUI(name)
        local f = Instance.new("Frame", TabContainer)
        f.Name = name
        f.Size = UDim2.new(0, 145, 1, 0)
        f.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        -- Scale animation on creation
        f.Size = UDim2.new(0, 0, 1, 0)
        TweenService:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 145, 1, 0)}):Play()
        
        local b = Instance.new("TextBox", f)
        b.Size = UDim2.new(0.7, 0, 1, 0)
        b.Position = UDim2.new(0, 5, 0, 0)
        b.BackgroundTransparency = 1
        b.Text = name
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = "FredokaOne"
        b.TextSize = 10
        b.ClearTextOnFocus = false
        
        b.Focused:Connect(function() 
            PlayClick()
            SwitchTab(f.Name)
            TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(0, 200, 255)}):Play()
            task.wait(0.1)
            TweenService:Create(b, TweenInfo.new(0.1), {TextColor3 = Color3.new(1,1,1)}):Play()
        end)
        
        local close = Instance.new("TextButton", f)
        close.Size = UDim2.new(0, 22, 0, 22)
        close.Position = UDim2.new(1, -25, 0.5, -11)
        close.Text = "×"
        close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        close.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)
        
        close.MouseEnter:Connect(function()
            TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
        end)
        close.MouseLeave:Connect(function()
            TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        end)
        
        close.MouseButton1Click:Connect(function()
            PlayClick()
            if #TabContainer:GetChildren() <= 1 then return end
            TweenService:Create(f, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            task.wait(0.15)
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
    local ModeBtn = QuickBtn("CLIENT", UDim2.new(0, 95, 1, 0), Color3.fromRGB(0, 120, 255), function(b)
        isServerMode = not isServerMode
        local newText = isServerMode and "SERVER" or "CLIENT"
        local newColor = isServerMode and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(0, 120, 255)
        
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        b.Text = newText
        AddConsoleMessage("Switched to " .. newText .. " mode", "warn")
    end)

    QuickBtn("NEW TAB", UDim2.new(0, 80, 1, 0), Color3.fromRGB(0, 150, 100), function() 
        AddNewTab()
        AddConsoleMessage("New tab created", "info")
    end)
    
    QuickBtn("SCRIPTBLOX", UDim2.new(0, 100, 1, 0), Color3.fromRGB(0, 150, 200), function()
        -- Page transition animation
        TweenService:Create(ExecutorPage, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.15)
        ExecutorPage.Visible = false
        ScriptBloxPage.Visible = true
        ScriptBloxPage.BackgroundTransparency = 1
        TweenService:Create(ScriptBloxPage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    QuickBtn("CONSOLE", UDim2.new(0, 85, 1, 0), Color3.fromRGB(0, 100, 180), function()
        ConsoleVisible = true
        TweenService:Create(ExecutorPage, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.15)
        ExecutorPage.Visible = false
        ConsolePage.Visible = true
        ConsolePage.BackgroundTransparency = 1
        TweenService:Create(ConsolePage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        RefreshConsole()
    end)

    -- ==================== CONSOLE PAGE ====================
    local ConsoleFrame = Instance.new("Frame", ConsolePage)
    ConsoleFrame.Size = UDim2.new(0.92, 0, 0.75, 0)
    ConsoleFrame.Position = UDim2.new(0.04, 0, 0.12, 0)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    Instance.new("UICorner", ConsoleFrame).CornerRadius = UDim.new(0, 8)

    local ConsoleList = Instance.new("ScrollingFrame", ConsoleFrame)
    ConsoleList.Size = UDim2.new(1, -10, 1, -10)
    ConsoleList.Position = UDim2.new(0, 5, 0, 5)
    ConsoleList.BackgroundTransparency = 1
    ConsoleList.ScrollBarThickness = 4
    ConsoleList.AutomaticCanvasSize = "Y"

    local ConsoleLayout = Instance.new("UIListLayout", ConsoleList)
    ConsoleLayout.Padding = UDim.new(0, 2)
    ConsoleLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ClearConsole = Instance.new("TextButton", ConsolePage)
    ClearConsole.Size = UDim2.new(0, 120, 0, 35)
    ClearConsole.Position = UDim2.new(0.04, 0, 0.9, 0)
    ClearConsole.Text = "CLEAR CONSOLE"
    ClearConsole.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    ClearConsole.TextColor3 = Color3.new(1,1,1)
    ClearConsole.Font = "FredokaOne"
    Instance.new("UICorner", ClearConsole)
    
    ClearConsole.MouseEnter:Connect(function()
        TweenService:Create(ClearConsole, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    ClearConsole.MouseLeave:Connect(function()
        TweenService:Create(ClearConsole, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
    end)
    
    ClearConsole.MouseButton1Click:Connect(function()
        PlayClick()
        TweenService:Create(ClearConsole, TweenInfo.new(0.1), {Size = UDim2.new(0, 125, 0, 38)}):Play()
        task.wait(0.1)
        TweenService:Create(ClearConsole, TweenInfo.new(0.1), {Size = UDim2.new(0, 120, 0, 35)}):Play()
        ConsoleMessages = {}
        RefreshConsole()
        AddConsoleMessage("Console cleared", "warn")
    end)

    local BackFromConsole = Instance.new("TextButton", ConsolePage)
    BackFromConsole.Size = UDim2.new(0, 100, 0, 35)
    BackFromConsole.Position = UDim2.new(0.8, 0, 0.9, 0)
    BackFromConsole.Text = "BACK"
    BackFromConsole.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    BackFromConsole.TextColor3 = Color3.new(1,1,1)
    BackFromConsole.Font = "FredokaOne"
    Instance.new("UICorner", BackFromConsole)
    
    BackFromConsole.MouseEnter:Connect(function()
        TweenService:Create(BackFromConsole, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
    end)
    BackFromConsole.MouseLeave:Connect(function()
        TweenService:Create(BackFromConsole, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 80, 160)}):Play()
    end)
    
    BackFromConsole.MouseButton1Click:Connect(function()
        PlayClick()
        TweenService:Create(ConsolePage, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.15)
        ConsolePage.Visible = false
        ExecutorPage.Visible = true
        ExecutorPage.BackgroundTransparency = 1
        TweenService:Create(ExecutorPage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    -- ==================== SCRIPTBLOX PAGE ====================
    local SearchBox = Instance.new("TextBox", ScriptBloxPage)
    SearchBox.Size = UDim2.new(0.6, 0, 0, 40)
    SearchBox.Position = UDim2.new(0.04, 0, 0.12, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(5, 15, 25)
    SearchBox.PlaceholderText = "Search scripts on ScriptBlox..."
    SearchBox.TextColor3 = Color3.new(1,1,1)
    SearchBox.Font = "FredokaOne"
    Instance.new("UICorner", SearchBox)

    local SearchBtn = Instance.new("TextButton", ScriptBloxPage)
    SearchBtn.Size = UDim2.new(0, 100, 0, 40)
    SearchBtn.Position = UDim2.new(0.68, 0, 0.12, 0)
    SearchBtn.Text = "SEARCH"
    SearchBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SearchBtn.TextColor3 = Color3.new(1,1,1)
    SearchBtn.Font = "FredokaOne"
    Instance.new("UICorner", SearchBtn)
    
    SearchBtn.MouseEnter:Connect(function()
        TweenService:Create(SearchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
    end)
    SearchBtn.MouseLeave:Connect(function()
        TweenService:Create(SearchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
    end)

    local BackFromSB = Instance.new("TextButton", ScriptBloxPage)
    BackFromSB.Size = UDim2.new(0, 100, 0, 40)
    BackFromSB.Position = UDim2.new(0.8, 0, 0.12, 0)
    BackFromSB.Text = "BACK"
    BackFromSB.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    BackFromSB.TextColor3 = Color3.new(1,1,1)
    BackFromSB.Font = "FredokaOne"
    Instance.new("UICorner", BackFromSB)
    
    BackFromSB.MouseEnter:Connect(function()
        TweenService:Create(BackFromSB, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
    end)
    BackFromSB.MouseLeave:Connect(function()
        TweenService:Create(BackFromSB, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 80, 160)}):Play()
    end)
    
    BackFromSB.MouseButton1Click:Connect(function()
        PlayClick()
        TweenService:Create(ScriptBloxPage, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.15)
        ScriptBloxPage.Visible = false
        ExecutorPage.Visible = true
        ExecutorPage.BackgroundTransparency = 1
        TweenService:Create(ExecutorPage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)

    local ResultsScroll = Instance.new("ScrollingFrame", ScriptBloxPage)
    ResultsScroll.Size = UDim2.new(0.92, 0, 0.65, 0)
    ResultsScroll.Position = UDim2.new(0.04, 0, 0.25, 0)
    ResultsScroll.BackgroundTransparency = 1
    ResultsScroll.ScrollBarThickness = 4
    ResultsScroll.AutomaticCanvasSize = "Y"

    local ResultsLayout = Instance.new("UIListLayout", ResultsScroll)
    ResultsLayout.Padding = UDim.new(0, 8)

    local function AddScriptResult(title, script, gameName, views)
        local frame = Instance.new("Frame", ResultsScroll)
        frame.Size = UDim2.new(1, 0, 0, 70)
        frame.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        -- Scale animation on creation
        frame.Size = UDim2.new(1, 0, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 70)}):Play()
        
        local titleLabel = Instance.new("TextLabel", frame)
        titleLabel.Size = UDim2.new(0.5, 0, 0, 25)
        titleLabel.Position = UDim2.new(0.02, 0, 0.05, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title:sub(1, 50)
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = "FredokaOne"
        titleLabel.TextSize = 13
        titleLabel.TextXAlignment = "Left"
        
        local infoLabel = Instance.new("TextLabel", frame)
        infoLabel.Size = UDim2.new(0.5, 0, 0, 20)
        infoLabel.Position = UDim2.new(0.02, 0, 0.45, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = string.format("📁 %s  |  👁️ %s", gameName:sub(1, 30), tostring(views))
        infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        infoLabel.Font = "FredokaOne"
        infoLabel.TextSize = 10
        infoLabel.TextXAlignment = "Left"
        
        local function Btn(txt, pos, col, fn)
            local b = Instance.new("TextButton", frame)
            b.Size = UDim2.new(0, 90, 0, 30)
            b.Position = pos
            b.Text = txt
            b.BackgroundColor3 = col
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = "FredokaOne"
            b.TextSize = 11
            Instance.new("UICorner", b)
            
            b.MouseEnter:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col:Lerp(Color3.new(1,1,1), 0.2)}):Play()
            end)
            b.MouseLeave:Connect(function()
                TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col}):Play()
            end)
            
            b.MouseButton1Click:Connect(function()
                PlayClick()
                TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0, 95, 0, 33)}):Play()
                task.wait(0.1)
                TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0, 90, 0, 30)}):Play()
                fn()
            end)
            return b
        end
        
        Btn("EXECUTE", UDim2.new(1, -290, 0.5, -15), Color3.fromRGB(0, 120, 255), function()
            RunCode(script, false)
            AddConsoleMessage("Loaded from ScriptBlox: " .. title, "info")
        end)
        
        Btn("COPY", UDim2.new(1, -190, 0.5, -15), Color3.fromRGB(0, 80, 160), function()
            setclipboard(script)
            AddConsoleMessage("Copied to clipboard: " .. title, "info")
        end)
        
        Btn("+ TAB", UDim2.new(1, -90, 0.5, -15), Color3.fromRGB(0, 150, 200), function()
            AddNewTab(title:sub(1, 20), script)
            TweenService:Create(ScriptBloxPage, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            task.wait(0.15)
            ScriptBloxPage.Visible = false
            ExecutorPage.Visible = true
            ExecutorPage.BackgroundTransparency = 1
            TweenService:Create(ExecutorPage, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            AddConsoleMessage("Added to new tab: " .. title, "info")
        end)
    end

    SearchBtn.MouseButton1Click:Connect(function()
        if SearchBox.Text == "" then return end
        for _, child in pairs(ResultsScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local loading = Instance.new("TextLabel", ResultsScroll)
        loading.Size = UDim2.new(1, 0, 0, 40)
        loading.Text = "🔍 Searching ScriptBlox..."
        loading.BackgroundTransparency = 1
        loading.TextColor3 = Color3.fromRGB(0, 200, 255)
        loading.Font = "FredokaOne"
        
        -- Loading animation
        local dots = 0
        local loadingThread = task.spawn(function()
            while loading and loading.Parent do
                dots = (dots % 3) + 1
                loading.Text = "🔍 Searching ScriptBlox" .. string.rep(".", dots)
                task.wait(0.3)
            end
        end)
        
        SearchScriptBlox(SearchBox.Text, function(results)
            task.cancel(loadingThread)
            loading:Destroy()
            if #results == 0 then
                local noResult = Instance.new("TextLabel", ResultsScroll)
                noResult.Size = UDim2.new(1, 0, 0, 40)
                noResult.Text = "❌ No results found on ScriptBlox"
                noResult.BackgroundTransparency = 1
                noResult.TextColor3 = Color3.fromRGB(255, 100, 100)
                noResult.Font = "FredokaOne"
            else
                for _, r in pairs(results) do
                    AddScriptResult(r.title, r.script, r.game, r.views)
                end
                AddConsoleMessage(string.format("Found %d scripts on ScriptBlox", #results), "info")
            end
        end)
    end)

    -- ==================== EXECUTOR BUTTONS ====================
    local function MainBtn(txt, pos, col, fn)
        local b = Instance.new("TextButton", ExecutorPage)
        b.Size = UDim2.new(0, 180, 0, 45)
        b.Position = pos
        b.Text = txt
        b.BackgroundColor3 = col
        b.Font = "FredokaOne"
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 16
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = col:Lerp(Color3.new(1,1,1), 0.2)}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {Size = UDim2.new(0, 190, 0, 48)}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
            TweenService:Create(b, TweenInfo.new(0.15), {Size = UDim2.new(0, 180, 0, 45)}):Play()
        end)
        
        b.MouseButton1Click:Connect(function()
            PlayClick()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
            task.wait(0.1)
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            fn()
        end)
    end

    MainBtn("🚀 EXECUTE", UDim2.new(0.04, 0, 0.78, 0), Color3.fromRGB(0, 100, 200), function()
        RunCode(CodeEditor.Text, isServerMode)
    end)
    
    MainBtn("🗑️ CLEAR", UDim2.new(0.35, 0, 0.78, 0), Color3.fromRGB(50, 50, 50), function()
        TweenService:Create(CodeEditor, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        task.wait(0.15)
        CodeEditor.Text = ""
        TweenService:Create(CodeEditor, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        AddConsoleMessage("Editor cleared", "warn")
    end)
    
    MainBtn("📋 COPY ALL", UDim2.new(0.66, 0, 0.78, 0), Color3.fromRGB(0, 80, 160), function()
        setclipboard(CodeEditor.Text)
        AddConsoleMessage("Copied all text to clipboard", "info")
        TweenService:Create(MainBtn, TweenInfo.new(0.1), {Text = "✓ COPIED!"}):Play()
        task.wait(0.5)
        TweenService:Create(MainBtn, TweenInfo.new(0.1), {Text = "COPY ALL"}):Play()
    end)

    -- ==================== ICON WITH NEW ID ====================
    local IconBtn = Instance.new("ImageButton", ScreenGui)
    IconBtn.Size = UDim2.new(0, 65, 0, 65)
    IconBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    IconBtn.Image = "rbxassetid://116766438673467"
    IconBtn.BackgroundColor3 = Color3.fromRGB(0, 40, 80)
    IconBtn.ZIndex = 1000000
    Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(1, 0)
    
    -- Icon animations
    local iconPulse = true
    task.spawn(function()
        while iconPulse do
            TweenService:Create(IconBtn, TweenInfo.new(1), {Size = UDim2.new(0, 70, 0, 70)}):Play()
            TweenService:Create(IconBtn, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
            task.wait(0.5)
            TweenService:Create(IconBtn, TweenInfo.new(1), {Size = UDim2.new(0, 65, 0, 65)}):Play()
            TweenService:Create(IconBtn, TweenInfo.new(0.5), {ImageTransparency = 0.1}):Play()
            task.wait(0.5)
        end
    end)
    
    -- Rotate animation on hover
    IconBtn.MouseEnter:Connect(function()
        TweenService:Create(IconBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 75, 0, 75)}):Play()
        TweenService:Create(IconBtn, TweenInfo.new(0.2), {Rotation = 15}):Play()
        task.wait(0.1)
        TweenService:Create(IconBtn, TweenInfo.new(0.2), {Rotation = -15}):Play()
        task.wait(0.1)
        TweenService:Create(IconBtn, TweenInfo.new(0.2), {Rotation = 0}):Play()
    end)
    
    IconBtn.MouseLeave:Connect(function()
        TweenService:Create(IconBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 65, 0, 65)}):Play()
    end)

    local dragging, dragStart, startPos
    IconBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = IconBtn.Position
            TweenService:Create(IconBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 60, 100)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local finalX = math.clamp(startPos.X.Offset + delta.X, 0, ScreenGui.AbsoluteSize.X - 65)
            local finalY = math.clamp(startPos.Y.Offset + delta.Y, 0, ScreenGui.AbsoluteSize.Y - 65)
            IconBtn.Position = UDim2.new(0, finalX, 0, finalY)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(IconBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 40, 80)}):Play()
        end
    end)

    -- ==================== TOGGLE UI ====================
    local function ToggleUI(state)
        PlayClick()
        if state then
            MainFrame.Visible = true
            Overlay.Visible = true
            Blur.Enabled = true
            iconPulse = false
            TweenService:Create(IconBtn, TweenInfo.new(0.2), {ImageTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
            
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.BackgroundTransparency = 1
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 740, 0, 420)}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
            TweenService:Create(Overlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.85}):Play()
            
            -- Spawn border animation
            task.spawn(AnimateBorder)
            task.spawn(AnimateBlur)
        else
            iconPulse = true
            MainFrame.Size = UDim2.new(0, 740, 0, 420)
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)})
            TweenService:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            t:Play()
            t.Completed:Connect(function()
                if not state then
                    MainFrame.Visible = false
                    Overlay.Visible = false
                    Blur.Enabled = false
                    TweenService:Create(IconBtn, TweenInfo.new(0.3), {ImageTransparency = 0, Size = UDim2.new(0, 65, 0, 65)}):Play()
                    IconBtn.Visible = true
                end
            end)
        end
    end

    IconBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
    CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)

    -- Load saved tabs
    if isfile(FOLDER_NAME.."/tabs.json") then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(FOLDER_NAME.."/tabs.json")) end)
        tabsData = (s and d) or {["Tab 1"] = {content = ""}}
    else
        tabsData = {["Tab 1"] = {content = ""}}
    end
    
    for n,_ in pairs(tabsData) do CreateTabUI(n) end
    SwitchTab(next(tabsData))
    
    AddConsoleMessage("Axver Executor v2.0 loaded!", "info")
    AddConsoleMessage("Client mode enabled", "info")
    AddConsoleMessage("Icon ID: 116766438673467", "info")
end

-- ==================== LAUNCH ====================
LaunchHub()