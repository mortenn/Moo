--
-- [[ SECTION START: Chat Bubble Debugging ]]
--

local events = {
	CHAT_MSG_SAY = "chatBubbles", CHAT_MSG_YELL = "chatBubbles",
	CHAT_MSG_PARTY = "chatBubblesParty", CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
	CHAT_MSG_MONSTER_SAY = "chatBubbles", CHAT_MSG_MONSTER_YELL = "chatBubbles", CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
};

-- Locate the chat bubble with a specific message and return it.
local function LocateChatBubble(message)
	local frames = { WorldFrame:GetChildren() };
	for i, frame in ipairs(frames) do
		if not frame:GetName() and frame:GetNumRegions() == 11 then
			if not frame.text then
				-- Search for the font string containing the message.
				for i = 1, select("#", frame:GetRegions()) do
					local region = select(i, frame:GetRegions())
					if region:GetObjectType() == "FontString" then
						if region:GetText() == message then
							frame.text = region;
						end
					end
				end
			end

			return frame;
		end
	end
	return nil;
end

local function HijackChatBubble(bubble, senderGUID, sender)
	
end

local e = CreateFrame("FRAME");
for event, cvar in pairs(events) do e:RegisterEvent(event); end

e:SetScript("OnEvent", function(self, event, msg, sender, _, _, _, _, _, _, _, _, _, guid)
	if GetCVarBool(events[event]) then
		e.elapsed = 0
		e:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed;
			local frame = LocateChatBubble(msg);
			if frame or self.elapsed > 0.3 then
				e:SetScript("OnUpdate", nil)
				if frame then
					HijackChatBubble(frame, guid, sender)
				end
			end
		end);
	end
end);


					--frame.text = region;
					--region:SetText("This is a pretty long sentence that I am checking to see how the custom text inside a chat bubble is wrapped.");
					--region:SetWidth(344);

					--if region:GetStringWidth() < 344 then
					--	region:SetWidth(region:GetStringWidth());
					--end
					--frame:SetWidth(region:GetStringWidth());

--/run SendChatMessage("Test"); test_bubble();

--
-- [[ SECTION END: Chat Bubble Debugging ]]
--



--
-- [[ SECTION START: TMU Costume Presets ]]
--
TMU_COSTUMES = {
	["starman"] = {
		["morph"] = 45941
	},

	["windrunner"] = {
		["morph"] = 28213
	},

	["pirate"] = {
		["morph"] = 26991,
		[16] = 118083,
		[17] = 1557
	},

	["zaela"] = {
		["morph"] = 54683,
		[16] = 112787,
		[17] = 111221
	},

	["felorc"] = {
		["morph"] = 64162
	}
};
--
-- [[ SECTION END: TMU Costume Presets ]]
--

--
-- [[ SECTION START: LDF Join Tool ]]
--
local LFD_Frame = CreateFrame("FRAME");
local LFD_Target = nil;
local LFD_Groups = {};

-- Register events
LFD_Frame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");

LFD_Frame.TimeSinceLastUpdate = 0;
LFD_Frame:SetScript("OnUpdate", function(self, elapsed)
	-- If we have no active target, abort.
	if LFD_Target == nil or UnitInParty("player") or UnitInRaid("player") then
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	-- Scan for new groups every 5 seconds.
	if self.TimeSinceLastUpdate > 5 then
		C_LFGList.Search(6, "", LFGListFrame.SearchPanel.filters, LFGListFrame.SearchPanel.preferredFilters, C_LFGList.GetLanguageSearchFilter());
		self.TimeSinceLastUpdate = 0; -- Reset our timer.
	end
end);

LFD_Frame:SetScript("OnEvent", function(self, event, ...)
	local unit = ...;

	if UnitInParty("player") or UnitInRaid("player") then
		return;
	end

	if event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" and LFD_Target ~= nil then
		local numResults, results = C_LFGList.GetSearchResults();
		LFGListUtil_SortSearchResults(results);

		for k, v in pairs(results) do
			local id, activityID, name, comment, voiceChat, iLvl, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted = C_LFGList.GetSearchResultInfo(results[k]);
			if LFD_Groups[id] == nil then
				-- Check our filter exists in the name.
				if string.match(string.lower(name), LFD_Target) then
					print("Applying to join found group: " .. name);
					C_LFGList.ApplyToGroup(id, "", true, false, false);
				end
				LFD_Groups[id] = true;
			end
		end
	end
end);

SLASH_PMG1 = '/pmg';
function SlashCmdList.PMG(msg, editbox)
	if msg == "off" then
		LFD_Target = nil;
		print("Standing down... for now.");
	else
		LFD_Target = string.lower(msg);
		print("Searching for groups with filter: " .. msg);
	end
end

--
-- [[ SECTION END: LFD Join Tool ]]
--

