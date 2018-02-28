if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

  HardCCList = {
    10308, --HoJ
    20066, --repentance
    44572, --Deep Freeze
    30283, --Shadowfury
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

  function _LoS(unit,otherUnit)
    if not otherUnit then otherUnit = "player"; end
    if UnitIsVisible(unit) then
      local X1,Y1,Z1 = ObjectPosition(unit);
      local X2,Y2,Z2 = ObjectPosition(otherUnit);
      return not TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10);
    end
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
--Lowest HP Party Member
    local lowest = nil
    for i=1, #PartyUnits do
      if UnitExists(PartyUnits[i])
      and (lowest == nil or getHp(PartyUnits[i]) < getHp(lowest)) then
        lowest = PartyUnits[i]  
      end
    end

--Lowest HP Party Member without beacon
    local withoutbeacon = nil
    for i=1, #PartyUnits do
      if UnitExists(PartyUnits[i])
      and UnitBuffID(PartyUnits[i], 53563) == nil
      and (withoutbeacon == nil or getHp(PartyUnits[i]) < getHp(withoutbeacon)) then
        withoutbeacon = PartyUnits[i] 
      end
    end

--Lowest HP Party Pet Member
    local lowestpet = nil
    for i=1, #PartyPetUnits do
      if UnitExists(PartyPetUnits[i])
      and (lowestpet == nil or getHp(PartyPetUnits[i]) < getHp(lowestpet)) then
        lowestpet = PartyPetUnits[i]  
      end
    end

--Divine Shield
    if getHp("player") <= 15 then
      _castSpell(642)
    end

--HoP P1
    if UnitExists("party1") == 1
    and getHp("party1") < 25
    and UnitClass("party1") ~= "Warrior"
    then
      if UnitDebuffID("party1", 57975) ~= nil --wound poison
      or UnitDebuffID("party1", 57970) ~= nil --deadly poison
      or UnitDebuffID("party1", 47486) ~= nil --mortal strike
      or UnitDebuffID("party1", 47465) ~= nil --rend
      or UnitDebuffID("party1", 1715) ~= nil --hamstring
      or UnitDebuffID("party1", 46968) ~= nil --shockwave
      or UnitDebuffID("party1", 12809) ~= nil --concussion blow
      or UnitDebuffID("party1", 19434) ~= nil --aimed shot
      or UnitDebuffID("party1", 49001) ~= nil --serpent sting
      or UnitDebuffID("party1", 5116) ~= nil --concussive shot
      or UnitDebuffID("party1", 58181) ~= nil --infected wounds
      or UnitDebuffID("party1", 49802) ~= nil --maim
      or UnitDebuffID("party1", 48574) ~= nil --rake
      or UnitDebuffID("party1", 50536) ~= nil --unholy blight
      or UnitDebuffID("party1", 51735) ~= nil --ebon plague
      or UnitDebuffID("party1", 55095) ~= nil --frost fever
      or UnitDebuffID("party1", 10308) ~= nil --hoj
      or UnitDebuffID("party1", 54499) ~= nil --heart of the crusader
      or UnitDebuffID("party1", 17364) ~= nil --stormstrike
      then 
        _castSpell(10278,"party1")
      end
    end

--HoP P2
    if UnitExists("party2") == 1
    and getHp("party2") < 25
    and UnitClass("party2") ~= "Warrior"
    then
      if UnitDebuffID("party2", 57975) ~= nil --wound poison
      or UnitDebuffID("party2", 57970) ~= nil --deadly poison
      or UnitDebuffID("party2", 47486) ~= nil --mortal strike
      or UnitDebuffID("party2", 47465) ~= nil --rend
      or UnitDebuffID("party2", 1715) ~= nil --hamstring
      or UnitDebuffID("party2", 46968) ~= nil --shockwave
      or UnitDebuffID("party2", 12809) ~= nil --concussion blow
      or UnitDebuffID("party2", 19434) ~= nil --aimed shot
      or UnitDebuffID("party2", 49001) ~= nil --serpent sting
      or UnitDebuffID("party2", 5116) ~= nil --concussive shot
      or UnitDebuffID("party2", 58181) ~= nil --infected wounds
      or UnitDebuffID("party2", 49802) ~= nil --maim
      or UnitDebuffID("party2", 48574) ~= nil --rake
      or UnitDebuffID("party2", 50536) ~= nil --unholy blight
      or UnitDebuffID("party2", 51735) ~= nil --ebon plague
      or UnitDebuffID("party2", 55095) ~= nil --frost fever
      or UnitDebuffID("party2", 10308) ~= nil --hoj
      or UnitDebuffID("party2", 54499) ~= nil --heart of the crusader
      or UnitDebuffID("party2", 17364) ~= nil --stormstrike
      then 
        _castSpell(10278,"party2")
      end
    end

--Bauble Arena
    if UnitBuffID("player", 59578) 
    and getHp(lowest) < 40 then
      UseItemByName("Bauble of True Blood", lowest)
    end

--Turn Evil Undead Target
    if UnitIsEnemy("player", "target")
    and UnitIsDead("target") == nil
    and UnitCreatureType("target") == "Undead" then 
      _castSpell(10326, "target")
    end

