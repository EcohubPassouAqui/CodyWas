--[[
    UILib - Biblioteca de Interface para Roblox
    Desenvolvido por: rip_sheldoohz
    Versão: 1.0
    
    Uso:
    local UILib = require(game.ServerScriptService.UILib)
    local window = UILib.Window.new("Meu Painel", "by codywas")
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local FONT = Enum.Font.BuilderSans
local FONT_BOLD = Enum.Font.BuilderSansBold

local Theme = {
    Panel = Color3.fromRGB(20, 20, 20),
    HoverFill = Color3.fromRGB(255, 255, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(105, 105, 115),
    TextHeader = Color3.fromRGB(130, 130, 140),
    TitleText = Color3.fromRGB(255, 255, 255),
    Line = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(255, 255, 255)
}

local ICONS = { assets = {} }
pcall(function()
    local result = loadstring(game:HttpGet("https://raw.githubusercontent.com/EcohubPassouAqui/rip_sheldoohz/refs/heads/main/src/Icons.lua"))()
    if type(result) == "table" then
        ICONS = result
    end
end)

-- // Anti-Cheat
local AntiCheat = {}
AntiCheat.enabled = true

function AntiCheat:Init()
    if setthreadidentity then
        pcall(function() setthreadidentity(8) end)
    end
    
    if getgc then
        pcall(function()
            local gc = getgc(true)
            for i = #gc, 1, -1 do
                if gc[i] == getfenv() then
                    table.remove(gc, i)
                end
            end
        end)
    end
    
    if hookfunction and getscripts then
        pcall(function()
            hookfunction(getscripts, function()
                return {}
            end)
        end)
    end
    
    if hookfunction and isexecutorclosure then
        pcall(function()
            hookfunction(isexecutorclosure, function(f)
                return false
            end)
        end)
    end
    
    if hookfunction and getloadedmodules then
        pcall(function()
            hookfunction(getloadedmodules, function()
                return {}
            end)
        end)
    end
    
    if hookfunction and getrunningscripts then
        pcall(function()
            hookfunction(getrunningscripts, function()
                return {}
            end)
        end)
    end
    
    if hookfunction and getnilinstances then
        pcall(function()
            hookfunction(getnilinstances, function()
                return {}
            end)
        end)
    end
    
    if getrawmetatable then
        pcall(function()
            local mt = getrawmetatable(game)
            if mt and setreadonly then
                setreadonly(mt, true)
            end
        end)
    end
    
    if hookfunction and filtergc then
        pcall(function()
            hookfunction(filtergc, function(filter)
                return {}
            end)
        end)
    end
    
    if hookfunction and getinstances then
        pcall(function()
            hookfunction(getinstances, function()
                return {}
            end)
        end)
    end
end

function AntiCheat:ProtectObject(obj)
    if not obj then return end
    pcall(function()
        if setreadonly then setreadonly(obj, true) end
        if sethiddenproperty then sethiddenproperty(obj, "Visible", true) end
    end)
end

-- // Elements Registry
local Elements = {}
Elements.List = {}

function Elements.Register(name, constructor)
    Elements.List[name] = constructor
end

-- // Checkbox
Elements.Register("Checkbox", function(section, options)
    local COLORS = {
        Active = Color3.fromRGB(255, 255, 255),
        Inactive = Color3.fromRGB(20, 20, 20),
        TextActive = Color3.fromRGB(255, 255, 255),
        TextInactive = Color3.fromRGB(105, 105, 115),
        TextDisabled = Color3.fromRGB(70, 70, 78),
        Line = Color3.fromRGB(32, 32, 32),
        Icon = Color3.fromRGB(20, 20, 20),
        DescriptionText = Color3.fromRGB(105, 105, 115),
    }

    local TITLE_TEXT_SIZE = 13
    local DESCRIPTION_TEXT_SIZE = 11
    local BOX_SIZE = 18
    local TITLE_HEIGHT = 16
    local TOP_PADDING = 8
    local BOTTOM_PADDING = 10
    local TITLE_ONLY_HEIGHT = 30
    local WORD_BREAK_LENGTH = 20

    local function warnf(format, ...)
        warn(("[UILib :: Checkbox] " .. format):format(...))
    end

    local function breakLongWords(text, maxRunLength)
        local result = {}
        for word in text:gmatch("%S+") do
            while #word > maxRunLength do
                table.insert(result, word:sub(1, maxRunLength))
                word = word:sub(maxRunLength + 1)
            end
            table.insert(result, word)
        end
        return table.concat(result, " ")
    end

    local title = options.title or options.Name or "Checkbox"
    local description = options.description or ""
    local default = options.default or options.Default or false
    local disabled = options.disabled or false
    local callback = options.callback or options.Callback or function() end

    local displayDescription = breakLongWords(description, WORD_BREAK_LENGTH)
    local hasDescription = description ~= ""

    local data = { state = default, disabled = disabled }

    local container = Instance.new("Frame")
    container.Name = title .. "_Checkbox"
    container.Size = UDim2.new(1, 0, 0, TITLE_ONLY_HEIGHT)
    container.BackgroundTransparency = 1
    container.Parent = section.frame

    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.AutoButtonColor = false
    clickArea.Selectable = false
    clickArea.Parent = container

    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -(BOX_SIZE + 12), 1, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = default and COLORS.TextActive or COLORS.TextInactive
    label.TextSize = TITLE_TEXT_SIZE
    label.Font = FONT or Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = textContainer

    local descLabel
    if hasDescription then
        descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.Position = UDim2.new(0, 0, 0, TITLE_HEIGHT)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = displayDescription
        descLabel.TextColor3 = COLORS.DescriptionText
        descLabel.TextSize = DESCRIPTION_TEXT_SIZE
        descLabel.Font = FONT or Enum.Font.SourceSans
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.LineHeight = 1.15
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.Parent = textContainer
    end

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.Size = UDim2.new(0, BOX_SIZE, 0, BOX_SIZE)
    box.Position = UDim2.new(1, 0, 0, 0)
    box.AnchorPoint = Vector2.new(1, 0)
    box.BackgroundColor3 = default and COLORS.Active or COLORS.Inactive
    box.BorderSizePixel = 0
    box.Parent = container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = default and COLORS.Active or COLORS.Line
    boxStroke.Thickness = 1.2
    boxStroke.Parent = box

    local checkIcon = Instance.new("ImageLabel")
    checkIcon.Name = "CheckIcon"
    checkIcon.Size = UDim2.new(0, 12, 0, 12)
    checkIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Image = (ICONS and ICONS.assets and ICONS.assets["lucide-check"]) or "rbxassetid://10709790644"
    checkIcon.ImageColor3 = COLORS.Icon
    checkIcon.ImageTransparency = default and 0 or 1
    checkIcon.Selectable = false
    checkIcon.Parent = box

    local function resizeContainer()
        if not hasDescription then return end
        local totalHeight = TOP_PADDING + TITLE_HEIGHT + descLabel.AbsoluteSize.Y + BOTTOM_PADDING
        container.Size = UDim2.new(1, 0, 0, math.max(totalHeight, TITLE_ONLY_HEIGHT))
    end

    local function updateVisuals(animate)
        local boxColor = data.state and COLORS.Active or COLORS.Inactive
        local strokeColor = data.state and COLORS.Active or COLORS.Line
        local checkTransparency = data.state and 0 or 1
        local textColor = data.state and COLORS.TextActive or COLORS.TextInactive

        if data.disabled then
            boxColor = COLORS.Inactive
            strokeColor = COLORS.Line
            textColor = COLORS.TextDisabled
        end

        if animate then
            local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(box, tweenInfo, { BackgroundColor3 = boxColor }):Play()
            TweenService:Create(boxStroke, tweenInfo, { Color = strokeColor }):Play()
            TweenService:Create(checkIcon, tweenInfo, { ImageTransparency = data.disabled and 1 or checkTransparency, ImageColor3 = COLORS.Icon }):Play()
            TweenService:Create(label, tweenInfo, { TextColor3 = textColor }):Play()
        else
            box.BackgroundColor3 = boxColor
            boxStroke.Color = strokeColor
            checkIcon.ImageTransparency = data.disabled and 1 or checkTransparency
            checkIcon.ImageColor3 = COLORS.Icon
            label.TextColor3 = textColor
        end

        clickArea.Active = not data.disabled
    end

    local function fireCallback(value)
        local ok, err = pcall(callback, value)
        if not ok then
            warnf("erro no callback do Checkbox '%s': %s", title, tostring(err))
        end
    end

    local function toggle()
        if data.disabled then return end
        data.state = not data.state
        updateVisuals(true)
        fireCallback(data.state)
    end

    clickArea.MouseButton1Click:Connect(toggle)

    clickArea.MouseEnter:Connect(function()
        if data.disabled then return end
        local hoverTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(boxStroke, hoverTween, { Color = COLORS.Active, Thickness = 1.4 }):Play()
        if not data.state then
            TweenService:Create(checkIcon, hoverTween, { ImageTransparency = 0.55, ImageColor3 = COLORS.Active }):Play()
        end
    end)

    clickArea.MouseLeave:Connect(function()
        if data.disabled then return end
        local hoverTween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local strokeColor = data.state and COLORS.Active or COLORS.Line
        TweenService:Create(boxStroke, hoverTween, { Color = strokeColor, Thickness = 1.2 }):Play()
        if not data.state then
            TweenService:Create(checkIcon, hoverTween, { ImageTransparency = 1, ImageColor3 = COLORS.Icon }):Play()
        end
    end)

    if hasDescription then
        descLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeContainer)
        resizeContainer()
    end

    updateVisuals(false)

    if default then
        fireCallback(default)
    end

    function data:Set(value)
        data.state = value
        updateVisuals(true)
        fireCallback(value)
    end

    function data:Get()
        return data.state
    end

    function data:Toggle()
        toggle()
    end

    function data:SetDisabled(value)
        data.disabled = value
        updateVisuals(true)
    end

    function data:SetTitle(newTitle)
        label.Text = newTitle
    end

    function data:SetDescription(newDescription)
        if not descLabel then
            warnf("Checkbox '%s' não possui descrição inicial; SetDescription ignorado.", title)
            return
        end
        descLabel.Text = breakLongWords(newDescription, WORD_BREAK_LENGTH)
        resizeContainer()
    end

    function data:Destroy()
        container:Destroy()
    end

    return data
end)

-- // Button
Elements.Register("Button", function(section, options)
    local COLORS = {
        Background = Color3.fromRGB(20, 20, 20),
        BackgroundHover = Color3.fromRGB(32, 32, 32),
        Border = Color3.fromRGB(40, 40, 40),
        BorderHover = Color3.fromRGB(70, 70, 80),
        TextActive = Color3.fromRGB(220, 220, 220),
        TextDisabled = Color3.fromRGB(70, 70, 78),
        DescriptionText = Color3.fromRGB(100, 100, 110),
    }

    local SIZES = {
        TitleText = 13,
        DescriptionText = 11,
        TitleHeight = 16,
        TopPadding = 8,
        BottomPadding = 10,
        MinHeight = 30,
        ArrowSize = 14,
        WordBreakLength = 20,
        BorderWidth = 1,
    }

    local function warnf(format, ...)
        warn(("[UILib :: Button] " .. format):format(...))
    end

    local function breakLongWords(text, maxRunLength)
        local result = {}
        for word in text:gmatch("%S+") do
            while #word > maxRunLength do
                table.insert(result, word:sub(1, maxRunLength))
                word = word:sub(maxRunLength + 1)
            end
            table.insert(result, word)
        end
        return table.concat(result, " ")
    end

    local function createFrame(name, parent, size, position, bgColor, transparent)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = size or UDim2.new(1, 0, 0, SIZES.MinHeight)
        frame.Position = position or UDim2.new(0, 0, 0, 0)
        frame.BackgroundColor3 = bgColor or COLORS.Background
        frame.BackgroundTransparency = transparent and 1 or 0
        frame.BorderSizePixel = 0
        frame.Parent = parent
        return frame
    end

    local function createLabel(name, parent, text, size, position, textSize, color, wrapped)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = size or UDim2.new(1, 0, 0, SIZES.TitleHeight)
        label.Position = position or UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color or COLORS.TextActive
        label.TextSize = textSize or SIZES.TitleText
        label.Font = FONT or Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = wrapped and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
        label.TextWrapped = wrapped or false
        label.Parent = parent
        return label
    end

    local title = options.title or options.Name or "Button"
    local description = options.description or ""
    local disabled = options.disabled or false
    local callback = options.callback or options.Callback or function() end

    local displayDescription = breakLongWords(description, SIZES.WordBreakLength)
    local hasDescription = description ~= ""

    local data = { disabled = disabled }

    local container = createFrame("Button_" .. title, section.frame, UDim2.new(1, 0, 0, SIZES.MinHeight), nil, COLORS.Background)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = container

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.Border
    stroke.Thickness = SIZES.BorderWidth
    stroke.Transparency = 0
    stroke.Parent = container

    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.AutoButtonColor = false
    clickArea.Selectable = false
    clickArea.Parent = container

    local textContainer = createFrame("TextContainer", container, UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), nil, true)

    local label = createLabel("Title", textContainer, title, nil, nil, SIZES.TitleText, disabled and COLORS.TextDisabled or COLORS.TextActive)

    if hasDescription then
        label.Size = UDim2.new(1, 0, 0, SIZES.TitleHeight)
        label.Position = UDim2.new(0, 0, 0, SIZES.TopPadding)
        label.TextYAlignment = Enum.TextYAlignment.Top
    else
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
    end

    local descLabel
    if hasDescription then
        descLabel = createLabel("Description", textContainer, displayDescription, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, SIZES.TopPadding + SIZES.TitleHeight), SIZES.DescriptionText, COLORS.DescriptionText, true)
        descLabel.LineHeight = 1.15
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
    end

    local function resizeContainer()
        if not hasDescription then return end
        local totalHeight = SIZES.TopPadding + SIZES.TitleHeight + descLabel.AbsoluteSize.Y + SIZES.BottomPadding
        container.Size = UDim2.new(1, 0, 0, math.max(totalHeight, SIZES.MinHeight))
    end

    local function updateVisuals()
        local textColor = data.disabled and COLORS.TextDisabled or COLORS.TextActive
        label.TextColor3 = textColor
        clickArea.Active = not data.disabled
    end

    local function fireCallback()
        local ok, err = pcall(callback)
        if not ok then
            warnf("Erro no callback do Button '%s': %s", title, tostring(err))
        end
    end

    local function press()
        if data.disabled then return end
        fireCallback()
    end

    clickArea.MouseButton1Click:Connect(press)

    clickArea.MouseEnter:Connect(function()
        if data.disabled then return end
        container.BackgroundColor3 = COLORS.BackgroundHover
        stroke.Color = COLORS.BorderHover
    end)

    clickArea.MouseLeave:Connect(function()
        if data.disabled then return end
        container.BackgroundColor3 = COLORS.Background
        stroke.Color = COLORS.Border
    end)

    if hasDescription then
        descLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeContainer)
        resizeContainer()
    end

    updateVisuals()

    function data:SetDisabled(value)
        data.disabled = value
        updateVisuals()
    end

    function data:SetTitle(newTitle)
        label.Text = newTitle
    end

    function data:SetDescription(newDescription)
        if not descLabel then
            warnf("Button '%s' não possui descrição inicial; SetDescription ignorado.", title)
            return
        end
        descLabel.Text = breakLongWords(newDescription, SIZES.WordBreakLength)
        resizeContainer()
    end

    function data:Fire()
        press()
    end

    function data:Destroy()
        container:Destroy()
    end

    return data