--
-- [[ SECTION START: Primal Spirit Auto-Greed ]]
--
local lootFrame = CreateFrame("FRAME");
lootFrame.TimeSinceLastUpdate = 0;
lootFrame:SetScript("OnUpdate", function(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 

	if (self.TimeSinceLastUpdate > 1) then
		if UnitInParty("player") or UnitInRaid("player") then

			for i = 1, 5 do
				local lootFrame = _G["GroupLootFrame" .. i];
				if lootFrame ~= nil and lootFrame:IsShown() then
					if string.match(lootFrame.Name:GetText(), "Primal Spirit") then
						DEFAULT_CHAT_FRAME:AddMessage("Automatically greeding on Primal Spirit.", 0, 1, 0);
						if StaticPopup1 ~= nil and StaticPopup1:IsShown() then
							lootFrame.GreedButton:Click();
						else
							lootFrame.GreedButton:Click();
							StaticPopup1Button1:Click();
						end
					end
				end
			end

			if StaticPopup1 ~= nil and StaticPopup1:IsShown() then
				if string.match(StaticPopup1Text:GetText(), "Primal Spirit") then
					StaticPopup1Button1:Click();
				end
			end
		end
		self.TimeSinceLastUpdate = 0;
	end
end);
--
-- [[ SECTION END: Primal Spirit Auto-Greed ]]
--

--
-- [[ SECTION START: IsInTrade Util Func ]]
--
local function isInTrade()
	local channelID, channelName = GetChannelName(2);
	return channelID > 0;
end
--
-- [[ SECTION END: IsInTrade Util Func ]]
--


--
-- [[ SECTION START: Zone Level Look-up Command ]]
--
local zone_data = {
	["Gilneas City"] = { ["low"] = 1, ["high"] = 5 },
	["Kezan"] = { ["low"] = 1, ["high"] = 5 },
	["Azuremyst Isle"] = { ["low"] = 1, ["high"] = 10 },
	["Dun Morogh"] = { ["low"] = 1, ["high"] = 10 },
	["Durotar"] = { ["low"] = 1, ["high"] = 10 },
	["Elwynn Forest"] = { ["low"] = 1, ["high"] = 10 },
	["Eversong Woods"] = { ["low"] = 1, ["high"] = 10 },
	["Mulgore"] = { ["low"] = 1, ["high"] = 10 },
	["Teldrassil"] = { ["low"] = 1, ["high"] = 10 },
	["Tirisfal Glades"] = { ["low"] = 1, ["high"] = 10 },
	["Wandering Isle"] = { ["low"] = 1, ["high"] = 10 },
	["Gilneas"] = { ["low"] = 5, ["high"] = 10 },
	["Lost Isles"] = { ["low"] = 5, ["high"] = 10 },
	["Westfall"] = { ["low"] = 10, ["high"] = 15 },
	["Azshara"] = { ["low"] = 10, ["high"] = 20 },
	["Bloodmyst Isle"] = { ["low"] = 10, ["high"] = 20 },
	["Darkshore"] = { ["low"] = 10, ["high"] = 20 },
	["Ghostlands"] = { ["low"] = 10, ["high"] = 20 },
	["Loch Modan"] = { ["low"] = 10, ["high"] = 20 },
	["Northern Barrens"] = { ["low"] = 10, ["high"] = 20 },
	["Silverpine Forest"] = { ["low"] = 10, ["high"] = 20 },
	["Ruins of Gilneas"] = { ["low"] = 10, ["high"] = 20 },
	["Redridge Mountains"] = { ["low"] = 15, ["high"] = 20 },
	["Ashenvale"] = { ["low"] = 20, ["high"] = 25 },
	["Duskwood"] = { ["low"] = 20, ["high"] = 25 },
	["Hillsbrad Foothills"] = { ["low"] = 20, ["high"] = 25 },
	["Wetlands"] = { ["low"] = 20, ["high"] = 25 },
	["Arathi Highlands"] = { ["low"] = 25, ["high"] = 30 },
	["Northern Stranglethorn"] = { ["low"] = 25, ["high"] = 30 },
	["Stonetalon Mountains"] = { ["low"] = 25, ["high"] = 30 },
	["Cape of Stranglethorn"] = { ["low"] = 30, ["high"] = 35 },
	["Desolace"] = { ["low"] = 30, ["high"] = 35 },
	["Hinterlands"] = { ["low"] = 30, ["high"] = 35 },
	["Southern Barrens"] = { ["low"] = 30, ["high"] = 35 },
	["Dustwallow Marsh"] = { ["low"] = 35, ["high"] = 40 },
	["Feralas"] = { ["low"] = 35, ["high"] = 40 },
	["Western Plaguelands"] = { ["low"] = 35, ["high"] = 40 },
	["Eastern Plaguelands"] = { ["low"] = 40, ["high"] = 45 },
	["Thousand Needles"] = { ["low"] = 40, ["high"] = 45 },
	["Badlands"] = { ["low"] = 44, ["high"] = 48 },
	["Felwood"] = { ["low"] = 45, ["high"] = 50 },
	["Tanaris"] = { ["low"] = 45, ["high"] = 50 },
	["Searing Gorge"] = { ["low"] = 47, ["high"] = 51 },
	["Burning Steppes"] = { ["low"] = 49, ["high"] = 52 },
	["Un'Goro Crater"] = { ["low"] = 50, ["high"] = 55 },
	["Winterspring"] = { ["low"] = 50, ["high"] = 55 },
	["Swamp of Sorrows"] = { ["low"] = 52, ["high"] = 54 },
	["Blasted Lands"] = { ["low"] = 54, ["high"] = 60 },
	["Scarlet Enclave"] = { ["low"] = 55, ["high"] = 58 },
	["Deadwind Pass"] = { ["low"] = 55, ["high"] = 60 },
	["Moonglade"] = { ["low"] = 55, ["high"] = 60 },
	["Silithus"] = { ["low"] = 55, ["high"] = 60 },
	["Hellfire Peninsula"] = { ["low"] = 58, ["high"] = 63 },
	["Zangarmarsh"] = { ["low"] = 60, ["high"] = 64 },
	["Terokkar Forest"] = { ["low"] = 62, ["high"] = 65 },
	["Nagrand"] = { ["low"] = 64, ["high"] = 67 },
	["Blade's Edge Mountains"] = { ["low"] = 65, ["high"] = 68 },
	["Netherstorm"] = { ["low"] = 67, ["high"] = 70 },
	["Shadowmoon Valley"] = { ["low"] = 67, ["high"] = 70 },
	["Deadwind Pass"] = { ["low"] = 68, ["high"] = 70 },
	["Isle of Quel'Danas"] = { ["low"]  = 70 },
	["Howling Fjord"] = { ["low"] = 68, ["high"] = 72 },
	["Borean Tundra"] = { ["low"] = 68, ["high"] = 72 },
	["Dragonblight"] = { ["low"] = 71, ["high"] = 75 },
	["Grizzly Hills"] = { ["low"] = 73, ["high"] = 75 },
	["Zul'Drak"] = { ["low"] = 74, ["high"] = 76 },
	["Sholazar Basin"] = { ["low"] = 76, ["high"] = 78 },
	["Crystalsong Forest"] = { ["low"] = 77, ["high"] = 80 },
	["Hrothgar's Landing"] = { ["low"] = 77, ["high"] = 80 },
	["Icecrown"] = { ["low"] = 77, ["high"] = 80 },
	["Storm Peaks"] = { ["low"] = 77, ["high"] = 80 },
	["Wintergrasp"] = { ["low"] = 77, ["high"] = 80 },
	["Mount Hyjal"] = { ["low"] = 80, ["high"] = 82 },
	["Vashj'ir"] = { ["low"] = 80, ["high"] = 82 },
	["Deepholm"] = { ["low"] = 82, ["high"] = 83 },
	["Uldum"] = { ["low"] = 83, ["high"] = 84 },
	["Twilight Highlands"] = { ["low"] = 84, ["high"] = 85 },
	["Shadowmoon Valley"] = { ["low"] = 90, ["high"] = 92 },
	["Frostfire Ridge"] = { ["low"] = 90, ["high"] = 92 },
	["Tanaan Jungle"] = { ["low"] = 90, ["high"] = 92 },
	["Gorgrond"] = { ["low"] = 92, ["high"] = 94 },
	["Talador"] = { ["low"] = 94, ["high"] = 96 },
	["Spires of Arak"] = { ["low"] = 96, ["high"] = 98 },
	["Nagrand"] = { ["low"] = 98, ["high"] = 100 },
	["Ashran"] = { ["low"] = 98, ["high"] = 100 },
	["Jade Forest"] = { ["low"] = 85, ["high"] = 86 },
	["Valley of the Four Winds"] = { ["low"] = 86, ["high"] = 87 },
	["Krasarang Wilds"] = { ["low"] = 86, ["high"] = 90 },
	["Kun-Lai Summit"] = { ["low"] = 87, ["high"] = 88 },
	["Townlong Steppes"] = { ["low"] = 88, ["high"] = 89 },
	["Dread Wastes"] = { ["low"] = 88, ["high"] = 89 },
	["Vale of Eternal Blossoms"] = { ["low"] = 90 }
};

SLASH_KRULEVEL1 = "/zone";
function SlashCmdList.KRULEVEL(msg, editbox)
	local level = tonumber(msg);
	DEFAULT_CHAT_FRAME:AddMessage("Zones for " .. level .. ":");
	for key, value in pairs(zone_data) do
		local low = value["low"];
		local high = low;

		if value["high"] ~= nil then
			high = value["high"];
		end

		if level >= low and level <= high then
			DEFAULT_CHAT_FRAME:AddMessage(YELLOW_FONT_COLOR_CODE .. key .. " (" .. low .. " - " .. high .. ")" .. FONT_COLOR_CODE_CLOSE);
		end
	end
end
--
-- [[ SECTION END: Zone Level Look-up Command ]]
--

--
-- [[ SECTION START: Advertising helper ]]
--
local currentAdvert = nil;

SLASH_KRUADVERT1 = '/tm';
function SlashCmdList.KRUADVERT(msg, editbox)
	if currentAdvert ~= nil then
		local sendChannel = 2;
		if not isInTrade() then sendChannel = 1; end

		SendChatMessage(currentAdvert, "CHANNEL", nil, sendChannel);
	end
end

SLASH_KRUADVERTSET1 = '/ts';
function SlashCmdList.KRUADVERTSET(msg, editbox)
	currentAdvert = msg;
	print("Message set: " .. currentAdvert);
end
--
-- [[ SECTION END: Advertising helper ]]
--

--
-- [[ SECTION START: Rogue Pick-pocket visual ]]
--
local playerClass = UnitClass("player");
local pUnitCache = {};

if playerClass == "Rogue" then
	local pFrame = CreateFrame("FRAME", nil, UIParent);
	pFrame:SetFrameStrata("BACKGROUND");
	pFrame:SetWidth(50);
	pFrame:SetHeight(50);
	
	local t = pFrame:CreateTexture(nil, "BACKGROUND");
	t:SetTexture("Interface\\Icons\\Rogue_DirtyTricks.blp");
	t:SetAllPoints(pFrame);
	pFrame.texture = t;
	
	pFrame:SetPoint("TOPLEFT", 250, -250);
	pFrame:Hide();
	
	pFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	pFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	pFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	
	pFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			local _, eventType, _, casterGUID, _, _, _, targetGUID, _, _, _, spellID = ...;
			
			if eventType == "SPELL_CAST_SUCCESS" and spellID == 921 and casterGUID == UnitGUID("player") then
				pUnitCache[targetGUID] = true;
				self:Hide();
			end
		elseif event == "PLAYER_TARGET_CHANGED" then
			local guid = UnitGUID("target");
			
			if guid ~= nil then
				if pUnitCache[guid] == nil and not UnitIsFriend("target", "player") then
					local creatureType = UnitCreatureType("target");
					if creatureType == "Humanoid" then
						self:Show();
					end
					return;
				end
			end
			
			self:Hide();
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			for i, v in pairs(pUnitCache) do
				pUnitCache[i] = nil;
			end
		end
	end);
