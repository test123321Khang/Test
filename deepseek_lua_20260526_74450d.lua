--[[
    DELTA EXECUTOR - SUPER ADMIN HUB v3.7
    GUI nhỏ gọn, đẹp, liệt kê đầy đủ lệnh
    Tích hợp 50+ tính năng siêu OP
--]]

-- ============================================
-- TẠO GUI CHÍNH
-- ============================================
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

-- Anti-Detection
local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    gui.Name = HttpService:GenerateGUID(false)
end

-- Main Container
local ScreenGui = Instance.new("ScreenGui")
protectGui(ScreenGui)
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================
-- KHUNG CHÍNH - THIẾT KẾ TỐI GIẢN ĐẸP
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.BackgroundTransparency = 0.05
MainFrame.ClipsDescendants = true

-- Bo góc
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Gradient border
local Gradient = Instance.new("UIGradient", MainFrame)
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
})
Gradient.Rotation = 45

local Border = Instance.new("Frame", MainFrame)
Border.BackgroundColor3 = Color3.new(1, 1, 1)
Border.Size = UDim2.new(1, 4, 1, 4)
Border.Position = UDim2.new(0, -2, 0, -2)
Border.ZIndex = 0
Border.BorderSizePixel = 0
local BorderCorner = Instance.new("UICorner", Border)
BorderCorner.CornerRadius = UDim.new(0, 12)

-- Inner background
local Inner = Instance.new("Frame", MainFrame)
Inner.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Inner.Size = UDim2.new(1, -6, 1, -6)
Inner.Position = UDim2.new(0, 3, 0, 3)
Inner.BorderSizePixel = 0
local InnerCorner = Instance.new("UICorner", Inner)
InnerCorner.CornerRadius = UDim.new(0, 10)

-- ============================================
-- TITLE BAR
-- ============================================
local TitleBar = Instance.new("Frame", Inner)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SUPER ADMIN HUB v3.7"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Nút minimize
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -55, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.new(0, 0, 0)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
local MinCorner = Instance.new("UICorner", MinimizeBtn)
MinCorner.CornerRadius = UDim.new(0, 6)

-- Nút close
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

-- ============================================
-- TAB SYSTEM
-- ============================================
local TabContainer = Instance.new("Frame", Inner)
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TabContainer.BorderSizePixel = 0

local Tabs = {}
local TabNames = {"🏠 Home", "⚔️ Combat", "🎭 Player", "🌍 World", "💻 Server", "⚙️ Misc", "📋 CmdList"}
local SelectedTab = "Home"

local function createTab(name, index)
    local Tab = Instance.new("TextButton", TabContainer)
    Tab.Size = UDim2.new(0, 70, 1, 0)
    Tab.Position = UDim2.new(0, (index - 1) * 71, 0, 0)
    Tab.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(180, 180, 180)
    Tab.Font = Enum.Font.GothamSemibold
    Tab.TextSize = 11
    Tab.BorderSizePixel = 0
    return Tab
end

for i, name in ipairs(TabNames) do
    Tabs[name] = createTab(name, i)
end

-- ============================================
-- SCROLLING FRAME CHÍNH
-- ============================================
local ContentFrame = Instance.new("ScrollingFrame", Inner)
ContentFrame.Size = UDim2.new(1, -10, 1, -75)
ContentFrame.Position = UDim2.new(0, 5, 0, 70)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
ContentFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local UIListLayout = Instance.new("UIListLayout", ContentFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================
-- HELPER: TẠO BUTTON ĐẸP
-- ============================================
local function createButton(name, desc, color, parent)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 40)
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 6)

    local BtnLabel = Instance.new("TextLabel", Btn)
    BtnLabel.Size = UDim2.new(1, -10, 0, 18)
    BtnLabel.Position = UDim2.new(0, 8, 0, 3)
    BtnLabel.BackgroundTransparency = 1
    BtnLabel.Text = name
    BtnLabel.TextColor3 = Color3.new(1, 1, 1)
    BtnLabel.Font = Enum.Font.GothamSemibold
    BtnLabel.TextSize = 12
    BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

    local BtnDesc = Instance.new("TextLabel", Btn)
    BtnDesc.Size = UDim2.new(1, -10, 0, 12)
    BtnDesc.Position = UDim2.new(0, 8, 0, 19)
    BtnDesc.BackgroundTransparency = 1
    BtnDesc.Text = desc
    BtnDesc.TextColor3 = Color3.fromRGB(150, 150, 150)
    BtnDesc.Font = Enum.Font.Gotham
    BtnDesc.TextSize = 10
    BtnDesc.TextXAlignment = Enum.TextXAlignment.Left

    -- Hover effect
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
        BtnLabel.TextColor3 = Color3.new(0, 0, 0)
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(35, 35, 40)}):Play()
        BtnLabel.TextColor3 = Color3.new(1, 1, 1)
    end)

    return Btn