end)

-- // Slider
Elements.Register("Slider", function(section, options)
    local COLORS = {
        Active = Color3.fromRGB(255, 255, 255),
        Inactive = Color3.fromRGB(20, 20, 20),
        TextActive = Color3.fromRGB(255, 255, 255),
        TextInactive = Color3.fromRGB(105, 105, 115),
        TextDisabled = Color3.fromRGB(70, 70, 78),
        Line = Color3.fromRGB(32, 32, 32),
        Track = Color3.fromRGB(30, 30, 30),
        Fill = Color3.fromRGB(255, 255, 255),
        ValueBadgeBackground = Color3.fromRGB(20, 20, 20),
        ValueText = Color3.fromRGB(255, 255, 255),
        DescriptionText = Color3.fromRGB(105, 105, 115),
    }

    local TITLE_TEXT_SIZE = 13
    local DESCRIPTION_TEXT_SIZE = 11
    local TITLE_HEIGHT = 16
    local TOP_PADDING = 8
    local BOTTOM_PADDING = 10
    local TRACK_HEIGHT = 14
    local TITLE_ONLY_HEIGHT = 30
    local WORD_BREAK_LENGTH = 20

    local function warnf(format, ...)
        warn(("[UILib :: Slider] " .. format):format(...))
    end

    local function breakLongWords(text, maxRunLength)
        local result = {}
        for word in text:gmatch("%S+") do
            while #word > maxRunLength do
                table.insert(result, word:sub(1, maxRunLength))
                word = word:sub(maxRunLength + 1)
            end
            table.insert(result, word)
        end
        return table.concat(result, " ")
    end

    local function round(value, rounding)
        local multiplier = 10 ^ rounding
        return math.floor(value * multiplier + 0.5) / multiplier
    end

    local title = options.title or options.Name or "Slider"
    local description = options.description or ""
    local min = options.min or options.Min or 0
    local max = options.max or options.Max or 100
    local rounding = options.rounding or 0
    local suffix = options.suffix or options.ValueName or ""
    local default = options.default or options.Default or min
    local disabled = options.disabled or false
    local callback = options.callback or options.Callback or function() end

    local displayDescription = breakLongWords(description, WORD_BREAK_LENGTH)
    local hasDescription = description ~= ""

    default = round(math.clamp(default, min, max), rounding)

    local data = { value = default, disabled = disabled }

    local container = Instance.new("Frame")
    container.Name = title .. "_Slider"
    container.Size = UDim2.new(1, 0, 0, TITLE_ONLY_HEIGHT + TRACK_HEIGHT + 6)
    container.BackgroundTransparency = 1
    container.Parent = section.frame

    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -60, 0, TITLE_HEIGHT)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = COLORS.TextActive
    label.TextSize = TITLE_TEXT_SIZE
    label.Font = FONT or Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = textContainer

    local descLabel
    if hasDescription then
        descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.Position = UDim2.new(0, 0, 0, TITLE_HEIGHT)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = displayDescription
        descLabel.TextColor3 = COLORS.DescriptionText
        descLabel.TextSize = DESCRIPTION_TEXT_SIZE
        descLabel.Font = FONT or Enum.Font.SourceSans
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.LineHeight = 1.15
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.Parent = container
    end

    local valueBadge = Instance.new("TextLabel")
    valueBadge.Name = "ValueBadge"
    valueBadge.Size = UDim2.new(0, 50, 0, 20)
    valueBadge.Position = UDim2.new(1, 0, 0, 0)
    valueBadge.AnchorPoint = Vector2.new(1, 0)
    valueBadge.BackgroundColor3 = COLORS.ValueBadgeBackground
    valueBadge.BorderSizePixel = 0
    valueBadge.Text = tostring(default) .. suffix
    valueBadge.TextColor3 = COLORS.ValueText
    valueBadge.TextSize = 11
    valueBadge.Font = FONT or Enum.Font.SourceSans
    valueBadge.Parent = container

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 5)
    badgeCorner.Parent = valueBadge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Color = COLORS.Line
    badgeStroke.Thickness = 1
    badgeStroke.Parent = valueBadge

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, TRACK_HEIGHT)
    track.Position = UDim2.new(0, 0, 1, -TRACK_HEIGHT)
    track.BackgroundColor3 = COLORS.Track
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 6)
    trackCorner.Parent = track

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = COLORS.Line
    trackStroke.Thickness = 1.2
    trackStroke.Parent = track

    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.AutoButtonColor = false
    clickArea.Selectable = false
    clickArea.ZIndex = 3
    clickArea.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Fill
    fill.BorderSizePixel = 0
    fill.ZIndex = 1
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local function resizeContainer()
        local descHeight = hasDescription and descLabel.AbsoluteSize.Y or 0
        local totalHeight = TOP_PADDING + TITLE_HEIGHT + descHeight + 6 + TRACK_HEIGHT + BOTTOM_PADDING
        container.Size = UDim2.new(1, 0, 0, math.max(totalHeight, TITLE_ONLY_HEIGHT + TRACK_HEIGHT))

        if hasDescription then
            track.Position = UDim2.new(0, 0, 0, TOP_PADDING + TITLE_HEIGHT + descHeight + 6)
        end
    end

    local function updateVisuals(animate)
        local alpha = (data.value - min) / (max - min)
        alpha = math.clamp(alpha, 0, 1)

        local displayText = tostring(data.value) .. suffix
        local textColor = data.disabled and COLORS.TextDisabled or COLORS.TextActive
        local strokeColor = COLORS.Line
        local fillColor = data.disabled and COLORS.TextDisabled or COLORS.Fill

        valueBadge.Text = displayText
        label.TextColor3 = textColor

        if animate then
            local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(fill, tweenInfo, { Size = UDim2.new(alpha, 0, 1, 0), BackgroundColor3 = fillColor }):Play()
            TweenService:Create(trackStroke, tweenInfo, { Color = strokeColor }):Play()
        else
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            fill.BackgroundColor3 = fillColor
            trackStroke.Color = strokeColor
        end

        clickArea.Active = not data.disabled
    end

    local function fireCallback(value)
        local ok, err = pcall(callback, value)
        if not ok then
            warnf("erro no callback do Slider '%s': %s", title, tostring(err))
        end
    end

    local function setValueFromAlpha(alpha, animate)
        alpha = math.clamp(alpha, 0, 1)
        local newValue = round(min + (max - min) * alpha, rounding)

        if newValue == data.value then return end

        data.value = newValue
        updateVisuals(animate)
        fireCallback(data.value)
    end

    local function getAlphaFromX(xPos)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        if absSize <= 0 then return 0 end
        return (xPos - absPos) / absSize
    end

    local dragging = false

    clickArea.InputBegan:Connect(function(input)
        if data.disabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValueFromAlpha(getAlphaFromX(input.Position.X), false)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            setValueFromAlpha(getAlphaFromX(input.Position.X), false)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if hasDescription then
        descLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeContainer)
    end

    resizeContainer()
    updateVisuals(false)
    fireCallback(data.value)

    function data:Set(value)
        value = round(math.clamp(value, min, max), rounding)
        data.value = value
        updateVisuals(true)
        fireCallback(value)
    end

    function data:Get()
        return data.value
    end

    function data:SetDisabled(value)
        data.disabled = value
        updateVisuals(true)
    end

    function data:SetTitle(newTitle)
        label.Text = newTitle
    end

    function data:SetDescription(newDescription)
        if not descLabel then
            warnf("Slider '%s' não possui descrição inicial; SetDescription ignorado.", title)
            return
        end

        descLabel.Text = breakLongWords(newDescription, WORD_BREAK_LENGTH)
        resizeContainer()
    end

    function data:Destroy()
        container:Destroy()
    end

    return data
