--[[
  COMPLETE c00lkidd GUI - FULL OPERATIONAL SCRIPT
  Target: Roblox (Requires Executor: Synapse X, Krnl, Script-Ware, etc.)
  Features: Ad Spam, Image Flood, Lag Bomb, Server Crash, Kill All (FF Bypass), 
            Sound Spam, Teleport Trap, Anti-Kick, Infection, Cleanup, 
            Auto-Rejoin, Player List, God Mode, Fly, Noclip, ESP
  Author: palofsc
]]--

-- /////// CORE INITIALIZATION ///////
local execEnv = identifyexecutor()
local protectedGui = (execEnv and execEnv.syn and execEnv.syn.protect_gui and gethui) and gethui() or game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local virtualInputManager = game:GetService("VirtualInputManager")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera

-- Global State
_G.c00lState = _G.c00lState or {
    infectedPlayers = {},
    spawnedObjects = {},
    adLoopActive = false,
    imageFloodActive = false,
    lagBombActive = false,
    soundSpamActive = false,
    antiKickActive = false,
    infectActive = false,
    crashSequenceRunning = false,
    godModeActive = false,
    flyActive = false,
    noclipActive = false,
    espActive = false,
    flyBodyGyro = nil,
    flyBodyVelocity = nil,
    espConnections = {},
    godConnection = nil
}

-- /////// SECURE UI CONSTRUCTION ///////
local c00lGui = Instance.new("ScreenGui")
c00lGui.Name = "c00lgui_full_" .. httpService:GenerateGUID(false)
c00lGui.ResetOnSpawn = false
c00lGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
c00lGui.Parent = protectedGui

if execEnv and execEnv.syn and execEnv.syn.protect_gui then
    execEnv.syn.protect_gui(c00lGui)
end

-- Main container with scrolling capability
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = c00lGui
MainFrame.ClipsDescendants = true

-- Scrolling frame for all buttons
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 40)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 1800)
ScrollingFrame.Parent = MainFrame

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 1, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = ScrollingFrame

-- Title bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
TitleBar.Text = "TEAM C00LKIDD - FULL SUITE"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.GothamBlack
TitleBar.TextSize = 18
TitleBar.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    c00lGui:Destroy()
    _G.c00lState.adLoopActive = false
    _G.c00lState.imageFloodActive = false
    _G.c00lState.lagBombActive = false
    _G.c00lState.soundSpamActive = false
    _G.c00lState.infectActive = false
    _G.c00lState.flyActive = false
    _G.c00lState.noclipActive = false
    _G.c00lState.espActive = false
end)