--Hammer of Wrath
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if UnitDebuffID(unit, 51724) == nil --sap
        and UnitDebuffID(unit, 33786) == nil --cyclone
        and UnitDebuffID(unit, 12826) == nil --poly
        and UnitBuffID(unit, 45438) == nil --ice block
        and UnitBuffID(unit, 642) == nil --bubble
        and UnitBuffID(unit, 19263) == nil --deterrance
        and UnitBuffID(unit, 31224) == nil --cloak of shadows
        and getHp(lowest) > 50
        and getHp(unit) <= 20 then
          _castSpell(48806, unit)
        end
      end
    end

--Cleanse Hard CC P1
    if UnitExists("party1") == 1 
    and CanHeal("party1") then
      for i=1, #HardCCList do
        if UnitDebuffID("party1", HardCCList[i]) then
          _castSpell(4987, "party1")
        end
      end
    end

--Cleanse Hard CC P2
    if UnitExists("party2") == 1 
    and CanHeal("party2") then
      for i=1, #HardCCList do
        if UnitDebuffID("party2", HardCCList[i]) then
          _castSpell(4987, "party2")
        end
      end
    end

--Cleanse Silence P1
    if UnitExists("party1") == 1 
    and CanHeal("party1")
    and UnitClass("party1") ~= "Warrior" 
    and UnitClass("party1") ~= "Rogue" then
      for i=1, #SilenceList do
        if UnitDebuffID("party1", SilenceList[i]) then
          _castSpell(4987, "party1")
        end
      end
    end

--Cleanse Silence P2
    if UnitExists("party2") == 1 
    and CanHeal("party2")
    and UnitClass("party2") ~= "Warrior" 
    and UnitClass("party2") ~= "Rogue" then
      for i=1, #SilenceList do
        if UnitDebuffID("party2", SilenceList[i]) then
          _castSpell(4987, "party2")
        end
      end
    end

--Cleanse Root P1 lowest > 60
    if UnitExists("party1") == 1 
    and getHp(lowest) > 60
    and ( UnitClass("party1") == "Warrior" or UnitClass("party1") == "Rogue" or UnitClass("party1") == "Death Knight" ) then
      for i=1, #RootList do
        if UnitDebuffID("party1", RootList[i]) then
          _castSpell(4987, "party1")
        end
      end
    end

--Cleanse Root P2 lowest > 60
    if UnitExists("party2") == 1 
    and getHp(lowest) > 60
    and ( UnitClass("party2") == "Warrior" or UnitClass("party2") == "Rogue" or UnitClass("party2") == "Death Knight" ) then
      for i=1, #RootList do
        if UnitDebuffID("party2", RootList[i]) then
          _castSpell(4987, "party2")
        end
      end
    end

--HoJ CC
    for _, unit in ipairs(EnemyList) do
      local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
      for i=1, #CCList do
        if GetSpellInfo(CCList[i]) == spellName 
        and canInterrupt == false then
          if ((endCast/1000) - GetTime()) < .5 then
            _castSpell(10308, unit)
          end
        end
      end
    end

--Mana Divine Illumination
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if PlayerMana <= 75  then
      _castSpell(31842)
    end

--Mana Divine Plea
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if getHp(lowest) > 80
    and PlayerMana <= 60  then
      _castSpell(54428)
    end

--Freedom P1
    if UnitExists("party1") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("party1", RootList[i]) then
          _castSpell(1044, "party1")
        end
      end
    end

--Freedom P2
    if UnitExists("party2") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("party2", RootList[i]) then
          _castSpell(1044, "party2")
        end
      end
    end

--Heal Pets
    --insta flash of light
    if UnitBuffID("player", 54149) 
    and getHp(lowestpet) < 85
    and getHp(lowestpet) < getHp(lowest) then 
      _castSpell(48785, lowestpet)
    end

    --holy shock
    if getHp(lowestpet) < 85
    and getHp(lowestpet) < getHp(lowest) then 
      _castSpell(48825, lowestpet)
    end

    --flash of light
    if getHp(lowestpet) < 85
    and getHp(lowestpet) < getHp(lowest) then 
      _castSpell(48785, lowestpet)
    end

--Infusion of Light
    if UnitBuffID("player", 54149) 
    and getHp(lowest) < 85 then
      _castSpell(48785, withoutbeacon)
    end

--Divine Favor
    if getHp(lowest) < 50 then
      _castSpell(20216)
    end

--Holy Shock
    if getHp(lowest) < 70 then 
      _castSpell(48825, withoutbeacon)
    end

--Hand of Sacrifice
    if not UnitBuffID("party1", 64205)
    and not UnitBuffID("party2", 64205)
    and getHp("party1") < 45
    and getHp("party1") > 10 then 
      _castSpell(6940,"party1")
    end
    if not UnitBuffID("party1", 64205)
    and not UnitBuffID("party2", 64205)
    and getHp("party2") < 45
    and getHp("party2") > 10 then 
      _castSpell(6940,"party2")
    end

