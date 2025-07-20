-- Example usage of Rayfade UI Lib with config schema and save/load
local Rayfade = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LT3RTH3GL1TCH3R/RayFade-UI-Library/refs/heads/main/RayFade%20UI%20Library.lua"))()

Rayfade:Setup({
	FolderName = "MyExecutorFolder"
})

local win = Rayfade:CreateWindow("My Awesome Script")

-- Create Config tab with full save/load/sync support
local configTab = Rayfade:CreateTab("Config")

-- Add UI elements and define their config keys + default values + callbacks
configTab:AddToggle("Enable Feature", "enableFeature", true, function(state)
	print("Enable Feature set to:", state)
end)

configTab:AddTextBox("Enter your username", "username", "Guest", function(txt)
	print("Username set to:", txt)
end)

configTab:AddDropdown("Difficulty", "difficulty", {"Easy","Medium","Hard"}, "Medium", function(choice)
	print("Difficulty selected:", choice)
end)

configTab:AddKeybind("Toggle UI", "toggleKey", "F", function(key)
	print("Toggle UI bound to:", key)
end)

-- Save config button
configTab:AddButton("Save Config", function()
	local success, err = configTab:SaveConfig("UserConfig")
	if success then
		print("Config saved!")
	else
		warn("Failed to save config:", err)
	end
end)

-- Load config button
configTab:AddButton("Load Config", function()
	local success, err = configTab:LoadConfig("UserConfig")
	if success then
		print("Config loaded!")
	else
		warn("Failed to load config:", err)
	end
end)
