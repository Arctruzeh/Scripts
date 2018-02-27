if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

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

  function UnitBuffID(unit, id)    
    return UnitBuff(unit, GetSpellInfo(id))
  end

  function UnitDebuffID(unit, id)    
    return UnitDebuff(unit, GetSpellInfo(id))
  end

  function getHp(unit)
    if UnitExists(unit) ~= nil then
      return 100 * UnitHealth(unit) / UnitHealthMax(unit)
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

--Iceblock Low HP
    if getHp("player") < 20 then 
      SpellStopCasting()
      _castSpell(45438)
    end

--Blink Stun
    if UnitDebuffID("player", 10308) ~= nil --hoj
    or UnitDebuffID("player", 20252) ~= nil --intercept
    or UnitDebuffID("player", 8643) ~= nil --kidney
    then 
      _castSpell(1953)
    end

--Fake SWD	
    local Polymorphs = {
      12826, --Sheep
      28271, --Turtle
      61721, --Rabbit
      61305, --Black Cat
      28272, --Pig
    }
    if not SWDFrame  then
      SWDFrame = CreateFrame("Frame", nil, UIParent)
    end
    SWDFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    SWDFrame:SetScript("OnEvent", EventHandler)
    SWD = 48158
    spellIds = {
      [48158] = {SWD},
    }
    function EventHandler(self, event, ...)
      local type,  sourceGUID, sourceNAME, _, destGUID, destNAME, _, sid = select(2, ...)
      if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if type == "SPELL_CAST_SUCCESS" then
          if spellIds[sid] ~= nil 
          and destGUID == UnitGUID("player") then
            local spellName, _, _, _, _, endCast, _, _, canInterrupt = UnitCastingInfo("player")
            for _, v in ipairs(Polymorphs) do
              if GetSpellInfo(v) == spellName and canInterrupt == false then
                SpellStopCasting()	
                print("faked swd")					
                return
              end
            end
          end
        end
      end
    end

--CS Channel 
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
          _castSpell(2139, unit)
        end
      end
    end

--CS CC
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 54748) --Burning Determination
        and not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #CCList do
            if GetSpellInfo(CCList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .5 then
                CastSpellByID(2139, unit)
              end
            end
          end
        end
      end
    end

--CS Heal 
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #HealList do
            if GetSpellInfo(HealList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .6 then
                _castSpell(2139, unit)
              end
            end
          end
        end
      end
    end

--Lance Reflect
    if UnitBuffID("target", 23920) ~= nil then
      SpellStopCasting()
      _castSpell(42914, "target")
    end

--Lance Grounding
    if UnitBuffID("target", 8178) ~= nil then
      SpellStopCasting()
      _castSpell(42914, "target")
    end

--Remove Curse
    if UnitExists("party1") == 1
    and UnitDebuffID("party1", 51514) then 
      _castSpell(475,"party1")
    end
    if UnitExists("party2") == 1
    and UnitDebuffID("party2", 51514) then 
      _castSpell(475,"party2")
    end

--Get Combat vs Rogue
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitExists("party1")
    and UnitAffectingCombat("party1")
    and not UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player") then 
      _castSpell(130, "party1")
    end
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitExists("party2")
    and UnitAffectingCombat("party2")
    and not UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player") then 
      _castSpell(130, "party2")
    end

--Buff Int
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 42995)
      and UnitBuffID("player", 32727) then 
        _castSpell(42995, unit)
      end
    end

--Buff R1 Amp Magic
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 1008)
      and UnitBuffID("player", 32727) then 
        _castSpell(1008, unit)
      end
    end

--Buff Armor
    if UnitBuffID("player", 32727) --prep
    and UnitBuffID("player", 43024) == nil --mage
    and UnitBuffID("player", 43008) == nil --ice
    then 
      _castSpell(43024)
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

  print("Arc Mage 3v3")

end

-- Script
if enabled then
  Disable()
else
  Enable()
end