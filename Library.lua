-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    g33t UI Library v2.0                      ║
-- ║              Linoria / Gamesense inspired style              ║
-- ╚══════════════════════════════════════════════════════════════╝

local Input   = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ─── Theme (Gamesense / Linoria dark) ────────────────────────────────────────
local Theme = {
	WindowBg       = Color3.fromRGB(18, 18, 20),
	TitleBg        = Color3.fromRGB(13, 13, 15),
	Border         = Color3.fromRGB(55, 55, 60),

	TabBg          = Color3.fromRGB(22, 22, 25),
	TabActive      = Color3.fromRGB(28, 28, 32),
	TabText        = Color3.fromRGB(130, 130, 140),
	TabTextActive  = Color3.fromRGB(220, 220, 230),

	SectionBg      = Color3.fromRGB(22, 22, 25),
	SectionBorder  = Color3.fromRGB(45, 45, 52),

	ElemBg         = Color3.fromRGB(28, 28, 32),
	ElemHover      = Color3.fromRGB(34, 34, 40),
	ElemText       = Color3.fromRGB(210, 210, 218),
	ElemSubText    = Color3.fromRGB(100, 100, 115),

	ToggleOn       = Color3.fromRGB(75, 145, 255),
	ToggleOff      = Color3.fromRGB(45, 45, 52),
	ToggleKnob     = Color3.fromRGB(220, 220, 230),

	SliderTrack    = Color3.fromRGB(35, 35, 42),
	SliderFill     = Color3.fromRGB(75, 145, 255),

	InputBg        = Color3.fromRGB(14, 14, 17),
	InputBorder    = Color3.fromRGB(50, 50, 58),

	ScrollBar      = Color3.fromRGB(55, 55, 65),

	Font           = Enum.Font.GothamMedium,
	FontSm         = Enum.Font.Gotham,
	FontSize       = 12,
	FontSizeSm     = 11,
}

-- ─── Library ──────────────────────────────────────────────────────────────────
local Library = {
	Theme = Theme,
	Utils = { Showed = true, Key = nil },
}

getfenv().Objects = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent           = CoreGui
ScreenGui.IgnoreGuiInset   = true
ScreenGui.ResetOnSpawn     = false
ScreenGui.DisplayOrder     = 10000
ScreenGui.Name             = "g33tLibrary"

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function New(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		pcall(function() obj[k] = v end)
	end
	if parent then obj.Parent = parent end
	table.insert(getfenv().Objects, obj)
	return obj
end

local function Tw(obj, t, props)
	Tween:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function Corner(parent, radius)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 4) }, parent)
end