end)

-- // Dropdown
Elements.Register("Dropdown", function(section, options)
    local COLORS = {
        Active = Color3.fromRGB(255, 255, 255),
        Inactive = Color3.fromRGB(20, 20, 20),
        TextActive = Color3.fromRGB(255, 255, 255),
        TextInactive = Color3.fromRGB(105, 105, 115),
        TextDisabled = Color3.fromRGB(70, 70, 78),
        Line = Color3.fromRGB(32, 32, 32),
        Field = Color3.fromRGB(24, 24, 24),
        ListBackground = Color3.fromRGB(18, 18, 18),
        SearchBackground = Color3.fromRGB(24, 24, 24),
        OptionHover = Color3.fromRGB(32, 32, 32),
        OptionSelectedBackground = Color3.fromRGB(255, 255, 255),
        OptionSelectedText = Color3.fromRGB(20, 20, 20),
        DescriptionText = Color3.fromRGB(105, 105, 115),
        Icon = Color3.fromRGB(105, 105, 115),
    }

    local TITLE_TEXT_SIZE = 12
    local DESCRIPTION_TEXT_SIZE = 10
    local OPTION_TEXT_SIZE = 11
    local ROW_HEIGHT = 40
    local FIELD_WIDTH = 150
    local FIELD_HEIGHT = 24
    local OPTION_HEIGHT = 22
    local SEARCH_HEIGHT = 22
    local MAX_LIST_HEIGHT = 150
    local WORD_BREAK_LENGTH = 20
    local OVERLAY_ZINDEX = 1000

    local function warnf(format, ...)
        warn(("[UILib :: Dropdown] " .. format):format(...))
    end

    local function breakLongWords(text, maxRunLength)
        local result = {}
        for word in text:gmatch("%S+") do
            while #word > maxRunLength do
                table.insert(result, word:sub(1, maxRunLength))
                word = word:sub(maxRunLength + 1)
            end
            table.insert(result, word)
        end
        return table.concat(result, " ")
    end

    local function safeIcon(name, fallback)
        local ok, result = pcall(function()
            return ICONS.assets[name]
        end)
        if ok and result then
            return result
        end
        return fallback
    end

    local screenGui = section.frame:FindFirstAncestorWhichIsA("ScreenGui")
    if not screenGui then
        warnf("nenhum ScreenGui encontrado como ancestral; overlay será filho do próprio container.")
    end

    local title = options.title or options.Name or "Dropdown"
    local description = options.description or ""
    local values = options.values or options.Options or {}
    local multi = options.multi or false
    local disabled = options.disabled or false
    local searchable = options.searchable
    if searchable == nil then searchable = true end
    local callback = options.callback or options.Callback or function() end

    local displayDescription = breakLongWords(description, WORD_BREAK_LENGTH)
    local hasDescription = description ~= ""

    local data = { disabled = disabled, opened = false }

    if multi then
        data.value = {}
        if type(options.default) == "table" then
            for _, v in ipairs(options.default) do
                if table.find(values, v) then
                    data.value[v] = true
                end
            end
        end
    else
        data.value = nil
        if type(options.default) == "string" and table.find(values, options.default) then
            data.value = options.default
        end
    end

    local container = Instance.new("Frame")
    container.Name = title .. "_Dropdown"
    container.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = section.frame

    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -(FIELD_WIDTH + 16), 1, 0)
    textContainer.Position = UDim2.new(0, 0, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Position = UDim2.new(0, 0, 0, hasDescription and 2 or 0)
    label.AnchorPoint = Vector2.new(0, hasDescription and 0 or 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = COLORS.TextActive
    label.TextSize = TITLE_TEXT_SIZE
    label.Font = FONT or Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = textContainer

    if not hasDescription then
        label.Position = UDim2.new(0, 0, 0.5, 0)
        label.AnchorPoint = Vector2.new(0, 0.5)
    end

    local descLabel
    if hasDescription then
        descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.Position = UDim2.new(0, 0, 0, 18)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = displayDescription
        descLabel.TextColor3 = COLORS.DescriptionText
        descLabel.TextSize = DESCRIPTION_TEXT_SIZE
        descLabel.Font = FONT or Enum.Font.SourceSans
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextWrapped = true
        descLabel.LineHeight = 1.1
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.Parent = textContainer
    end

    local field = Instance.new("TextButton")
    field.Name = "Field"
    field.Size = UDim2.new(0, FIELD_WIDTH, 0, FIELD_HEIGHT)
    field.Position = UDim2.new(1, 0, 0.5, 0)
    field.AnchorPoint = Vector2.new(1, 0.5)
    field.BackgroundColor3 = COLORS.Field
    field.BorderSizePixel = 0
    field.Text = ""
    field.AutoButtonColor = false
    field.Selectable = false
    field.ZIndex = 10
    field.Parent = container

    local fieldCorner = Instance.new("UICorner")
    fieldCorner.CornerRadius = UDim.new(0, 5)
    fieldCorner.Parent = field

    local fieldStroke = Instance.new("UIStroke")
    fieldStroke.Color = COLORS.Line
    fieldStroke.Thickness = 1
    fieldStroke.Parent = field

    local fieldText = Instance.new("TextLabel")
    fieldText.Name = "FieldText"
    fieldText.Size = UDim2.new(1, -26, 1, 0)
    fieldText.Position = UDim2.new(0, 8, 0, 0)
    fieldText.BackgroundTransparency = 1
    fieldText.Text = "Selecione..."
    fieldText.TextColor3 = COLORS.TextInactive
    fieldText.TextSize = OPTION_TEXT_SIZE
    fieldText.Font = FONT or Enum.Font.SourceSans
    fieldText.TextXAlignment = Enum.TextXAlignment.Left
    fieldText.TextTruncate = Enum.TextTruncate.AtEnd
    fieldText.ZIndex = 10
    fieldText.Parent = field

    local fieldIcon = Instance.new("ImageLabel")
    fieldIcon.Name = "FieldIcon"
    fieldIcon.Size = UDim2.new(0, 12, 0, 12)
    fieldIcon.Position = UDim2.new(1, -8, 0.5, 0)
    fieldIcon.AnchorPoint = Vector2.new(1, 0.5)
    fieldIcon.BackgroundTransparency = 1
    fieldIcon.Image = safeIcon("lucide-chevron-down", "rbxassetid://10709790948")
    fieldIcon.ImageColor3 = COLORS.Icon
    fieldIcon.ZIndex = 10
    fieldIcon.Parent = field

    local overlayCanvas = Instance.new("Frame")
    overlayCanvas.Name = title .. "_DropdownOverlay"
    overlayCanvas.BackgroundTransparency = 1
    overlayCanvas.Size = UDim2.fromOffset(0, 0)
    overlayCanvas.Visible = false
    overlayCanvas.ZIndex = OVERLAY_ZINDEX
    overlayCanvas.Parent = screenGui or container

    local listBackground = Instance.new("Frame")
    listBackground.Name = "ListBackground"
    listBackground.Size = UDim2.new(1, 0, 1, 0)
    listBackground.BackgroundColor3 = COLORS.ListBackground
    listBackground.BorderSizePixel = 0
    listBackground.ClipsDescendants = true
    listBackground.ZIndex = OVERLAY_ZINDEX
    listBackground.Parent = overlayCanvas

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = listBackground

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = COLORS.Line
    listStroke.Thickness = 1
    listStroke.Parent = listBackground

    local searchBox
    if searchable then
        local searchHolder = Instance.new("Frame")
        searchHolder.Name = "SearchHolder"
        searchHolder.Size = UDim2.new(1, -6, 0, SEARCH_HEIGHT)
        searchHolder.Position = UDim2.new(0, 3, 0, 3)
        searchHolder.BackgroundColor3 = COLORS.SearchBackground
        searchHolder.BorderSizePixel = 0
        searchHolder.ZIndex = OVERLAY_ZINDEX + 1
        searchHolder.Parent = listBackground

        local searchCorner = Instance.new("UICorner")
        searchCorner.CornerRadius = UDim.new(0, 4)
        searchCorner.Parent = searchHolder

        local searchStroke = Instance.new("UIStroke")
        searchStroke.Color = COLORS.Line
        searchStroke.Thickness = 1
        searchStroke.Parent = searchHolder

        searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Size = UDim2.new(1, -12, 1, 0)
        searchBox.Position = UDim2.new(0, 6, 0, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.Text = ""
        searchBox.PlaceholderText = "Pesquisar..."
        searchBox.PlaceholderColor3 = COLORS.TextInactive
        searchBox.TextColor3 = COLORS.TextActive
        searchBox.TextSize = OPTION_TEXT_SIZE
        searchBox.Font = FONT or Enum.Font.SourceSans
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ClearTextOnFocus = false
        searchBox.ZIndex = OVERLAY_ZINDEX + 1
        searchBox.Parent = searchHolder
    end

    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Name = "ListScroll"
    listScroll.Size = searchable
        and UDim2.new(1, -6, 1, -(SEARCH_HEIGHT + 9))
        or UDim2.new(1, -6, 1, -6)
    listScroll.Position = searchable
        and UDim2.new(0, 3, 0, SEARCH_HEIGHT + 6)
        or UDim2.new(0, 3, 0, 3)
    listScroll.BackgroundTransparency = 1
    listScroll.BorderSizePixel = 0
    listScroll.ScrollBarThickness = 3
    listScroll.ScrollBarImageColor3 = COLORS.Active
    listScroll.ScrollBarImageTransparency = 0.7
    listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    listScroll.ZIndex = OVERLAY_ZINDEX
    listScroll.Parent = listBackground

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listScroll

    local function fireCallback()
        local ok, err = pcall(callback, data.value)
        if not ok then
            warnf("erro no callback do Dropdown '%s': %s", title, tostring(err))
        end
    end

    local function getDisplayText()
        if multi then
            local selected = {}
            for _, value in ipairs(values) do
                if data.value[value] then
                    table.insert(selected, value)
                end
            end
            if #selected == 0 then return "Selecione..." end
            return table.concat(selected, ", ")
        else
            return data.value or "Selecione..."
        end
    end

    local function updateFieldVisuals(animate)
        local hasSelection = multi and (next(data.value) ~= nil) or (data.value ~= nil)
        local textColor = COLORS.TextInactive
        if data.disabled then
            textColor = COLORS.TextDisabled
        elseif hasSelection then
            textColor = COLORS.TextActive
        end

        fieldText.Text = getDisplayText()

        if animate then
            local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(fieldText, tweenInfo, { TextColor3 = textColor }):Play()
        else
            fieldText.TextColor3 = textColor
        end

        field.Active = not data.disabled
    end

    local optionRows = {}

    local function updateOptionVisual(row, value)
        local selected = multi and (data.value[value] == true) or (data.value == value)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(row.button, tweenInfo, {
            BackgroundColor3 = selected and COLORS.OptionSelectedBackground or COLORS.ListBackground,
        }):Play()
        TweenService:Create(row.label, tweenInfo, {
            TextColor3 = selected and COLORS.OptionSelectedText or COLORS.TextInactive,
        }):Play()
    end

    local closeDropdown

    local function selectValue(value)
        if multi then
            data.value[value] = not data.value[value] or nil
            for _, row in ipairs(optionRows) do
                updateOptionVisual(row, row.value)
            end
        else
            data.value = value
            for _, row in ipairs(optionRows) do
                updateOptionVisual(row, row.value)
            end
        end

        updateFieldVisuals(true)
        fireCallback()

        if not multi then
            closeDropdown()
        end
    end

    local function getTargetListHeight()
        local searchExtra = searchable and (SEARCH_HEIGHT + 6) or 0
        return math.min(listLayout.AbsoluteContentSize.Y + 6 + searchExtra, MAX_LIST_HEIGHT)
    end

    local function filterOptions(query)
        query = (query or ""):lower()
        for _, row in ipairs(optionRows) do
            local matches = query == "" or tostring(row.value):lower():find(query, 1, true) ~= nil
            row.button.Visible = matches
        end
        listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
    end

    local function buildOptions()
        for _, child in ipairs(listScroll:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end
        optionRows = {}

        for i, value in ipairs(values) do
            local optButton = Instance.new("TextButton")
            optButton.Name = "Option_" .. tostring(i)
            optButton.Size = UDim2.new(1, 0, 0, OPTION_HEIGHT)
            optButton.BackgroundColor3 = COLORS.ListBackground
            optButton.BorderSizePixel = 0
            optButton.Text = ""
            optButton.AutoButtonColor = false
            optButton.Selectable = false
            optButton.ZIndex = OVERLAY_ZINDEX + 1
            optButton.LayoutOrder = i
            optButton.Parent = listScroll

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 4)
            optCorner.Parent = optButton

            local optLabel = Instance.new("TextLabel")
            optLabel.Name = "OptionLabel"
            optLabel.Size = UDim2.new(1, -12, 1, 0)
            optLabel.Position = UDim2.new(0, 6, 0, 0)
            optLabel.BackgroundTransparency = 1
            optLabel.Text = tostring(value)
            optLabel.TextColor3 = COLORS.TextInactive
            optLabel.TextSize = OPTION_TEXT_SIZE
            optLabel.Font = FONT or Enum.Font.SourceSans
            optLabel.TextXAlignment = Enum.TextXAlignment.Left
            optLabel.TextTruncate = Enum.TextTruncate.AtEnd
            optLabel.ZIndex = OVERLAY_ZINDEX + 1
            optLabel.Parent = optButton

            local row = { button = optButton, label = optLabel, value = value }
            table.insert(optionRows, row)

            optButton.MouseButton1Click:Connect(function()
                selectValue(value)
            end)

            optButton.MouseEnter:Connect(function()
                local selected = multi and (data.value[value] == true) or (not multi and data.value == value)
                if not selected then
                    TweenService:Create(optButton, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.OptionHover }):Play()
                end
            end)

            optButton.MouseLeave:Connect(function()
                local selected = multi and (data.value[value] == true) or (not multi and data.value == value)
                if not selected then
                    TweenService:Create(optButton, TweenInfo.new(0.1), { BackgroundColor3 = COLORS.ListBackground }):Play()
                end
            end)

            updateOptionVisual(row, value)
        end

        listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
    end

    local function repositionOverlay()
        if not data.opened then return end
        local camera = workspace.CurrentCamera
        local fieldPos = field.AbsolutePosition
        local fieldSize = field.AbsoluteSize
        local listHeight = getTargetListHeight()

        local spaceBelow = (camera and camera.ViewportSize.Y or 600) - (fieldPos.Y + fieldSize.Y)
        local openUpward = spaceBelow < listHeight + 8

        local yPos = openUpward and (fieldPos.Y - 4 - listHeight) or (fieldPos.Y + fieldSize.Y + 4)
        overlayCanvas.Position = UDim2.fromOffset(fieldPos.X, yPos)
        overlayCanvas.Size = UDim2.fromOffset(fieldSize.X, listHeight)
    end

    local function openDropdown()
        if data.disabled or data.opened or #values == 0 then return end
        data.opened = true
        data.openedAt = os.clock()

        if searchBox then
            searchBox.Text = ""
            filterOptions("")
        end

        task.defer(function()
            if not data.opened then return end
            local camera = workspace.CurrentCamera
            local targetHeight = getTargetListHeight()
            local fieldPos = field.AbsolutePosition
            local fieldSize = field.AbsoluteSize
            local spaceBelow = (camera and camera.ViewportSize.Y or 600) - (fieldPos.Y + fieldSize.Y)
            local openUpward = spaceBelow < targetHeight + 8

            local startY = openUpward and (fieldPos.Y - 4) or (fieldPos.Y + fieldSize.Y + 4)
            local endY = openUpward and (fieldPos.Y - 4 - targetHeight) or (fieldPos.Y + fieldSize.Y + 4)

            overlayCanvas.Visible = true
            overlayCanvas.Size = UDim2.fromOffset(fieldSize.X, 0)
            overlayCanvas.Position = UDim2.fromOffset(fieldPos.X, startY)

            TweenService:Create(overlayCanvas, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(fieldSize.X, targetHeight),
                Position = UDim2.fromOffset(fieldPos.X, endY),
            }):Play()

            TweenService:Create(fieldIcon, TweenInfo.new(0.15), { Rotation = 180 }):Play()

            if searchBox then
                task.defer(function()
                    if data.opened then
                        searchBox:CaptureFocus()
                    end
                end)
            end
        end)
    end

    closeDropdown = function()
        if not data.opened then return end
        data.opened = false

        local fieldSize = field.AbsoluteSize

        if searchBox then
            searchBox:ReleaseFocus()
        end

        local tween = TweenService:Create(overlayCanvas, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(fieldSize.X, 0),
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not data.opened then
                overlayCanvas.Visible = false
            end
        end)

        TweenService:Create(fieldIcon, TweenInfo.new(0.12), { Rotation = 0 }):Play()
    end

    local function toggleDropdown()
        if data.opened then
            closeDropdown()
        else
            openDropdown()
        end
    end

    field.MouseButton1Click:Connect(toggleDropdown)
    field:GetPropertyChangedSignal("AbsolutePosition"):Connect(repositionOverlay)
    field:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionOverlay)

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            filterOptions(searchBox.Text)
        end)
    end

    UserInputService.InputEnded:Connect(function(input)
        if not data.opened then return end
        if data.openedAt and (os.clock() - data.openedAt) < 0.15 then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mousePos = UserInputService:GetMouseLocation()
            local fieldPos = field.AbsolutePosition
            local fieldSize = field.AbsoluteSize
            local listPos = overlayCanvas.AbsolutePosition
            local listSize = overlayCanvas.AbsoluteSize

            local insideList = mousePos.X >= listPos.X - 2 and mousePos.X <= listPos.X + listSize.X + 2
                and mousePos.Y >= listPos.Y - 2 and mousePos.Y <= listPos.Y + listSize.Y + 2
            local insideField = mousePos.X >= fieldPos.X and mousePos.X <= fieldPos.X + fieldSize.X
                and mousePos.Y >= fieldPos.Y and mousePos.Y <= fieldPos.Y + fieldSize.Y

            if not insideList and not insideField then
                closeDropdown()
            end
        end
    end)

    buildOptions()
    updateFieldVisuals(false)

    if not multi and data.value ~= nil then
        fireCallback()
    elseif multi and next(data.value) then
        fireCallback()
    end

    function data:Set(value)
        if multi then
            local newState = {}
            if type(value) == "table" then
                for _, v in ipairs(value) do
                    if table.find(values, v) then
                        newState[v] = true
                    end
                end
            end
            data.value = newState
        else
            if value == nil or table.find(values, value) then
                data.value = value
            else
                warnf("Dropdown '%s': valor '%s' não existe na lista de valores.", title, tostring(value))
                return
            end
        end

        for _, row in ipairs(optionRows) do
            updateOptionVisual(row, row.value)
        end
        updateFieldVisuals(true)
        fireCallback()
    end

    function data:Get()
        return data.value
    end

    function data:SetValues(newValues)
        values = newValues or {}
        if multi then
            local filtered = {}
            for value in pairs(data.value) do
                if table.find(values, value) then
                    filtered[value] = true
                end
            end
            data.value = filtered
        else
            if data.value and not table.find(values, data.value) then
                data.value = nil
            end
        end
        buildOptions()
        updateFieldVisuals(true)
    end

    function data:SetDisabled(value)
        data.disabled = value
        if value then
            closeDropdown()
        end
        updateFieldVisuals(true)
    end

    function data:SetTitle(newTitle)
        title = newTitle
        label.Text = newTitle
        container.Name = title .. "_Dropdown"
        overlayCanvas.Name = title .. "_DropdownOverlay"
    end

    function data:SetDescription(newDescription)
        description = newDescription
        displayDescription = breakLongWords(newDescription, WORD_BREAK_LENGTH)
        hasDescription = description ~= ""

        if not hasDescription then
            if descLabel then
                descLabel:Destroy()
                descLabel = nil
            end
            label.Position = UDim2.new(0, 0, 0.5, 0)
            label.AnchorPoint = Vector2.new(0, 0.5)
        else
            if not descLabel then
                descLabel = Instance.new("TextLabel")
                descLabel.Name = "Description"
                descLabel.Size = UDim2.new(1, 0, 0, 0)
                descLabel.Position = UDim2.new(0, 0, 0, 18)
                descLabel.BackgroundTransparency = 1
                descLabel.TextColor3 = COLORS.DescriptionText
                descLabel.TextSize = DESCRIPTION_TEXT_SIZE
                descLabel.Font = FONT or Enum.Font.SourceSans
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextYAlignment = Enum.TextYAlignment.Top
                descLabel.TextWrapped = true
                descLabel.LineHeight = 1.1
                descLabel.AutomaticSize = Enum.AutomaticSize.Y
                descLabel.Parent = textContainer
            end
            descLabel.Text = displayDescription
            label.Position = UDim2.new(0, 0, 0, 2)
            label.AnchorPoint = Vector2.new(0, 0)
        end
    end

    function data:Close()
        closeDropdown()
    end

    function data:Open()
        openDropdown()
    end

    function data:Destroy()
        overlayCanvas:Destroy()
        container:Destroy()
    end

    return data
