--[[
    WindUI — MainUI System
    Implements the Window, Sidebar, SubTabs, Profile Card, Dragging, Resizing,
    Header controls, and Open Button matching the reference screenshot.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.System.Theme)
local Icons = require(script.Parent.Icons)
local Components = require(script.Parent.Components)

local MainUI = {}
MainUI.__index = MainUI

export type WindowConfig = {
    Title: string?,
    Author: string?,
    Icon: string?,
    Size: UDim2?,
    MinSize: Vector2?,
    MaxSize: Vector2?,
    Profile: {
        Username: string?,
        Handle: string?,
        Avatar: string?,
    }?,
}

function MainUI.CreateWindow(screenGui: ScreenGui, config: WindowConfig)
    local titleText = config.Title or "Vind Ui Reborn"
    local authorText = config.Author or "Complete Showcase · v2.9.0-modular"
    local iconId = Icons.Resolve(config.Icon or "sparkles")

    local minSize = config.MinSize or Vector2.new(520, 360)
    local maxSize = config.MaxSize or Vector2.new(900, 640)
    local initialSize = config.Size or UDim2.new(0, 680, 0, 480)

    -- Main Container Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "WindUI_MainWindow"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = initialSize
    mainFrame.BackgroundColor3 = Theme.GetColor("Background")
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 14)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.GetColor("Outline")
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame

    Theme.Register(mainFrame, "BackgroundColor3", "Background")
    Theme.Register(mainStroke, "Color", "Outline")

    -- =========================================================================
    -- HEADER
    -- =========================================================================
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 52)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Parent = mainFrame

    local headerPad = Instance.new("UIPadding")
    headerPad.PaddingLeft = UDim.new(0, 16)
    headerPad.PaddingRight = UDim.new(0, 16)
    headerPad.Parent = header

    -- Left: Logo Icon
    local logo = Instance.new("ImageLabel")
    logo.Name = "LogoIcon"
    logo.BackgroundTransparency = 1
    logo.Position = UDim2.new(0, 0, 0.5, -12)
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Image = iconId or ""
    logo.ImageColor3 = Theme.GetColor("Text")
    logo.Parent = header
    Theme.Register(logo, "ImageColor3", "Text")

    -- Title & Subtitle
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 32, 0, 8)
    titleLbl.Size = UDim2.new(0, 220, 0, 20)
    titleLbl.Font = Theme.GetFont("Bold")
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.GetColor("Text")
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = header
    Theme.Register(titleLbl, "TextColor3", "Text")

    local authorLbl = Instance.new("TextLabel")
    authorLbl.BackgroundTransparency = 1
    authorLbl.Position = UDim2.new(0, 32, 0, 26)
    authorLbl.Size = UDim2.new(0, 280, 0, 16)
    authorLbl.Font = Theme.GetFont("Regular")
    authorLbl.Text = authorText
    authorLbl.TextColor3 = Theme.GetColor("SubText")
    authorLbl.TextSize = 11
    authorLbl.TextXAlignment = Enum.TextXAlignment.Left
    authorLbl.Parent = header
    Theme.Register(authorLbl, "TextColor3", "SubText")

    -- Right Control Buttons (Search, Minimize, Maximize, Close)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.AnchorPoint = Vector2.new(1, 0.5)
    controlsFrame.Position = UDim2.new(1, 0, 0.5, 0)
    controlsFrame.Size = UDim2.new(0, 120, 0, 28)
    controlsFrame.Parent = header

    local controlsList = Instance.new("UIListLayout")
    controlsList.FillDirection = Enum.FillDirection.Horizontal
    controlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsList.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsList.SortOrder = Enum.SortOrder.LayoutOrder
    controlsList.Padding = UDim.new(0, 6)
    controlsList.Parent = controlsFrame

    local function CreateHeaderBtn(name: string, iconName: string, order: number): ImageButton
        local btn = Instance.new("ImageButton")
        btn.Name = name
        btn.LayoutOrder = order
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(0, 24, 0, 24)
        btn.Image = Icons.Resolve(iconName) or ""
        btn.ImageColor3 = Theme.GetColor("SubText")
        btn.Parent = controlsFrame

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { ImageColor3 = Theme.GetColor("Text") }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { ImageColor3 = Theme.GetColor("SubText") }):Play()
        end)

        return btn
    end

    local searchBtn = CreateHeaderBtn("SearchBtn", "search", 1)
    local minBtn = CreateHeaderBtn("MinimizeBtn", "minus", 2)
    local maxBtn = CreateHeaderBtn("MaximizeBtn", "maximize", 3)
    local closeBtn = CreateHeaderBtn("CloseBtn", "x", 4)

    -- =========================================================================
    -- BODY (Sidebar on left, Content on right)
    -- =========================================================================
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 0, 0, 52)
    body.Size = UDim2.new(1, 0, 1, -52)
    body.Parent = mainFrame

    -- Left Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.Parent = body

    local sidebarPad = Instance.new("UIPadding")
    sidebarPad.PaddingLeft = UDim.new(0, 12)
    sidebarPad.PaddingRight = UDim.new(0, 8)
    sidebarPad.PaddingTop = UDim.new(0, 4)
    sidebarPad.PaddingBottom = UDim.new(0, 12)
    sidebarPad.Parent = sidebar

    local tabListContainer = Instance.new("ScrollingFrame")
    tabListContainer.Name = "TabList"
    tabListContainer.BackgroundTransparency = 1
    tabListContainer.BorderSizePixel = 0
    tabListContainer.ScrollBarThickness = 0
    tabListContainer.Size = UDim2.new(1, 0, 1, -60)
    tabListContainer.Position = UDim2.new(0, 0, 0, 0)
    tabListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabListContainer.Parent = sidebar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    tabListLayout.Parent = tabListContainer

    -- Profile Card at bottom of sidebar (matching SkFOrest @luis_akz4)
    local profileCfg = config.Profile or {
        Username = "SkFOrest",
        Handle = "@luis_akz4",
        Avatar = "rbxassetid://10709799567",
    }

    local profileCard = Instance.new("Frame")
    profileCard.Name = "ProfileCard"
    profileCard.BackgroundColor3 = Theme.GetColor("Card")
    profileCard.BackgroundTransparency = 0.5
    profileCard.Size = UDim2.new(1, 0, 0, 48)
    profileCard.Position = UDim2.new(0, 0, 1, -48)
    profileCard.Parent = sidebar

    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 10)
    profileCorner.Parent = profileCard

    local profilePad = Instance.new("UIPadding")
    profilePad.PaddingLeft = UDim.new(0, 8)
    profilePad.PaddingRight = UDim.new(0, 8)
    profilePad.Parent = profileCard

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.new(0, 32, 0, 32)
    avatarImg.Position = UDim2.new(0, 0, 0.5, -16)
    avatarImg.BackgroundColor3 = Color3.fromHex("#15803D") -- Green avatar box as in screenshot
    avatarImg.Image = profileCfg.Avatar or ""
    avatarImg.Parent = profileCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 8)
    avatarCorner.Parent = avatarImg

    local userLbl = Instance.new("TextLabel")
    userLbl.BackgroundTransparency = 1
    userLbl.Position = UDim2.new(0, 40, 0, 8)
    userLbl.Size = UDim2.new(1, -44, 0, 16)
    userLbl.Font = Theme.GetFont("Bold")
    userLbl.Text = profileCfg.Username or "User"
    userLbl.TextColor3 = Theme.GetColor("Text")
    userLbl.TextSize = 12
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.Parent = profileCard
    Theme.Register(userLbl, "TextColor3", "Text")

    local handleLbl = Instance.new("TextLabel")
    handleLbl.BackgroundTransparency = 1
    handleLbl.Position = UDim2.new(0, 40, 0, 24)
    handleLbl.Size = UDim2.new(1, -44, 0, 14)
    handleLbl.Font = Theme.GetFont("Regular")
    handleLbl.Text = profileCfg.Handle or "@user"
    handleLbl.TextColor3 = Theme.GetColor("SubText")
    handleLbl.TextSize = 10
    handleLbl.TextXAlignment = Enum.TextXAlignment.Left
    handleLbl.Parent = profileCard
    Theme.Register(handleLbl, "TextColor3", "SubText")

    -- Right Content View
    local rightView = Instance.new("Frame")
    rightView.Name = "RightView"
    rightView.BackgroundTransparency = 1
    rightView.Position = UDim2.new(0, 185, 0, 0)
    rightView.Size = UDim2.new(1, -195, 1, -10)
    rightView.Parent = body

    -- =========================================================================
    -- TAB MANAGEMENT & SUB-TABS
    -- =========================================================================
    local tabs = {}
    local activeTab = nil

    local function CreateTab(tabConfig: {
        Title: string,
        Icon: string?,
        Locked: boolean?,
        Section: string?, -- Group under category (e.g., 'Examples')
    })
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. (tabConfig.Title or "Tab")
        tabBtn.BackgroundColor3 = Theme.GetColor("Card")
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, 0, 0, 36)
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tabListContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn

        local tabPad = Instance.new("UIPadding")
        tabPad.PaddingLeft = UDim.new(0, 10)
        tabPad.PaddingRight = UDim.new(0, 10)
        tabPad.Parent = tabBtn

        local tabIcon = Instance.new("ImageLabel")
        tabIcon.BackgroundTransparency = 1
        tabIcon.Size = UDim2.new(0, 16, 0, 16)
        tabIcon.Position = UDim2.new(0, 0, 0.5, -8)
        tabIcon.Image = Icons.Resolve(tabConfig.Icon or "grid") or ""
        tabIcon.ImageColor3 = Theme.GetColor("SubText")
        tabIcon.Parent = tabBtn
        Theme.Register(tabIcon, "ImageColor3", "SubText")

        local tabTitle = Instance.new("TextLabel")
        tabTitle.BackgroundTransparency = 1
        tabTitle.Position = UDim2.new(0, 24, 0, 0)
        tabTitle.Size = UDim2.new(1, tabConfig.Locked and -48 or -24, 1, 0)
        tabTitle.Font = Theme.GetFont("Semibold")
        tabTitle.Text = tabConfig.Title or "Tab"
        tabTitle.TextColor3 = Theme.GetColor("SubText")
        tabTitle.TextSize = 12
        tabTitle.TextXAlignment = Enum.TextXAlignment.Left
        tabTitle.Parent = tabBtn
        Theme.Register(tabTitle, "TextColor3", "SubText")

        -- Lock badge if locked (matching Admin lock in screenshot)
        if tabConfig.Locked then
            local lockBadge = Instance.new("ImageLabel")
            lockBadge.BackgroundTransparency = 1
            lockBadge.AnchorPoint = Vector2.new(1, 0.5)
            lockBadge.Position = UDim2.new(1, 0, 0.5, 0)
            lockBadge.Size = UDim2.new(0, 14, 0, 14)
            lockBadge.Image = Icons.Resolve("lock") or ""
            lockBadge.ImageColor3 = Theme.GetColor("SubText")
            lockBadge.Parent = tabBtn
        end

        -- Tab Content Frame
        local tabContent = Instance.new("Frame")
        tabContent.Name = "TabContent_" .. (tabConfig.Title or "Tab")
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.Parent = rightView

        -- Top Sub-Tabs Navigation Bar (matching Auto Farm, Settings, Visuals, Profiles)
        local subTabsBar = Instance.new("Frame")
        subTabsBar.Name = "SubTabsBar"
        subTabsBar.BackgroundTransparency = 1
        subTabsBar.Size = UDim2.new(1, 0, 0, 36)
        subTabsBar.Position = UDim2.new(0, 0, 0, 0)
        subTabsBar.Visible = false
        subTabsBar.Parent = tabContent

        local subTabsList = Instance.new("UIListLayout")
        subTabsList.FillDirection = Enum.FillDirection.Horizontal
        subTabsList.SortOrder = Enum.SortOrder.LayoutOrder
        subTabsList.Padding = UDim.new(0, 8)
        subTabsList.Parent = subTabsBar

        -- Scrollable Component Area
        local scrollArea = Instance.new("ScrollingFrame")
        scrollArea.Name = "ComponentsScroll"
        scrollArea.BackgroundTransparency = 1
        scrollArea.BorderSizePixel = 0
        scrollArea.ScrollBarThickness = 3
        scrollArea.ScrollBarImageColor3 = Theme.GetColor("Outline")
        scrollArea.Position = UDim2.new(0, 0, 0, 0)
        scrollArea.Size = UDim2.new(1, 0, 1, 0)
        scrollArea.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollArea.Parent = tabContent

        local scrollPad = Instance.new("UIPadding")
        scrollPad.PaddingRight = UDim.new(0, 10)
        scrollPad.PaddingTop = UDim.new(0, 6)
        scrollPad.PaddingBottom = UDim.new(0, 14)
        scrollPad.Parent = scrollArea

        local scrollLayout = Instance.new("UIListLayout")
        scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        scrollLayout.Padding = UDim.new(0, 8)
        scrollLayout.Parent = scrollArea

        local subTabs = {}
        local activeSubTab = nil

        local function SelectThisTab()
            for _, t in ipairs(tabs) do
                t.Button.BackgroundTransparency = 1
                t.TitleLabel.TextColor3 = Theme.GetColor("SubText")
                t.IconLabel.ImageColor3 = Theme.GetColor("SubText")
                t.Content.Visible = false
            end
            tabBtn.BackgroundColor3 = Theme.GetColor("Active")
            tabBtn.BackgroundTransparency = 0
            tabTitle.TextColor3 = Theme.GetColor("Text")
            tabIcon.ImageColor3 = Theme.GetColor("Text")
            tabContent.Visible = true
            activeTab = tabConfig.Title
        end

        tabBtn.MouseButton1Click:Connect(SelectThisTab)

        local tabData = {
            Button = tabBtn,
            TitleLabel = tabTitle,
            IconLabel = tabIcon,
            Content = tabContent,
            ScrollArea = scrollArea,
        }
        table.insert(tabs, tabData)

        -- If first tab, select it by default
        if #tabs == 1 then
            SelectThisTab()
        end

        local tabHandle = {
            Select = SelectThisTab,
            Container = scrollArea,
        }

        -- SubTab creation method
        function tabHandle:CreateSubTab(subConfig: { Title: string, Icon: string? })
            subTabsBar.Visible = true
            scrollArea.Position = UDim2.new(0, 0, 0, 42)
            scrollArea.Size = UDim2.new(1, 0, 1, -42)

            local subBtn = Instance.new("TextButton")
            subBtn.Name = "SubTab_" .. (subConfig.Title or "Sub")
            subBtn.BackgroundTransparency = 1
            subBtn.Size = UDim2.new(0, 0, 1, 0)
            subBtn.AutomaticSize = Enum.AutomaticSize.X
            subBtn.Text = ""
            subBtn.Parent = subTabsBar

            local subPad = Instance.new("UIPadding")
            subPad.PaddingLeft = UDim.new(0, 8)
            subPad.PaddingRight = UDim.new(0, 8)
            subPad.Parent = subBtn

            local subContent = Instance.new("Frame")
            subContent.BackgroundTransparency = 1
            subContent.Size = UDim2.new(1, 0, 1, 0)
            subContent.Visible = false
            subContent.Parent = scrollArea

            local subLayout = Instance.new("UIListLayout")
            subLayout.SortOrder = Enum.SortOrder.LayoutOrder
            subLayout.Padding = UDim.new(0, 8)
            subLayout.Parent = subContent

            -- SubTab Icon & Label
            local subIcon = Instance.new("ImageLabel")
            subIcon.BackgroundTransparency = 1
            subIcon.Position = UDim2.new(0, 0, 0.5, -8)
            subIcon.Size = UDim2.new(0, 16, 0, 16)
            subIcon.Image = Icons.Resolve(subConfig.Icon or "folder") or ""
            subIcon.ImageColor3 = Theme.GetColor("SubText")
            subIcon.Parent = subBtn

            local subTitle = Instance.new("TextLabel")
            subTitle.BackgroundTransparency = 1
            subTitle.Position = UDim2.new(0, 22, 0, 0)
            subTitle.Size = UDim2.new(0, 0, 1, 0)
            subTitle.AutomaticSize = Enum.AutomaticSize.X
            subTitle.Font = Theme.GetFont("Semibold")
            subTitle.Text = subConfig.Title or "SubTab"
            subTitle.TextColor3 = Theme.GetColor("SubText")
            subTitle.TextSize = 12
            subTitle.Parent = subBtn

            -- Active indicator underline
            local line = Instance.new("Frame")
            line.BackgroundColor3 = Color3.fromHex("#FAFAFA")
            line.BorderSizePixel = 0
            line.Size = UDim2.new(1, 0, 0, 2)
            line.Position = UDim2.new(0, 0, 1, -2)
            line.Visible = false
            line.Parent = subBtn

            local function SelectSub()
                for _, s in ipairs(subTabs) do
                    s.Title.TextColor3 = Theme.GetColor("SubText")
                    s.Icon.ImageColor3 = Theme.GetColor("SubText")
                    s.Line.Visible = false
                    s.Content.Visible = false
                end
                subTitle.TextColor3 = Theme.GetColor("Text")
                subIcon.ImageColor3 = Theme.GetColor("Text")
                line.Visible = true
                subContent.Visible = true
                activeSubTab = subConfig.Title
            end

            subBtn.MouseButton1Click:Connect(SelectSub)

            local sData = {
                Title = subTitle,
                Icon = subIcon,
                Line = line,
                Content = subContent,
            }
            table.insert(subTabs, sData)

            if #subTabs == 1 then
                SelectSub()
            end

            local subHandle = {
                Container = subContent,
                Select = SelectSub,
            }

            for key, fn in pairs(Components) do
                if type(fn) == "function" then
                    (subHandle :: any)[key] = function(self, compConfig)
                        return fn(subContent, compConfig)
                    end
                end
            end

            return subHandle
        end

        -- Directly attach component methods to tab
        for key, fn in pairs(Components) do
            if type(fn) == "function" then
                (tabHandle :: any)[key] = function(self, compConfig)
                    return fn(scrollArea, compConfig)
                end
            end
        end

        return tabHandle
    end

    -- Category separator helper for sidebar (e.g. "Examples v")
    local function AddCategory(title: string)
        local catFrame = Instance.new("Frame")
        catFrame.Name = "Category_" .. title
        catFrame.BackgroundTransparency = 1
        catFrame.Size = UDim2.new(1, 0, 0, 24)
        catFrame.Parent = tabListContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = catFrame

        local catChevron = Instance.new("ImageLabel")
        catChevron.BackgroundTransparency = 1
        catChevron.Position = UDim2.new(0, 0, 0.5, -6)
        catChevron.Size = UDim2.new(0, 12, 0, 12)
        catChevron.Image = Icons.Resolve("chevron-down") or ""
        catChevron.ImageColor3 = Theme.GetColor("SubText")
        catChevron.Parent = catFrame

        local catTitle = Instance.new("TextLabel")
        catTitle.BackgroundTransparency = 1
        catTitle.Position = UDim2.new(0, 18, 0, 0)
        catTitle.Size = UDim2.new(1, -18, 1, 0)
        catTitle.Font = Theme.GetFont("Semibold")
        catTitle.Text = title
        catTitle.TextColor3 = Theme.GetColor("SubText")
        catTitle.TextSize = 11
        catTitle.TextXAlignment = Enum.TextXAlignment.Left
        catTitle.Parent = catFrame
    end

    -- =========================================================================
    -- DRAGGING BEHAVIOR
    -- =========================================================================
    local dragging = false
    local dragStart = Vector2.zero
    local startPos = UDim2.new()

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- =========================================================================
    -- RESIZING BEHAVIOR (Bottom-Right Handle)
    -- =========================================================================
    local resizeGrip = Instance.new("ImageButton")
    resizeGrip.Name = "ResizeGrip"
    resizeGrip.BackgroundTransparency = 1
    resizeGrip.AnchorPoint = Vector2.new(1, 1)
    resizeGrip.Position = UDim2.new(1, -2, 1, -2)
    resizeGrip.Size = UDim2.new(0, 14, 0, 14)
    resizeGrip.Image = Icons.Resolve("chevron-down") or ""
    resizeGrip.Rotation = -45
    resizeGrip.ImageColor3 = Theme.GetColor("Outline")
    resizeGrip.ZIndex = 50
    resizeGrip.Parent = mainFrame

    local resizing = false
    local resizeStart = Vector2.zero
    local initialSizeVec = Vector2.zero

    resizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = Vector2.new(input.Position.X, input.Position.Y)
            initialSizeVec = Vector2.new(mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStart
            local newW = math.clamp(initialSizeVec.X + delta.X, minSize.X, maxSize.X)
            local newH = math.clamp(initialSizeVec.Y + delta.Y, minSize.Y, maxSize.Y)
            mainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    -- =========================================================================
    -- OPEN BUTTON (Floating trigger when window is hidden/minimized)
    -- =========================================================================
    local openBtn = Instance.new("ImageButton")
    openBtn.Name = "WindUI_OpenButton"
    openBtn.AnchorPoint = Vector2.new(0, 0.5)
    openBtn.Position = UDim2.new(0, 16, 0.5, 0)
    openBtn.Size = UDim2.new(0, 44, 0, 44)
    openBtn.BackgroundColor3 = Theme.GetColor("Background")
    openBtn.BorderSizePixel = 0
    openBtn.Image = iconId or ""
    openBtn.ImageColor3 = Theme.GetColor("Text")
    openBtn.Visible = false
    openBtn.ZIndex = 999
    openBtn.Parent = screenGui

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 12)
    openCorner.Parent = openBtn

    local openStroke = Instance.new("UIStroke")
    openStroke.Color = Theme.GetColor("Outline")
    openStroke.Thickness = 1
    openStroke.Parent = openBtn

    local isWindowVisible = true

    local function ToggleWindow()
        isWindowVisible = not isWindowVisible
        mainFrame.Visible = isWindowVisible
        openBtn.Visible = not isWindowVisible
    end

    minBtn.MouseButton1Click:Connect(ToggleWindow)
    closeBtn.MouseButton1Click:Connect(ToggleWindow)
    openBtn.MouseButton1Click:Connect(ToggleWindow)

    return {
        Instance = mainFrame,
        CreateTab = CreateTab,
        AddCategory = AddCategory,
        Toggle = ToggleWindow,
        Destroy = function(self)
            mainFrame:Destroy()
            openBtn:Destroy()
        end
    }
end

return MainUI
