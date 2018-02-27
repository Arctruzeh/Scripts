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

  function CanHeal(unit)
    if UnitExists(unit)
    and _LoS(unit)
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

--Pet
    local PetHealth = 100 * UnitHealth("pet") / UnitHealthMax("pet")

    if PetHealth < 35
    and IsUsableSpell("Huddle") == 1
    and UnitExists("target")
    and UnitAffectingCombat("player") == 1 then
      _castSpell(47484)
    end

    if UnitPower("pet") >= 85
    and IsUsableSpell("Claw") == 1
    and UnitExists("target")
    and UnitAffectingCombat("player") == 1 then
      _castSpell(47468, "target")
    end

--Blood Tap
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and rangeCheck(49930, "target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55095) ~= nil --frost fever
    and UnitDebuffID("target", 55078) ~= nil --blood plague
    and ( GetRuneType(1) == 1 or GetRuneType(2) == 1 ) then
      _castSpell(45529)
    end

--Summon Pet
    if UnitExists("playerpet") ~= 1 then
      _castSpell(46584)
    end

--Leap Scatter
    if UnitDebuffID("party1", 19503) then
      _castSpell(47482, "party1	")
      RunMacroText("/petstay")
    end
    if UnitDebuffID("party2", 19503) then
      _castSpell(47482, "party2")
      RunMacroText("/petstay")
    end

--MF Channel
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
          _castSpell(47528, unit)
        end
      end
    end

--Gnaw Channel
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
        then
          _castSpell(47481, unit)
        end
      end
    end

--MF CC
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
                _castSpell(47528, unit)
              end
            end
          end
        end
      end
    end

--Death Grip CC
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #CCList do
          if GetSpellInfo(CCList[i]) == spellName 
          and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < .5 then
              _castSpell(49576, unit)
            end
          end
        end
      end
    end

--Gnaw CC
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #CCList do
          if GetSpellInfo(CCList[i]) == spellName 
          and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < .5 then
              _castSpell(47482, unit)
              _castSpell(47481, unit)
            end
          end
        end
      end
    end

--MF Heal
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then --Valid unit check if the unit is attackable (he can be under mind control u know)
        if not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #HealList do
            if GetSpellInfo(HealList[i]) == spellName 
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .6 then
                _castSpell(47528, unit)
              end
            end
          end
        end
      end
    end

--Empower Rune Wep Garg
    if ValidUnit("target", "enemy")
    and UnitPower("player") >= 35
    and GetSpellCooldown(49206) == 0 then
      _castSpell(47568)
    end

--Summon Garg
    if ValidUnit("target", "enemy")
    and UnitPower("player") >= 60 
    and GetSpellCooldown(49206) == 0 
    and UnitBuffID("target", 45438) == nil --ice block
    then
      _castSpell(49206)
    end

--Strangulate Focus on Garg
    if UnitDebuffID("target", 49206) 
    and not UnitDebuff("focus", "Psychic Scream") 
    and UnitBuffID("target", 48707) == nil --ams
    then
      _castSpell(47476, "focus")
    end

--Eat Pet
    if UnitExists("playerpet") == 1
    and getHp("player") < 60 then
      if UnitPower("player") >= 40 then
        _castSpell(48743)
      end
    end

--Empower Rune Weapon
    if GetRuneCooldown(1) == false 
    and GetRuneCooldown(2) == false 
    and GetRuneCooldown(3) == false 
    and GetRuneCooldown(4) == false 
    and GetRuneCooldown(5) == false 
    and GetRuneCooldown(6) == false then
      _castSpell(47568)
    end

--Blood Tap(for pestilence)
    local dbFrostFever, _, _, _, _, _, dbexpire = UnitDebuffID("target",55095, "player")
    local dbBloodPlague, _, _, _, _, _, BloodPlagueExpire = UnitDebuffID("target",59879, "player")

    if GetRuneCooldown(1) == false 
    or GetRuneCooldown(2) == false then
      if dbBloodPlague ~= nil 
      and dbFrostFever ~= nil 
      then
        BloodPlagueExpire =(BloodPlagueExpire - GetTime())
        dbexpire =(dbexpire - GetTime())
        if BloodPlagueExpire < 5 
        and dbexpire < 5 then
          _castSpell(45529)
        end
      end
    end

--Pet Kill Totems
    for i = 1, ObjectCount() do
      local object = ObjectWithIndex(i)
      if string.find(select(1, ObjectName(object)), "Cleansing Totem") ~= nil  
      and UnitBuffID("target", 8170)
      and UnitIsEnemy(object, "player") 
      and UnitCanAttack("player", object) == 1 then
        RunMacroText("/petattack [@"..object.."]")
      end
    end

--Pestilence
    local dbFrostFever, _, _, _, _, _, dbexpire = UnitDebuffID("target",55095, "player")
    local dbBloodPlague, _, _, _, _, _, BloodPlagueExpire = UnitDebuffID("target",55078, "player")

    if dbBloodPlague ~= nil 
    and dbFrostFever ~= nil 
    and ( GetRuneCooldown(1) == 0 or GetRuneCooldown(2) == 0 )
    then
      BloodPlagueExpire =(BloodPlagueExpire - GetTime())
      dbexpire =(dbexpire - GetTime())
      if BloodPlagueExpire < 3 
      and dbexpire < 3 then
        _castSpell(50842, "target")
      end
    end

--Death Coil Dump
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and UnitPower("player") >= 100 
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitBuffID("target", 47585) == nil --dispersion
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then _castSpell(49895, "target")
    end

--Chains of Ice
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55095) == nil
    and ( GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 ) then
      _castSpell(45524, "target")
    end

