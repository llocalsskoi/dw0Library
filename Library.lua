local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- ================================================================
-- THEME (Neverlose-style)
-- ================================================================
local Theme = {
	Bg          = Color3.fromRGB(15, 15, 18),       -- основной фон
	BgSecondary = Color3.fromRGB(20, 20, 24),       -- фон боксов
	BgTertiary  = Color3.fromRGB(26, 26, 32),       -- фон элементов
	Border      = Color3.fromRGB(40, 40, 50),       -- бордер
	BorderLight = Color3.fromRGB(55, 55, 68),       -- светлый бордер
	Accent      = Color3.fromRGB(108, 92, 231),     -- фиолетовый акцент
	AccentDark  = Color3.fromRGB(75, 63, 170),      -- тёмный акцент
	AccentGlow  = Color3.fromRGB(138, 116, 255),    -- светлый акцент
	Text        = Color3.fromRGB(220, 220, 230),    -- основной текст
	TextDim     = Color3.fromRGB(130, 130, 150),    -- приглушённый текст
	TextDisabled= Color3.fromRGB(70, 70, 85),       -- отключённый текст
	TabBg       = Color3.fromRGB(18, 18, 22),       -- фон таб-бара
	CheckOn     = Color3.fromRGB(108, 92, 231),
	CheckOff    = Color3.fromRGB(30, 30, 38),
	SliderFill  = Color3.fromRGB(108, 92, 231),
	SliderBg    = Color3.fromRGB(30, 30, 38),
	ScrollBar   = Color3.fromRGB(60, 55, 90),
}

local Library = {
	Theme = Theme,
	Utils = { Showed = true, Key = nil }
}

getfenv().Objects = {}

local ScreenGui__ = Instance.new("ScreenGui")
ScreenGui__.Parent = CoreGui
ScreenGui__.IgnoreGuiInset = true
ScreenGui__.ResetOnSpawn = false
ScreenGui__.DisplayOrder = 10000
ScreenGui__.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function CreateObj(Class, Props)
	if not Class or not Props then return end
	local Obj = Instance.new(Class)
	table.insert(getfenv().Objects, Obj)
	for k, v in pairs(Props) do
		if k ~= "Parent" then Obj[k] = v end
	end
	if Props.Parent then Obj.Parent = Props.Parent end
	return Obj
end

