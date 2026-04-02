local PercsUI = {}
PercsUI.__index = PercsUI
PercsUI.Flags = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL = game:GetService("Players").LocalPlayer
local HS = game:GetService("HttpService")

local T = {
	Win = Color3.fromRGB(10, 10, 10),
	Surface = Color3.fromRGB(15, 15, 15),
	Raised = Color3.fromRGB(20, 20, 20),
	Element = Color3.fromRGB(25, 25, 25),
	Hover = Color3.fromRGB(32, 32, 32),
	Border = Color3.fromRGB(40, 40, 40),
	BorderFaint = Color3.fromRGB(28, 28, 28),
	Accent = Color3.fromRGB(0, 210, 175),
	AccentDim = Color3.fromRGB(0, 150, 125),
	AccentGlow = Color3.fromRGB(0, 255, 210),
	Text = Color3.fromRGB(220, 220, 220),
	TextDim = Color3.fromRGB(150, 150, 150),
	Muted = Color3.fromRGB(75, 75, 75),
	Red = Color3.fromRGB(210, 60, 60),
	White = Color3.new(1, 1, 1),
}

local function tw(o, p, t, s, d)
	TS:Create(o, TweenInfo.new(t or 0.13, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out), p):Play()
end

local function New(cls, props, parent)
	local i = Instance.new(cls)
	for k, v in pairs(props or {}) do i[k] = v end
	if parent then i.Parent = parent end
	return i
end

local function corner(p, r) return New("UICorner", { CornerRadius = UDim.new(0, r or 5) }, p) end
local function stroke(p, c, t) return New("UIStroke", { Color = c or T.Border, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, t, b, l, r) return New("UIPadding", { PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0) }, p) end
local function list(p, g, so) return New("UIListLayout", { Padding = UDim.new(0, g or 0), SortOrder = so or Enum.SortOrder.LayoutOrder }, p) end

local function F(parent, bg, sz, pos, zindex)
	return New("Frame", { BackgroundColor3 = bg, Size = sz or UDim2.new(1, 0, 0, 32), Position = pos or UDim2.new(0, 0, 0, 0), BorderSizePixel = 0, ZIndex = zindex or 1 }, parent)
end

local function Lbl(parent, props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	if not props.Font then props.Font = Enum.Font.GothamMedium end
	if not props.TextSize then props.TextSize = 13 end
	if not props.TextColor3 then props.TextColor3 = T.Text end
	if not props.TextXAlignment then props.TextXAlignment = Enum.TextXAlignment.Left end
	return New("TextLabel", props, parent)
end

local function Btn(parent, props)
	props.BorderSizePixel = 0
	props.AutoButtonColor = false
	if not props.Font then props.Font = Enum.Font.GothamMedium end
	if not props.TextSize then props.TextSize = 13 end
	if not props.TextColor3 then props.TextColor3 = T.Text end
	if props.BackgroundColor3 == nil then props.BackgroundTransparency = 1 end
	return New("TextButton", props, parent)
end

local function Divider(parent)
	return F(parent, T.BorderFaint, UDim2.new(1, 0, 0, 1))
end

local function makeDraggable(root, handle)
	local drag, start, origin
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag, start, origin = true, i.Position, root.Position end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - start
			root.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
	end)
end

local function getGui(name, order)
	local sg = New("ScreenGui", { Name = name, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = order or 10 })
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok or not sg.Parent then sg.Parent = PL:WaitForChild("PlayerGui") end
	return sg
end

local function cfgPath(folder) return folder .. "/" .. tostring(game.PlaceId) .. ".json" end

local function saveConfig(folder, flags)
	pcall(function()
		if not isfolder(folder) then makefolder(folder) end
		local d = {}
		for k, v in pairs(flags) do if v._save then d[k] = v.Value end end
		writefile(cfgPath(folder), HS:JSONEncode(d))
	end)
end

local function loadConfig(folder, flags)
	pcall(function()
		local p = cfgPath(folder)
		if not isfile(p) then return end
		for k, v in pairs(HS:JSONDecode(readfile(p))) do
			if flags[k] and flags[k].Set then flags[k]:Set(v) end
		end
	end)
