if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

  MDList = {
    10278, --hand of protection
    642, --bubble
    45438, --ice block
  }

  HardCCList = {
    10308, --HoJ
    20066, --repentance
    44572, --Deep Freeze
    47847, --Shadowfury
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
    
--[[mc .suicide
if UnitExists("target") 
and UnitDebuffID("target", 605)
and UnitBuffID("player", 605) then
  RunMacroText(".suicide")
end]]

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
    if UnitExists("party1") == 1 then
      for i=1, #HardCCList do
        if UnitDebuffID("party1", HardCCList[i]) then
          _castSpell(988, "party1")
        end
      end
    end
    if UnitExists("party2") == 1 then
      for i=1, #HardCCList do
        if UnitDebuffID("party2", HardCCList[i]) then
          _castSpell(988, "party2")
        end
      end
    end

--Dispel Silence
    if UnitExists("party1") == 1 then
      for i=1, #SilenceList do
        if UnitDebuffID("party1", SilenceList[i]) 
        and UnitClass("party1") ~= "Warrior" 
        and UnitClass("party1") ~= "Rogue" then
          _castSpell(988, "party1")
        end
      end
    end
    if UnitExists("party2") == 1 then
      for i=1, #SilenceList do
        if UnitDebuffID("party2", SilenceList[i]) 
        and UnitClass("party2") ~= "Warrior" 
        and UnitClass("party2") ~= "Rogue" then
          _castSpell(988, "party2")
        end
      end
    end

    --[[Shackle Gargoyle
    for i = 1, ObjectCount() do
      local object = ObjectWithIndex(i)
      if string.find(select(1, ObjectName(object)), "Ebon Gargoyle") ~= nil  
      and UnitIsEnemy(object, "player") 
      and not UnitDebuffID(object, 10955)
      and UnitCanAttack("player", object) == 1 then
        _castSpell(10955, object)
      end
    end
]]
--[[Shackle dk lichbornearena123
    for _, unit in ipairs(EnemyList) do
      if UnitExists(unit) == 1 
      and getHp("player") > 10 then
        if UnitBuffID(unit, 49039) 
        and not UnitDebuffId(unit, 10955) then
          _castSpell(10955, unit)
        end
      end
    end
    ]]
--MD
    for _, unit in ipairs(PartyList) do
      if UnitExists(unit) == 1
      and getHp("player") > 60 then
        for i=1, #MDList do
          local X,Y,Z = ObjectPosition(unit)
          if UnitBuffID(unit, MDList[i]) 
          and UnitBuffID(unit, 33206) == nil then
            _castSpell(32375)
            if SpellIsTargeting() then
              ClickPosition(X, Y, Z)
            end
          end
        end
      end
    end
--Dispel Root Player
    for _, unit in ipairs(PartyList) do
      if UnitExists("player") == 1 
      and getHp(unit) > 90 then
        for i=1, #RootList do
          if UnitDebuffID("player", RootList[i]) then
            _castSpell(988, "player")
          end
        end
      end
    end

--Dispel Root P1
    for _, unit in ipairs(PartyList) do
      if UnitExists("party1") == 1 
      and getHp(unit) > 90 then
        for i=1, #RootList do
          if UnitDebuffID("party1", RootList[i]) then
            _castSpell(988, "party1")
          end
        end
      end
    end

--Dispel Root P2
    for _, unit in ipairs(PartyList) do
      if UnitExists("party2") == 1 
      and getHp(unit) > 90 then
        for i=1, #RootList do
          if UnitDebuffID("party2", RootList[i]) then
            _castSpell(988, "party2")
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
    if UnitBuffID("target", 8178) ~= nil then
      _castSpell(48125, "target")
    end

--Mind Soothe Reflect
    if UnitBuffID("target", 23920) ~= nil then
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
    enabled = false print("Disabled")
  end

  -- Disable the rotation     
  function Enable()
    enabled = true print("Enabled")
  end

  function Toggle()
    if enabled then Disable() else Enable() end 
  end

  print("Arc Disc")

end

-- Script
if enabled then Disable() else Enable() end