--Death Coil Range
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and rangeCheck(49924,"target") ~= true --death strike
    and UnitPower("player") >= 40 
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitBuffID("target", 47585) == nil --dispersion
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then _castSpell(49895, "target")
    end

--Plague Strike
    if UnitExists("target") == 1
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55078) == nil
    and ( GetRuneCooldown(3) == 0 or GetRuneCooldown(4) == 0 ) then
      _castSpell(49921, "target")
    end

--Death Strike
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") < 90
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    and ( GetRuneCooldown(3) == 0 or GetRuneCooldown(4) == 0 )
    and ( GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 ) then
      _castSpell(49924, "target")
    end
--Death Strike 2
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") < 90
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    then
      if 
      (
        (
          ( GetRuneCooldown(1) == 0 and GetRuneType(1) == 4 )
          or
          ( GetRuneCooldown(2) == 0 and GetRuneType(2) == 4 )
        )	
        and 
        ( GetRuneCooldown(3) == 0 or GetRuneCooldown(4) == 0 or GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 )
        ) then
        _castSpell(49924, "target")
      end
    end

--Scourge Strike
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") > 50
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    and ( GetRuneCooldown(3) == 0 or GetRuneCooldown(4) == 0 )
    and ( GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 ) then
      _castSpell(55271, "target")
    end

--Scourge Strike 2
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") > 50
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    then
      if 
      (
        (
          ( GetRuneCooldown(1) == 0 and GetRuneType(1) == 4 ) or ( GetRuneCooldown(2) == 0 and GetRuneType(2) == 4 )
        )	
        and 
        ( GetRuneCooldown(3) == 0 or GetRuneCooldown(4) == 0 or GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 )
        ) then
        _castSpell(55271, "target")
      end
    end

--Blood Strike
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55095) ~= nil --frost fever
    and UnitDebuffID("target", 55078) ~= nil --blood plague
    and (
      ( GetRuneCooldown(1) == 0 and GetRuneType(1) == 1 )
      or 
      ( GetRuneCooldown(2) == 0 and GetRuneType(2) == 1 )
      ) then
      _castSpell(49930, "target")
    end

--Horn of Winter
    local Horn, _, _, _, _, _, hwexpire = UnitBuffID("player", 57623)

    if Horn ~= nil then
      hwexpire =(hwexpire - GetTime())
      if hwexpire < 5 then
        _castSpell(57623)
      end
    else
      _castSpell(57623)
    end

--Bone Shield
    if 
    UnitBuffID("player", 49222) == nil 
    and ( GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 ) then
      _castSpell(49222)
    end

--Chains Range
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and rangeCheck(49924,"target") ~= true --death strike
    and UnitDebuffID("target", 45524) == nil --chains
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and ( GetRuneCooldown(5) == 0 or GetRuneCooldown(6) == 0 ) then 
      _castSpell(45524, "target")
    end

--Death Coil
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and UnitPower("player") >= 40 
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitBuffID("target", 47585) == nil --dispersion
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then _castSpell(49895, "target")
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

  print("Arc DK Unholy 3v3")

end

-- Script
if enabled then
  Disable()
else
  Enable()
end