-- Un-comment a frame to activate frame hiding
local frameList = {
    'oUF_Neav_Player',
    'oUF_Neav_Pet',
    'oUF_Neav_Target',
    'oUF_Neav_TargetTarget',
    'oUF_Neav_Focus',
    'oUF_Neav_FocusTarget',
    'oUF_Neav_Party',
    'oUF_Neav_Raid',
}

-- Alpha value for when out of combat
local outOfCombatAlpha = 0

-------------------------------------------------------------------------------

local f = CreateFrame('Frame')
local EnabledFrames = {}

local function FullHealth()
    return UnitHealth('player') == UnitHealthMax('player')
end

local function FadeIn(frame)
    UIFrameFadeIn(frame, 0.35, frame:GetAlpha(), 1)
    frame:EnableMouse(true)
end

local function FadeOut(frame)
    if not InCombatLockdown() then
        UIFrameFadeOut(frame, 0.35, frame:GetAlpha(), outOfCombatAlpha)
        frame:EnableMouse(false)
    end
end

-- Need to wait for the PLAYER_ENTERING_WORLD event before
-- accessing the oUF elements
function addon:PLAYER_ENTERING_WORLD()
    f:UnregisterEvent('PLAYER_ENTERING_WORLD')

    for _, frame in ipairs(frameList) do
        if frame == 'oUF_Neav_Raid' then
            -- Loop through all the raid groups
            for i = 1, oUF_Neav.units.raid.numGroups do
                table.insert(EnabledFrames, _G[frame..i])
                _G[frame..i]:SetAlpha(outOfCombatAlpha)
            end
        else
            table.insert(EnabledFrames, _G[frame])
            _G[frame]:SetAlpha(outOfCombatAlpha)
        end
    end
end

function addon:UNIT_HEALTH()
    for _, frame in pairs(EnabledFrames) do
        if FullHealth() then
            FadeOut(frame)
        else
            FadeIn(frame)
        end
    end
end

function addon:PLAYER_REGEN_DISABLED()
    for _, frame in pairs(EnabledFrames) do
        FadeIn(frame)
    end
end

function addon:PLAYER_REGEN_ENABLED()
    if FullHealth() then
        for _, frame in pairs(EnabledFrames) do
            FadeOut(frame)
        end
    end
end

f:RegisterEvent('PLAYER_REGEN_DISABLED')
f:RegisterEvent('PLAYER_REGEN_ENABLED')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:RegisterUnitEvent('UNIT_HEALTH', 'player')

f:SetScript('OnEvent', function(event, ...)
    addon[event](...)
end)

for _, frame in pairs(frameList) do
    _G[frame]:HookScript('OnEnter', function()
        FadeIn(frame)
    end)

    _G[frame]:HookScript('OnLeave', function()
        FadeOut(frame)
    end)
end
