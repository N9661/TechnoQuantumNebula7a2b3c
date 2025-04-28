-- Enhanced whitelist system with anti-tampering measures
local WhitelistSystem = {}

-- Get player services
local Players = game:GetService("Players")
local RbxAnalytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")

-- Create a secure environment marker
local securityMarker = newproxy(true)
getmetatable(securityMarker).__tostring = function() return "SystemSecurity" end

-- Check if script has already been executed
if _G._whitelistExecuted then
    warn("Whitelist system already executed")
    return {IsWhitelisted = function() return false end}
end

-- Set execution flag
_G._whitelistExecuted = securityMarker

-- Check for environment tampering
local function checkEnvironment()
    -- Check for common exploit functions
    local env = getfenv(0)
    local suspiciousFunctions = {
        "hookfunction", "hookmetamethod", "replaceclosure", "setreadonly",
        "make_writeable", "setclipboard", "getgc", "getconnections",
        "firesignal", "fireclickdetector"
    }
    
    for _, funcName in ipairs(suspiciousFunctions) do
        if env[funcName] then
            warn("Suspicious function detected: " .. funcName)
            return false
        end
    end
    
    -- Check if GetService is original
    local success, result = pcall(function()
        local originalGetService = game.GetService
        return originalGetService == game.GetService
    end)
    
    if not success or not result then
        warn("GetService has been tampered with")
        return false
    end
    
    -- Check if ClientId getter is original
    local success2, result2 = pcall(function()
        local originalGetClientId = RbxAnalytics.GetClientId
        return originalGetClientId == RbxAnalytics.GetClientId
    end)
    
    if not success2 or not result2 then
        warn("GetClientId has been tampered with")
        return false
    end
    
    return true
end

-- Load whitelist data from GitHub with verification
local function loadWhitelistData()
    -- Add a random parameter to bypass caching
    local cacheBreaker = tostring(math.random(1000000, 9999999))
    
    local success, data = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/N9661/TechnoQuantumNebula7a2b3c/refs/heads/main/whitelist.lua?cb=" .. cacheBreaker))()
    end)
    
    if not success then
        warn("Failed to load whitelist data: " .. tostring(data))
        return {}
    end
    
    -- Verify data structure
    if type(data) ~= "table" then
        warn("Invalid whitelist data format")
        return {}
    end
    
    return data
end

-- Check if user is whitelisted with anti-spoofing measures
function WhitelistSystem:IsWhitelisted()
    -- Check environment first
    if not checkEnvironment() then
        warn("Environment check failed")
        return false
    end
    
    -- Get current user info with error handling
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
    
    -- Add timing check to detect debuggers
    local startTime = os.clock()
    local counter = 0
    for i = 1, 10000 do
        counter = counter + i
    end
    local endTime = os.clock()
    
    -- If execution took too long, might be debugged
    if endTime - startTime > 0.1 then
        warn("Execution timing anomaly detected")
        return false
    end
    
    -- Load and check against whitelist
    local whitelistedUsers = loadWhitelistData()
    
    -- Create a verification hash of the current user
    local userHash = HttpService:GenerateGUID(false)
    
    for _, user in ipairs(whitelistedUsers) do
        -- Check for exact match with additional verification
        if user.username == currentUsername and user.clientId == currentClientId then
            -- Verify the username length as an additional check
            if #user.username == #currentUsername then
                return true
            end
        end
    end
    
    return false
end

-- Get current user's ClientId (for adding to whitelist)
function WhitelistSystem:GetClientId()
    if not checkEnvironment() then
        return "ERROR"
    end
    
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
    if not checkEnvironment() then
        return "ERROR"
    end
    
    local player = Players.LocalPlayer
    if player then
        return player.Name
    else
        return "Error getting username"
    end
end

-- Add protection against method tampering
local mt = getmetatable(WhitelistSystem) or {}
setmetatable(WhitelistSystem, mt)

mt.__index = function(t, k)
    if k ~= "IsWhitelisted" and k ~= "GetClientId" and k ~= "GetUsername" then
        warn("Attempt to access undefined method: " .. tostring(k))
        return function() return false end
    end
    return rawget(t, k)
end

return WhitelistSystem
