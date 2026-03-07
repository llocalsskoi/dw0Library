local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
	Theme = {
		BackgroundOutline = Color3.fromRGB(10, 10, 10),
		Background = Color3.fromRGB(25, 27, 25),
		ElementBackground = Color3.fromRGB(18, 20, 18),
		ElementHover = Color3.fromRGB(30, 33, 30),
		TextColor = Color3.new(1, 1, 1),
		TextColorDim = Color3.fromRGB(160, 160, 160),
		AccentColor = Color3.fromRGB(255, 255, 255),
		ToggleOn = Color3.fromRGB(80, 200, 100),
		ToggleOff = Color3.fromRGB(60, 60, 60),
		SliderFill = Color3.fromRGB(200, 200, 200),
		DropdownBg = Color3.fromRGB(20, 22, 20),
	},
	Utils = {
		Showed = true,
		Key = nil
	}
}

getfenv().Objects = {}

local ScreenGui__ = Instance.new("ScreenGui")
ScreenGui__.Parent = CoreGui
ScreenGui__.IgnoreGuiInset = true
ScreenGui__.ResetOnSpawn = false
ScreenGui__.DisplayOrder = 10000

local function CreateObj(Class, Parametrs)
	if not Class or not Parametrs then return end
	local Obj = Instance.new(Class)
	table.insert(getfenv().Objects, Obj)
	for p,v in pairs(Parametrs) do Obj[p]=v end
	return Obj
end

local function MakeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local handle = dragHandle or frame
	handle = typeof(handle) == "table" and handle[1] or handle

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Input.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

local function AddPadding(parent, px)
	local pad = CreateObj("UIPadding", {
		Parent = parent,
		PaddingLeft = UDim.new(0, px or 6),
		PaddingRight = UDim.new(0, px or 6),
		PaddingTop = UDim.new(0, px or 6),
		PaddingBottom = UDim.new(0, px or 6),
	})
	return pad
end

