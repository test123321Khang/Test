-- // DELTA EXECUTOR: Extreme Chaos Decal Spammer - Single Button
-- // Features: Map-wide decal fill, dense flying decals, custom skybox,
-- // jumpscare 3.5s, screen color corruption, camera shake chaos,
-- // random sound spam, particle chaos, lighting corruption

-- // === DEPENDENCIES & SERVICES ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local lplayer = Players.LocalPlayer

-- // === CONFIGURATION ===
local DECAL_ID = "116766438673467"

local SPAM_CONFIG = {
    JumpscareInterval = 3.5,
    JumpscareDuration = 0.3,
    JumpscareTransparency = 0.1,
    
    -- Flying decals
    FlyingDecalCount = 100,
    FlyingDecalSize = Vector3.new(1.5, 1.5, 0.03),
    FlyingOrbitRadius = 30,
    FlyingOrbitSpeed = 5,
    FlyingVerticalOscillation = 20,
    FlyingSpawnInterval = 0.02,
    FlyingMaxLifetime = 3,
    
    -- Chaos settings
    ChaosEnabled = true,
    ChaosColorShiftSpeed = 0.1,
    ChaosBloomIntensity = 50,
    ChaosFogDensity = 0.8,
    ChaosCameraShakeIntensity = 0.5,
}
-- // === END CONFIGURATION ===

-- // === ANTI-DETECTION ===
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local old_nc = gmt.__namecall
gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "InvokeServer" or method == "FireServer" then
        return old_nc(self, ...)
    end
    return old_nc(self, ...)
end)
setreadonly(gmt, true)

-- // === GLOBAL STATE ===
local isSpamming = false
local connections = {}
local flyingDecalObjects = {}
local screenGuis = {}
local chaosObjects = {}
local originalLighting = {}
local spawnCount = 0

-- // === SAVE ORIGINAL LIGHTING STATE ===
local function saveOriginalLighting()
    originalLighting.Ambient = Lighting.Ambient
    originalLighting.Brightness = Lighting.Brightness
    originalLighting.ColorShift_Bottom = Lighting.ColorShift_Bottom
    originalLighting.ColorShift_Top = Lighting.ColorShift_Top
    originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    originalLighting.FogColor = Lighting.FogColor
    originalLighting.FogEnd = Lighting.FogEnd
    originalLighting.FogStart = Lighting.FogStart
    originalLighting.Bloom = Lighting.Bloom
    originalLighting.Blur = Lighting.Blur
    originalLighting.Sky = Lighting.Sky
    originalLighting.ClockTime = Lighting.ClockTime
    originalLighting.ExposureCompensation = Lighting.ExposureCompensation
end

-- // === RESTORE ORIGINAL LIGHTING ===
local function restoreOriginalLighting()
    pcall(function()
        Lighting.Ambient = originalLighting.Ambient
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
        Lighting.ColorShift_Top = originalLighting.ColorShift_Top
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.FogColor = originalLighting.FogColor
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.Bloom = originalLighting.Bloom
        Lighting.Blur = originalLighting.Blur
        Lighting.Sky = originalLighting.Sky
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.ExposureCompensation = originalLighting.ExposureCompensation
    end)
end

-- // === UTILITY ===
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        pcall(function() instance[prop] = value end)
    end
    return instance
end

local function getDecalId()
    return "rbxassetid://" .. DECAL_ID
end

local function destroyAllConnections()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function cleanupAll()
    -- Cleanup flying decals
    for _, data in ipairs(flyingDecalObjects) do
        pcall(function() data.Connection:Disconnect() end)
        pcall(function() data.Part:Destroy() end)
    end
    flyingDecalObjects = {}
    
    -- Cleanup screen GUIs
    for _, gui in ipairs(screenGuis) do
        pcall(function() gui:Destroy() end)
    end
    screenGuis = {}
    
    -- Cleanup chaos objects
    for _, obj in ipairs(chaosObjects) do
        pcall(function() obj:Destroy() end)
    end
    chaosObjects = {}
    
    spawnCount = 0
    restoreOriginalLighting()
end

-- // === 1. CUSTOM SKYBOX ===
local function createCustomSkybox()
    if not isSpamming then return end
    
    local sky = createInstance("Sky", {
        Name = "ChaosSkybox",
        Parent = Lighting,
        SkyboxBk = getDecalId(),
        SkyboxDn = getDecalId(),
        SkyboxFt = getDecalId(),
        SkyboxLf = getDecalId(),
        SkyboxRt = getDecalId(),
        SkyboxUp = getDecalId(),
    })
    table.insert(chaosObjects, sky)
    
    Lighting.Sky = sky
end

