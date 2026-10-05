local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

if not Player then
    return
end

local ENV = getgenv and getgenv() or _G

if ENV.KYOSH_ANTI_AFK_V2 then
    pcall(function()
        ENV.KYOSH_ANTI_AFK_V2.Stop()
    end)
end

local Running = true
local Connections = {}
local Character
local Humanoid
local RootPart
local LastActivity = os.clock()

local Config = {
    ActivityInterval = 45,
    CameraInterval = 30,
    MovementInterval = 90,
    MovementDistance = 0.15,
    CameraAngle = 0.5
}

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)
end

local function GetCharacter()
    Character = Player.Character

    if not Character then
        return false
    end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")

    return Humanoid ~= nil and RootPart ~= nil
end

local function RegisterActivity()
    LastActivity = os.clock()
end

local function CameraActivity()
    if not Running then
        return
    end

    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local Original = Camera.CFrame

    Camera.CFrame =
        Original
        * CFrame.Angles(
            math.rad(Config.CameraAngle),
            0,
            0
        )

    task.wait(0.08)

    if Camera then
        Camera.CFrame = Original
    end

    RegisterActivity()
end

local function MovementActivity()
    if not Running then
        return
    end

    if not GetCharacter() then
        return
    end

    if Humanoid.Health <= 0 then
        return
    end

    local Direction = Humanoid.MoveDirection

    if Direction.Magnitude > 0 then
        RegisterActivity()
        return
    end

    local OriginalCFrame = RootPart.CFrame

    RootPart.CFrame =
        OriginalCFrame
        * CFrame.new(
            Config.MovementDistance,
            0,
            0
        )

    task.wait(0.08)

    if RootPart and RootPart.Parent then
        RootPart.CFrame = OriginalCFrame
    end

    RegisterActivity()
end

local function SetupCharacter(NewCharacter)
    Character = NewCharacter

    Humanoid = NewCharacter:WaitForChild(
        "Humanoid",
        10
    )

    RootPart = NewCharacter:WaitForChild(
        "HumanoidRootPart",
        10
    )

    RegisterActivity()
end

local CharacterConnection = Player.CharacterAdded:Connect(
    SetupCharacter
)

table.insert(
    Connections,
    CharacterConnection
)

if Player.Character then
    SetupCharacter(Player.Character)
end

local InputBeganConnection =
    UserInputService.InputBegan:Connect(
        function()
            RegisterActivity()
        end
    )

table.insert(
    Connections,
    InputBeganConnection
)

local InputChangedConnection =
    UserInputService.InputChanged:Connect(
        function(Input)
            if
                Input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                or
                Input.UserInputType ==
                    Enum.UserInputType.Touch
            then
                RegisterActivity()
            end
        end
    )

table.insert(
    Connections,
    InputChangedConnection
)

local IdledConnection =
    Player.Idled:Connect(
        function()
            if not Running then
                return
            end

            RegisterActivity()
        end
    )

table.insert(
    Connections,
    IdledConnection
)

task.spawn(function()
    while Running do
        task.wait(Config.ActivityInterval)

        if not Running then
            break
        end

        RegisterActivity()
    end
end)

task.spawn(function()
    while Running do
        task.wait(Config.CameraInterval)

        if not Running then
            break
        end

        pcall(CameraActivity)
    end
end)

task.spawn(function()
    while Running do
        task.wait(Config.MovementInterval)

        if not Running then
            break
        end

        pcall(MovementActivity)
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KYOSH_ANTI_AFK_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(245, 105)
Main.Position = UDim2.new(0.5, -122, 0, 80)
Main.BackgroundColor3 = Color3.fromRGB(12, 20, 15)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 255, 130)
Stroke.Thickness = 1.5
Stroke.Transparency = 0.15
Stroke.Parent = Main

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(18, 35, 23)
    ),
    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(8, 14, 10)
    )
})
Gradient.Rotation = 90
Gradient.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -25, 0, 30)
Title.Position = UDim2.fromOffset(13, 8)
Title.BackgroundTransparency = 1
Title.Text = "KYOSH // ANTI-AFK"
Title.TextColor3 = Color3.fromRGB(100, 255, 150)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -25, 0, 20)
Status.Position = UDim2.fromOffset(13, 34)
Status.BackgroundTransparency = 1
Status.Text = "CLIENT ACTIVITY • ACTIVE"
Status.TextColor3 = Color3.fromRGB(170, 210, 180)
Status.TextSize = 10
Status.Font = Enum.Font.GothamMedium
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(85, 30)
Toggle.Position = UDim2.new(1, -98, 1, -42)
Toggle.BackgroundColor3 = Color3.fromRGB(35, 130, 65)
Toggle.BorderSizePixel = 0
Toggle.Text = "ON"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 12
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -115, 0, 30)
Info.Position = UDim2.fromOffset(13, 62)
Info.BackgroundTransparency = 1
Info.Text = "Local activity protection"
Info.TextColor3 = Color3.fromRGB(130, 165, 140)
Info.TextSize = 10
Info.Font = Enum.Font.Gotham
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.Parent = Main

local function UpdateUI()
    if Running then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 =
            Color3.fromRGB(35, 130, 65)

        Status.Text =
            "CLIENT ACTIVITY • ACTIVE"

        Status.TextColor3 =
            Color3.fromRGB(100, 255, 150)

        Stroke.Color =
            Color3.fromRGB(70, 255, 130)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 =
            Color3.fromRGB(70, 70, 70)

        Status.Text =
            "CLIENT ACTIVITY • OFF"

        Status.TextColor3 =
            Color3.fromRGB(170, 170, 170)

        Stroke.Color =
            Color3.fromRGB(100, 100, 100)
    end
end

Toggle.MouseButton1Click:Connect(function()
    Running = not Running
    UpdateUI()
end)

local Dragging = false
local DragStart
local StartPosition

Main.InputBegan:Connect(function(Input)
    if
        Input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
            Enum.UserInputType.Touch
    then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

Main.InputEnded:Connect(function(Input)
    if
        Input.UserInputType ==
            Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
            Enum.UserInputType.Touch
    then
        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then
        return
    end

    if
        Input.UserInputType ==
            Enum.UserInputType.MouseMovement
        or
        Input.UserInputType ==
            Enum.UserInputType.Touch
    then
        local Delta =
            Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

ENV.KYOSH_ANTI_AFK_V2 = {
    Stop = function()
        Running = false

        DisconnectAll()

        if ScreenGui then
            ScreenGui:Destroy()
        end

        ENV.KYOSH_ANTI_AFK_V2 = nil
    end,

    Start = function()
        if Running then
            return
        end

        Running = true
        RegisterActivity()
        UpdateUI()
    end,

    Toggle = function()
        Running = not Running
        UpdateUI()
    end,

    Activity = function()
        if Running then
            RegisterActivity()
            pcall(CameraActivity)
        end
    end,

    Running = function()
        return Running
    end
}

UpdateUI()

print("KYOSH Executor Anti-AFK v2 loaded")
print("Client activity mode: ACTIVE")