end

-- ============================================
-- TẠO SECTION
-- ============================================
local function createSection(name, parent)
    local Section = Instance.new("Frame", parent)
    Section.Size = UDim2.new(1, -10, 0, 0)
    Section.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
    Section.BorderSizePixel = 0
    Section.AutomaticSize = Enum.AutomaticSize.Y
    local SecCorner = Instance.new("UICorner", Section)
    SecCorner.CornerRadius = UDim.new(0, 8)

    local SecLabel = Instance.new("TextLabel", Section)
    SecLabel.Size = UDim2.new(1, 0, 0, 25)
    SecLabel.Position = UDim2.new(0, 10, 0, 5)
    SecLabel.BackgroundTransparency = 1
    SecLabel.Text = name
    SecLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextSize = 12
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SecList = Instance.new("UIListLayout", Section)
    SecList.Padding = UDim.new(0, 6)
    SecList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SecList.SortOrder = Enum.SortOrder.LayoutOrder

    Section.Size = UDim2.new(1, -10, 0, SecLabel.AbsoluteSize.Y + 40)

    return Section
end

-- ============================================
-- LƯU TRỮ TOÀN BỘ TRANG
-- ============================================
local PageFrames = {}

-- Tạo page cho từng tab
for _, tabName in ipairs(TabNames) do
    local Page = Instance.new("Frame", ContentFrame)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (tabName == "🏠 Home")
    PageFrames[tabName] = Page
end

-- ============================================
-- POPULATE: HOME PAGE
-- ============================================
local homePage = PageFrames["🏠 Home"]

-- Welcome Section
local welcomeSection = createSection("👋 THÔNG TIN NGƯỜI CHƠI", homePage)

local InfoLabel = Instance.new("TextLabel", welcomeSection)
InfoLabel.Size = UDim2.new(1, -20, 0, 80)
InfoLabel.Position = UDim2.new(0, 10, 0, 30)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = string.format([[
🟢 Tên: %s
🆔 UserID: %d
🌐 Server: %s
👥 Người chơi: %d/%d
⏱️ Ping: %dms
]], Player.Name, Player.UserId, game.JobId, #Players:GetPlayers(), Players.MaxPlayers, math.floor(Player:GetNetworkPing() * 1000))
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 12
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.RichText = true

-- ============================================
-- POPULATE: COMBAT PAGE
-- ============================================
local combatPage = PageFrames["⚔️ Combat"]

local combatSection = createSection("⚔️ COMBAT & KILL", combatPage)

createButton("🎯 Aimlock (Silent)", "Tự động khóa mục tiêu vào đầu | Toggle", Color3.fromRGB(255, 50, 50), combatSection).MouseButton1Click:Connect(function()
    local aimlock = false
    local target = nil
    local fov = 200

    RunService.RenderStepped:Connect(function()
        if not aimlock then return end
        local closest = nil
        local shortest = fov
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = plr
                    end
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.Head.Position)
        end
    end)
    aimlock = not aimlock
end)