end)

-- // ColorPicker
Elements.Register("ColorPicker", function(section, options)
    local COLORS = {
        TextActive = Color3.fromRGB(255, 255, 255),
        TextInactive = Color3.fromRGB(105, 105, 115),
        Line = Color3.fromRGB(32, 32, 32),
        Field = Color3.fromRGB(24, 24, 24),
        MenuBackground = Color3.fromRGB(18, 18, 18),
        DescriptionText = Color3.fromRGB(105, 105, 115),
    }

    local function rgbToHex(color)
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        return string.format("%02X%02X%02X", r, g, b)
    end

    local function getContrastColor(color)
        local luminance = (0.299 * color.R) + (0.587 * color.G) + (0.114 * color.B)
        return luminance > 0.55 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
    end

    local title = options.title or options.Name or "Color"
    local defaultColor = options.default or options.Default or Color3.fromRGB(68, 120, 255)
    local disabled = options.disabled or false
    local callback = options.callback or options.Callback or function() end

    local data = { disabled = disabled, opened = false, value = defaultColor }
    local hue, sat, vib = Color3.toHSV(data.value)

    local container = Instance.new("Frame")
    container.Name = title .. "_ColorPicker"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = section.frame

    local label = Instance.new("TextLabel")
    label.Name = "Title"
    label.Size = UDim2.new(0.5, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = COLORS.TextActive
    label.TextSize = 12
    label.Font = FONT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local field = Instance.new("TextButton")
    field.Name = "Field"
    field.Size = UDim2.new(0, 100, 0, 24)
    field.Position = UDim2.new(1, -100, 0.5, -12)
    field.BackgroundColor3 = data.value
    field.BorderSizePixel = 0
    field.Text = ""
    field.AutoButtonColor = false
    field.ZIndex = 10
    field.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = field

    local hex = Instance.new("TextLabel")
    hex.Name = "HexLabel"
    hex.Size = UDim2.new(1, 0, 1, 0)
    hex.BackgroundTransparency = 1
    hex.Text = rgbToHex(data.value)
    hex.TextColor3 = getContrastColor(data.value)
    hex.TextSize = 10
    hex.Font = FONT
    hex.ZIndex = 11
    hex.Parent = field

    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(0.5, 0, 0, 150)
    overlay.Position = UDim2.new(0, 0, 1, 5)
    overlay.BackgroundColor3 = COLORS.MenuBackground
    overlay.BorderSizePixel = 0
    overlay.ClipsDescendants = true
    overlay.Visible = false
    overlay.ZIndex = 1000
    overlay.Parent = container

    local overlayCorner = Instance.new("UICorner")
    overlayCorner.CornerRadius = UDim.new(0, 6)
    overlayCorner.Parent = overlay

    local overlayStroke = Instance.new("UIStroke")
    overlayStroke.Color = COLORS.Line
    overlayStroke.Thickness = 1
    overlayStroke.Parent = overlay

    local satMap = Instance.new("ImageLabel")
    satMap.Name = "SaturationMap"
    satMap.Size = UDim2.new(1, -10, 0, 100)
    satMap.Position = UDim2.new(0, 5, 0, 5)
    satMap.Image = "rbxassetid://4155801252"
    satMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    satMap.BorderSizePixel = 0
    satMap.ClipsDescendants = true
    satMap.ZIndex = 1001
    satMap.Parent = overlay

    local mapCorner = Instance.new("UICorner")
    mapCorner.CornerRadius = UDim.new(0, 4)
    mapCorner.Parent = satMap

    local cursor = Instance.new("Frame")
    cursor.Name = "Cursor"
    cursor.Size = UDim2.fromOffset(12, 12)
    cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cursor.BorderSizePixel = 1
    cursor.BorderColor3 = Color3.fromRGB(0, 0, 0)
    cursor.ZIndex = 1002
    cursor.Parent = satMap

    local cursorCorner = Instance.new("UICorner")
    cursorCorner.CornerRadius = UDim.new(1, 0)
    cursorCorner.Parent = cursor

    local function fireCallback()
        pcall(callback, data.value)
    end

    local function updateField()
        field.BackgroundColor3 = data.value
        hex.Text = rgbToHex(data.value)
        hex.TextColor3 = getContrastColor(data.value)
    end

    local function display()
        satMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        cursor.Position = UDim2.new(sat, -6, 1 - vib, -6)
        data.value = Color3.fromHSV(hue, sat, vib)
        updateField()
    end

    display()

    local dragging = false

    satMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local minX, maxX = satMap.AbsolutePosition.X, satMap.AbsolutePosition.X + satMap.AbsoluteSize.X
            local minY, maxY = satMap.AbsolutePosition.Y, satMap.AbsolutePosition.Y + satMap.AbsoluteSize.Y
            sat = (math.clamp(input.Position.X, minX, maxX) - minX) / (maxX - minX)
            vib = 1 - ((math.clamp(input.Position.Y, minY, maxY) - minY) / (maxY - minY))
            display()
            fireCallback()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local minX, maxX = satMap.AbsolutePosition.X, satMap.AbsolutePosition.X + satMap.AbsoluteSize.X
            local minY, maxY = satMap.AbsolutePosition.Y, satMap.AbsolutePosition.Y + satMap.AbsoluteSize.Y
            sat = (math.clamp(input.Position.X, minX, maxX) - minX) / (maxX - minX)
            vib = 1 - ((math.clamp(input.Position.Y, minY, maxY) - minY) / (maxY - minY))
            display()
            fireCallback()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    field.MouseButton1Click:Connect(function()
        overlay.Visible = not overlay.Visible
    end)

    function data:Set(color)
        data.value = color
        hue, sat, vib = Color3.toHSV(data.value)
        display()
        fireCallback()
    end

    function data:Get()
        return data.value
    end

    function data:Destroy()
        container:Destroy()
    end

    return data
end)

-- // Windows
local Window = {}
Window.__index = Window

function Window.new(title, subtitle)
    local self = setmetatable({}, Window)
    
    self.Title = title or "UILib"
    self.Subtitle = subtitle or "by rip_sheldoohz"
    self.Width = 550
    self.Height = 350
    self.tabs = {}
    self.sections = {}
    self.sectionCount = 0
    self.selectedTab = nil
    self.dragging = false
    self.dragOffset = Vector2.new(0, 0)
    self.connections = {}
    
    AntiCheat:Init()
    self:_init()
    
    return self
end

function Window:_init()
    local player = Players.LocalPlayer
    if not player then return end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    for _, child in ipairs(playerGui:GetChildren()) do
        if child.Name == self.Title or child.Name == self.Title .. "_Toggle" then
            child:Destroy()
        end
    end
    
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = self.Title
    self.screenGui.ResetOnSpawn = false
    self.screenGui.DisplayOrder = 999
    self.screenGui.Parent = playerGui
    
    AntiCheat:ProtectObject(self.screenGui)
    
    self.mainPanel = Instance.new("Frame")
    self.mainPanel.Name = "MainPanel"
    self.mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    self.mainPanel.Size = UDim2.new(0, self.Width, 0, self.Height)
    self.mainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.mainPanel.BackgroundColor3 = Theme.Panel
    self.mainPanel.BorderSizePixel = 0
    self.mainPanel.ClipsDescendants = true
    self.mainPanel.Parent = self.screenGui
    
    AntiCheat:ProtectObject(self.mainPanel)
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 6)
    panelCorner.Parent = self.mainPanel
    
    self:_createTopBar()
    self:_createContent()
    self:_createToggleButton(playerGui)
    self:_setupDrag()
