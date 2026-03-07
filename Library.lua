-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    g33t UI Library v1.0                      ║
-- ║        Toggle | Button | Slider | Dropdown | TextBox         ║
-- ╚══════════════════════════════════════════════════════════════╝

local Input   = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ─── Theme ────────────────────────────────────────────────────────────────────
local Theme = {
	Background      = Color3.fromRGB(25, 27, 25),
	BackgroundOutline = Color3.fromRGB(10, 10, 10),
	Element          = Color3.fromRGB(30, 32, 30),
	ElementHover     = Color3.fromRGB(40, 42, 40),
	ElementActive    = Color3.fromRGB(20, 22, 20),
	Text             = Color3.new(1, 1, 1),
	SubText          = Color3.fromRGB(160, 160, 160),
	ToggleOn         = Color3.fromRGB(80, 200, 120),
	ToggleOff        = Color3.fromRGB(60, 60, 60),
	SliderFill       = Color3.fromRGB(100, 180, 255),
	Font             = Enum.Font.Code,
	FontSize         = 13,
}

-- ─── Library ──────────────────────────────────────────────────────────────────
local Library = {
	Theme = Theme,
	Utils = { Showed = true, Key = nil },
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent           = CoreGui
ScreenGui.IgnoreGuiInset   = true
ScreenGui.ResetOnSpawn     = false
ScreenGui.DisplayOrder     = 10000
ScreenGui.Name             = "g33tLibrary"

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function New(class, props, parent)
	local obj = Instance.new(class)
	if parent then obj.Parent = parent end
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

local function TweenProp(obj, time, props)
	Tween:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function MakeDraggable(frame, handle)
	local dragging, dragStart, startPos = false, nil, nil
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = inp.Position
			startPos  = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	Input.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
			                            startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Bordered panel: outer accent → dark inner
local function MakePanel(parent, size, position, accentColor)
	local outer = New("Frame", {
		Size = size, Position = position,
		BackgroundColor3 = accentColor, BorderSizePixel = 0,
	}, parent)
	local inner = New("Frame", {
		Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Theme.BackgroundOutline, BorderSizePixel = 0,
	}, outer)
	return outer, inner
end

-- ─── CreateWindow ─────────────────────────────────────────────────────────────
function Library:CreateWindow(params)
	assert(typeof(params.Name) == "string", "Window Name must be a string")
	local accent = params.Color or Color3.new(1, 1, 1)

	-- Main window frame
	local WindowFrame = New("Frame", {
		Parent = ScreenGui,
		Size = UDim2.new(0, 500, 0, 550),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
	})

	-- Title bar
	local TitleBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
	}, WindowFrame)

	local _, TitleInner = MakePanel(TitleBar, UDim2.new(1, -2, 1, -2), UDim2.new(0, 1, 0, 1), accent)

	New("TextLabel", {
		Size = UDim2.new(1, -12, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = params.Name,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Font = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, TitleInner)

	-- Content outline
	local _, ContentInner = MakePanel(WindowFrame,
		UDim2.new(1, -2, 1, -40),
		UDim2.new(0, 1, 0, 39),
		accent)

	-- Tab buttons strip (left sidebar, width = 120)
	local TabStrip = New("Frame", {
		Size = UDim2.new(0, 120, 1, 0),
		BackgroundColor3 = Theme.BackgroundOutline,
		BorderSizePixel = 0,
	}, ContentInner)

	New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 1),
	}, TabStrip)

	-- Content area (right of TabStrip)
	local TabContent = New("Frame", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 120, 0, 0),
		BackgroundColor3 = Theme.BackgroundOutline,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, ContentInner)

	MakeDraggable(WindowFrame, TitleBar)

	-- ── Window object ──────────────────────────────────────────────────────────
	local Window = {
		_accent  = accent,
		_strip   = TabStrip,
		_content = TabContent,
		_tabs    = {},
		_activeTab = nil,
	}

	function Window:AddTab(tabParams)
		local tabName = tabParams.Name or "Tab"

		-- Button in TabStrip
		local btn = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Text = tabName,
			TextColor3 = Theme.SubText,
			TextSize = Theme.FontSize,
			Font = Theme.Font,
			AutoButtonColor = false,
		}, self._strip)

		-- Page frame in TabContent
		local page = New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
		}, self._content)

		-- Two column layout inside page
		local leftCol = New("Frame", {
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0, 4, 0, 4),
			BackgroundTransparency = 1,
		}, page)
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, leftCol)

		local rightCol = New("Frame", {
			Size = UDim2.new(0.5, -4, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			BackgroundTransparency = 1,
		}, page)
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }, rightCol)

		-- Tab activation
		local Tab = { _page = page, _left = leftCol, _right = rightCol, _accent = self._accent }

		local function activate()
			-- hide all pages, reset all buttons
			for _, t in ipairs(Window._tabs) do
				t._page.Visible = false
				t._btn.TextColor3 = Theme.SubText
				t._btn.BackgroundColor3 = Theme.Element
			end
			page.Visible = true
			btn.TextColor3 = Theme.Text
			btn.BackgroundColor3 = Theme.ElementHover
			Window._activeTab = Tab
		end

		Tab._btn = btn
		btn.MouseButton1Click:Connect(activate)

		-- Hover effects
		btn.MouseEnter:Connect(function()
			if Window._activeTab ~= Tab then
				TweenProp(btn, 0.15, { BackgroundColor3 = Theme.ElementHover })
			end
		end)
		btn.MouseLeave:Connect(function()
			if Window._activeTab ~= Tab then
				TweenProp(btn, 0.15, { BackgroundColor3 = Theme.Element })
			end
		end)

		table.insert(self._tabs, Tab)

		-- Auto-activate first tab
		if #self._tabs == 1 then activate() end

		-- ── Tab:AddBox ──────────────────────────────────────────────────────────
		function Tab:AddBox(boxParams)
			local boxName   = boxParams.Name   or "Box"
			local origin    = boxParams.Origin or "Left"
			local col       = (origin == "Right") and self._right or self._left
			local accentCol = self._accent

			-- Box container
			local boxOuter = New("Frame", {
				Size = UDim2.new(1, 0, 0, 28),  -- grows with UIListLayout
				BackgroundColor3 = accentCol,
				BorderSizePixel = 0,
				LayoutOrder = #col:GetChildren(),
			}, col)

			local boxInner = New("Frame", {
				Size = UDim2.new(1, -2, 1, -2),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundColor3 = Theme.BackgroundOutline,
				BorderSizePixel = 0,
				ClipsDescendants = false,
			}, boxOuter)

			-- Box header
			New("TextLabel", {
				Size = UDim2.new(1, -8, 0, 24),
				Position = UDim2.new(0, 6, 0, 0),
				BackgroundTransparency = 1,
				Text = boxName,
				TextColor3 = accentCol,
				TextSize = 12,
				Font = Theme.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, boxInner)

			-- Elements go below header
			local elemContainer = New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 24),
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
			}, boxInner)
			New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, elemContainer)
			New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, elemContainer)

			-- Auto-resize boxOuter/boxInner when elemContainer grows
			elemContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local h = 24 + elemContainer.AbsoluteSize.Y + 6
				boxOuter.Size = UDim2.new(1, 0, 0, h + 2)
				boxInner.Size = UDim2.new(1, -2, 0, h)
			end)

			-- ── Box object ────────────────────────────────────────────────────────
			local Box = { _container = elemContainer, _accent = accentCol }

			-- ── Helpers shared by elements ────────────────────────────────────────
			local function makeRow(labelText, height)
				local row = New("Frame", {
					Size = UDim2.new(1, 0, 0, height or 24),
					BackgroundColor3 = Theme.Element,
					BorderSizePixel = 0,
					LayoutOrder = #elemContainer:GetChildren(),
				}, elemContainer)
				New("UICorner", { CornerRadius = UDim.new(0, 3) }, row)
				if labelText and labelText ~= "" then
					New("TextLabel", {
						Size = UDim2.new(0.6, 0, 1, 0),
						Position = UDim2.new(0, 6, 0, 0),
						BackgroundTransparency = 1,
						Text = labelText,
						TextColor3 = Theme.Text,
						TextSize = Theme.FontSize,
						Font = Theme.Font,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, row)
				end
				return row
			end

			-- ════════════════════════════════════════════════════════════════
			-- TOGGLE
			-- ════════════════════════════════════════════════════════════════
			function Box:AddToggle(p)
				local name     = p.Name     or "Toggle"
				local value    = p.Default  ~= nil and p.Default or false
				local callback = p.Callback or function() end

				local row = makeRow(name, 26)

				-- Track
				local track = New("Frame", {
					Size = UDim2.new(0, 36, 0, 16),
					Position = UDim2.new(1, -42, 0.5, -8),
					BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
					BorderSizePixel = 0,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

				-- Knob
				local knob = New("Frame", {
					Size = UDim2.new(0, 12, 0, 12),
					Position = value and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
				}, track)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

				local btn = New("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
				}, row)

				local function setToggle(v)
					value = v
					TweenProp(track, 0.15, { BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff })
					TweenProp(knob,  0.15, { Position = v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) })
					callback(value)
				end

				btn.MouseButton1Click:Connect(function() setToggle(not value) end)
				btn.MouseEnter:Connect(function() TweenProp(row, 0.1, { BackgroundColor3 = Theme.ElementHover }) end)
				btn.MouseLeave:Connect(function() TweenProp(row, 0.1, { BackgroundColor3 = Theme.Element }) end)

				return { SetValue = setToggle, GetValue = function() return value end }
			end

			-- ════════════════════════════════════════════════════════════════
			-- BUTTON
			-- ════════════════════════════════════════════════════════════════
			function Box:AddButton(p)
				local name     = p.Name     or "Button"
				local callback = p.Callback or function() end

				local row = makeRow("", 26)
				row.BackgroundColor3 = Theme.ElementActive

				New("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
				}, row)

				local btn = New("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
				}, row)

				btn.MouseButton1Click:Connect(function()
					TweenProp(row, 0.07, { BackgroundColor3 = accentCol })
					task.delay(0.12, function() TweenProp(row, 0.1, { BackgroundColor3 = Theme.ElementActive }) end)
					callback()
				end)
				btn.MouseEnter:Connect(function() TweenProp(row, 0.1, { BackgroundColor3 = Theme.ElementHover }) end)
				btn.MouseLeave:Connect(function() TweenProp(row, 0.1, { BackgroundColor3 = Theme.ElementActive }) end)
			end

			-- ════════════════════════════════════════════════════════════════
			-- SLIDER
			-- ════════════════════════════════════════════════════════════════
			function Box:AddSlider(p)
				local name     = p.Name     or "Slider"
				local min      = p.Min      or 0
				local max      = p.Max      or 100
				local value    = math.clamp(p.Default or min, min, max)
				local callback = p.Callback or function() end

				local row = makeRow("", 42)

				-- Header row inside
				local headerLabel = New("TextLabel", {
					Size = UDim2.new(0.7, 0, 0, 18),
					Position = UDim2.new(0, 6, 0, 3),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)

				local valueLabel = New("TextLabel", {
					Size = UDim2.new(0.3, -6, 0, 18),
					Position = UDim2.new(0.7, 0, 0, 3),
					BackgroundTransparency = 1,
					Text = tostring(value),
					TextColor3 = accentCol,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Right,
				}, row)

				-- Track
				local trackBg = New("Frame", {
					Size = UDim2.new(1, -12, 0, 6),
					Position = UDim2.new(0, 6, 0, 28),
					BackgroundColor3 = Theme.BackgroundOutline,
					BorderSizePixel = 0,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, trackBg)

				local fillPct = (value - min) / (max - min)
				local trackFill = New("Frame", {
					Size = UDim2.new(fillPct, 0, 1, 0),
					BackgroundColor3 = Theme.SliderFill,
					BorderSizePixel = 0,
				}, trackBg)
				New("UICorner", { CornerRadius = UDim.new(1, 0) }, trackFill)

				local function updateSlider(absX)
					local abs   = trackBg.AbsolutePosition.X
					local width = trackBg.AbsoluteSize.X
					local pct   = math.clamp((absX - abs) / width, 0, 1)
					value = math.floor(min + pct * (max - min) + 0.5)
					trackFill.Size = UDim2.new(pct, 0, 1, 0)
					valueLabel.Text = tostring(value)
					callback(value)
				end

				local dragging = false
				local inputBtn = New("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
				}, row)

				inputBtn.MouseButton1Down:Connect(function(x)
					dragging = true
					updateSlider(x)
				end)
				Input.InputChanged:Connect(function(inp)
					if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
						updateSlider(inp.Position.X)
					end
				end)
				Input.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				return {
					SetValue = function(v)
						value = math.clamp(v, min, max)
						local pct = (value - min) / (max - min)
						trackFill.Size = UDim2.new(pct, 0, 1, 0)
						valueLabel.Text = tostring(value)
					end,
					GetValue = function() return value end
				}
			end

			-- ════════════════════════════════════════════════════════════════
			-- DROPDOWN
			-- ════════════════════════════════════════════════════════════════
			function Box:AddDropdown(p)
				local name     = p.Name     or "Dropdown"
				local options  = p.Options  or {}
				local value    = p.Default  or (options[1] or "")
				local callback = p.Callback or function() end
				local isOpen   = false

				local row = makeRow("", 26)

				New("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)

				local selectedLabel = New("TextLabel", {
					Size = UDim2.new(0.45, -22, 1, -4),
					Position = UDim2.new(0.5, 0, 0, 2),
					BackgroundColor3 = Theme.BackgroundOutline,
					Text = value,
					TextColor3 = accentCol,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					BorderSizePixel = 0,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(0, 3) }, selectedLabel)

				local arrowLabel = New("TextLabel", {
					Size = UDim2.new(0, 18, 1, -4),
					Position = UDim2.new(1, -20, 0, 2),
					BackgroundColor3 = Theme.BackgroundOutline,
					Text = "▼",
					TextColor3 = Theme.SubText,
					TextSize = 10,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Center,
					BorderSizePixel = 0,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(0, 3) }, arrowLabel)

				-- Dropdown list (renders above other elements via ZIndex)
				local dropList = New("Frame", {
					Size = UDim2.new(0.5, -2, 0, #options * 22),
					Position = UDim2.new(0.5, 0, 1, 2),
					BackgroundColor3 = Theme.BackgroundOutline,
					BorderSizePixel = 0,
					Visible = false,
					ZIndex = 20,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(0, 3) }, dropList)
				New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, dropList)

				for i, opt in ipairs(options) do
					local optBtn = New("TextButton", {
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						Text = opt,
						TextColor3 = opt == value and accentCol or Theme.SubText,
						TextSize = Theme.FontSize,
						Font = Theme.Font,
						ZIndex = 21,
						LayoutOrder = i,
					}, dropList)
					optBtn.MouseButton1Click:Connect(function()
						value = opt
						selectedLabel.Text = opt
						-- reset all colors
						for _, child in ipairs(dropList:GetChildren()) do
							if child:IsA("TextButton") then
								child.TextColor3 = Theme.SubText
							end
						end
						optBtn.TextColor3 = accentCol
						dropList.Visible = false
						isOpen = false
						arrowLabel.Text = "▼"
						callback(value)
					end)
					optBtn.MouseEnter:Connect(function() optBtn.BackgroundTransparency = 0; optBtn.BackgroundColor3 = Theme.ElementHover end)
					optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
				end

				local toggleBtn = New("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
				}, row)

				toggleBtn.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					dropList.Visible = isOpen
					arrowLabel.Text = isOpen and "▲" or "▼"
				end)

				return {
					SetValue = function(v)
						if table.find(options, v) then
							value = v
							selectedLabel.Text = v
							callback(value)
						end
					end,
					GetValue = function() return value end
				}
			end

			-- ════════════════════════════════════════════════════════════════
			-- TEXTBOX
			-- ════════════════════════════════════════════════════════════════
			function Box:AddTextBox(p)
				local name        = p.Name        or "TextBox"
				local placeholder = p.Placeholder or ""
				local callback    = p.Callback    or function() end

				local row = makeRow("", 26)

				New("TextLabel", {
					Size = UDim2.new(0.4, 0, 1, 0),
					Position = UDim2.new(0, 6, 0, 0),
					BackgroundTransparency = 1,
					Text = name,
					TextColor3 = Theme.Text,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, row)

				local tb = New("TextBox", {
					Size = UDim2.new(0.55, 0, 1, -6),
					Position = UDim2.new(0.42, 0, 0, 3),
					BackgroundColor3 = Theme.BackgroundOutline,
					Text = "",
					PlaceholderText = placeholder,
					PlaceholderColor3 = Theme.SubText,
					TextColor3 = Theme.Text,
					TextSize = Theme.FontSize,
					Font = Theme.Font,
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}, row)
				New("UICorner", { CornerRadius = UDim.new(0, 3) }, tb)
				New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, tb)

				tb.FocusLost:Connect(function(enter)
					callback(tb.Text)
				end)

				-- Highlight on focus
				tb.Focused:Connect(function()    TweenProp(tb, 0.1, { BackgroundColor3 = Theme.ElementHover }) end)
				tb.FocusLost:Connect(function()  TweenProp(tb, 0.1, { BackgroundColor3 = Theme.BackgroundOutline }) end)

				return {
					SetValue = function(v) tb.Text = tostring(v) end,
					GetValue = function() return tb.Text end
				}
			end

			return Box
		end -- AddBox

		return Tab
	end -- AddTab

	-- ── Window visibility helpers ──────────────────────────────────────────────
	function Window:SetVisible(v)
		WindowFrame.Visible = v
		Library.Utils.Showed = v
	end

	function Window:Toggle()
		self:SetVisible(not Library.Utils.Showed)
	end

	return Window
end

-- ─── Global keybind ───────────────────────────────────────────────────────────
function Library:SetKeybind(key)
	Library.Utils.Key = typeof(key) == "EnumItem" and key or Enum.KeyCode[key]
end

Input.InputBegan:Connect(function(inp, gp)
	if gp or Input:GetFocusedTextBox() then return end
	if inp.KeyCode == Library.Utils.Key then
		Library.Utils.Showed = not Library.Utils.Showed
		ScreenGui.Enabled = Library.Utils.Showed
	end
end)

function Library:Unload()
	pcall(function() ScreenGui:Destroy() end)
end

return Library