end

--
-- [[ SECTION END: Rogue Pick-pocket visual ]]
--

--
-- [[ SECTION START: Camera auto-zoom tool ]]
--
local z= 10 ;
local f = CreateFrame('Frame');
local t = 0;

--f:SetScript('OnUpdate', function(self, el)
--	t = t + el;
--	if t >= .5 then
--		local im = IsMounted();
--		local set = self.set;
--		if im and not set then
--			CameraZoomOut(z);
--			self.set = true;
--		elseif not im and set then
--			CameraZoomIn(z);
--			self.set = nil;
--		end
--		t = 0;
--	end
--wend);
--
-- [[ SECTION END: Camera auto-zoom tool ]]
--

--
-- [[ SECTION START: Mounting ]]
--
local MOUNT_CONDITION = "[outdoors,nocombat,nomounted,novehicleui]"
--local GARRISON_MOUNT_CONDITION = "[outdoors,nomounted,novehicleui,nomod:"..MOD_TRAVEL_FORM.."]"
--local SAFE_DISMOUNT = "/stopmacro [flying,nomod:"..MOD_DISMOUNT_FLYING.."]"
local DISMOUNT = [[
/leavevehicle [canexitvehicle]
/dismount [mounted]
]]

-- MOUNTS

local WORLD_SPINNER = 126508;
local CRIMSON_WATER_STRIDER = 127271;