end

function Window:_createTopBar()
    self.topBar = Instance.new("Frame")
    self.topBar.Name = "TopBar"
    self.topBar.Size = UDim2.new(1, 0, 0, 55)
    self.topBar.BackgroundTransparency = 1
    self.topBar.BorderSizePixel = 0
    self.topBar.ZIndex = 5
    self.topBar.Parent = self.mainPanel
    
    local topBarLine = Instance.new("Frame")
    topBarLine.Name = "Line"
    topBarLine.Size = UDim2.new(1, 0, 0, 1)
    topBarLine.Position = UDim2.new(0, 0, 1, -1)
    topBarLine.BackgroundColor3 = Theme.Line
    topBarLine.BorderSizePixel = 0
    topBarLine.Parent = self.topBar
    
    local textContainer = Instance.new("Frame")
    textContainer.Name = "TextContainer"
    textContainer.Size = UDim2.new(1, -220, 1, 0)
    textContainer.Position = UDim2.new(0, 18, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.BorderSizePixel = 0
    textContainer.Parent = self.topBar
    
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "TitleLabel"
    self.titleLabel.Size = UDim2.new(1, 0, 0, 22)
    self.titleLabel.Position = UDim2.new(0, 0, 0, 10)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.TextColor3 = Theme.TitleText
    self.titleLabel.TextSize = 18
    self.titleLabel.Font = FONT_BOLD
    self.titleLabel.Text = self.Title
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Parent = textContainer
    
    self.subtitleLabel = Instance.new("TextLabel")
    self.subtitleLabel.Name = "SubtitleLabel"
    self.subtitleLabel.Size = UDim2.new(1, 0, 0, 14)
    self.subtitleLabel.Position = UDim2.new(0, 0, 0, 29)
    self.subtitleLabel.BackgroundTransparency = 1
    self.subtitleLabel.TextColor3 = Theme.TextSecondary
    self.subtitleLabel.TextSize = 11
    self.subtitleLabel.Font = FONT
    self.subtitleLabel.Text = self.Subtitle
    self.subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.subtitleLabel.Parent = textContainer
    
    local searchContainer = Instance.new("Frame")
    searchContainer.Name = "SearchContainer"
    searchContainer.Size = UDim2.new(0, 160, 0, 28)
    searchContainer.Position = UDim2.new(1, -18, 0.5, 0)
    searchContainer.AnchorPoint = Vector2.new(1, 0.5)
    searchContainer.BackgroundColor3 = Theme.HoverFill
    searchContainer.BackgroundTransparency = 0.96
    searchContainer.BorderSizePixel = 0
    searchContainer.ClipsDescendants = true
    searchContainer.Parent = self.topBar
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 4)
    searchCorner.Parent = searchContainer
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.new(0, 14, 0, 14)
    searchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = ICONS.assets and ICONS.assets["lucide-search"] or "rbxassetid://11419472304"
    searchIcon.ImageColor3 = Theme.TextSecondary
    searchIcon.Parent = searchContainer
    
    self.searchBox = Instance.new("TextBox")
    self.searchBox.Name = "SearchInput"
    self.searchBox.Size = UDim2.new(1, -32, 1, 0)
    self.searchBox.Position = UDim2.new(0, 28, 0.5, 0)
    self.searchBox.AnchorPoint = Vector2.new(0, 0.5)
    self.searchBox.BackgroundTransparency = 1
    self.searchBox.Text = ""
    self.searchBox.PlaceholderText = "Pesquisar..."
    self.searchBox.PlaceholderColor3 = Theme.TextSecondary
    self.searchBox.TextColor3 = Theme.TextPrimary
    self.searchBox.Font = FONT
    self.searchBox.TextSize = 13
    self.searchBox.TextXAlignment = Enum.TextXAlignment.Left
    self.searchBox.ClearTextOnFocus = false
    self.searchBox.ClipsDescendants = true
    self.searchBox.Parent = searchContainer
    
    table.insert(self.connections, self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:_filterTabs(self.searchBox.Text)
    end))
