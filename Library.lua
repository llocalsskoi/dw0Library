local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
	Theme = {
		BackgroundOutline = Color3.fromRGB(10, 10, 10),
		Background = Color3.fromRGB(25, 27, 25)
	},
	Utils = { Showed = true, Key = nil }
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
	local dragging, dragStart, startPos = false, nil, nil
	local handle = dragHandle or frame
	handle = typeof(handle) == "table" and handle[1] or handle

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	Input.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- ================================================================
-- Фабрика элементов — переиспользуется и в Tab и в Box
-- ================================================================
local function BuildElements(Container, AccentColor)
	local ItemCount = 0
	local API = {}

	local function NewItem(height)
		ItemCount += 1
		return CreateObj("Frame", {
			Parent = Container,
			Size = UDim2.new(1, 0, 0, height or 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = ItemCount
		})
	end

	function API:AddToggle(Params)
		if not Params then return end
		local State = Params["Default"] or false
		local Callback = Params["Callback"] or function() end
		local Row = NewItem(30)

		CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,6,0,0),
			BackgroundTransparency = 1, Text = Params["Name"] or "Toggle",
			TextColor3 = Color3.fromRGB(200,200,200), TextSize = 13,
			Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
		})

		local ToggleOutline = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(0,36,0,18), Position = UDim2.new(1,-42,0.5,-9),
			BackgroundColor3 = State and AccentColor or Color3.fromRGB(50,50,50), BorderSizePixel = 0
		})
		local ToggleKnob = CreateObj("Frame", {
			Parent = ToggleOutline, Size = UDim2.new(0,12,0,12),
			Position = State and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
			BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0
		})
		local ToggleBtn = CreateObj("TextButton", {
			Parent = Row, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""
		})

		local Obj = { Value = State }
		local function Redraw()
			Tween:Create(ToggleOutline, TweenInfo.new(0.15), {
				BackgroundColor3 = Obj.Value and AccentColor or Color3.fromRGB(50,50,50)
			}):Play()
			Tween:Create(ToggleKnob, TweenInfo.new(0.15), {
				Position = Obj.Value and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)
			}):Play()
		end
		ToggleBtn.MouseButton1Click:Connect(function()
			Obj.Value = not Obj.Value; Redraw(); Callback(Obj.Value)
		end)
		function Obj:Set(v) self.Value = v; Redraw(); Callback(v) end
		return Obj
	end

	function API:AddSlider(Params)
		if not Params then return end
		local Min = Params["Min"] or 0
		local Max = Params["Max"] or 100
		local Default = math.clamp(Params["Default"] or Min, Min, Max)
		local Callback = Params["Callback"] or function() end
		local Row = NewItem(42)

		CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(1,-50,0,16), Position = UDim2.new(0,6,0,2),
			BackgroundTransparency = 1, Text = Params["Name"] or "Slider",
			TextColor3 = Color3.fromRGB(200,200,200), TextSize = 13,
			Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
		})
		local ValLabel = CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(0,44,0,16), Position = UDim2.new(1,-50,0,2),
			BackgroundTransparency = 1, Text = tostring(Default),
			TextColor3 = AccentColor, TextSize = 13,
			Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Right
		})
		local Track = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(1,-12,0,6), Position = UDim2.new(0,6,0,26),
			BackgroundColor3 = Color3.fromRGB(50,50,50), BorderSizePixel = 0
		})
		local Fill = CreateObj("Frame", {
			Parent = Track, Size = UDim2.new((Default-Min)/(Max-Min),0,1,0),
			BackgroundColor3 = AccentColor, BorderSizePixel = 0
		})
		local SliderBtn = CreateObj("TextButton", {
			Parent = Track, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""
		})

		local Obj = { Value = Default }
		local dragging = false

		local function SetValue(v)
			v = math.clamp(math.round(v), Min, Max)
			Obj.Value = v
			Fill.Size = UDim2.new((v-Min)/(Max-Min), 0, 1, 0)
			ValLabel.Text = tostring(v)
			Callback(v)
		end

		SliderBtn.MouseButton1Down:Connect(function() dragging = true end)
		Input.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		Input.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local a = math.clamp((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				SetValue(Min + a*(Max-Min))
			end
		end)
		SliderBtn.MouseButton1Click:Connect(function()
			local mp = Input:GetMouseLocation()
			local a = math.clamp((mp.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
			SetValue(Min + a*(Max-Min))
		end)
		function Obj:Set(v) SetValue(v) end
		return Obj
	end

	function API:AddButton(Params)
		if not Params then return end
		local Callback = Params["Callback"] or function() end
		local Row = NewItem(30)

		local Outline = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(1,-8,1,-6), Position = UDim2.new(0,4,0,3),
			BackgroundColor3 = AccentColor, BorderSizePixel = 0
		})
		local Btn = CreateObj("TextButton", {
			Parent = Outline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
			BackgroundColor3 = Color3.fromRGB(30,32,30), BorderSizePixel = 0,
			Text = Params["Name"] or "Button", TextColor3 = Color3.new(1,1,1),
			TextSize = 13, Font = Enum.Font.Code, AutoButtonColor = false
		})
		Btn.MouseButton1Click:Connect(function()
			Tween:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(45,47,45)}):Play()
			task.delay(0.15, function()
				Tween:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(30,32,30)}):Play()
			end)
			Callback()
		end)
		Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(40,42,40) end)
		Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(30,32,30) end)
	end

	function API:AddTextbox(Params)
		if not Params then return end
		local Callback = Params["Callback"] or function() end
		local Row = NewItem(30)

		CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(0.5,-6,1,0), Position = UDim2.new(0,6,0,0),
			BackgroundTransparency = 1, Text = Params["Name"] or "Input",
			TextColor3 = Color3.fromRGB(200,200,200), TextSize = 13,
			Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
		})
		local Outline = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(0.5,-8,0,22), Position = UDim2.new(0.5,4,0.5,-11),
			BackgroundColor3 = AccentColor, BorderSizePixel = 0
		})
		local Box = CreateObj("TextBox", {
			Parent = Outline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
			BackgroundColor3 = Color3.fromRGB(18,20,18), BorderSizePixel = 0,
			Text = Params["Default"] or "", PlaceholderText = Params["Placeholder"] or "...",
			TextColor3 = Color3.new(1,1,1), PlaceholderColor3 = Color3.fromRGB(100,100,100),
			TextSize = 13, Font = Enum.Font.Code, ClearTextOnFocus = false
		})
		Box.FocusLost:Connect(function(enter) Callback(Box.Text, enter) end)
	end

	function API:AddDropdown(Params)
		if not Params then return end
		local Options = Params["Options"] or {}
		local Callback = Params["Callback"] or function() end
		local Selected = Params["Default"] or (Options[1] or "")
		local Row = NewItem(30)
		local Open = false
		local Obj = { Value = Selected }

		CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(0.5,-6,1,0), Position = UDim2.new(0,6,0,0),
			BackgroundTransparency = 1, Text = Params["Name"] or "Dropdown",
			TextColor3 = Color3.fromRGB(200,200,200), TextSize = 13,
			Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
		})
		local Outline = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(0.5,-8,0,22), Position = UDim2.new(0.5,4,0.5,-11),
			BackgroundColor3 = AccentColor, BorderSizePixel = 0
		})
		local BtnInner = CreateObj("TextButton", {
			Parent = Outline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
			BackgroundColor3 = Color3.fromRGB(18,20,18), BorderSizePixel = 0,
			Text = Selected, TextColor3 = Color3.new(1,1,1),
			TextSize = 12, Font = Enum.Font.Code, AutoButtonColor = false
		})
		local List = CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(0.5,-8,0,#Options*24), Position = UDim2.new(0.5,4,1,2),
			BackgroundColor3 = Color3.fromRGB(18,20,18), BorderSizePixel = 0, Visible = false, ZIndex = 10
		})
		CreateObj("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
		for i, opt in ipairs(Options) do
			local O = CreateObj("TextButton", {
				Parent = List, Size = UDim2.new(1,0,0,24),
				BackgroundColor3 = Color3.fromRGB(22,24,22), BorderSizePixel = 0,
				Text = opt, TextColor3 = Color3.fromRGB(200,200,200),
				TextSize = 12, Font = Enum.Font.Code, AutoButtonColor = false, LayoutOrder = i, ZIndex = 10
			})
			O.MouseEnter:Connect(function() O.BackgroundColor3 = Color3.fromRGB(35,37,35) end)
			O.MouseLeave:Connect(function() O.BackgroundColor3 = Color3.fromRGB(22,24,22) end)
			O.MouseButton1Click:Connect(function()
				Obj.Value = opt; BtnInner.Text = opt; List.Visible = false; Open = false; Callback(opt)
			end)
		end
		BtnInner.MouseButton1Click:Connect(function() Open = not Open; List.Visible = Open end)
		function Obj:Set(val)
			for _,o in ipairs(Options) do
				if o == val then self.Value=val; BtnInner.Text=val; Callback(val); return end
			end
		end
		return Obj
	end

	function API:AddLabel(Params)
		if not Params then return end
		local Row = NewItem(24)
		CreateObj("TextLabel", {
			Parent = Row, Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,6,0,0),
			BackgroundTransparency = 1, Text = Params["Text"] or "",
			TextColor3 = Params["Color"] or Color3.fromRGB(140,140,140),
			TextSize = 12, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	function API:AddSeparator()
		local Row = NewItem(10)
		CreateObj("Frame", {
			Parent = Row, Size = UDim2.new(1,-12,0,1), Position = UDim2.new(0,6,0.5,0),
			BackgroundColor3 = Color3.fromRGB(50,50,50), BorderSizePixel = 0
		})
	end

	return API
end

-- ================================================================

function Library:CreateWindow(Parametrs)
	if not Parametrs or typeof(Parametrs["Name"]) ~= "string" then return end

	local WindowFrame = CreateObj("Frame",{
		Parent = ScreenGui__, Size = UDim2.new(0,500,0,550),
		AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0),
		BackgroundColor3 = Library.Theme.Background, BackgroundTransparency = 0,
		BorderSizePixel = 0, Visible = true
	})

	local TitleFrame = CreateObj("Frame", {
		Parent = WindowFrame, Size = UDim2.new(1,0,0,40),
		Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1
	})
	local TitleOutline = CreateObj("Frame", {
		Parent = TitleFrame, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
		BackgroundColor3 = Parametrs["Color"], BorderSizePixel = 0
	})
	local TitleInner = CreateObj("Frame", {
		Parent = TitleOutline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
		BackgroundColor3 = Library.Theme.BackgroundOutline, BorderSizePixel = 0
	})
	CreateObj("TextLabel", {
		Parent = TitleInner, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,10,0,0),
		BackgroundTransparency = 1, Text = Parametrs["Name"],
		TextColor3 = Color3.new(1,1,1), TextSize = 14,
		Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
	})

	local WindowOutline = CreateObj("Frame", {
		Parent = WindowFrame, Size = UDim2.new(1,-2,1,-42), Position = UDim2.new(0,1,0,41),
		BackgroundColor3 = Parametrs["Color"], BorderSizePixel = 0
	})
	local WindowInner = CreateObj("Frame", {
		Parent = WindowOutline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
		BackgroundColor3 = Library.Theme.BackgroundOutline, BorderSizePixel = 0
	})

	local ContentContainer = CreateObj("Frame", {
		Parent = WindowInner, Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1, BorderSizePixel = 0
	})

	local TabsFrame = CreateObj("Frame",{
		Parent = WindowFrame, Size = UDim2.new(.265,0,0,550),
		Position = UDim2.new(0,-133,0,0), BackgroundTransparency = 0,
		BackgroundColor3 = Library.Theme.Background, BorderSizePixel = 0, Visible = true
	})
	local TabsOutline = CreateObj("Frame", {
		Parent = TabsFrame, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
		BackgroundColor3 = Parametrs["Color"], BorderSizePixel = 0
	})
	local TabsInner = CreateObj("Frame", {
		Parent = TabsOutline, Size = UDim2.new(1,-2,1,-2), Position = UDim2.new(0,1,0,1),
		BackgroundColor3 = Library.Theme.BackgroundOutline, BorderSizePixel = 0
	})
	CreateObj("UIListLayout", {
		Parent = TabsInner, SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0,2)
	})

	MakeDraggable(WindowFrame, TitleFrame)

	local WindowObj = {}
	local Tabs = {}
	local ActiveTab = nil

	local function SetActiveTab(tab)
		if ActiveTab == tab then return end
		if ActiveTab then
			ActiveTab._Content.Visible = false
			ActiveTab._Button.BackgroundColor3 = Library.Theme.BackgroundOutline
			ActiveTab._ButtonLabel.TextColor3 = Color3.fromRGB(160,160,160)
		end
		ActiveTab = tab
		ActiveTab._Content.Visible = true
		ActiveTab._Button.BackgroundColor3 = Parametrs["Color"]
		ActiveTab._ButtonLabel.TextColor3 = Color3.new(1,1,1)
	end

	function WindowObj:AddTab(TabParams)
		if not TabParams or typeof(TabParams["Name"]) ~= "string" then return end

		local TabButton = CreateObj("TextButton", {
			Parent = TabsInner, Size = UDim2.new(1,-8,0,28),
			BackgroundColor3 = Library.Theme.BackgroundOutline, BorderSizePixel = 0,
			Text = "", AutoButtonColor = false, LayoutOrder = #Tabs + 1
		})
		local TabButtonLabel = CreateObj("TextLabel", {
			Parent = TabButton, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
			Text = TabParams["Name"], TextColor3 = Color3.fromRGB(160,160,160),
			TextSize = 13, Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Center
		})

		-- Двухколоночный контент таба
		local TabContent = CreateObj("Frame", {
			Parent = ContentContainer, Size = UDim2.new(1,-4,1,-4), Position = UDim2.new(0,2,0,2),
			BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false
		})

		-- Левая колонка (ScrollingFrame для боксов)
		local LeftCol = CreateObj("ScrollingFrame", {
			Parent = TabContent, Size = UDim2.new(0.5,-3,1,0), Position = UDim2.new(0,0,0,0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			ScrollBarThickness = 3, ScrollBarImageColor3 = Parametrs["Color"],
			CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y
		})
		CreateObj("UIListLayout", {
			Parent = LeftCol, SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0,5)
		})
		CreateObj("UIPadding", {
			Parent = LeftCol, PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,3)
		})

		-- Правая колонка
		local RightCol = CreateObj("ScrollingFrame", {
			Parent = TabContent, Size = UDim2.new(0.5,-3,1,0), Position = UDim2.new(0.5,3,0,0),
			BackgroundTransparency = 1, BorderSizePixel = 0,
			ScrollBarThickness = 3, ScrollBarImageColor3 = Parametrs["Color"],
			CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y
		})
		CreateObj("UIListLayout", {
			Parent = RightCol, SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0,5)
		})
		CreateObj("UIPadding", {
			Parent = RightCol, PaddingTop = UDim.new(0,4), PaddingLeft = UDim.new(0,3), PaddingRight = UDim.new(0,4)
		})

		-- Вертикальный разделитель
		CreateObj("Frame", {
			Parent = TabContent, Size = UDim2.new(0,1,1,-8), Position = UDim2.new(0.5,-1,0,4),
			BackgroundColor3 = Color3.fromRGB(40,40,40), BorderSizePixel = 0
		})

		local TabObj = {
			_Button = TabButton,
			_ButtonLabel = TabButtonLabel,
			_Content = TabContent
		}

		table.insert(Tabs, TabObj)
		if #Tabs == 1 then SetActiveTab(TabObj) end

		TabButton.MouseButton1Click:Connect(function() SetActiveTab(TabObj) end)
		TabButton.MouseEnter:Connect(function()
			if ActiveTab ~= TabObj then TabButton.BackgroundColor3 = Color3.fromRGB(35,37,35) end
		end)
		TabButton.MouseLeave:Connect(function()
			if ActiveTab ~= TabObj then TabButton.BackgroundColor3 = Library.Theme.BackgroundOutline end
		end)

		-- ============================================================
		-- AddBox — секция в левой или правой колонке
		-- ============================================================
		function TabObj:AddBox(BoxParams)
			if not BoxParams then return end
			local Origin = BoxParams["Origin"] or "Left"
			local ColParent = Origin == "Right" and RightCol or LeftCol

			-- Обёртка с акцентной рамкой
			local BoxOuter = CreateObj("Frame", {
				Parent = ColParent,
				Size = UDim2.new(1,0,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Parametrs["Color"],
				BorderSizePixel = 0,
				LayoutOrder = #ColParent:GetChildren()
			})

			local BoxInner = CreateObj("Frame", {
				Parent = BoxOuter,
				Size = UDim2.new(1,-2,0,0),
				Position = UDim2.new(0,1,0,1),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.BackgroundOutline,
				BorderSizePixel = 0
			})

			-- Заголовок (опционально)
			local headerH = 0
			if BoxParams["Name"] and BoxParams["Name"] ~= "" then
				headerH = 22
				local Header = CreateObj("Frame", {
					Parent = BoxInner, Size = UDim2.new(1,0,0,headerH),
					BackgroundTransparency = 1, BorderSizePixel = 0
				})
				CreateObj("TextLabel", {
					Parent = Header, Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0,8,0,0),
					BackgroundTransparency = 1, Text = BoxParams["Name"],
					TextColor3 = Parametrs["Color"], TextSize = 12,
					Font = Enum.Font.Code, TextXAlignment = Enum.TextXAlignment.Left
				})
				CreateObj("Frame", {
					Parent = Header, Size = UDim2.new(1,-8,0,1), Position = UDim2.new(0,4,1,-1),
					BackgroundColor3 = Parametrs["Color"], BackgroundTransparency = 0.65, BorderSizePixel = 0
				})
			end

			-- Контейнер для элементов
			local BoxBody = CreateObj("Frame", {
				Parent = BoxInner, Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,headerH),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1, BorderSizePixel = 0
			})
			CreateObj("UIListLayout", {
				Parent = BoxBody, SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0,2)
			})
			CreateObj("UIPadding", {
				Parent = BoxBody,
				PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
				PaddingLeft = UDim.new(0,2), PaddingRight = UDim.new(0,2)
			})

			-- Возвращаем объект с полным набором методов
			return BuildElements(BoxBody, Parametrs["Color"])
		end

		return TabObj
	end

	return WindowObj
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
	end
end)

return Library
