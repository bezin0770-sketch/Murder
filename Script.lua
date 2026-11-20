-- [F]sk Murder Mystery 2 Script - V12 (Delta Loadstring Edition)
-- Feito para Fishik

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- CARREGANDO A UI (WindUI)
-- ==========================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "[F]sk Hub | MM2 V12",
    Icon = "rbxassetid://10709793686",
    Author = "Fishik",
    Folder = "FskMM2_V12",
    Size = UDim2.fromOffset(620, 520),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = true,
})

local State = {
    ESP = false, ESPBox = false, ESPLine = false, ESPTracer = false, ESPHealth = false, ESPItems = false,
    AutoWin = false, AutoShoot = false, KillAura = false, CoinFarm = false, AutoPickup = false,
    GodMode = false, WalkSpeed = 16, JumpPower = 50,
    Fly = false, NoClip = false, InfiniteJump = false,
    FullBright = false, AutoSteal = false
}

-- ==========================================
-- FUNÇÕES AUXILIARES
-- ==========================================
local function GetRemotes()
    local Remotes = {}
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            Remotes[v.Name] = v
        end
    end
    return Remotes
end
local Remotes = GetRemotes()

local function GetRoleColor(player)
    local role = player:GetAttribute("Role") or "Innocent"
    if role == "Murderer" then return Color3.fromRGB(255, 0, 0), "Murderer"
    elseif role == "Sheriff" then return Color3.fromRGB(0, 150, 255), "Sheriff"
    else return Color3.fromRGB(0, 255, 0), "Innocent" end
end

local function GetItemColor(item)
    if item.Name == "Gun" or item.Name == "GunDrop" then return Color3.fromRGB(0, 150, 255)
    elseif item.Name == "Knife" then return Color3.fromRGB(255, 0, 0)
    else return Color3.fromRGB(255, 255, 255) end
end

-- ==========================================
-- ESP + TRACERS + ITEMS
-- ==========================================
local ESP_Active = {}
local Tracers = {}
local ItemESP = {}

local function CleanESP()
    for player, items in pairs(ESP_Active) do
        for _, obj in pairs(items) do if obj and obj.Destroy then obj:Destroy() end end
    end
    ESP_Active = {}
end

local function CleanTracers()
    for player, line in pairs(Tracers) do if line and line.Remove then line:Remove() end end
    Tracers = {}
end

local function CleanItemESP()
    for _, items in pairs(ItemESP) do
        for _, obj in pairs(items) do if obj and obj.Destroy then obj:Destroy() end end
    end
    ItemESP = {}
end

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    if not head or not hum then return end

    if ESP_Active[player] then
        for _, obj in pairs(ESP_Active[player]) do if obj and obj.Destroy then obj:Destroy() end end
    end
    
    local roleColor, roleName = GetRoleColor(player)
    local items = {}

    local hl = Instance.new("Highlight")
    hl.Name = "Fsk_HL"
    hl.Adornee = char
    hl.FillTransparency = State.ESPBox and 0.5 or 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = roleColor
    hl.FillColor = roleColor
    hl.Parent = char
    table.insert(items, hl)

    local bg = Instance.new("BillboardGui")
    bg.Name = "Fsk_BG"
    bg.Size = UDim2.new(0, 160, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = head
    bg.Parent = head

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = player.Name .. " (" .. roleName .. ")"
    nameLbl.TextColor3 = roleColor
    nameLbl.TextStrokeTransparency = 0
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.Parent = bg

    if State.ESPHealth then
        local hpLbl = Instance.new("TextLabel")
        hpLbl.Size = UDim2.new(1, 0, 0.5, 0)
        hpLbl.Position = UDim2.new(0, 0, 0.5, 0)
        hpLbl.BackgroundTransparency = 1
        hpLbl.Text = "HP: " .. math.floor(hum.Health)
        hpLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        hpLbl.TextStrokeTransparency = 0
        hpLbl.Font = Enum.Font.Gotham
        hpLbl.TextSize = 11
        hpLbl.Parent = bg
    end
    table.insert(items, bg)

    ESP_Active[player] = items
end

-- Loop Principal
RunService.RenderStepped:Connect(function()
    if State.ESP or State.ESPBox or State.ESPHealth then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not ESP_Active[player] then ApplyESP(player) end
            end
        end
    else
        CleanESP()
    end

    if State.ESPItems then
        for _, v in pairs(Workspace:GetChildren()) do
            if (v.Name == "Knife" or v.Name == "Gun" or v.Name == "GunDrop") and v:IsA("Model") then
                if not ItemESP[v] then
                    local head = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                    if head then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = v
                        hl.FillColor = GetItemColor(v)
                        hl.OutlineColor = GetItemColor(v)
                        hl.FillTransparency = 0.5
                        hl.Parent = v
                        
                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0, 100, 0, 50)
                        bg.StudsOffset = Vector3.new(0, 2, 0)
                        bg.AlwaysOnTop = true
                        bg.Adornee = head
                        bg.Parent = head
                        
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1,0,1,0)
                        txt.BackgroundTransparency = 1
                        txt.Text = v.Name
                        txt.TextColor3 = GetItemColor(v)
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                        txt.Parent = bg
                        
                        ItemESP[v] = {hl, bg}
                    end
                end
            end
        end
    else
        CleanItemESP()
    end

    if State.ESPLine or State.ESPTracer then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        if not Tracers[player] then
                            Tracers[player] = Drawing.new("Line")
                            Tracers[player].Thickness = 1.5
                            Tracers[player].Transparency = 1
                        end
                        local line = Tracers[player]
                        local color = GetRoleColor(player)
                        
                        if State.ESPLine then
                            line.From = Vector2.new(screenPos.X, 0)
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                        elseif State.ESPTracer then
                            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                        end
                        
                        line.Color = color
                        line.Visible = true
                    elseif Tracers[player] then
                        Tracers[player].Visible = false
                    end
                end
            end
        end
    else
        CleanTracers()
    end