local function Corner(parent, radius)
	return CreateObj("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius or 4) })
end

local function Stroke(parent, color, thickness, transparency)
	local s = CreateObj("UIStroke", {
		Parent = parent,
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	})
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

local function Gradient(parent, c0, c1, rotation)
	local g = CreateObj("UIGradient", {
		Parent = parent,
		Color = ColorSequence.new(c0, c1),
		Rotation = rotation or 90
	})
	return g
end

local function MakeDraggable(frame, handle)
	local dragging, start, startPos = false, nil, nil
	handle = handle or frame
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			start = i.Position
			startPos = frame.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	Input.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - start
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- ================================================================
-- ЭЛЕМЕНТЫ (фабрика)
-- ================================================================
local function BuildElements(Container, AccentColor)
	AccentColor = AccentColor or Theme.Accent
	local ItemCount = 0
	local API = {}

	local function NewRow(h)
		ItemCount += 1
		local row = CreateObj("Frame", {
			Parent = Container,
			Size = UDim2.new(1, 0, 0, h or 28),
			BackgroundTransparency = 1,
			LayoutOrder = ItemCount
		})
		return row
	end

	-- ── Toggle ──────────────────────────────────────────────────
	function API:AddToggle(P)
		if not P then return end
		local State = P.Default or false
		local Callback = P.Callback or function() end
		local Row = NewRow(28)

		-- Чекбокс (левая сторона, квадратик с галкой)
		local CheckOuter = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(0, 4, 0.5, -7),
			BackgroundColor3 = State and AccentColor or Theme.CheckOff,
			BorderSizePixel = 0
		})
		Corner(CheckOuter, 3)
		Stroke(CheckOuter, State and AccentColor or Theme.BorderLight, 1)

		local CheckMark = CreateObj("TextLabel", {
			Parent = CheckOuter,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "✓",
			TextColor3 = Color3.new(1,1,1),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextTransparency = State and 0 or 1
		})

		CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.new(0, 24, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Name or "Toggle",
			TextColor3 = State and Theme.Text or Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local Btn = CreateObj("TextButton", {
			Parent = Row,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = ""
		})

		local Obj = { Value = State }
		local animating = false

		local function Redraw()
			if animating then return end
			animating = true
			local col = Obj.Value and AccentColor or Theme.CheckOff
			local strokeCol = Obj.Value and AccentColor or Theme.BorderLight
			local txtT = Obj.Value and 0 or 1
			local labelCol = Obj.Value and Theme.Text or Theme.TextDim

			Tween:Create(CheckOuter, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {BackgroundColor3 = col}):Play()
			Tween:Create(CheckMark, TweenInfo.new(0.12), {TextTransparency = txtT}):Play()
			-- label ref
			for _, c in ipairs(Row:GetChildren()) do
				if c:IsA("TextLabel") then
					Tween:Create(c, TweenInfo.new(0.18), {TextColor3 = labelCol}):Play()
				end
			end
			task.delay(0.2, function() animating = false end)
		end

		Btn.MouseButton1Click:Connect(function()
			Obj.Value = not Obj.Value
			Redraw()
			Callback(Obj.Value)
		end)

		Btn.MouseEnter:Connect(function()
			if not Obj.Value then
				Tween:Create(CheckOuter, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40,38,60)}):Play()
			end
		end)
		Btn.MouseLeave:Connect(function()
			if not Obj.Value then
				Tween:Create(CheckOuter, TweenInfo.new(0.1), {BackgroundColor3 = Theme.CheckOff}):Play()
			end
		end)

		function Obj:Set(v)
			self.Value = v; Redraw(); Callback(v)
		end
		return Obj
	end

	-- ── Slider ──────────────────────────────────────────────────
	function API:AddSlider(P)
		if not P then return end
		local Min = P.Min or 0
		local Max = P.Max or 100
		local Default = math.clamp(P.Default or Min, Min, Max)
		local Callback = P.Callback or function() end
		local Suffix = P.Suffix or ""
		local Row = NewRow(44)

		-- Верхняя строка: название + значение
		local NameLabel = CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(1, -50, 0, 16),
			Position = UDim2.new(0, 4, 0, 2),
			BackgroundTransparency = 1,
			Text = P.Name or "Slider",
			TextColor3 = Theme.TextDim,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local ValLabel = CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(0, 60, 0, 16),
			Position = UDim2.new(1, -64, 0, 2),
			BackgroundTransparency = 1,
			Text = tostring(Default) .. Suffix,
			TextColor3 = AccentColor,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Right
		})

		-- Трек
		local TrackBg = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(1, -8, 0, 4),
			Position = UDim2.new(0, 4, 0, 26),
			BackgroundColor3 = Theme.SliderBg,
			BorderSizePixel = 0
		})
		Corner(TrackBg, 2)

		local Fill = CreateObj("Frame", {
			Parent = TrackBg,
			Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0),
			BackgroundColor3 = AccentColor,
			BorderSizePixel = 0
		})
		Corner(Fill, 2)
		-- Градиент на заливке
		Gradient(Fill,
			Color3.fromRGB(138, 116, 255),
			AccentColor,
			180
		)

		-- Ползунок
		local Knob = CreateObj("Frame", {
			Parent = TrackBg,
			Size = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = Color3.new(1,1,1),
			BorderSizePixel = 0,
			ZIndex = 3
		})
		Corner(Knob, 5)
		Stroke(Knob, AccentColor, 1)

		local function UpdateKnob(alpha)
			Knob.Position = UDim2.new(alpha, -5, 0.5, -5)
		end
		UpdateKnob((Default - Min) / (Max - Min))

		local SliderBtn = CreateObj("TextButton", {
			Parent = Row,
			Size = UDim2.new(1, -8, 0, 20),
			Position = UDim2.new(0, 4, 0, 20),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 5
		})

		local Obj = { Value = Default }
		local dragging = false

		local function SetValue(v)
			v = math.clamp(math.round(v), Min, Max)
			Obj.Value = v
			local a = (v - Min) / (Max - Min)
			Tween:Create(Fill, TweenInfo.new(0.08), {Size = UDim2.new(a, 0, 1, 0)}):Play()
			UpdateKnob(a)
			ValLabel.Text = tostring(v) .. Suffix
			Callback(v)
		end

		SliderBtn.MouseButton1Down:Connect(function() dragging = true end)
		Input.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		Input.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local abs = TrackBg.AbsolutePosition
				local sz = TrackBg.AbsoluteSize
				SetValue(Min + math.clamp((i.Position.X - abs.X) / sz.X, 0, 1) * (Max - Min))
			end
		end)
		SliderBtn.MouseButton1Click:Connect(function()
			local mp = Input:GetMouseLocation()
			local abs = TrackBg.AbsolutePosition
			local sz = TrackBg.AbsoluteSize
			SetValue(Min + math.clamp((mp.X - abs.X) / sz.X, 0, 1) * (Max - Min))
		end)

		function Obj:Set(v) SetValue(v) end
		return Obj
	end

	-- ── Button ──────────────────────────────────────────────────
	function API:AddButton(P)
		if not P then return end
		local Callback = P.Callback or function() end
		local Row = NewRow(28)

		local Btn = CreateObj("TextButton", {
			Parent = Row,
			Size = UDim2.new(1, -8, 1, -6),
			Position = UDim2.new(0, 4, 0, 3),
			BackgroundColor3 = Theme.BgTertiary,
			BorderSizePixel = 0,
			Text = P.Name or "Button",
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			AutoButtonColor = false
		})
		Corner(Btn, 4)
		Stroke(Btn, Theme.Border, 1)

		Btn.MouseButton1Click:Connect(function()
			Tween:Create(Btn, TweenInfo.new(0.08), {BackgroundColor3 = AccentColor, TextColor3 = Color3.new(1,1,1)}):Play()
			task.delay(0.18, function()
				Tween:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgTertiary, TextColor3 = Theme.TextDim}):Play()
			end)
			Callback()
		end)
		Btn.MouseEnter:Connect(function()
			Tween:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 33, 50), TextColor3 = Theme.Text}):Play()
		end)
		Btn.MouseLeave:Connect(function()
			Tween:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BgTertiary, TextColor3 = Theme.TextDim}):Play()
		end)
	end

	-- ── Textbox ─────────────────────────────────────────────────
	function API:AddTextbox(P)
		if not P then return end
		local Callback = P.Callback or function() end
		local Row = NewRow(28)

		local Label = CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(0.45, -4, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Name or "Input",
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local BoxFrame = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(0.55, -4, 0, 20),
			Position = UDim2.new(0.45, 0, 0.5, -10),
			BackgroundColor3 = Theme.BgTertiary,
			BorderSizePixel = 0
		})
		Corner(BoxFrame, 4)
		local stroke = Stroke(BoxFrame, Theme.Border, 1)

		local Box = CreateObj("TextBox", {
			Parent = BoxFrame,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Default or "",
			PlaceholderText = P.Placeholder or "...",
			TextColor3 = Theme.Text,
			PlaceholderColor3 = Theme.TextDisabled,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false
		})

		Box.Focused:Connect(function()
			Tween:Create(stroke, TweenInfo.new(0.12), {Color = AccentColor}):Play()
		end)
		Box.FocusLost:Connect(function(enter)
			Tween:Create(stroke, TweenInfo.new(0.12), {Color = Theme.Border}):Play()
			Callback(Box.Text, enter)
		end)
	end

	-- ── Dropdown ────────────────────────────────────────────────
	function API:AddDropdown(P)
		if not P then return end
		local Options = P.Options or {}
		local Callback = P.Callback or function() end
		local Selected = P.Default or (Options[1] or "none")
		local Row = NewRow(28)
		local Open = false
		local Obj = { Value = Selected }

		local Label = CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(0.45, -4, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Name or "Dropdown",
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local BtnFrame = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(0.55, -4, 0, 20),
			Position = UDim2.new(0.45, 0, 0.5, -10),
			BackgroundColor3 = Theme.BgTertiary,
			BorderSizePixel = 0,
			ZIndex = 2
		})
		Corner(BtnFrame, 4)
		Stroke(BtnFrame, Theme.Border, 1)

		local BtnLabel = CreateObj("TextButton", {
			Parent = BtnFrame,
			Size = UDim2.new(1, -22, 1, 0),
			Position = UDim2.new(0, 6, 0, 0),
			BackgroundTransparency = 1,
			Text = Selected,
			TextColor3 = Theme.Text,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			ZIndex = 2
		})

		-- Стрелка
		local Arrow = CreateObj("TextLabel", {
			Parent = BtnFrame,
			Size = UDim2.new(0, 16, 1, 0),
			Position = UDim2.new(1, -18, 0, 0),
			BackgroundTransparency = 1,
			Text = "▾",
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			ZIndex = 2
		})

		-- Список опций
		local ListOuter = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(0.55, -4, 0, math.min(#Options, 6) * 22 + 4),
			Position = UDim2.new(0.45, 0, 1, 2),
			BackgroundColor3 = Theme.BgSecondary,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 20,
			ClipsDescendants = true
		})
		Corner(ListOuter, 4)
		Stroke(ListOuter, Theme.Border, 1)

		local ListScroll = CreateObj("ScrollingFrame", {
			Parent = ListOuter,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.ScrollBar,
			CanvasSize = UDim2.new(0, 0, 0, #Options * 22),
			ZIndex = 20
		})
		CreateObj("UIListLayout", {
			Parent = ListScroll,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0)
		})
		CreateObj("UIPadding", {
			Parent = ListScroll,
			PaddingTop = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2)
		})

		for i, opt in ipairs(Options) do
			local OptBtn = CreateObj("TextButton", {
				Parent = ListScroll,
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundColor3 = Theme.BgSecondary,
				BorderSizePixel = 0,
				Text = opt,
				TextColor3 = opt == Selected and Theme.Text or Theme.TextDim,
				TextSize = 11,
				Font = opt == Selected and Enum.Font.GothamBold or Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = 21
			})
			Corner(OptBtn, 3)
			CreateObj("UIPadding", {Parent = OptBtn, PaddingLeft = UDim.new(0, 8)})

			OptBtn.MouseEnter:Connect(function()
				if opt ~= Obj.Value then
					Tween:Create(OptBtn, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(30, 28, 45)}):Play()
				end
			end)
			OptBtn.MouseLeave:Connect(function()
				if opt ~= Obj.Value then
					Tween:Create(OptBtn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.BgSecondary}):Play()
				end
			end)
			OptBtn.MouseButton1Click:Connect(function()
				Obj.Value = opt
				BtnLabel.Text = opt
				-- сброс всех
				for _, c in ipairs(ListScroll:GetChildren()) do
					if c:IsA("TextButton") then
						c.TextColor3 = Theme.TextDim
						c.Font = Enum.Font.Gotham
						c.BackgroundColor3 = Theme.BgSecondary
					end
				end
				OptBtn.TextColor3 = Theme.Text
				OptBtn.Font = Enum.Font.GothamBold
				OptBtn.BackgroundColor3 = Color3.fromRGB(30, 28, 45)
				ListOuter.Visible = false
				Open = false
				Tween:Create(Arrow, TweenInfo.new(0.12), {Rotation = 0}):Play()
				Callback(opt)
			end)
		end

		BtnLabel.MouseButton1Click:Connect(function()
			Open = not Open
			ListOuter.Visible = Open
			Tween:Create(Arrow, TweenInfo.new(0.12), {Rotation = Open and 180 or 0}):Play()
		end)

		function Obj:Set(val)
			for _, o in ipairs(Options) do
				if o == val then
					self.Value = val
					BtnLabel.Text = val
					Callback(val)
					return
				end
			end
		end
		return Obj
	end

	-- ── Label ───────────────────────────────────────────────────
	function API:AddLabel(P)
		if not P then return end
		local Row = NewRow(20)
		CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Text or "",
			TextColor3 = P.Color or Theme.TextDisabled,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})
	end

	-- ── Separator ───────────────────────────────────────────────
	function API:AddSeparator(P)
		P = P or {}
		local Row = NewRow(14)
		local line = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(1, -8, 0, 1),
			Position = UDim2.new(0, 4, 0.5, 0),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0
		})
		if P.Text then
			-- текст поверх линии
			local lbl = CreateObj("TextLabel", {
				Parent = Row,
				Size = UDim2.new(1, -8, 1, 0),
				Position = UDim2.new(0, 4, 0, 0),
				BackgroundTransparency = 1,
				Text = "  " .. P.Text .. "  ",
				TextColor3 = Theme.TextDisabled,
				TextSize = 10,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end
	end

	-- ── ColorPicker (упрощённый, показывает цветной квадрат) ───
	function API:AddColorPicker(P)
		if not P then return end
		local Callback = P.Callback or function() end
		local Default = P.Default or Color3.fromRGB(108, 92, 231)
		local Row = NewRow(28)
		local Obj = { Value = Default }

		CreateObj("TextLabel", {
			Parent = Row,
			Size = UDim2.new(1, -34, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Name or "Color",
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local Swatch = CreateObj("Frame", {
			Parent = Row,
			Size = UDim2.new(0, 24, 0, 16),
			Position = UDim2.new(1, -28, 0.5, -8),
			BackgroundColor3 = Default,
			BorderSizePixel = 0
		})
		Corner(Swatch, 3)
		Stroke(Swatch, Theme.BorderLight, 1)

		function Obj:Set(v)
			self.Value = v
			Swatch.BackgroundColor3 = v
			Callback(v)
		end
		return Obj
	end

	return API
end

-- ================================================================
-- WINDOW
-- ================================================================
function Library:CreateWindow(P)
	if not P or typeof(P.Name) ~= "string" then return end
	local AccentColor = P.Color or Theme.Accent

	-- Тень (имитация через полупрозрачный фрейм под окном)
	local Shadow = CreateObj("Frame", {
		Parent = ScreenGui__,
		Size = UDim2.new(0, 520, 0, 570),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 3, 0.5, 4),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = 0
	})
	Corner(Shadow, 8)

	-- Основной фрейм
	local Win = CreateObj("Frame", {
		Parent = ScreenGui__,
		Size = UDim2.new(0, 520, 0, 560),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Theme.Bg,
		BorderSizePixel = 0,
		ZIndex = 1
	})
	Corner(Win, 6)
	Stroke(Win, Theme.Border, 1)

	-- Синхронизация тени с движением окна
	local function SyncShadow()
		Shadow.Position = UDim2.new(
			Win.Position.X.Scale, Win.Position.X.Offset + 3,
			Win.Position.Y.Scale, Win.Position.Y.Offset + 4
		)
	end
	RunService.RenderStepped:Connect(SyncShadow)

	-- ── Заголовок ───────────────────────────────────────────────
	local TitleBar = CreateObj("Frame", {
		Parent = Win,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.TabBg,
		BorderSizePixel = 0,
		ZIndex = 2
	})
	-- Скруглить только верхние углы
	Corner(TitleBar, 6)
	-- Закрыть нижние скругления у TitleBar через Frame поверх
	CreateObj("Frame", {
		Parent = TitleBar,
		Size = UDim2.new(1, 0, 0.5, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.TabBg,
		BorderSizePixel = 0,
		ZIndex = 2
	})

	-- Акцентная линия снизу заголовка
	local AccentLine = CreateObj("Frame", {
		Parent = Win,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = AccentColor,
		BorderSizePixel = 0,
		ZIndex = 3
	})
	Gradient(AccentLine,
		AccentColor,
		Color3.fromRGB(60, 48, 140),
		180
	)

	-- Название
	CreateObj("TextLabel", {
		Parent = TitleBar,
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundTransparency = 1,
		Text = P.Name,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	})

	-- Версия / subtitle
	if P.Version then
		CreateObj("TextLabel", {
			Parent = TitleBar,
			Size = UDim2.new(0, 60, 1, 0),
			Position = UDim2.new(1, -74, 0, 0),
			BackgroundTransparency = 1,
			Text = P.Version,
			TextColor3 = Theme.TextDisabled,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 4
		})
	end

	MakeDraggable(Win, TitleBar)

	-- ── Таб-бар (горизонтальный, под заголовком) ────────────────
	local TabBar = CreateObj("Frame", {
		Parent = Win,
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundColor3 = Theme.TabBg,
		BorderSizePixel = 0,
		ZIndex = 2
	})
	-- Нижняя граница таб-бара
	CreateObj("Frame", {
		Parent = TabBar,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		ZIndex = 3
	})

	local TabList = CreateObj("Frame", {
		Parent = TabBar,
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 3
	})
	CreateObj("UIListLayout", {
		Parent = TabList,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 2)
	})

	-- ── Контент ─────────────────────────────────────────────────
	local ContentArea = CreateObj("Frame", {
		Parent = Win,
		Size = UDim2.new(1, 0, 1, -80),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		ZIndex = 2
	})

	-- ── WindowObj ────────────────────────────────────────────────
	local WindowObj = {}
	local Tabs = {}
	local ActiveTab = nil

	local function SetActiveTab(tab)
		if ActiveTab == tab then return end
		if ActiveTab then
			ActiveTab._Content.Visible = false
			-- сброс кнопки
			Tween:Create(ActiveTab._BtnLabel, TweenInfo.new(0.15), {TextColor3 = Theme.TextDim}):Play()
			ActiveTab._Indicator.BackgroundTransparency = 1
		end
		ActiveTab = tab
		ActiveTab._Content.Visible = true
		Tween:Create(ActiveTab._BtnLabel, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
		ActiveTab._Indicator.BackgroundTransparency = 0
	end

	function WindowObj:AddTab(TP)
		if not TP or typeof(TP.Name) ~= "string" then return end

		-- Кнопка вкладки
		local BtnWidth = math.max(60, #TP.Name * 8 + 20)
		local TabBtn = CreateObj("Frame", {
			Parent = TabList,
			Size = UDim2.new(0, BtnWidth, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = #Tabs + 1,
			ZIndex = 4
		})

		local BtnLabel = CreateObj("TextButton", {
			Parent = TabBtn,
			Size = UDim2.new(1, 0, 1, -2),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = TP.Name,
			TextColor3 = Theme.TextDim,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			AutoButtonColor = false,
			ZIndex = 4
		})

		-- Индикатор активной вкладки (линия снизу)
		local Indicator = CreateObj("Frame", {
			Parent = TabBtn,
			Size = UDim2.new(0.7, 0, 0, 2),
			Position = UDim2.new(0.15, 0, 1, -2),
			BackgroundColor3 = AccentColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5
		})
		Corner(Indicator, 1)

		-- Двухколоночный контент вкладки
		local TabContent = CreateObj("Frame", {
			Parent = ContentArea,
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 2
		})

		-- Левая колонка (боксы)
		local LeftCol = CreateObj("ScrollingFrame", {
			Parent = TabContent,
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.ScrollBar,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 2
		})
		CreateObj("UIListLayout", {
			Parent = LeftCol,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		})
		CreateObj("UIPadding", {
			Parent = LeftCol,
			PaddingRight = UDim.new(0, 2)
		})

		-- Правая колонка
		local RightCol = CreateObj("ScrollingFrame", {
			Parent = TabContent,
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0.5, 4, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.ScrollBar,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 2
		})
		CreateObj("UIListLayout", {
			Parent = RightCol,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		})
		CreateObj("UIPadding", {
			Parent = RightCol,
			PaddingLeft = UDim.new(0, 2)
		})

		local TabObj = {
			_BtnLabel  = BtnLabel,
			_Indicator = Indicator,
			_Content   = TabContent
		}
		table.insert(Tabs, TabObj)
		if #Tabs == 1 then SetActiveTab(TabObj) end

		BtnLabel.MouseButton1Click:Connect(function() SetActiveTab(TabObj) end)
		BtnLabel.MouseEnter:Connect(function()
			if ActiveTab ~= TabObj then
				Tween:Create(BtnLabel, TweenInfo.new(0.1), {TextColor3 = Theme.Text}):Play()
			end
		end)
		BtnLabel.MouseLeave:Connect(function()
			if ActiveTab ~= TabObj then
				Tween:Create(BtnLabel, TweenInfo.new(0.1), {TextColor3 = Theme.TextDim}):Play()
			end
		end)

		-- ── AddBox ───────────────────────────────────────────────
		function TabObj:AddBox(BP)
			if not BP then return end
			local Origin = BP.Origin or "Left"
			local Col = Origin == "Right" and RightCol or LeftCol

			-- Внешняя рамка бокса
			local BoxOuter = CreateObj("Frame", {
				Parent = Col,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.BgSecondary,
				BorderSizePixel = 0,
				LayoutOrder = #Col:GetChildren()
			})
			Corner(BoxOuter, 5)
			Stroke(BoxOuter, Theme.Border, 1)

			-- Заголовок бокса
			if BP.Name and BP.Name ~= "" then
				local Header = CreateObj("Frame", {
					Parent = BoxOuter,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = Theme.BgTertiary,
					BorderSizePixel = 0
				})
				-- Скруглить верхние углы хэдера
				Corner(Header, 5)
				-- Закрыть нижние
				CreateObj("Frame", {
					Parent = Header,
					Size = UDim2.new(1, 0, 0.5, 0),
					Position = UDim2.new(0, 0, 0.5, 0),
					BackgroundColor3 = Theme.BgTertiary,
					BorderSizePixel = 0
				})

				-- Акцентная точка слева от заголовка
				CreateObj("Frame", {
					Parent = Header,
					Size = UDim2.new(0, 3, 0, 12),
					Position = UDim2.new(0, 8, 0.5, -6),
					BackgroundColor3 = AccentColor,
					BorderSizePixel = 0
				})
				Corner(CreateObj("Frame", { -- dummy для скругления точки
					Parent = Header,
					Size = UDim2.new(0, 3, 0, 12),
					Position = UDim2.new(0, 8, 0.5, -6),
					BackgroundColor3 = AccentColor,
					BorderSizePixel = 0
				}), 2)

				CreateObj("TextLabel", {
					Parent = Header,
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 18, 0, 0),
					BackgroundTransparency = 1,
					Text = BP.Name,
					TextColor3 = Theme.Text,
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				-- Нижняя линия заголовка
				CreateObj("Frame", {
					Parent = Header,
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.new(0, 0, 1, -1),
					BackgroundColor3 = Theme.Border,
					BorderSizePixel = 0
				})
			end

			-- Тело бокса
			local BoxBody = CreateObj("Frame", {
				Parent = BoxOuter,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0
			})
			CreateObj("UIListLayout", {
				Parent = BoxBody,
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 0)
			})
			CreateObj("UIPadding", {
				Parent = BoxBody,
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 3),
				PaddingRight = UDim.new(0, 3)
			})

			return BuildElements(BoxBody, AccentColor)
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
		for _, obj in ipairs(ScreenGui__:GetChildren()) do
			if obj:IsA("Frame") then
				obj.Visible = Library.Utils.Showed
			end
		end
	end
end)

return Library
