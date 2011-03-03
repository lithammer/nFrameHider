
-- Un-comment a frame in order to active frame hiding
local frameList = {
	'oUF_Neav_Player',
	--'oUF_Neav_Pet',
	--'oUF_Neav_Target',
	--'oUF_Neav_TargetTarget',
	--'oUF_Neav_Focus',
	--'oUF_Neav_FocusTarget,
	--'oUF_Neav_Party',
	--'oUF_Neav_Raid',
}

-- Alpha value for when out of combat
local outOfCombatAlpha = 0

-------------------------------------------------------------------------------

local EnabledFrames = {}

local function CheckHealthAndMana()
	return UnitHealth('player') == UnitHealthMax('player') and UnitPower('player', SPELL_POWER_MANA) == UnitPowerMax('player', SPELL_POWER_MANA)
end

local function FadeIn(frame)
	UIFrameFadeIn(frame, 0.35, frame:GetAlpha(), 1)
	frame:EnableMouse(true)
end

local function FadeOut(frame)
	UIFrameFadeOut(frame, 0.35, frame:GetAlpha(), outOfCombatAlpha)
	frame:EnableMouse(false)
end

local function OnEvent(self, event, unit)
	if (event == 'PLAYER_REGEN_DISABLED') then
		for _, frame in ipairs(EnabledFrames) do
			FadeIn(frame)
		end

		self:UnregisterEvent('UNIT_HEALTH')
		self:UnregisterEvent('UNIT_POWER')
	elseif (event == 'PLAYER_REGEN_ENABLED') then
		if (CheckHealthAndMana()) then
			for _, frame in ipairs(EnabledFrames) do
				FadeOut(frame)
			end
		end

		self:RegisterEvent('UNIT_HEALTH')
		self:RegisterEvent('UNIT_POWER')
	end

	-- Only runs when out of combat and health/mana < 100%
	if (unit == 'player' and event == 'UNIT_HEALTH' or event == 'UNIT_POWER') then
		for _, frame in ipairs(EnabledFrames) do
			if (CheckHealthAndMana()) then
				FadeOut(frame)
			else
				FadeIn(frame)
			end
		end
	end

	-- Need to wait for the PLAYER_ENTERING_WORLD event before
	-- accessing the oUF elements
	if (event == 'PLAYER_ENTERING_WORLD') then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')

		for _, frame in ipairs(frameList) do
			if (frame ~= 'oUF_Neav_Raid') then
				table.insert(EnabledFrames, _G[frame])
				_G[frame]:SetAlpha(outOfCombatAlpha)
			else
				-- Loop through all the raid groups
				for i = 1, oUF_Neav.units.raid.numGroups do
					table.insert(EnableFrames, _G[frame..i])
					_G[frame..i]:SetAlpha(outOfCombatAlpha)
				end
			end
		end
	end
end

local f = CreateFrame('Frame')
-- Only register events if we're actually going to iterate any elements
if (#frameList > 0) then
	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:RegisterEvent('PLAYER_REGEN_ENABLED')
	f:RegisterEvent('UNIT_HEALTH')
	f:RegisterEvent('UNIT_POWER')
	f:RegisterEvent('PLAYER_ENTERING_WORLD')

	f:SetScript('OnEvent', OnEvent)
end