end)

-- ==========================================
-- ABA 1: VISUAL / ESP
-- ==========================================
local VisualTab = Window:Tab({ Title = "Visual / ESP", Icon = "eye" })

VisualTab:Toggle({ Title = "ESP Nome e Role", Value = false, Callback = function(v) State.ESP = v end })
VisualTab:Toggle({ Title = "ESP Vida", Value = false, Callback = function(v) State.ESPHealth = v end })
VisualTab:Toggle({ 
    Title = "ESP Caixa (Highlight)", 
    Value = false, 
    Callback = function(v) 
        State.ESPBox = v 
        for _, items in pairs(ESP_Active) do
            if items[1] then items[1].FillTransparency = v and 0.5 or 1 end
        end
    end 
})
VisualTab:Toggle({ Title = "ESP Linha (Céu)", Value = false, Callback = function(v) State.ESPLine = v end })
VisualTab:Toggle({ Title = "ESP Tracer (Mira)", Value = false, Callback = function(v) State.ESPTracer = v end })
VisualTab:Toggle({ Title = "ESP Itens (Faca/Arma)", Value = false, Callback = function(v) State.ESPItems = v end })

VisualTab:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(v)
        game.Lighting.Ambient = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
        game.Lighting.OutdoorAmbient = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
    end
})

-- ==========================================
-- ABA 2: COMBATE
-- ==========================================
local CombatTab = Window:Tab({ Title = "Combate", Icon = "swords" })