end

function Window:_filterTabs(query)
    query = query:lower()
    local sectionHasVisible = {}
    local firstVisibleTab = nil
    
    for _, tab in ipairs(self.tabs) do
        local visible = query == "" or string.find(tab.name:lower(), query, 1, true) ~= nil
        tab.button.Visible = visible
        
        if visible then
            if not firstVisibleTab then firstVisibleTab = tab end
            if tab.section then sectionHasVisible[tab.section] = true end
        else
            tab.page.Visible = false
        end
    end
    
    for sectionName, header in pairs(self.sections) do
        header.Visible = sectionHasVisible[sectionName] == true
    end
    
    if firstVisibleTab then
        if self.selectedTab and not firstVisibleTab.button.Visible then
            self.selectedTab.updateVisuals(false)
            self.selectedTab = firstVisibleTab
            self.selectedTab.updateVisuals(true)
        elseif self.selectedTab and self.selectedTab.button.Visible then
            self.selectedTab.page.Visible = true
        end
    end
end

function Window:_createContent()
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, 0, 1, -55)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 55)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.ZIndex = 1
    self.contentFrame.Parent = self.mainPanel
    
    self.tabBar = Instance.new("ScrollingFrame")
    self.tabBar.Name = "TabBar"
    self.tabBar.Size = UDim2.new(0, 150, 1, 0)
    self.tabBar.BackgroundTransparency = 1
    self.tabBar.BorderSizePixel = 0
    self.tabBar.ScrollBarThickness = 0
    self.tabBar.ClipsDescendants = true
    self.tabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.tabBar.Parent = self.contentFrame
    
    local sectionLine = Instance.new("Frame")
    sectionLine.Name = "SectionLine"
    sectionLine.Size = UDim2.new(0, 1, 1, 0)
    sectionLine.Position = UDim2.new(0, 149, 0, 0)
    sectionLine.BackgroundColor3 = Theme.Line
    sectionLine.BorderSizePixel = 0
    sectionLine.ZIndex = 2
    sectionLine.Parent = self.contentFrame
    
    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 2)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = self.tabBar
    
    local tabListPadding = Instance.new("UIPadding")
    tabListPadding.PaddingTop = UDim.new(0, 8)
    tabListPadding.PaddingBottom = UDim.new(0, 8)
    tabListPadding.PaddingLeft = UDim.new(0, 6)
    tabListPadding.PaddingRight = UDim.new(0, 6)
    tabListPadding.Parent = self.tabBar
    
    self.tabContent = Instance.new("Frame")
    self.tabContent.Name = "TabContent"
    self.tabContent.Size = UDim2.new(1, -150, 1, 0)
    self.tabContent.Position = UDim2.new(0, 150, 0, 0)
    self.tabContent.BackgroundTransparency = 1
    self.tabContent.BorderSizePixel = 0
    self.tabContent.ClipsDescendants = true
    self.tabContent.Parent = self.contentFrame
