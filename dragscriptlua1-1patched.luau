--[[
    Universal Part Manipulator v1.1 (Fixed & Improved)
    ====================================================
    Исправления:
    - Корректное перемещение частей с осями
    - Исправлена третья вкладка (Player FX)
    - Остановка Blackhole больше не разбрасывает части
    - Добавлен режим Float (взлетание) для выделенных частей
    - Оптимизация очистки ресурсов
]]

-- ====================== СЕРВИСЫ ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ====================== НАСТРОЙКИ СЕТИ (FE) ======================
getgenv().Network = getgenv().Network or {
    BaseParts = {},
    Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
}
local Network = getgenv().Network

-- ====================== ГРАФИЧЕСКИЙ ИНТЕРФЕЙС ======================
local Gui = Instance.new("ScreenGui")
Gui.Name = "PartManipulatorGui"
Gui.Parent = gethui and gethui() or CoreGui
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.7, 0, 0.5, 0)
Main.Size = UDim2.new(0, 300, 0, 460)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = Main
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 10, 10)
Shadow.ZIndex = 0

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 36)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "✨ Part Manipulator"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 3)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18
CloseButton.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Parent = Main
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.Size = UDim2.new(1, 0, 0, 30)

local UIListLayout_Tabs = Instance.new("UIListLayout")
UIListLayout_Tabs.Parent = TabContainer
UIListLayout_Tabs.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_Tabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Tabs.Padding = UDim.new(0, 2)

local function createTab(name, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Parent = TabContainer
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.LayoutOrder = layoutOrder
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local Tab1 = createTab("Move/Draw", 1)
local Tab2 = createTab("ESP", 2)
local Tab3 = createTab("Player FX", 3)
local Tab4 = createTab("Other", 4)

local PageContainer = Instance.new("Frame")
PageContainer.Parent = Main
PageContainer.BackgroundTransparency = 1
PageContainer.Position = UDim2.new(0, 0, 0, 75)
PageContainer.Size = UDim2.new(1, 0, 1, -75)
PageContainer.ClipsDescendants = true

local Pages = {}
for i = 1, 4 do
    local page = Instance.new("Frame")
    page.Name = "Page" .. i
    page.Parent = PageContainer
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = (i == 1)
    Pages[i] = page

    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    local padding = Instance.new("UIPadding")
    padding.Parent = page
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
end

local function switchTab(tabNum)
    for i, page in ipairs(Pages) do
        page.Visible = (i == tabNum)
    end
    for i, tabBtn in ipairs(TabContainer:GetChildren()) do
        if tabBtn:IsA("TextButton") then
            tabBtn.BackgroundColor3 = (i == tabNum) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
            tabBtn.TextColor3 = (i == tabNum) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        end
    end
end

Tab1.MouseButton1Click:Connect(function() switchTab(1) end)
Tab2.MouseButton1Click:Connect(function() switchTab(2) end)
Tab3.MouseButton1Click:Connect(function() switchTab(3) end)
Tab4.MouseButton1Click:Connect(function() switchTab(4) end)

-- ====================== ЭЛЕМЕНТЫ UI ======================
local function createButton(parent, text, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.LayoutOrder = layoutOrder
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    return btn
end

local function createCheckbox(parent, text, layoutOrder, default)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -20, 0, 34)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local boxFrame = Instance.new("Frame")
    boxFrame.Parent = frame
    boxFrame.AnchorPoint = Vector2.new(1, 0.5)
    boxFrame.Position = UDim2.new(1, 0, 0.5, 0)
    boxFrame.Size = UDim2.new(0, 22, 0, 22)
    boxFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = boxFrame

    local check = Instance.new("ImageLabel")
    check.Parent = boxFrame
    check.BackgroundTransparency = 1
    check.Size = UDim2.new(0.8, 0, 0.8, 0)
    check.Position = UDim2.new(0.1, 0, 0.1, 0)
    check.Image = "rbxassetid://7733960981"
    check.ImageColor3 = Color3.fromRGB(100, 255, 100)
    check.Visible = default or false

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""
    local isChecked = default or false
    btn.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        check.Visible = isChecked
    end)

    return {
        Frame = frame,
        IsChecked = function() return isChecked end,
        SetChecked = function(val)
            isChecked = val
            check.Visible = val
        end
    }
end