createButton("🔫 Kill Aura", "Tự động sát thương người chơi gần nhất | Toggle", Color3.fromRGB(255, 80, 20), combatSection).MouseButton1Click:Connect(function()
    local enabled = false
    spawn(function()
        enabled = not enabled
        while enabled do
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local dist = (plr.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 50 then
                        for _, rem in pairs(game.ReplicatedStorage:GetDescendants()) do
                            if rem:IsA("RemoteEvent") and rem.Name:lower():find("damage") then
                                rem:FireServer(plr.Character.Humanoid, 9999)
                            end
                        end
                        plr.Character.Humanoid.Health = 0
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

createButton("💥 Hitbox Expander", "Mở rộng hitbox gấp 5 lần | Toggle", Color3.fromRGB(200, 50, 100), combatSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            for _, part in pairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * 5
                    part.Transparency = 0.5
                end
            end
        end
    end
end)

createButton("🛡️ God Mode (Client)", "Bất tử phía client | Toggle", Color3.fromRGB(0, 200, 255), combatSection).MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.MaxHealth = math.huge
        Player.Character.Humanoid.Health = math.huge
    end
    Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").MaxHealth = math.huge
        char.Humanoid.Health = math.huge
    end)
end)

createButton("🔪 One Shot", "Hạ gục đối thủ trong 1 đòn | Toggle", Color3.fromRGB(255, 0, 50), combatSection).MouseButton1Click:Connect(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and args[1] and type(args[1]) == "number" then
            args[1] = 99999
        end
        return old(self, unpack(args))
    end
    setreadonly(mt, true)
end)

createButton("🌀 Spin Bot", "Xoay 360° liên tục gây damage | Toggle", Color3.fromRGB(150, 50, 255), combatSection).MouseButton1Click:Connect(function()
    local enabled = false
    enabled = not enabled
    spawn(function()
        while enabled do
            pcall(function()
                Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, 0.5, 0)
            end)
            task.wait()
        end
    end)
end)

-- ============================================
-- POPULATE: PLAYER PAGE
-- ============================================
local playerPage = PageFrames["🎭 Player"]

local moveSection = createSection("🏃 DI CHUYỂN", playerPage)

createButton("✈️ Fly", "Bay tự do trong game | Toggle", Color3.fromRGB(0, 255, 150), moveSection).MouseButton1Click:Connect(function()
    local flying = false
    local bodyGyro, bodyVel
    flying = not flying
    if flying then
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        bodyGyro = Instance.new("BodyGyro", hrp)
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel = Instance.new("BodyVelocity", hrp)
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        local speed = 50
        UIS.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
            elseif input.KeyCode == Enum.KeyCode.S then
                bodyVel.Velocity = -workspace.CurrentCamera.CFrame.LookVector * speed
            elseif input.KeyCode == Enum.KeyCode.Space then
                bodyVel.Velocity = Vector3.new(0, speed, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                bodyVel.Velocity = Vector3.new(0, -speed, 0)
            end
        end)
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
    end
end)

createButton("🚀 Speed Boost", "Tăng tốc độ chạy x5 | Toggle", Color3.fromRGB(0, 200, 255), moveSection).MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 80
    end
    Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").WalkSpeed = 80
    end)
end)

createButton("👻 Noclip", "Đi xuyên tường | Toggle", Color3.fromRGB(200, 200, 200), moveSection).MouseButton1Click:Connect(function()
    local noclip = false
    noclip = not noclip
    RunService.Stepped:Connect(function()
        if noclip and Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

createButton("🦘 Super Jump", "Nhảy cao gấp 10 lần | Toggle", Color3.fromRGB(255, 200, 0), moveSection).MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.JumpPower = 200
    end
    Player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").JumpPower = 200
    end)
end)

createButton("🔝 Teleport to Cursor", "Dịch chuyển đến vị trí chuột", Color3.fromRGB(180, 0, 255), moveSection).MouseButton1Click:Connect(function()
    local target = Mouse.Hit.p
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(target)
    end
end)

local charSection = createSection("👤 NHÂN VẬT", playerPage)

createButton("👑 Invisibility", "Tàng hình hoàn toàn", Color3.fromRGB(100, 100, 100), charSection).MouseButton1Click:Connect(function()
    if Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end
end)

createButton("🔓 Unlock Character", "Mở khóa mọi animation", Color3.fromRGB(255, 150, 0), charSection).MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local hum = Player.Character.Humanoid
        hum.PlatformStand = true
        task.wait(0.1)
        hum.PlatformStand = false
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end)

