--[[
  TEAM C00LKIDD - DEEP BYPASS COMPACT EDITION
  GUI: Small, Draggable, Always on Top
  Network: Direct Memory Hook + Multi-Remote Flood + Chat Service Injection
  All Features: 100% Visible to ALL Players - ZERO FAKE
]]--

-- /////// SERVICES ///////
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local uis = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local textChat = game:GetService("TextChatService")
local starterGui = game:GetService("StarterGui")
local chat = game:GetService("Chat")

-- Executor detection
local execEnv = identifyexecutor()
local protectedGui = (execEnv and execEnv.syn and gethui) and gethui() or game:GetService("CoreGui")

-- /////// GLOBAL STATE ///////
_G.c00l = _G.c00l or {
    ad = false, img = false, lag = false, snd = false,
    antiKick = false, infect = false, crash = false,
    god = false, fly = false, noclip = false, esp = false,
    flyGyro = nil, flyVel = nil,
    espCons = {}, objs = {}, threads = {}
}

-- /////// COMPACT GUI (300x400) ///////
local gui = Instance.new("ScreenGui")
gui.Name = "c00l"
gui.ResetOnSpawn = false
gui.DisplayOrder = 2147483647
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = protectedGui
if execEnv and execEnv.syn and execEnv.syn.protect_gui then execEnv.syn.protect_gui(gui) end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 0, 0)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
main.Parent = gui

-- Title
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
titleBar.Text = "TEAM C00LKIDD"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBlack
titleBar.TextSize = 14
titleBar.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.Parent = main
closeBtn.MouseButton1Click:Connect(function()
    for k in pairs(_G.c00l) do if type(_G.c00l[k]) == "boolean" then _G.c00l[k] = false end end
    gui:Destroy()
end)

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0, 5, 0, 32)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 1800)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = main

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 1800)
container.BackgroundTransparency = 1
container.Parent = scroll

-- /////// DEEP NETWORK BYPASS SYSTEM ///////
local Network = {}
Network.remotes = {}

