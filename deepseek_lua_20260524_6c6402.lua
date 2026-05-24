--[[
    Universal Roblox Exploit Scanner & Auto-Executor
    Tự động quét tất cả lỗ hổng phổ biến và thực thi khai thác
--]]

-- ===== CONFIGURATION =====
local CONFIG = {
    autoExecute = true,
    scanInterval = 3,          -- Thời gian giữa các lần quét (giây)
    targetPlayer = "all",      -- "all" = tất cả người chơi
    bypassMethods = {
        hookDetour = true,     -- Hook và redirect function
        namecallBypass = true, -- Bypass __namecall
        indexBypass = true,    -- Bypass __index
        antiKick = true,       -- Chống kick khỏi game
        antiBan = true,        -- Chống ban
        antiCrash = true,      -- Chống crash client
    },
    logLevel = "ALL",         -- "ALL", "EXPLOITS", "CRITICAL"
}

-- ===== INITIAL SETUP =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ===== BYPASS SANDBOX (Phase 1: Environment Hook) =====
local function setupEnvironmentBypass()
    local success = pcall(function()
        -- Hook __index để bypass bảo vệ
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        
        mt.__index = newcclosure(function(self, key)
            if key == "Name" and self == LocalPlayer then
                return LocalPlayer.Name
            end
            return oldIndex(self, key)
        end)
        
        -- Hook __namecall để bypass anticheat
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Bypass Kick
            if method == "Kick" and CONFIG.bypassMethods.antiKick then
                return nil
            end
            
            -- Bypass các hàm kiểm tra cheat
            if string.find(string.lower(method), "ban") or 
               string.find(string.lower(method), "detect") or
               string.find(string.lower(method), "check") then
                return false
            end
            
            return oldNamecall(self, unpack(args))
        end)
        
        setreadonly(mt, true)
    end)
    
    return success
end

-- ===== UTILITY FUNCTIONS =====
local function notify(title, text, duration)
    duration = duration or 5
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration,
        })
    end)
end

local function findInGame(keywords, caseSensitive)
    caseSensitive = caseSensitive or false
    local results = {}
    
    local function search(obj)
        for _, child in ipairs(obj:GetChildren()) do
            local name = caseSensitive and child.Name or string.lower(child.Name)
            for _, kw in ipairs(keywords) do
                local searchKw = caseSensitive and kw or string.lower(kw)
                if string.find(name, searchKw) then
                    table.insert(results, {
                        object = child,
                        name = child.Name,
                        path = child:GetFullName(),
                        className = child.ClassName,
                        matchedKeyword = kw,
                    })
                end
            end
            if #child:GetChildren() > 0 then
                search(child)
            end
        end
    end
    
    search(game)
    return results
end

-- ===== EXPLOIT MODULES =====
local UniversalExploits = {}

-- 1. Anti-Kick / Anti-Ban
function UniversalExploits.antiKickAndBan()
    if not CONFIG.bypassMethods.antiKick then return end
    
    -- Method 1: Hook Kick function
    pcall(function()
        local oldKick = LocalPlayer.Kick
        LocalPlayer.Kick = function(...) return end
    end)
    
    -- Method 2: Disconnect detection
    pcall(function()
        game:GetService("Players").PlayerRemoving:Connect(function(player)
            if player == LocalPlayer then
                -- Ngăn disconnect
                while true do
                    pcall(function()
                        LocalPlayer:LoadCharacter()
                    end)
                    wait(0.1)
                end
            end
        end)
    end)
end

-- 2. Teleport System
function UniversalExploits.teleportTo(target)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    if typeof(target) == "Vector3" then
        rootPart.CFrame = CFrame.new(target)
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        rootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
    elseif typeof(target) == "string" then
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                rootPart.CFrame = targetRoot.CFrame
            end
        end
    end
end