local function createSlider(parent, text, min, max, default, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = frame
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Size = UDim2.new(1, 0, 0, 6)
    sliderFrame.Position = UDim2.new(0, 0, 0, 23)
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame

    local fill = Instance.new("Frame")
    fill.Parent = sliderFrame
    fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("ImageButton")
    knob.Parent = sliderFrame
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.Image = "rbxassetid://7733960981"
    knob.ImageColor3 = Color3.fromRGB(0, 170, 255)
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local currentValue = default

    local function updateKnob(percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
        currentValue = min + percent * (max - min)
        label.Text = text .. ": " .. math.floor(currentValue * 10 + 0.5) / 10
    end

    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relPos = mousePos.X - sliderFrame.AbsolutePosition.X
            local percent = math.clamp(relPos / sliderFrame.AbsoluteSize.X, 0, 1)
            updateKnob(percent)
        end
    end)

    return {
        Frame = frame,
        GetValue = function() return currentValue end,
        SetValue = function(val)
            local percent = (val - min) / (max - min)
            updateKnob(percent)
        end
    }
end

local function createTextBox(parent, placeholder, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, -20, 0, 34)
    frame.LayoutOrder = layoutOrder
    frame.BackgroundTransparency = 1

    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.ClearTextOnFocus = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = box

    return box
end

-- ====================== ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ======================
local Folder = Instance.new("Folder", Workspace)
Folder.Name = "PartManipulatorHelper"

local HelperPart = Instance.new("Part", Folder)
HelperPart.Name = "Helper"
HelperPart.Anchored = true
HelperPart.CanCollide = false
HelperPart.Transparency = 0.5
HelperPart.Color = Color3.fromRGB(0, 170, 255)
HelperPart.Material = Enum.Material.Neon
HelperPart.Shape = Enum.PartType.Ball
HelperPart.Size = Vector3.new(1, 1, 1)

local HelperAttachment = Instance.new("Attachment", HelperPart)
HelperAttachment.Name = "MoveAttachment"

local SelectionFolder = Instance.new("Folder", Folder)
SelectionFolder.Name = "SelectedParts"

local SelectedParts = {}
local ESPFolder = Instance.new("Folder", Folder)
ESPFolder.Name = "ESPFolder"
local DraggedESP = nil

local DrawModeActive = false
local MouseMoveConnection = nil
local MouseDownConnection = nil

local BlackholeActive = false
local OrbitActive = false
local FloatActive = false
local OrbitConnection = nil
local FloatConnection = nil
local SelectedPlayer = nil

local MegaDragMode = false
local MegaDragPart = nil

-- ====================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ======================
local function getPlayer(name)
    local lowerName = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), lowerName) or string.find(string.lower(p.DisplayName), lowerName) then
            return p
        end
    end
    return nil
end

-- Очистка части от всех наших манипуляторов
local function cleanupPart(part)
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("AlignPosition") or child:IsA("Torque") or child.Name == "MoverAttachment" or child.Name == "BlackholeAttachment" then
            child:Destroy()
        end
    end
    -- Удаляем из сетевого контроля
    for i, p in ipairs(Network.BaseParts) do
        if p == part then
            table.remove(Network.BaseParts, i)
            break
        end
    end
    part.CustomPhysicalProperties = PhysicalProperties.new(part.Material)
    part.CanCollide = true
    part.Massless = false
end

Network.RetainPart = function(Part)
    if Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
        -- Избегаем дублирования
        for _, p in ipairs(Network.BaseParts) do
            if p == Part then return end
        end
        table.insert(Network.BaseParts, Part)
        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
    end
end

local function EnablePartControl()
    LocalPlayer.ReplicationFocus = Workspace
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        for _, Part in pairs(Network.BaseParts) do
            if Part:IsDescendantOf(Workspace) then
                Part.Velocity = Network.Velocity
            end
        end
    end)
end
EnablePartControl()

-- ====================== ESP ======================
local function createESP(part, color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.Parent = ESPFolder
    highlight.Adornee = part
    highlight.FillColor = color or Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    return highlight
end

local function removeESP(part)
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        if obj:IsA("Highlight") and obj.Adornee == part then
            obj:Destroy()
            break
        end
    end
end

local function updateAllUnanchoredESP()
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        if obj:IsA("Highlight") and obj.Name == "ESP_Unanchored" then
            obj:Destroy()
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(SelectionFolder) then
            local exists = false
            for _, h in ipairs(ESPFolder:GetChildren()) do
                if h:IsA("Highlight") and h.Adornee == obj then
                    exists = true
                    break
                end
            end
            if not exists then
                local hl = createESP(obj, Color3.fromRGB(0, 255, 0))
                hl.Name = "ESP_Unanchored"
            end
        end
    end
end

Workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("BasePart") and not desc.Anchored then
        task.wait()
        if not desc:IsDescendantOf(SelectionFolder) then
            local hl = createESP(desc, Color3.fromRGB(0, 255, 0))
            hl.Name = "ESP_Unanchored"
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(desc)
    if desc:IsA("BasePart") then
        removeESP(desc)
    end
end)