end

function Window:_createToggleButton(playerGui)
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = self.Title .. "_Toggle"
    toggleGui.ResetOnSpawn = false
    toggleGui.DisplayOrder = 1000
    toggleGui.Parent = playerGui
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "OpenButton"
    toggleButton.Size = UDim2.new(0, 46, 0, 46)
    toggleButton.Position = UDim2.new(0, 20, 0.5, -23)
    toggleButton.BackgroundColor3 = Theme.Panel
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.ClipsDescendants = true
    toggleButton.Parent = toggleGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Line
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = toggleButton
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleButton
    
    local toggleTexture = Instance.new("ImageLabel")
    toggleTexture.Name = "Texture"
    toggleTexture.Size = UDim2.new(1, 0, 1, 0)
    toggleTexture.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleTexture.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleTexture.BackgroundTransparency = 1
    toggleTexture.Image = "rbxassetid://88779617285504"
    toggleTexture.ScaleType = Enum.ScaleType.Crop
    toggleTexture.ImageTransparency = 0.90
    toggleTexture.ZIndex = 1
    toggleTexture.Parent = toggleButton
    
    local textureCorner = Instance.new("UICorner")
    textureCorner.CornerRadius = UDim.new(1, 0)
    textureCorner.Parent = toggleTexture
    
    local toggleIcon = Instance.new("ImageLabel")
    toggleIcon.Name = "ToggleIcon"
    toggleIcon.Size = UDim2.new(0, 20, 0, 20)
    toggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Image = ICONS.assets and ICONS.assets["lucide-panel-left"] or "rbxassetid://11419472304"
    toggleIcon.ImageColor3 = Theme.TextPrimary
    toggleIcon.ZIndex = 2
    toggleIcon.Parent = toggleButton
    
    local draggingButton = false
    local isActualDrag = false
    local dragStart = Vector3.new(0, 0, 0)
    local startPos = UDim2.new(0, 0, 0, 0)
    local DRAG_THRESHOLD = 7
    
    table.insert(self.connections, toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingButton = true
            isActualDrag = false
            dragStart = input.Position
            startPos = toggleButton.Position
        end
    end))
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if draggingButton and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > DRAG_THRESHOLD then isActualDrag = true end
            if isActualDrag then
                toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if draggingButton and not isActualDrag then
                self.mainPanel.Visible = not self.mainPanel.Visible
            end
            draggingButton = false
            isActualDrag = false
        end
    end))
