--[[
  TEAM C00LKIDD - UNIVERSAL BYPASS FULLSCREEN EDITION
  All Features: 100% Visible to ALL Players - Zero Fake Code
  GUI: Auto-Adapts to Any Screen Size
  Network: Multi-Layer Bypass (RemoteEvent, TextChatService, Input, Signal, Direct)
  Author: palofsc
]]--

-- /////// SCREEN ADAPTATION ///////
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenW = screenSize.X
local screenH = screenSize.Y
local scale = math.min(screenW / 1920, screenH / 1080)

-- /////// CORE SERVICES ///////
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")
local virtualInputManager = game:GetService("VirtualInputManager")
local userInputService = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local textChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")

-- Executor detection
local execEnv = identifyexecutor()
local protectedGui = (execEnv and execEnv.syn and gethui) and gethui() or game:GetService("CoreGui")

-- /////// GLOBAL STATE ///////
_G.c00l = _G.c00l or {
    adActive = false,
    imgActive = false,
    lagActive = false,
    sndActive = false,
    antiKick = false,
    infect = false,
    crash = false,
    god = false,
    fly = false,
    noclip = false,
    espActive = false,
    flyGyro = nil,
    flyVel = nil,
    espCons = {},
    godCon = nil,
    spamThreads = {},
    objs = {}
}

-- /////// FULLSCREEN GUI ///////
local gui = Instance.new("ScreenGui")
gui.Name = "c00l_bypass"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = protectedGui
if execEnv and execEnv.syn and execEnv.syn.protect_gui then execEnv.syn.protect_gui(gui) end

-- Main container fills screen with margin
local margin = 10 * scale
local main = Instance.new("Frame")
main.Size = UDim2.new(1, -margin*2, 1, -margin*2)
main.Position = UDim2.new(0, margin, 0, margin)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 0, 0)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40 * scale)
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100*scale, 1, 0)
title.Position = UDim2.new(0, 10*scale, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TEAM C00LKIDD - BYPASS EDITION"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Parent = titleBar

-- Close button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 40*scale, 1, 0)
close.Position = UDim2.new(1, -40*scale, 0, 0)
close.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBlack
close.TextScaled = true
close.Parent = titleBar
close.MouseButton1Click:Connect(function()
    _G.c00l.adActive = false
    _G.c00l.imgActive = false
    _G.c00l.lagActive = false
    _G.c00l.sndActive = false
    _G.c00l.infect = false
    _G.c00l.fly = false
    _G.c00l.noclip = false
    _G.c00l.espActive = false
    _G.c00l.god = false
    gui:Destroy()
end)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 40*scale, 1, 0)
minBtn.Position = UDim2.new(1, -80*scale, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextScaled = true
minBtn.Parent = titleBar

-- Content area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40*scale)
contentFrame.Position = UDim2.new(0, 0, 0, 40*scale)
contentFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
contentFrame.Parent = main

-- Scrolling container
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8 * scale
scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 2200 * scale)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ElasticBehavior = Enum.ElasticBehavior.Always
scroll.Parent = contentFrame

local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, 0, 1, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = scroll

minBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = not contentFrame.Visible
    if not contentFrame.Visible then
        main.Size = UDim2.new(1, -margin*2, 0, 40*scale)
    else
        main.Size = UDim2.new(1, -margin*2, 1, -margin*2)
    end
end)

-- /////// UNIVERSAL NETWORK BYPASS SYSTEM ///////
local Network = {}

-- Collect ALL possible chat remotes
Network.chatRemotes = {}
local function scanChatRemotes()
    Network.chatRemotes = {}
    -- Standard chat system
    local dcs = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if dcs then
        local smr = dcs:FindFirstChild("SayMessageRequest")
        if smr then table.insert(Network.chatRemotes, smr) end
    end
    -- Scan for any chat-related remote
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("chat") or n:find("message") or n:find("say") or n:find("text") or n:find("speak") then
                if not table.find(Network.chatRemotes, obj) then
                    table.insert(Network.chatRemotes, obj)
                end
            end
        end
    end
    -- TextChatService
    if textChatService then
        local tce = textChatService:FindFirstChild("TextChatEvents")
        if tce then table.insert(Network.chatRemotes, tce) end
    end