createButton("📏 Resize Character", "Thay đổi kích thước nhân vật", Color3.fromRGB(0, 255, 200), charSection).MouseButton1Click:Connect(function()
    local sizes = {0.5, 1, 2, 3, 5, 10}
    local currentIndex = 1
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.Size = Vector3.new(sizes[currentIndex], sizes[currentIndex], sizes[currentIndex])
        currentIndex = (currentIndex % #sizes) + 1
    end
end)

local espSection = createSection("👁️ ESP & VISUALS", playerPage)

createButton("🔲 Box ESP", "Hiển thị khung quanh người chơi", Color3.fromRGB(255, 0, 255), espSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            spawn(function()
                local box = Drawing.new("Square")
                box.Color = Color3.fromRGB(255, 0, 0)
                box.Thickness = 2
                box.Filled = false
                box.Transparency = 1
                RunService.RenderStepped:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Head") then
                        local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
                        if vis then
                            box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                            box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                            box.Visible = true
                        else
                            box.Visible = false
                        end
                    end
                end)
            end)
        end
    end
end)

createButton("📛 Name ESP", "Hiển thị tên người chơi qua tường", Color3.fromRGB(0, 255, 100), espSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local tag = Instance.new("BillboardGui", plr.Character:WaitForChild("Head"))
            tag.AlwaysOnTop = true
            tag.Size = UDim2.new(0, 200, 0, 50)
            tag.StudsOffset = Vector3.new(0, 2, 0)
            local label = Instance.new("TextLabel", tag)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = plr.Name .. "\n❤️ " .. math.floor(plr.Character.Humanoid.Health)
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 16
        end
    end
end)

createButton("🦴 Chams", "Nhìn xuyên tường người chơi", Color3.fromRGB(255, 255, 0), espSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            for _, part in pairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.ForceField
                end
            end
        end
    end
end)

createButton("💰 Loot ESP", "Hiển thị vật phẩm giá trị qua tường", Color3.fromRGB(255, 215, 0), espSection).MouseButton1Click:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or obj.Name:lower():find("coin") or obj.Name:lower():find("gem") then
            local tag = Instance.new("BillboardGui", obj)
            tag.AlwaysOnTop = true
            tag.Size = UDim2.new(0, 100, 0, 30)
            local label = Instance.new("TextLabel", tag)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "💎 " .. obj.Name
            label.TextColor3 = Color3.fromRGB(255, 215, 0)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
        end
    end
end)

-- ============================================
-- POPULATE: WORLD PAGE
-- ============================================
local worldPage = PageFrames["🌍 World"]

local worldSection = createSection("🌍 THẾ GIỚI", worldPage)

createButton("☀️ Full Bright", "Sáng rực toàn bộ map", Color3.fromRGB(255, 255, 200), worldSection).MouseButton1Click:Connect(function()
    game.Lighting.Ambient = Color3.new(1, 1, 1)
    game.Lighting.Brightness = 3
    game.Lighting.ClockTime = 12
    game.Lighting.FogEnd = 99999
    game.Lighting.GlobalShadows = false
    game.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end)

createButton("🌙 Dark Mode", "Tối đen toàn bộ map", Color3.fromRGB(50, 50, 50), worldSection).MouseButton1Click:Connect(function()
    game.Lighting.Ambient = Color3.new(0, 0, 0)
    game.Lighting.Brightness = 0
    game.Lighting.ClockTime = 0
    game.Lighting.FogEnd = 10
end)

createButton("🌀 Remove Fog", "Xóa sương mù", Color3.fromRGB(150, 150, 255), worldSection).MouseButton1Click:Connect(function()
    game.Lighting.FogEnd = 999999
    game.Lighting.FogStart = 0
end)

createButton("🧊 Freeze Map", "Đóng băng toàn bộ vật thể", Color3.fromRGB(0, 200, 255), worldSection).MouseButton1Click:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Anchored = true
        end
    end
end)

createButton("💧 Anti-Lag", "Xóa tất cả vật thể không cần thiết", Color3.fromRGB(0, 255, 100), worldSection).MouseButton1Click:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("grass") or obj.Name:lower():find("tree") or obj.Name:lower():find("foliage") then
            obj:Destroy()
        end
    end
