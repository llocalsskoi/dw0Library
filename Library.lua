local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
	Theme = {
		BackgroundOutline = Color3.fromRGB(10, 10, 10),
		Background = Color3.fromRGB(25, 27, 25),
		Accent = Color3.fromRGB(255, 255, 255),
		ElementBg = Color3.fromRGB(18, 20, 18),
		ElementHover = Color3.fromRGB(30, 33, 30),
		Text = Color3.fromRGB(220, 220, 220),
		TextDim = Color3.fromRGB(120, 120, 120),
		Toggle_On = Color3.fromRGB(80, 200, 100),
		Toggle_Off = Color3.fromRGB(50, 50, 50),
	}, --
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

-- Утилита: рисуем тонкую рамку-обводку вокруг frame
local function Outline(parent, color, offset)
	offset = offset or 1
	local o = CreateObj("Frame", {
		Parent = parent,
		Size = UDim2.new(1, offset*2, 1, offset*2),
		Position = UDim2.new(0, -offset, 0, -offset),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = parent.ZIndex - 1
	})
	return o
end

function Library:CreateWindow(Parametrs)
	if not Parametrs then return end
	if typeof(Parametrs["Name"]) ~= "string" then return end

	Library.Theme.Accent = Parametrs["Color"] or Library.Theme.Accent

	local WindowFrame = CreateObj("Frame",{
		Parent = ScreenGui__,
		Size = UDim2.new(0, 500, 0, 550),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Library.Theme.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Visible = true,
		ClipsDescendants = false
	})

	-- Тонкая цветная обводка всего окна
	CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, 2, 1, 2),
		Position = UDim2.new(0, -1, 0, -1),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0,
		ZIndex = 0
	})

	local TitleFrame = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ZIndex = 2
	})

	-- Нижняя линия заголовка — акцентный цвет
	CreateObj("Frame", {
		Parent = TitleFrame,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0,
		ZIndex = 3
	})

	local TitleLabel = CreateObj("TextLabel", {
		Parent = TitleFrame,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = Parametrs["Name"],
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = false,
		TextSize = 13,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3
	})

	-- Правая часть: версия/subtitle
	if Parametrs["SubTitle"] then
		CreateObj("TextLabel", {
			Parent = TitleFrame,
			Size = UDim2.new(0, 150, 1, 0),
			Position = UDim2.new(1, -152, 0, 0),
			BackgroundTransparency = 1,
			Text = Parametrs["SubTitle"],
			TextColor3 = Library.Theme.TextDim,
			TextScaled = false,
			TextSize = 11,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 3
		})
	end

	-- Основная зона контента (правее tabs)
	local ContentFrame = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, -133, 1, -41),
		Position = UDim2.new(0, 133, 0, 41),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ZIndex = 1,
		ClipsDescendants = true
	})

	-- Панель вкладок (tabs sidebar)
	local TabsFrame = CreateObj("Frame",{
		Parent = WindowFrame,
		Size = UDim2.new(0, 132, 1, -41),
		Position = UDim2.new(0, 0, 0, 41),
		BackgroundColor3 = Library.Theme.Background,
		BorderSizePixel = 0,
		Visible = true,
		ZIndex = 2,
		ClipsDescendants = true
	})

	-- Правая граница tabs
	CreateObj("Frame", {
		Parent = TabsFrame,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0,
		ZIndex = 3
	})

	local TabListLayout = CreateObj("UIListLayout", {
		Parent = TabsFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0)
	})

	local TabPadding = CreateObj("UIPadding", {
		Parent = TabsFrame,
		PaddingTop = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 0),
		PaddingRight = UDim.new(0, 0)
	})

	MakeDraggable(WindowFrame, TitleFrame)

	local Window = {}
	local Tabs = {}
	local ActiveTab = nil

	function Window:AddTab(TabParams)
		if not TabParams or typeof(TabParams["Name"]) ~= "string" then return end

		-- Кнопка таба в сайдбаре
		local TabButton = CreateObj("TextButton", {
			Parent = TabsFrame,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Library.Theme.Background,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 3,
			LayoutOrder = #Tabs + 1
		})

		-- Акцентная левая полоска (видна у активного)
		local TabAccent = CreateObj("Frame", {
			Parent = TabButton,
			Size = UDim2.new(0, 2, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Parametrs["Color"],
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 4
		})

		local TabLabel = CreateObj("TextLabel", {
			Parent = TabButton,
			Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			Text = TabParams["Name"],
			TextColor3 = Library.Theme.TextDim,
			TextScaled = false,
			TextSize = 12,
			Font = Enum.Font.Code,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4
		})

		-- Контент-фрейм таба (внутри ContentFrame)
		local TabContent = CreateObj("Frame", {
			Parent = ContentFrame,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 2,
			ClipsDescendants = true
		})

		-- Два столбца (Left / Right)
		local LeftScroll = CreateObj("ScrollingFrame", {
			Parent = TabContent,
			Size = UDim2.new(0.5, -5, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Parametrs["Color"],
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 2
		})

		local LeftLayout = CreateObj("UIListLayout", {
			Parent = LeftScroll,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		})

		CreateObj("UIPadding", {
			Parent = LeftScroll,
			PaddingTop = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0)
		})

		local RightScroll = CreateObj("ScrollingFrame", {
			Parent = TabContent,
			Size = UDim2.new(0.5, -5, 1, -10),
			Position = UDim2.new(0.5, 0, 0, 5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Parametrs["Color"],
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 2
		})

		local RightLayout = CreateObj("UIListLayout", {
			Parent = RightScroll,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		})

		CreateObj("UIPadding", {
			Parent = RightScroll,
			PaddingTop = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0)
		})

		local Tab = {
			Content = TabContent,
			LeftScroll = LeftScroll,
			RightScroll = RightScroll
		}
		table.insert(Tabs, Tab)

		-- Активация таба
		local function ActivateTab()
			for _, t in ipairs(Tabs) do
				t.Content.Visible = false
			end
			for _, btn in ipairs(TabsFrame:GetChildren()) do
				if btn:IsA("TextButton") then
					local lbl = btn:FindFirstChildOfClass("TextLabel")
					local acc = btn:FindFirstChildOfClass("Frame")
					if lbl then lbl.TextColor3 = Library.Theme.TextDim end
					if acc then acc.Visible = false end
					btn.BackgroundColor3 = Library.Theme.Background
				end
			end
			TabContent.Visible = true
			TabLabel.TextColor3 = Color3.new(1,1,1)
			TabAccent.Visible = true
			TabButton.BackgroundColor3 = Library.Theme.ElementBg
			ActiveTab = Tab
		end

		TabButton.MouseButton1Click:Connect(ActivateTab)

		-- Первый таб активен по умолчанию
		if #Tabs == 1 then
			ActivateTab()
		end

		-- ===== AddBox =====
		function Tab:AddBox(BoxParams)
			if not BoxParams then return end
			local scrollParent = (BoxParams["Origin"] == "Right") and RightScroll or LeftScroll

			local BoxOuter = CreateObj("Frame", {
				Parent = scrollParent,
				Size = UDim2.new(1, 0, 0, 28), -- будет расти
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.BackgroundOutline,
				BorderSizePixel = 0,
				ZIndex = 3
			})

			-- Акцентная верхняя граница
			CreateObj("Frame", {
				Parent = BoxOuter,
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundColor3 = Parametrs["Color"],
				BorderSizePixel = 0,
				ZIndex = 4
			})

			local BoxHeader = CreateObj("TextLabel", {
				Parent = BoxOuter,
				Size = UDim2.new(1, -10, 0, 24),
				Position = UDim2.new(0, 8, 0, 2),
				BackgroundTransparency = 1,
				Text = BoxParams["Name"] or "Box",
				TextColor3 = Parametrs["Color"],
				TextScaled = false,
				TextSize = 11,
				Font = Enum.Font.Code,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 4
			})

			-- Разделитель под заголовком
			CreateObj("Frame", {
				Parent = BoxOuter,
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 0, 26),
				BackgroundColor3 = Color3.fromRGB(35, 38, 35),
				BorderSizePixel = 0,
				ZIndex = 4
			})

			local ItemsContainer = CreateObj("Frame", {
				Parent = BoxOuter,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 27),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 3
			})

			local ItemsLayout = CreateObj("UIListLayout", {
				Parent = ItemsContainer,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 1)
			})

			CreateObj("UIPadding", {
				Parent = ItemsContainer,
				PaddingBottom = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 0)
			})

			local Box = {}

			-- Вспомогательная функция создания строки элемента
			local function MakeRow(height)
				local row = CreateObj("Frame", {
					Parent = ItemsContainer,
					Size = UDim2.new(1, 0, 0, height or 28),
					BackgroundColor3 = Library.Theme.BackgroundOutline,
					BorderSizePixel = 0,
					ZIndex = 4,
					AutoButtonColor = false
				})
				-- hover-эффект
				local hovering = false
				row.MouseEnter:Connect(function()
					if not hovering then
						hovering = true
						Tween:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementHover}):Play()
					end
				end)
				row.MouseLeave:Connect(function()
					hovering = false
					Tween:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.BackgroundOutline}):Play()
				end)
				return row
			end

			local function MakeLabel(parent, text, xOffset, yOffset, width)
				return CreateObj("TextLabel", {
					Parent = parent,
					Size = UDim2.new(width or 0.65, -(xOffset or 8), 1, 0),
					Position = UDim2.new(0, xOffset or 8, 0, yOffset or 0),
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = Library.Theme.Text,
					TextScaled = false,
					TextSize = 11,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 5
				})
			end

			-- ===== Toggle =====
			function Box:AddToggle(P)
				local value = P["Default"] or false
				local accentColor = Parametrs["Color"]
				local offColor = Color3.fromRGB(35, 38, 35)
				local dimColor = Color3.fromRGB(22, 24, 22)

				local row = MakeRow(26)
				MakeLabel(row, P["Name"] or "Toggle")

				-- Слой 1: самая внешняя обводка (accent / dim)
				local OuterBorder = CreateObj("Frame", {
					Parent = row,
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(1, -28, 0.5, -9),
					BackgroundColor3 = value and accentColor or Color3.fromRGB(40, 43, 40),
					BorderSizePixel = 0,
					ZIndex = 5
				})

				-- Слой 2: внутренний бордер (тёмный разделитель)
				local MidBorder = CreateObj("Frame", {
					Parent = OuterBorder,
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.new(0, 1, 0, 1),
					BackgroundColor3 = Library.Theme.BackgroundOutline,
					BorderSizePixel = 0,
					ZIndex = 6
				})

				-- Слой 3: ещё один внутренний бордер (accent / dim)
				local InnerBorder = CreateObj("Frame", {
					Parent = MidBorder,
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.new(0, 1, 0, 1),
					BackgroundColor3 = value and accentColor or offColor,
					BorderSizePixel = 0,
					ZIndex = 7
				})

				-- Слой 4: ядро — маленький квадрат (заливка)
				local Core = CreateObj("Frame", {
					Parent = InnerBorder,
					Size = UDim2.new(1, -4, 1, -4),
					Position = UDim2.new(0, 2, 0, 2),
					BackgroundColor3 = value and accentColor or dimColor,
					BorderSizePixel = 0,
					ZIndex = 8
				})

				local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local function SetToggle(v)
					value = v
					local borderCol  = v and accentColor or Color3.fromRGB(40, 43, 40)
					local innerCol   = v and accentColor or offColor
					local coreCol    = v and accentColor or dimColor

					Tween:Create(OuterBorder, tweenInfo, { BackgroundColor3 = borderCol }):Play()
					Tween:Create(InnerBorder, tweenInfo, { BackgroundColor3 = innerCol }):Play()
					Tween:Create(Core,        tweenInfo, { BackgroundColor3 = coreCol  }):Play()

					-- Пульс: при включении ядро на миг вспыхивает ярче
					if v then
						local flash = Tween:Create(Core, TweenInfo.new(0.06), {
							BackgroundColor3 = Color3.new(1,1,1)
						})
						flash:Play()
						flash.Completed:Connect(function()
							Tween:Create(Core, TweenInfo.new(0.12), { BackgroundColor3 = accentColor }):Play()
						end)
					end

					if P["Callback"] then P["Callback"](value) end
				end

				row.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						SetToggle(not value)
					end
				end)

				local ToggleObj = {}
				function ToggleObj:Set(v) SetToggle(v) end
				function ToggleObj:Get() return value end
				return ToggleObj
			end

			-- ===== Button =====
			function Box:AddButton(P)
				local row = MakeRow(26)
				row.BackgroundColor3 = Library.Theme.BackgroundOutline

				-- Hover override для кнопки чуть другой
				local btnLabel = CreateObj("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = P["Name"] or "Button",
					TextColor3 = Parametrs["Color"],
					TextScaled = false,
					TextSize = 11,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 5
				})

				row.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						Tween:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(40,43,40)}):Play()
						task.delay(0.1, function()
							Tween:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementHover}):Play()
						end)
						if P["Callback"] then P["Callback"]() end
					end
				end)
			end

			-- ===== Slider =====
			function Box:AddSlider(P)
				local min = P["Min"] or 0
				local max = P["Max"] or 100
				local value = math.clamp(P["Default"] or min, min, max)
				local row = MakeRow(36)

				-- Верхняя строка: название + значение
				local nameLabel = MakeLabel(row, P["Name"] or "Slider", 8, 0, 0.7)
				nameLabel.Size = UDim2.new(0.7, -8, 0, 18)
				nameLabel.Position = UDim2.new(0, 8, 0, 0)

				local valLabel = CreateObj("TextLabel", {
					Parent = row,
					Size = UDim2.new(0.3, -8, 0, 18),
					Position = UDim2.new(0.7, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(value),
					TextColor3 = Library.Theme.TextDim,
					TextScaled = false,
					TextSize = 10,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 5
				})

				local Track = CreateObj("Frame", {
					Parent = row,
					Size = UDim2.new(1, -16, 0, 3),
					Position = UDim2.new(0, 8, 0, 24),
					BackgroundColor3 = Color3.fromRGB(45, 48, 45),
					BorderSizePixel = 0,
					ZIndex = 5
				})

				local Fill = CreateObj("Frame", {
					Parent = Track,
					Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundColor3 = Parametrs["Color"],
					BorderSizePixel = 0,
					ZIndex = 6
				})

				local Knob = CreateObj("Frame", {
					Parent = Track,
					Size = UDim2.new(0, 8, 0, 8),
					Position = UDim2.new((value - min)/(max - min), -4, 0.5, -4),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderSizePixel = 0,
					ZIndex = 7
				})
				CreateObj("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

				local dragging = false

				local function UpdateSlider(inputX)
					local trackAbsPos = Track.AbsolutePosition.X
					local trackAbsSize = Track.AbsoluteSize.X
					local rel = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)
					local step = P["Step"] or 1
					value = math.round(min + rel * (max - min))
					if step then
						value = math.round(value / step) * step
					end
					value = math.clamp(value, min, max)
					local pct = (value - min) / (max - min)
					Fill.Size = UDim2.new(pct, 0, 1, 0)
					Knob.Position = UDim2.new(pct, -4, 0.5, -4)
					valLabel.Text = tostring(value)
					if P["Callback"] then P["Callback"](value) end
				end

				Track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						UpdateSlider(i.Position.X)
					end
				end)

				Input.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						UpdateSlider(i.Position.X)
					end
				end)

				Input.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				local SliderObj = {}
				function SliderObj:Set(v)
					value = math.clamp(v, min, max)
					local pct = (value - min)/(max - min)
					Fill.Size = UDim2.new(pct, 0, 1, 0)
					Knob.Position = UDim2.new(pct, -4, 0.5, -4)
					valLabel.Text = tostring(value)
					if P["Callback"] then P["Callback"](value) end
				end
				function SliderObj:Get() return value end
				return SliderObj
			end

			-- ===== Dropdown =====
			function Box:AddDropdown(P)
				local options = P["Options"] or {}
				local selected = P["Default"] or (options[1] or "Select...")
				local opened = false

				local row = MakeRow(26)

				MakeLabel(row, P["Name"] or "Dropdown", 8, 0, 0.5)

				local SelLabel = CreateObj("TextLabel", {
					Parent = row,
					Size = UDim2.new(0.5, -32, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = selected,
					TextColor3 = Library.Theme.TextDim,
					TextScaled = false,
					TextSize = 10,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Right,
					ZIndex = 5
				})

				-- Стрелка
				local Arrow = CreateObj("TextLabel", {
					Parent = row,
					Size = UDim2.new(0, 16, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					BackgroundTransparency = 1,
					Text = "▾",
					TextColor3 = Parametrs["Color"],
					TextScaled = false,
					TextSize = 12,
					Font = Enum.Font.Code,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 5
				})

				-- Дропдаун список (поверх всего)
				local DropList = CreateObj("Frame", {
					Parent = BoxOuter,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = Library.Theme.BackgroundOutline,
					BorderSizePixel = 0,
					ZIndex = 20,
					Visible = false,
					ClipsDescendants = true
				})

				CreateObj("Frame", {
					Parent = DropList,
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundColor3 = Parametrs["Color"],
					BorderSizePixel = 0,
					ZIndex = 21
				})

				local DropLayout = CreateObj("UIListLayout", {
					Parent = DropList,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 0)
				})

				CreateObj("UIPadding", {
					Parent = DropList,
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2)
				})

				local function BuildOptions()
					for _, c in ipairs(DropList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(options) do
						local optBtn = CreateObj("TextButton", {
							Parent = DropList,
							Size = UDim2.new(1, 0, 0, 22),
							BackgroundColor3 = Library.Theme.BackgroundOutline,
							BorderSizePixel = 0,
							Text = opt,
							TextColor3 = opt == selected and Color3.new(1,1,1) or Library.Theme.TextDim,
							TextScaled = false,
							TextSize = 10,
							Font = Enum.Font.Code,
							AutoButtonColor = false,
							ZIndex = 21
						})
						optBtn.MouseButton1Click:Connect(function()
							selected = opt
							SelLabel.Text = selected
							-- обновить цвет всех
							for _, c in ipairs(DropList:GetChildren()) do
								if c:IsA("TextButton") then
									c.TextColor3 = c.Text == selected and Color3.new(1,1,1) or Library.Theme.TextDim
								end
							end
							if P["Callback"] then P["Callback"](selected) end
						end)
					end
					local h = #options * 22 + 4
					DropList.Size = UDim2.new(1, 0, 0, h)
				end

				BuildOptions()

				local function ToggleDrop()
					opened = not opened
					DropList.Visible = opened
					Arrow.Text = opened and "▴" or "▾"
				end

				row.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						ToggleDrop()
					end
				end)

				local DropObj = {}
				function DropObj:Set(v) selected = v; SelLabel.Text = v; BuildOptions() end
				function DropObj:Get() return selected end
				function DropObj:SetOptions(o) options = o; BuildOptions() end
				return DropObj
			end

			-- ===== TextBox =====
			function Box:AddTextBox(P)
				local value = P["Default"] or ""
				local row = MakeRow(26)

				MakeLabel(row, P["Name"] or "Input", 8, 0, 0.45)

				local TBFrame = CreateObj("Frame", {
					Parent = row,
					Size = UDim2.new(0.52, -8, 0, 16),
					Position = UDim2.new(0.48, 0, 0.5, -8),
					BackgroundColor3 = Color3.fromRGB(15, 17, 15),
					BorderSizePixel = 0,
					ZIndex = 5
				})

				-- Граница текстбокса
				CreateObj("Frame", {
					Parent = TBFrame,
					Size = UDim2.new(1, 2, 1, 2),
					Position = UDim2.new(0, -1, 0, -1),
					BackgroundColor3 = Color3.fromRGB(45, 48, 45),
					BorderSizePixel = 0,
					ZIndex = 4
				})

				local TB = CreateObj("TextBox", {
					Parent = TBFrame,
					Size = UDim2.new(1, -6, 1, 0),
					Position = UDim2.new(0, 4, 0, 0),
					BackgroundTransparency = 1,
					Text = value,
					PlaceholderText = P["Placeholder"] or "...",
					PlaceholderColor3 = Library.Theme.TextDim,
					TextColor3 = Color3.new(1,1,1),
					TextScaled = false,
					TextSize = 10,
					Font = Enum.Font.Code,
					ClearTextOnFocus = P["ClearOnFocus"] ~= false,
					ZIndex = 6
				})

				TB.FocusLost:Connect(function(enter)
					value = TB.Text
					if P["Callback"] then P["Callback"](value, enter) end
				end)

				-- Подсветка активного поля
				TB.Focused:Connect(function()
					Tween:Create(TBFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 22, 20)}):Play()
				end)
				TB.FocusLost:Connect(function()
					Tween:Create(TBFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(15, 17, 15)}):Play()
				end)

				local TBObj = {}
				function TBObj:Set(v) TB.Text = v; value = v end
				function TBObj:Get() return value end
				return TBObj
			end

			return Box
		end

		return Tab
	end

	function Window:SetVisible(v)
		WindowFrame.Visible = v
		Library.Utils.Showed = v
	end

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
		for _, obj in ipairs(ScreenGui__:GetChildren()) do
			if obj:IsA("Frame") then
				obj.Visible = Library.Utils.Showed
			end
		end
	end
end)

return Library
