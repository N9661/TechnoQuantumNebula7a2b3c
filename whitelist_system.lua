-- Simple and reliable whitelist system
local WhitelistSystem = {}

-- Get player services
local Players = game:GetService("Players")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

-- Load whitelist data from GitHub
local function loadWhitelistData()
    local success, data = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/N9661/TechnoQuantumNebula7a2b3c/refs/heads/main/Wwwhitelist.lua"))()
    end)
    
    if not success then
        warn("Failed to load whitelist data: " .. tostring(data))
        return {}
    end
    
    return data
end

-- Check if user is whitelisted
function WhitelistSystem:IsWhitelisted()
    -- Get current user info
    local currentPlayer = Players.LocalPlayer
    if not currentPlayer then 
        warn("LocalPlayer not found")
        return false 
    end
    
    local currentUsername = currentPlayer.Name
    
    local success, currentClientId = pcall(function()
        return RbxAnalytics:GetClientId()
    end)
    
    if not success then 
        warn("Failed to get ClientId")
        return false 
    end
    
    -- Print debug info with quotes to see exact values
    print("Current Username: '" .. currentUsername .. "'")
    print("Current ClientId: '" .. currentClientId .. "'")
    print("ClientId length: " .. #currentClientId)
    
    -- Load and check against whitelist
    local whitelistedUsers = loadWhitelistData()
    
    print("Number of whitelisted users: " .. #whitelistedUsers)
    
    for i, user in ipairs(whitelistedUsers) do
        print("Checking user #" .. i)
        print("Whitelist entry: '" .. user.username .. "', '" .. user.clientId .. "'")
        print("ClientId length in whitelist: " .. #user.clientId)
        
        -- Check for exact match
        if user.username == currentUsername and user.clientId == currentClientId then
            print("User is whitelisted! Exact match found.")
            return true
        end
        
        -- Check for case-insensitive username match and exact ClientId match
        if string.lower(user.username) == string.lower(currentUsername) and user.clientId == currentClientId then
            print("User is whitelisted! Case-insensitive username match.")
            return true
        end
    end
    
    print("User is not whitelisted - no matching entries found")
    return false
end

-- Get current user's ClientId (for adding to whitelist)
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

-- Get current username (for adding to whitelist)
function WhitelistSystem:GetUsername()
    local player = Players.LocalPlayer
    if player then
        return player.Name
    else
        return "Error getting username"
    end
end

return WhitelistSystem