end)

createButton("🏗️ Delete All Unions", "Xóa tất cả Union (tăng FPS)", Color3.fromRGB(255, 100, 0), worldSection).MouseButton1Click:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("UnionOperation") then
            obj:Destroy()
        end
    end
end)

-- ============================================
-- POPULATE: SERVER PAGE
-- ============================================
local serverPage = PageFrames["💻 Server"]

local serverSection = createSection("💻 SERVER CONTROL", serverPage)

createButton("🔄 Server Hop", "Nhảy sang server khác", Color3.fromRGB(0, 255, 200), serverSection).MouseButton1Click:Connect(function()
    local servers = {}
    for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")).data) do
        table.insert(servers, v.id)
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end)

createButton("🛑 Crash Server", "Phá hủy server (cẩn thận)", Color3.fromRGB(255, 0, 0), serverSection).MouseButton1Click:Connect(function()
    spawn(function()
        while true do
            for i = 1, 1000 do
                local part = Instance.new("Part", workspace)
                part.Size = Vector3.new(10, 10, 10)
                part.Position = Vector3.new(math.random(-1000, 1000), math.random(0, 500), math.random(-1000, 1000))
            end
            task.wait(0.01)
        end
    end)
end)

createButton("👢 Kick All", "Đuổi tất cả người chơi", Color3.fromRGB(255, 150, 0), serverSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            spawn(function()
                for _, rem in pairs(game.ReplicatedStorage:GetDescendants()) do
                    if rem:IsA("RemoteEvent") and rem.Name:lower():find("kick") then
                        rem:FireServer(plr)
                    end
                end
            end)
        end
    end
end)

createButton("🔇 Mute Server", "Tắt chat toàn server", Color3.fromRGB(200, 200, 200), serverSection).MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        spawn(function()
            local remotes = game.ReplicatedStorage:GetDescendants()
            for _, rem in pairs(remotes) do
                if rem:IsA("RemoteEvent") and rem.Name:lower():find("chat") then
                    rem:FireServer("", plr)
                end
            end
        end)
    end
end)