-- ====================== РАБОТА С ЧАСТЯМИ ======================
local function isPartValid(part)
    if not part:IsA("BasePart") then return false end
    if part.Anchored then return false end
    if part.Parent:FindFirstChildOfClass("Humanoid") then return false end
    if part.Parent:FindFirstChild("Head") then return false end
    if part.Name == "Handle" then return false end
    if part:IsDescendantOf(SelectionFolder) then return false end
    return true
end

local function setupPartControl(part)
    cleanupPart(part) -- сначала полная очистка
    local attach = Instance.new("Attachment", part)
    attach.Name = "MoverAttachment"
    local alignPos = Instance.new("AlignPosition", part)
    alignPos.Attachment0 = attach
    alignPos.Attachment1 = HelperAttachment
    alignPos.MaxForce = math.huge
    alignPos.MaxVelocity = math.huge
    alignPos.Responsiveness = 200
    alignPos.RigidityEnabled = false

    local torque = Instance.new("Torque", part)
    torque.Attachment0 = attach
    torque.Torque = Vector3.new(100000, 100000, 100000)

    part.CanCollide = false
    part.Massless = true

    Network.RetainPart(part)

    if DraggedESP then DraggedESP:Destroy() end
    DraggedESP = createESP(part, Color3.fromRGB(255, 165, 0))
    DraggedESP.Name = "ESP_Dragged"
end

local function addPartToSelection(part)
    if not isPartValid(part) then return end
    if SelectedParts[part] then return end

    setupPartControl(part)
    part.Parent = SelectionFolder
    SelectedParts[part] = true
    removeESP(part)
end

local function removePartFromSelection(part)
    if not SelectedParts[part] then return end
    cleanupPart(part)
    part.Parent = Workspace
    SelectedParts[part] = nil

    if DraggedESP and DraggedESP.Adornee == part then
        DraggedESP:Destroy()
        DraggedESP = nil
    end
    if not part.Anchored then
        local hl = createESP(part, Color3.fromRGB(0, 255, 0))
        hl.Name = "ESP_Unanchored"
    end
end

local function clearSelection()
    for part in pairs(SelectedParts) do
        removePartFromSelection(part)
    end
    if DraggedESP then
        DraggedESP:Destroy()
        DraggedESP = nil
    end
    StatusLabel.Text = "Status: Cleared selection"
end

-- ====================== ВЫДЕЛЕНИЕ С МОДИФИКАТОРАМИ ======================
local function handlePartSelection(part, addMode, toggleMode)
    if toggleMode then
        if SelectedParts[part] then
            removePartFromSelection(part)
            StatusLabel.Text = "Status: Removed part from selection"
        else
            addPartToSelection(part)
            StatusLabel.Text = "Status: Added part to selection"
        end
    elseif addMode then
        if not SelectedParts[part] then
            addPartToSelection(part)
            StatusLabel.Text = "Status: Added part to selection"
        end
    else
        clearSelection()
        addPartToSelection(part)
        StatusLabel.Text = "Status: Selected part"
    end
end

local function handleAreaSelection(center, radius, addMode, toggleMode)
    local parts = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isPartValid(obj) then
            local dist = (obj.Position - center).Magnitude
            if dist <= radius then
                table.insert(parts, obj)
            end
        end
    end

    if toggleMode then
        for _, part in ipairs(parts) do
            if SelectedParts[part] then
                removePartFromSelection(part)
            else
                addPartToSelection(part)
            end
        end
        StatusLabel.Text = "Status: Toggled " .. #parts .. " parts"
    elseif addMode then
        for _, part in ipairs(parts) do
            if not SelectedParts[part] then
                addPartToSelection(part)
            end
        end
        StatusLabel.Text = "Status: Added " .. #parts .. " parts"
    else
        clearSelection()
        for _, part in ipairs(parts) do
            addPartToSelection(part)
        end
        StatusLabel.Text = "Status: Selected " .. #parts .. " parts"
    end
end

-- ====================== MEGA DRAG ======================
local function startMegaDrag()
    MegaDragMode = true
    MegaDragPart = nil
end