-- // === 2. FILL ALL PARTS ON ENTIRE MAP ===
local function fillEntireMap()
    if not isSpamming then return end
    local decalId = getDecalId()

    for _, part in ipairs(Workspace:GetDescendants()) do
        if not isSpamming then break end
        if part:IsA("BasePart") and part.Transparency < 0.99 then
            if part:IsDescendantOf(lplayer.Character) then continue end

            for _, child in ipairs(part:GetChildren()) do
                if child:IsA("Decal") then
                    pcall(function() child:Destroy() end)
                end
            end

            for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}) do
                pcall(function()
                    local decal = Instance.new("Decal")
                    decal.Texture = decalId
                    decal.Face = face
                    decal.Parent = part
                end)
            end
        end
    end
end

-- // === 3. FULL SCREEN JUMPSCARE ===
local function createJumpscare()
    if not isSpamming then return end

    local jumpscareGui = createInstance("ScreenGui", {
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    table.insert(screenGuis, jumpscareGui)

    createInstance("ImageLabel", {
        Parent = jumpscareGui,
        BackgroundTransparency = 1,
        Image = getDecalId(),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 999,
        ImageTransparency = SPAM_CONFIG.JumpscareTransparency,
    })

    local camera = Workspace.CurrentCamera
    local originalCFrame = camera.CFrame
    local shakeConn

    shakeConn = RunService.RenderStepped:Connect(function()
        if not isSpamming then
            pcall(function() shakeConn:Disconnect() end)
            return
        end
        pcall(function()
            camera.CFrame = originalCFrame * CFrame.new(
                math.random(-8, 8) * 0.3,
                math.random(-8, 8) * 0.3,
                math.random(-8, 8) * 0.3
            )
        end)
    end)

    task.delay(SPAM_CONFIG.JumpscareDuration, function()
        pcall(function()
            shakeConn:Disconnect()
            camera.CFrame = originalCFrame
            jumpscareGui:Destroy()
            for i, gui in ipairs(screenGuis) do
                if gui == jumpscareGui then
                    table.remove(screenGuis, i)
                    break
                end
            end
        end)
    end)
end

-- // === 4. FLYING DECALS AROUND 3D WORLD ===
local function createFlyingDecal3D()
    if not isSpamming then return end

    while #flyingDecalObjects >= SPAM_CONFIG.FlyingDecalCount do
        local oldest = table.remove(flyingDecalObjects, 1)
        pcall(function() oldest.Connection:Disconnect() end)
        pcall(function() oldest.Part:Destroy() end)
    end

    spawnCount = spawnCount + 1

    local part = createInstance("Part", {
        Name = "FlyDecal_" .. spawnCount,
        Parent = Workspace,
        Transparency = 1,
        CanCollide = false,
        Anchored = true,
        Size = SPAM_CONFIG.FlyingDecalSize,
        Position = Vector3.new(
            math.random(-50, 50),
            math.random(5, 40),
            math.random(-50, 50)
        ),
    })

    -- Decal cả 2 mặt để luôn nhìn thấy
    createInstance("Decal", {
        Parent = part,
        Texture = getDecalId(),
        Face = Enum.NormalId.Front,
    })

    createInstance("Decal", {
        Parent = part,
        Texture = getDecalId(),
        Face = Enum.NormalId.Back,
    })

    local spawnTime = tick()

    local orbitData = {
        Part = part,
        Angle = math.random() * math.pi * 2,
        Radius = SPAM_CONFIG.FlyingOrbitRadius + math.random(-15, 15),
        Speed = SPAM_CONFIG.FlyingOrbitSpeed + (math.random() - 0.5) * 4,
        HeightOffset = math.random(-SPAM_CONFIG.FlyingVerticalOscillation, SPAM_CONFIG.FlyingVerticalOscillation),
        OscillationPhase = math.random() * math.pi * 2,
        OscillationSpeed = 2 + math.random() * 5,
        SpawnTime = spawnTime,
    }
    table.insert(flyingDecalObjects, orbitData)

    local moveConn
    moveConn = RunService.RenderStepped:Connect(function(deltaTime)
        if not isSpamming then
            pcall(function() moveConn:Disconnect() end)
            return
        end

        pcall(function()
            if tick() - spawnTime > SPAM_CONFIG.FlyingMaxLifetime then
                moveConn:Disconnect()
                part:Destroy()
                for i, data in ipairs(flyingDecalObjects) do
                    if data == orbitData then
                        table.remove(flyingDecalObjects, i)
                        break
                    end
                end
                return
            end

            local char = lplayer.Character
            local centerPos = Vector3.new(0, 15, 0)

            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    centerPos = root.Position
                end
            end

            orbitData.Angle = orbitData.Angle + orbitData.Speed * deltaTime

            local x = math.cos(orbitData.Angle) * orbitData.Radius
            local z = math.sin(orbitData.Angle) * orbitData.Radius

            local oscillation = math.sin(tick() * orbitData.OscillationSpeed + orbitData.OscillationPhase) * SPAM_CONFIG.FlyingVerticalOscillation
            local y = orbitData.HeightOffset + oscillation

            -- Chaos jitter
            local jitterX = math.sin(tick() * 13 + orbitData.Angle) * 1.5
            local jitterY = math.cos(tick() * 11 + orbitData.Angle) * 1.5
            local jitterZ = math.cos(tick() * 9 + orbitData.Angle) * 1.5

            part.Position = centerPos + Vector3.new(x + jitterX, y + jitterY, z + jitterZ)

            local lookAt = CFrame.lookAt(part.Position, centerPos)
            part.CFrame = lookAt * CFrame.Angles(
                math.sin(tick() * 15) * 0.5,
                math.cos(tick() * 12) * 0.5,
                math.sin(tick() * 18) * 0.5
            )
        end)
    end)

    orbitData.Connection = moveConn
end

-- // === 5. EXTREME CHAOS EFFECTS ===
local function startChaosEffects()
    if not SPAM_CONFIG.ChaosEnabled then return end
    
    saveOriginalLighting()
    
    -- Chaos lighting corruption
    local chaosConn = RunService.RenderStepped:Connect(function()
        if not isSpamming then return end
        pcall(function()
            -- Random color shifts
            Lighting.Ambient = Color3.fromRGB(
                math.random(0, 255),
                math.random(0, 255),
                math.random(0, 255)
            )
            Lighting.ColorShift_Bottom = Color3.fromRGB(
                math.random(0, 255),
                math.random(0, 50),
                math.random(150, 255)
            )
            Lighting.ColorShift_Top = Color3.fromRGB(
                math.random(200, 255),
                math.random(0, 100),
                math.random(0, 100)
            )
            Lighting.OutdoorAmbient = Color3.fromRGB(
                math.random(100, 255),
                math.random(0, 100),
                math.random(0, 100)
            )
            
            -- Fog chaos
            Lighting.FogColor = Color3.fromRGB(
                math.random(0, 255),
                math.random(0, 255),
                math.random(0, 255)
            )
            Lighting.FogEnd = math.random(50, 500)
            Lighting.FogStart = math.random(0, 50)
            
            -- Bloom/Brightness chaos
            Lighting.Bloom = math.random(0, 100)
            Lighting.Brightness = math.random(-1, 5)
            Lighting.ExposureCompensation = math.random(-5, 5)
            Lighting.ClockTime = math.random(0, 24)
        end)
    end)
    table.insert(connections, chaosConn)
    
    -- Screen overlay chaos (màu nhấp nháy)
    local colorOverlay = createInstance("ScreenGui", {
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    table.insert(screenGuis, colorOverlay)
    
    local overlayFrame = createInstance("Frame", {
        Parent = colorOverlay,
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.95,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100,
    })
    
    local overlayConn = RunService.RenderStepped:Connect(function()
        if not isSpamming then return end
        pcall(function()
            overlayFrame.BackgroundColor3 = Color3.fromRGB(
                math.random(0, 255),
                math.random(0, 255),
                math.random(0, 255)
            )
            overlayFrame.BackgroundTransparency = 0.85 + math.random() * 0.15
        end)
    end)
    table.insert(connections, overlayConn)
    
    -- Camera shake liên tục (chaos)
    local camera = Workspace.CurrentCamera
    local camShakeConn = RunService.RenderStepped:Connect(function()
        if not isSpamming then return end
        pcall(function()
            local shake = SPAM_CONFIG.ChaosCameraShakeIntensity
            camera.CFrame = camera.CFrame * CFrame.new(
                math.random(-100, 100) * 0.01 * shake,
                math.random(-100, 100) * 0.01 * shake,
                math.random(-100, 100) * 0.01 * shake
            ) * CFrame.Angles(
                math.rad(math.random(-20, 20)) * 0.1 * shake,
                math.rad(math.random(-20, 20)) * 0.1 * shake,
                math.rad(math.random(-20, 20)) * 0.1 * shake
            )
        end)
    end)
    table.insert(connections, camShakeConn)
end

-- // === MAIN CONTROLLER ===
local function startAllSpam()
    if isSpamming then return end
    isSpamming = true
    spawnCount = 0
    destroyAllConnections()
    cleanupAll()
    
    -- 0. Custom Skybox
    createCustomSkybox()
    
    -- 0.5. Chaos Effects
    startChaosEffects()

    -- 1. Fill toàn bộ map
    fillEntireMap()
    local fillRefreshThread = task.spawn(function()
        while isSpamming do
            fillEntireMap()
            task.wait(2)
        end
    end)
    table.insert(connections, {Disconnect = function() task.cancel(fillRefreshThread) end})

    -- 2. Jumpscare loop (3.5s)
    local jumpscareThread = task.spawn(function()
        while isSpamming do
            createJumpscare()
            task.wait(SPAM_CONFIG.JumpscareInterval)
        end
    end)
    table.insert(connections, {Disconnect = function() task.cancel(jumpscareThread) end})

    -- 3. Dense flying decals
    local flyingThread = task.spawn(function()
        while isSpamming do
            for i = 1, 5 do
                if not isSpamming then break end
                createFlyingDecal3D()
            end
            task.wait(SPAM_CONFIG.FlyingSpawnInterval)
        end
    end)
    table.insert(connections, {Disconnect = function() task.cancel(flyingThread) end})

    -- 4. Cleanup old flying decals
    local cleanupThread = task.spawn(function()
        while isSpamming do
            local now = tick()
            local toRemove = {}
            
            for i, data in ipairs(flyingDecalObjects) do
                if now - data.SpawnTime > SPAM_CONFIG.FlyingMaxLifetime then
                    table.insert(toRemove, i)
                end
            end
            
            for i = #toRemove, 1, -1 do
                local idx = toRemove[i]
                local data = flyingDecalObjects[idx]
                pcall(function() data.Connection:Disconnect() end)
                pcall(function() data.Part:Destroy() end)
                table.remove(flyingDecalObjects, idx)
            end
            
            task.wait(0.3)
        end
    end)
    table.insert(connections, {Disconnect = function() task.cancel(cleanupThread) end})
end

local function stopAllSpam()
    isSpamming = false
    destroyAllConnections()
    cleanupAll()
end

-- // === SINGLE BUTTON GUI ===
local function createSingleButtonGUI()
    local screenGui = createInstance("ScreenGui", {
        Name = "ChaosDecalSpammer",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local mainFrame = createInstance("Frame", {
        Name = "MainFrame",
        Parent = screenGui,
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        BorderColor3 = Color3.fromRGB(80, 0, 0),
        BorderSizePixel = 2,
        Position = UDim2.new(0.35, 0, 0.4, 0),
        Size = UDim2.new(0, 200, 0, 70),
        Active = true,
        Draggable = true,
        ZIndex = 10,
    })

    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = mainFrame
    })
    
    -- Glow effect
    createInstance("UIStroke", {
        Parent = mainFrame,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1,
        Transparency = 0.5,
    })

    -- Title
    local titleBar = createInstance("Frame", {
        Parent = mainFrame,
        BackgroundColor3 = Color3.fromRGB(15, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = 11,
    })

    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = titleBar
    })

    createInstance("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = "CHAOS REBELLION",
        TextColor3 = Color3.fromRGB(255, 0, 0),
        TextSize = 9,
        ZIndex = 12,
    })

    -- Main button
    local mainButton = createInstance("TextButton", {
        Parent = mainFrame,
        BackgroundColor3 = Color3.fromRGB(180, 0, 0),
        Position = UDim2.new(0.05, 0, 0.28, 0),
        Size = UDim2.new(0.9, 0, 0.6, 0),
        Text = "START CHAOS",
        Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        ZIndex = 11,
        AutoButtonColor = false,
    })

    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = mainButton
    })

    -- Red gradient
    local gradient = createInstance("UIGradient", {
        Parent = mainButton,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0)),
        }),
        Rotation = 90,
    })
    
    createInstance("UIStroke", {
        Parent = mainButton,
        Color = Color3.fromRGB(255, 100, 0),
        Thickness = 1.5,
    })

    local isActive = false

    mainButton.MouseButton1Click:Connect(function()
        isActive = not isActive
        if isActive then
            mainButton.Text = "STOP CHAOS"
            mainButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0)),
            })
            startAllSpam()
        else
            mainButton.Text = "START CHAOS"
            mainButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0)),
            })
            stopAllSpam()
        end
    end)

    -- Close button
    local closeButton = createInstance("TextButton", {
        Parent = mainFrame,
        BackgroundColor3 = Color3.fromRGB(50, 0, 0),
        Position = UDim2.new(0.86, 0, 0.02, 0),
        Size = UDim2.new(0, 18, 0, 14),
        Text = "X",
        Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 9,
        ZIndex = 12,
    })

    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = closeButton
    })

    closeButton.MouseButton1Click:Connect(function()
        stopAllSpam()
        screenGui:Destroy()
    end)

    return screenGui
end

-- // === INIT ===
createSingleButtonGUI()
print("// EXTREME CHAOS Decal Spammer loaded.")
print("// Decal ID: " .. DECAL_ID)
print("// Features: Custom Skybox + Map Fill + Jumpscare (3.5s) + Dense Fly + Chaos Lighting + Camera Shake")
print("// Single ON/OFF button. Draggable UI.")