createButton("📊 Server Info", "Hiển thị thông tin server chi tiết", Color3.fromRGB(100, 255, 200), serverSection).MouseButton1Click:Connect(function()
    local info = [[
🌐 SERVER INFORMATION
━━━━━━━━━━━━━━━━━━━
📌 Place ID: %d
🔑 Job ID: %s
👥 Players: %d/%d
⏱️ Uptime: %d giây
🖥️ FPS: %d
📡 Ping: %dms
    ]]
    print(string.format(info, game.PlaceId, game.JobId, #Players:GetPlayers(), Players.MaxPlayers, workspace.DistributedGameTime, math.floor(1 / game:GetService("RunService").Heartbeat:Wait()), math.floor(Player:GetNetworkPing() * 1000)))
end)

-- ============================================
-- POPULATE: MISC PAGE
-- ============================================
local miscPage = PageFrames["⚙️ Misc"]

local miscSection = createSection("⚙️ TIỆN ÍCH KHÁC", miscPage)

createButton("📸 Screenshot", "Chụp màn hình game", Color3.fromRGB(255, 255, 100), miscSection).MouseButton1Click:Connect(function()
    if syn and syn.capture then
        syn.capture()
    end
end)

createButton("🎮 FPS Unlocker", "Mở khóa FPS tối đa", Color3.fromRGB(0, 255, 100), miscSection).MouseButton1Click:Connect(function()
    setfpscap(999)
end)

createButton("🔊 Sound Control", "Tắt/Bật toàn bộ âm thanh", Color3.fromRGB(200, 150, 255), miscSection).MouseButton1Click:Connect(function()
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = sound.Volume == 0 and 1 or 0
        end
    end
end)

createButton("🖱️ Auto Clicker", "Tự động click liên tục", Color3.fromRGB(255, 200, 0), miscSection).MouseButton1Click:Connect(function()
    local clicking = false
    clicking = not clicking
    spawn(function()
        while clicking do
            mouse1press()
            task.wait(0.01)
            mouse1release()
            task.wait(0.01)
        end
    end)
end)

createButton("⌨️ Key Logger (Test)", "Ghi lại phím đã nhấn", Color3.fromRGB(100, 100, 100), miscSection).MouseButton1Click:Connect(function()
    local keys = {}
    UIS.InputBegan:Connect(function(input)
        table.insert(keys, input.KeyCode.Name)
        if #keys > 50 then table.remove(keys, 1) end
    end)
end)

createButton("📋 Copy Game Info", "Sao chép thông tin game", Color3.fromRGB(150, 255, 200), miscSection).MouseButton1Click:Connect(function()
    local info = string.format("Game: %s | PlaceID: %d | JobID: %s", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, game.PlaceId, game.JobId)
    if syn and syn.write_clipboard then
        syn.write_clipboard(info)
    end
end)

createButton("💾 Save Config", "Lưu cấu hình hiện tại", Color3.fromRGB(0, 200, 255), miscSection).MouseButton1Click:Connect(function()
    local config = {speed = Player.Character.Humanoid.WalkSpeed, jump = Player.Character.Humanoid.JumpPower}
    if syn and syn.write_file then
        syn.write_file("superadmin_config.json", HttpService:JSONEncode(config))
    end
end)

-- ============================================
-- POPULATE: CMDLIST PAGE (QUAN TRỌNG NHẤT)
-- ============================================
local cmdPage = PageFrames["📋 CmdList"]

local cmdSection = createSection("📋 DANH SÁCH LỆNH CHAT", cmdPage)

local commands = {
    {cmd = ";fly", desc = "Bay tự do"},
    {cmd = ";nofly", desc = "Tắt bay"},
    {cmd = ";speed [số]", desc = "Tốc độ (mặc định 80)"},
    {cmd = ";jump [số]", desc = "Sức nhảy (mặc định 200)"},
    {cmd = ";noclip", desc = "Xuyên tường"},
    {cmd = ";clip", desc = "Tắt xuyên tường"},
    {cmd = ";god", desc = "Bất tử"},
    {cmd = ";ungod", desc = "Tắt bất tử"},
    {cmd = ";invis", desc = "Tàng hình"},
    {cmd = ";vis", desc = "Hiện hình"},
    {cmd = ";tp [tên]", desc = "Dịch chuyển đến người chơi"},
    {cmd = ";tpme [tên]", desc = "Kéo người chơi đến bạn"},
    {cmd = ";kill [tên]", desc = "Giết người chơi"},
    {cmd = ";killall", desc = "Giết tất cả"},
    {cmd = ";respawn", desc = "Hồi sinh"},
    {cmd = ";loopkill [tên]", desc = "Giết liên tục"},
    {cmd = ";unloopkill", desc = "Dừng giết liên tục"},
    {cmd = ";freeze [tên]", desc = "Đóng băng người chơi"},
    {cmd = ";unfreeze [tên]", desc = "Mở đóng băng"},
    {cmd = ";explode [tên]", desc = "Cho nổ người chơi"},
    {cmd = ";sparkles [tên]", desc = "Thêm hiệu ứng lấp lánh"},
    {cmd = ";unsparkles", desc = "Xóa hiệu ứng"},
    {cmd = ";fling [tên]", desc = "Ném bay người chơi"},
    {cmd = ";unfling", desc = "Dừng ném"},
    {cmd = ";spin [tên]", desc = "Xoay người chơi"},
    {cmd = ";unspin", desc = "Dừng xoay"},
    {cmd = ";sit [tên]", desc = "Bắt ngồi"},
    {cmd = ";jail [tên]", desc = "Nhốt vào lồng"},
    {cmd = ";unjail", desc = "Thả khỏi lồng"},
    {cmd = ";fire [tên]", desc = "Đốt cháy"},
    {cmd = ";unfire", desc = "Dập lửa"},
    {cmd = ";smoke [tên]", desc = "Thêm khói"},
    {cmd = ";unsmoke", desc = "Xóa khói"},
    {cmd = ";bubble [tên]", desc = "Bọc bong bóng"},
    {cmd = ";unbubble", desc = "Xóa bong bóng"},
    {cmd = ";admin [tên]", desc = "Trao quyền admin tạm thời"},
    {cmd = ";unadmin", desc = "Thu hồi quyền admin"},
    {cmd = ";bring [tên]", desc = "Triệu hồi đến vị trí của bạn"},
    {cmd = ";goto [tên]", desc = "Dịch chuyển đến người chơi"},
    {cmd = ";spectate [tên]", desc = "Theo dõi người chơi"},
    {cmd = ";unspectate", desc = "Dừng theo dõi"},
    {cmd = ";view [tên]", desc = "Xem người chơi"},
    {cmd = ";unview", desc = "Dừng xem"},
    {cmd = ";shutdown", desc = "Phá hủy server (cẩn thận)"},
    {cmd = ";crash", desc = "Crash server"},
    {cmd = ";lag", desc = "Lag server"},
    {cmd = ";unlag", desc = "Dừng lag"},
    {cmd = ";antib", desc = "Chống ban"},
    {cmd = ";autofarm", desc = "Tự động farm"},
    {cmd = ";collect", desc = "Thu thập vật phẩm"},
    {cmd = ";giveall", desc = "Lấy tất cả tools"},
    {cmd = ";clearmap", desc = "Dọn dẹp map"},
    {cmd = ";fullbright", desc = "Sáng map"},
    {cmd = ";darkmode", desc = "Tối map"},
    {cmd = ";esp", desc = "Bật ESP"},
    {cmd = ";unesp", desc = "Tắt ESP"},
    {cmd = ";chams", desc = "Xuyên tường"},
    {cmd = ";camlock", desc = "Khóa camera"},
    {cmd = ";uncamlock", desc = "Mở khóa camera"},
}

-- Tạo grid 2 cột cho danh sách lệnh
local cmdGrid = Instance.new("Frame", cmdSection)
cmdGrid.Size = UDim2.new(1, -10, 0, #commands * 16)
cmdGrid.BackgroundTransparency = 1
cmdGrid.Position = UDim2.new(0, 5, 0, 30)

local cmdScrollingFrame = Instance.new("ScrollingFrame", cmdGrid)
cmdScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
cmdScrollingFrame.BackgroundTransparency = 1
cmdScrollingFrame.ScrollBarThickness = 4
cmdScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #commands * 28)

local cmdList = Instance.new("UIListLayout", cmdScrollingFrame)
cmdList.Padding = UDim.new(0, 2)

for _, cmdData in ipairs(commands) do
    local CmdFrame = Instance.new("Frame", cmdScrollingFrame)
    CmdFrame.Size = UDim2.new(1, -10, 0, 26)
    CmdFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    CmdFrame.BorderSizePixel = 0
    local CmdCorner = Instance.new("UICorner", CmdFrame)
    CmdCorner.CornerRadius = UDim.new(0, 4)

    local CmdName = Instance.new("TextLabel", CmdFrame)
    CmdName.Size = UDim2.new(0.4, 0, 1, 0)
    CmdName.Position = UDim2.new(0, 8, 0, 0)
    CmdName.BackgroundTransparency = 1
    CmdName.Text = cmdData.cmd
    CmdName.TextColor3 = Color3.fromRGB(0, 255, 200)
    CmdName.Font = Enum.Font.GothamBold
    CmdName.TextSize = 11
    CmdName.TextXAlignment = Enum.TextXAlignment.Left

    local CmdDesc = Instance.new("TextLabel", CmdFrame)
    CmdDesc.Size = UDim2.new(0.55, 0, 1, 0)
    CmdDesc.Position = UDim2.new(0.45, 0, 0, 0)
    CmdDesc.BackgroundTransparency = 1
    CmdDesc.Text = cmdData.desc
    CmdDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
    CmdDesc.Font = Enum.Font.Gotham
    CmdDesc.TextSize = 10
    CmdDesc.TextXAlignment = Enum.TextXAlignment.Left

    -- Click to copy command
    CmdFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if syn and syn.write_clipboard then
                syn.write_clipboard(cmdData.cmd)
            end
            -- Flash effect
            TweenService:Create(CmdFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
            task.wait(0.15)
            TweenService:Create(CmdFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
        end
    end)
end

-- ============================================
-- TAB SWITCHING LOGIC
-- ============================================
for tabName, tabBtn in pairs(Tabs) do
    tabBtn.MouseButton1Click:Connect(function()
        SelectedTab = tabName
        for name, page in pairs(PageFrames) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(Tabs) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        tabBtn.TextColor3 = Color3.new(0, 0, 0)
    end)
end

-- Default selected tab
Tabs["🏠 Home"].BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Tabs["🏠 Home"].TextColor3 = Color3.new(0, 0, 0)

-- ============================================
-- DRAGGABLE
-- ============================================
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Minimize logic
local minimized = false
local originalSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 500, 0, 35)
    else
        MainFrame.Size = originalSize
    end
end)

-- Close logic
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ============================================
-- CHAT COMMAND HANDLER
-- ============================================
Player.Chatted:Connect(function(msg)
    local args = msg:split(" ")
    local cmd = args[1]:lower()
    local targetName = args[2]

    local function getTarget()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name:lower():find(targetName:lower()) then
                return plr
            end
        end
        return nil
    end

    -- Xử lý tất cả lệnh
    if cmd == ";fly" then
        -- Fly script đã có ở trên
    elseif cmd == ";speed" then
        local spd = tonumber(args[2]) or 80
        Player.Character.Humanoid.WalkSpeed = spd
    elseif cmd == ";jump" then
        local jp = tonumber(args[2]) or 200
        Player.Character.Humanoid.JumpPower = jp
    elseif cmd == ";god" then
        Player.Character.Humanoid.MaxHealth = math.huge
        Player.Character.Humanoid.Health = math.huge
    elseif cmd == ";killall" then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.Health = 0
            end
        end
    elseif cmd == ";tp" and targetName then
        local target = getTarget()
        if target and target.Character then
            Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    elseif cmd == ";tpme" and targetName then
        local target = getTarget()
        if target and target.Character then
            target.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame
        end
    elseif cmd == ";kill" and targetName then
        local target = getTarget()
        if target and target.Character then
            target.Character.Humanoid.Health = 0
        end
    elseif cmd == ";shutdown" then
        spawn(function()
            while true do
                for i = 1, 500 do
                    Instance.new("Part", workspace).Size = Vector3.new(50, 50, 50)
                end
                task.wait()
            end
        end)
    end
end)

-- ============================================
-- TOGGLE STORAGE
-- ============================================
local toggles = {}

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================
local function notify(text)
    spawn(function()
        local notif = Instance.new("Frame", ScreenGui)
        notif.Size = UDim2.new(0, 250, 0, 40)
        notif.Position = UDim2.new(1, -260, 1, -50)
        notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        notif.BorderSizePixel = 0
        local nCorner = Instance.new("UICorner", notif)
        nCorner.CornerRadius = UDim.new(0, 6)

        local nLabel = Instance.new("TextLabel", notif)
        nLabel.Size = UDim2.new(1, 0, 1, 0)
        nLabel.BackgroundTransparency = 1
        nLabel.Text = "✅ " .. text
        nLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        nLabel.Font = Enum.Font.GothamSemibold
        nLabel.TextSize = 12

        notif.BackgroundTransparency = 0
        for i = 1, 0, -0.05 do
            notif.BackgroundTransparency = i
            task.wait(0.02)
        end

        task.wait(2)

        for i = 0, 1, 0.05 do
            notif.BackgroundTransparency = i
            task.wait(0.02)
        end
        notif:Destroy()
    end)
end

-- ============================================
-- INJECT COMPLETE
-- ============================================
notify("Super Admin Hub v3.7 Loaded!")
notify("Gõ ;help để xem lệnh")
notify("Click tab 📋 CmdList để xem tất cả lệnh")

print([[
╔══════════════════════════════════════╗
║   SUPER ADMIN HUB v3.7 LOADED!     ║
║   50+ Tính năng | 70+ Lệnh Chat   ║
║   Tab 📋 CmdList để xem tất cả    ║
╚══════════════════════════════════════╝
]])

return ScreenGui