local function stopMegaDrag()
    MegaDragMode = false
    if MegaDragPart then
        removePartFromSelection(MegaDragPart)
        MegaDragPart = nil
    end
end

-- ====================== DRAW MODE ======================
local function startDrawMode()
    DrawModeActive = true
    DrawBtn.Text = "🖌️ Draw Mode (ON)"
    StatusLabel.Text = "Status: Draw mode active"

    MouseMoveConnection = RunService.RenderStepped:Connect(function()
        if not DrawModeActive then return end
        local ray = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * 1000)
        local hit, pos = Workspace:FindPartOnRay(ray, nil, false, true)
        local targetPos = pos or (Mouse.UnitRay.Origin + Mouse.UnitRay.Direction * 50)

        local currentPos = HelperPart.Position
        local newPos = Vector3.new(
            AxisXCheck.IsChecked() and targetPos.X or currentPos.X,
            AxisYCheck.IsChecked() and targetPos.Y or currentPos.Y,
            AxisZCheck.IsChecked() and targetPos.Z or currentPos.Z
        )
        HelperPart.Position = newPos

        if MegaDragMode then
            local target = Mouse.Target
            if target and target:IsA("BasePart") and isPartValid(target) then
                if MegaDragPart ~= target then
                    if MegaDragPart then removePartFromSelection(MegaDragPart) end
                    MegaDragPart = target
                    addPartToSelection(target)
                end
            end
        end
    end)

    MouseDownConnection = Mouse.Button1Down:Connect(function()
        if not DrawModeActive then return end
        if MegaDragCheck.IsChecked() then return end

        local ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        local shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        local target = Mouse.Target
        if target and isPartValid(target) then
            handlePartSelection(target, shiftPressed, ctrlPressed)
        else
            local ray = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * 1000)
            local hit, pos = Workspace:FindPartOnRay(ray, nil, false, true)
            if pos then
                handleAreaSelection(pos, RadiusSlider.GetValue(), shiftPressed, ctrlPressed)
            end
        end
    end)
end

local function stopDrawMode()
    DrawModeActive = false
    DrawBtn.Text = "🖌️ Draw Mode"
    StatusLabel.Text = "Status: Idle"
    if MouseDownConnection then MouseDownConnection:Disconnect() end
    if MouseMoveConnection then MouseMoveConnection:Disconnect() end
    stopMegaDrag()
end

-- ====================== BLACKHOLE (ИСПРАВЛЕНО) ======================
local BlackholeConnections = {}
local BlackholeParts = {}

local function forcePartToPlayer(part, targetHRP)
    if not isPartValid(part) then return end
    cleanupPart(part) -- очищаем от предыдущих манипуляций
    local attach = Instance.new("Attachment", part)
    local alignPos = Instance.new("AlignPosition", part)
    alignPos.Attachment0 = attach
    local targetAttach = targetHRP:FindFirstChild("BlackholeAttachment") or Instance.new("Attachment", targetHRP)
    targetAttach.Name = "BlackholeAttachment"
    alignPos.Attachment1 = targetAttach
    alignPos.MaxForce = math.huge
    alignPos.MaxVelocity = math.huge
    alignPos.Responsiveness = 200
    part.CanCollide = false
    Network.RetainPart(part)
    table.insert(BlackholeParts, part)
end

local function startBlackhole(player)
    if not player then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    BlackholeActive = true

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isPartValid(obj) then
            forcePartToPlayer(obj, hrp)
        end
    end

    local conn = Workspace.DescendantAdded:Connect(function(obj)
        if BlackholeActive and obj:IsA("BasePart") and isPartValid(obj) then
            forcePartToPlayer(obj, hrp)
        end
    end)
    table.insert(BlackholeConnections, conn)
end

local function stopBlackhole()
    BlackholeActive = false
    for _, conn in ipairs(BlackholeConnections) do
        conn:Disconnect()
    end
    BlackholeConnections = {}
    for _, part in ipairs(BlackholeParts) do
        cleanupPart(part) -- полностью очищаем часть, возвращаем физику
    end
    BlackholeParts = {}
end

-- ====================== ORBIT ======================
local OrbitParts = {}
local function startOrbit(player)
    if not player then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    OrbitActive = true

    for part in pairs(SelectedParts) do
        if part and part.Parent then
            table.insert(OrbitParts, part)
        end
    end

    local angle = 0
    local radius = 10
    local speed = 2

    OrbitConnection = RunService.Heartbeat:Connect(function(delta)
        if not OrbitActive then return end
        angle = angle + delta * speed
        for i, part in ipairs(OrbitParts) do
            if part and part.Parent then
                local offset = Vector3.new(math.cos(angle + i), math.sin(angle + i), math.cos(angle + i*2)) * radius
                local targetPos = hrp.Position + offset
                HelperAttachment.WorldPosition = targetPos
            end
        end
    end)
