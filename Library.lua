local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
	Theme = {
		BackgroundOutline = Color3.fromRGB(10, 10, 10),
		Background       = Color3.fromRGB(25, 27, 25),
		ElementBackground= Color3.fromRGB(18, 20, 18),
		ElementHover     = Color3.fromRGB(32, 35, 32),
		TextPrimary      = Color3.new(1, 1, 1),
		TextSecondary    = Color3.fromRGB(160, 160, 160),
		ToggleOn         = Color3.fromRGB(80, 200, 120),
		ToggleOff        = Color3.fromRGB(60, 60, 60),
		SliderFill       = Color3.fromRGB(100, 180, 255),
		SliderBg         = Color3.fromRGB(40, 40, 40),
	},
	Utils = { Showed = true, Key = nil }
}

getfenv().Objects = {}

local ScreenGui__ = Instance.new("ScreenGui")
ScreenGui__.Parent = CoreGui
ScreenGui__.IgnoreGuiInset = true
ScreenGui__.ResetOnSpawn = false
ScreenGui__.DisplayOrder = 10000

local function CreateObj(Class, Props)
	if not Class or not Props then return end
	local obj = Instance.new(Class)
	table.insert(getfenv().Objects, obj)
	for p,v in pairs(Props) do obj[p]=v end
	return obj
end

local function MakeDraggable(frame, handle)
	local dragging, dragStart, startPos = false, nil, nil
	handle = handle or frame
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos  = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	Input.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
			                           startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)
end

function Library:CreateWatermark(P)
	P = P or {}
	local WmFrame = CreateObj("Frame",{
		Parent=ScreenGui__, Size=UDim2.new(0,0,0,26),
		Position=UDim2.new(0,10,0,10),
		BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0,
		AutomaticSize=Enum.AutomaticSize.X, ZIndex=9999
	})
	CreateObj("Frame",{
		Parent=WmFrame, Size=UDim2.new(1,2,1,2), Position=UDim2.new(0,-1,0,-1),
		BackgroundColor3=P.Color or Color3.new(1,1,1), BorderSizePixel=0, ZIndex=9998
	})
	CreateObj("UIPadding",{
		Parent=WmFrame,
		PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10),
		PaddingTop=UDim.new(0,2),   PaddingBottom=UDim.new(0,2)
	})
	local Lbl = CreateObj("TextLabel",{
		Parent=WmFrame, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
		BackgroundTransparency=1, Text=P.Text or "g33t",
		TextColor3=Library.Theme.TextPrimary, TextSize=13, Font=Enum.Font.Code, ZIndex=10000
	})
	local Wm = {}
	function Wm:SetText(t)    Lbl.Text = t end
	function Wm:SetVisible(v) WmFrame.Visible = v end
	return Wm
end

