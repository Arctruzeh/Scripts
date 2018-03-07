if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "target", "focus", "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

  ChannelList = { "Penance", "Divine Hymn", "Hymn of Hope", "Mind Control", "Evocation", "Seduction", }

  HealList = {
    49276, --Lesser Healing Wave : Rank 9
    49273, --Healing Wave
    48785, --Flash of Light
    48782, --Holy Light
    48071, --Flash Heal
    48120, --Binding Heal
    48443, --Regrowth
    50464, --Nourish
    48378, --Healing Touch
  }

  CCList = {
    51514, --Hex
    12826, --Sheep
    28271, --Turtle
    61721, --Rabbit
    61305, --Black Cat
    28272, --Pig
    33786, --Cyclone
    53308, --Entangline Roots
    18658, --Hibernate
    6215, --Fear
    17928, --Howl of Terror
    605, --Mind Control
  }

  DMGList = {
    34914, --Vampiric Touch
    42842, --Frostbolt
    50796, --Chaos Bolt
    47843, --Unstable Affliction
    60043, --Lava Burst
  }

  PurgeList = {
    48066, --power word: shield
    32182, --heroism
    2825, --bloodlust
    43309, --ice barrier
    12472, --icy veins
    12042, --arcane power
    12043, --presence of mind
    16188, --shaman nature's swiftness
    17116, --druid nature'es swiftness
    54428, --divine plea
    53601, --sacred shield
    31884, --wings
    64205, --divine sacrifice
    6940, --hand of sacrifice
    10060, --power infusion
    29166, --innervate
    54833, --innervate glyph
    10278, --hand of protection
    498, --divine protection
    1044, --hand of freedom
    64701, --elemental mastery
    16166, --elemantal mastery 2
    6346, --fear ward
    48161, --Power Word: Fortitude
    20217, --Blessing of Kings
    48469, --Mark of the Wild
    48932, --Blessing of Might
    48111, --Prayer of Mending
  }

  Purgeb4dmgList = {
    48066, --power word: shield
    43309, --ice barrier
    498, --divine protection
    48111, --Prayer of Mending
  }

  EBindList = {
    2974, --Wing clip
    13809, --Ice trap
    5116, --Concussive shot
    16979, --feral charge
    120, --Cone of cold
    11113, --Blast wave
    15407, --mindflay
    3776, --Crippeling poison
    26679, --Deadly throw
    8056, --Frost shock
    2484, --Earthbind totem
    1715, --Hamstring   
    12323, --Piercing howl
    48483, --Infected wounds
    42842, --frostbolt max rank
    116, --frostbolt r1
    42931, --cone of cold
    47610, --frostfire bolt
    59638, --mirror images
    7321, --chilled
    31589, --slow
    49236, --frost shock
    3600, --earthbind
    61291, --shadow flame
    18118, --conflagrate aftermath daze
    58181, --feral disease
    3409 , --rogue crippling poison
    45524, --chains of ice
  }

  SWalkList = {
    64695, --Earthbind Root
    63685, --enhance nova
    42917, --frost nova
    12494, --frost bite
    33395, --pet nova
    53313, --nature's grasp
    53308, --entangling roots
  }

  function UnitBuffID(unit, id)    
    return UnitBuff(unit, GetSpellInfo(id))
  end

  function UnitDebuffID(unit, id)    
    return UnitDebuff(unit, GetSpellInfo(id))
  end

  function CanHeal(unit)
    if UnitExists(unit)
    and UnitIsConnected(unit)
    and not UnitIsCharmed(unit) 
    and not UnitDebuffID(unit, 33786) --Cyclone
    and not UnitIsDeadOrGhost(unit) then
      return true
    end
  end

  function getHp(unit) 
    if CanHeal(unit) then
      return 100 * UnitHealth(unit) / UnitHealthMax(unit)
    else
      return 200
    end
  end

  function rangeCheck(spellid,unit)
    if IsSpellInRange(GetSpellInfo(spellid),unit) == 1 then
      return true
    end
  end

  function cdRemains(spellid)
    if select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime()) > 0 then 
      return select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime())
    else 
      return 0
    end
  end

  function _LoS(unit,otherUnit)
    if not otherUnit then otherUnit = "player"; end
    if not UnitExists(unit) then return end
    if UnitIsVisible(unit) then
      local X1,Y1,Z1 = ObjectPosition(unit);
      local X2,Y2,Z2 = ObjectPosition(otherUnit);
      return not TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10);
    end
  end

  function _castSpell(spellid,tar)
    if UnitCastingInfo("player") == nil
    and UnitChannelInfo("player") == nil
    and cdRemains(spellid) == 0 
    and UnitIsDead("player") == nil then
      if tar ~= nil
      and rangeCheck(spellid,tar) == nil then
        return false
      elseif tar ~= nil
      and rangeCheck(spellid,tar) == true
      and _LoS(tar) then
        CastSpellByID(spellid, tar)
        return true
      elseif tar == nil then
        CastSpellByID(spellid)
        return true
      else
        return false
      end
    end
  end

  function inEBRange()
    for i = 1, ObjectCount() do 
      local object = ObjectWithIndex(i) 
      if string.find(select(1, ObjectName(object)), "Earthbind Totem") ~= nil 
      and UnitIsFriend("player", object) then 
        if GetDistanceBetweenObjects("player", object) < 12 then
          return true
        else
          return false
        end
      end
    end
  end

  -- Return true if a given type is checked
  function ValidUnitType(unitType, unit)
    local isEnemyUnit = UnitCanAttack("player", unit) == 1
    return (isEnemyUnit and unitType == "enemy")
    or (not isEnemyUnit and unitType == "friend")
  end

  -- Return if a given unit exists, isn't dead
  function ValidUnit(unit, unitType) 
    return UnitExists(unit)==1 and ValidUnitType(unitType, unit)
  end

  ------------------
  --ROTATION START--
  ------------------
  function Rotation()