end

local function stopOrbit()
    OrbitActive = false
    if OrbitConnection then
        OrbitConnection:Disconnect()
        OrbitConnection = nil
    end
    OrbitParts = {}
end

-- ====================== FLOAT (ВЗЛЕТАНИЕ) ======================
local FloatParts = {}
local function startFloat()
    FloatActive = true
    for part in pairs(SelectedParts) do
        if part and part.Parent then
            table.insert(FloatParts, part)
        end
    end
    local speed = 5 -- юнитов в секунду
    FloatConnection = RunService.Heartbeat:Connect(function(delta)
        if not FloatActive then return end
        for _, part in ipairs(FloatParts) do
            if part and part.Parent then
                HelperAttachment.WorldPosition = part.Position + Vector3.new(0, speed * delta, 0)
            end
        end
    end)
end

local function stopFloat()
    FloatActive = false
    if FloatConnection then
        FloatConnection:Disconnect()
        FloatConnection = nil
    end
    FloatParts = {}
end

-- ====================== ЗАПОЛНЕНИЕ UI ======================
-- Страница 1: Move/Draw
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Pages[1]
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.LayoutOrder = 99
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 12

local DrawBtn = createButton(Pages[1], "🖌️ Draw Mode", 1)
local MoveToggleCheck = createCheckbox(Pages[1], "🎯 Move with Mouse", 2, true)
local AxisXCheck = createCheckbox(Pages[1], "↔️ X Axis", 3, true)
local AxisYCheck = createCheckbox(Pages[1], "↕️ Y Axis", 4, true)
local AxisZCheck = createCheckbox(Pages[1], "↗️ Z Axis", 5, true)
local RadiusSlider = createSlider(Pages[1], "Selection Radius", 5, 50, 15, 6)
local ClearBtn = createButton(Pages[1], "🧹 Clear Selected Parts", 7)
local MegaDragCheck = createCheckbox(Pages[1], "💪 Mega Drag (stick to cursor)", 8, false)
local NoclipCheck = createCheckbox(Pages[1], "🚫 Noclip (parts pass through walls)", 9, true)

-- Страница 2: ESP
local ESPToggleCheck = createCheckbox(Pages[2], "👁️ ESP All Unanchored Parts", 1, true)
local ESPRefreshBtn = createButton(Pages[2], "🔄 Refresh ESP", 2)
local ESPColorNote = Instance.new("TextLabel")
ESPColorNote.Parent = Pages[2]
ESPColorNote.Size = UDim2.new(1, -20, 0, 20)
ESPColorNote.LayoutOrder = 3
ESPColorNote.BackgroundTransparency = 1
ESPColorNote.Font = Enum.Font.Gotham
ESPColorNote.Text = "Green = unanchored | Orange = dragged"
ESPColorNote.TextColor3 = Color3.fromRGB(150, 150, 150)
ESPColorNote.TextSize = 11

-- Страница 3: Player FX
local PlayerBox = createTextBox(Pages[3], "Enter player name", 1)
local SelectPlayerBtn = createButton(Pages[3], "👤 Select Player", 2)
local SelectedPlayerLabel = Instance.new("TextLabel")
SelectedPlayerLabel.Parent = Pages[3]
SelectedPlayerLabel.Size = UDim2.new(1, -20, 0, 20)
SelectedPlayerLabel.LayoutOrder = 3
SelectedPlayerLabel.BackgroundTransparency = 1
SelectedPlayerLabel.Font = Enum.Font.Gotham
SelectedPlayerLabel.Text = "Selected: None"
SelectedPlayerLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SelectedPlayerLabel.TextSize = 12

local BlackholeBtn = createButton(Pages[3], "🌌 Blackhole (Bring parts to player)", 4)
local BlackholeStopBtn = createButton(Pages[3], "⏹️ Stop Blackhole", 5)
local OrbitBtn = createButton(Pages[3], "🔄 Orbit Selected Parts", 6)
local OrbitStopBtn = createButton(Pages[3], "⏹️ Stop Orbit", 7)