local SUBDUED_SEAHORSE = 98718;

local HORDE_CHOPPER = 179244;
local ALLIANCE_CHOPPER = 179245;

-- Flying Mounts
local SWIFT_WINDSTEED = 134573;
local ONYXIAN_DRAKE = 69395;
local ARGENT_HIPPOGRYPH = 63844;
local IRON_SKYREAVER = 153489;
local MIMIRONS_HEAD = 63796;
local FELFIRE_HAWK = 97501;
local CORRUPTED_DREADWING = 183117;
local ASHEN_PANDAREN_PHOENIX = 132117;
local EMERALD_DRAKE = 175700;
local BLAZING_DRAKE = 107842;
local PHOSPHORESCENT = 88718;
local TLPD = 60002;
local IRONBOUND_WRAITH = 142910;
local GRINNING_REAVER = 163025;
local SKY_GOLEM = 134359;

local FLYING_MOUNTS = {MIMIRONS_HEAD, ASHEN_PANDAREN_PHOENIX, EMERALD_DRAKE, PHOSPHORESCENT, TLPD, GRINNING_REAVER, IRONBOUND_WRAITH};

-- Land Mounts
local ARGENT_CHARGER = 66906;
local SWIFT_ZHEVRA = 49322;
local FIERY_WARHORSE = 36702;
local IRONSIDE_WOLF = 171839;
local IRONTUSK = 171626;
local TREADBLADE = 171846;
local WHITE_POLAR_BEAR = 54753;
local FROSTWOLF = 171838;
local BLOODHOOF_BULL = 171620;
local CHALLENGERS_YETI = 171848;
local SWIFT_SPECTRAL_TIGER = 42777;
local RIVENDARES_DEATHCHARGER = 17481;
local KOR_KRON_WOLF = 148396;
local WILD_GORETUSK = 171633;
local COALFIST_GRONNLING = 189364;
local WARLORDS_DEATHWHEEL = 171845;
local CRIMSON_DEATHCHARGER = 73313;
local DEATHTUSK_FELBOAR = 190977;

local LAND_MOUNTS = {DEATHTUSK_FELBOAR, SWIFT_ZHEVRA, WHITE_POLAR_BEAR, SWIFT_SPECTRAL_TIGER, RIVENDARES_DEATHCHARGER, KOR_KRON_WOLF, WILD_GORETUSK, CRIMSON_DEATHCHARGER, IRONBOUND_WRAITH};

local FLYING_SKILLS = IsSpellKnown(90265) or IsSpellKnown(34091) or IsSpellKnown(34090);
local LAND_SKILLS = IsSpellKnown(33391) or IsSpellKnown(33388);

local mountButton = CreateFrame("Button", "KruUtilMountButton", nil, "SecureActionButtonTemplate");
--mountButton:SetAttribute("type", "macro");

function UseMount(mountID)
	for i = 1, C_MountJournal.GetNumMounts() do
		local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpec, faction, hideOnChar, isCollected = C_MountJournal.GetMountInfo(i);
		local creatureDisplayID, descriptionText, sourceText, isSelfMount, mountType = C_MountJournal.GetMountInfoExtra(i);
		
		if spellID == mountID then
			C_MountJournal.Summon(i);
			break;
		end
	end
end

function string.starts(sr,st)
	return string.sub(sr,1,string.len(st))==st
end

function func_search(name)
	for key, value in pairs(_G) do
		if type(value) == "function" and string.starts(key, name) then
			print(key);
		end
	end
end