--Lowest HP Party Member
    local lowest = nil
    for i=1, #PartyUnits do
      if UnitExists(PartyUnits[i])
      and (lowest == nil or getHp(PartyUnits[i]) < getHp(lowest)) then
        lowest = PartyUnits[i]  
      end
    end
--Berserker Rage
    if (
      UnitDebuffID("player", 20066) --repentance
      or UnitDebuffID("player", 6215) --Fear
      or UnitDebuffID("player", 10890) --Psychic Scream
      or UnitDebuffID("player", 6358) --Seduction
      or UnitDebuffID("player", 47860) --death coil
      or UnitDebuffID("player", 17928) --howl of terror
      or UnitDebuffID("player", 1776) --gouge
    )
    then
      _castSpell(18499)
    end
--Shield Wall
    if getHp("player") < 25
    and cdRemains(871) == 0 
    then 
      if GetShapeshiftForm() ~= 2 then
        _castSpell(71)
      end
      _castSpell(871)
      print("shield wall")
      return true
    end
--Enraged Regeneration
    if getHp("player") < 25
    and UnitPower("player") >= 15
    then
      _castSpell(55694)
    end
--Disarm
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if UnitBuffID(unit, 46924) --bladestorm
        or UnitBuffID(unit, 51713) --shadow dance 
        then
          if GetShapeshiftForm() ~= 2 then
            _castSpell(71)
          end
          _castSpell(676, unit)
        end
      end
    end
--Intervene Scatter 3v3
    if UnitDebuffID("party1", 19503) --scatter
    then 
      if GetShapeshiftForm() ~= 2 then
        _castSpell(71)
      end
      _castSpell(3411, "party1") --intervene
    end

    if UnitDebuffID("party2", 19503) --scatter
    then 
      if GetShapeshiftForm() ~= 2 then
        _castSpell(71)
      end
      _castSpell(3411, "party2") --intervene
    end