end

local _nGui, _nStack

local function ensureNotifs()
	if _nGui and _nGui.Parent then return end
	_nGui = getGui("PercsNotifs", 999)
	_nStack = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 295, 1, 0), Position = UDim2.new(1, -305, 0, 0), BorderSizePixel = 0 }, _nGui)
	local ll = list(_nStack, 8)
	ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
	pad(_nStack, 0, 16, 0, 0)
end

function PercsUI:MakeNotification(opts)
	opts = opts or {}
	ensureNotifs()
	local col = opts.Type == "success" and Color3.fromRGB(0, 200, 100) or opts.Type == "error" and T.Red or T.Accent
	local card = New("Frame", { BackgroundColor3 = T.Raised, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, BorderSizePixel = 0 }, _nStack)
	corner(card, 6)
	stroke(card, T.Border)
	local bar = F(card, col, UDim2.new(0, 2, 1, 0))
	corner(bar, 0)
	Lbl(card, { Text = opts.Name or "Percs", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T.Text, Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 14, 0, 10) })
	Lbl(card, { Text = opts.Content or "", TextSize = 11, TextColor3 = T.TextDim, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 14, 0, 28), TextWrapped = true })
	tw(card, { Size = UDim2.new(1, 0, 0, 60) }, 0.22, Enum.EasingStyle.Back)
	task.delay(opts.Time or 3, function()
		tw(card, { Size = UDim2.new(1, 0, 0, 0) }, 0.18)
		task.delay(0.2, function() card:Destroy() end)
	end)
end

