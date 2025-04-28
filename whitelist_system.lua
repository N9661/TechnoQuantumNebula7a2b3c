local WhitelistSystem = {}

local Players = game:GetService("Players")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local function loadWhitelistData()
    local success, data = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/N9661/TechnoQuantumNebula7a2b3c/refs/heads/main/Whitelist.lua"))()
    end)
    
    if not success then
        warn("Failed to load whitelist data: " .. tostring(data))
        return {}
    end
    
    return data
end

function WhitelistSystem:IsWhitelisted()
    local currentPlayer = Players.LocalPlayer
    if not currentPlayer then return false end
    
    local currentUsername = currentPlayer.Name
    
    local success, currentClientId = pcall(function()
        return RbxAnalytics:GetClientId()
    end)
    
    if not success then return false end
    
    print("Current Username: " .. currentUsername)
    print("Current ClientId: " .. currentClientId)
    
    local whitelistedUsers = loadWhitelistData()
    
    for _, user in ipairs(whitelistedUsers) do
        print("Checking against: " .. user.username .. ", " .. user.clientId)
        
        if user.username == currentUsername and user.clientId == currentClientId then
            print("User is whitelisted!")
            return true
        end
    end
    
    print("User is not whitelisted")
    return false
end

function WhitelistSystem:GetClientId()
    local success, clientId = pcall(function()
        return RbxAnalytics:GetClientId()
    end)
    
    if success then
        return clientId
    else
        return "Error getting ClientId"
    end
end

function WhitelistSystem:GetUsername()
    local player = Players.LocalPlayer
    if player then
        return player.Name
    else
        return "Error getting username"
    end
end

return WhitelistSystem