CombatTab:Toggle({
    Title = "Auto Win",
    Value = false,
    Callback = function(v)
        State.AutoWin = v
        if v then
            task.spawn(function()
                while State.AutoWin do
                    task.wait(1)
                    if LocalPlayer:GetAttribute("Role") ~= "Murderer" and Remotes.Win then
                        Remotes.Win:FireServer()
                    end
                end
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Auto Shoot (Sheriff)",
    Value = false,
    Callback = function(v)
        State.AutoShoot = v
        if v then
            task.spawn(function()
                while State.AutoShoot do
                    task.wait(0.1)
                    if LocalPlayer:GetAttribute("Role") == "Sheriff" then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p:GetAttribute("Role") == "Murderer" then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and Remotes.Shoot then
                                    Remotes.Shoot:FireServer(hrp.Position, hrp)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:Toggle({
    Title = "Kill Aura",
    Value = false,
    Callback = function(v)
        State.KillAura = v
        if v then
            task.spawn(function()
                while State.KillAura do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                if (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 25 then
                                    p.Character:BreakJoints()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:Button({
    Title = "Matar Todos",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
                p.Character.Humanoid.Health = 0
            end
        end
    end
})

CombatTab:Toggle({
    Title = "Auto Pickup (Pega Itens)",
    Value = false,
    Callback = function(v)
        State.AutoPickup = v
        if v then
            task.spawn(function()
                while State.AutoPickup do
                    task.wait(0.5)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, item in pairs(Workspace:GetChildren()) do
                            if item.Name == "Knife" or item.Name == "Gun" then
                                if item:FindFirstChild("Handle") then
                                    firetouchinterest(char.HumanoidRootPart, item.Handle, 0)
                                    task.wait(0.1)
                                    firetouchinterest(char.HumanoidRootPart, item.Handle, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- ABA 3: JOGADOR
-- ==========================================
local PlayerTab = Window:Tab({ Title = "Jogador", Icon = "user" })

PlayerTab:Toggle({
    Title = "God Mode",
    Value = false,
    Callback = function(v)
        State.GodMode = v
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.MaxHealth = v and math.huge or 100
            char.Humanoid.Health = v and math.huge or 100
        end
    end
})

PlayerTab:Slider({ Title = "Speed", Value = { Min = 16, Max = 500, Default = 16 }, Callback = function(v)
    State.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end })

PlayerTab:Slider({ Title = "Jump", Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v)
    State.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end })

PlayerTab:Toggle({
    Title = "Pulo Infinito",
    Value = false,
    Callback = function(v)
        State.InfiniteJump = v
        if v then
            UserInputService.JumpRequest:Connect(function()
                if State.InfiniteJump and LocalPlayer.Character then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

PlayerTab:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(v)
        State.NoClip = v
        task.spawn(function()
            while State.NoClip do
                task.wait()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
})

PlayerTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(v)
        State.Fly = v
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if v then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "FskFly"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "FskGyro"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1e3

            task.spawn(function()
                while State.Fly and bv.Parent do
                    task.wait()
                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
                    bv.Velocity = dir * State.WalkSpeed * 2
                    bg.CFrame = Camera.CFrame
                end
            end)
        else
            if hrp:FindFirstChild("FskFly") then hrp.FskFly:Destroy() end
            if hrp:FindFirstChild("FskGyro") then hrp.FskGyro:Destroy() end
        end
    end
})

-- ==========================================
-- ABA 4: MISC E ROUBADOS EXTREMOS
-- ==========================================
local MiscTab = Window:Tab({ Title = "Roubados", Icon = "skull" })

MiscTab:Toggle({
    Title = "Auto Farm Moedas (Loop)",
    Value = false,
    Callback = function(v)
        State.CoinFarm = v
        if v then
            task.spawn(function()
                while State.CoinFarm do
                    task.wait(0.5)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        for _, coin in pairs(Workspace:GetChildren()) do
                            if coin.Name == "Coin" and coin:FindFirstChild("TouchInterest") then
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                                task.wait(0.01)
                                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
})

MiscTab:Button({
    Title = "Teleportar para Todas as Moedas",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, coin in pairs(Workspace:GetChildren()) do
                if coin.Name == "Coin" and coin:IsA("BasePart") then
                    char.HumanoidRootPart.CFrame = coin.CFrame
                    task.wait(0.1)
                    firetouchinterest(char.HumanoidRootPart, coin, 0)
                    firetouchinterest(char.HumanoidRootPart, coin, 1)
                end
            end
        end
    end
})

MiscTab:Button({
    Title = "Teleportar para Todos (TP Kill)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                    task.wait(0.5)
                end
            end
        end
    end
})

MiscTab:Button({
    Title = "Anti-Void (Cai e Volta)",
    Callback = function()
        task.spawn(function()
            while task.wait(0.5) do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character.HumanoidRootPart.Position.Y < -50 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                    end
                end
            end
        end)
    end
})

MiscTab:Button({
    Title = "Troll: Explodir o Mapa",
    Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Position.Magnitude < 500 then
                local exp = Instance.new("Explosion")
                exp.Position = v.Position
                exp.BlastRadius = 10
                exp.BlastPressure = 10000
                exp.Parent = Workspace
                task.wait(0.1)
            end
        end
    end
})

MiscTab:Button({
    Title = "Fling (Arremessar Jogadores)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < 15 then
                        p.Character.HumanoidRootPart.Velocity = Vector3.new(0, 500, 0)
                    end
                end
            end
        end
    end
})

MiscTab:Toggle({
    Title = "Auto Steal (Roubar Itens no Chão)",
    Desc = "Puxa itens dropados no mapa (Muito Roubado)",
    Value = false,
    Callback = function(v)
        State.AutoSteal = v
        if v then
            task.spawn(function()
                while State.AutoSteal do
                    task.wait(0.3)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, item in pairs(Workspace:GetChildren()) do
                            if item.Name == "GunDrop" or item.Name == "KnifeDrop" then
                                if item:FindFirstChild("Handle") then
                                    item.Handle.CFrame = char.HumanoidRootPart.CFrame
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- Respawn fix
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.GodMode then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
    end
    char.Humanoid.WalkSpeed = State.WalkSpeed
    char.Humanoid.JumpPower = State.JumpPower
end)

WindUI:Notify({
    Title = "[F]sk Hub V12",
    Content = "Auto Steal e Loadstring adicionados. Use o raw!",
    Duration = 5
})