local function Stroke(parent, color, thickness)
	return New("UIStroke", {
		Color           = color or Theme.Border,
		Thickness       = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
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

-- ─── CreateWindow ─────────────────────────────────────────────────────────────
function Library:CreateWindow(Parametrs)
	if not Parametrs then return end
	if typeof(Parametrs["Name"]) ~= "string" then return end

	local accent = Parametrs["Color"] or Color3.fromRGB(75, 145, 255)

	-- Root
	local WindowFrame = New("Frame", {
		Parent           = ScreenGui,
		Size             = UDim2.new(0, 580, 0, 460),
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Theme.WindowBg,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	})
	Corner(WindowFrame, 6)
	Stroke(WindowFrame, Theme.Border, 1)

	-- Shadow
	New("ImageLabel", {
		Parent             = WindowFrame,
		Size               = UDim2.new(1, 36, 1, 36),
		Position           = UDim2.new(0, -18, 0, -18),
		BackgroundTransparency = 1,
		Image              = "rbxassetid://6014261993",
		ImageColor3        = Color3.new(0, 0, 0),
		ImageTransparency  = 0.5,
		ScaleType          = Enum.ScaleType.Slice,
		SliceCenter        = Rect.new(49, 49, 450, 450),
		ZIndex             = -1,
	})

	-- Title bar
	local TitleBar = New("Frame", {
		Parent           = WindowFrame,
		Size             = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.TitleBg,
		BorderSizePixel  = 0,
		ZIndex           = 3,
	})
	-- bottom separator
	New("Frame", {
		Parent           = TitleBar,
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel  = 0,
	})
	-- accent pip
	New("Frame", {
		Parent           = TitleBar,
		Size             = UDim2.new(0, 2, 0, 16),
		Position         = UDim2.new(0, 10, 0.5, -8),
		BackgroundColor3 = accent,
		BorderSizePixel  = 0,
	})
	New("TextLabel", {
		Parent             = TitleBar,
		Size               = UDim2.new(1, -30, 1, 0),
		Position           = UDim2.new(0, 20, 0, 0),
		BackgroundTransparency = 1,
		Text               = Parametrs["Name"],
		TextColor3         = Theme.ElemText,
		TextSize           = 13,
		Font               = Theme.Font,
		TextXAlignment     = Enum.TextXAlignment.Left,
		ZIndex             = 4,
	})
	MakeDraggable(WindowFrame, TitleBar)

	-- Tab strip (left sidebar)
	local TabStrip = New("Frame", {
		Parent           = WindowFrame,
		Size             = UDim2.new(0, 120, 1, -38),
		Position         = UDim2.new(0, 0, 0, 38),
		BackgroundColor3 = Theme.TabBg,
		BorderSizePixel  = 0,
	})
	-- right border
	New("Frame", {
		Parent           = TabStrip,
		Size             = UDim2.new(0, 1, 1, 0),
		Position         = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel  = 0,
	})
	New("UIListLayout", { Parent = TabStrip, SortOrder = Enum.SortOrder.LayoutOrder })

	-- Content pane
	local TabContent = New("Frame", {
		Parent           = WindowFrame,
		Size             = UDim2.new(1, -121, 1, -38),
		Position         = UDim2.new(0, 121, 0, 38),
		BackgroundColor3 = Theme.WindowBg,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
	})

	-- ── Window object ─────────────────────────────────────────────────────────
	local Window = {
		_accent  = accent,
		_strip   = TabStrip,
		_content = TabContent,
		_frame   = WindowFrame,
		_tabs    = {},
		_active  = nil,
	}

	-- ── Window:AddTab ─────────────────────────────────────────────────────────
	function Window:AddTab(tabParams)
		local tabName = tabParams.Name or "Tab"

		local tabBtn = New("Frame", {
			Parent           = self._strip,
			Size             = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Theme.TabBg,
			BorderSizePixel  = 0,
			LayoutOrder      = #self._tabs + 1,
		})
		local accentBar = New("Frame", {
			Parent           = tabBtn,
			Size             = UDim2.new(0, 2, 0, 16),
			Position         = UDim2.new(0, 0, 0.5, -8),
			BackgroundColor3 = accent,
			BorderSizePixel  = 0,
			Visible          = false,
		})
		local tabLabel = New("TextLabel", {
			Parent             = tabBtn,
			Size               = UDim2.new(1, -14, 1, 0),
			Position           = UDim2.new(0, 14, 0, 0),
			BackgroundTransparency = 1,
			Text               = tabName,
			TextColor3         = Theme.TabText,
			TextSize           = Theme.FontSize,
			Font               = Theme.FontSm,
			TextXAlignment     = Enum.TextXAlignment.Left,
		})
		local tabClickBtn = New("TextButton", {
			Parent             = tabBtn,
			Size               = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text               = "",
			ZIndex             = 2,
		})
		-- separator
		New("Frame", {
			Parent           = tabBtn,
			Size             = UDim2.new(1, -14, 0, 1),
			Position         = UDim2.new(0, 14, 1, -1),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel  = 0,
			BackgroundTransparency = 0.5,
		})

		-- Page + scroll
		local page = New("Frame", {
			Parent           = self._content,
			Size             = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible          = false,
		})
		local scrollFrame = New("ScrollingFrame", {
			Parent                = page,
			Size                  = UDim2.new(1, 0, 1, -8),
			Position              = UDim2.new(0, 0, 0, 8),
			BackgroundTransparency = 1,
			BorderSizePixel       = 0,
			ScrollBarThickness    = 3,
			ScrollBarImageColor3  = Theme.ScrollBar,
			CanvasSize            = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize   = Enum.AutomaticSize.Y,
		})
		local colsFrame = New("Frame", {
			Parent           = scrollFrame,
			Size             = UDim2.new(1, -16, 0, 0),
			Position         = UDim2.new(0, 8, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize    = Enum.AutomaticSize.Y,
		})
		local leftCol = New("Frame", {
			Parent           = colsFrame,
			Size             = UDim2.new(0.5, -4, 0, 0),
			Position         = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize    = Enum.AutomaticSize.Y,
		})
		New("UIListLayout", { Parent = leftCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })
		local rightCol = New("Frame", {
			Parent           = colsFrame,
			Size             = UDim2.new(0.5, -4, 0, 0),
			Position         = UDim2.new(0.5, 4, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize    = Enum.AutomaticSize.Y,
		})
		New("UIListLayout", { Parent = rightCol, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) })

		-- Tab object
		local Tab = {
			_page   = page,
			_left   = leftCol,
			_right  = rightCol,
			_btn    = tabBtn,
			_label  = tabLabel,
			_bar    = accentBar,
			_accent = self._accent,
		}

		local function activateTab()
			for _, t in ipairs(Window._tabs) do
				t._page.Visible        = false
				t._bar.Visible         = false
				t._label.TextColor3    = Theme.TabText
				t._label.Font          = Theme.FontSm
				t._btn.BackgroundColor3 = Theme.TabBg
			end
			page.Visible              = true
			accentBar.Visible         = true
			tabLabel.TextColor3       = Theme.TabTextActive
			tabLabel.Font             = Theme.Font
			tabBtn.BackgroundColor3   = Theme.TabActive
			Window._active            = Tab
		end

		tabClickBtn.MouseButton1Click:Connect(activateTab)
		tabClickBtn.MouseEnter:Connect(function()
			if Window._active ~= Tab then Tw(tabBtn, 0.12, { BackgroundColor3 = Theme.TabActive }) end
		end)
		tabClickBtn.MouseLeave:Connect(function()
			if Window._active ~= Tab then Tw(tabBtn, 0.12, { BackgroundColor3 = Theme.TabBg }) end
		end)

		table.insert(self._tabs, Tab)
		if #self._tabs == 1 then activateTab() end

		-- ── Tab:AddBox ────────────────────────────────────────────────────────
		function Tab:AddBox(boxParams)
			local boxName = boxParams.Name   or "Section"
			local origin  = boxParams.Origin or "Left"
			local col     = (origin == "Right") and self._right or self._left
			local accentC = self._accent

			-- Section wrapper
			local section = New("Frame", {
				Parent           = col,
				Size             = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Theme.SectionBg,
				BorderSizePixel  = 0,
				AutomaticSize    = Enum.AutomaticSize.Y,
				LayoutOrder      = #col:GetChildren(),
			})
			Corner(section, 5)
			Stroke(section, Theme.SectionBorder, 1)

			-- Header
			local headerBar = New("Frame", {
				Parent           = section,
				Size             = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = Theme.TitleBg,
				BorderSizePixel  = 0,
			})
			-- manual flat-bottom: cover rounded bottom corners
			New("Frame", {
				Parent           = headerBar,
				Size             = UDim2.new(1, 0, 0.5, 0),
				Position         = UDim2.new(0, 0, 0.5, 0),
				BackgroundColor3 = Theme.TitleBg,
				BorderSizePixel  = 0,
			})
			Corner(headerBar, 5)
			-- header bottom line
			New("Frame", {
				Parent           = headerBar,
				Size             = UDim2.new(1, 0, 0, 1),
				Position         = UDim2.new(0, 0, 1, -1),
				BackgroundColor3 = Theme.SectionBorder,
				BorderSizePixel  = 0,
			})
			-- accent pip
			New("Frame", {
				Parent           = headerBar,
				Size             = UDim2.new(0, 2, 0, 10),
				Position         = UDim2.new(0, 8, 0.5, -5),
				BackgroundColor3 = accentC,
				BorderSizePixel  = 0,
			})
			New("TextLabel", {
				Parent             = headerBar,
				Size               = UDim2.new(1, -20, 1, 0),
				Position           = UDim2.new(0, 16, 0, 0),
				BackgroundTransparency = 1,
				Text               = boxName,
				TextColor3         = Theme.ElemText,
				TextSize           = Theme.FontSize,
				Font               = Theme.Font,
				TextXAlignment     = Enum.TextXAlignment.Left,
			})

			-- Elements frame
			local elemFrame = New("Frame", {
				Parent           = section,
				Size             = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				AutomaticSize    = Enum.AutomaticSize.Y,
			})
			New("UIPadding", {
				Parent        = elemFrame,
				PaddingLeft   = UDim.new(0, 8),
				PaddingRight  = UDim.new(0, 8),
				PaddingTop    = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 8),
			})
			New("UIListLayout", { Parent = elemFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) })

			-- ── Row / label factories ──────────────────────────────────────────
			local function makeRow(h)
				local r = New("Frame", {
					Parent           = elemFrame,
					Size             = UDim2.new(1, 0, 0, h or 26),
					BackgroundColor3 = Theme.ElemBg,
					BorderSizePixel  = 0,
					LayoutOrder      = #elemFrame:GetChildren(),
				})
				Corner(r, 3)
				return r
			end

			local function rowLabel(parent, text)
				return New("TextLabel", {
					Parent             = parent,
					Size               = UDim2.new(0.55, 0, 1, 0),
					Position           = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text               = text,
					TextColor3         = Theme.ElemText,
					TextSize           = Theme.FontSize,
					Font               = Theme.FontSm,
					TextXAlignment     = Enum.TextXAlignment.Left,
				})
			end

			local function hoverRow(row)
				row.MouseEnter:Connect(function() Tw(row, 0.1, { BackgroundColor3 = Theme.ElemHover }) end)
				row.MouseLeave:Connect(function() Tw(row, 0.1, { BackgroundColor3 = Theme.ElemBg   }) end)
			end

			-- ── Box object ─────────────────────────────────────────────────────
			local Box = {}

			-- ══════════════════════════════════════════════════════════════════
			-- TOGGLE
			-- ══════════════════════════════════════════════════════════════════
			function Box:AddToggle(p)
				local name     = p.Name     or "Toggle"
				local value    = p.Default  ~= nil and p.Default or false
				local callback = p.Callback or function() end

				local row = makeRow(26)
				rowLabel(row, name)
				hoverRow(row)

				local track = New("Frame", {
					Parent           = row,
					Size             = UDim2.new(0, 32, 0, 14),
					Position         = UDim2.new(1, -40, 0.5, -7),
					BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff,
					BorderSizePixel  = 0,
				})
				Corner(track, 7)
				local knob = New("Frame", {
					Parent           = track,
					Size             = UDim2.new(0, 10, 0, 10),
					Position         = value and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5),
					BackgroundColor3 = Theme.ToggleKnob,
					BorderSizePixel  = 0,
					ZIndex           = 2,
				})
				Corner(knob, 5)
				local hitbox = New("TextButton", {
					Parent = row, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = "", ZIndex = 3,
				})

				local function set(v)
					value = v
					Tw(track, 0.15, { BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff })
					Tw(knob,  0.15, { Position = v and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5) })
					callback(v)
				end
				hitbox.MouseButton1Click:Connect(function() set(not value) end)
				return { Set = set, Get = function() return value end }
			end

			-- ══════════════════════════════════════════════════════════════════
			-- BUTTON
			-- ══════════════════════════════════════════════════════════════════
			function Box:AddButton(p)
				local name     = p.Name     or "Button"
				local callback = p.Callback or function() end

				local row = makeRow(26)
				Stroke(row, Theme.SectionBorder, 1)
				New("TextLabel", {
					Parent = row, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = name,
					TextColor3 = Theme.ElemText, TextSize = Theme.FontSize,
					Font = Theme.Font, TextXAlignment = Enum.TextXAlignment.Center,
				})
				local hitbox = New("TextButton", {
					Parent = row, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = "", ZIndex = 2,
				})
				hitbox.MouseButton1Click:Connect(function()
					Tw(row, 0.07, { BackgroundColor3 = accentC })
					task.delay(0.14, function() Tw(row, 0.14, { BackgroundColor3 = Theme.ElemBg }) end)
					callback()
				end)
				hitbox.MouseEnter:Connect(function() Tw(row, 0.1, { BackgroundColor3 = Theme.ElemHover }) end)
				hitbox.MouseLeave:Connect(function() Tw(row, 0.1, { BackgroundColor3 = Theme.ElemBg   }) end)
			end

			-- ══════════════════════════════════════════════════════════════════
			-- SLIDER
			-- ══════════════════════════════════════════════════════════════════
			function Box:AddSlider(p)
				local name     = p.Name     or "Slider"
				local min      = p.Min      or 0
				local max      = p.Max      or 100
				local value    = math.clamp(p.Default or min, min, max)
				local callback = p.Callback or function() end

				local row = makeRow(44)
				hoverRow(row)

				New("TextLabel", {
					Parent = row, Size = UDim2.new(0.6,0,0,20),
					Position = UDim2.new(0,8,0,3),
					BackgroundTransparency = 1, Text = name,
					TextColor3 = Theme.ElemText, TextSize = Theme.FontSize,
					Font = Theme.FontSm, TextXAlignment = Enum.TextXAlignment.Left,
				})
				local valLabel = New("TextLabel", {
					Parent = row, Size = UDim2.new(0.35,-4,0,20),
					Position = UDim2.new(0.63,0,0,3),
					BackgroundTransparency = 1, Text = tostring(value),
					TextColor3 = accentC, TextSize = Theme.FontSizeSm,
					Font = Theme.Font, TextXAlignment = Enum.TextXAlignment.Right,
				})

				local trackBg = New("Frame", {
					Parent = row, Size = UDim2.new(1,-16,0,4),
					Position = UDim2.new(0,8,0,32),
					BackgroundColor3 = Theme.SliderTrack, BorderSizePixel = 0,
				})
				Corner(trackBg, 2)
				local fill = New("Frame", {
					Parent = trackBg,
					Size = UDim2.new((value-min)/(max-min),0,1,0),
					BackgroundColor3 = accentC, BorderSizePixel = 0,
				})
				Corner(fill, 2)
				local knobDot = New("Frame", {
					Parent = trackBg, Size = UDim2.new(0,8,0,8),
					Position = UDim2.new((value-min)/(max-min),-4,0.5,-4),
					BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 3,
				})
				Corner(knobDot, 4)

				local function updateSlider(absX)
					local pct   = math.clamp((absX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
					value       = math.floor(min + pct*(max-min) + 0.5)
					local rpct  = (value-min)/(max-min)
					fill.Size        = UDim2.new(rpct,0,1,0)
					knobDot.Position = UDim2.new(rpct,-4,0.5,-4)
					valLabel.Text    = tostring(value)
					callback(value)
				end

				local dragging = false
				local hitbox = New("TextButton", {
					Parent = row, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = "", ZIndex = 5,
				})
				hitbox.MouseButton1Down:Connect(function(x) dragging = true; updateSlider(x) end)
				Input.InputChanged:Connect(function(inp)
					if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(inp.Position.X) end
				end)
				Input.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)

				return {
					Set = function(v)
						value = math.clamp(v,min,max)
						local pct = (value-min)/(max-min)
						fill.Size = UDim2.new(pct,0,1,0)
						knobDot.Position = UDim2.new(pct,-4,0.5,-4)
						valLabel.Text = tostring(value)
					end,
					Get = function() return value end,
				}
			end

			-- ══════════════════════════════════════════════════════════════════
			-- DROPDOWN
			-- ══════════════════════════════════════════════════════════════════
			function Box:AddDropdown(p)
				local name     = p.Name     or "Dropdown"
				local options  = p.Options  or {}
				local value    = p.Default  or (options[1] or "")
				local callback = p.Callback or function() end
				local isOpen   = false

				local row = makeRow(26)
				rowLabel(row, name)
				hoverRow(row)

				local dispFrame = New("Frame", {
					Parent = row, Size = UDim2.new(0.44,0,0,18),
					Position = UDim2.new(0.53,0,0.5,-9),
					BackgroundColor3 = Theme.InputBg, BorderSizePixel = 0,
				})
				Corner(dispFrame, 3)
				Stroke(dispFrame, Theme.InputBorder, 1)
				local dispLabel = New("TextLabel", {
					Parent = dispFrame, Size = UDim2.new(1,-20,1,0),
					Position = UDim2.new(0,6,0,0),
					BackgroundTransparency = 1, Text = value,
					TextColor3 = Theme.ElemText, TextSize = Theme.FontSizeSm,
					Font = Theme.FontSm, TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				local arrow = New("TextLabel", {
					Parent = dispFrame, Size = UDim2.new(0,18,1,0),
					Position = UDim2.new(1,-18,0,0),
					BackgroundTransparency = 1, Text = "v",
					TextColor3 = Theme.ElemSubText, TextSize = 11,
					Font = Theme.Font, TextXAlignment = Enum.TextXAlignment.Center,
				})

				local listFrame = New("Frame", {
					Parent = row,
					Size = UDim2.new(0.44,0,0,math.min(#options,6)*22+4),
					Position = UDim2.new(0.53,0,1,2),
					BackgroundColor3 = Theme.TitleBg, BorderSizePixel = 0,
					Visible = false, ZIndex = 50, ClipsDescendants = true,
				})
				Corner(listFrame, 4)
				Stroke(listFrame, Theme.SectionBorder, 1)
				New("UIPadding", { Parent = listFrame, PaddingTop = UDim.new(0,2), PaddingBottom = UDim.new(0,2) })
				New("UIListLayout", { Parent = listFrame, SortOrder = Enum.SortOrder.LayoutOrder })

				for i, opt in ipairs(options) do
					local optBtn = New("TextButton", {
						Parent = listFrame, Size = UDim2.new(1,0,0,22),
						BackgroundTransparency = 1, Text = opt,
						TextColor3 = (opt == value) and accentC or Theme.ElemSubText,
						TextSize = Theme.FontSizeSm, Font = Theme.FontSm,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 51, LayoutOrder = i,
					})
					New("UIPadding", { Parent = optBtn, PaddingLeft = UDim.new(0,8) })
					optBtn.MouseButton1Click:Connect(function()
						value = opt; dispLabel.Text = opt
						for _, c in ipairs(listFrame:GetChildren()) do
							if c:IsA("TextButton") then c.TextColor3 = Theme.ElemSubText end
						end
						optBtn.TextColor3 = accentC
						listFrame.Visible = false; isOpen = false; arrow.Text = "v"
						callback(value)
					end)
					optBtn.MouseEnter:Connect(function() optBtn.BackgroundTransparency = 0; optBtn.BackgroundColor3 = Theme.ElemHover end)
					optBtn.MouseLeave:Connect(function() optBtn.BackgroundTransparency = 1 end)
				end

				local hitbox = New("TextButton", {
					Parent = row, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = "", ZIndex = 10,
				})
				hitbox.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					listFrame.Visible = isOpen
					arrow.Text = isOpen and "^" or "v"
				end)

				return {
					Set = function(v)
						if table.find(options,v) then value=v; dispLabel.Text=v; callback(v) end
					end,
					Get = function() return value end,
				}
			end

			-- ══════════════════════════════════════════════════════════════════
			-- TEXTBOX
			-- ══════════════════════════════════════════════════════════════════
			function Box:AddTextBox(p)
				local name        = p.Name        or "TextBox"
				local placeholder = p.Placeholder or ""
				local callback    = p.Callback    or function() end

				local row = makeRow(26)
				rowLabel(row, name)
				hoverRow(row)

				local inputFrame = New("Frame", {
					Parent = row, Size = UDim2.new(0.44,0,0,18),
					Position = UDim2.new(0.53,0,0.5,-9),
					BackgroundColor3 = Theme.InputBg, BorderSizePixel = 0,
				})
				Corner(inputFrame, 3)
				local stroke = Stroke(inputFrame, Theme.InputBorder, 1)

				local tb = New("TextBox", {
					Parent = inputFrame, Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1, Text = "",
					PlaceholderText = placeholder, PlaceholderColor3 = Theme.ElemSubText,
					TextColor3 = Theme.ElemText, TextSize = Theme.FontSizeSm,
					Font = Theme.FontSm, BorderSizePixel = 0,
					ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
				})
				New("UIPadding", { Parent = tb, PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,4) })

				tb.Focused:Connect(function()   Tw(stroke,0.12,{Color=accentC}) end)
				tb.FocusLost:Connect(function() Tw(stroke,0.12,{Color=Theme.InputBorder}); callback(tb.Text) end)

				return {
					Set = function(v) tb.Text = tostring(v) end,
					Get = function() return tb.Text end,
				}
			end

			return Box
		end -- AddBox

		return Tab
	end -- AddTab

	function Window:SetVisible(v)
		WindowFrame.Visible  = v
		Library.Utils.Showed = v
	end
	function Window:Toggle()
		self:SetVisible(not Library.Utils.Showed)
	end

	return Window
end

-- ─── Keybind ──────────────────────────────────────────────────────────────────
function Library:SetKeybind(Key)
	Library.Utils.Key = typeof(Key) == "EnumItem" and Key or Enum.KeyCode[Key]
end

Input.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Input:GetFocusedTextBox() then return end
	if input.KeyCode == Library.Utils.Key then
		Library.Utils.Showed = not Library.Utils.Showed
		ScreenGui.Enabled    = Library.Utils.Showed
	end
end)

function Library:Unload()
	pcall(function() ScreenGui:Destroy() end)
end

return Library
