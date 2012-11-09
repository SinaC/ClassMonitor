-- Credits to Tukz (ripped from Tukui)

local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local L = Engine.Locales

-- Communicate to other players through our AddOn
local tonumber = tonumber
local Version = tonumber(GetAddOnMetadata(ADDON_NAME, "Version"))
local SendAddonMessage = SendAddonMessage
local playerName = select(1, UnitName("player"))

--
local CheckVersion = function(self, event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if (prefix ~= "ClassMonitorVersion") or (sender == playerName) then 
			return
		end
		
		if (tonumber(message) > Version) then -- We recieved a higher version, we're outdated. :(
			print("|cffffff00"..L.classmonitor_outdated.."|r")
			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		-- Tell everyone what version we use.
		local bg = UnitInBattleground("player")
		if bg and bg > 0 then
			SendAddonMessage("ClassMonitorVersion", Version, "BATTLEGROUND")
		elseif UnitInRaid("player") then
			SendAddonMessage("ClassMonitorVersion", Version, "RAID") 
		elseif UnitInParty("player") then
			SendAddonMessage("ClassMonitorVersion", Version, "PARTY")
		elseif IsInGuild() then
			SendAddonMessage("ClassMonitorVersion", Version, "GUILD")
		end
	end
end

local ClassMonitorVersionFrame = CreateFrame("Frame")
ClassMonitorVersionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ClassMonitorVersionFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
ClassMonitorVersionFrame:RegisterEvent("CHAT_MSG_ADDON")
ClassMonitorVersionFrame:SetScript("OnEvent", CheckVersion)

RegisterAddonMessagePrefix("ClassMonitorVersion")
