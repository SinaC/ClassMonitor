-- Credits to Tukz (ripped from Tukui)

local ADDON_NAME, Engine = ...
if not Engine.Enabled then return end

local L = Engine.Locales

-- Communicate to other players through our AddOn
local LocalVersion = GetAddOnMetadata(ADDON_NAME, "Version")
local PlayerName = select(1, UnitName("player"))
local MessagePrefix = "CMVersion"
local SendAddonMessage = SendAddonMessage

local function SplitVersion(version)
	local major, minor, build, revision = strsplit(".", version, 4)
	return tonumber(major or 0), tonumber(minor or 0), tonumber(build or 0), tonumber(revision or 0)
end

local function CompareVersion(remoteVersion)
	local major, minor, build, revision = SplitVersion(LocalVersion)
	local remoteMajor, remoteMinor, remoteBuild, remoteRevision = SplitVersion(remoteVersion)

	if remoteMajor > major then return 1
	elseif remoteMajor < major then return -1
	elseif remoteMinor > minor then return 1
	elseif remoteMinor < minor then return -1
	elseif remoteBuild > build then return 1
	elseif remoteBuild < build then return -1
	elseif remoteRevision > revision then return 1
	elseif remoteRevision < revision then return -1
	else return 0 end
end

--
local function CheckVersion(self, event, prefix, message, channel, sender)
--print("CheckVersion:"..tostring(event).."  "..tostring(prefix).."  "..tostring(message).."  "..tostring(channel).."  "..tostring(sender))
	if event == "CHAT_MSG_ADDON" then
		if (prefix ~= MessagePrefix) or (sender == PlayerName) then 
			return
		end
		if (CompareVersion(message) == 1 ) then -- We received a higher version, we're outdated. :(
			print("|cffffff00"..L.classmonitor_outdated.."|r")
			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		-- Tell everyone what version we use.
		local bg = UnitInBattleground("player")
		if bg and bg > 0 then
			SendAddonMessage(MessagePrefix, LocalVersion, "BATTLEGROUND")
		elseif UnitInRaid("player") then
			SendAddonMessage(MessagePrefix, LocalVersion, "RAID") 
		elseif UnitInParty("player") then
			SendAddonMessage(MessagePrefix, LocalVersion, "PARTY")
		elseif IsInGuild() then
			SendAddonMessage(MessagePrefix, LocalVersion, "GUILD")
		end
	end
end

local ClassMonitorVersionFrame = CreateFrame("Frame")
ClassMonitorVersionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ClassMonitorVersionFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
ClassMonitorVersionFrame:RegisterEvent("CHAT_MSG_ADDON")
ClassMonitorVersionFrame:SetScript("OnEvent", CheckVersion)

RegisterAddonMessagePrefix(MessagePrefix)