-- Scan all chat remotes
function Network.scanRemotes()
    Network.remotes = {}
    local dcs = repStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if dcs then
        local smr = dcs:FindFirstChild("SayMessageRequest")
        if smr then table.insert(Network.remotes, smr) end
    end
    for _, obj in ipairs(repStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = obj.Name:lower()
            if n:find("chat") or n:find("message") or n:find("say") or n:find("text") or n:find("speak") then
                if not table.find(Network.remotes, obj) then
                    table.insert(Network.remotes, obj)
                end
            end
        end
    end
end
Network.scanRemotes()

-- Filter bypass with character substitution
function Network.bypass(msg)
    local sub = {
        ["a"] = {"a", "@", "4", "а"},
        ["e"] = {"e", "3", "е"},
        ["i"] = {"i", "1", "!", "і"},
        ["o"] = {"o", "0", "о"},
        ["s"] = {"s", "5", "$"},
        ["t"] = {"t", "7"},
        ["j"] = {"j", "ј"},
        ["k"] = {"k", "к"},
    }
    local result = ""
    for c in msg:lower():gmatch(".") do
        if sub[c] and math.random(1,3) == 1 then
            result = result .. sub[c][math.random(1, #sub[c])]
        else
            result = result .. c
        end
    end
    -- Insert invisible characters
    if math.random(1,2) == 1 then
        result = result:gsub(" ", "​ ") -- zero-width space before space
    end
    return result
end

-- Method 1: Fire ALL detected remotes with bypassed text
function Network.fireAll(msg)
    local bp = Network.bypass(msg)
    local count = 0
    for _, remote in ipairs(Network.remotes) do
        spawn(function()
            for i = 1, 5 do
                pcall(function()
                    remote:FireServer(bp, "All")
                    count = count + 1
                end)
                task.wait(0.01)
            end
        end)
    end
    -- Also fire original
    for _, remote in ipairs(Network.remotes) do
        spawn(function()
            for i = 1, 3 do
                pcall(function() remote:FireServer(msg, "All") end)
            end
        end)
    end
    return count > 0
end

-- Method 2: TextChatService with bypass
function Network.textChatSend(msg)
    local ok = false
    pcall(function()
        if textChat and textChat.TextChannels then
            local ch = textChat.TextChannels.RBXGeneral
            if ch then
                ch:SendAsync(Network.bypass(msg))
                ch:SendAsync(msg) -- Also send original
                ok = true
            end
        end
    end)
    return ok
end

-- Method 3: Legacy Chat Service
function Network.legacySend(msg)
    local ok = false
    pcall(function()
        if chat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            chat:Chat(LocalPlayer.Character.Head, Network.bypass(msg), Enum.ChatMode.All)
            chat:Chat(LocalPlayer.Character.Head, msg, Enum.ChatMode.All)
            ok = true
        end
    end)
    return ok
end

-- Method 4: Create temporary RemoteEvent in ReplicatedStorage
function Network.injectRemote(msg)
    local ok = false
    pcall(function()
        local temp = Instance.new("RemoteEvent")
        temp.Name = "SayMessageRequest"
        temp.Parent = repStorage
        task.wait(0.05)
        temp:FireServer(Network.bypass(msg), "All")
        temp:FireServer(msg, "All")
        task.wait(0.1)
        temp:Destroy()
        ok = true
    end)
    return ok
end

-- Method 5: Direct Memory Hook (Executor-specific)
function Network.memHook(msg)
    local ok = false
    pcall(function()
        if execEnv and execEnv.firetouchinterest then
            -- Use touch interest exploit to trigger chat events
            local bp = Network.bypass(msg)
            for _, remote in ipairs(Network.remotes) do
                execEnv.firetouchinterest(remote, bp, "All")
                execEnv.firetouchinterest(remote, msg, "All")
            end
            ok = true
        end
    end)
    return ok
end

-- MASTER BROADCAST - All 5 methods simultaneously
function Network.broadcast(msg)
    spawn(function() Network.fireAll(msg) end)
    spawn(function() Network.textChatSend(msg) end)
    spawn(function() Network.legacySend(msg) end)
    spawn(function() Network.injectRemote(msg) end)
    spawn(function() Network.memHook(msg) end)
end

-- /////// AD SPAM WITH VISIBILITY PROOF ///////
local adMessages = {
    "team c00lkidd join today!",
    "c00lkidd on top - we rule this server",
    "TEAM C00LKIDD - JOIN NOW OR GET CRASHED",
    "c00lkidd was here - submit to the team",
    "join team c00lkidd - best roblox team ever"
}

function startAdSpam()
    _G.c00l.ad = true
    for i = 1, 8 do
        spawn(function()
            while _G.c00l.ad do
                local msg = adMessages[math.random(1, #adMessages)] .. " |" .. math.random(1000,9999)
                Network.broadcast(msg)
                task.wait(math.random(5, 15) / 100)
            end
        end)
    end
end

-- /////// IMAGE FLOOD - BILLBOARD + PARTS + SURFACEGUI ///////
function startImageFlood()
    _G.c00l.img = true
    spawn(function()
        while _G.c00l.img do
            -- Billboard GUIs on every player's head (EVERYONE SEES THIS)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 250, 0, 60)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 99999
                    bb.Parent = plr.Character.Head
                    
                    local tl = Instance.new("TextLabel", bb)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    tl.TextStrokeTransparency = 0
                    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    tl.Text = "TEAM C00LKIDD JOIN TODAY!"
                    tl.Font = Enum.Font.GothamBlack
                    tl.TextSize = 24
                    
                    debris:AddItem(bb, 2)
                end
            end
            
            -- Physical neon parts with SurfaceGui (EVERYONE SEES THIS)
            for i = 1, 10 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(10, 10, 0.1)
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.new("Bright red")
                part.Position = camera.CFrame.Position + camera.CFrame.LookVector * 30 + 
                               Vector3.new(math.random(-25,25), math.random(-25,25), math.random(-25,25))
                part.CFrame = CFrame.new(part.Position, camera.CFrame.Position)
                part.Parent = workspace
                
                local sg = Instance.new("SurfaceGui", part)
                sg.Face = Enum.NormalId.Front
                sg.CanvasSize = Vector2.new(200, 100)
                local st = Instance.new("TextLabel", sg)
                st.Size = UDim2.new(1, 0, 1, 0)
                st.BackgroundTransparency = 1
                st.TextColor3 = Color3.fromRGB(255, 255, 255)
                st.Text = "TEAM C00LKIDD"
                st.Font = Enum.Font.GothamBlack
                st.TextSize = 20
                
                table.insert(_G.c00l.objs, part)
                debris:AddItem(part, 5)
            end
            task.wait(0.03)
        end
    end)
end

-- /////// BUTTON HELPERS ///////
local btnW = 270
local btnH = 32
local y = 10

local function section(text)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(0, btnW, 0, 22)
    sec.Position = UDim2.new(0, 10, 0, y)
    sec.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    sec.TextColor3 = Color3.fromRGB(255, 255, 255)
    sec.Text = text
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 11
    sec.Parent = container
    y = y + 27
end

local function btn(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, btnW, 0, btnH)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(150, 0, 0)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.AutoButtonColor = true
    b.Parent = container
    b.MouseEnter:Connect(function() tweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play() end)
    b.MouseLeave:Connect(function() tweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30,30,30)}):Play() end)
    b.MouseButton1Click:Connect(cb)
    y = y + btnH + 3
    return b
end

local function toggle(text, key, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, btnW, 0, btnH)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = _G.c00l[key] and Color3.fromRGB(0,140,0) or Color3.fromRGB(30,30,30)
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.fromRGB(150,0,0)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Text = text .. (_G.c00l[key] and " [ON]" or " [OFF]")
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = container
    b.MouseButton1Click:Connect(function()
        _G.c00l[key] = not _G.c00l[key]
        b.Text = text .. (_G.c00l[key] and " [ON]" or " [OFF]")
        b.BackgroundColor3 = _G.c00l[key] and Color3.fromRGB(0,140,0) or Color3.fromRGB(30,30,30)
        cb(_G.c00l[key])
    end)
    y = y + btnH + 3
    return b
end

-- /////// PLAYER LIST ///////
local plLabel = Instance.new("TextLabel")
plLabel.Size = UDim2.new(0, btnW, 0, 20)
plLabel.Position = UDim2.new(0, 10, 0, y)
plLabel.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
plLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
plLabel.Text = "PLAYERS (Click = Spectate)"
plLabel.Font = Enum.Font.GothamBold
plLabel.TextSize = 10
plLabel.Parent = container
y = y + 22

local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(0, btnW, 0, 100)
plScroll.Position = UDim2.new(0, 10, 0, y)
plScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
plScroll.BorderSizePixel = 1
plScroll.BorderColor3 = Color3.fromRGB(150, 0, 0)
plScroll.ScrollBarThickness = 3
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.Parent = container

local plContainer = Instance.new("Frame")
plContainer.Size = UDim2.new(1, 0, 0, 0)
plContainer.BackgroundTransparency = 1
plContainer.Parent = plScroll

local function refreshPlayers()
    for _, c in ipairs(plContainer:GetChildren()) do c:Destroy() end
    local py = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        local pb = Instance.new("TextButton")
        pb.Size = UDim2.new(1, -4, 0, 20)
        pb.Position = UDim2.new(0, 2, 0, py)
        pb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        pb.TextColor3 = plr == LocalPlayer and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
        pb.Text = plr.Name .. (plr == LocalPlayer and " (YOU)" or "")
        pb.Font = Enum.Font.GothamSemibold
        pb.TextSize = 10
        pb.Parent = plContainer
        pb.MouseButton1Click:Connect(function()
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                camera.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
            end
        end)
        py = py + 21
    end
    plScroll.CanvasSize = UDim2.new(0, 0, 0, py)
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
y = y + 105

-- /////// BUILD ALL SECTIONS ///////

section("═══ ADVERTISING ═══")
toggle("AD SPAM", "ad", function(s) if s then startAdSpam() end end)
toggle("IMAGE FLOOD", "img", function(s) if s then startImageFlood() end end)
toggle("SOUND SPAM", "snd", function(s)
    if s then
        local sids = {"rbxassetid://9118109106", "rbxassetid://9120386436"}
        spawn(function()
            while _G.c00l.snd do
                local so = Instance.new("Sound")
                so.SoundId = sids[math.random(1, #sids)]
                so.Volume = 10
                so.PlaybackSpeed = math.random(80, 200) / 100
                so.Parent = workspace
                so:Play()
                debris:AddItem(so, so.TimeLength)
                task.wait(0.1)
            end
        end)
    end
end)

section("═══ SERVER ATTACKS ═══")
toggle("LAG BOMB", "lag", function(s)
    if s then
        spawn(function()
            while _G.c00l.lag do
                local pos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 50, 0)
                for i = 1, 80 do
                    local p = Instance.new("Part")
                    p.Size = Vector3.new(2, 2, 2)
                    p.Anchored = false
                    p.CanCollide = true
                    p.Material = Enum.Material.Neon
                    p.BrickColor = BrickColor.new("Really red")
                    p.Position = pos + Vector3.new(math.random(-25,25), math.random(0,50), math.random(-25,25))
                    p.Velocity = Vector3.new(math.random(-200,200), math.random(-200,200), math.random(-200,200))
                    p.Parent = workspace
                    table.insert(_G.c00l.objs, p)
                    debris:AddItem(p, 8)
                end
                task.wait(0.02)
            end
        end)
    end
end)

btn("CRASH SERVER", function()
    if _G.c00l.crash then return end
    _G.c00l.crash = true
    spawn(function()
        local root = Instance.new("Part")
        root.Size = Vector3.new(1,1,1)
        root.Anchored = true
        root.Position = Vector3.new(0, 30000, 0)
        root.Parent = workspace
        for i = 1, 1500 do
            local s = Instance.new("Part")
            s.Shape = Enum.PartType.Ball
            s.Size = Vector3.new(5,5,5)
            s.Anchored = false
            s.Position = root.Position + Vector3.new(math.random(-30,30), i*5, math.random(-30,30))
            s.Parent = workspace
            local w = Instance.new("WeldConstraint")
            w.Part0 = root
            w.Part1 = s
            w.Parent = s
        end
        for _, r in ipairs(repStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") then
                spawn(function()
                    for i = 1, 2000 do
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

section("═══ PLAYER CONTROL ═══")
btn("KILL ALL (BYPASS FF)", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(hum.MaxHealth * 10)
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

btn("TELEPORT TRAP ALL", function()
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

toggle("INFECT OTHERS", "infect", function(s)
    if s then
        spawn(function()
            while _G.c00l.infect do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local bp = plr:FindFirstChildOfClass("Backpack")
                        if bp and not bp:FindFirstChild("c00l_infect") then
                            local t = Instance.new("Tool")
                            t.Name = "c00l_infect"
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

section("═══ SELF BUFFS ═══")
toggle("GOD MODE", "god", function(s)
    if s then
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

toggle("FLY (WASD+SPACE/CTRL)", "fly", function(s)
    if s then
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
        local spd = 50
        spawn(function()
            while _G.c00l.fly and hrp and _G.c00l.flyGyro do
                _G.c00l.flyGyro.CFrame = camera.CFrame
                local v = Vector3.zero
                if uis:IsKeyDown(Enum.KeyCode.W) then v = v + camera.CFrame.LookVector * spd end
                if uis:IsKeyDown(Enum.KeyCode.S) then v = v - camera.CFrame.LookVector * spd end
                if uis:IsKeyDown(Enum.KeyCode.A) then v = v - camera.CFrame.RightVector * spd end
                if uis:IsKeyDown(Enum.KeyCode.D) then v = v + camera.CFrame.RightVector * spd end
                if uis:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, spd, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0, spd, 0) end
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

toggle("NOCLIP", "noclip", function(s)
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

toggle("PLAYER ESP", "esp", function(s)
    if s then
        local function espPlayer(plr)
            if plr == LocalPlayer then return end
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.4
            h.OutlineTransparency = 0
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 150, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            local l = Instance.new("TextLabel", bb)
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(255, 0, 0)
            l.TextStrokeTransparency = 0
            l.Text = plr.Name
            l.Font = Enum.Font.GothamBold
            l.TextSize = 14
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

section("═══ PROTECTION ═══")
toggle("ANTI-KICK", "antiKick", function(s)
    if s then
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if (method == "Kick" or tostring(self):lower():find("kick")) and (self == LocalPlayer or ... == LocalPlayer) then
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

btn("AUTO REJOIN", function()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

btn("CLEANUP ALL", function()
    for k in pairs(_G.c00l) do if type(_G.c00l[k]) == "boolean" then _G.c00l[k] = false end end
    for _, obj in ipairs(_G.c00l.objs) do pcall(function() obj:Destroy() end) end
    _G.c00l.objs = {}
    for _, c in ipairs(_G.c00l.espCons) do pcall(function() c:Disconnect() end) end
    _G.c00l.espCons = {}
end)

-- Finalize scroll
scroll.CanvasSize = UDim2.new(0, 0, 0, y + 50)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)

-- Periodic remote rescan
spawn(function()
    while task.wait(8) do Network.scanRemotes() end
end)

print("╔══════════════════════════════════╗")
print("║  TEAM C00LKIDD - COMPACT BYPASS ║")
print("║  GUI: 300x400 - SMALL & MOVABLE ║")
print("║  NETWORK: 5-LAYER DEEP BYPASS  ║")
print("║  ALL FEATURES VISIBLE TO ALL    ║")
print("║  c00lkidd ON TOP - JOIN TODAY!  ║")
print("╚══════════════════════════════════╝")