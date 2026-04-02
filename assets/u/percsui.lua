-- PercsUI v3
-- loadstring(game:HttpGet("RAW_URL"))()

local PercsUI = {}
PercsUI.__index = PercsUI
PercsUI.Flags = {}

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players").LocalPlayer
local HS  = game:GetService("HttpService")

-- ── Theme ─────────────────────────────────────────────────────────────────────
local T = {
	Bg         = Color3.fromRGB(12, 12, 12),
	Surface    = Color3.fromRGB(18, 18, 18),
	Alt        = Color3.fromRGB(24, 24, 24),
	Border     = Color3.fromRGB(38, 38, 38),
	Accent     = Color3.fromRGB(0, 210, 175),
	AccentDark = Color3.fromRGB(0, 140, 116),
	Text       = Color3.fromRGB(225, 225, 225),
	Muted      = Color3.fromRGB(100, 100, 100),
	Red        = Color3.fromRGB(215, 65, 65),
	White      = Color3.new(1, 1, 1),
}

-- ── Utility ───────────────────────────────────────────────────────────────────
local function tw(o, p, t, s, d)
	TS:Create(o, TweenInfo.new(t or 0.14, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p):Play()
end

local function New(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end

local function corner(p, r)
	return New("UICorner", {CornerRadius = UDim.new(0, r or 6)}, p)
end

local function stroke(p, col, th)
	return New("UIStroke", {Color = col or T.Border, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p)
end

local function padding(p, t, b, l, r)
	return New("UIPadding", {PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0)}, p)
end

local function listLayout(p, gap, so)
	return New("UIListLayout", {Padding=UDim.new(0,gap or 0), SortOrder=so or Enum.SortOrder.LayoutOrder}, p)
end

local function Frame(p, props)
	props = props or {}
	props.BorderSizePixel = 0
	if not props.BackgroundColor3 then props.BackgroundTransparency = 1 end
	return New("Frame", props, p)
end

local function Label(p, props)
	props = props or {}
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	if not props.TextColor3 then props.TextColor3 = T.Text end
	if not props.Font then props.Font = Enum.Font.GothamMedium end
	if not props.TextSize then props.TextSize = 13 end
	if not props.TextXAlignment then props.TextXAlignment = Enum.TextXAlignment.Left end
	return New("TextLabel", props, p)
end

local function Button(p, props)
	props = props or {}
	props.BorderSizePixel = 0
	props.AutoButtonColor = false
	if props.BackgroundColor3 == nil then props.BackgroundTransparency = 1 end
	if not props.Font then props.Font = Enum.Font.GothamMedium end
	if not props.TextSize then props.TextSize = 13 end
	if not props.TextColor3 then props.TextColor3 = T.Text end
	return New("TextButton", props, p)
end

local function makeDraggable(root, handle)
	local drag, start, origin = false
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag, start, origin = true, i.Position, root.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - start
			root.Position = UDim2.new(origin.X.Scale, origin.X.Offset+d.X, origin.Y.Scale, origin.Y.Offset+d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
end

local function getGui(name)
	local sg = New("ScreenGui", {Name=name, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok or not sg.Parent then sg.Parent = PL:WaitForChild("PlayerGui") end
	return sg
end

-- ── Config ────────────────────────────────────────────────────────────────────
local function configPath(folder)
	return folder.."/"..tostring(game.PlaceId)..".json"
end

local function saveConfig(folder, flags)
	pcall(function()
		if not isfolder(folder) then makefolder(folder) end
		local data = {}
		for k, v in pairs(flags) do
			if v._save then data[k] = v.Value end
		end
		writefile(configPath(folder), HS:JSONEncode(data))
	end)
end

local function loadConfig(folder, flags)
	pcall(function()
		local path = configPath(folder)
		if not isfile(path) then return end
		local data = HS:JSONDecode(readfile(path))
		for k, v in pairs(data) do
			if flags[k] and flags[k].Set then flags[k]:Set(v) end
		end
	end)
end

-- ── Notification stack ────────────────────────────────────────────────────────
local notifGui, notifStack

local function ensureNotifGui()
	if notifGui and notifGui.Parent then return end
	notifGui = getGui("PercsNotifs")
	notifGui.DisplayOrder = 999
	notifStack = Frame(notifGui, {
		Size     = UDim2.new(0, 290, 1, 0),
		Position = UDim2.new(1, -300, 0, 0),
	})
	local ll = listLayout(notifStack, 8)
	ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
	padding(notifStack, 0, 14, 0, 0)
end

function PercsUI:MakeNotification(opts)
	opts = opts or {}
	ensureNotifGui()

	local accentCol = opts.Type == "success" and Color3.fromRGB(0,200,100)
		or opts.Type == "error" and T.Red or T.Accent

	local card = New("Frame", {
		BackgroundColor3 = T.Surface,
		Size             = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		BorderSizePixel  = 0,
	}, notifStack)
	corner(card, 7)
	stroke(card, T.Border)

	New("Frame", {BackgroundColor3=accentCol, Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,9,0.2,0), BorderSizePixel=0}, card)
	local function cornerSmall(p) corner(p, 2) end
	cornerSmall(card:FindFirstChildOfClass("Frame"))

	Label(card, {
		Text     = opts.Name or "Percs",
		Font     = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = T.Text,
		Size     = UDim2.new(1, -20, 0, 18),
		Position = UDim2.new(0, 19, 0, 8),
	})

	Label(card, {
		Text         = opts.Content or "",
		TextSize     = 11,
		TextColor3   = T.Muted,
		Size         = UDim2.new(1, -20, 0, 28),
		Position     = UDim2.new(0, 19, 0, 28),
		TextWrapped  = true,
	})

	tw(card, {Size = UDim2.new(1, 0, 0, 62)}, 0.25, Enum.EasingStyle.Back)
	task.delay(opts.Time or 3, function()
		tw(card, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
		task.delay(0.22, function() card:Destroy() end)
	end)
end

-- ── MakeWindow ────────────────────────────────────────────────────────────────
function PercsUI:MakeWindow(opts)
	opts = opts or {}

	local title      = opts.Name or "Percs"
	local saveConfig_ = opts.SaveConfig or false
	local cfgFolder  = opts.ConfigFolder or "PercsConfig"
	local W, H       = 540, 370

	if saveConfig_ then
		self._saveEnabled = true
		self._saveFolder  = cfgFolder
	end

	-- intro
	if opts.IntroEnabled ~= false then
		local isg = getGui("PercsIntro")
		local bg = New("Frame", {BackgroundColor3=Color3.new(0,0,0), Size=UDim2.new(1,0,1,0), BorderSizePixel=0}, isg)

		if opts.IntroIcon and opts.IntroIcon ~= "" then
			New("ImageLabel", {
				Image=opts.IntroIcon, BackgroundTransparency=1,
				Size=UDim2.new(0,48,0,48), Position=UDim2.new(0.5,-24,0.5,-44),
				ImageTransparency=1,
			}, bg)
		end

		local il = Label(bg, {
			Text            = opts.IntroText or title,
			Font            = Enum.Font.GothamBold,
			TextSize        = 26,
			TextColor3      = T.Accent,
			TextTransparency= 1,
			Size            = UDim2.new(1,0,0,36),
			Position        = UDim2.new(0,0,0.5,-18),
			TextXAlignment  = Enum.TextXAlignment.Center,
		})

		tw(il, {TextTransparency=0}, 0.45)
		if bg:FindFirstChildOfClass("ImageLabel") then
			tw(bg:FindFirstChildOfClass("ImageLabel"), {ImageTransparency=0}, 0.45)
		end
		task.delay(1.4, function()
			tw(bg, {BackgroundTransparency=1}, 0.4)
			tw(il, {TextTransparency=1}, 0.3)
			task.delay(0.45, function() isg:Destroy() end)
		end)
	end

	local sg = getGui("PercsUI_"..title)

	-- shadow
	New("Frame", {
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.7,
		Size     = UDim2.new(0, W+28, 0, H+28),
		Position = UDim2.new(0.5, -(W+28)/2, 0.5, -(H+28)/2),
		ZIndex   = 0,
		BorderSizePixel = 0,
	}, sg)
	corner(sg:FindFirstChildOfClass("Frame"), 13)

	local root = New("Frame", {
		BackgroundColor3 = T.Bg,
		Size     = UDim2.new(0, W, 0, H),
		Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
		BorderSizePixel = 0,
	}, sg)
	corner(root, 8)
	stroke(root, T.Border)

	-- topbar
	local topbar = New("Frame", {
		BackgroundColor3 = T.Surface,
		Size = UDim2.new(1,0,0,38),
		BorderSizePixel = 0,
	}, root)
	corner(topbar, 8)
	New("Frame", {BackgroundColor3=T.Surface, Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BorderSizePixel=0}, topbar)

	-- accent pip
	local pip = New("Frame", {BackgroundColor3=T.Accent, Size=UDim2.new(0,3,0.55,0), Position=UDim2.new(0,11,0.225,0), BorderSizePixel=0}, topbar)
	corner(pip, 2)

	-- title
	if opts.Icon and opts.Icon ~= "" then
		New("ImageLabel", {Image=opts.Icon, BackgroundTransparency=1, Size=UDim2.new(0,20,0,20), Position=UDim2.new(0,20,0.5,-10)}, topbar)
	end
	Label(topbar, {
		Text       = title,
		Font       = Enum.Font.GothamBold,
		TextSize   = 14,
		TextColor3 = T.Text,
		Size       = UDim2.new(1,-80,1,0),
		Position   = UDim2.new(0, opts.Icon ~= "" and opts.Icon and 46 or 21, 0, 0),
	})

	-- window buttons
	local function winBtn(xOff, txt, hCol, cb)
		local b = Button(topbar, {
			Text=txt, TextSize=17, Font=Enum.Font.GothamBold, TextColor3=T.Muted,
			BackgroundTransparency=1, Size=UDim2.new(0,28,1,0), Position=UDim2.new(1,xOff,0,0),
		})
		b.MouseEnter:Connect(function() tw(b,{TextColor3=hCol}) end)
		b.MouseLeave:Connect(function() tw(b,{TextColor3=T.Muted}) end)
		b.MouseButton1Click:Connect(cb)
		return b
	end

	winBtn(-30, "×", T.Red, function()
		if opts.CloseCallback then opts.CloseCallback() end
		if self._saveEnabled then saveConfig(self._saveFolder, self.Flags) end
		tw(root, {Size=UDim2.new(0,W,0,0), Position=UDim2.new(0.5,-W/2,0.5,0)}, 0.18)
		task.delay(0.2, function() sg:Destroy() end)
	end)

	local minimized = false
	winBtn(-58, "–", T.Text, function()
		minimized = not minimized
		tw(root, {Size = minimized and UDim2.new(0,W,0,38) or UDim2.new(0,W,0,H)}, 0.18)
	end)

	makeDraggable(root, topbar)

	-- sidebar
	local sidebar = New("Frame", {
		BackgroundColor3 = T.Surface,
		Size     = UDim2.new(0, 118, 1, -38),
		Position = UDim2.new(0, 0, 0, 38),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, root)
	listLayout(sidebar, 3)
	padding(sidebar, 8, 8, 6, 6)

	New("Frame", {BackgroundColor3=T.Border, Size=UDim2.new(0,1,1,-38), Position=UDim2.new(0,118,0,38), BorderSizePixel=0}, root)

	-- content
	local content = Frame(root, {
		Size = UDim2.new(1,-119,1,-38),
		Position = UDim2.new(0,119,0,38),
		ClipsDescendants = true,
	})

	-- footer
	local footer = New("Frame", {
		BackgroundColor3=T.Surface, Size=UDim2.new(1,0,0,20),
		Position=UDim2.new(0,0,1,-20), BorderSizePixel=0,
	}, root)
	New("Frame", {BackgroundColor3=T.Surface, Size=UDim2.new(1,0,0,8), BorderSizePixel=0}, footer)
	Label(footer, {Text="percs ui  ·  v3", TextSize=10, TextColor3=T.Muted, Font=Enum.Font.Gotham, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,10,0,0)})

	-- load saved config after short delay (elements need to exist first)
	if saveConfig_ then
		task.delay(0.6, function() loadConfig(cfgFolder, self.Flags) end)
	end

	-- window object
	local win = {
		_sg       = sg,
		_root     = root,
		_sidebar  = sidebar,
		_content  = content,
		_tabs     = {},
		_active   = nil,
		_lib      = self,
	}

	-- ── MakeTab ───────────────────────────────────────────────────────────────
	function win:MakeTab(opts)
		opts = opts or {}
		local name = opts.Name or "Tab"

		local btn = Button(self._sidebar, {
			Text             = name,
			TextSize         = 12,
			Font             = Enum.Font.GothamMedium,
			TextColor3       = T.Muted,
			TextXAlignment   = Enum.TextXAlignment.Left,
			BackgroundColor3 = T.Alt,
			BackgroundTransparency = 1,
			Size             = UDim2.new(1, 0, 0, 28),
		})
		corner(btn, 5)
		padding(btn, 0, 0, 10, 0)

		if opts.Icon and opts.Icon ~= "" then
			New("ImageLabel", {
				Image=opts.Icon, BackgroundTransparency=1,
				Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,-2,0.5,-7),
				ImageColor3=T.Muted,
			}, btn)
		end

		local pill = New("Frame", {
			BackgroundColor3=T.Accent, Size=UDim2.new(0,2,0.55,0),
			Position=UDim2.new(0,1,0.225,0), BorderSizePixel=0, Visible=false,
		}, btn)
		corner(pill, 2)

		local page = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			Size                  = UDim2.new(1, 0, 1, -20),
			BorderSizePixel       = 0,
			ScrollBarThickness    = 2,
			ScrollBarImageColor3  = T.Accent,
			CanvasSize            = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize   = Enum.AutomaticSize.Y,
			Visible               = false,
		}, self._content)
		listLayout(page, 5)
		padding(page, 10, 10, 10, 10)

		local tab = {_btn=btn, _page=page, _pill=pill, _win=self, _lib=self._lib}

		local function activate()
			for _, t in ipairs(self._tabs) do
				t._page.Visible = false
				t._pill.Visible = false
				tw(t._btn, {TextColor3=T.Muted, BackgroundTransparency=1})
				if t._btn:FindFirstChildOfClass("ImageLabel") then
					tw(t._btn:FindFirstChildOfClass("ImageLabel"), {ImageColor3=T.Muted})
				end
			end
			page.Visible = true
			pill.Visible = true
			tw(btn, {TextColor3=T.Accent, BackgroundTransparency=0.82})
			if btn:FindFirstChildOfClass("ImageLabel") then
				tw(btn:FindFirstChildOfClass("ImageLabel"), {ImageColor3=T.Accent})
			end
			self._active = tab
		end

		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function() if self._active ~= tab then tw(btn,{TextColor3=T.Text}) end end)
		btn.MouseLeave:Connect(function() if self._active ~= tab then tw(btn,{TextColor3=T.Muted}) end end)

		table.insert(self._tabs, tab)
		if #self._tabs == 1 then activate() end

		-- ── AddSection ────────────────────────────────────────────────────
		-- Sections return a container; elements can be added to sections
		-- OR directly to the tab — both work identically.
		function tab:AddSection(opts)
			opts = type(opts) == "string" and {Name=opts} or (opts or {})
			local name = opts.Name or "Section"

			local container = Frame(page, {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y})
			local header = Frame(container, {
				BackgroundColor3=T.Alt,
				Size=UDim2.new(1,0,0,24),
				BorderSizePixel=0,
			})
			corner(header, 5)
			Label(header, {
				Text       = name:upper(),
				TextSize   = 10,
				TextColor3 = T.Muted,
				Font       = Enum.Font.GothamBold,
				Size       = UDim2.new(1,-10,1,0),
				Position   = UDim2.new(0,8,0,0),
			})

			local inner = Frame(container, {
				Size     = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,28),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			listLayout(inner, 5)

			-- A section behaves like a tab for element-adding purposes
			local section = {_page=inner, _lib=self._lib, _win=self._win}
			for _, method in ipairs({"AddButton","AddToggle","AddSlider","AddDropdown","AddTextbox","AddBind","AddColorpicker","AddLabel","AddParagraph","AddSeparator"}) do
				section[method] = function(s, ...) return tab[method](tab, ...) end
			end
			-- redirect to inner
			local _origPage = tab._page
			section.AddButton     = function(_, o) local old=tab._page tab._page=inner local r=tab:AddButton(o)     tab._page=old return r end
			section.AddToggle     = function(_, o) local old=tab._page tab._page=inner local r=tab:AddToggle(o)     tab._page=old return r end
			section.AddSlider     = function(_, o) local old=tab._page tab._page=inner local r=tab:AddSlider(o)     tab._page=old return r end
			section.AddDropdown   = function(_, o) local old=tab._page tab._page=inner local r=tab:AddDropdown(o)   tab._page=old return r end
			section.AddTextbox    = function(_, o) local old=tab._page tab._page=inner local r=tab:AddTextbox(o)    tab._page=old return r end
			section.AddBind       = function(_, o) local old=tab._page tab._page=inner local r=tab:AddBind(o)       tab._page=old return r end
			section.AddColorpicker= function(_, o) local old=tab._page tab._page=inner local r=tab:AddColorpicker(o) tab._page=old return r end
			section.AddLabel      = function(_, t, c) local old=tab._page tab._page=inner local r=tab:AddLabel(t,c) tab._page=old return r end
			section.AddParagraph  = function(_, t, c) local old=tab._page tab._page=inner local r=tab:AddParagraph(t,c) tab._page=old return r end
			return section
		end

		-- ── AddButton ─────────────────────────────────────────────────────
		function tab:AddButton(opts)
			opts = opts or {}
			local b = Button(self._page, {
				Text=opts.Name or "Button", TextColor3=T.Text,
				BackgroundColor3=T.Alt, Size=UDim2.new(1,0,0,32),
			})
			corner(b,5) stroke(b,T.Border)
			b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=T.Border}) end)
			b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=T.Alt}) end)
			b.MouseButton1Click:Connect(function()
				tw(b,{BackgroundColor3=T.AccentDark},0.05)
				task.delay(0.12,function() tw(b,{BackgroundColor3=T.Alt}) end)
				if opts.Callback then opts.Callback() end
			end)
			return b
		end

		-- ── AddToggle ─────────────────────────────────────────────────────
		function tab:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default or false

			local row = New("Frame", {BackgroundColor3=T.Alt, Size=UDim2.new(1,0,0,32), BorderSizePixel=0}, self._page)
			corner(row,5) stroke(row,T.Border)

			Label(row, {Text=opts.Name or "Toggle", Size=UDim2.new(1,-54,1,0), Position=UDim2.new(0,10,0,0)})

			local track = New("Frame", {BackgroundColor3=state and T.Accent or T.Border, Size=UDim2.new(0,34,0,18), Position=UDim2.new(1,-44,0.5,-9), BorderSizePixel=0}, row)
			corner(track,9)
			local knob = New("Frame", {BackgroundColor3=T.White, Size=UDim2.new(0,12,0,12), Position=state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6), BorderSizePixel=0}, track)
			corner(knob,6)

			local obj = {Value=state, _save=opts.Save}
			local function set(v)
				obj.Value = v
				tw(track,{BackgroundColor3=v and T.Accent or T.Border})
				tw(knob,{Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)})
				if opts.Callback then opts.Callback(v) end
				if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder, self._lib.Flags) end
			end
			function obj:Set(v) set(v) end

			local hit = Button(row, {BackgroundTransparency=1, Text="", Size=UDim2.new(1,0,1,0)})
			hit.MouseButton1Click:Connect(function() set(not obj.Value) end)

			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end

		-- ── AddSlider ─────────────────────────────────────────────────────
		function tab:AddSlider(opts)
			opts = opts or {}
			local mn, mx = opts.Min or 0, opts.Max or 100
			local inc    = opts.Increment or 1
			local vname  = opts.ValueName or ""
			local val    = math.clamp(opts.Default or mn, mn, mx)

			local row = New("Frame", {BackgroundColor3=T.Alt, Size=UDim2.new(1,0,0,48), BorderSizePixel=0}, self._page)
			corner(row,5) stroke(row,T.Border)

			Label(row, {Text=opts.Name or "Slider", Size=UDim2.new(1,-70,0,20), Position=UDim2.new(0,10,0,6)})

			local vl = Label(row, {
				Text=tostring(val)..(vname~="" and " "..vname or ""),
				TextSize=12, TextColor3=T.Accent, Font=Enum.Font.GothamMedium,
				TextXAlignment=Enum.TextXAlignment.Right,
				Size=UDim2.new(0,60,0,20), Position=UDim2.new(1,-68,0,6),
			})

			local trackBg = New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,0,34),BorderSizePixel=0},row)
			corner(trackBg,2)
			local fill = New("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new((val-mn)/(mx-mn),0,1,0),BorderSizePixel=0},trackBg)
			corner(fill,2)
			local thumb = New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,10,0,10),Position=UDim2.new((val-mn)/(mx-mn),-5,0.5,-5),BorderSizePixel=0,ZIndex=5},trackBg)
			corner(thumb,5)

			local obj = {Value=val, _save=opts.Save}
			local dragging=false

			local function update(mx_)
				local pct = math.clamp((mx_-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
				local v   = math.round((mn + pct*(mx-mn))/inc)*inc
				v = math.clamp(v,mn,mx)
				obj.Value = v
				vl.Text   = tostring(v)..(vname~="" and " "..vname or "")
				local p   = (v-mn)/(mx-mn)
				tw(fill,{Size=UDim2.new(p,0,1,0)},0.05)
				tw(thumb,{Position=UDim2.new(p,-5,0.5,-5)},0.05)
				if opts.Callback then opts.Callback(v) end
			end

			trackBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true update(i.Position.X) end end)
			UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

			function obj:Set(v)
				v=math.clamp(v,mn,mx) obj.Value=v
				local p=(v-mn)/(mx-mn)
				vl.Text=tostring(v)..(vname~="" and " "..vname or "")
				tw(fill,{Size=UDim2.new(p,0,1,0)}) tw(thumb,{Position=UDim2.new(p,-5,0.5,-5)})
			end

			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end

		-- ── AddDropdown ───────────────────────────────────────────────────
		function tab:AddDropdown(opts)
			opts = opts or {}
			local options = opts.Options or {}
			local sel     = opts.Default or (options[1] or "")
			local open    = false

			local wrapper = Frame(self._page, {Size=UDim2.new(1,0,0,32), ZIndex=5})

			local row = Button(wrapper, {
				BackgroundColor3=T.Alt, Size=UDim2.new(1,0,1,0),
				BackgroundTransparency=0,
			})
			corner(row,5) stroke(row,T.Border)

			Label(row,{Text=opts.Name or "Dropdown",Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0)})
			local selL=Label(row,{Text=sel,TextSize=12,TextColor3=T.Accent,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0.42,-22,1,0),Position=UDim2.new(0.5,0,0,0)})
			local arrow=Label(row,{Text="▾",TextSize=12,TextColor3=T.Muted,TextXAlignment=Enum.TextXAlignment.Center,Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0)})

			local obj = {Value=sel, _save=opts.Save}
			local sg_ = sg

			local dropF = New("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(0,0,0,0),Visible=false,ClipsDescendants=true,ZIndex=30,BorderSizePixel=0},sg_)
			corner(dropF,5) stroke(dropF,T.Border)
			listLayout(dropF,0)

			local itemH = 26
			local function rebuildItems(list, clear)
				if clear then
					for _, ch in ipairs(dropF:GetChildren()) do
						if ch:IsA("TextButton") then ch:Destroy() end
					end
				end
				for _, opt in ipairs(list) do
					local item = Button(dropF,{Text=opt,TextSize=12,TextColor3=T.Text,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,Size=UDim2.new(1,0,0,itemH),ZIndex=31})
					padding(item,0,0,10,0)
					item.MouseEnter:Connect(function() tw(item,{TextColor3=T.Accent}) end)
					item.MouseLeave:Connect(function() tw(item,{TextColor3=T.Text}) end)
					item.MouseButton1Click:Connect(function()
						obj.Value=opt selL.Text=opt
						tw(dropF,{Size=UDim2.new(0,dropF.Size.X.Offset,0,0)},0.12)
						task.delay(0.13,function() dropF.Visible=false end)
						open=false arrow.Text="▾"
						if opts.Callback then opts.Callback(opt) end
						if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder,self._lib.Flags) end
					end)
				end
			end
			rebuildItems(options, false)

			local totalH = #options * itemH + 6
			row.MouseButton1Click:Connect(function()
				open=not open
				if open then
					local abs=row.AbsolutePosition local sz=row.AbsoluteSize
					dropF.Position=UDim2.new(0,abs.X,0,abs.Y+sz.Y+4)
					dropF.Size=UDim2.new(0,sz.X,0,0) dropF.Visible=true
					tw(dropF,{Size=UDim2.new(0,sz.X,0,totalH)},0.15,Enum.EasingStyle.Back)
					arrow.Text="▴"
				else
					tw(dropF,{Size=UDim2.new(0,dropF.Size.X.Offset,0,0)},0.12)
					task.delay(0.13,function() dropF.Visible=false end) arrow.Text="▾"
				end
			end)

			function obj:Set(v)
				if table.find(options,v) then
					obj.Value=v selL.Text=v
					if opts.Callback then opts.Callback(v) end
				end
			end
			function obj:Refresh(list, clear)
				options=list totalH=#list*itemH+6
				rebuildItems(list, clear)
			end

			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end

		-- ── AddTextbox ────────────────────────────────────────────────────
		function tab:AddTextbox(opts)
			opts = opts or {}
			local row = New("Frame",{BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,48),BorderSizePixel=0},self._page)
			corner(row,5) stroke(row,T.Border)

			Label(row,{Text=opts.Name or "Input",TextSize=11,TextColor3=T.Muted,Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,10,0,4)})

			local box=New("TextBox",{
				BackgroundTransparency=1,PlaceholderText=opts.Default or "",
				PlaceholderColor3=T.Muted,Text="",TextColor3=T.Text,
				TextSize=13,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,
				ClearTextOnFocus=opts.TextDisappear or false,
				Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,26),
			},row)

			box.Focused:Connect(function() tw(row,{BackgroundColor3=T.Border}) end)
			box.FocusLost:Connect(function(enter)
				tw(row,{BackgroundColor3=T.Alt})
				if opts.Callback then opts.Callback(box.Text) end
				if opts.TextDisappear then box.Text="" end
			end)
			return box
		end

		-- ── AddBind ───────────────────────────────────────────────────────
		function tab:AddBind(opts)
			opts = opts or {}
			local bound     = opts.Default or Enum.KeyCode.Unknown
			local holdMode  = opts.Hold or false
			local listening = false
			local holding   = false

			local row = New("Frame",{BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,32),BorderSizePixel=0},self._page)
			corner(row,5) stroke(row,T.Border)
			Label(row,{Text=opts.Name or "Bind",Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,10,0,0)})

			local keyBtn=Button(row,{
				Text=bound.Name,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=T.Accent,
				BackgroundColor3=T.Border,BackgroundTransparency=0,
				Size=UDim2.new(0,76,0,22),Position=UDim2.new(1,-82,0.5,-11),
			})
			corner(keyBtn,4)

			local obj={Value=bound,_save=opts.Save}
			local function setKey(k)
				bound=k obj.Value=k keyBtn.Text=k.Name keyBtn.TextColor3=T.Accent listening=false
				if opts.Callback and not holdMode then end
			end

			keyBtn.MouseButton1Click:Connect(function()
				if listening then listening=false keyBtn.Text=bound.Name keyBtn.TextColor3=T.Accent return end
				listening=true keyBtn.Text="..." keyBtn.TextColor3=T.Muted
			end)

			UIS.InputBegan:Connect(function(i,gp)
				if gp then return end
				if listening and i.UserInputType==Enum.UserInputType.Keyboard then
					setKey(i.KeyCode)
				elseif i.KeyCode==bound and bound~=Enum.KeyCode.Unknown then
					if holdMode then
						holding=true
						if opts.Callback then opts.Callback(true) end
					else
						if opts.Callback then opts.Callback() end
					end
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if holdMode and i.KeyCode==bound and holding then
					holding=false
					if opts.Callback then opts.Callback(false) end
				end
			end)

			function obj:Set(k) setKey(k) end
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end

		-- ── AddColorpicker ────────────────────────────────────────────────
		function tab:AddColorpicker(opts)
			opts = opts or {}
			local color = opts.Default or Color3.fromRGB(255,0,0)
			local open  = false

			local row = New("Frame",{BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,32),BorderSizePixel=0},self._page)
			corner(row,5) stroke(row,T.Border)
			Label(row,{Text=opts.Name or "Color",Size=UDim2.new(1,-54,1,0),Position=UDim2.new(0,10,0,0)})

			local swatch = Button(row,{
				BackgroundColor3=color,BackgroundTransparency=0,
				Size=UDim2.new(0,40,0,20),Position=UDim2.new(1,-46,0.5,-10),Text="",
			})
			corner(swatch,4) stroke(swatch,T.Border,1)

			-- Simple HSV picker panel
			local pickerF = New("Frame",{
				BackgroundColor3=T.Surface,
				Size=UDim2.new(0,200,0,160),
				Visible=false,ZIndex=25,BorderSizePixel=0,
			},sg)
			corner(pickerF,7) stroke(pickerF,T.Border)
			padding(pickerF,8,8,8,8)

			local obj={Value=color,_save=opts.Save}

			-- Hue slider
			Label(pickerF,{Text="H",TextSize=10,TextColor3=T.Muted,Size=UDim2.new(0,10,0,16),Position=UDim2.new(0,0,0,0)})
			local hTrack=New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,14,0,3),BorderSizePixel=0},pickerF)
			corner(hTrack,3)
			-- rainbow fill
			local rainbow=New("UIGradient",{
				Color=ColorSequence.new({
					ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
					ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
					ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
					ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),
					ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
					ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
					ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
				}),
			},hTrack)
			local hThumb=New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,8,0,16),Position=UDim2.new(0,-4,0.5,-8),BorderSizePixel=0,ZIndex=26},hTrack)
			corner(hThumb,3)

			-- S slider
			Label(pickerF,{Text="S",TextSize=10,TextColor3=T.Muted,Size=UDim2.new(0,10,0,16),Position=UDim2.new(0,0,0,24)})
			local sTrack=New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,14,0,27),BorderSizePixel=0},pickerF)
			corner(sTrack,3)
			New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})},sTrack)
			local sThumb=New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,8,0,16),Position=UDim2.new(0,-4,0.5,-8),BorderSizePixel=0,ZIndex=26},sTrack)
			corner(sThumb,3)

			-- V slider
			Label(pickerF,{Text="V",TextSize=10,TextColor3=T.Muted,Size=UDim2.new(0,10,0,16),Position=UDim2.new(0,0,0,48)})
			local vTrack=New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,14,0,51),BorderSizePixel=0},pickerF)
			corner(vTrack,3)
			New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})},vTrack)
			local vThumb=New("Frame",{BackgroundColor3=T.White,Size=UDim2.new(0,8,0,16),Position=UDim2.new(0,-4,0.5,-8),BorderSizePixel=0,ZIndex=26},vTrack)
			corner(vThumb,3)

			local previewF=New("Frame",{BackgroundColor3=color,Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,72),BorderSizePixel=0},pickerF)
			corner(previewF,4) stroke(previewF,T.Border)

			local hexBox=New("TextBox",{BackgroundTransparency=1,Text=string.format("#%02X%02X%02X",math.floor(color.R*255),math.floor(color.G*255),math.floor(color.B*255)),TextColor3=T.Text,TextSize=11,Font=Enum.Font.GothamMedium,Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,104)},pickerF)

			local h_,s_,v_ = color:ToHSV()

			local function applyHSV()
				local c=Color3.fromHSV(h_,s_,v_)
				obj.Value=c swatch.BackgroundColor3=c previewF.BackgroundColor3=c
				hexBox.Text=string.format("#%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
				if opts.Callback then opts.Callback(c) end
				if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder,self._lib.Flags) end
			end

			local function makeSliderDrag(track, thumb, onUpdate)
				local d=false
				track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true onUpdate(i.Position.X) end end)
				UIS.InputChanged:Connect(function(i) if d and i.UserInputType==Enum.UserInputType.MouseMovement then onUpdate(i.Position.X) end end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)
			end

			makeSliderDrag(hTrack,hThumb,function(mx)
				local p=math.clamp((mx-hTrack.AbsolutePosition.X)/hTrack.AbsoluteSize.X,0,1)
				h_=p tw(hThumb,{Position=UDim2.new(p,-4,0.5,-8)},0.04) applyHSV()
			end)
			makeSliderDrag(sTrack,sThumb,function(mx)
				local p=math.clamp((mx-sTrack.AbsolutePosition.X)/sTrack.AbsoluteSize.X,0,1)
				s_=p tw(sThumb,{Position=UDim2.new(p,-4,0.5,-8)},0.04) applyHSV()
			end)
			makeSliderDrag(vTrack,vThumb,function(mx)
				local p=math.clamp((mx-vTrack.AbsolutePosition.X)/vTrack.AbsoluteSize.X,0,1)
				v_=p tw(vThumb,{Position=UDim2.new(p,-4,0.5,-8)},0.04) applyHSV()
			end)

			swatch.MouseButton1Click:Connect(function()
				open=not open
				if open then
					local abs=swatch.AbsolutePosition local sz=swatch.AbsoluteSize
					pickerF.Position=UDim2.new(0,abs.X-160,0,abs.Y+sz.Y+4)
					pickerF.Visible=true
				else
					pickerF.Visible=false
				end
			end)

			function obj:Set(c)
				obj.Value=c swatch.BackgroundColor3=c previewF.BackgroundColor3=c
				h_,s_,v_=c:ToHSV()
				tw(hThumb,{Position=UDim2.new(h_,-4,0.5,-8)})
				tw(sThumb,{Position=UDim2.new(s_,-4,0.5,-8)})
				tw(vThumb,{Position=UDim2.new(v_,-4,0.5,-8)})
				hexBox.Text=string.format("#%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
			end

			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end

		-- ── AddLabel ──────────────────────────────────────────────────────
		function tab:AddLabel(text, color)
			local l=Label(self._page,{
				Text=text or "",TextSize=12,TextColor3=color or T.Muted,
				Size=UDim2.new(1,0,0,18),TextWrapped=true,
			})
			local obj={}
			function obj:Set(t) l.Text=t end
			return obj
		end

		-- ── AddParagraph ──────────────────────────────────────────────────
		function tab:AddParagraph(title_, content_)
			local row=Frame(self._page,{
				BackgroundColor3=T.Alt,Size=UDim2.new(1,0,0,0),
				AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0,
			})
			corner(row,5) stroke(row,T.Border) padding(row,8,8,10,10)
			local layout=listLayout(row,4)

			local tl=Label(row,{Text=title_ or "",Font=Enum.Font.GothamBold,TextSize=13,Size=UDim2.new(1,0,0,18)})
			local cl=Label(row,{Text=content_ or "",TextSize=12,TextColor3=T.Muted,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true})

			local obj={}
			function obj:Set(t,c) tl.Text=t cl.Text=c end
			return obj
		end

		-- ── AddSeparator ──────────────────────────────────────────────────
		function tab:AddSeparator()
			New("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),BorderSizePixel=0},self._page)
		end

		return tab
	end

	return win
end

-- ── Init (call at end of script) ──────────────────────────────────────────────
function PercsUI:Init()
	-- intentional no-op stub for Orion API compatibility
	-- config loading is handled automatically in MakeWindow
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function PercsUI:Destroy()
	for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
		if v.Name:sub(1,5) == "Percs" then v:Destroy() end
	end
	pcall(function()
		for _, v in ipairs(PL.PlayerGui:GetChildren()) do
			if v.Name:sub(1,5) == "Percs" then v:Destroy() end
		end
	end)
end

return PercsUI
