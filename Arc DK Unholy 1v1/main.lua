if not funcs then funcs = true

  PartyList = {
    "player",
    "playerpet",
  }

  EnemyList = {
    "arena1",
    "arenapet1",
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
    58181, --feral disease
    3409 , --rogue crippling poison
    45524, --chains of ice
  }

  DotList = {
    47811, --Immolate
    47813, --corruption
    49233, --flame shock
    48300, --devouring plague
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
--Lichborne
    local spell, _, _, _, _, endTime = UnitCastingInfo("target")
    local spd = UnitCastingInfo("target")
    if spell 
    then
      local finish = endTime/1000 - GetTime()
      if 
      finish < 0.3 
      and 
      not IsUsableSpell("Anti-Magic Shell") then
        if 
        spd == ("Polymorph") 
        or 
        spd == ("Fear")  
        then
          _castSpell(49039)
        end
      end
    end
--Summon Pet
    if
    UnitExists("playerpet") ~= 1
    and
    cdRemains(46584) == 0 then
      _castSpell(46584)
    end
--Horn of Winter
    local Horn, _, _, _, _, _, hwexpire = UnitBuffID("player", 57623)

    if Horn ~= nil
    then
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
    and cdRemains(49222) == 0
    and ( GetRuneCooldown(5) == 0
      or GetRuneCooldown(6) == 0 ) then
      _castSpell(49222)
    end
--Mind Freeze (Target)
    local spell, _, _, _, _, endTime = UnitCastingInfo("target")
    local spd = UnitCastingInfo("target")
    local inRange = IsSpellInRange("Mind Freeze", "target")
    if inRange == 1 then
      if spell then
        castInterruptable = true
        local finish = endTime/1000 - GetTime()
        if finish < 0.4 then
          _castSpell(47528, "target")
        end
      end
    end
--Death and Decay
    if IsLeftAltKeyDown() 
    and not GetCurrentKeyBoardFocus() 
    and not UnitChannelInfo("player") 
    then
      CastSpellByID(49938)
      if SpellIsTargeting() 
      then CameraOrSelectOrMoveStart() CameraOrSelectOrMoveStop() 
      end  
    end
--Eat Pet
    if UnitExists("playerpet") == 1
    and getHp("player") < 60 then
      if UnitPower("player") >= 40 then
        _castSpell(48743)
      end
    end
--Empower Rune Wep Garg
    if UnitPower("player") >= 35
    and GetSpellCooldown(49206) == 0 then
      _castSpell(47568)
    end
--Strangulate on Garg
    if UnitDebuffID("target", 49206) 
	and _LoS("target")
    and not UnitDebuff("target", "Psychic Scream") 
    and UnitBuffID("target", 48707) == nil --ams
    then
      _castSpell(47476, "target")
    end
--Summon Garg
    if UnitPower("player") >= 60 
    and GetSpellCooldown(49206) == 0 
    and UnitBuffID("target", 45438) == nil --ice block
    then
      _castSpell(49206)
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
--Blood Tap
    if UnitExists("target") == 1
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(45529) == 0
    and rangeCheck(49930,"target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55095) ~= nil --frost fever
    and UnitDebuffID("target", 55078) ~= nil --blood plague
    and ( GetRuneType(1) == 1
      or GetRuneType(2) == 1 )
    then
      _castSpell(45529)
    end
--Death Coil Dump
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(49895) == 0
    and rangeCheck(49895,"target") == true
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
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(45524) == 0
    and rangeCheck(45524,"target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitBuffID("target", 48707) == nil --ams
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55095) == nil
    and ( GetRuneCooldown(5) == 0
      or GetRuneCooldown(6) == 0 )
    then
      _castSpell(45524, "target")
    end
--Death Coil Range
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(49895) == 0
    and rangeCheck(49895,"target") == true
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
	and _LoS("target")
    and cdRemains(49921) == 0
    and rangeCheck(49921,"target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 55078) == nil
    and ( GetRuneCooldown(3) == 0
      or GetRuneCooldown(4) == 0 )
    then
      _castSpell(49921, "target")
    end
--Death Strike
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") < 90
    and cdRemains(49924) == 0
    and rangeCheck(49924,"target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    and ( GetRuneCooldown(3) == 0
      or GetRuneCooldown(4) == 0 )
    and ( GetRuneCooldown(5) == 0
      or GetRuneCooldown(6) == 0 )
    then
      _castSpell(49924, "target")
    end
--Death Strike 2
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") < 90
    and cdRemains(49924) == 0
    and rangeCheck(49924,"target") == true
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
          ( GetRuneCooldown(1) == 0
            and GetRuneType(1) == 4 
          )
          or
          ( GetRuneCooldown(2) == 0
            and GetRuneType(2) == 4 
          )
        )	
        and 
        ( GetRuneCooldown(3) == 0
          or GetRuneCooldown(4) == 0 
          or GetRuneCooldown(5) == 0 
          or GetRuneCooldown(6) == 0 
        )
      )
      then
        _castSpell(49924, "target")
      end
    end
--Scourge Strike
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("player") > 50
    and cdRemains(55271) == 0
    and rangeCheck(55271,"target") == true
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    --and UnitDebuffID("target", 55095) ~= nil
    --and UnitDebuffID("target", 55078) ~= nil
    and ( GetRuneCooldown(3) == 0
      or GetRuneCooldown(4) == 0 )
    and ( GetRuneCooldown(5) == 0
      or GetRuneCooldown(6) == 0 )
    then
      _castSpell(55271, "target")
    end
--Blood Strike
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(49930) == 0
    and rangeCheck(49930,"target") == true
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
      ( 
        GetRuneCooldown(1) == 0
        and
        GetRuneType(1) == 1
      )
      or 
      ( 
        GetRuneCooldown(2) == 0
        and
        GetRuneType(2) == 1
      )
    )
    then
      _castSpell(49930, "target")
    end
--Chains Range
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(45524) == 0
    and rangeCheck(45524,"target") == true
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
    and ( GetRuneCooldown(5) == 0
      or GetRuneCooldown(6) == 0 )
    then _castSpell(45524, "target")
    end
--Death Coil
    if UnitExists("target") == 1
	and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and cdRemains(49895) == 0
    and rangeCheck(49895,"target") == true
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
  
  print("Arc DK Unholy 1v1")
  
end

-- Script
if enabled then
  Disable()
else
  Enable()
end