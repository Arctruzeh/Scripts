if not funcs then funcs = true

  PartyList = {
    "player",
    "party1",
    "party2",
    "playerpet",
    "partypet1",
    "partypet2",
  }

  PlayersList = {
    "player",
    "party1",
    "party2",
  }

  EnemyList = {
    "arena1",
    "arena2",
    "arena3",
    "arenapet1",
    "arenapet2",
    "arenapet3",
  }

  HardCCList = {
    10308, --HoJ
    20066, --repentance
    44572, --Deep Freeze
    30283, --Shadowfury
    12826, --Polymorph
    42950, --dragons breath
    6215, --Fear
    10890, --Psychic Scream
    6358, --Seduction
    47860, --death coil
    17928, --howl of terror
    18647, --banish
    60210, --freezing arrow
    14309, --freezing trap
    18658, --hibernate
    51209, --hungering cold
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

  SilenceList = {
    15487, --Silence
    47476, --Strangulate
    55021, --Counter Spell
    34490, --silencing shot
    24259, --spell lock
  }

  RootList = {
    64695, --Earthbind Root
    63685, --enhance nova
    42917, --frost nova
    12494, --frost bite
    33395, --pet nova
    53313, --nature's grasp
    53308, --entangling roots
  }

  SlowList = {
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
    45524, --chains of ice
  }

  DotList = {
    47811, --Immolate
    47813, --corruption
    49233, --flame shock
    48300, --devouring plague
  }

  DKList = {
    55095, --frost fever
    51735, --ebon plague
    55078, --blood plague
  }

  CastList = {
    12826, --Sheep
    28271, --Turtle
    61721, --Rabbit
    61305, --Black Cat
    28272, --Pig
    6358, --Seduction
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

  function PlayerLowest()
    if getHp("player") < getHp("party1")
    and getHp("player") < getHp("party2") then
      return true
    end
  end

  function Party1Lowest()
    if getHp("party1") < getHp("player")
    and getHp("party1") < getHp("party2") then
      return true
    end
  end

  function Party2Lowest()
    if getHp("party2") < getHp("party1")
    and getHp("party2") < getHp("player") then
      return true
    end
  end

  function cdRemains(spellid)
    if select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime()) > 0
    then return select(2,GetSpellCooldown(spellid)) + (select(1,GetSpellCooldown(spellid)) - GetTime())
    else return 0
    end
  end

  function rangeCheck(spellid,unit)
    if IsSpellInRange(GetSpellInfo(spellid),unit) == 1
    then
      return true
    end
  end

  function _LoS(unit,otherUnit)
    if not otherUnit then otherUnit = "player"; end
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
    then
      if tar ~= nil
      and rangeCheck(spellid,tar) == nil
      then
        return false
      elseif tar ~= nil
      and rangeCheck(spellid,tar) == true
      then
        CastSpellByID(spellid, tar)
        return true
      elseif tar == nil
      then
        CastSpellByID(spellid)
        return true
      else
        return false
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
--SWD Hunter
    if not SWDFrame then
      SWDFrame = CreateFrame("Frame", nil, UIParent)
    end
    SWDFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    SWDFrame:SetScript("OnEvent", EventHandler)
    SWD = 48158
    spellIds = {
      [19503] = {SWD}, --Scatter Shot
      [49012] = {SWD} --Wyvern Sting
    }
    function EventHandler(self, event, ...)
      local type,  sourceGUID, sourceNAME, _, destGUID, destNAME, _, sid = select(2, ...)
      if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if type == "SPELL_CAST_SUCCESS" then
          if sid == 48158
          and sourceGUID == UnitGUID("player") then
            print("Success!")
          end
          if spellIds[sid] ~= nil 
          and destGUID == UnitGUID("player") 
          and cdRemains(SWD) == 0 then
            SpellStopCasting()
            TargetNearestEnemy()
            _castSpell(48158, "target")
            TargetLastTarget()
            return
          end
        end
      end
    end
--SWD Cast
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if cdRemains(48158) == 0 then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #CastList do
            if GetSpellInfo(CastList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .6 then
                SpellStopCasting()
                TargetNearestEnemy()
                _castSpell(48158, "target")
                TargetLastTarget()
              end
            end
          end
        end
      end
    end
--Dispel HardCC
    if UnitExists("party1") == 1 
    and _LoS("party1") then
      for i=1, #HardCCList do
        if UnitDebuffID("party1", HardCCList[i]) then
          _castSpell(988, "party1")
        end
      end
    end
    if UnitExists("party2") == 1 
    and _LoS("party2") then
      for i=1, #HardCCList do
        if UnitDebuffID("party2", HardCCList[i]) then
          _castSpell(988, "party2")
        end
      end
    end
--Dispel Silence
    if UnitExists("party1") == 1 
    and _LoS("party1") then
      for i=1, #SilenceList do
        if UnitDebuffID("party1", SilenceList[i]) then
          _castSpell(988, "party1")
        end
      end
    end
    if UnitExists("party2") == 1 
    and _LoS("party2") then
      for i=1, #SilenceList do
        if UnitDebuffID("party2", SilenceList[i]) then
          _castSpell(988, "party2")
        end
      end
    end
--Dispel Root Player
    for _, unit in ipairs(PartyList) do
      if UnitExists("player") == 1 
      and getHp(unit) > 90 then
        if cdRemains(988) == 0
        and rangeCheck(988, "player") == true then
          for i=1, #RootList do
            if UnitDebuffID("player", RootList[i]) then
              _castSpell(988, "player")
            end
          end
        end
      end
    end	
--Dispel Root P1
    for _, unit in ipairs(PartyList) do
      if UnitExists("party1") == 1 
      and getHp(unit) > 90
      and _LoS("party1") then
        if cdRemains(988) == 0
        and rangeCheck(988, "party1") == true then
          for i=1, #RootList do
            if UnitDebuffID("party1", RootList[i]) then
              _castSpell(988, "party1")
            end
          end
        end
      end
    end
--Dispel Root P2
    for _, unit in ipairs(PartyList) do
      if UnitExists("party2") == 1 
      and getHp(unit) > 90
      and _LoS("party2") then
        if cdRemains(988) == 0
        and rangeCheck(988, "party2") == true then
          for i=1, #RootList do
            if UnitDebuffID("party2", RootList[i]) then
              _castSpell(988, "party2")
            end
          end
        end
      end
    end
--Abolish Disease
    --dk
    for i=1, #DKList do
      if UnitDebuffID("player",49194 ) == nil
      and UnitDebuffID("player", DKList[i]) then
        if UnitBuffID("player", 552) == nil then 
          _castSpell(552, "player")
        end
      end
    end
    --feral
    if UnitDebuffID("player", 58181)
    and UnitBuffID("player", 552) == nil then 
      _castSpell(552, "player")
    end
--Fiend Crawl
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if UnitExists("pet") 
        and UnitName("pettarget") == UnitName(unit) then  
          _castSpell(63619, unit)
        end
      end
    end
--SWPain Grounding
    if UnitBuffID("target", 8178) ~= nil 
    and _LoS("target") then
      _castSpell(48125, "target")
    end
--Mind Soothe Reflect
    if UnitBuffID("target", 23920) ~= nil 
    and _LoS("target") then
      _castSpell(453, "target")
    end
--Buff Inner Fire
    if not UnitBuffID("player", 48168) then
      _castSpell(48168)
    end
--Buff Fear Ward 3v3
    if not UnitBuffID("player", 6346)
    and UnitExists("party2") then
      _castSpell(6346, "player")
    end
--Buff Party
    ----fortitude
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 48161)
      and UnitBuffID("player", 32727) then 
        _castSpell(48161, unit)
      end
    end
    ----spirit
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 48073)
      and UnitBuffID("player", 32727) then 
        _castSpell(48073, unit)
      end
    end
    ----shadow protection
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 48169)
      and UnitBuffID("player", 32727) then 
        _castSpell(48169, unit)
      end
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
    enabled = false
	print("Disabled")
  end

  -- Disable the rotation
  function Enable()
    enabled = true
	print("Enabled")
  end
  
  function Toggle()
	if enabled then
		Disable()
	else
		Enable()
	end	
  end
  
  print("Arc Disc")
  
end

-- Script
if enabled then
  Disable()
else
  Enable()
end