-- /////// BUTTON CREATION FUNCTION ///////
local function createButton(text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = true
    btn.Parent = ButtonContainer
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggleButton(text, yOffset, stateVar, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. " [OFF]"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = true
    btn.Parent = ButtonContainer
    btn.MouseEnter:Connect(function()
        if not _G.c00lState[stateVar] then
            btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        end
    end)
    btn.MouseLeave:Connect(function()
        if not _G.c00lState[stateVar] then
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        _G.c00lState[stateVar] = not _G.c00lState[stateVar]
        if _G.c00lState[stateVar] then
            btn.Text = text .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            btn.Text = text .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        callback(_G.c00lState[stateVar])
    end)
    return btn
end

-- /////// NETWORK BYPASS MODULE ///////
local chatEvent = nil
local function findChatEvent()
    if chatEvent then return chatEvent end
    local possiblePaths = {
        replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"),
        replicatedStorage:FindFirstChild("SayMessageRequest"),
        game:GetService("TextChatService"):FindFirstChild("TextChatEvents")
    }
    for _, path in ipairs(possiblePaths) do
        if path then
            chatEvent = path
            return path
        end
    end
end

local function broadcastMessage(message)
    findChatEvent()
    if not chatEvent then return end
    pcall(function()
        if chatEvent:IsA("RemoteEvent") then
            chatEvent:FireServer(message, "All")
        elseif chatEvent.Parent == game:GetService("TextChatService") then
            local textChat = game:GetService("TextChatService")
            local channel = textChat.TextChannels.RBXGeneral
            if channel then channel:SendAsync(message) end
        end
    end)
end

-- /////// PLAYER LIST ///////
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -20, 0, 120)
PlayerList.Position = UDim2.new(0, 10, 0, 0)
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerList.BorderSizePixel = 1
PlayerList.BorderColor3 = Color3.fromRGB(150, 0, 0)
PlayerList.ScrollBarThickness = 4
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.Parent = ButtonContainer

local function refreshPlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local yPos = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local playerBtn = Instance.new("TextButton")
        playerBtn.Size = UDim2.new(1, -10, 0, 25)
        playerBtn.Position = UDim2.new(0, 5, 0, yPos)
        playerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        playerBtn.TextColor3 = player == LocalPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
        playerBtn.Text = player.Name
        playerBtn.Font = Enum.Font.GothamSemibold
        playerBtn.TextSize = 12
        playerBtn.Parent = PlayerList
        playerBtn.MouseButton1Click:Connect(function()
            if player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    camera.CameraSubject = player.Character
                end
            end
        end)
        yPos = yPos + 27
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- /////// BUTTON Y-AXIS OFFSET TRACKER ///////
local yOffset = 130

-- ///// SECTION 1: CHAT & VISUAL DISRUPTION /////
local sectionLabel1 = Instance.new("TextLabel")
sectionLabel1.Size = UDim2.new(1, -20, 0, 25)
sectionLabel1.Position = UDim2.new(0, 10, 0, yOffset)
sectionLabel1.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sectionLabel1.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionLabel1.Text = "-- CHAT & VISUAL DISRUPTION --"
sectionLabel1.Font = Enum.Font.GothamBlack
sectionLabel1.TextSize = 12
sectionLabel1.Parent = ButtonContainer
yOffset = yOffset + 30

-- AD SPAM
createToggleButton("AD SPAM", yOffset, "adLoopActive", function(state)
    if state then
        local messages = {
            "team c00lkidd join today!",
            "c00lkidd is back - we own this server",
            "JOIN c00lkidd NOW or get crashed",
            "team c00lkidd - the legends return",
            "c00lkidd was here - submit or leave"
        }
        spawn(function()
            while _G.c00lState.adLoopActive do
                broadcastMessage(messages[math.random(1, #messages)])
                task.wait(0.15)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- IMAGE FLOOD
createToggleButton("IMAGE FLOOD", yOffset, "imageFloodActive", function(state)
    if state then
        spawn(function()
            while _G.c00lState.imageFloodActive do
                if camera then
                    for i = 1, 5 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(8, 8, 0.1)
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 0.2
                        part.Material = Enum.Material.Neon
                        part.BrickColor = BrickColor.new("Bright red")
                        part.Position = camera.CFrame.Position + camera.CFrame.LookVector * 15 + Vector3.new(math.random(-8,8), math.random(-8,8), math.random(-8,8))
                        part.CFrame = CFrame.new(part.Position, camera.CFrame.Position)
                        part.Parent = workspace
                        local decal = Instance.new("Decal", part)
                        decal.Texture = "rbxassetid://187654688"
                        decal.Face = Enum.NormalId.Front
                        table.insert(_G.c00lState.spawnedObjects, part)
                        debris:AddItem(part, 5)
                    end
                end
                task.wait(0.08)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- SOUND SPAM
createToggleButton("SOUND SPAM", yOffset, "soundSpamActive", function(state)
    if state then
        local soundIds = {
            "rbxassetid://9118109106",
            "rbxassetid://9120386436",
            "rbxassetid://5410086218",
            "rbxassetid://145174549"
        }
        spawn(function()
            while _G.c00lState.soundSpamActive do
                local sound = Instance.new("Sound")
                sound.SoundId = soundIds[math.random(1, #soundIds)]
                sound.Volume = 10
                sound.PlaybackSpeed = math.random(80, 200) / 100
                sound.Parent = workspace
                sound:Play()
                debris:AddItem(sound, sound.TimeLength)
                task.wait(0.2)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- ///// SECTION 2: SERVER ATTACKS /////
yOffset = yOffset + 5
local sectionLabel2 = Instance.new("TextLabel")
sectionLabel2.Size = UDim2.new(1, -20, 0, 25)
sectionLabel2.Position = UDim2.new(0, 10, 0, yOffset)
sectionLabel2.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sectionLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionLabel2.Text = "-- SERVER ATTACKS --"
sectionLabel2.Font = Enum.Font.GothamBlack
sectionLabel2.TextSize = 12
sectionLabel2.Parent = ButtonContainer
yOffset = yOffset + 30

-- LAG BOMB
createToggleButton("LAG BOMB", yOffset, "lagBombActive", function(state)
    if state then
        spawn(function()
            while _G.c00lState.lagBombActive do
                local bombOrigin = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 50, 0)
                for i = 1, 80 do
                    local lagPart = Instance.new("Part")
                    lagPart.Size = Vector3.new(1.5, 1.5, 1.5)
                    lagPart.Anchored = false
                    lagPart.CanCollide = true
                    lagPart.Material = Enum.Material.Neon
                    lagPart.BrickColor = BrickColor.new("Really red")
                    lagPart.Position = bombOrigin + Vector3.new(math.random(-15,15), math.random(0,30), math.random(-15,15))
                    lagPart.Velocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
                    lagPart.Parent = workspace
                    table.insert(_G.c00lState.spawnedObjects, lagPart)
                    debris:AddItem(lagPart, 8)
                end
                for i = 1, 20 do
                    local pointLight = Instance.new("PointLight")
                    pointLight.Brightness = 10
                    pointLight.Range = 30
                    pointLight.Color = Color3.fromRGB(255, 0, 0)
                    pointLight.Parent = workspace.Terrain
                    debris:AddItem(pointLight, 3)
                end
                task.wait(0.03)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- CRASH SERVER
createButton("CRASH SERVER", yOffset, function()
    if _G.c00lState.crashSequenceRunning then return end
    _G.c00lState.crashSequenceRunning = true
    spawn(function()
        -- Phase 1: Massive weld cluster
        local root = Instance.new("Part")
        root.Size = Vector3.new(1,1,1)
        root.Anchored = true
        root.Position = Vector3.new(0, 10000, 0)
        root.Parent = workspace
        for i = 1, 500 do
            local sphere = Instance.new("Part")
            sphere.Shape = Enum.PartType.Ball
            sphere.Size = Vector3.new(3,3,3)
            sphere.Anchored = false
            sphere.Position = root.Position + Vector3.new(math.random(-10,10), i*3, math.random(-10,10))
            sphere.Parent = workspace
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = root
            weld.Part1 = sphere
            weld.Parent = sphere
        end
        -- Phase 2: Remote flood
        for _, remote in ipairs(replicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                spawn(function()
                    for i = 1, 500 do
                        pcall(function() remote:FireServer(math.huge, {}, true) end)
                    end
                end)
                break
            end
        end
        -- Phase 3: Infinite loop injection
        local repFirst = game:GetService("ReplicatedFirst")
        pcall(function()
            local crashModule = Instance.new("ModuleScript")
            crashModule.Name = "c00l_crash"
            crashModule.Source = "while task.wait() do end return {}"
            crashModule.Parent = repFirst
        end)
        task.wait(5)
        _G.c00lState.crashSequenceRunning = false
    end)
end)
yOffset = yOffset + 43

-- ///// SECTION 3: PLAYER MANIPULATION /////
yOffset = yOffset + 5
local sectionLabel3 = Instance.new("TextLabel")
sectionLabel3.Size = UDim2.new(1, -20, 0, 25)
sectionLabel3.Position = UDim2.new(0, 10, 0, yOffset)
sectionLabel3.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sectionLabel3.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionLabel3.Text = "-- PLAYER MANIPULATION --"
sectionLabel3.Font = Enum.Font.GothamBlack
sectionLabel3.TextSize = 12
sectionLabel3.Parent = ButtonContainer
yOffset = yOffset + 30

-- KILL ALL (ForceField Bypass)
createButton("KILL ALL (BYPASS FF)", yOffset, function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:TakeDamage(humanoid.MaxHealth)
                if humanoid.Health > 0 then
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            pcall(function()
                                part:Destroy()
                            end)
                        end
                    end
                end
            end
        end
    end
end)
yOffset = yOffset + 43

-- TELEPORT TRAP
createButton("TELEPORT TRAP ALL", yOffset, function()
    local trapPos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 30, 0)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                spawn(function()
                    while player.Character and root.Parent do
                        pcall(function()
                            root.CFrame = CFrame.new(trapPos + Vector3.new(0, 5, 0))
                            root.Velocity = Vector3.zero
                            root.RotVelocity = Vector3.zero
                        end)
                        task.wait(0.05)
                    end
                end)
            end
        end
    end
end)
yOffset = yOffset + 43

-- INFECT OTHERS
createToggleButton("INFECT OTHERS", yOffset, "infectActive", function(state)
    if state then
        spawn(function()
            while _G.c00lState.infectActive do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and not _G.c00lState.infectedPlayers[player.UserId] and player.Character then
                        local backpack = player:FindFirstChildOfClass("Backpack")
                        if backpack then
                            local tool = Instance.new("Tool")
                            tool.Name = "c00lkidd_joiner"
                            tool.RequiresHandle = false
                            local remote = Instance.new("RemoteEvent", tool)
                            remote.Name = "Loadc00l"
                            remote.OnServerEvent:Connect(function(infectedPlayer)
                                _G.c00lState.infectedPlayers[player.UserId] = true
                                broadcastMessage("c00lkidd infection spread to " .. player.Name)
                            end)
                            tool.Parent = backpack
                        end
                    end
                end
                task.wait(5)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- ///// SECTION 4: SELF MODIFICATIONS /////
yOffset = yOffset + 5
local sectionLabel4 = Instance.new("TextLabel")
sectionLabel4.Size = UDim2.new(1, -20, 0, 25)
sectionLabel4.Position = UDim2.new(0, 10, 0, yOffset)
sectionLabel4.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sectionLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionLabel4.Text = "-- SELF MODIFICATIONS --"
sectionLabel4.Font = Enum.Font.GothamBlack
sectionLabel4.TextSize = 12
sectionLabel4.Parent = ButtonContainer
yOffset = yOffset + 30

-- GOD MODE
createToggleButton("GOD MODE", yOffset, "godModeActive", function(state)
    if state then
        _G.c00lState.godConnection = runService.Heartbeat:Connect(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = humanoid.MaxHealth
                    humanoid.BreakJointsOnDeath = false
                end
            end
        end)
    else
        if _G.c00lState.godConnection then
            _G.c00lState.godConnection:Disconnect()
            _G.c00lState.godConnection = nil
        end
    end
end)
yOffset = yOffset + 43

-- FLY
createToggleButton("FLY", yOffset, "flyActive", function(state)
    if state then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChildOfClass("Humanoid")
        humanoid.PlatformStand = true
        
        _G.c00lState.flyBodyGyro = Instance.new("BodyGyro")
        _G.c00lState.flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        _G.c00lState.flyBodyGyro.CFrame = root.CFrame
        _G.c00lState.flyBodyGyro.Parent = root
        
        _G.c00lState.flyBodyVelocity = Instance.new("BodyVelocity")
        _G.c00lState.flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        _G.c00lState.flyBodyVelocity.Velocity = Vector3.zero
        _G.c00lState.flyBodyVelocity.Parent = root
        
        local speed = 50
        spawn(function()
            while _G.c00lState.flyActive and root and _G.c00lState.flyBodyGyro do
                _G.c00lState.flyBodyGyro.CFrame = camera.CFrame
                local vel = Vector3.zero
                if userInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + camera.CFrame.LookVector * speed end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - camera.CFrame.LookVector * speed end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - camera.CFrame.RightVector * speed end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + camera.CFrame.RightVector * speed end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, speed, 0) end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, speed, 0) end
                _G.c00lState.flyBodyVelocity.Velocity = vel
                task.wait()
            end
        end)
    else
        if _G.c00lState.flyBodyGyro then _G.c00lState.flyBodyGyro:Destroy(); _G.c00lState.flyBodyGyro = nil end
        if _G.c00lState.flyBodyVelocity then _G.c00lState.flyBodyVelocity:Destroy(); _G.c00lState.flyBodyVelocity = nil end
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end
end)
yOffset = yOffset + 43

-- NOCLIP
createToggleButton("NOCLIP", yOffset, "noclipActive", function(state)
    spawn(function()
        while _G.c00lState.noclipActive do
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            task.wait()
        end
    end)
end)
yOffset = yOffset + 43

-- ESP
createToggleButton("PLAYER ESP", yOffset, "espActive", function(state)
    if state then
        local function createESP(player)
            if player == LocalPlayer then return end
            local espFolder = Instance.new("Folder")
            espFolder.Name = "ESP_" .. player.Name
            
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = espFolder
            
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 0, 0)
            label.Text = player.Name
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            billboard.Parent = espFolder
            
            local connection
            connection = runService.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and espFolder.Parent then
                    highlight.Parent = player.Character
                    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
                else
                    connection:Disconnect()
                end
            end)
            espFolder.Parent = workspace
            table.insert(_G.c00lState.espConnections, connection)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end
        Players.PlayerAdded:Connect(createESP)
    else
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name:find("ESP_") then
                child:Destroy()
            end
        end
        for _, conn in ipairs(_G.c00lState.espConnections) do
            conn:Disconnect()
        end
        _G.c00lState.espConnections = {}
    end
end)
yOffset = yOffset + 43

-- ///// SECTION 5: PROTECTION & UTILITY /////
yOffset = yOffset + 5
local sectionLabel5 = Instance.new("TextLabel")
sectionLabel5.Size = UDim2.new(1, -20, 0, 25)
sectionLabel5.Position = UDim2.new(0, 10, 0, yOffset)
sectionLabel5.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
sectionLabel5.TextColor3 = Color3.fromRGB(255, 255, 255)
sectionLabel5.Text = "-- PROTECTION & UTILITY --"
sectionLabel5.Font = Enum.Font.GothamBlack
sectionLabel5.TextSize = 12
sectionLabel5.Parent = ButtonContainer
yOffset = yOffset + 30

-- ANTI-KICK
createToggleButton("ANTI-KICK", yOffset, "antiKickActive", function(state)
    if state then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "Kick" and self == LocalPlayer then
                return nil
            end
            if tostring(self) == "Kick" or tostring(self) == "kick" then
                return nil
            end
            return oldNamecall(self, unpack(args))
        end)
        setreadonly(mt, true)
        
        game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.InProgress then
                pcall(function()
                    game:GetService("TeleportService"):TeleportCancel()
                end)
            end
        end)
    end
end)
yOffset = yOffset + 43

-- AUTO REJOIN
createButton("AUTO REJOIN", yOffset, function()
    if #Players:GetPlayers() > 1 then
        local teleportService = game:GetService("TeleportService")
        pcall(function()
            teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
end)
yOffset = yOffset + 43

-- CLEANUP
createButton("CLEANUP ALL", yOffset, function()
    for _, obj in ipairs(_G.c00lState.spawnedObjects) do
        pcall(function() obj:Destroy() end)
    end
    _G.c00lState.spawnedObjects = {}
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:find("ESP_") then
            child:Destroy()
        end
    end
    for _, conn in ipairs(_G.c00lState.espConnections) do
        conn:Disconnect()
    end
    _G.c00lState.espConnections = {}
    _G.c00lState.adLoopActive = false
    _G.c00lState.imageFloodActive = false
    _G.c00lState.lagBombActive = false
    _G.c00lState.soundSpamActive = false
    _G.c00lState.infectActive = false
    _G.c00lState.flyActive = false
    _G.c00lState.noclipActive = false
    _G.c00lState.espActive = false
    _G.c00lState.godModeActive = false
    print("[c00lgui] Full cleanup complete")
end)
yOffset = yOffset + 43

-- UPDATE CANVAS SIZE
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 50)

-- /////// ANTI-AFK (Keep connection alive) ///////
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("[TEAM C00LKIDD] Full Suite Loaded Successfully")
print("[TEAM C00LKIDD] Join Today! - c00lkidd was here")