-- 3. Speed / Jump / Fly Exploit
function UniversalExploits.movementExploit()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    pcall(function()
        humanoid.WalkSpeed = 100
        humanoid.JumpPower = 200
        humanoid.HipHeight = 10
    end)
    
    -- Fly exploit
    local function enableFly()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.velocity = Vector3.new(0, 0, 0)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = rootPart
        
        spawn(function()
            while wait() do
                if not character or not character.Parent then break end
                
                local flying = false
                local speed = 50
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    bodyVelocity.velocity = Vector3.new(0, speed, 0)
                    flying = true
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    bodyVelocity.velocity = Vector3.new(0, -speed, 0)
                    flying = true
                end
                
                -- WASD movement
                local moveDirection = Vector3.new(0, 0, 0)
                local camera = workspace.CurrentCamera
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                
                if moveDirection.Magnitude > 0 then
                    bodyVelocity.velocity = moveDirection.Unit * speed
                    flying = true
                end
                
                if flying then
                    bodyGyro.cframe = camera.CFrame
                    humanoid.PlatformStand = true
                else
                    bodyVelocity.velocity = Vector3.new(0, 0, 0)
                    humanoid.PlatformStand = false
                end
            end
        end)
    end
    
    pcall(enableFly)
end

-- 4. Item/Currency Duplication & Modification
function UniversalExploits.economyExploit()
    local moneyKeywords = {
        "Money", "Coins", "Gems", "Cash", "Points", "Gold", 
        "Diamond", "Credit", "Currency", "Value", "Balance",
        "Wins", "Kills", "Level", "XP", "Experience"
    }
    
    local values = findInGame(moneyKeywords)
    
    for _, item in ipairs(values) do
        local obj = item.object
        pcall(function()
            if obj:IsA("IntValue") then
                obj.Value = 999999999
                notify("Economy Exploit", item.name .. " set to 999999999", 3)
            elseif obj:IsA("NumberValue") then
                obj.Value = 999999999
                notify("Economy Exploit", item.name .. " set to 999999999", 3)
            elseif obj:IsA("StringValue") and tonumber(obj.Value) then
                obj.Value = "999999999"
                notify("Economy Exploit", item.name .. " set to 999999999", 3)
            end
        end)
    end
    
    -- Clone valuable items
    for _, tool in ipairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") then
            pcall(function()
                local clone = tool:Clone()
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    clone.Parent = backpack
                    notify("Item Duplication", "Cloned: " .. tool.Name, 3)
                end
            end)
        end
    end
end

-- 5. Remote Fuzzer (Fire tất cả remote với payload)
function UniversalExploits.remoteFuzzer()
    local remotes = {}
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(remotes, v)
        end
    end
    
    local payloads = {
        "", nil, true, false, 0, 999999, -999999,
        "admin", "true", "false", "1 OR 1=1",
        game, LocalPlayer, workspace,
        {}, {1, 2, 3}, Vector3.new(0, 0, 0),
        CFrame.new(), Color3.new(1, 1, 1),
        LocalPlayer.Character,
    }
    
    for _, remote in ipairs(remotes) do
        for _, payload in ipairs(payloads) do
            spawn(function()
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(payload)
                    else
                        local result = remote:InvokeServer(payload)
                        if result then
                            notify("Remote Exploit", remote.Name .. " returned: " .. tostring(result), 3)
                        end
                    end
                end)
            end)
        end
    end
end

-- 6. ESP / Wallhack
function UniversalExploits.enableESP()
    local function createESP(player)
        if player == LocalPlayer then return end
        
        spawn(function()
            while player and player.Parent do
                local character = player.Character
                if character then
                    local head = character:FindFirstChild("Head")
                    if head and not head:FindFirstChild("ESP_Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Highlight"
                        highlight.FillColor = Color3.new(1, 0, 0)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                        highlight.OutlineTransparency = 0
                        highlight.Parent = head
                        highlight.Adornee = head
                    end
                end
                wait(1)
            end
        end)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
    
    Players.PlayerAdded:Connect(createESP)
end

-- 7. Auto-Farm / Auto-Clicker
function UniversalExploits.autoFarm()
    -- Tìm các nút bấm, clickable objects
    local clickables = {}
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ClickDetector") or v:IsA("ProximityPrompt") then
            table.insert(clickables, v)
        end
        
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            table.insert(clickables, v)
        end
    end
    
    spawn(function()
        while wait(0.1) do
            for _, clickable in ipairs(clickables) do
                pcall(function()
                    if clickable:IsA("ClickDetector") then
                        fireclickdetector(clickable)
                    elseif clickable:IsA("ProximityPrompt") then
                        fireproximityprompt(clickable)
                    end
                end)
            end
            
            -- Auto equip tools
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function()
                            LocalPlayer.Character.Humanoid:EquipTool(tool)
                            tool:Activate()
                            wait(0.5)
                            tool:Deactivate()
                        end)
                    end
                end
            end
        end
    end)