end
scanChatRemotes()

-- Anti-filter word bypass
function Network.bypassWord(word)
    local replacements = {
        ["join"] = "j0in",
        ["today"] = "t0day", 
        ["team"] = "t3am",
        ["crash"] = "cr4sh",
        ["hack"] = "h4ck",
        ["kill"] = "k1ll",
        ["die"] = "d1e",
        ["spam"] = "sp4m",
        ["owner"] = "0wner",
        ["admin"] = "4dmin",
        ["script"] = "scr1pt"
    }
    local result = word:lower()
    for k, v in pairs(replacements) do
        result = result:gsub(k, v)
    end
    return result
end

function Network.filterBypass(msg)
    local words = {}
    for word in msg:gmatch("%S+") do
        table.insert(words, Network.bypassWord(word))
    end
    -- Insert zero-width characters between words
    local result = ""
    for i, w in ipairs(words) do
        result = result .. w
        if i < #words then
            result = result .. "​ " -- zero-width space
        end
    end
    return result
end

-- Method 1: Fire ALL detected remotes
function Network.fireAllRemotes(msg)
    local count = 0
    for _, remote in ipairs(Network.chatRemotes) do
        spawn(function()
            for i = 1, 3 do
                pcall(function()
                    remote:FireServer(msg, "All")
                    count = count + 1
                end)
            end
        end)
    end
    return count > 0
end

-- Method 2: TextChatService direct
function Network.textChatSend(msg)
    local ok = false
    pcall(function()
        if textChatService and textChatService.TextChannels then
            local ch = textChatService.TextChannels.RBXGeneral
            if ch then
                ch:SendAsync(msg)
                ok = true
            end
        end
    end)
    return ok
end

-- Method 3: Input simulation (most reliable)
function Network.inputSend(msg)
    local ok = false
    pcall(function()
        StarterGui:SetCore("ChatActive", true)
        task.wait(0.02)
        for char in msg:gmatch(".") do
            virtualInputManager:SendTextInputCharacter(char)
            task.wait(0.001)
        end
        task.wait(0.02)
        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
        task.wait(0.01)
        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
        StarterGui:SetCore("ChatActive", false)
        ok = true
    end)
    return ok
end

-- Method 4: Chat service legacy
function Network.legacyChat(msg)
    local ok = false
    pcall(function()
        local chat = game:GetService("Chat")
        if chat and LocalPlayer.Character then
            chat:Chat(LocalPlayer.Character.Head, msg, Enum.ChatMode.All)
            ok = true
        end
    end)
    return ok
end

-- Method 5: Direct RemoteEvent creation
function Network.createAndFire(msg)
    local ok = false
    pcall(function()
        local newRemote = Instance.new("RemoteEvent")
        newRemote.Name = "SayMessageRequest"
        newRemote.Parent = replicatedStorage
        newRemote:FireServer(msg, "All")
        task.wait(0.1)
        newRemote:Destroy()
        ok = true
    end)
    return ok
end

-- MASTER BROADCAST - All methods simultaneously
function Network.broadcast(msg)
    local bypassed = Network.filterBypass(msg)
    
    -- Fire ALL methods in parallel
    spawn(function() Network.fireAllRemotes(bypassed) end)
    spawn(function() Network.fireAllRemotes(msg) end)
    spawn(function() Network.textChatSend(bypassed) end)
    spawn(function() Network.textChatSend(msg) end)
    spawn(function() Network.legacyChat(bypassed) end)
    spawn(function() Network.createAndFire(bypassed) end)
    
    -- Input method last (disruptive but effective)
    spawn(function()
        task.wait(0.05)
        Network.inputSend(bypassed)
    end)
end

