-------------------------------------
------離開和進入戰鬥,大文字提示------
-------------------------------------

local _, ns = ...

-- ====================
-- 用户配置区
-- ====================
ns.setting = {
    EnableCombat = true,          -- 插件总开关（禁用:false/启用:true）
    EnableIcons = true,           -- 图标总开关（禁用:false/启用:true）
    EnableTopIcon = true,         -- 职业图标开关（禁用:false/启用:true）
    EnableFactionIcons = true,    -- 两侧阵营图标开关（禁用:false/启用:true）
    classIconSize = {100, 100},   -- 职业图标尺寸[宽,高]
    classIconOffset = {0, 15},    -- 职业图标偏移[X,Y]
    classIconAlpha = 0.6,         -- 职业图标透明度（0-1）
    FactionIconAlpha = 1.0,       -- 阵营图标透明度（0-1）
    EnterColor = {1, 0.2, 0.2},   -- 进入战斗颜色
    LeaveColor = {0.3, 1, 0.3},   -- 脱离战斗颜色
    IconSize = {60, 60},          -- 两侧图标尺寸
    IconOffset = {-4, 3},         -- 两侧图标间距
    TextOffset = {0, 3},          -- 文字偏移
    FrameScale = 0.8,             -- 整体缩放
    ClassIconPath = "Interface\\AddOns\\CombatAlert\\Media\\fabledrealmv2"   --职业图标Media文件内有其他样式。
}

ns.texts = {
    EnterCombat = {
    " 戰  鬥  開  始 "
    },
    LeaveCombat = {
    " 脫  離  戰  鬥 "
    },
}

-- 职业图标纹理坐标
ns.class = {
    WARRIOR     = {0, 0.125, 0, 0.125},
    MAGE        = {0.125, 0.25, 0, 0.125},
    ROGUE       = {0.25, 0.375, 0, 0.125},
    DRUID       = {0.375, 0.5, 0, 0.125},
    EVOKER      = {0.5, 0.625, 0, 0.125},
    HUNTER      = {0, 0.125, 0.125, 0.25},
    SHAMAN      = {0.125, 0.25, 0.125, 0.25},
    PRIEST      = {0.25, 0.375, 0.125, 0.25},
    WARLOCK     = {0.375, 0.5, 0.125, 0.25},
    PALADIN     = {0, 0.125, 0.25, 0.375},
    DEATHKNIGHT = {0.125, 0.25, 0.25, 0.375},
    MONK        = {0.25, 0.375, 0.25, 0.375},
    DEMONHUNTER = {0.375, 0.5, 0.25, 0.375},
}

-- ====================
-- 核心代码
-- ====================
local MyAddon = CreateFrame("Frame")
local imsg = CreateFrame("Frame", "CombatAlert")
imsg:SetSize(460, 85)
imsg:SetPoint("TOP", 0, -250) --位置
imsg:Hide()