-- Страница 4: Other
local HelperToggleBtn = createButton(Pages[4], "👁️ Hide Helper Part", 1)
local DestroyAllBtn = createButton(Pages[4], "💣 Destroy All Selected Parts", 2)
local FloatCheck = createCheckbox(Pages[4], "⬆️ Float Selected Parts (rise up)", 3, false)

-- ====================== ОБРАБОТЧИКИ UI ======================
switchTab(1)

ESPToggleCheck.SetChecked(true)
local espEnabled = true
ESPToggleCheck.Frame:FindFirstChildOfClass("TextButton").MouseButton1Click:Connect(function()
    espEnabled = ESPToggleCheck.IsChecked()
    for _, hl in ipairs(ESPFolder:GetChildren()) do
        if hl:IsA("Highlight") then
            hl.Enabled = espEnabled
        end
    end
end)

ESPRefreshBtn.MouseButton1Click:Connect(function()
    updateAllUnanchoredESP()
    StatusLabel.Text = "Status: ESP refreshed"
end)

SelectPlayerBtn.MouseButton1Click:Connect(function()
    local name = PlayerBox.Text
    if name ~= "" then
        SelectedPlayer = getPlayer(name)
        if SelectedPlayer then
            SelectedPlayerLabel.Text = "Selected: " .. SelectedPlayer.Name
        else
            SelectedPlayerLabel.Text = "Selected: Not found"
        end
    end
end)

BlackholeBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer then
        stopBlackhole()
        startBlackhole(SelectedPlayer)
        StatusLabel.Text = "Status: Blackhole active on " .. SelectedPlayer.Name
    else
        StatusLabel.Text = "Status: No player selected"
    end
end)

BlackholeStopBtn.MouseButton1Click:Connect(function()
    stopBlackhole()
    StatusLabel.Text = "Status: Blackhole stopped"
end)

OrbitBtn.MouseButton1Click:Connect(function()
    if SelectedPlayer then
        stopOrbit()
        startOrbit(SelectedPlayer)
        StatusLabel.Text = "Status: Orbit active around " .. SelectedPlayer.Name
    else
        StatusLabel.Text = "Status: No player selected"
    end
end)

OrbitStopBtn.MouseButton1Click:Connect(function()
    stopOrbit()
    StatusLabel.Text = "Status: Orbit stopped"
end)

FloatCheck.Frame:FindFirstChildOfClass("TextButton").MouseButton1Click:Connect(function()
    if FloatCheck.IsChecked() then
        startFloat()
        StatusLabel.Text = "Status: Float active"
    else
        stopFloat()
        StatusLabel.Text = "Status: Float stopped"
    end
end)

NoclipCheck.SetChecked(true)
NoclipCheck.Frame:FindFirstChildOfClass("TextButton").MouseButton1Click:Connect(function()
    local noclip = NoclipCheck.IsChecked()
    HelperPart.CanCollide = not noclip
    for part in pairs(SelectedParts) do
        part.CanCollide = not noclip
    end
end)

HelperToggleBtn.MouseButton1Click:Connect(function()
    HelperPart.Transparency = HelperPart.Transparency == 0.5 and 1 or 0.5
    HelperToggleBtn.Text = HelperPart.Transparency == 1 and "👁️ Show Helper Part" or "👁️ Hide Helper Part"
end)

DestroyAllBtn.MouseButton1Click:Connect(function()
    for part in pairs(SelectedParts) do
        part:Destroy()
    end
    SelectedParts = {}
    clearSelection()
    StatusLabel.Text = "Status: Destroyed selected parts"
end)

DrawBtn.MouseButton1Click:Connect(function()
    if DrawModeActive then
        stopDrawMode()
    else
        startDrawMode()
    end
end)

ClearBtn.MouseButton1Click:Connect(clearSelection)

MegaDragCheck.Frame:FindFirstChildOfClass("TextButton").MouseButton1Click:Connect(function()
    if MegaDragCheck.IsChecked() then
        startMegaDrag()
    else
        stopMegaDrag()
    end
end)

-- ====================== ИНИЦИАЛИЗАЦИЯ И ЗАВЕРШЕНИЕ ======================
updateAllUnanchoredESP()

Gui.Destroying:Connect(function()
    stopDrawMode()
    stopBlackhole()
    stopOrbit()
    stopFloat()
    clearSelection()
    HelperPart:Destroy()
    Folder:Destroy()
    for _, part in pairs(Network.BaseParts) do
        cleanupPart(part)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessed then
        Main.Visible = not Main.Visible
    end
end)

StatusLabel.Text = "Status: Ready"