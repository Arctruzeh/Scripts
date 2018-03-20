if not funcs then funcs = true

  TrinketList = {
    20066, --repentance
    12826, --Sheep
    28271, --Turtle
    61721, --Rabbit
    61305, --Black Cat
    28272, --Pig
    42950, --dragons breath
    6215,  --Fear
    10890, --Psychic Scream
    6358,  --Seduction
    47860, --death coil
    17928, --howl of terror
    18647, --banish
    60210, --freezing arrow
    14309, --freezing trap
    51209, --hungering cold
    51514, --Hex
    33786, --Cyclone
    605, --Mind Control
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

--Divine Shield
    if getHp("player") <= 20 then
      _castSpell(642)
    end
--Every Man for Himself
    for i=1, #TrinketList do
      if UnitDebuffID("player", TrinketList[i]) then
        _castSpell(59752)
      end
    end
--Divine Protection
    if cdRemains(642) > 10
    and getHp("player") <= 10 
    and UnitDebuffID("player",25771 ) == nil then
      _castSpell(498)
    end
--HoF Stun Player
    if UnitDebuffID("player", 10308) --HoJ
    or UnitDebuffID("player", 44572) --Deep Freeze
    or UnitDebuffID("player", 47847) --Shadowfury
    or UnitDebuffID("player", 8643) --kidney
    then _castSpell(1044,"player")
    end
--Hammer of Wrath Target
    if UnitExists("target") == 1
    and UnitPower("player") > 527
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and getHp("target") <= 20 then
      _castSpell(48806, "target")
    end
--Mana Divine Plea
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")
    if PlayerMana <= 60  then
      _castSpell(54428)
    end
--Repentance target
    if UnitDebuffID("target", 10308) == nil --hoj
    and UnitDebuffID("target", 44572) == nil --deep freeze
    and UnitDebuffID("target", 47847) == nil --shadowfury
    and UnitDebuffID("target", 15487) == nil --silence
    and UnitDebuffID("target", 12826) == nil --polymorph
    and UnitDebuffID("target", 47476) == nil --strangulate
    and UnitDebuffID("target", 6215) == nil --fear
    and UnitDebuffID("target", 10890) == nil --psychic scream
    and UnitDebuffID("target", 6358) == nil --seduction
    and UnitDebuffID("target", 2139) == nil --counter spell
    and UnitDebuffID("target", 17928) == nil --howl of terror
    and UnitDebuffID("target", 60210) == nil --freezing arrow
    and UnitDebuffID("target", 14309) == nil --freezing trap
    and UnitDebuffID("target", 2094) == nil --blind
    and UnitDebuffID("target", 1776) == nil --gouge
    and UnitDebuffID("target", 1833) == nil --cheapshot
    and UnitDebuffID("target", 8643) == nil --kidney
    and UnitDebuffID("target", 51514) == nil --hex
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 8983) == nil --bear stun
    and UnitDebuffID("target", 5246) == nil --intimidating shout
    and UnitBuffID("target", 642) == nil --divine shield
    and UnitBuffID("target", 10278) == nil --HoP
    and UnitBuffID("target", 8178) == nil --grounding
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48792) == nil --IBF
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitPower("player")>=550 then
      _castSpell(20066, "target")
    end
--HoJ target
    if UnitDebuffID("target", 20066) == nil --repentance
    and UnitDebuffID("target", 44572) == nil --deep freeze
    and UnitDebuffID("target", 47847) == nil --shadowfury
    and UnitDebuffID("target", 15487) == nil --silence
    and UnitDebuffID("target", 12826) == nil --polymorph
    and UnitDebuffID("target", 47476) == nil --strangulate
    and UnitDebuffID("target", 6215) == nil --fear
    and UnitDebuffID("target", 10890) == nil --psychic scream
    and UnitDebuffID("target", 6358) == nil --seduction
    and UnitDebuffID("target", 2139) == nil --counter spell
    and UnitDebuffID("target", 17928) == nil --howl of terror
    and UnitDebuffID("target", 60210) == nil --freezing arrow
    and UnitDebuffID("target", 14309) == nil --freezing trap
    and UnitDebuffID("target", 2094) == nil --blind
    and UnitDebuffID("target", 1776) == nil --gouge
    and UnitDebuffID("target", 1833) == nil --cheapshot
    and UnitDebuffID("target", 8643) == nil --kidney
    and UnitDebuffID("target", 51514) == nil --hex
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 8983) == nil --bear stun
    and UnitDebuffID("target", 5246) == nil --intimidating shout
    and UnitBuffID("target", 642) == nil --divine shield
    and UnitBuffID("target", 10278) == nil --HoP
    and UnitBuffID("target", 8178) == nil --grounding
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48792) == nil --IBF
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitPower("player")>=314 then
      _castSpell(10308, "target")
    end
--Insta Heal Player
    if UnitBuffID("player", 59578) 
    and getHp("player") < 85 then
      _castSpell(48785,"player")
    end
--AoW Exorcism
    if UnitExists("target") == 1
    and UnitBuffID("player", 59578) 
    and UnitPower("player") > 520
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitBuffID("target", 48707) == nil --AMS
    then
      _castSpell(48801,"target")
    end
--Judgement of Wisdom
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")
    if UnitExists("target") == 1
    and PlayerMana <= 50 
    and UnitPower("player") > 197
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48066) == nil --PW:S
    and UnitBuffID("target", 43039) == nil --Ice Barrier
    then
      _castSpell(53408,"target")
    end
--Judgement of Light
    if UnitExists("target") == 1
    and getHp("player") <= 75 
    and UnitPower("player") > 197
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48066) == nil --PW:S
    and UnitBuffID("target", 43039) == nil --Ice Barrier
    then
      _castSpell(20271,"target")
    end
--Judgement of Justice
    if UnitExists("target") == 1
    and UnitPower("player") > 197
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48066) == nil --PW:S
    and UnitBuffID("target", 43039) == nil --Ice Barrier
    then
      _castSpell(53407,"target")
    end
--Crusader Strike
    if UnitExists("target") == 1
    and UnitPower("player") > 197
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    then
      _castSpell(35395, "target")
    end
--Divine Storm
    if UnitExists("target") == 1
    and UnitCanAttack("player", "target")
    and _LoS("target")
    and GetDistanceBetweenObjects ("player", "target") < 9
    and UnitPower("player") > 700
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    then
      _castSpell(53385)
    end
--Sacred BG Player
    if not UnitBuffID("player", 53601) 
    and IsMounted() == nil then
      _castSpell(53601, "player")
    end
--Cleanse Root Player
    for i=1, #RootList do
      if UnitDebuffID("player", RootList[i]) then _castSpell(4987, "player") end
    end
--Cleanse Slow Player
    for i=1, #SlowList do
      if UnitDebuffID("player", SlowList[i]) then _castSpell(4987, "player") end
    end
--Buff
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if PlayerMana > 50 and IsMounted() == nil then
      --Buff Righteous Fury
      if not UnitBuffID("player", 25780) then _castSpell(25780) end
      --Buff Seal of Righteousness
      if not UnitBuffID("player", 21084) then _castSpell(21084) end
      --Buff Kings
      if not UnitBuffID("player", 20217) then _castSpell(20217) end
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

  print("Arc Pala Ret BG")

end

-- Script
if enabled then Disable() else Enable() end