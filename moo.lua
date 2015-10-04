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

local topInset = 20;
local bottomInset = 20;
function cow_setBarValue(bar, value)
	local fill = bar.fillTexture;
	local amount = topInset + value * ((1 - bottomInset) - topInset);
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