function PercsUI:MakeWindow(opts)
	opts = opts or {}
	local title = opts.Name or "Percs"
	local doSave = opts.SaveConfig or false
	local cfgFolder = opts.ConfigFolder or "PercsConfig"
	local W, H = 560, 380
	if doSave then
		self._saveEnabled = true
		self._saveFolder = cfgFolder
	end
	if opts.IntroEnabled ~= false then
		local isg = getGui("PercsIntro", 100)
		local bg = F(isg, Color3.new(0, 0, 0), UDim2.new(1, 0, 1, 0))
		if opts.IntroIcon and opts.IntroIcon ~= "" then
			New("ImageLabel", { Image = opts.IntroIcon, BackgroundTransparency = 1, ImageTransparency = 1, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, -20, 0.5, -38) }, bg)
		end
		local il = Lbl(bg, { Text = opts.IntroText or title, Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = T.Accent, TextTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.5, -15), TextXAlignment = Enum.TextXAlignment.Center })
		tw(il, { TextTransparency = 0 }, 0.5)
		if bg:FindFirstChildOfClass("ImageLabel") then tw(bg:FindFirstChildOfClass("ImageLabel"), { ImageTransparency = 0 }, 0.5) end
		task.delay(1.3, function()
			tw(bg, { BackgroundTransparency = 1 }, 0.35)
			tw(il, { TextTransparency = 1 }, 0.25)
			task.delay(0.4, function() isg:Destroy() end)
		end)
	end
	local sg = getGui("PercsUI_" .. title)
	local shadow = F(sg, Color3.new(0, 0, 0), UDim2.new(0, W + 32, 0, H + 32), UDim2.new(0.5, -(W + 32) / 2, 0.5, -(H + 32) / 2))
	shadow.BackgroundTransparency = 0.75
	shadow.ZIndex = 0
	corner(shadow, 12)
	local root = F(sg, T.Win, UDim2.new(0, W, 0, H), UDim2.new(0.5, -W / 2, 0.5, -H / 2))
	corner(root, 7)
	stroke(root, T.Border)
	local topbar = F(root, T.Surface, UDim2.new(1, 0, 0, 40))
	corner(topbar, 7)
	F(topbar, T.Surface, UDim2.new(1, 0, 0, 8), UDim2.new(0, 0, 1, -8))
	local tpip = F(topbar, T.Accent, UDim2.new(0, 2, 0.4, 0), UDim2.new(0, 12, 0.3, 0))
	corner(tpip, 1)
	if opts.Icon and opts.Icon ~= "" then
		New("ImageLabel", { Image = opts.Icon, BackgroundTransparency = 1, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 20, 0.5, -9) }, topbar)
	end
	local titleLbl = Lbl(topbar, { Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.Text, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, (opts.Icon and opts.Icon ~= "") and 44 or 20, 0, 0) })
	F(root, T.BorderFaint, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 40))
	local function winBtn(xOff, glyph, hoverCol, cb)
		local b = Btn(topbar, { Text = glyph, TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = T.Muted, BackgroundTransparency = 1, Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(1, xOff, 0, 0) })
		b.MouseEnter:Connect(function() tw(b, { TextColor3 = hoverCol }) end)
		b.MouseLeave:Connect(function() tw(b, { TextColor3 = T.Muted }) end)
		b.MouseButton1Click:Connect(cb)
		return b
	end
	winBtn(-26, "×", T.Red, function()
		if opts.CloseCallback then opts.CloseCallback() end
		if self._saveEnabled then saveConfig(self._saveFolder, self.Flags) end
		tw(root, { Size = UDim2.new(0, W, 0, 0), Position = UDim2.new(0.5, -W / 2, 0.5, 0) }, 0.16)
		tw(shadow, { BackgroundTransparency = 1 }, 0.16)
		task.delay(0.18, function() sg:Destroy() end)
	end)
	local minimized = false
	winBtn(-52, "–", T.TextDim, function()
		minimized = not minimized
		tw(root, { Size = minimized and UDim2.new(0, W, 0, 40) or UDim2.new(0, W, 0, H) }, 0.18)
	end)
	makeDraggable(root, topbar)
	local SIDEBAR_W = 112
	local sidebar = F(root, T.Surface, UDim2.new(0, SIDEBAR_W, 1, -41), UDim2.new(0, 0, 0, 41))
	sidebar.ClipsDescendants = true
	list(sidebar, 2)
	pad(sidebar, 8, 8, 6, 6)
	F(root, T.BorderFaint, UDim2.new(0, 1, 1, -41), UDim2.new(0, SIDEBAR_W, 0, 41))
	local content = F(root, Color3.new(0, 0, 0), UDim2.new(1, -(SIDEBAR_W + 1), 1, -41), UDim2.new(0, SIDEBAR_W + 1, 0, 41))
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	local footer = F(root, T.Surface, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 1, -20))
	F(footer, T.Surface, UDim2.new(1, 0, 0, 6))
	F(root, T.BorderFaint, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -21))
	Lbl(footer, { Text = "percs ui v4", TextSize = 10, TextColor3 = T.Muted, Font = Enum.Font.Gotham, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0) })
	if doSave then task.delay(0.6, function() loadConfig(cfgFolder, self.Flags) end) end
	local win = { _sg = sg, _root = root, _sidebar = sidebar, _content = content, _tabs = {}, _active = nil, _lib = self }
	function win:MakeTab(opts)
		opts = opts or {}
		local name = opts.Name or "Tab"
		local btn = Btn(self._sidebar, { Text = name, TextSize = 11, Font = Enum.Font.GothamMedium, TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Left, BackgroundColor3 = T.Element, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26) })
		corner(btn, 4)
		pad(btn, 0, 0, 8, 0)
		local pill = F(btn, T.Accent, UDim2.new(0, 2, 0.5, 0), UDim2.new(0, 0, 0.25, 0))
		pill.Visible = false
		corner(pill, 1)
		if opts.Icon and opts.Icon ~= "" then
			New("ImageLabel", { Image = opts.Icon, BackgroundTransparency = 1, ImageColor3 = T.Muted, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 6, 0.5, -6) }, btn)
		end
		local page = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -20), BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, self._content)
		list(page, 4)
		pad(page, 10, 10, 10, 10)
		local tab = { _btn = btn, _page = page, _pill = pill, _win = self, _lib = self._lib }
		local function activate()
			for _, t in ipairs(self._tabs) do
				t._page.Visible = false
				t._pill.Visible = false
				tw(t._btn, { TextColor3 = T.Muted, BackgroundTransparency = 1 })
				local ic = t._btn:FindFirstChildOfClass("ImageLabel")
				if ic then tw(ic, { ImageColor3 = T.Muted }) end
			end
			page.Visible = true
			pill.Visible = true
			tw(btn, { TextColor3 = T.Accent, BackgroundTransparency = 0.88 })
			local ic = btn:FindFirstChildOfClass("ImageLabel")
			if ic then tw(ic, { ImageColor3 = T.Accent }) end
			self._active = tab
		end
		btn.MouseButton1Click:Connect(activate)
		btn.MouseEnter:Connect(function() if self._active ~= tab then tw(btn, { TextColor3 = T.TextDim, BackgroundTransparency = 0.94 }) end end)
		btn.MouseLeave:Connect(function() if self._active ~= tab then tw(btn, { TextColor3 = T.Muted, BackgroundTransparency = 1 }) end end)
		table.insert(self._tabs, tab)
		if #self._tabs == 1 then activate() end
		function tab:AddSection(opts)
			opts = type(opts) == "string" and { Name = opts } or (opts or {})
			local sName = (opts.Name or "Section"):upper()
			local header = F(self._page, Color3.new(0, 0, 0), UDim2.new(1, 0, 0, 20))
			header.BackgroundTransparency = 1
			local pip = F(header, T.Accent, UDim2.new(0, 2, 0.6, 0), UDim2.new(0, 0, 0.2, 0))
			corner(pip, 1)
			Lbl(header, { Text = sName, TextSize = 10, TextColor3 = T.TextDim, Font = Enum.Font.GothamBold, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0) })
			local inner = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0 }, self._page)
			list(inner, 4)
			local section = { _page = inner, _lib = self._lib, _win = self._win }
			local proxy = tab
			local methods = { "AddButton", "AddToggle", "AddSlider", "AddDropdown", "AddTextbox", "AddBind", "AddColorpicker", "AddLabel", "AddParagraph", "AddSeparator" }
			for _, m in ipairs(methods) do
				section[m] = function(s, o)
					local old = proxy._page
					proxy._page = inner
					local r = proxy[m](proxy, o)
					proxy._page = old
					return r
				end
			end
			return section
		end
		function tab:AddButton(opts)
			opts = opts or {}
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 30))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Button", TextSize = 12, TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 1, 0) })
			local hit = Btn(row, { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) })
			hit.MouseEnter:Connect(function()
				tw(row, { BackgroundColor3 = T.Hover })
				local l = row:FindFirstChildOfClass("TextLabel")
				if l then tw(l, { TextColor3 = T.Text }) end
			end)
			hit.MouseLeave:Connect(function()
				tw(row, { BackgroundColor3 = T.Element })
				local l = row:FindFirstChildOfClass("TextLabel")
				if l then tw(l, { TextColor3 = T.TextDim }) end
			end)
			hit.MouseButton1Click:Connect(function()
				tw(row, { BackgroundColor3 = T.AccentDim }, 0.04)
				task.delay(0.1, function() tw(row, { BackgroundColor3 = T.Element }) end)
				if opts.Callback then opts.Callback() end
			end)
			return hit
		end
		function tab:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default or false
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 32))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Toggle", TextSize = 12, TextColor3 = T.TextDim, Size = UDim2.new(1, -52, 1, 0), Position = UDim2.new(0, 10, 0, 0) })
			local track = F(row, state and T.Accent or T.Muted, UDim2.new(0, 32, 0, 17), UDim2.new(1, -42, 0.5, -8.5))
			corner(track, 9)
			local knob = F(track, T.White, UDim2.new(0, 11, 0, 11), state and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5))
			corner(knob, 6)
			local trackStroke = stroke(track, state and T.AccentDim or T.Border, 1)
			local obj = { Value = state, _save = opts.Save }
			local function set(v)
				obj.Value = v
				tw(track, { BackgroundColor3 = v and T.Accent or T.Muted })
				tw(knob, { Position = v and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5) })
				tw(trackStroke, { Color = v and T.AccentDim or T.Border })
				if opts.Callback then opts.Callback(v) end
				if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder, self._lib.Flags) end
			end
			function obj:Set(v) set(v) end
			local hit = Btn(row, { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0) })
			hit.MouseButton1Click:Connect(function() set(not obj.Value) end)
			row.MouseEnter:Connect(function() tw(row, { BackgroundColor3 = T.Hover }) end)
			row.MouseLeave:Connect(function() tw(row, { BackgroundColor3 = T.Element }) end)
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end
		function tab:AddSlider(opts)
			opts = opts or {}
			local mn, mx = opts.Min or 0, opts.Max or 100
			local inc = opts.Increment or 1
			local vname = opts.ValueName or ""
			local val = math.clamp(opts.Default or mn, mn, mx)
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 46))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Slider", TextSize = 12, TextColor3 = T.TextDim, Size = UDim2.new(1, -70, 0, 18), Position = UDim2.new(0, 10, 0, 6) })
			local valLbl = Lbl(row, { Text = tostring(val) .. (vname ~= "" and " " .. vname or ""), TextSize = 11, TextColor3 = T.Accent, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 62, 0, 18), Position = UDim2.new(1, -70, 0, 6) })
			local trackBg = F(row, T.Raised, UDim2.new(1, -20, 0, 5), UDim2.new(0, 10, 0, 32))
			corner(trackBg, 3)
			local pct0 = (val - mn) / (mx - mn)
			local fill = F(trackBg, T.Accent, UDim2.new(pct0, 0, 1, 0))
			corner(fill, 3)
			local thumb = F(trackBg, T.White, UDim2.new(0, 9, 0, 9), UDim2.new(pct0, -4.5, 0.5, -4.5))
			corner(thumb, 5)
			thumb.ZIndex = 5
			local obj = { Value = val, _save = opts.Save }
			local dragging = false
			local function update(mx_)
				local p = math.clamp((mx_ - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
				local v = math.round((mn + p * (mx - mn)) / inc) * inc
				v = math.clamp(v, mn, mx)
				obj.Value = v
				valLbl.Text = tostring(v) .. (vname ~= "" and " " .. vname or "")
				local pp = (v - mn) / (mx - mn)
				tw(fill, { Size = UDim2.new(pp, 0, 1, 0) }, 0.04)
				tw(thumb, { Position = UDim2.new(pp, -4.5, 0.5, -4.5) }, 0.04)
				if opts.Callback then opts.Callback(v) end
			end
			trackBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(i.Position.X) end end)
			UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			row.MouseEnter:Connect(function() tw(row, { BackgroundColor3 = T.Hover }) end)
			row.MouseLeave:Connect(function() tw(row, { BackgroundColor3 = T.Element }) end)
			function obj:Set(v)
				v = math.clamp(v, mn, mx)
				obj.Value = v
				local p = (v - mn) / (mx - mn)
				valLbl.Text = tostring(v) .. (vname ~= "" and " " .. vname or "")
				tw(fill, { Size = UDim2.new(p, 0, 1, 0) })
				tw(thumb, { Position = UDim2.new(p, -4.5, 0.5, -4.5) })
			end
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end
		function tab:AddDropdown(opts)
			opts = opts or {}
			local options = opts.Options or {}
			local sel = opts.Default or (options[1] or "")
			local open = false
			local wrapper = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), BorderSizePixel = 0, ZIndex = 5 }, self._page)
			local row = Btn(wrapper, { BackgroundColor3 = T.Element, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 1, 0) })
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Dropdown", TextSize = 12, TextColor3 = T.TextDim, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0) })
			local selLbl = Lbl(row, { Text = sel, TextSize = 11, TextColor3 = T.Accent, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0.44, -20, 1, 0), Position = UDim2.new(0.5, 0, 0, 0) })
			local chevron = Lbl(row, { Text = "⌄", TextSize = 12, TextColor3 = T.Muted, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0) })
			local obj = { Value = sel, _save = opts.Save }
			local sg_ = sg
			local dropF = New("Frame", { BackgroundColor3 = T.Raised, Size = UDim2.new(0, 0, 0, 0), Visible = false, ClipsDescendants = true, ZIndex = 40, BorderSizePixel = 0 }, sg_)
			corner(dropF, 5)
			stroke(dropF, T.Border)
			list(dropF, 0)
			local itemH = 24
			local function rebuildItems(lst, clear)
				if clear then
					for _, ch in ipairs(dropF:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
				end
				for _, opt in ipairs(lst) do
					local item = Btn(dropF, { Text = opt, TextSize = 11, TextColor3 = T.TextDim, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, itemH), ZIndex = 41 })
					pad(item, 0, 0, 10, 0)
					item.MouseEnter:Connect(function()
						tw(item, { BackgroundTransparency = 0.85, TextColor3 = T.Accent })
						item.BackgroundColor3 = T.Element
					end)
					item.MouseLeave:Connect(function() tw(item, { BackgroundTransparency = 1, TextColor3 = T.TextDim }) end)
					item.MouseButton1Click:Connect(function()
						obj.Value = opt
						selLbl.Text = opt
						tw(dropF, { Size = UDim2.new(0, dropF.Size.X.Offset, 0, 0) }, 0.1)
						task.delay(0.11, function() dropF.Visible = false end)
						open = false
						chevron.Text = "⌄"
						if opts.Callback then opts.Callback(opt) end
						if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder, self._lib.Flags) end
					end)
				end
			end
			rebuildItems(options, false)
			local totalH = #options * itemH + 4
			row.MouseButton1Click:Connect(function()
				open = not open
				if open then
					local ab = row.AbsolutePosition
					local sz = row.AbsoluteSize
					dropF.Position = UDim2.new(0, ab.X, 0, ab.Y + sz.Y + 3)
					dropF.Size = UDim2.new(0, sz.X, 0, 0)
					dropF.Visible = true
					tw(dropF, { Size = UDim2.new(0, sz.X, 0, totalH) }, 0.14, Enum.EasingStyle.Back)
					chevron.Text = "⌃"
				else
					tw(dropF, { Size = UDim2.new(0, dropF.Size.X.Offset, 0, 0) }, 0.1)
					task.delay(0.11, function() dropF.Visible = false end)
					chevron.Text = "⌄"
				end
			end)
			row.MouseEnter:Connect(function() tw(row, { BackgroundColor3 = T.Hover }) end)
			row.MouseLeave:Connect(function() tw(row, { BackgroundColor3 = T.Element }) end)
			function obj:Set(v)
				if table.find(options, v) then
					obj.Value = v
					selLbl.Text = v
					if opts.Callback then opts.Callback(v) end
				end
			end
			function obj:Refresh(lst, clear)
				options = lst
				totalH = #lst * itemH + 4
				rebuildItems(lst, clear)
			end
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end
		function tab:AddTextbox(opts)
			opts = opts or {}
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 46))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Input", TextSize = 10, TextColor3 = T.Muted, Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, 5) })
			local box = New("TextBox", { BackgroundTransparency = 1, PlaceholderText = opts.Default or "...", PlaceholderColor3 = T.Muted, Text = "", TextColor3 = T.Text, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = opts.TextDisappear or false, Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 24) }, row)
			local underline = F(row, T.Border, UDim2.new(1, -20, 0, 1), UDim2.new(0, 10, 1, -8))
			box.Focused:Connect(function()
				tw(row, { BackgroundColor3 = T.Hover })
				tw(underline, { BackgroundColor3 = T.Accent })
			end)
			box.FocusLost:Connect(function()
				tw(row, { BackgroundColor3 = T.Element })
				tw(underline, { BackgroundColor3 = T.Border })
				if opts.Callback then opts.Callback(box.Text) end
				if opts.TextDisappear then box.Text = "" end
			end)
			return box
		end
		function tab:AddBind(opts)
			opts = opts or {}
			local bound = opts.Default or Enum.KeyCode.Unknown
			local holdMode = opts.Hold or false
			local listening, holding = false, false
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 32))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Bind", TextSize = 12, TextColor3 = T.TextDim, Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 10, 0, 0) })
			local keyBtn = Btn(row, { Text = bound == Enum.KeyCode.Unknown and "NONE" or bound.Name, TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = T.Accent, BackgroundColor3 = T.Raised, BackgroundTransparency = 0, Size = UDim2.new(0, 72, 0, 20), Position = UDim2.new(1, -78, 0.5, -10) })
			corner(keyBtn, 4)
			stroke(keyBtn, T.Border)
			local obj = { Value = bound, _save = opts.Save }
			local function setKey(k)
				bound = k
				obj.Value = k
				keyBtn.Text = k == Enum.KeyCode.Unknown and "NONE" or k.Name
				keyBtn.TextColor3 = T.Accent
				listening = false
			end
			keyBtn.MouseButton1Click:Connect(function()
				if listening then
					listening = false
					keyBtn.Text = bound == Enum.KeyCode.Unknown and "NONE" or bound.Name
					keyBtn.TextColor3 = T.Accent
					return
				end
				listening = true
				keyBtn.Text = "..."
				keyBtn.TextColor3 = T.Muted
			end)
			UIS.InputBegan:Connect(function(i, gp)
				if gp then return end
				if listening and i.UserInputType == Enum.UserInputType.Keyboard then
					setKey(i.KeyCode)
				elseif not listening and i.KeyCode == bound and bound ~= Enum.KeyCode.Unknown then
					if holdMode then
						holding = true
						if opts.Callback then opts.Callback(true) end
					else
						if opts.Callback then opts.Callback() end
					end
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if holdMode and i.KeyCode == bound and holding then
					holding = false
					if opts.Callback then opts.Callback(false) end
				end
			end)
			row.MouseEnter:Connect(function() tw(row, { BackgroundColor3 = T.Hover }) end)
			row.MouseLeave:Connect(function() tw(row, { BackgroundColor3 = T.Element }) end)
			function obj:Set(k) setKey(k) end
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end
		function tab:AddColorpicker(opts)
			opts = opts or {}
			local color = opts.Default or Color3.fromRGB(255, 0, 0)
			local open = false
			local row = F(self._page, T.Element, UDim2.new(1, 0, 0, 32))
			corner(row, 5)
			stroke(row, T.Border)
			Lbl(row, { Text = opts.Name or "Color", TextSize = 12, TextColor3 = T.TextDim, Size = UDim2.new(1, -54, 1, 0), Position = UDim2.new(0, 10, 0, 0) })
			local swatch = Btn(row, { BackgroundColor3 = color, BackgroundTransparency = 0, Text = "", Size = UDim2.new(0, 38, 0, 18), Position = UDim2.new(1, -44, 0.5, -9) })
			corner(swatch, 4)
			stroke(swatch, T.Border)
			local pickerF = New("Frame", { BackgroundColor3 = T.Raised, Size = UDim2.new(0, 210, 0, 168), Visible = false, ZIndex = 35, BorderSizePixel = 0 }, sg)
			corner(pickerF, 6)
			stroke(pickerF, T.Border)
			pad(pickerF, 10, 10, 10, 10)
			local obj = { Value = color, _save = opts.Save }
			local h_, s_, v_ = color:ToHSV()
			local function applyHSV()
				local c = Color3.fromHSV(h_, s_, v_)
				obj.Value = c
				swatch.BackgroundColor3 = c
				if pickerF:FindFirstChild("__preview") then pickerF.__preview.BackgroundColor3 = c end
				if pickerF:FindFirstChild("__hex") then pickerF.__hex.Text = string.format("%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)) end
				if opts.Callback then opts.Callback(c) end
				if opts.Flag and self._lib._saveEnabled then saveConfig(self._lib._saveFolder, self._lib.Flags) end
			end
			local function makeSlider(yPos, label_, gradStart, gradEnd, getV, setV)
				Lbl(pickerF, { Text = label_, TextSize = 10, TextColor3 = T.Muted, Size = UDim2.new(0, 12, 0, 14), Position = UDim2.new(0, 0, 0, yPos) })
				local tr = F(pickerF, T.Border, UDim2.new(1, -16, 0, 8), UDim2.new(0, 14, 0, yPos + 3))
				corner(tr, 2)
				New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, gradStart), ColorSequenceKeypoint.new(1, gradEnd) }) }, tr)
				local th = F(tr, T.White, UDim2.new(0, 8, 0, 14), UDim2.new(getV(), -4, 0.5, -7))
				corner(th, 4)
				th.ZIndex = 36
				local d = false
				tr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true local p = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1) setV(p) tw(th, { Position = UDim2.new(p, -4, 0.5, -7) }, 0.03) applyHSV() end end)
				UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then local p = math.clamp((i.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1) setV(p) tw(th, { Position = UDim2.new(p, -4, 0.5, -7) }, 0.03) applyHSV() end end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
				return th
			end
			local hth = makeSlider(0, "H", Color3.fromHSV(0, 1, 1), Color3.fromHSV(0.999, 1, 1), function() return h_ end, function(v) h_ = v end)
			local htr = hth.Parent
			htr:FindFirstChildOfClass("UIGradient"):Destroy()
			New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)), ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)), ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)), ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)) }) }, htr)
			makeSlider(22, "S", Color3.new(1, 1, 1), Color3.new(0, 0, 0), function() return s_ end, function(v) s_ = v end)
			makeSlider(44, "V", Color3.new(0, 0, 0), Color3.new(1, 1, 1), function() return v_ end, function(v) v_ = v end)
			local prev = F(pickerF, color, UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 66))
			corner(prev, 4)
			stroke(prev, T.Border)
			prev.Name = "__preview"
			local hexLbl = New("TextBox", { BackgroundTransparency = 1, Text = string.format("%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)), TextColor3 = T.Text, TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 92), Name = "__hex" }, pickerF)
			swatch.MouseButton1Click:Connect(function()
				open = not open
				if open then
					local ab = swatch.AbsolutePosition
					local sz = swatch.AbsoluteSize
					pickerF.Position = UDim2.new(0, math.max(4, ab.X - 170), 0, ab.Y + sz.Y + 4)
					pickerF.Visible = true
				else
					pickerF.Visible = false
				end
			end)
			row.MouseEnter:Connect(function() tw(row, { BackgroundColor3 = T.Hover }) end)
			row.MouseLeave:Connect(function() tw(row, { BackgroundColor3 = T.Element }) end)
			function obj:Set(c)
				obj.Value = c
				swatch.BackgroundColor3 = c
				h_, s_, v_ = c:ToHSV()
				applyHSV()
			end
			if opts.Flag then self._lib.Flags[opts.Flag] = obj end
			return obj
		end
		function tab:AddLabel(text, color)
			local l = Lbl(self._page, { Text = text or "", TextSize = 11, TextColor3 = color or T.Muted, Size = UDim2.new(1, 0, 0, 16), TextWrapped = true })
			local obj = {}
			function obj:Set(t) l.Text = t end
			return obj
		end
		function tab:AddParagraph(t_, c_)
			local row = New("Frame", { BackgroundColor3 = T.Element, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, self._page)
			corner(row, 5)
			stroke(row, T.Border)
			pad(row, 8, 8, 10, 10)
			local ll = list(row, 3)
			local tl = Lbl(row, { Text = t_ or "", Font = Enum.Font.GothamBold, TextSize = 12, Size = UDim2.new(1, 0, 0, 16) })
			local cl = Lbl(row, { Text = c_ or "", TextSize = 11, TextColor3 = T.TextDim, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true })
			local obj = {}
			function obj:Set(t, c)
				tl.Text = t
				cl.Text = c
			end
			return obj
		end
		function tab:AddSeparator() Divider(self._page) end
		return tab
	end
	return win
end

function PercsUI:Init() end

function PercsUI:Destroy()
	for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do if v.Name:sub(1, 5) == "Percs" then v:Destroy() end end
	pcall(function() for _, v in ipairs(PL.PlayerGui:GetChildren()) do if v.Name:sub(1, 5) == "Percs" then v:Destroy() end end end)
end

return PercsUI
