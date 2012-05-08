-- Mover plugin
local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local movingframe = CreateFrame("Frame", "movingframe", UIParent) -- Ice Block / smoke / ShS...
movingframe:CreatePanel("Transparent", 200, 15,"CENTER", "UIParent" , "CENTER", 0, -100)
movingframe:SetMovable(true)
movingframe:SetBackdropBorderColor(RAID_CLASS_COLORS[T.myclass].r,RAID_CLASS_COLORS[T.myclass].g,RAID_CLASS_COLORS[T.myclass].b)
movingframe:SetFrameLevel(2)
movingframe:SetFrameStrata("HIGH")
movingframe.text = T.SetFontString(movingframe, C.media.uffont, 12)
movingframe.text:SetPoint("CENTER")
movingframe.text:SetText("Move iClassMonitor")
movingframe:Hide()

local function exec(self, enable)
	if enable then
		self:Show()
	else
		self:Hide()
	end
end

local enable = true
local origa1, origf, origa2, origx, origy

local function moving()
	-- don't allow moving while in combat
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	
	if enable then			
		movingframe:EnableMouse(true)
		movingframe:RegisterForDrag("LeftButton", "RightButton")
		movingframe:SetScript("OnDragStart", function(self) 
			origa1, origf, origa2, origx, origy = movingframe:GetPoint() 
			self.moving = true 
			self:SetUserPlaced(true) 
			self:StartMoving() 
		end)			
		movingframe:SetScript("OnDragStop", function(self) 
			self.moving = false 
			self:StopMovingOrSizing() 
		end)			
		exec(movingframe, enable)			
		if movingframe.text then 
			movingframe.text:Show() 
		end
	else			
		movingframe:EnableMouse(false)
		if movingframe.moving == true then
			movingframe:StopMovingOrSizing()
			movingframe:ClearAllPoints()
			movingframe:SetPoint(origa1, origf, origa2, origx, origy)
		end
		exec(movingframe, enable)
		if movingframe.text then movingframe.text:Hide() end
		movingframe.moving = false
	end
	
	if enable then enable = false else enable = true end
end

SLASH_MOVINGICLASSMONITOR1 = "/mcm"
SlashCmdList["MOVINGICLASSMONITOR"] = moving

local protection = CreateFrame("Frame")
protection:RegisterEvent("PLAYER_REGEN_DISABLED")
protection:SetScript("OnEvent", function(self, event)
	if enable then return end
	print(ERR_NOT_IN_COMBAT)
	enable = false
	moving()
end)

local function positionsetup()
	-- reset movable stuff into original position
	if movingframe then movingframe:SetUserPlaced(false) end
	ReloadUI()
end

SLASH_RESETICLASSMONITOR1 = "/rcm"
SlashCmdList.RESETICLASSMONITOR = positionsetup

-- Make it move when clicking on the tukui's moveui command. =D
hooksecurefunc(_G.SlashCmdList, "MOVING", moving)