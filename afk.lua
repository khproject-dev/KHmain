local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

if not Player then
    return
end

local Running = true
local Connections = {}

local Remotes

pcall(function()
    Remotes = require(
        ReplicatedStorage
            :WaitForChild("Shared")
            :WaitForChild("Remotes")
    )
end)

local Telemetry
local IdleRescue

if Remotes then
    pcall(function()
        Telemetry = Remotes.Telemetry
    end)

    pcall(function()
        IdleRescue = Remotes.IdleRescue
    end)
end

local SubmitIdleState
local SubmitIdleFlag

if Telemetry then
    pcall(function()
        SubmitIdleState = Telemetry.SubmitIdleState
    end)
end

if IdleRescue then
    pcall(function()
        SubmitIdleFlag = IdleRescue.SubmitIdleFlag
    end)
end

local function FireIdleState(State)
    if not Running then
        return
    end

    if SubmitIdleState then
        pcall(function()
            SubmitIdleState:FireServer(State)
        end)
    end

    if SubmitIdleFlag then
        pcall(function()
            SubmitIdleFlag:FireServer(State)
        end)
    end
end

local function SendVirtualActivity()
    if not Running then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()

        VirtualUser:Button2Down(
            Vector2.new(0, 0),
            workspace.CurrentCamera.CFrame
        )

        task.wait(0.05)

        VirtualUser:Button2Up(
            Vector2.new(0, 0),
            workspace.CurrentCamera.CFrame
        )
    end)
end

local function RegisterActivity()
    if not Running then
        return
    end

    FireIdleState(false)
end

local function ConnectActivity()
    local Connection = UserInputService.InputBegan:Connect(function()
        RegisterActivity()
    end)

    table.insert(Connections, Connection)

    local Connection2 = UserInputService.InputChanged:Connect(function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch
            or string.find(Input.UserInputType.Name, "Gamepad")
        then
            RegisterActivity()
        end
    end)

    table.insert(Connections, Connection2)
end

local IdleConnection = Player.Idled:Connect(function(IdleTime)
    if not Running then
        return
    end

    FireIdleState(false)

    task.spawn(function()
        SendVirtualActivity()
    end)
end)

table.insert(Connections, IdleConnection)

ConnectActivity()

task.spawn(function()
    while Running do
        task.wait(10)

        if not Running then
            break
        end

        FireIdleState(false)
    end
end)

task.spawn(function()
    while Running do
        task.wait(30)

        if not Running then
            break
        end

        SendVirtualActivity()
        FireIdleState(false)
    end
end)

task.spawn(function()
    while Running do
        task.wait(1)

        if not Running then
            break
        end

        FireIdleState(false)
    end
end)

getgenv().KYOSH_ANTI_AFK = {
    Running = function()
        return Running
    end,

    Stop = function()
        if not Running then
            return
        end

        Running = false

        for _, Connection in ipairs(Connections) do
            pcall(function()
                Connection:Disconnect()
            end)
        end

        table.clear(Connections)
    end,

    Activity = function()
        if Running then
            FireIdleState(false)
            SendVirtualActivity()
        end
    end
}

FireIdleState(false)

print("KYOSH Advanced Anti-AFK loaded")
print("Game-specific AFK protection detected")
print("Idle state protection: ACTIVE")
