--[[ 
	I looked for an appropriate area I could use in data/spells/lib/spells.lua.
	None matched the diamond-shaped area featured in the video, so I needed to make my own.
	To keep a light footprint, I did not edit the aforementioned spells.lua, but in production, I might
	suggest adding this area to it.

	I ran into a snag, though - for whatever reason, the area defined below did not 
	correctly display the tornado sprites, unless I walked out of the space in which I casted the spell.
	I couldn't find a solution to this, and I was out of time and needed to complete the other questions. 
	With additional time I would have posted my client/server version info, and Tibia spr/dat info to the 
	forums, in order to get some assistance.

	With the above issue resolved, I would have worked to fine tune the placement of the tornadoes.
	I would have done this through the creation of different "keyframes", which would be additional areas to
	update the combat instance with via combat:setArea(), to more closely match the pattern in the supplied
	video.
]]--

-- this delay determines how long we wait before spawnign the effect again.
local DELAY_TIME_MS = 1000

local NUMBER_OF_WAVES = 6

-- Need a 2 in the middle to both mark our player and ensure that a tornado does not spawn on them
local DIAMOND3X3 = 
{
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 1, 0, 1, 0, 1, 0},
	{1, 0, 1, 2, 1, 0, 1},
	{0, 1, 0, 1, 0, 1, 0},
	{0, 0, 1, 0, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

--combat instance and parameter setup
local combat = Combat() 
combat:setArea(createCombatArea(DIAMOND3X3))
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)

-- function to get damage values - from eternal_winter.lua 
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.5) + 25
	local max = (level / 5) + (magicLevel * 11) + 50
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

-- asynchronous implementation, to rapid-fire and forget multiple torando instances, each with their own delay.
local function castSpell(cid, variant)
	local creature = Creature(cid)
	if creature ~= nil then
		combat:execute(creature, variant)
	end
end

-- add async events, each with an increasing delay, to create the effect of a prolonged set of tornadoes.
function onCastSpell(creature, variant)
	local delay = 0
	for i = 1, NUMBER_OF_WAVES, 1 do
		-- needed to validate the incoming creature to avoid an unsafe event
		addEvent(castSpell, delay, creature:getId(), variant)
		delay = delay + DELAY_TIME_MS
	end
end