mountButton:SetScript("OnClick", function(self)
	-- We're mounted, let's dismount!
	if IsMounted() then
		Dismount();
		return;
	end
	
	-- We're in a vehicle, exit the vehicle.
	if UnitInVehicle("player") then
		VehicleExit();
		return;
	end
	
	-- We can't update during combat.
	if InCombatLockdown() then return end
	
	-- Check if we can mount.
	if SecureCmdOptionParse(MOUNT_CONDITION) then
		if IsLeftShiftKeyDown() then
			UseMount(CRIMSON_WATER_STRIDER);
			return;
		end
		
		if IsSwimming() then
			UseMount(SUBDUED_SEAHORSE);
			return;
		end
		
		if IsFlyableArea() and (IsSpellKnown(90265) or IsSpellKnown(34091) or IsSpellKnown(34090)) then
			--UseMount(MIMIRONS_HEAD);
			local playerName = UnitName("player");
			
			if playerName == "Vallessia" then
				UseMount(SWIFT_WINDSTEED);
			elseif playerName == "Kruith" then
				UseMount(SKY_GOLEM);
			else
				UseMount(MIMIRONS_HEAD);
				--UseMount(FLYING_MOUNTS[math.random(#FLYING_MOUNTS)]);
			end
			
			return;
		end
		
		if (IsSpellKnown(33391) or IsSpellKnown(33388)) or (IsSpellKnown(90265) or IsSpellKnown(34091) or IsSpellKnown(34090)) then
			local playerName = UnitName("player");
			
			if GetRealmName() == "Zul'jin" then
				UseMount(SWIFT_ZHEVRA);
			elseif playerName == "Tagara" then
				UseMount(KOR_KRON_WOLF);
			elseif UnitFactionGroup("player") == "Alliance" then
				UseMount(TREADBLADE);
			else
				--UseMount(CHALLENGERS_YETI);
				--UseMount(LAND_MOUNTS[math.random(#LAND_MOUNTS)]);
				UseMount(WHITE_POLAR_BEAR);
				--UseMount(IRONBOUND_WRAITH);
			end
			return;
		end
		
		if UnitFactionGroup == "Alliance" then
			UseMount(ALLIANCE_CHOPPER);
			return;
		end
		
		if UnitFactionGroup == "Horde" then
			UseMount(HORDE_CHOPPER);
			return;
		end
	end
end)

mountButton:RegisterEvent("PLAYER_ENTERING_WORLD");
mountButton:RegisterEvent("UPDATE_BINDINGS");

mountButton:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_BINDINGS" then
		ClearOverrideBindings(self);
		
		local primary, secondary = GetBindingKey("DISMOUNT");
		
		if primary then
			SetOverrideBinding(self, false, primary, "CLICK KruUtilMountButton:LeftButton")
		end
		
		if secondary then
			SetOverrideBinding(self, false, secondary, "CLICK KruUtilMountButton:LeftButton")
		end
	end
end);
--
-- [[ SECTION END: Mounting ]]
--

--
-- [[ SECTION START: Spell Annoucement ]]
--
local rbLink = GetSpellLink("Rebirth");
local ssLink = GetSpellLink("Soulstone");
local raLink = GetSpellLink("Raise Ally");
local ressSpell = GetSpellLink("Revive");

local lowHPWarningCD = 0;

local sayings_shieldWall = {
	"Hit the shield, not my face, that'd be great!",
	"Ouch, ouch, ouch...",
	"My shield is a wall! .. not a literal one mind you.",
	"These things are really trying to make me dead.",
	"Just keep blocking, just keep blocking.."
};

local death_warnings = {
	"I don't feel so good...",
	"Is my everything supposed to be bleeding like that?",
	"I'm not convinced my arm normally bends that way!",
	"Not good, not good, not good!",
	"Could really use a paladin touching me with their hands right now...",
	"If I die, make sure the rogue doesn't steal my sword..",
	"Having second thoughts about this situation!"
};

local function saEvent(self, event, ...)
	if event == "UNIT_COMBAT" then
		local unitID = select(12, ...);

		if unitID == "player" then
			if lowHPWarningCD == 0 then
				local pct = (UnitHealth("player") / UnitHealthMax("player")) * 100;

				if pct < 10 then
					lowHPWarningCD = 300;
					SendChatMessage(death_warnings[math.random(#death_warnings)]);
				end
			end
		end

		return false;
	end

	local timestamp, message, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = select(1, ...);

	-- THESE ARE LOCAL CACHED LINKS

	-- Check spell cast (can also be SPELL_CAST_START or SPELL_CAST_FAILED)
	if message == "SPELL_CAST_SUCCESS" then
		-- Additional arguments
		local spellId, spellName, spellSchool = select(12, ...);
		
		if (spellName == "Rebirth") then
			SendChatMessage(sourceName .. " cast " .. rbLink .. " on " .. destName .. "!", "RAID");
			if sourceGUID == UnitGUID("player") then
				local n = math.random(3);
				if n == 1 then
					SendChatMessage("Time to get back up, " .. destName .. ".");
				elseif n == 2 then
					SendChatMessage("We're not done fighting just yet " .. destName .. "!");
				elseif n == 3 then
					SendChatMessage("One " .. destName .. " coming right up, fresh off the floor!");
				end
			end
		elseif (spellName == "Raise Ally") then
			SendChatMessage(sourceName .. " cast " .. raLink .. " on " .. destName .. "!", "RAID");
		elseif (spellName == "Soulstone") then
			SendChatMessage(sourceName .. " cast " .. ssLink .. " on " .. destName .. "!", "RAID");
		end
		
		-- Compare caster and spell
		if sourceName == UnitName("player") then
			if (spellName == "Vigilance") then
				SendChatMessage("Vigilance (30% reduced damage) on " .. destName .. "!");
			elseif (spellName == "Rallying Cry") then
				SendChatMessage("Rallying Cry (20% increased health) up!", "RAID");
			elseif (spellName == "Shield Wall") then
				SendChatMessage(sayings_shieldWall[math.random(#sayings_shieldWall)]);
			elseif (spellName == "Demoralizing Banner") then
				SendChatMessage("Demoralizing Banner (10% reduced damage) up!", "RAID");
			end
			-- Show display
			return false
		end
	elseif message == "SPELL_CAST_START" then
		-- Additional arguments
		
		if sourceGUID == UnitGUID("player") then
			local spellId, spellName, spellSchool = ...;
			
			if spellName == "Revive" then
				local name = UnitName("mouseover"); 
				SendChatMessage("Casting " .. ressSpell .. " on " .. name .. "!", "RAID");
			elseif spellName == "Tranquility" then
				SendChatMessage("Using Tranquility now!!");
			end
		end
	end
end

local saFrame = CreateFrame("FRAME");
saFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
saFrame:RegisterEvent("UNIT_COMBAT");
saFrame:SetScript("OnEvent", saEvent);
saFrame:SetScript("OnUpdate", function(self, elapsed)
	if lowHPWarningCD > 0 then
		lowHPWarningCD = lowHPWarningCD - elapsed;

		if lowHPWarningCD < 0 then
			lowHPWarningCD = 0;
		end
	end
end);
--
-- [[ SECTION END: Spell Annoucement ]]
--

--
-- [[ SECTION START: Pet Type Filter Buttons ]]
--

local ptfOffset = 0;
function ptf_button_factory(icon, index)
	local b = CreateFrame("CheckButton", nil, PetJournal);
	b:SetSize(29, 29);

	-- Icon texture.
	b.Icon = b:CreateTexture(nil, "ARTWORK");
	b.Icon:SetTexture("Interface\\Icons\\" .. icon);
	b.Icon:SetAllPoints(b);

	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");

	b:SetScript("PreClick", function(self)
		self:SetChecked(false);
	end);

	if index == 0 then
		b:SetScript("OnClick", function(self)
			C_PetJournal.AddAllPetTypesFilter();
		end);
	else
		b:SetScript("OnClick", function(self)
			C_PetJournal.ClearAllPetTypesFilter();
			C_PetJournal.SetPetTypeFilter(index, true);
		end);
	end

	b:SetPoint("BOTTOMLEFT", PetJournal, "TOPLEFT", 100 + (35 * ptfOffset), 10);
	ptfOffset = ptfOffset + 1;
end

local ptfHooked = false;
function ptf_hook()
	if ptfHooked then
		return;
	end

	ptf_button_factory("INV_Pet_Achievement_CaptureAPetFromEachFamily_Battle", 0);
	ptf_button_factory("Icon_PetFamily_Beast", 8);
	ptf_button_factory("Icon_PetFamily_Elemental", 7);
	ptf_button_factory("Icon_PetFamily_Critter", 5);
	ptf_button_factory("Icon_PetFamily_Dragon", 2);
	ptf_button_factory("Icon_PetFamily_Flying", 3);
	ptf_button_factory("Icon_PetFamily_Humanoid", 1);
	ptf_button_factory("Icon_PetFamily_Magical", 6);
	ptf_button_factory("Icon_PetFamily_Mechanical", 10);
	ptf_button_factory("Icon_PetFamily_Undead", 4);
	ptf_button_factory("Icon_PetFamily_Water", 9);

	ptfHooked = true;
end

local ptfFrame = CreateFrame("FRAME");
ptfFrame:RegisterEvent("ADDON_LOADED");
ptfFrame:SetScript("OnEvent", function(self, event, name)
	if name == "KruUtil" then
		if IsAddOnLoaded("Blizzard_Collections") then
			ptf_hook();
		end
	elseif name == "Blizzard_Collections" then
		ptf_hook();
	end
end);

--
-- [[ SECTION END: Pet Type Filter Buttons ]]
--

--
-- [[ SECTION START: Auto Pet Stuff ]]
--

-- 1 = Humanoid
-- 2 = Dragonkin
-- 3 = Flying
-- 4 = Undead
-- 5 = Critter
-- 6 = Magical
-- 7 = Elemental
-- 8 = Breast
-- 9 = Water
-- 10 = Mechanical

local boostedPetHasEngaged = false;

function KU_PP()	
	if C_PetBattles.IsInBattle() then
		local battleState = C_PetBattles.GetBattleState();

		if battleState == 2 or battleState == 7 then
			boostedPetHasEngaged = false;
		end

		if not battleState == 3 then
			return;
		end

		if C_PetBattles.IsWaitingOnOpponent() then
			return;
		end

		local myActivePetIndex = C_PetBattles.GetActivePet(1);
		local _, myActivePetName = C_PetBattles.GetName(1, myActivePetIndex);
		local isBoostPetActive = myActivePetName ~= "Feline Familiar";

		local eActivePetIndex = C_PetBattles.GetActivePet(2);
		local eActivePetName = C_PetBattles.GetName(2, eActivePetIndex);

		if boostedPetHasEngaged then
			if isBoostPetActive then
				-- We still have the boosted pet out after casting.
				C_PetBattles.ChangePet(2); -- Switch to second pet.
			else
				-- Normal rotation.
				local hasStoneskin = false;
				local eHealth = C_PetBattles.GetHealth(2, eActivePetIndex);
				local eMaxHealth = C_PetBattles.GetMaxHealth(2, eActivePetIndex);
				local eHealthPct = (eHealth / eMaxHealth) * 100;
				local ePetType = C_PetBattles.GetPetType(2, eActivePetIndex);

				for auraIndex = 1, C_PetBattles.GetNumAuras(1, myActivePetIndex) do
					local auraID, aB, aC, aD, aE, aF = C_PetBattles.GetAuraInfo(1, myActivePetIndex, auraIndex);
					local auraName, auraIcon = C_PetJournal.GetPetAbilityInfo(auraID);

					if auraName == "Stoneskin" then
						hasStoneskin = true;
					end
				end

				if not hasStoneskin then
					C_PetBattles.UseAbility(2);
				else
					local devourThresh = 0;

					if ePetType == 8 then
						devourThresh = 40;
					elseif ePetType == 5 then
						devourThresh = 50;
					elseif ePetType == 3 then
						devourThresh = 15;
					end

					local canDevour = C_PetBattles.GetAbilityState(1, myActivePetIndex, 3);
					if eHealthPct <= devourThresh and canDevour then
						C_PetBattles.UseAbility(3);
					else
						C_PetBattles.UseAbility(1);
					end
				end
			end
		else
			C_PetBattles.UseAbility(1); -- Use first ability.
			boostedPetHasEngaged = true;
		end
	else
		boostedPetHasEngaged = false;
	end
end

--
-- [[ SECTION END: Auto Pet Stuff ]]
--

--
-- [[ SECTION START: Auto Rep Tracker ]]
--

local repTracks = {
	-- Draenor Reputations
	[948] = 1515, -- Spires of Arak: Arakkoa Outcasts

	-- Classic
	[696] = 749, -- Molten Core: Hydraxian Waterlords
	[717] = 609, -- Ruins of Ahn'Qiraj: Cenarion Circle
	[766] = 910, -- Temple of Ahn'Qiraj: Brood of Nozdormu
	[704] = 59, -- Blackrock Depths: Thorium Brotherhood
	[765] = 529, -- Stratholme: Argent Dawn

	-- Cataclysm
	[800] = 1204, -- Firelands: Avengers of Hyjal

	-- Wrath of the Lich King
	[604] = 1156, -- Icecrown Citadel: The Ashen Verdict

	-- The Burning Crusade
	[796] = 1012, -- The Black Temple: Ashtongue Deathsworn
	[775] = 990, -- Hyjal Summit: The Scale of the Sands
	[799] = 967, -- Karazhan: The Violet Eye
	[797] = {["Horde"] = 947, ["Alliance"] = 946}, -- Hellfire Ramparts: Thrallmar/Honor Hold
	[710] = {["Horde"] = 947, ["Alliance"] = 946}, -- Shattered Halls: Thrallmar/Honor Hold
	[725] = {["Horde"] = 947, ["Alliance"] = 946}, -- The Blood Furnace: Thrallmar/Honor Hold
	[722] = 1011, -- Auchenai Crpyts: Lower City
	[732] = 1011, -- Sethekk Halls: Lower City
	[724] = 1011, -- Shadow Labyrinth: Lower City
	[734] = 989, -- Old Hillsbrad Foothills: Keepers of Time
	[733] = 989, -- The Black Morass: Keepers of Time
	[732] = 933, -- Mana-Tombs: The Consortium
	[731] = 935, -- The Arcatraz: The Sha'tar
	[729] = 935, -- The Botanica: The Sha'tar
	[730] = 935, -- The Mechanar: The Sha'tar
	[728] = 942, -- The Slave Pens: Cenarion Expedition
	[727] = 942, -- The Steamvault: Cenarion Expedition
	[726] = 942, -- The Underbog: Cenarion Expedition

	-- Mists of Pandaria
	[930] = 1435, -- Throne of Thunder: Shado'pan Assault
	[951] = 1492, -- Timeless Isle: Emperor Shaohao

	-- Battlegrounds
	[443] = {["Horde"] = 889, ["Alliance"] = 890}, -- Warsong Gulch: Warsong Outriders/Silverwing Sentinels
	[401] = {["Horde"] = 729, ["Alliance"] = 730}, -- Alterac Valley: Frostwolf Clan/Stormpike Guard
	[461] = {["Horde"] = 510, ["Alliance"] = 509}, -- Arathi Basin: The Defilers/League of Arathor
};

local function trackRepByID(id, speak)
	if type(id) == "table" then
		id = id[UnitFactionGroup("player")];
	end

	for factionIndex = 1, GetNumFactions() do
		name, _, _, _, _, _, _, _, isHeader, _, _, _, _, factionID = GetFactionInfo(factionIndex);
		if isHeader ~= true then
			if tonumber(factionID) == id then
				SetWatchedFactionIndex(factionIndex);

				if speak then
					DEFAULT_CHAT_FRAME:AddMessage("Automatically tracking reputation " .. GREEN_FONT_COLOR_CODE .. name .. FONT_COLOR_CODE_CLOSE .. " for this zone.");
				end

				break;
			end
		end
	end
end

local repTracker = CreateFrame("FRAME");
repTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA");
repTracker:SetScript("OnEvent", function(self, event)
	local zoneID = GetCurrentMapAreaID();
	local factionID = repTracks[zoneID];

	if type(factionID) ~= "nil" then
		trackRepByID(factionID, true);
	end
end);

--
-- [[ SECTION END: Auto Rep Tracker ]]
--

--
-- [[ SECTION START: Clarity of Will Pres ]]
--

local cow_f = CreateFrame("FRAME");
local cow_e = 0;
local cow_bars = {};
local cow_format = nil;

cow_f:RegisterEvent("PARTY_MEMBERS_CHANGED");

function cow_spawnBar(target)
	local prev_bar = nil;
	local f = nil;

	for index, bar in pairs(cow_bars) do
		if bar.InUse then
			prev_bar = bar;
		else
			f = bar;
		end

		if prev_bar ~= nil and f ~= nil then
			break;
		end
	end

	if f == nil then
		f = CreateFrame("FRAME", "CoWFrame" .. #cow_bars + 1, UIParent);
		f:SetFrameStrata("MEDIUM");
		f:SetWidth(64);
		f:SetAlpha(0.8);
		f:SetHeight(128);

		local ht = f:CreateTexture();
		ht:SetTexture("Interface\\UNITPOWERBARALT\\Generic3_Vertical_Fill.blp");
		ht:SetVertexColor(0.90980392156, 0.86666666666, 0.27450980392);
		ht:ClearAllPoints();
		ht:SetAlpha(0.6);
		ht:SetPoint("BOTTOMLEFT");
		ht:SetPoint("BOTTOMRIGHT");
		
		ht:SetHeight(f:GetHeight());
		f.fillTexture = ht;

		local bt = f:CreateTexture(nil, "BACKGROUND");
		bt:SetTexture("Interface\\UNITPOWERBARALT\\Generic3_Vertical_Fill.blp");
		bt:SetAlpha(0.6);
		bt:SetVertexColor(0.00980392156, 0.06666666666, 0.07450980392);
		bt:SetAllPoints(f);

		local frame = CreateFrame("FRAME", nil, f);
		frame:SetAllPoints(f);

		local t = frame:CreateTexture();
		t:SetTexture("Interface\\UNITPOWERBARALT\\StoneDiamond_Vertical_Frame.blp");
		t:SetAllPoints(frame);
		t:SetAlpha(0.3);

		f.frame = frame;
		frame.texture = t;
	end

	cow_setBarValue(f, 0);

	if prev_bar ~= nil then
		f:SetPoint("LEFT", prev_bar, "RIGHT", 0, 0); -- OFFSET FOR THE OTHER BARS COMPARED TO THE PREVIOUS.
	else
		f:SetPoint("CENTER", UIParent, "CENTER", -50, 350); -- THIS CONTROLS WHERE THE FIRST BAR SPAWNS.
	end

	f.InUse = true;
	f.Target = target;
	f:Show();
	table.insert(cow_bars, f);
	return f;
end

function cow_hideBars()
	for index, bar in pairs(cow_bars) do
		bar:Hide();
		bar.InUse = false;
	end
end

function cow_setBarValue(bar, value)
	if value == 0 then
		bar:SetAlpha(0.3);
	else
		bar:SetAlpha(0.7);
	end
	local fill = bar.fillTexture;
	local amount = 0.15625 + value * 0.6875;
	fill:SetHeight(max(bar:GetHeight() * amount, 1));
	fill:SetTexCoord(0, 1, 1 - amount, 1);
end

function cow_setupParty()
	cow_hideBars(); -- Hide all bars.
	cow_spawnBar("player"); -- Spawn a bar for the player.

	-- Spawn bars for party members that exist.
	for partyIndex = 1, 4 do
		local unitID = "party" .. partyIndex;
		if UnitExists(unitID) then
			cow_spawnBar(unitID);
		end
	end
end

cow_f:SetScript("OnUpdate", function(self, elapsed)
	if cow_e > 0.25 then
		-- Check the player's current group situation.
		if UnitInRaid("player") then
			-- Check if we're currently using a raid format.
			if cow_format ~= "raid" then
				-- Set-up the bars for a raid.
				cow_hideBars(); -- Hide all bars.
				cow_format = "raid";
			end
		elseif UnitInParty("player") then
			-- Check if we're currently using a party format.
			if cow_format ~= "party" then
				cow_setupParty();
				cow_format = "party";
			end
		else
			-- Check if we're set-up for solo play.
			if cow_format ~= "solo" then
				-- Set-up the bars for solo.
				cow_hideBars(); -- Hide all bars.
				cow_spawnBar("player"); -- Spawn a bar for the player.
				cow_format = "solo";
			end
		end

		-- Update bars.
		for index, bar in pairs(cow_bars) do
			if bar.InUse and UnitExists(bar.Target) then
				local buffPct = 0;
				for buffIndex = 1, 40 do
					local name, _, _, _, _, duration, expirationTime, unitCaster, _, _, spellId = UnitBuff(bar.Target, buffIndex);
					if name then -- 152118
						if spellId == 152118 and unitCaster == "player" then
							buffPct = math.abs((GetTime() - expirationTime) / duration);
							break;
						end
					else
						break;
					end 
				end
				cow_setBarValue(bar, buffPct);
			end
		end

		cow_e = 0;
	end

	cow_e = cow_e + elapsed;
end);

cow_f:SetScript("OnEvent", function(self, event)
	if event == "PARTY_MEMBERS_CHANGED" and cow_format == "party" then
		cow_setupParty();
	end
end);

--
-- [[ SECTION END: Clarity of Will Pres]]
--
