--------------------------------------------
------小地图显示副本难度-代码来自：EK的EKMinimap
--------------------------------------------
local G = {}
G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
G.Diff = "Interface\\Addons\\CombatAlert\\Media\\difficulty.tga"
G.font = STANDARD_TEXT_FONT
G.fontSize = 10  --字体大小
G.fontFlag = "OUTLINE"
 
local F = {}
F.CreateFS = function(parent, text, fontsize, justify, anchor, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(G.font, fontsize, G.fontFlag)
    fs:SetText(text)
    fs:SetShadowOffset(0, 0)
    fs:SetWordWrap(false)
    fs:SetJustifyH(justify)
    if anchor and x and y then
        fs:SetPoint(anchor, x, y)
    else
        fs:SetPoint("CENTER", 0, 0)
    end
 
    return fs
end
 
local instDifficulty = _G.MinimapCluster.InstanceDifficulty
instDifficulty:UnregisterAllEvents()
instDifficulty:Hide()
instDifficulty.Show = function() end
 
local Diff = CreateFrame("Frame", "EKMinimapDungeonIcon", Minimap)
	Diff:SetSize(46, 46)
	Diff:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Diff:SetPoint("TOPRIGHT", Minimap, 5, 5)  --位置
	Diff.Texture = Diff:CreateTexture(nil, "OVERLAY")
	Diff.Texture:SetAllPoints(Diff)
	Diff.Texture:SetTexture("Interface\\Addons\\CombatAlert\\Media\\difficulty.tga")
	Diff.Texture:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	Diff.Text = F.CreateFS(Diff, "", G.fontSize + 4, "CENTER")
 
local function styleDifficulty(self)
    -- Difficulty Text / 難度文字
    local DiffText = self.Text
 
    local inInstance, instanceType = IsInInstance()
    local difficulty = select(3, GetInstanceInfo())
    local num = select(9, GetInstanceInfo())
    local mplus = select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or ""
	local DifficultyTAG = {
		-- https://warcraft.wiki.gg/wiki/DifficultyID
		[1] = "5N",
		[2] = "5H",
		[3] = "10N",
		[4] = "25N",
		[5] = "10H",		    -- 10（英雄）
		[6] = "25H",            -- 25（英雄）
		[7] = "随机",			    -- 随机
		[8] = "秘境" .. mplus,	-- 史诗+（M+）
		[9] = "40",
		[11] = "3H",		-- 场景（英雄-MOP）
		[12] = "3N",		-- 场景（普通-MOP）
		[14] = num .. "普通",	-- 普通团本（N）
		[15] = num .. "英雄",	-- 英雄团本（H）
		[16] = "史诗",			-- 史诗团本（M）
		[17] = num .. "随机",	-- 随机团本（L）
		[18] = "E",			-- 事件（团队）
		[19] = "E",			-- 事件（地城）
		[20] = "E",			-- 事件（场景）
	
		[23] = "5M",        -- 史诗（地城）
		[24] = "T",			-- 时空漫游（地城）
		[25] = "PVP",
		[29] = "PEP",
		[30] = "E",			-- 事件
		[32] = "PVP",
		[33] = "T+",		-- 时空漫游（团队）
		[34] = "PVP",
		[38] = "3N",		-- 普通海岛（BFA）
		[39] = "3H",		-- 英雄海岛（BFA）
		[40] = "3M",		-- 史诗海岛（BFA）
		[45] = "PVP",		-- 海岛（BFA）
		
		[147] = "WF",		-- 战争前线
		[149] = "HWF",		-- 战争前线（英雄）
		[151] = "T",		-- 随机团本（时光）
		[152] = "幻象",		-- 幻象（E）
		[153] = "10",		-- 海岛（10）
		-- 168/169/170/171 晉升之路
		[167] = "TOR",		-- 托加斯特
		[205] = "F",		-- 追随者
		[208] = "De"			-- 地下堡 delve（D）
	}
 
    if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		DiffText:SetText(DifficultyTAG[difficulty] or "D")
    elseif instanceType == "pvp" or instanceType == "arena" then
        DiffText:SetText("PVP")
    else
        DiffText:SetText("D")
    end
 
    if not inInstance then
        Diff:SetAlpha(0)
    else
        Diff:SetAlpha(1)
    end
end
 
Diff:RegisterEvent("PLAYER_ENTERING_WORLD")
Diff:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
Diff:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
Diff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Diff:RegisterEvent("CHALLENGE_MODE_START")
Diff:RegisterEvent("CHALLENGE_MODE_COMPLETED")
Diff:RegisterEvent("CHALLENGE_MODE_RESET")
Diff:SetScript("OnEvent", styleDifficulty)
