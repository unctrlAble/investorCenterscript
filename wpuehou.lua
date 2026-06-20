local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local CalmLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/calmlib/refs/heads/main/src.lua"))()
local window = CalmLib:win("inveztour")
local section = window:tab("asd123", "rbxassetid://6034288294")
local passSection = window:tab("larpGamepass", "rbxassetid://6034288294")
local settingsSection = window:tab("settin' ", "rbxassetid://99579688577014")
local funSection = window:tab("fun", "rbxassetid://109121102062195")

getgenv().antiafk = true
LocalPlayer.Idled:Connect(function()
    if not getgenv().antiafk then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

local activeThreads = {}
local toggleNames = {}

local function createSwitch(tab, name, default, callback)
    getgenv()[name] = default
    table.insert(toggleNames, name)
    
    tab:toggle(name, default, function(bool)
        getgenv()[name] = bool
    end)
    
    task.spawn(function()
        while true do
            if getgenv()[name] then
                pcall(callback)
            end
            task.wait(1)
        end
    end)
end

createSwitch(section, "autoEmail", true, function()
    local Emails = LocalPlayer:FindFirstChild("Emails")
    if Emails then
        for i = 1, 4 do
            local slot = Emails:FindFirstChild("slot" .. i)
            if slot and slot:FindFirstChild("id").Value ~= "" then
                pcall(function() Events.EmailStart:InvokeServer(i) end)
                local ks = {} for k = 1, 100 do table.insert(ks, {key = "a", correct = true}) end
                Events.EmailProgress:FireServer(i, ks)
                Events.EmailSend:InvokeServer(i)
            end
        end
    end
end)

createSwitch(section, "autoCache", true, function()
    local canClear = Events.clearCacheRequest:InvokeServer()
    if canClear == true then pcall(function() Events.clearCacheComplete:InvokeServer() end) end
end)

createSwitch(section, "autoFire", true, function()
    local office = Workspace:FindFirstChild(LocalPlayer.Name .. "_office")
    if office and office:FindFirstChild("Placed") then
        for _, unit in pairs(office.Placed:GetChildren()) do
            local data = unit:FindFirstChild("Data")
            if data and data:FindFirstChild("FireClicksLeft") and data.FireClicksLeft.Value > 0 then
                pcall(function() Events.FireClickExtinguish:FireServer(unit) end)
            end
        end
    end
end)

local passBypass = {
    {"noTax", "FreeTax", true}, {"2xIncome", "DoubleIncome", true}, 
    {"2xToken", "DoubleToken", true}, {"fireFighter", "Firefighters", false},
    {"passiveIncome", "PassiveIncome", true}, {"professional", "Professional", true}, 
    {"3xStock", "TripleStock", true}
}

for _, p in pairs(passBypass) do
    createSwitch(passSection, p[1], p[3], function()
        if LocalPlayer:FindFirstChild("Gamepass") and LocalPlayer.Gamepass:FindFirstChild(p[2]) then
            LocalPlayer.Gamepass[p[2]].Value = true
        end
    end)
end

settingsSection:toggle("antiAFK", true, function(bool)
    getgenv().antiafk = bool
end)

settingsSection:toggle("fullBright", true, function(bool)
    if bool then
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
    else
        Lighting.Brightness = 1; Lighting.ClockTime = 12; Lighting.FogEnd = 10000
    end
end)

settingsSection:toggle("disable3DRendering", false, function(bool)
    RunService:Set3dRenderingEnabled(not bool)
end)

funSection:button("flingPlayer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"))()
end)

window.OnDestroy = function()
    for _, name in pairs(toggleNames) do getgenv()[name] = false end
    getgenv().antiafk = false
    RunService:Set3dRenderingEnabled(true)
end