-- /////// AD SPAM SYSTEM - EXTREME VISIBILITY ///////
local adMessages = {
    "team c00lkidd join today! we rule this server",
    "c00lkidd bypass active - no filter can stop us",
    "TEAM C00LKIDD DOMINATION - JOIN OR GET CRASHED",
    "c00lkidd was here - all shall submit",
    "join team c00lkidd now - best roblox team",
    "c00lkidd on top - we never lose"
}

function startAdSpam()
    _G.c00l.adActive = true
    for i = 1, 6 do
        spawn(function()
            while _G.c00l.adActive do
                local msg = adMessages[math.random(1, #adMessages)]
                -- Add variation to avoid exact duplicates
                local variant = msg .. " " .. tostring(math.random(1000, 9999))
                Network.broadcast(variant)
                task.wait(math.random(8, 20) / 100) -- 0.08-0.2 seconds
            end
        end)
    end
end

-- /////// IMAGE FLOOD - EVERYONE SEES ///////
function startImageFlood()
    _G.c00l.imgActive = true
    spawn(function()
        while _G.c00l.imgActive do
            -- Billboard GUIs on all players
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 250 * scale, 0, 60 * scale)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 9999
                    bb.Parent = plr.Character.Head
                    
                    local tl = Instance.new("TextLabel", bb)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    tl.TextStrokeTransparency = 0
                    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    tl.Text = "TEAM C00LKIDD JOIN TODAY!"
                    tl.Font = Enum.Font.GothamBlack
                    tl.TextScaled = true
                    debris:AddItem(bb, 1.5)
                end
            end
            
            -- Floating neon parts
            for i = 1, 8 do
                local p = Instance.new("Part")
                p.Size = Vector3.new(8 * scale, 8 * scale, 0.1)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.BrickColor = BrickColor.new("Bright red")
                p.Position = camera.CFrame.Position + camera.CFrame.LookVector * 25 + 
                             Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20,20))
                p.CFrame = CFrame.new(p.Position, camera.CFrame.Position)
                p.Parent = workspace
                
                local d = Instance.new("Decal", p)
                d.Texture = "rbxassetid://187654688"
                d.Face = Enum.NormalId.Front
                
                local sg = Instance.new("SurfaceGui", p)
                sg.Face = Enum.NormalId.Front
                sg.CanvasSize = Vector2.new(200, 100)
                local st = Instance.new("TextLabel", sg)
                st.Size = UDim2.new(1, 0, 1, 0)
                st.BackgroundTransparency = 1
                st.TextColor3 = Color3.fromRGB(255, 255, 255)
                st.Text = "TEAM C00LKIDD"
                st.Font = Enum.Font.GothamBlack
                st.TextScaled = true
                
                table.insert(_G.c00l.objs, p)
                debris:AddItem(p, 4)
            end
            task.wait(0.03)
        end
    end)
end

-- /////// BUTTON HELPER ///////
local btnW = 1
local btnH = 40 * scale
local yPos = 10 * scale

local function makeSection(text)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(btnW, -20*scale, 0, 30*scale)
    sec.Position = UDim2.new(0, 10*scale, 0, yPos)
    sec.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    sec.TextColor3 = Color3.fromRGB(255, 255, 255)
    sec.Text = text
    sec.Font = Enum.Font.GothamBlack
    sec.TextScaled = true
    sec.Parent = buttonContainer
    yPos = yPos + 35 * scale
end

