local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:Notify({
   Title = "Changelog: 1.0",
   Content = "Added basic functions: Distance, Ayuwoki ESP, Player ESP, Fullbright",
   Duration = 6,
   Image = "vibrate",
})
local main = Rayfield:CreateWindow({
   Name = "Ayucocky Private",
   Icon = "square-user", -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Only given to uhh... idk",
   LoadingSubtitle = "by TritiDium",
   ShowText = "Ayucocky", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "H", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "ayucocky"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local firstTab = main:CreateTab("Game", 4483362458) -- Title, Image
local timerSection = firstTab:CreateSection("time")
local distSection = firstTab:CreateSection("distance")
local esp
local plrEsp
local distance
local espEnabled = false
local plrEspEnabled = false
local bright = false
local lastErrorTime = {}
local healthPercent
local function addPlayersToESP()
    for i,v in pairs(game.Players:GetPlayers()) do
        if v.Character and v:HasAppearanceLoaded() then
            if v.Character:FindFirstChild("Humanoid") then
                healthPercent = v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth
            else
                
            end
            if not v.Character:FindFirstChild("plrESP") then
                print("No ESP for player ".. v.Name .. " present, creating new...")
                local plrEsp = Instance.new("Highlight")
                plrEsp.Parent = v.Character
                plrEsp.Name = "plrESP"
                plrEsp.Adornee = v.Character
            else
                if healthPercent ~= nil and v.Character:FindFirstChild("plrESP") then
                    v.Character:FindFirstChild("plrESP").Enabled = plrEspEnabled
                    if v.Character:FindFirstChild("Humanoid") then
                        if v.Character.Humanoid.Health <= 0 then
                            v.Character:FindFirstChild("plrESP").FillColor = Color3.new(0, 0, 0)
                            v.Character:FindFirstChild("plrESP").OutlineColor = Color3.new(0, 0, 0)
                        else
                            v.Character:FindFirstChild("plrESP").FillColor = Color3.new(1 - healthPercent, healthPercent, 0)
                            v.Character:FindFirstChild("plrESP").OutlineColor = Color3.new(1 - healthPercent - 0.1, healthPercent - 0.1, 0)
                        end
                    else
                        
                    end
                end
            end
        else
            local now = tick()
            if not lastErrorTime[v] or now - lastErrorTime[v] >= 15 then
                print("Can't create ESP for player ".. v.Name.. ", player isn't loaded. Retrying in 15 seconds...")
                lastErrorTime[v] = now
            end
        end
    end
end
game.ReplicatedStorage.Values.Timer:GetPropertyChangedSignal("Value"):Connect(function()
    if game.ReplicatedStorage.Values.Day.Value == true then
        timerSection:Set(tostring(game.ReplicatedStorage.Values.Timer.Value).. " seconds till night")
    else
        timerSection:Set(tostring(game.ReplicatedStorage.Values.Timer.Value).. " seconds till day")
    end
end)
game.ReplicatedStorage.Values.Rage:GetPropertyChangedSignal("Value"):Connect(function()
    if game.Workspace:FindFirstChild("Ayuwoki"):FindFirstChild("AyuwokiESP") then
        game.Workspace:FindFirstChild("Ayuwoki"):FindFirstChild("AyuwokiESP").OutlineColor = Color3.new(game.ReplicatedStorage.Values.Rage.Value/10,0,0)
        game.Workspace:FindFirstChild("Ayuwoki"):FindFirstChild("AyuwokiESP").FillColor = Color3.new(game.ReplicatedStorage.Values.Rage.Value/10 + 0.1,0,0)
    else
        print("No ayuwoki model present, can't change ESP's parameters")
    end
end)
local infoDiv = firstTab:CreateDivider()
local espAyuwoki = firstTab:CreateToggle({
   Name = "Ayuwoki ESP",
   CurrentValue = false,
   Flag = "esp1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       espEnabled = Value
   end,
})
local espPlayers = firstTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "esp2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       plrEspEnabled = Value
   end,
})
local fullbrightBtn = firstTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "fullbright", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       bright = Value
   end,
})
game.Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Ayuwoki" then
        if not child:FindFirstChild("AyuwokiESP") then
            print("No ESP present, recreating...")
            esp = Instance.new("Highlight")
            esp.Parent = child
            esp.Name = "AyuwokiESP"
            esp.Adornee = child
            esp.Enabled = espEnabled
        end
    end
end)
local distErrorCount = 0
local lastDistErrorTime = 0
local distCooldownUntil = 0

game:GetService("RunService").RenderStepped:Connect(function()
    if bright then
        game.Lighting.ClockTime = 12
        game.Lighting.Ambient = Color3.new(1,1,1)
        game.Lighting.FogEnd = 1000
    else
        game.Lighting.ClockTime = 0
        game.Lighting.Ambient = Color3.new(0,0,0)
        game.Lighting.FogEnd = 60
    end

    if game.Workspace:FindFirstChild("Ayuwoki") then
        if not game.Workspace:FindFirstChild("Ayuwoki"):FindFirstChild("AyuwokiESP") then
            print("No ESP present, creating new...")
            local esp = Instance.new("Highlight")
            esp.Parent = game.Workspace:FindFirstChild("Ayuwoki")
            esp.Name = "AyuwokiESP"
            esp.Adornee = game.Workspace:FindFirstChild("Ayuwoki")
        else
            game.Workspace:FindFirstChild("Ayuwoki"):FindFirstChild("AyuwokiESP").Enabled = espEnabled
            if game.Players.LocalPlayer.Character and game.Workspace:FindFirstChild("Ayuwoki") then
                distance = (game.Workspace:FindFirstChild("Ayuwoki"):GetBoundingBox().Position - game.Players.LocalPlayer.Character:GetBoundingBox().Position).Magnitude
            end
        end

        if distance ~= nil then
            distSection:Set("The Ayuwoki is " .. math.round(distance) .. " studs from you")
            -- сброс счётчика если всё ок
            distErrorCount = 0
        else
            local now = tick()
            -- проверяем, не находимся ли в 15-секундном кулдауне
            if now >= distCooldownUntil then
                if now - lastDistErrorTime >= 5 then  -- 5 секунд между сообщениями
                    distErrorCount += 1
                    if distErrorCount < 3 then
                        print("No distance present. The player wasn't loaded or the Ayuwoki doesn't exist yet. Retrying in 5 seconds.")
                    else
                        print("Too many distance errors! Pausing messages for 15 seconds...")
                        distCooldownUntil = now + 15
                        distErrorCount = 0
                    end
                    lastDistErrorTime = now
                end
            end
        end
    else
        distSection:Set("He's gone.")
    end

    addPlayersToESP()
end)