end

function Window:_setupDrag()
    table.insert(self.connections, self.topBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            local center = self.mainPanel.AbsolutePosition + self.mainPanel.AbsoluteSize / 2
            self.dragOffset = center - UserInputService:GetMouseLocation()
        end
    end))
    
    table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = false
        end
    end))
    
    table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
        if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            self.mainPanel.Position = UDim2.new(0, mousePos.X + self.dragOffset.X, 0, mousePos.Y + self.dragOffset.Y)
        end
    end))
end

function Window:CreateTab(options)
    local sectionName = type(options) == "table" and options.section or nil
    local tabName = type(options) == "table" and options.tab or options
    local iconName = type(options) == "table" and options.icon or nil
    
    if sectionName and not self.sections[sectionName] then
        self.sectionCount = self.sectionCount + 1
        
        local headerContainer = Instance.new("Frame")
        headerContainer.Name = sectionName .. "_Header"
        headerContainer.Size = UDim2.new(1, -12, 0, 26)
        headerContainer.BackgroundTransparency = 1
        headerContainer.LayoutOrder = self.sectionCount * 1000
        headerContainer.Parent = self.tabBar
        
        local header = Instance.new("TextLabel")
        header.Name = "Text"
        header.Size = UDim2.new(1, 0, 1, 0)
        header.Position = UDim2.new(0, 8, 0, 4)
        header.BackgroundTransparency = 1
        header.Text = sectionName
        header.Font = FONT
        header.TextSize = 12
        header.TextColor3 = Theme.TextHeader
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextYAlignment = Enum.TextYAlignment.Center
        header.Parent = headerContainer
        
        self.sections[sectionName] = headerContainer
    end
    
    local window = self
    local tabData = {}
    tabData.name = tabName
    tabData.section = sectionName
    tabData.selected = false
    tabData.window = window
    
    local button = Instance.new("TextButton")
    button.Name = tabName
    button.Size = UDim2.new(1, -12, 0, 30)
    button.BackgroundTransparency = 1
    button.AutoButtonColor = false
    button.Text = ""
    button.BorderSizePixel = 0
    button.LayoutOrder = (self.sectionCount * 1000) + #self.tabs + 1
    button.Parent = self.tabBar
    
    local highlight = Instance.new("Frame")
    highlight.Name = "Highlight"
    highlight.Size = UDim2.new(1, 0, 1, 0)
    highlight.BackgroundColor3 = Theme.HoverFill
    highlight.BackgroundTransparency = 1
    highlight.BorderSizePixel = 0
    highlight.Parent = button
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 4)
    highlightCorner.Parent = highlight
    
    local indicatorBar = Instance.new("Frame")
    indicatorBar.Name = "IndicatorBar"
    indicatorBar.Size = UDim2.new(0, 2, 0, 0)
    indicatorBar.Position = UDim2.new(0, 2, 0.5, 0)
    indicatorBar.BackgroundColor3 = Theme.Accent
    indicatorBar.BorderSizePixel = 0
    indicatorBar.BackgroundTransparency = 1
    indicatorBar.Parent = button
    
    local iconLabel
    if iconName and ICONS.assets then
        local foundIcon = ICONS.assets["lucide-" .. iconName]
        if foundIcon then
            iconLabel = Instance.new("ImageLabel")
            iconLabel.Name = "Icon"
            iconLabel.Size = UDim2.new(0, 14, 0, 14)
            iconLabel.Position = UDim2.new(0, 14, 0.5, -7)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = foundIcon
            iconLabel.ImageColor3 = Theme.TextSecondary
            iconLabel.Parent = button
        end
    end
    
    local textOffset = iconLabel and 34 or 14
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Size = UDim2.new(1, -textOffset, 1, 0)
    tabLabel.Position = UDim2.new(0, textOffset, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = tabName
    tabLabel.Font = FONT
    tabLabel.TextSize = 13
    tabLabel.TextColor3 = Theme.TextSecondary
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = button
    
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ClipsDescendants = true
    page.Visible = false
    page.Parent = self.tabContent
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page
    
    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 12)
    pagePadding.PaddingLeft = UDim.new(0, 12)
    pagePadding.PaddingRight = UDim.new(0, 12)
    pagePadding.PaddingBottom = UDim.new(0, 12)
    pagePadding.Parent = page
    
    tabData.button = button
    tabData.page = page
    tabData.pageLayout = pageLayout
    
    local function updateTabVisuals(isSelected)
        tabData.selected = isSelected
        page.Visible = isSelected and button.Visible
        
        tabLabel.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
        tabLabel.Font = isSelected and FONT_BOLD or FONT
        
        if iconLabel then
            iconLabel.ImageColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
        end
        
        TweenService:Create(highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = isSelected and 0.94 or 1
        }):Play()
        
        TweenService:Create(indicatorBar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = isSelected and UDim2.new(0, 2, 0, 14) or UDim2.new(0, 2, 0, 0),
            Position = isSelected and UDim2.new(0, 2, 0.5, -7) or UDim2.new(0, 2, 0.5, 0),
            BackgroundTransparency = isSelected and 0 or 1
        }):Play()
    end
    
    table.insert(self.connections, button.MouseEnter:Connect(function()
        if not tabData.selected then
            TweenService:Create(highlight, TweenInfo.new(0.1), {BackgroundTransparency = 0.97}):Play()
        end
    end))
    
    table.insert(self.connections, button.MouseLeave:Connect(function()
        if not tabData.selected then
            TweenService:Create(highlight, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
        end
    end))
    
    table.insert(self.connections, button.MouseButton1Click:Connect(function()
        if self.selectedTab and self.selectedTab ~= tabData then
            self.selectedTab.updateVisuals(false)
        end
        self.selectedTab = tabData
        updateTabVisuals(true)
    end))
    
    tabData.updateVisuals = updateTabVisuals
    table.insert(self.tabs, tabData)
    
    if #self.tabs == 1 then
        self.selectedTab = tabData
        updateTabVisuals(true)
    end
    
    function tabData:CreateSection(sectionName)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = sectionName .. "_Section"
        sectionFrame.Size = UDim2.new(1, 0, 0, 0)
        sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        sectionFrame.BackgroundColor3 = Theme.HoverFill
        sectionFrame.BackgroundTransparency = 0.98
        sectionFrame.BorderSizePixel = 0
        sectionFrame.ClipsDescendants = false
        sectionFrame.Parent = tabData.page
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 6)
        sectionCorner.Parent = sectionFrame
        
        local sectionStroke = Instance.new("UIStroke")
        sectionStroke.Color = Theme.Line
        sectionStroke.Thickness = 1
        sectionStroke.Parent = sectionFrame
        
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 6)
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Parent = sectionFrame
        
        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingTop = UDim.new(0, 10)
        sectionPadding.PaddingBottom = UDim.new(0, 10)
        sectionPadding.PaddingLeft = UDim.new(0, 12)
        sectionPadding.PaddingRight = UDim.new(0, 12)
        sectionPadding.Parent = sectionFrame
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "SectionTitle"
        sectionTitle.Size = UDim2.new(1, 0, 0, 16)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = sectionName:upper()
        sectionTitle.Font = FONT_BOLD
        sectionTitle.TextSize = 11
        sectionTitle.TextColor3 = Theme.TextHeader
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.LayoutOrder = 0
        sectionTitle.Parent = sectionFrame
        
        local sectionData = {}
        sectionData.frame = sectionFrame
        sectionData.window = window
        
        function sectionData:CreateToggle(options)
            return Elements.List["Checkbox"](self, options)
        end
        
        function sectionData:CreateButton(options)
            return Elements.List["Button"](self, options)
        end
        
        function sectionData:CreateSlider(options)
            return Elements.List["Slider"](self, options)
        end
        
        function sectionData:CreateDropdown(options)
            return Elements.List["Dropdown"](self, options)
        end
        
        function sectionData:CreateColorPicker(options)
            return Elements.List["ColorPicker"](self, options)
        end
        
        return sectionData
    end
    
    return tabData
end

function Window:Destroy()
    for _, connection in ipairs(self.connections) do
        pcall(function() connection:Disconnect() end)
    end
    if self.screenGui then self.screenGui:Destroy() end
end

Window.AntiCheat = AntiCheat
Window.ICONS = ICONS
Window.Elements = Elements
Window.Theme = Theme

return Window