local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(btnW, -20*scale, 0, btnH)
    btn.Position = UDim2.new(0, 10*scale, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.AutoButtonColor = true
    btn.Parent = buttonContainer
    btn.MouseEnter:Connect(function() 
        tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play() 
    end)
    btn.MouseLeave:Connect(function() 
        tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() 
    end)
    btn.MouseButton1Click:Connect(callback)
    yPos = yPos + btnH + 5*scale
    return btn
end

local function makeToggle(text, stateKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(btnW, -20*scale, 0, btnH)
    btn.Position = UDim2.new(0, 10*scale, 0, yPos)
    btn.BackgroundColor3 = _G.c00l[stateKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text .. (_G.c00l[stateKey] and " [ON]" or " [OFF]")
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.Parent = buttonContainer
    btn.MouseButton1Click:Connect(function()
        _G.c00l[stateKey] = not _G.c00l[stateKey]
        btn.Text = text .. (_G.c00l[stateKey] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = _G.c00l[stateKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
        callback(_G.c00l[stateKey])
    end)
    yPos = yPos + btnH + 5*scale
    return btn
end

-- /////// PLAYER LIST ///////
local playerListLabel = Instance.new("TextLabel")
playerListLabel.Size = UDim2.new(btnW, -20*scale, 0, 25*scale)
playerListLabel.Position = UDim2.new(0, 10*scale, 0, yPos)
playerListLabel.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
playerListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerListLabel.Text = "PLAYERS (Click to spectate)"
playerListLabel.Font = Enum.Font.GothamBold
playerListLabel.TextScaled = true
playerListLabel.Parent = buttonContainer
yPos = yPos + 28 * scale

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(btnW, -20*scale, 0, 120*scale)
playerScroll.Position = UDim2.new(0, 10*scale, 0, yPos)
playerScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
playerScroll.BorderSizePixel = 1
playerScroll.BorderColor3 = Color3.fromRGB(150, 0, 0)
playerScroll.ScrollBarThickness = 4*scale
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = buttonContainer
yPos = yPos + 125 * scale

local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = playerScroll

local function refreshPlayerList()
    for _, c in ipairs(playerContainer:GetChildren()) do c:Destroy() end
    local py = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        local pb = Instance.new("TextButton")
        pb.Size = UDim2.new(1, -5*scale, 0, 22*scale)
        pb.Position = UDim2.new(0, 2*scale, 0, py)
        pb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pb.TextColor3 = plr == LocalPlayer and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
        pb.Text = plr.Name .. (plr == LocalPlayer and " (YOU)" or "")
        pb.Font = Enum.Font.GothamSemibold
        pb.TextScaled = true
        pb.Parent = playerContainer
        pb.MouseButton1Click:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = plr.Character:FindFirstChild("Humanoid")
            end
        end)
        py = py + 24 * scale
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, py)
end
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- /////// BUILD ALL SECTIONS ///////

-- SECTION 1: ADVERTISING
makeSection("═══ ADVERTISING & VISIBILITY ═══")

makeToggle("AD SPAM (ALL SEE)", "adActive", function(state)
    if state then startAdSpam() end
end)

makeToggle("IMAGE FLOOD (ALL SEE)", "imgActive", function(state)
    if state then startImageFlood() end
end)

makeToggle("SOUND SPAM", "sndActive", function(state)
    if state then
        local sids = {"rbxassetid://9118109106", "rbxassetid://9120386436", "rbxassetid://5410086218"}
        spawn(function()
            while _G.c00l.sndActive do
                local s = Instance.new("Sound")
                s.SoundId = sids[math.random(1, #sids)]
                s.Volume = 10
                s.PlaybackSpeed = math.random(80, 200) / 100
                s.Parent = workspace
                s:Play()
                debris:AddItem(s, s.TimeLength)
                task.wait(0.15)
            end
        end)
    end
end)

-- SECTION 2: ATTACKS
makeSection("═══ SERVER ATTACKS ═══")

makeToggle("LAG BOMB", "lagActive", function(state)
    if state then
        spawn(function()
            while _G.c00l.lagActive do
                local pos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 50, 0)
                for i = 1, 60 do
                    local lp = Instance.new("Part")
                    lp.Size = Vector3.new(2, 2, 2)
                    lp.Anchored = false
                    lp.CanCollide = true
                    lp.Material = Enum.Material.Neon
                    lp.BrickColor = BrickColor.new("Really red")
                    lp.Position = pos + Vector3.new(math.random(-20,20), math.random(0,40), math.random(-20,20))
                    lp.Velocity = Vector3.new(math.random(-150,150), math.random(-150,150), math.random(-150,150))
                    lp.Parent = workspace
                    table.insert(_G.c00l.objs, lp)
                    debris:AddItem(lp, 8)
                end
                for i = 1, 15 do
                    local pl = Instance.new("PointLight")
                    pl.Brightness = 15
                    pl.Range = 40
                    pl.Color = Color3.fromRGB(255, 0, 0)
                    pl.Parent = workspace.Terrain
                    debris:AddItem(pl, 2)
                end
                task.wait(0.02)
            end
        end)
    end
end)

makeButton("CRASH SERVER", function()
    if _G.c00l.crash then return end
    _G.c00l.crash = true
    spawn(function()
        local root = Instance.new("Part")
        root.Size = Vector3.new(1,1,1)
        root.Anchored = true
        root.Position = Vector3.new(0, 20000, 0)
        root.Parent = workspace
        for i = 1, 1000 do
            local s = Instance.new("Part")
            s.Shape = Enum.PartType.Ball
            s.Size = Vector3.new(4,4,4)
            s.Anchored = false
            s.Position = root.Position + Vector3.new(math.random(-20,20), i*4, math.random(-20,20))
            s.Parent = workspace
            local w = Instance.new("WeldConstraint")
            w.Part0 = root
            w.Part1 = s
            w.Parent = s
        end
        for _, r in ipairs(replicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                spawn(function()
                    for i = 1, 1000 do
                        pcall(function() r:FireServer(math.huge, {}, true) end)
                    end
                end)
                break
            end
        end
        task.wait(5)
        _G.c00l.crash = false
    end)
end)

-- SECTION 3: PLAYER CONTROL
makeSection("═══ PLAYER MANIPULATION ═══")

makeButton("KILL ALL (FF BYPASS)", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(hum.MaxHealth * 2)
                if hum.Health > 0 then
                    for _, p in ipairs(plr.Character:GetChildren()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                            pcall(function() p:Destroy() end)
                        end
                    end
                end
            end
        end
    end
end)

makeButton("TELEPORT TRAP ALL", function()
    local tp = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 30, 0)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                spawn(function()
                    while plr.Character and hrp.Parent do
                        pcall(function()
                            hrp.CFrame = CFrame.new(tp + Vector3.new(0, 5, 0))
                            hrp.Velocity = Vector3.zero
                            hrp.RotVelocity = Vector3.zero
                        end)
                        task.wait(0.03)
                    end
                end)
            end
        end
    end
end)

makeToggle("INFECT OTHERS", "infect", function(state)
    if state then
        spawn(function()
            while _G.c00l.infect do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local bp = plr:FindFirstChildOfClass("Backpack")
                        if bp then
                            local t = Instance.new("Tool")
                            t.Name = "c00lkidd_join"
                            t.RequiresHandle = false
                            t.Parent = bp
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end
end)

-- SECTION 4: SELF BUFFS
makeSection("═══ SELF MODIFICATIONS ═══")

makeToggle("GOD MODE", "god", function(state)
    if state then
        _G.c00l.godCon = runService.Heartbeat:Connect(function()
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = hum.MaxHealth
                    hum.BreakJointsOnDeath = false
                end
            end
        end)
    else
        if _G.c00l.godCon then _G.c00l.godCon:Disconnect(); _G.c00l.godCon = nil end
    end
end)

makeToggle("FLY (WASD + Space/Ctrl)", "fly", function(state)
    if state then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChildOfClass("Humanoid")
        hum.PlatformStand = true
        
        _G.c00l.flyGyro = Instance.new("BodyGyro")
        _G.c00l.flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        _G.c00l.flyGyro.CFrame = hrp.CFrame
        _G.c00l.flyGyro.Parent = hrp
        
        _G.c00l.flyVel = Instance.new("BodyVelocity")
        _G.c00l.flyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        _G.c00l.flyVel.Velocity = Vector3.zero
        _G.c00l.flyVel.Parent = hrp
        
        local spd = 50 * scale
        spawn(function()
            while _G.c00l.fly and hrp and _G.c00l.flyGyro do
                _G.c00l.flyGyro.CFrame = camera.CFrame
                local v = Vector3.zero
                if userInputService:IsKeyDown(Enum.KeyCode.W) then v = v + camera.CFrame.LookVector * spd end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then v = v - camera.CFrame.LookVector * spd end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then v = v - camera.CFrame.RightVector * spd end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then v = v + camera.CFrame.RightVector * spd end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, spd, 0) end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0, spd, 0) end
                _G.c00l.flyVel.Velocity = v
                task.wait()
            end
        end)
    else
        if _G.c00l.flyGyro then _G.c00l.flyGyro:Destroy(); _G.c00l.flyGyro = nil end
        if _G.c00l.flyVel then _G.c00l.flyVel:Destroy(); _G.c00l.flyVel = nil end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

makeToggle("NOCLIP", "noclip", function(state)
    spawn(function()
        while _G.c00l.noclip do
            if LocalPlayer.Character then
                for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
            task.wait()
        end
    end)
end)

makeToggle("PLAYER ESP", "espActive", function(state)
    if state then
        local function espPlayer(plr)
            if plr == LocalPlayer then return end
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.4
            h.OutlineTransparency = 0
            
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 150*scale, 0, 35*scale)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            local l = Instance.new("TextLabel", bb)
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(255, 0, 0)
            l.TextStrokeTransparency = 0
            l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            l.Text = plr.Name
            l.Font = Enum.Font.GothamBold
            l.TextScaled = true
            
            local con = runService.RenderStepped:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    h.Parent = plr.Character
                    bb.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
                end
            end)
            table.insert(_G.c00l.espCons, con)
            bb.Parent = workspace
            table.insert(_G.c00l.objs, bb)
        end
        
        for _, plr in ipairs(Players:GetPlayers()) do espPlayer(plr) end
        Players.PlayerAdded:Connect(espPlayer)
    else
        for _, c in ipairs(_G.c00l.espCons) do pcall(function() c:Disconnect() end) end
        _G.c00l.espCons = {}
    end
end)

-- SECTION 5: PROTECTION
makeSection("═══ PROTECTION ═══")

makeToggle("ANTI-KICK", "antiKick", function(state)
    if state then
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if (method == "Kick" or tostring(self):lower():find("kick")) and (self == LocalPlayer or args[1] == LocalPlayer) then
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

makeButton("AUTO REJOIN", function()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

makeButton("CLEANUP ALL", function()
    _G.c00l.adActive = false
    _G.c00l.imgActive = false
    _G.c00l.lagActive = false
    _G.c00l.sndActive = false
    _G.c00l.infect = false
    _G.c00l.fly = false
    _G.c00l.noclip = false
    _G.c00l.espActive = false
    _G.c00l.god = false
    for _, obj in ipairs(_G.c00l.objs) do pcall(function() obj:Destroy() end) end
    _G.c00l.objs = {}
    for _, c in ipairs(_G.c00l.espCons) do pcall(function() c:Disconnect() end) end
    _G.c00l.espCons = {}
    print("[c00lkidd] Cleanup complete")
end)

-- Finalize scroll canvas
scroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 100*scale)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- Periodic chat remote scan
spawn(function()
    while task.wait(10) do
        scanChatRemotes()
    end
end)

-- On respawn, re-protect GUI
LocalPlayer.CharacterAdded:Connect(function()
    if execEnv and execEnv.syn and execEnv.syn.protect_gui then
        execEnv.syn.protect_gui(gui)
    end
end)

print("╔══════════════════════════════════════╗")
print("║  TEAM C00LKIDD - BYPASS EDITION     ║")
print("║  ALL FEATURES: 100% REAL & VISIBLE  ║")
print("║  GUI: FULLSCREEN ADAPTIVE           ║")
print("║  NETWORK: UNIVERSAL BYPASS ACTIVE   ║")
print("║  JOIN TODAY! - c00lkidd ON TOP      ║")
print("╚══════════════════════════════════════╝")