-- 图形元素初始化
do
    -- 装饰线
    imsg.line = imsg:CreateTexture(nil, 'BACKGROUND')
    imsg.line:SetTexture([[Interface\QuestFrame\BonusObjectives]])
    imsg.line:SetPoint("CENTER")
    imsg.line:SetSize(460, 85)
    imsg.line:SetTexCoord(0.00195312, 0.818359, 0.359375, 0.507812)

    -- 职业图标
    imsg.icon = imsg:CreateTexture(nil, 'ARTWORK')
    imsg.icon:SetSize(ns.setting.classIconSize[1], ns.setting.classIconSize[2])
    imsg.icon:SetPoint("CENTER", 0, ns.setting.classIconOffset[2])
    imsg.icon:SetAlpha(ns.setting.classIconAlpha)
    imsg.icon:Hide()

    -- 提示文字
    imsg.text = imsg:CreateFontString(nil, 'OVERLAY', 'GameFont_Gigantic')
    imsg.text:SetPoint("CENTER", ns.setting.TextOffset[1], ns.setting.TextOffset[2])
    imsg.text:SetJustifyH("CENTER")
    imsg.text:SetFont(STANDARD_TEXT_FONT, 40, "THICKOUTLINE")

    -- 两侧阵营图标
    if ns.setting.EnableFactionIcons then
        local faction = UnitFactionGroup("player")
        local factionIcon = faction == "Alliance" and 
            [[Interface\FriendsFrame\PlusManz-Alliance]] or 
            [[Interface\FriendsFrame\PlusManz-Horde]]

        imsg.iconLeft = imsg:CreateTexture(nil, 'OVERLAY')
        imsg.iconLeft:SetTexture(factionIcon)
        imsg.iconLeft:SetSize(ns.setting.IconSize[1], ns.setting.IconSize[2])
        imsg.iconLeft:SetPoint("RIGHT", imsg.text, "LEFT", -ns.setting.IconOffset[1], ns.setting.IconOffset[2])
        imsg.iconLeft:Hide()

        imsg.iconRight = imsg:CreateTexture(nil, 'OVERLAY')
        imsg.iconRight:SetTexture(factionIcon)
        imsg.iconRight:SetSize(ns.setting.IconSize[1], ns.setting.IconSize[2])
        imsg.iconRight:SetPoint("LEFT", imsg.text, "RIGHT", ns.setting.IconOffset[1], ns.setting.IconOffset[2])
        imsg.iconRight:SetTexCoord(1, 0, 0, 1)
        imsg.iconRight:Hide()
    end
end

-- 显示提示信息
local function ShowAlert(texts, color)
    if not ns.setting.EnableCombat then return end
    
    local text = texts[math.random(1, #texts)]
    imsg.text:SetText(text)
    imsg.text:SetTextColor(unpack(color))
    
    -- 职业图标逻辑
    if ns.setting.EnableIcons and ns.setting.EnableTopIcon then
        local _, playerClass = UnitClass("player")
        local coords = ns.class[playerClass]
        if coords then
            imsg.icon:SetTexture(ns.setting.ClassIconPath)
            imsg.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            imsg.icon:Show()
        end
    else
        imsg.icon:Hide()
    end

    -- 两侧阵营图标逻辑
    if ns.setting.EnableIcons and ns.setting.EnableFactionIcons then
        imsg.iconLeft:SetAlpha(ns.setting.FactionIconAlpha)
        imsg.iconRight:SetAlpha(ns.setting.FactionIconAlpha)
        imsg.iconLeft:Show()
        imsg.iconRight:Show()
    else
        if imsg.iconLeft then imsg.iconLeft:Hide() end
        if imsg.iconRight then imsg.iconRight:Hide() end
    end

    -- 动态调整框架宽度
    local frameWidth = imsg.text:GetStringWidth() + 100
    if ns.setting.EnableIcons and ns.setting.EnableFactionIcons then
        frameWidth = frameWidth + (ns.setting.IconSize[1] * 2) + (ns.setting.IconOffset[1] * 2)
    end
    imsg:SetWidth(frameWidth)
    imsg.line:SetWidth(frameWidth)
    
    imsg:Show()
end

-- 动画效果
local timer = 0
imsg:SetScript("OnShow", function(self)
    self:SetAlpha(1)
    timer = 0
    self:SetScript("OnUpdate", function(_, elapsed)
        timer = timer + elapsed
        if timer < 3 then
            self:SetAlpha(1)
        elseif timer < 3.5 then
            self:SetAlpha((3.5 - timer) / 0.5)
        else
            self:Hide()
        end
    end)
end)

-- 事件处理
MyAddon:RegisterEvent("PLAYER_REGEN_ENABLED")
MyAddon:RegisterEvent("PLAYER_REGEN_DISABLED")

MyAddon:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        ShowAlert(ns.texts.EnterCombat, ns.setting.EnterColor)
    elseif event == "PLAYER_REGEN_ENABLED" then
        ShowAlert(ns.texts.LeaveCombat, ns.setting.LeaveColor)
    end
end)

-- 应用全局缩放
imsg:SetScale(ns.setting.FrameScale)
