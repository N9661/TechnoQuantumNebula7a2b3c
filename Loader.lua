-- Simple loader script
local function loadWhitelistSystem()
    local success, whitelist = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/whitelist_system.lua"))()
    end)
    
    if not success then
        warn("Failed to load whitelist system: " .. tostring(whitelist))
        return nil
    end
    
    return whitelist
end

-- Load the whitelist system
local whitelist = loadWhitelistSystem()

-- Check if user is whitelisted
if whitelist and whitelist:IsWhitelisted() then
    print("Access granted - loading script...")
    
    -- Load your UI library
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/memejames/elerium-v2-ui-library//main/Library", true))()
    
    -- Create your UI
    local window = library:AddWindow("Rebirth Farm GUI", {
        main_color = Color3.fromRGB(41, 74, 122),
        min_size = Vector2.new(300, 350),
        can_resize = false,
    })
    
    -- Add your UI elements
    local tab1 = window:AddTab("Main")
    local section1 = tab1:AddSection("Farming", {default = false})
    
    section1:AddToggle("Auto Rebirth", {flag = "autoRebirth", default = false})
    section1:AddSlider("Farm Speed", {flag = "farmSpeed", default = 1, min = 1, max = 10, step = 1})
    
    section1:AddButton("Collect All", function()
        print("Collecting all items...")
    end)
    
    -- Main script loop
    spawn(function()
        while wait(1) do
            if window.flags.autoRebirth then
                print("Auto rebirthing at speed: " .. window.flags.farmSpeed)
            end
        end
    end)
else
    -- User is not whitelisted
    print("Access denied - not whitelisted")
end