function Library:CreateWindow(P)
	assert(P and typeof(P.Name)=="string", "CreateWindow: Name required")
	local Accent = P.Color or Color3.fromRGB(255,255,255)

	local WinFrame = CreateObj("Frame",{
		Parent=ScreenGui__, Size=UDim2.new(0,500,0,550),
		AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
		BackgroundColor3=Library.Theme.Background, BorderSizePixel=0, ClipsDescendants=false
	})

	local TitleFrame = CreateObj("Frame",{
		Parent=WinFrame, Size=UDim2.new(1,0,0,40), BackgroundTransparency=1, ZIndex=5
	})
	local TitleOutline = CreateObj("Frame",{
		Parent=TitleFrame, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
		BackgroundColor3=Accent, BorderSizePixel=0, ZIndex=5
	})
	local TitleInner = CreateObj("Frame",{
		Parent=TitleOutline, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
		BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0, ZIndex=5
	})
	CreateObj("TextLabel",{
		Parent=TitleInner, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,10,0,0),
		BackgroundTransparency=1, Text=P.Name,
		TextColor3=Color3.new(1,1,1), TextSize=14, Font=Enum.Font.Code,
		TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6
	})

	local BodyOutline = CreateObj("Frame",{
		Parent=WinFrame, Size=UDim2.new(1,-2,1,-42), Position=UDim2.new(0,1,0,41),
		BackgroundColor3=Accent, BorderSizePixel=0
	})
	local BodyInner = CreateObj("Frame",{
		Parent=BodyOutline, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
		BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0
	})

	local ContentFrame = CreateObj("Frame",{
		Parent=BodyInner, Size=UDim2.new(1,0,1,0),
		BackgroundTransparency=1, ClipsDescendants=true
	})

	local TabsFrame = CreateObj("Frame",{
		Parent=WinFrame, Size=UDim2.new(0,133,1,0), Position=UDim2.new(0,-135,0,0),
		BackgroundColor3=Library.Theme.Background, BorderSizePixel=0
	})
	local TabsOutline = CreateObj("Frame",{
		Parent=TabsFrame, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
		BackgroundColor3=Accent, BorderSizePixel=0
	})
	local TabsInner = CreateObj("Frame",{
		Parent=TabsOutline, Size=UDim2.new(1,-2,1,-2), Position=UDim2.new(0,1,0,1),
		BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0
	})
	local TabBtnList = CreateObj("Frame",{
		Parent=TabsInner, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1
	})
	CreateObj("UIListLayout",{ Parent=TabBtnList, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2) })

	MakeDraggable(WinFrame, TitleFrame)

	local Window = {}
	local AllTabs = {}

	function Window:AddTab(TP)
		TP = TP or {}
		local tabName = TP.Name or "Tab"

		local Btn = CreateObj("TextButton",{
			Parent=TabBtnList, Size=UDim2.new(1,-6,0,28), Position=UDim2.new(0,3,0,0),
			BackgroundColor3=Library.Theme.ElementBackground, BorderSizePixel=0,
			Text=tabName, TextColor3=Library.Theme.TextSecondary,
			TextSize=13, Font=Enum.Font.Code, LayoutOrder=#AllTabs+1
		})
		CreateObj("UICorner",{ Parent=Btn, CornerRadius=UDim.new(0,3) })

		local TabPage = CreateObj("Frame",{
			Parent=ContentFrame, Size=UDim2.new(1,0,1,0),
			BackgroundTransparency=1, Visible=#AllTabs==0
		})

		local function MakeColumn(xPos)
			local Col = CreateObj("ScrollingFrame",{
				Parent=TabPage, Size=UDim2.new(0.5,-4,1,-8),
				Position=UDim2.new(xPos,xPos==0 and 4 or 2,0,4),
				BackgroundTransparency=1, BorderSizePixel=0,
				ScrollBarThickness=2, ScrollBarImageColor3=Accent,
				CanvasSize=UDim2.new(0,0,0,0),
				AutomaticCanvasSize=Enum.AutomaticSize.Y
			})
			CreateObj("UIListLayout",{ Parent=Col, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4) })
			return Col
		end
		local LeftCol  = MakeColumn(0)
		local RightCol = MakeColumn(0.5)

		if #AllTabs == 0 then
			Btn.TextColor3 = Library.Theme.TextPrimary
			Btn.BackgroundColor3 = Library.Theme.ElementHover
		end

		Btn.MouseButton1Click:Connect(function()
			for _, t in ipairs(AllTabs) do
				t.Page.Visible = false
				t.Btn.TextColor3 = Library.Theme.TextSecondary
				t.Btn.BackgroundColor3 = Library.Theme.ElementBackground
			end
			TabPage.Visible = true
			Btn.TextColor3 = Library.Theme.TextPrimary
			Btn.BackgroundColor3 = Library.Theme.ElementHover
		end)
		Btn.MouseEnter:Connect(function()
			if not TabPage.Visible then Btn.BackgroundColor3 = Library.Theme.ElementHover end
		end)
		Btn.MouseLeave:Connect(function()
			if not TabPage.Visible then Btn.BackgroundColor3 = Library.Theme.ElementBackground end
		end)

		table.insert(AllTabs, { Page=TabPage, Btn=Btn })

		local Tab = {}

		function Tab:AddBox(BP)
			BP = BP or {}
			local boxName = BP.Name or "Box"
			local parent  = (BP.Origin == "Right") and RightCol or LeftCol

			local BoxFrame = CreateObj("Frame",{
				Parent=parent, Size=UDim2.new(1,0,0,0),
				AutomaticSize=Enum.AutomaticSize.Y,
				BackgroundColor3=Library.Theme.ElementBackground, BorderSizePixel=0
			})
			CreateObj("UICorner",{ Parent=BoxFrame, CornerRadius=UDim.new(0,4) })
			CreateObj("UIStroke",{ Parent=BoxFrame, Color=Accent, Thickness=1, Transparency=0.65 })
			CreateObj("UIPadding",{
				Parent=BoxFrame,
				PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6),
				PaddingTop=UDim.new(0,4),  PaddingBottom=UDim.new(0,6)
			})
			CreateObj("TextLabel",{
				Parent=BoxFrame, Size=UDim2.new(1,0,0,20),
				BackgroundTransparency=1, Text=boxName,
				TextColor3=Accent, TextSize=12, Font=Enum.Font.Code,
				TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=0
			})
			CreateObj("Frame",{
				Parent=BoxFrame, Size=UDim2.new(1,0,0,1),
				BackgroundColor3=Accent, BackgroundTransparency=0.7,
				BorderSizePixel=0, LayoutOrder=1
			})
			local ItemsFrame = CreateObj("Frame",{
				Parent=BoxFrame, Size=UDim2.new(1,0,0,0),
				AutomaticSize=Enum.AutomaticSize.Y,
				BackgroundTransparency=1, LayoutOrder=2
			})
			CreateObj("UIListLayout",{ Parent=ItemsFrame, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3) })
			CreateObj("UIListLayout",{ Parent=BoxFrame,   SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2) })

			local Box = {}

			local function Row(h)
				h = h or 24
				return CreateObj("Frame",{
					Parent=ItemsFrame, Size=UDim2.new(1,0,0,h),
					BackgroundTransparency=1, LayoutOrder=#ItemsFrame:GetChildren()
				})
			end
			local function RowLabel(row, txt)
				return CreateObj("TextLabel",{
					Parent=row, Size=UDim2.new(0.55,0,1,0),
					BackgroundTransparency=1, Text=txt,
					TextColor3=Library.Theme.TextPrimary, TextSize=12,
					Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left
				})
			end

			function Box:AddToggle(TP)
				TP = TP or {}
				local state = TP.Default or false
				local cb    = TP.Callback or function() end
				local row   = Row(24)
				RowLabel(row, TP.Name or "Toggle")

				local Track = CreateObj("Frame",{
					Parent=row, Size=UDim2.new(0,34,0,16),
					Position=UDim2.new(1,-36,0.5,-8),
					BackgroundColor3=state and Library.Theme.ToggleOn or Library.Theme.ToggleOff,
					BorderSizePixel=0
				})
				CreateObj("UICorner",{ Parent=Track, CornerRadius=UDim.new(1,0) })
				local Knob = CreateObj("Frame",{
					Parent=Track, Size=UDim2.new(0,12,0,12),
					Position=state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),
					BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0
				})
				CreateObj("UICorner",{ Parent=Knob, CornerRadius=UDim.new(1,0) })
				local HitBox = CreateObj("TextButton",{
					Parent=row, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""
				})
				HitBox.MouseButton1Click:Connect(function()
					state = not state
					local ti = TweenInfo.new(0.15,Enum.EasingStyle.Quad)
					Tween:Create(Track,ti,{ BackgroundColor3=state and Library.Theme.ToggleOn or Library.Theme.ToggleOff }):Play()
					Tween:Create(Knob, ti,{ Position=state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6) }):Play()
					pcall(cb, state)
				end)
				local O = {}
				function O:Set(v) state=v; Track.BackgroundColor3=state and Library.Theme.ToggleOn or Library.Theme.ToggleOff; Knob.Position=state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6); pcall(cb,state) end
				function O:Get() return state end
				return O
			end

			function Box:AddButton(BP)
				BP = BP or {}
				local cb  = BP.Callback or function() end
				local row = Row(24)
				local Btn = CreateObj("TextButton",{
					Parent=row, Size=UDim2.new(1,0,1,0),
					BackgroundColor3=Library.Theme.ElementHover, BorderSizePixel=0,
					Text=BP.Name or "Button",
					TextColor3=Library.Theme.TextPrimary, TextSize=12, Font=Enum.Font.Code
				})
				CreateObj("UICorner",{ Parent=Btn, CornerRadius=UDim.new(0,3) })
				Btn.MouseEnter:Connect(function()
					Tween:Create(Btn,TweenInfo.new(0.1),{ BackgroundColor3=Accent }):Play()
				end)
				Btn.MouseLeave:Connect(function()
					Tween:Create(Btn,TweenInfo.new(0.1),{ BackgroundColor3=Library.Theme.ElementHover }):Play()
				end)
				Btn.MouseButton1Click:Connect(function() pcall(cb) end)
				local O = {}
				function O:SetLabel(t) Btn.Text=t end
				return O
			end

			function Box:AddSlider(SP)
				SP = SP or {}
				local min  = SP.Min     or 0
				local max  = SP.Max     or 100
				local suf  = SP.Suffix  or ""
				local cb   = SP.Callback or function() end
				local val  = math.clamp(SP.Default or min, min, max)

				local row = Row(36)
				local Lbl = CreateObj("TextLabel",{
					Parent=row, Size=UDim2.new(1,0,0,16),
					BackgroundTransparency=1,
					Text=(SP.Name or "Slider")..": "..tostring(val)..suf,
					TextColor3=Library.Theme.TextPrimary, TextSize=12,
					Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left
				})
				local Track = CreateObj("Frame",{
					Parent=row, Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,0,22),
					BackgroundColor3=Library.Theme.SliderBg, BorderSizePixel=0
				})
				CreateObj("UICorner",{ Parent=Track, CornerRadius=UDim.new(1,0) })
				local Fill = CreateObj("Frame",{
					Parent=Track, Size=UDim2.new((val-min)/(max-min),0,1,0),
					BackgroundColor3=Library.Theme.SliderFill, BorderSizePixel=0
				})
				CreateObj("UICorner",{ Parent=Fill, CornerRadius=UDim.new(1,0) })
				local HitBox = CreateObj("TextButton",{
					Parent=Track, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""
				})

				local dragging = false
				local function update(x)
					local rel = math.clamp((x - Track.AbsolutePosition.X)/Track.AbsoluteSize.X, 0, 1)
					val = math.round(min + rel*(max-min))
					Fill.Size = UDim2.new(rel,0,1,0)
					Lbl.Text = (SP.Name or "Slider")..": "..tostring(val)..suf
					pcall(cb, val)
				end
				HitBox.MouseButton1Down:Connect(function(x) dragging=true; update(x) end)
				Input.InputChanged:Connect(function(i)
					if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end
				end)
				Input.InputEnded:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
				end)

				local O = {}
				function O:Set(v)
					val = math.clamp(v,min,max)
					local rel=(val-min)/(max-min)
					Fill.Size=UDim2.new(rel,0,1,0)
					Lbl.Text=(SP.Name or "Slider")..": "..tostring(val)..suf
					pcall(cb,val)
				end
				function O:Get() return val end
				return O
			end

			function Box:AddDropdown(DP)
				DP = DP or {}
				local opts = DP.Options  or {}
				local sel  = DP.Default  or (opts[1] or "")
				local cb   = DP.Callback or function() end
				local label= DP.Name     or "Dropdown"
				local opened= false

				local row = Row(24)
				local DBtn = CreateObj("TextButton",{
					Parent=row, Size=UDim2.new(1,0,1,0),
					BackgroundColor3=Library.Theme.ElementHover, BorderSizePixel=0,
					Text=label..": "..tostring(sel),
					TextColor3=Library.Theme.TextPrimary, TextSize=12, Font=Enum.Font.Code,
					ZIndex=11
				})
				CreateObj("UICorner",{ Parent=DBtn, CornerRadius=UDim.new(0,3) })
				local Arrow = CreateObj("TextLabel",{
					Parent=DBtn, Size=UDim2.new(0,16,1,0), Position=UDim2.new(1,-18,0,0),
					BackgroundTransparency=1, Text="▾",
					TextColor3=Library.Theme.TextSecondary, TextSize=12, Font=Enum.Font.Code, ZIndex=12
				})

				local DList = CreateObj("Frame",{
					Parent=ScreenGui__, Size=UDim2.new(0,0,0,0),
					BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0,
					Visible=false, ZIndex=200, ClipsDescendants=true
				})
				CreateObj("UICorner",{ Parent=DList, CornerRadius=UDim.new(0,4) })
				CreateObj("UIStroke",{ Parent=DList, Color=Accent, Thickness=1, Transparency=0.5, ZIndex=201 })
				CreateObj("UIListLayout",{ Parent=DList, SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,0) })
				CreateObj("UIPadding",{ Parent=DList, PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,2) })

				local IH, MV = 22, 5

				local function buildItems()
					for _,c in ipairs(DList:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for i,opt in ipairs(opts) do
						local Item = CreateObj("TextButton",{
							Parent=DList, Size=UDim2.new(1,0,0,IH),
							BackgroundTransparency=1, Text="  "..tostring(opt),
							TextColor3=Library.Theme.TextPrimary, TextSize=12,
							Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left,
							ZIndex=202, LayoutOrder=i
						})
						Item.MouseEnter:Connect(function() Item.BackgroundTransparency=0; Item.BackgroundColor3=Library.Theme.ElementHover end)
						Item.MouseLeave:Connect(function() Item.BackgroundTransparency=1 end)
						Item.MouseButton1Click:Connect(function()
							sel=opt; DBtn.Text=label..": "..tostring(sel)
							opened=false; DList.Visible=false; Arrow.Text="▾"
							pcall(cb,sel)
						end)
					end
				end
				buildItems()

				local function openDD()
					opened=true
					local ap,as = DBtn.AbsolutePosition, DBtn.AbsoluteSize
					DList.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+2)
					DList.Size=UDim2.new(0,as.X,0,0)
					DList.Visible=true
					Tween:Create(DList,TweenInfo.new(0.12),{ Size=UDim2.new(0,as.X,0,math.min(#opts,MV)*IH+4) }):Play()
					Arrow.Text="▴"
				end
				local function closeDD()
					opened=false
					Tween:Create(DList,TweenInfo.new(0.1),{ Size=UDim2.new(DList.Size.X.Scale,DList.Size.X.Offset,0,0) }):Play()
					task.delay(0.1,function() DList.Visible=false end)
					Arrow.Text="▾"
				end
				DBtn.MouseButton1Click:Connect(function() if opened then closeDD() else openDD() end end)

				local O = {}
				function O:Set(v) sel=v; DBtn.Text=label..": "..tostring(sel); pcall(cb,sel) end
				function O:Get() return sel end
				function O:UpdateOptions(new) opts=new; buildItems() end
				return O
			end

			function Box:AddTextBox(TP)
				TP = TP or {}
				local cb = TP.Callback or function() end
				local row = Row(24)
				RowLabel(row, TP.Name or "TextBox")

				local Bg = CreateObj("Frame",{
					Parent=row, Size=UDim2.new(0.58,0,1,-4), Position=UDim2.new(0.42,0,0,2),
					BackgroundColor3=Library.Theme.BackgroundOutline, BorderSizePixel=0
				})
				CreateObj("UICorner",{ Parent=Bg, CornerRadius=UDim.new(0,3) })
				CreateObj("UIStroke",{ Parent=Bg, Color=Accent, Thickness=1, Transparency=0.6 })

				local TBox = CreateObj("TextBox",{
					Parent=Bg, Size=UDim2.new(1,-6,1,0), Position=UDim2.new(0,3,0,0),
					BackgroundTransparency=1, Text=TP.Default or "",
					PlaceholderText=TP.Placeholder or "...",
					PlaceholderColor3=Library.Theme.TextSecondary,
					TextColor3=Library.Theme.TextPrimary, TextSize=12,
					Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left,
					ClearTextOnFocus=false
				})
				TBox.FocusLost:Connect(function(enter) if enter then pcall(cb,TBox.Text) end end)

				local O = {}
				function O:Set(v) TBox.Text=v end
				function O:Get() return TBox.Text end
				return O
			end

			return Box
		end

		return Tab
	end

	function Window:SetVisible(v)
		WinFrame.Visible  = v
		TabsFrame.Visible = v
	end

	return Window
end

function Library:Unload()
	pcall(function() ScreenGui__:Destroy() end)
end

function Library:SetKeybind(Key)
	Library.Utils.Key = typeof(Key)=="EnumItem" and Key or Enum.KeyCode[Key]
end

Input.InputBegan:Connect(function(input, gp)
	if gp or Input:GetFocusedTextBox() then return end
	if input.KeyCode == Library.Utils.Key then
		Library.Utils.Showed = not Library.Utils.Showed
		for _, child in ipairs(ScreenGui__:GetChildren()) do
			if child:IsA("Frame") then child.Visible = Library.Utils.Showed end
		end
	end
end)

return Library

-- hh