function Library:CreateWindow(Parametrs)
	if not Parametrs then return end
	if typeof(Parametrs["Name"]) ~= "string" then return end

	local AccentColor = Parametrs["Color"] or Color3.fromRGB(255,255,255)

	local WindowFrame = CreateObj("Frame",{
		Parent = ScreenGui__,
		Size = UDim2.new(0, 500, 0, 550),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Library.Theme.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = false,
	})

	local TitleFrame = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 5,
	})

	local TitleOutline = CreateObj("Frame", {
		Parent = TitleFrame,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = AccentColor,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local TitleInner = CreateObj("Frame", {
		Parent = TitleOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ZIndex = 5,
	})

	local TitleLabel = CreateObj("TextLabel", {
		Parent = TitleInner,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = Parametrs["Name"],
		TextColor3 = Library.Theme.TextColor,
		TextScaled = false,
		TextSize = 14,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	})

	local WindowOutline = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, -2, 1, -42),
		Position = UDim2.new(0, 1, 0, 41),
		BackgroundColor3 = AccentColor,
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	local WindowInner = CreateObj("Frame", {
		Parent = WindowOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ZIndex = 2,
	})

	local ContentFrame = CreateObj("Frame", {
		Parent = WindowInner,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local TabsFrame = CreateObj("Frame",{
		Parent = WindowFrame,
		Size = UDim2.new(0, 133, 1, 0),
		Position = UDim2.new(0, -133, 0, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Library.Theme.Background,
		BorderSizePixel = 0,
		Visible = true,
		ZIndex = 3,
	})

	local TabsOutline = CreateObj("Frame", {
		Parent = TabsFrame,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = AccentColor,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local TabsInner = CreateObj("Frame", {
		Parent = TabsOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ZIndex = 3,
	})

	local TabsList = CreateObj("ScrollingFrame", {
		Parent = TabsInner,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = AccentColor,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 4,
	})

	local TabsListLayout = CreateObj("UIListLayout", {
		Parent = TabsList,
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})

	local TabsListPad = CreateObj("UIPadding", {
		Parent = TabsList,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	})

	MakeDraggable(WindowFrame, TitleFrame)

	local Window = {}
	local Tabs = {}
	local ActiveTab = nil

	function Window:AddTab(TabParams)
		if not TabParams or typeof(TabParams["Name"]) ~= "string" then return end

		local TabBtn = CreateObj("TextButton", {
			Parent = TabsList,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Library.Theme.ElementBackground,
			BorderSizePixel = 0,
			Text = TabParams["Name"],
			TextColor3 = Library.Theme.TextColorDim,
			TextSize = 13,
			Font = Enum.Font.Code,
			AutoButtonColor = false,
			ZIndex = 5,
		})

		local TabPage = CreateObj("Frame", {
			Parent = ContentFrame,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 3,
		})

		local LeftColumn = CreateObj("ScrollingFrame", {
			Parent = TabPage,
			Size = UDim2.new(0.5, -4, 1, -8),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = AccentColor,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 3,
		})

		local LeftLayout = CreateObj("UIListLayout", {
			Parent = LeftColumn,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		})

		local LeftPad = CreateObj("UIPadding", {
			Parent = LeftColumn,
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 2),
		})

		local RightColumn = CreateObj("ScrollingFrame", {
			Parent = TabPage,
			Size = UDim2.new(0.5, -4, 1, -8),
			Position = UDim2.new(0.5, 0, 0, 4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = AccentColor,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 3,
		})

		local RightLayout = CreateObj("UIListLayout", {
			Parent = RightColumn,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		})

		local RightPad = CreateObj("UIPadding", {
			Parent = RightColumn,
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 4),
		})

		local function SetActive()
			if ActiveTab then
				ActiveTab.Page.Visible = false
				ActiveTab.Button.TextColor3 = Library.Theme.TextColorDim
				ActiveTab.Button.BackgroundColor3 = Library.Theme.ElementBackground
			end
			TabPage.Visible = true
			TabBtn.TextColor3 = Library.Theme.TextColor
			TabBtn.BackgroundColor3 = Library.Theme.ElementHover
			ActiveTab = { Page = TabPage, Button = TabBtn }
		end

		TabBtn.MouseButton1Click:Connect(SetActive)

		if #Tabs == 0 then
			SetActive()
		end

		local Tab = {}
		table.insert(Tabs, Tab)

		function Tab:AddBox(BoxParams)
			if not BoxParams then return end
			local origin = BoxParams["Origin"] or "Left"
			local parent = (origin == "Right") and RightColumn or LeftColumn

			local BoxFrame = CreateObj("Frame", {
				Parent = parent,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.ElementBackground,
				BorderSizePixel = 0,
				ZIndex = 4,
			})

			local BoxOutline = CreateObj("UIStroke", {
				Parent = BoxFrame,
				Color = AccentColor,
				Thickness = 1,
				Transparency = 0.7,
			})

			local BoxTitle = CreateObj("TextLabel", {
				Parent = BoxFrame,
				Size = UDim2.new(1, 0, 0, 24),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = Library.Theme.BackgroundOutline,
				BorderSizePixel = 0,
				Text = " " .. (BoxParams["Name"] or "Box"),
				TextColor3 = AccentColor,
				TextSize = 12,
				Font = Enum.Font.Code,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 5,
			})

			local BoxContent = CreateObj("Frame", {
				Parent = BoxFrame,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 26),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 4,
				ClipsDescendants = true,
			})

			local BoxContentLayout = CreateObj("UIListLayout", {
				Parent = BoxContent,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			})

			local BoxContentPad = CreateObj("UIPadding", {
				Parent = BoxContent,
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			})

			local Box = {}

			function Box:AddToggle(Params)
				local value = Params["Default"] or false
				local callback = Params["Callback"] or function() end

				local Row = CreateObj("Frame", {
					Parent = BoxContent,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 5,
				})

				local Label = CreateObj("TextLabel", {
					Parent = Row,
					Size = UDim2.new(1, -40, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = Params["Name"] or "Toggle",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 6,
				})

				local ToggleBg = CreateObj("Frame", {
					Parent = Row,
					Size = UDim2.new(0, 32, 0, 16),
					Position = UDim2.new(1, -32, 0.5, -8),
					BackgroundColor3 = value and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					ZIndex = 6,
				})

				local ToggleBgCorner = CreateObj("UICorner", {
					Parent = ToggleBg,
					CornerRadius = UDim.new(1, 0),
				})

				local ToggleKnob = CreateObj("Frame", {
					Parent = ToggleBg,
					Size = UDim2.new(0, 12, 0, 12),
					Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 7,
				})

				local ToggleKnobCorner = CreateObj("UICorner", {
					Parent = ToggleKnob,
					CornerRadius = UDim.new(1, 0),
				})

				local ToggleBtn = CreateObj("TextButton", {
					Parent = Row,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 8,
				})

				local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

				ToggleBtn.MouseButton1Click:Connect(function()
					value = not value
					Tween:Create(ToggleBg, tweenInfo, {
						BackgroundColor3 = value and Library.Theme.ToggleOn or Library.Theme.ToggleOff
					}):Play()
					Tween:Create(ToggleKnob, tweenInfo, {
						Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
					}):Play()
					pcall(callback, value)
				end)

				local ToggleAPI = {}
				function ToggleAPI:Set(v)
					value = v
					ToggleBg.BackgroundColor3 = v and Library.Theme.ToggleOn or Library.Theme.ToggleOff
					ToggleKnob.Position = v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
					pcall(callback, v)
				end
				function ToggleAPI:Get() return value end
				return ToggleAPI
			end

			function Box:AddButton(Params)
				local callback = Params["Callback"] or function() end

				local Btn = CreateObj("TextButton", {
					Parent = BoxContent,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = Library.Theme.ElementBackground,
					BorderSizePixel = 0,
					Text = Params["Name"] or "Button",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Code,
					AutoButtonColor = false,
					ZIndex = 5,
				})

				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad)

				Btn.MouseEnter:Connect(function()
					Tween:Create(Btn, tweenInfo, { BackgroundColor3 = Library.Theme.ElementHover }):Play()
				end)
				Btn.MouseLeave:Connect(function()
					Tween:Create(Btn, tweenInfo, { BackgroundColor3 = Library.Theme.ElementBackground }):Play()
				end)
				Btn.MouseButton1Click:Connect(function()
					Tween:Create(Btn, TweenInfo.new(0.05), { BackgroundColor3 = AccentColor }):Play()
					task.delay(0.1, function()
						Tween:Create(Btn, tweenInfo, { BackgroundColor3 = Library.Theme.ElementBackground }):Play()
					end)
					pcall(callback)
				end)

				return Btn
			end

			-- ===================== SLIDER =====================
			function Box:AddSlider(Params)
				local min = Params["Min"] or 0
				local max = Params["Max"] or 100
				local default = Params["Default"] or min
				local callback = Params["Callback"] or function() end
				local value = math.clamp(default, min, max)

				local Row = CreateObj("Frame", {
					Parent = BoxContent,
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 5,
				})

				local LabelRow = CreateObj("Frame", {
					Parent = Row,
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					ZIndex = 5,
				})

				local Label = CreateObj("TextLabel", {
					Parent = LabelRow,
					Size = UDim2.new(0.7, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = Params["Name"] or "Slider",
					TextColor3 = Library.Theme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 6,
				})

				local ValueLabel = CreateObj("TextLabel", {
					Parent = LabelRow,
					Size = UDim2.new(0.3, 0, 1, 0),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(value),
					TextColor3 = Library.Theme.TextColorDim,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 6,
				})

				local Track = CreateObj("Frame", {
					Parent = Row,
					Size = UDim2.new(1, 0, 0, 6),
					Position = UDim2.new(0, 0, 0, 22),
					BackgroundColor3 = Library.Theme.ToggleOff,
					BorderSizePixel = 0,
					ZIndex = 5,
				})

				local TrackCorner = CreateObj("UICorner", {
					Parent = Track,
					CornerRadius = UDim.new(1, 0),
				})

				local Fill = CreateObj("Frame", {
					Parent = Track,
					Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = AccentColor,
					BorderSizePixel = 0,
					ZIndex = 6,
				})

				local FillCorner = CreateObj("UICorner", {
					Parent = Fill,
					CornerRadius = UDim.new(1, 0),
				})

				local Knob = CreateObj("Frame", {
					Parent = Track,
					Size = UDim2.new(0, 12, 0, 12),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 7,
				})

				local KnobCorner = CreateObj("UICorner", {
					Parent = Knob,
					CornerRadius = UDim.new(1, 0),
				})

				local SliderBtn = CreateObj("TextButton", {
					Parent = Track,
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 0, 0.5, -10),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = 8,
				})

				local sliding = false

				local function UpdateSlider(inputX)
					local trackPos = Track.AbsolutePosition.X
					local trackSize = Track.AbsoluteSize.X
					local rel = math.clamp((inputX - trackPos) / trackSize, 0, 1)
					local rounded = min + math.floor((max - min) * rel + 0.5)
					value = rounded
					Fill.Size = UDim2.new(rel, 0, 1, 0)
					Knob.Position = UDim2.new(rel, 0, 0.5, 0)
					ValueLabel.Text = tostring(value)
					pcall(callback, value)
				end

				SliderBtn.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = true
						UpdateSlider(inp.Position.X)
					end
				end)
				SliderBtn.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = false
					end
				end)
				Input.InputChanged:Connect(function(inp)
					if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
						UpdateSlider(inp.Position.X)
					end
				end)
				Input.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = false
					end
				end)

				local SliderAPI = {}
				function SliderAPI:Set(v)
					value = math.clamp(v, min, max)
					local rel = (value - min) / (max - min)
					Fill.Size = UDim2.new(rel, 0, 1, 0)
					Knob.Position = UDim2.new(rel, 0, 0.5, 0)
					ValueLabel.Text = tostring(value)
					pcall(callback, value)
				end
				function SliderAPI:Get() return value end
				return SliderAPI
			end

			-- ===================== DROPDOWN =====================
			function Box:AddDropdown(Params)
				local options = Params["Options"] or {}
				local selected = Params["Default"] or options[1]
				local callback = Params["Callback"] or function() end
				local opened = false

				local Wrapper = CreateObj("Frame", {
					Parent = BoxContent,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 10,
					ClipsDescendants = false,
				})

				local Label = CreateObj("TextLabel", {
					Parent = Wrapper,
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = Params["Name"] or "Dropdown",
					TextColor3 = Library.Theme.TextColorDim,
					TextSize = 11,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
				})

				local DropBtn = CreateObj("TextButton", {
					Parent = Wrapper,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = Library.Theme.ElementBackground,
					BorderSizePixel = 0,
					Text = " " .. tostring(selected or "Select..."),
					TextColor3 = Library.Theme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					ZIndex = 11,
				})

				local DropBtnCorner = CreateObj("UICorner", {
					Parent = DropBtn,
					CornerRadius = UDim.new(0, 3),
				})

				local Arrow = CreateObj("TextLabel", {
					Parent = DropBtn,
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -22, 0, 0),
					BackgroundTransparency = 1,
					Text = "▾",
					TextColor3 = Library.Theme.TextColorDim,
					TextSize = 12,
					Font = Enum.Font.Code,
					ZIndex = 12,
				})

				local DropList = CreateObj("Frame", {
					Parent = DropBtn,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 1, 2),
					BackgroundColor3 = Library.Theme.DropdownBg,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 20,
					ClipsDescendants = true,
				})

				local DropListCorner = CreateObj("UICorner", {
					Parent = DropList,
					CornerRadius = UDim.new(0, 3),
				})

				local DropListStroke = CreateObj("UIStroke", {
					Parent = DropList,
					Color = AccentColor,
					Thickness = 1,
					Transparency = 0.7,
				})

				local DropListLayout = CreateObj("UIListLayout", {
					Parent = DropList,
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0),
				})

				local function RefreshList()
					for _, c in ipairs(DropList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(options) do
						local Item = Instance.new("TextButton")
						Item.Size = UDim2.new(1, 0, 0, 24)
						Item.BackgroundTransparency = 1
						Item.Text = " " .. tostring(opt)
						Item.TextColor3 = (opt == selected) and AccentColor or Library.Theme.TextColor
						Item.TextSize = 12
						Item.Font = Enum.Font.Code
						Item.TextXAlignment = Enum.TextXAlignment.Left
						Item.AutoButtonColor = false
						Item.ZIndex = 21
						Item.Parent = DropList

						Item.MouseEnter:Connect(function()
							Item.BackgroundTransparency = 0.85
							Item.BackgroundColor3 = AccentColor
						end)
						Item.MouseLeave:Connect(function()
							Item.BackgroundTransparency = 1
						end)

						Item.MouseButton1Click:Connect(function()
							selected = opt
							DropBtn.Text = " " .. tostring(selected)
							opened = false
							DropList.Visible = false
							Wrapper.Size = UDim2.new(1, 0, 0, 26)
							Arrow.Text = "▾"
							RefreshList()
							pcall(callback, selected)
						end)
					end
					local totalH = #options * 24
					DropList.Size = UDim2.new(1, 0, 0, totalH)
				end

				DropBtn.MouseButton1Click:Connect(function()
					opened = not opened
					if opened then
						RefreshList()
						DropList.Visible = true
						Wrapper.Size = UDim2.new(1, 0, 0, 26 + (#options * 24) + 4)
						Arrow.Text = "▴"
					else
						DropList.Visible = false
						Wrapper.Size = UDim2.new(1, 0, 0, 26)
						Arrow.Text = "▾"
					end
				end)

				RefreshList()

				local DAPI = {}
				function DAPI:Set(v)
					selected = v
					DropBtn.Text = " " .. tostring(v)
					RefreshList()
					pcall(callback, v)
				end
				function DAPI:Get() return selected end
				function DAPI:SetOptions(newOpts)
					options = newOpts
					RefreshList()
				end
				return DAPI
			end

			-- ===================== TEXTBOX =====================
			function Box:AddTextBox(Params)
				local callback = Params["Callback"] or function() end
				local placeholder = Params["Placeholder"] or "Enter text..."

				local Wrapper = CreateObj("Frame", {
					Parent = BoxContent,
					Size = UDim2.new(1, 0, 0, 38),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ZIndex = 5,
				})

				local Label = CreateObj("TextLabel", {
					Parent = Wrapper,
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = Params["Name"] or "TextBox",
					TextColor3 = Library.Theme.TextColorDim,
					TextSize = 11,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 6,
				})

				local TBox = CreateObj("TextBox", {
					Parent = Wrapper,
					Size = UDim2.new(1, 0, 0, 22),
					Position = UDim2.new(0, 0, 0, 16),
					BackgroundColor3 = Library.Theme.ElementBackground,
					BorderSizePixel = 0,
					Text = "",
					PlaceholderText = placeholder,
					PlaceholderColor3 = Library.Theme.TextColorDim,
					TextColor3 = Library.Theme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					ZIndex = 6,
				})

				local TBoxCorner = CreateObj("UICorner", {
					Parent = TBox,
					CornerRadius = UDim.new(0, 3),
				})

				local TBoxPad = CreateObj("UIPadding", {
					Parent = TBox,
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				})

				local TBoxStroke = CreateObj("UIStroke", {
					Parent = TBox,
					Color = AccentColor,
					Thickness = 1,
					Transparency = 0.85,
				})

				TBox.Focused:Connect(function()
					Tween:Create(TBoxStroke, TweenInfo.new(0.15), { Transparency = 0.3 }):Play()
				end)
				TBox.FocusLost:Connect(function(enterPressed)
					Tween:Create(TBoxStroke, TweenInfo.new(0.15), { Transparency = 0.85 }):Play()
					if enterPressed then
						pcall(callback, TBox.Text)
					end
				end)

				local TBAPI = {}
				function TBAPI:Set(v)
					TBox.Text = tostring(v)
				end
				function TBAPI:Get() return TBox.Text end
				return TBAPI
			end

			return Box
		end

		return Tab
	end

	Library._WindowFrame = WindowFrame

	return Window
end

function Library:Unload()
	pcall(function() ScreenGui__:Destroy() end)
end

function Library:SetKeybind(Key)
	Library.Utils.Key = typeof(Key) == "EnumItem" and Key or Enum.KeyCode[Key]
end

Input.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Input:GetFocusedTextBox() then return end
	if input.KeyCode == Library.Utils.Key then
		Library.Utils.Showed = not Library.Utils.Showed
		if Library._WindowFrame then
			Library._WindowFrame.Visible = Library.Utils.Showed
		end
	end
end)
--
return Library