--Reflect Death Coil
    if not cpoinit then cpoinit = true
      REFLECT = 23920
      -- Spell event table
      spells = {
        -- Warlock
        [47860] = {REFLECT}, --Death Coil
      }
      local SIN_PlayerGUID = UnitGUID("player")
      local SIN_InterruptFrame = CreateFrame("FRAME", nil, UIParent)
      SIN_InterruptFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      SIN_InterruptFrame:SetScript("OnEvent", 
        function(self, event, _, type,  sourceGUID, sourceNAME, _, destGUID, destNAME, _, spellID)

          if type == "SPELL_CAST_SUCCESS" and destGUID == SIN_PlayerGUID and spells[spellID] 
          and UnitPower("player") >= 15
          and GetSpellCooldown(23920) == 0 
          then
            CastSpellByID(REFLECT)
            print("trying to cast REFLECT")
          end		
        end)
      print("REFLECT Frame Inilitized")
    end
--Reflect CC
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #CCList do
          if GetSpellInfo(CCList[i]) == spellName 
          and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < .5 then
              _castSpell(23920, unit)
            end
          end
        end
      end
    end
--Reflect DMG
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #DMGList do
          if GetSpellInfo(DMGList[i]) == spellName 
          and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < .5 then
              _castSpell(23920, unit)
            end
          end
        end
      end
    end
--Heroic Throw Channel
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then 
        if ( UnitChannelInfo(unit) == ("Penance")
          or UnitChannelInfo(unit) == ("Divine Hymn") 
          or UnitChannelInfo(unit) == ("Hymn of Hope") 
          or UnitChannelInfo(unit) == ("Mind Control") 
          or ( UnitBuffID(unit, 31583) --Arcane Empowerment
            and UnitChannelInfo(unit) == ("Arcane Missiles") )
          or UnitChannelInfo(unit) == ("Evocation")
          or UnitChannelInfo(unit) == ("Seduction") )
        and not UnitBuffID(unit, 54748) --Burning Determination
        and not UnitBuffID(unit, 31821) --Aura Mastery
        then
          _castSpell(57755, unit)
        end
      end
    end
--Shield Bash Channel
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then 
        if ( UnitChannelInfo(unit) == ("Penance")
          or UnitChannelInfo(unit) == ("Divine Hymn") 
          or UnitChannelInfo(unit) == ("Hymn of Hope") 
          or UnitChannelInfo(unit) == ("Mind Control") 
          or ( UnitBuffID(unit, 31583) --Arcane Empowerment
            and UnitChannelInfo(unit) == ("Arcane Missiles") )
          or UnitChannelInfo(unit) == ("Evocation")
          or UnitChannelInfo(unit) == ("Seduction") )
        and not UnitBuffID(unit, 54748) --Burning Determination
        and not UnitBuffID(unit, 31821) --Aura Mastery
        then
          _castSpell(72, unit)
        end
      end
    end