--Divine Sacrifice
    if not UnitBuffID("party1", 6940)
    and not UnitBuffID("party2", 6940)
    and getHp("party1") > 10
    and getHp("party2") > 10
    and ( getHp("party1") < 50 or getHp("party2") < 50 ) then
      _castSpell(64205)
    end

--Flash of Light
    if getHp(lowest) < 85 then 
      _castSpell(48785, withoutbeacon)
    end

--Flash of Light
    if getHp("player") < 95
    and getHp("party1") > 95
    and getHp("party2") > 95 then 
      _castSpell(48785, "player")
    end

--Sacred Shield
    if UnitBuffID(lowest, 53601) == nil
    and getHp("party1") ~= getHp("player")
    and getHp("party1") ~= getHp("party2")
    and getHp(lowest) < 95 then
      _castSpell(53601, lowest)
    end

    if UnitBuffID("player", 32727)
    and UnitBuffID("player", 53601) == nil
    and UnitBuffID("party1", 53601) == nil
    and UnitBuffID("party2", 53601) == nil then 
      _castSpell(53601, "party1")
    end

--Beacon Focus
    if UnitExists("focus") == 1
    and not UnitBuffID("focus", 53563) then 
      _castSpell(53563, "focus")
    end

--Cleanse Root Player
    if UnitExists("player") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("player", RootList[i]) then
          _castSpell(4987, "player")
        end
      end
    end

--Cleanse Root P1
    if UnitExists("party1") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("party1", RootList[i]) then
          _castSpell(4987, "party1")
        end
      end
    end

--Cleanse Root P2
    if UnitExists("party2") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("party2", RootList[i]) then
          _castSpell(4987, "party2")
        end
      end
    end

--Cleanse Slow Player
    if UnitExists("player") == 1 then
      for i=1, #SlowList do
        if UnitDebuffID("player", SlowList[i]) then
          _castSpell(4987, "player")
        end
      end
    end

--Cleanse Slow P1
    if UnitExists("party1") == 1 then
      for i=1, #SlowList do
        if UnitDebuffID("party1", SlowList[i]) then
          _castSpell(4987, "party1")
        end
      end
    end

--Cleanse Slow P2
    if UnitExists("party2") == 1 then
      for i=1, #SlowList do
        if UnitDebuffID("party2", SlowList[i]) then
          _castSpell(4987, "party2")
        end
      end
    end

--Cleanse DoT's P1
    ----dk dots
    if UnitDebuffID("party1", 49194) == nil
    and (
      UnitDebuffID("party1", 55095) --frost fever
      or UnitDebuffID("party1",51735) --ebon plague
      or UnitDebuffID("party1",55078) --blood plague
      ) then 
      _castSpell(4987, "party1")
    end

    ----dots
    if UnitDebuffID("party1", 47811) --Immolate
    or UnitDebuffID("party1", 47813) --corruption
    or UnitDebuffID("party1", 49233) --flame shock
    or UnitDebuffID("party1", 48300) --devouring plague
    then 
      _castSpell(4987,"party1")
    end

--Cleanse DoT's P2
    ----dk dots
    if UnitDebuffID("party2", 49194) == nil
    and (
      UnitDebuffID("party2",55095) --frost fever
      or UnitDebuffID("party2",51735) --ebon plague
      or UnitDebuffID("party2",55078) --blood plague
      ) then 
      _castSpell(4987, "party2")
    end

    ---dots
    if UnitDebuffID("party2", 47811) --Immolate
    or UnitDebuffID("party2", 47813) --corruption
    or UnitDebuffID("party2", 49233) --flame shock
    or UnitDebuffID("party2", 48300) --devouring plague
    then 
      _castSpell(4987,"party2")
    end

--Cleanse DoT's Player
    ----dk dots
    if UnitDebuffID("player",49194) == nil
    and (
      UnitDebuffID("player",55095) --frost fever
      or UnitDebuffID("player",51735) --ebon plague
      or UnitDebuffID("player",55078) --blood plague
      ) then 
      _castSpell(4987, "player")
    end

    ----dots
    if UnitDebuffID("player", 47811) --Immolate
    or UnitDebuffID("player", 47813) --corruption
    or UnitDebuffID("player", 49233) --flame shock
    or UnitDebuffID("player", 48300) --devouring plague
    then _castSpell(4987,"player")
    end

--Judgement of Light
    if UnitExists("target") == 1
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitBuffID("target", 48707) == nil --AMS
    then
      _castSpell(20271,"target")
    end

--Shield of Righteousness
    if UnitExists("target") == 1
    and UnitPower("player") > 26
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --anti magic shell
    then 
      _castSpell(61411,"target")
    end

--Buff Seal of Light
    if not UnitBuffID("player", 20165)
    and not UnitBuffID("player", 20166)
    and not UnitBuffID("player", 31801) then
      _castSpell(20165)
    end

--Buff Righteous Fury
    if not UnitBuffID("player", 25780) then
      _castSpell(25780)
    end

--Buff Kings
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 20217)
      and UnitPower("player")>=5000 then 
        _castSpell(20217, unit)
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

  print("Arc Paladin Holy")

end

-- Script
if enabled then Disable() else Enable() end