end

-- 8. Noclip / Walk Through Walls
function UniversalExploits.enableNoclip()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    spawn(function()
        while wait() do
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- 9. Server/Client Crasher
function UniversalExploits.serverCrasher()
    -- Method 1: Spam remote với payload lớn
    for _, remote in ipairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            spawn(function()
                while wait() do
                    pcall(function()
                        local massiveString = string.rep("A", 100000)
                        remote:FireServer(massiveString)
                    end)
                end
            end)
        end
    end
    
    -- Method 2: Tạo quá nhiều parts
    spawn(function()
        while wait() do
            pcall(function()
                for i = 1, 100 do
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(10, 10, 10)
                    part.Position = Vector3.new(math.random(-1000, 1000), math.random(0, 500), math.random(-1000, 1000))
                    part.Anchored = false
                    part.Parent = workspace
                end
            end)
        end
    end)
end

-- 10. Full Bright / Remove Fog
function UniversalExploits.visualExploits()
    -- Fullbright
    pcall(function()
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Ambient = Color3.new(1, 1, 1)
        
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v:Destroy()
            end
        end
    end)
    
    -- Remove fog from workspace
    pcall(function()
        workspace.FallenPartsDestroyHeight = -99999
    end)
end

-- 11. Infinite Jump
function UniversalExploits.infiniteJump()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.Changed:Connect(function(property)
        if property == "Jump" and humanoid.Jump == true then
            humanoid.Jump = true
        end
    end)
end

-- 12. Grab All Tools/Items
function UniversalExploits.grabAllItems()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and not item.Parent:FindFirstChild("Humanoid") then
            pcall(function()
                local clone = item:Clone()
                clone.Parent = backpack
            end)
        end
    end
end

-- 13. Chat Spoofer / Bypass
function UniversalExploits.chatSpoofer(message)
    local chatService = game:GetService("Chat")
    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local chatEvent = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvent then
            local sayMessage = chatEvent:FindFirstChild("SayMessageRequest")
            if sayMessage then
                sayMessage:FireServer(message, "All")
            end
        end
    end)
end

-- 14. God Mode
function UniversalExploits.godMode()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    humanoid.HealthChanged:Connect(function()
        humanoid.Health = math.huge
    end)
end

-- 15. Script Injector (Inject code vào game)
function UniversalExploits.scriptInjector(scriptCode)
    pcall(function()
        local func = loadstring(scriptCode)
        if func then
            func()
        end
    end)
end

-- ===== MAIN SCANNER & AUTO-EXECUTOR =====
local function runAllExploits()
    local exploitsList = {
        {name = "Anti Kick/Ban", func = UniversalExploits.antiKickAndBan},
        {name = "Movement Exploit", func = UniversalExploits.movementExploit},
        {name = "Economy Exploit", func = UniversalExploits.economyExploit},
        {name = "Remote Fuzzer", func = UniversalExploits.remoteFuzzer},
        {name = "ESP", func = UniversalExploits.enableESP},
        {name = "Auto Farm", func = UniversalExploits.autoFarm},
        {name = "Noclip", func = UniversalExploits.enableNoclip},
        {name = "Server Crasher", func = UniversalExploits.serverCrasher},
        {name = "Visual Exploits", func = UniversalExploits.visualExploits},
        {name = "Infinite Jump", func = UniversalExploits.infiniteJump},
        {name = "Grab All Items", func = UniversalExploits.grabAllItems},
        {name = "God Mode", func = UniversalExploits.godMode},
    }
    
    for _, exploit in ipairs(exploitsList) do
        spawn(function()
            pcall(function()
                exploit.func()
                notify("Exploit Active", exploit.name, 3)
            end)
        end)
        wait(0.1)
    end
end

-- ===== INITIALIZATION =====
local function initialize()
    notify("Universal Executor", "Starting exploit suite...", 5)
    
    setupEnvironmentBypass()
    
    wait(1)
    
    runAllExploits()
    
    -- Continuous scanning loop
    spawn(function()
        while wait(CONFIG.scanInterval) do
            pcall(function()
                UniversalExploits.economyExploit()
                UniversalExploits.grabAllItems()
                UniversalExploits.remoteFuzzer()
            end)
        end
    end)
    
    notify("Universal Executor", "All exploits loaded and running!", 5)
end

-- ===== START =====
initialize()

return UniversalExploits