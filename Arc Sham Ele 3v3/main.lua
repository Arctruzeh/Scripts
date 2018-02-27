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

--Stoneclaw
    if getHp("player") <= 60 then
      _castSpell(58582)
    end
--Gift of Naruu
    if getHp("player") <= 60 then
      _castSpell(59547)
    end
--Shear CC
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 54748) --Burning Determination
        and not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #CCList do
            if GetSpellInfo(CCList[i]) == spellName 
            and canInterrupt == false 
            and _LoS(unit) then
              if ((endCast/1000) - GetTime()) < .5 then
                SpellStopCasting()
                CastSpellByID(57994, unit)
              end
            end
          end
        end
      end
    end
--Ground CC 
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then 
        if ( cdRemains(57994) ~= 0 --wind sheer on cd
          or UnitBuffID(unit, 54748) --Burning Determination
          or UnitBuffID(unit, 31821) --Aura Mastery 
          ) then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #CCList do
            if GetSpellInfo(CCList[i]) == spellName then
              if ((endCast/1000) - GetTime()) < .6 
              and _LoS(unit) then
                SpellStopCasting()
                _castSpell(8177)
              end
            end
          end
        end
      end
    end
--Shear Channel 
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
        and _LoS(unit)
        then
          _castSpell(57994, unit)
        end
      end
    end
--Shear Heal 
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #HealList do
            if GetSpellInfo(HealList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .6 
              and _LoS(unit) then
                SpellStopCasting()
                _castSpell(57994, unit)
              end
            end
          end
        end
      end
    end
--Ground DMG 
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #DMGList do
          if GetSpellInfo(DMGList[i]) == spellName then
            if ((endCast/1000) - GetTime()) < .6 then
              SpellStopCasting()
              _castSpell(8177)
            end
          end
        end
      end
    end
--Get Combat vs Rogue
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitExists("party1")
    and UnitAffectingCombat("party1")
    and not UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player") then 
      _castSpell(131, "party1")
    end
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitExists("party2")
    and UnitAffectingCombat("party2")
    and not UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player") then 
      _castSpell(131, "party2")
    end
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player")
    and UnitExists("party1")
    and not UnitAffectingCombat("party1") then 
      _castSpell(131, "party1")
    end
    if (UnitClass("arena1") == "Rogue"
      or UnitClass("arena2") == "Rogue"
      or UnitClass("arena3") == "Rogue")
    and UnitAffectingCombat("player")
    and not UnitIsDeadOrGhost("player")
    and UnitExists("party2")
    and not UnitAffectingCombat("party2") then 
      _castSpell(131, "party2")
    end
--Cleansing Totem
    local c = GetTotemTimeLeft(3)
    if UnitDebuffID("player", 55095) ~= nil --DK Disease
    or UnitDebuffID("player", 57975) ~= nil --Wound Poison
    or UnitDebuffID("player", 57970) ~= nil --Stacking Poison
    or UnitDebuffID("player", 58181) ~= nil --Infected Wounds 
    then 
      if c == 0 then
        _castSpell(8170)
      else
        return false
      end
    end
--Water Shield
    if UnitBuffID( "player", 57960 ) == nil then
      _castSpell(57960)
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

  print("Arc Sham Ele 3v3")

end

-- Script
if enabled then
  Disable()
else
  Enable()
end