--Bash Heal
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #HealList do
            if GetSpellInfo(HealList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .6 then
                _castSpell(72, unit)
              end
            end
          end
        end
      end
    end
--Shattering Throw
    if (
      UnitBuffID("target", 642) ~= nil --divine shield
      or UnitBuffID("target", 10278) ~= nil --HoP
      or UnitBuffID("target", 45438) ~= nil --ice block
    )
    and UnitPower("player")>=22 then 
      _castSpell(2457)
      _castSpell(64382,"target")
    end
--Recklessness
    if getHp("player") > 80
    and getHp("target") < 50
    and rangeCheck(47498,"target") == true --Devastate range
    and cdRemains(1719) == 0 
    then 
      if GetShapeshiftForm() ~= 3 then
        _castSpell(2458)
      end
      _castSpell(1719)
      if GetShapeshiftForm() ~= 2 then
        _castSpell(71)
      end
    end
--Shield Block
    if rangeCheck(47498,"target") == true --Devastate range
    and cdRemains(2565) == 0 then 
      if GetShapeshiftForm() ~= 2 then
        _castSpell(71)
      end
      _castSpell(2565)
    end
--Charge
    if UnitDebuffID("target", 20253) == nil --intercept stun 
    then
      _castSpell(11578, "target")
    end
--Intercept
    if cdRemains(11578) > 0.5
    and cdRemains(11578) < 14.5
    and UnitDebuffID("target", 7922) == nil --charge stun 
    and UnitPower("player") >= 7 then
      _castSpell(20252, "target")
    end
--Concussion Blow
    if rangeCheck(12809,"target") == true
    and UnitDebuffID("target", 7922) == nil --charge stun 
    and UnitDebuffID("target", 20253) == nil --intercept stun 
    and UnitDebuffID("target", 46968) == nil --Shockwave
    and UnitBuffID("target", 642) == nil --divine shield
    and UnitBuffID("target", 10278) == nil --HoP
    and UnitBuffID("target", 48792) == nil --Icebound Fortitude
    and GetSpellCooldown(12809) == 0 
    and UnitPower("player") >= 12
    then
      _castSpell(12809, "target")
    end
--Shockwave
if rangeCheck(47498,"target") == true --Devastate range
and UnitDebuffID("target", 7922) == nil --charge stun 
and UnitDebuffID("target", 20253) == nil --intercept stun 
and UnitBuffID("target", 642) == nil --divine shield
and UnitBuffID("target", 10278) == nil --HoP
and UnitBuffID("target", 48792) == nil --Icebound Fortitude
and _LoS("target")
and cdRemains(46968) == 0
and UnitPower("player") >= 12 then
  local CBlow, _, _, _, _, _, CBExpires = UnitDebuffID("target", 46968)
  if CBlow ~= nil then
    CBExpires =(CBExpires - GetTime())
    if CBExpires < 2 then
      if UnitIsFacing ("player", "target", 90) == false then
        FaceDirection ("target", true)
      end
      if UnitIsFacing ("player", "target", 90) then
      _castSpell(46968)
      end
    end
  else 
    if UnitIsFacing ("player", "target", 90) == false then
      FaceDirection ("target", true)
    end
    if UnitIsFacing ("player", "target", 90) then
    _castSpell(46968)
    end
  end 
end
--Shield Slam
    if rangeCheck(47488,"target") == true
    and UnitPower("player") >= 17
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      _castSpell(47488, "target")
    end
--Revenge
    if rangeCheck(57823,"target") == true
    and GetSpellCooldown(57823) == 0 
    and UnitPower("player") >= 2
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      if GetShapeshiftForm() ~= 2 then
      _castSpell(71)
      end
      _castSpell(57823, "target")
    end
--Rend
    if not UnitDebuffID("target", 47465) 
    and UnitPower("player") >= 7
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      _castSpell(47465, "target")
    end
--Devastate
    if UnitPower("player") >= 9
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      _castSpell(47498, "target")
    end
--Battle Shout
    if not UnitBuffID("player", 47436)
    and UnitPower("player") >= 10
    then
      _castSpell(47436)
    end

  end
----------------
--ROTATION END--
----------------

  rate_counter = 0    
  ahk_rate = 0.10
  enabled = true

  frame = CreateFrame("Frame", nil, UIParent)
  frame:Show()    
  frame:SetScript("OnUpdate", function(self, elapsed)        
      rate_counter = rate_counter + elapsed
      if enabled and rate_counter > ahk_rate then            
        Rotation()            
        rate_counter = 0        
      end    
    end
  )

-- Enable the rotation
  function Disable()
    enabled = false print("Disabled")
  end

-- Disable the rotation     
  function Enable()
    enabled = true print("Enabled")
  end

  function Toggle()
    if enabled then Disable() else Enable() end 
  end

  print("Arc War Prot 3v3")

end

-- Script
if enabled then Disable() else Enable() end