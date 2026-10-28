# WindUI Reborn — Modular Luau UI Library
**Version:** 2.9.0-modular  
**Style:** Monochrome Dark Acrylic / Glassmorphism  
**Target Environment:** Roblox Luau (Roblox Studio & Universal Script Executors)

WindUI Reborn is a high-performance, modular Roblox GUI library crafted for smooth interactions, modern monochrome aesthetic, reactive themes, and mobile-friendly layouts.

---

## 📁 Repository Structure

```
windui/
├── main.lua                # Public entry point and module coordinator
├── bundle.lua              # All-in-one standalone distribution bundle
├── example.lua             # Complete showcase reproducing reference design
├── UI/
│   ├── MainUI.lua          # Window, tabs, subtabs, profile card, drag & resize
│   ├── Components.lua      # Button, Toggle, Slider, Dropdown, Input, Keybind, etc.
│   ├── Icons.lua           # Lucide icon resolver and Roblox asset mapping
│   └── Notify.lua          # Stacked notification system with progress bars
├── System/
│   ├── Environment.lua     # Defensive GUI parenting (gethui, CoreGui, PlayerGui)
│   └── Theme.lua           # Reactive monochrome theme engine and switching
└── README.md
```

---

## 🚀 Quick Start / Loader

### Single-File Loader (Universal)
```lua
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/windui/main/bundle.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Vind Ui Reborn",
    Author = "Complete Showcase · v2.9.0-modular",
    Icon = "sparkles",
    Profile = {
        Username = "SkFOrest",
        Handle = "@luis_akz4",
        Avatar = "rbxassetid://10709799567",
    }
})
```

### Modular Studio Usage
If placed in `ReplicatedStorage/WindUI`:
```lua
local WindUI = require(game:GetService("ReplicatedStorage").WindUI.main)
```

---

## 🎨 Themes & Custom Themes

The primary default theme is **Monochrome** (#101010 background, #141416 card, #27272A outline, #FFFFFF text).

```lua
-- Change theme dynamically (smoothly tweens all existing elements)
WindUI:SetTheme("Dark") -- "Monochrome" | "Dark" | "Midnight" | "Light"

-- Register custom theme
WindUI:AddTheme({
    Name = "Onyx",
    Background = Color3.fromHex("#0C0A09"),
    Card = Color3.fromHex("#1C1917"),
    Accent = Color3.fromHex("#292524"),
    Active = Color3.fromHex("#44403C"),
    Outline = Color3.fromHex("#292524"),
    Text = Color3.fromHex("#FAFAF9"),
    SubText = Color3.fromHex("#A8A29E"),
    Placeholder = Color3.fromHex("#78716C"),
    Button = Color3.fromHex("#292524"),
    Icon = Color3.fromHex("#A8A29E"),
})
```

---

## 🧭 Window & Navigation

```lua
local Window = WindUI:CreateWindow({
    Title = "My Hub",
    Author = "by Developer",
    Icon = "door-open",
})

-- Sidebar Tab
local Tab = Window:CreateTab({
    Title = "General",
    Icon = "house",
})

-- Category separator in sidebar
Window:AddCategory("Combat Modules")

-- SubTabs within a Tab (pill navigation bar)
local AutoFarmSub = Tab:CreateSubTab({
    Title = "Auto Farm",
    Icon = "sprout",
})
```

---

## 🧩 Component Examples

### 1. Button
```lua
Tab:Button({
    Title = "Execute Action",
    Description = "Runs the primary script function.",
    Icon = "play",
    Callback = function()
        print("Action executed!")
    end,
})
```

### 2. Toggle (Pill Switch)
```lua
local toggleHandle = Tab:Toggle({
    Title = "Enable Auto Farm",
    Description = "Automatically engages nearby targets.",
    Value = false,
    Callback = function(enabled)
        print("Toggle state:", enabled)
    end,
})

toggleHandle:SetValue(true)
```

### 3. Slider
```lua
local sliderHandle = Tab:Slider({
    Title = "Intensity",
    Value = {
        Min = 0,
        Max = 100,
        Default = 50,
        Step = 1,
    },
    Callback = function(value)
        print("Intensity:", value)
    end,
})
```

### 4. Dropdown
```lua
local dropdownHandle = Tab:Dropdown({
    Title = "Target Mode",
    Values = { "Nearest", "Highest Level", "Lowest Health" },
    Value = "Nearest",
    Callback = function(selected)
        print("Mode selected:", selected)
    end,
})
```

### 5. Input
```lua
Tab:Input({
    Title = "Player Filter",
    Placeholder = "Enter username...",
    Default = "",
    Callback = function(text)
        print("Filter query:", text)
    end,
})
```

### 6. Keybind
```lua
Tab:Keybind({
    Title = "Toggle Interface",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window:Toggle()
    end,
})
```

### 7. Section (Collapsible Group)
```lua
local GeneralSection = Tab:Section({
    Title = "General Settings",
    Collapsible = true,
    DefaultCollapsed = false,
})

-- Add child components inside the section
GeneralSection:Toggle({ Title = "Auto Collect", Value = true })
GeneralSection:Dropdown({ Title = "Speed", Values = {"Normal", "Fast"} })
```

### 8. Expandable Row
```lua
local Advanced = Tab:Expandable({
    Title = "Advanced Configuration",
    DefaultExpanded = false,
})

Advanced:Slider({ Title = "Raycast Distance", Value = { Min = 10, Max = 300, Default = 100 } })
```

### 9. Colorpicker
```lua
Tab:Colorpicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(34, 197, 94),
    Callback = function(color)
        print("Color changed:", color)
    end,
})
```

### 10. Paragraph
```lua
Tab:Paragraph({
    Title = "Changelog v2.9.0",
    Content = "Added sub-tabs, responsive resizing, reactive themes, and touch dragging.",
})
```

---

## 🔔 Notifications

```lua
WindUI:Notify({
    Title = "Success",
    Content = "Settings saved to local storage.",
    Icon = "check",
    Duration = 4,
    Type = "Success", -- "Success" | "Warning" | "Error" | "Info"
})
```

---

## 🛡️ Environment & Security
- Safely checks for `gethui()` via protected call `pcall`.
- Safe fallback to `CoreGui` or `PlayerGui`.
- Clean singleton management with 32-byte safe hex instance naming and automatic cleanup of previous runs to prevent duplicate UI instances.
