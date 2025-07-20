-- Rayfade UI Lib v5 - Config Schema Support, Full Save/Load, UI Sync
-- Made by d3c0mp0s1ngc0rps3 on Discord

local Rayfade = {}

local UserInputService = game:GetService("UserInputService")

-- Default folder name in Workspace where configs are saved
local ConfigFolderName = "RayfadeConfigFolder"
local ConfigFolderInstance = nil

-- Internal UI refs
local ScreenGui, MainFrame, TopBar, TitleLabel, SubLabel, TabContainer

-- Utility: Create Instance helper
local function create(class, props)
	local inst = Instance.new(class)
	for k,v in pairs(props) do
		inst[k] = v
	end
	return inst
end

-- Setup must be called by script user with config folder name inside Workspace
function Rayfade:Setup(settings)
	ConfigFolderName = settings.FolderName or ConfigFolderName
	ConfigFolderInstance = workspace:FindFirstChild(ConfigFolderName)
	if not ConfigFolderInstance then
		ConfigFolderInstance = Instance.new("Folder")
		ConfigFolderInstance.Name = ConfigFolderName
		ConfigFolderInstance.Parent = workspace
	end
end

-- Creates main UI window, draggable and resizable
function Rayfade:CreateWindow(title)
	ScreenGui = create("ScreenGui", {
		Name = "RayfadeUI",
		ResetOnSpawn = false,
		Parent = game:GetService("CoreGui")
	})
	MainFrame = create("Frame", {
		Size = UDim2.new(0, 520, 0, 400),
		Position = UDim2.new(0.5, -260, 0.5, -200),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = ScreenGui
	})

	-- Top bar with folder name display
	TopBar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 35),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	TitleLabel = create("TextLabel", {
		Text = "Rayfade UI lib, " .. ConfigFolderName,
		Font = Enum.Font.Code,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = TopBar
	})

	SubLabel = create("TextLabel", {
		Text = "Made by d3c0mp0s1ngc0rps3 on Discord",
		Font = Enum.Font.Code,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(150, 150, 150),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 20),
		Position = UDim2.new(0, 10, 0, 35),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = MainFrame
	})

	-- Draggable top bar logic
	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
											startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Resizer corner
	local resizer = create("Frame", {
		Size = UDim2.new(0, 15, 0, 15),
		Position = UDim2.new(1, -15, 1, -15),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = Color3.fromRGB(80, 80, 80),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	local resizing = false
	local startSize, startMousePos
	resizer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startSize = MainFrame.Size
			startMousePos = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - startMousePos
			MainFrame.Size = UDim2.new(0,
				math.clamp(startSize.X.Offset + delta.X, 350, 1000),
				0,
				math.clamp(startSize.Y.Offset + delta.Y, 300, 800))
		end
	end)

	-- Tab container
	TabContainer = create("Frame", {
		Size = UDim2.new(1, 0, 1, -75),
		Position = UDim2.new(0, 0, 0, 65),
		BackgroundTransparency = 1,
		Parent = MainFrame
	})

	return self
end

-- Create a tab
function Rayfade:CreateTab(name)
	local tab = {}

	local scrollingFrame = create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = TabContainer,
	})
	local layout = create("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scrollingFrame,
	})

	local function updateCanvas()
		wait()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

	-- Hold refs to UI elements by key for syncing with config
	tab.UIElements = {}

	-- BUTTON
	function tab:AddButton(text, callback)
		local btn = create("TextButton", {
			Size = UDim2.new(1, -20, 0, 30),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			Text = text,
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Code,
			TextSize = 16,
			Parent = scrollingFrame
		})
		btn.MouseButton1Click:Connect(function()
			pcall(callback)
		end)
	end

	-- TEXTBOX
	function tab:AddTextBox(placeholder, key, default, callback)
		local val = default or ""
		local box = create("TextBox", {
			Size = UDim2.new(1, -20, 0, 30),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			PlaceholderText = placeholder,
			Text = val,
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Code,
			TextSize = 16,
			ClearTextOnFocus = false,
			Parent = scrollingFrame
		})

		tab.UIElements[key] = box

		box.FocusLost:Connect(function()
			val = box.Text
			if callback then
				pcall(callback, val)
			end
		end)
	end

	-- DROPDOWN (simple)
	function tab:AddDropdown(label, key, options, default, callback)
		local val = default or options[1]
		local frame = create("Frame", {
			Size = UDim2.new(1, -20, 0, 45),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			Parent = scrollingFrame
		})
		local labelLbl = create("TextLabel", {
			Text = label,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 16,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 5),
			Parent = frame
		})

		local selected = create("TextButton", {
			Text = val,
			Font = Enum.Font.Code,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 14,
			BackgroundColor3 = Color3.fromRGB(45,45,45),
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 5, 0, 25),
			Parent = frame,
			AutoButtonColor = true,
		})

		local menu = create("Frame", {
			Size = UDim2.new(1, 0, 0, #options*25),
			Position = UDim2.new(0, 5, 1, 0),
			BackgroundColor3 = Color3.fromRGB(40,40,40),
			BorderSizePixel = 0,
			Visible = false,
			Parent = frame,
			ClipsDescendants = true,
			ZIndex = 10,
		})

		for i,opt in ipairs(options) do
			local optBtn = create("TextButton", {
				Text = opt,
				Font = Enum.Font.Code,
				TextColor3 = Color3.new(1,1,1),
				TextSize = 14,
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundColor3 = Color3.fromRGB(50,50,50),
				Parent = menu,
			})
			optBtn.MouseButton1Click:Connect(function()
				selected.Text = opt
				menu.Visible = false
				val = opt
				if callback then
					pcall(callback, val)
				end
			end)
		end

		selected.MouseButton1Click:Connect(function()
			menu.Visible = not menu.Visible
		end)

		tab.UIElements[key] = selected
	end

	-- TOGGLE
	function tab:AddToggle(label, key, default, callback)
		local state = default or false
		local toggle = create("TextButton", {
			Size = UDim2.new(1, -20, 0, 30),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			Text = label..": "..(state and "ON" or "OFF"),
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Code,
			TextSize = 16,
			Parent = scrollingFrame
		})

		tab.UIElements[key] = toggle

		toggle.MouseButton1Click:Connect(function()
			state = not state
			toggle.Text = label..": "..(state and "ON" or "OFF")
			if callback then
				pcall(callback, state)
			end
		end)
	end

	-- KEYBIND PICKER
	function tab:AddKeybind(label, key, default, callback)
		local picking = false
		local keyName = default or "[Not set]"
		local btn = create("TextButton", {
			Size = UDim2.new(1, -20, 0, 30),
			BackgroundColor3 = Color3.fromRGB(60, 60, 60),
			Text = label .. ": " .. keyName,
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.Code,
			TextSize = 16,
			Parent = scrollingFrame
		})

		tab.UIElements[key] = btn

		btn.MouseButton1Click:Connect(function()
			if picking then return end
			picking = true
			btn.Text = label .. ": [Press key]"
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					keyName = input.KeyCode.Name
					btn.Text = label .. ": " .. keyName
					if callback then
						pcall(callback, keyName)
					end
					picking = false
					conn:Disconnect()
				end
			end)
		end)
	end

	-- Save current config (all UI values) to Workspace Folder as Folder + StringValues
	function tab:SaveConfig(name)
		if not ConfigFolderInstance then
			warn("Config folder missing in Workspace")
			return false, "Config folder missing"
		end
		local folder = ConfigFolderInstance:FindFirstChild(name)
		if folder then folder:Destroy() end
		local newFolder = Instance.new("Folder")
		newFolder.Name = name
		newFolder.Parent = ConfigFolderInstance

		for key, uiElement in pairs(tab.UIElements) do
			local value = nil
			local class = uiElement.ClassName

			if class == "TextBox" then
				value = uiElement.Text
			elseif class == "TextButton" then
				-- Handle toggle and keybind buttons differently:
				if uiElement.Text:find(":") then
					-- Split on ": " and get value after
					value = uiElement.Text:match(": (.+)$")
				else
					value = uiElement.Text
				end
			else
				value = tostring(uiElement.Text or "")
			end

			local val = Instance.new("StringValue")
			val.Name = key
			val.Value = tostring(value)
			val.Parent = newFolder
		end

		return true
	end

	-- Load config from Workspace folder and update UI elements accordingly
	function tab:LoadConfig(name)
		if not ConfigFolderInstance then
			warn("Config folder missing in Workspace")
			return false, "Config folder missing"
		end
		local folder = ConfigFolderInstance:FindFirstChild(name)
		if not folder then
			warn("Config not found:", name)
			return false, "Config not found"
		end

		for _, val in pairs(folder:GetChildren()) do
			if val:IsA("StringValue") then
				local key = val.Name
				local value = val.Value
				local uiElement = tab.UIElements[key]

				if uiElement then
					local class = uiElement.ClassName

					if class == "TextBox" then
						uiElement.Text = value

					elseif class == "TextButton" then
						if uiElement.Text:find(":") then
							-- Toggle or keybind: update text accordingly
							local label = uiElement.Text:match("^(.-):")
							uiElement.Text = label .. ": " .. value
						else
							uiElement.Text = value
						end

					else
						uiElement.Text = tostring(value)
					end
				end
			end
		end

		return true
	end

	return tab
end

return Rayfade
