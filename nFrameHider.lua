
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

local function CheckHealthAndMana()
	return UnitHealth('player') == UnitHealthMax('player') and UnitPower('player', SPELL_POWER_MANA) == UnitPowerMax('player', SPELL_POWER_MANA)
end

local function EnableHiding(frame)
	local f = CreateFrame('Frame')

	f:RegisterEvent('PLAYER_REGEN_DISABLED')
	f:RegisterEvent('PLAYER_REGEN_ENABLED')
	
	frame:SetAlpha(outOfCombatAlpha)
	frame:EnableMouse(false)

	f:SetScript('OnEvent', function(self, event, arg1)
		if (event == 'PLAYER_REGEN_DISABLED') then
			UIFrameFadeIn(frame, 0.35, frame:GetAlpha(), 1)
			frame:EnableMouse(true)
		elseif (event == 'PLAYER_REGEN_ENABLED') then
			if (CheckHealthAndMana()) then
				UIFrameFadeOut(frame, 0.35, frame:GetAlpha(), outOfCombatAlpha)
				frame:EnableMouse(false)
			else
				self:RegisterEvent('UNIT_HEALTH')
				self:RegisterEvent('UNIT_POWER')
			end
		end

		-- Only runs when out of combat and health/mana < 100%
		if (arg1 == 'player' and event == 'UNIT_HEALTH' or event == 'UNIT_POWER') then
			if (CheckHealthAndMana()) then
				UIFrameFadeOut(frame, 0.35, frame:GetAlpha(), outOfCombatAlpha)
				self:UnregisterEvent('UNIT_HEALTH')
				self:UnregisterEvent('UNIT_POWER')
				frame:EnableMouse(false)
			end
		end
	end)
end

-- Need to wait for the PLAYER_ENTERING_WORLD event before
-- accessing the oUF elements
local loader = CreateFrame('Frame')
loader:RegisterEvent('PLAYER_ENTERING_WORLD')
loader:SetScript('OnEvent', function()
	loader:UnregisterEvent('PLAYER_ENTERING_WORLD')

	for _, frame in pairs(frameList) do
		if (frame ~= 'oUF_Neav_Raid') then
			EnableHiding(_G[frame])
		else
			-- Loop through all the raid groups
			for i = 1, oUF_Neav.units.raid.numGroups do
				EnableHiding(_G[frame..i])
			end
		end
	end
end)
