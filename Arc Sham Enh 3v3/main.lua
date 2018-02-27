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
    64695, --Earthbind Root
    63685, --enhance nova
    42917, --frost nova
    12494, --frost bite
    33395, --pet nova
    53313, --nature's grasp
    53308, --entangling roots
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

--Hex Focus
    local _,_,_,hasMaelstrom = UnitBuffID("player", 53817)

    if hasMaelstrom == 5
    and UnitDebuffID("focus", 20066) == nil --repentance
    and UnitDebuffID("focus", 10308) == nil --hoj
    and UnitDebuffID("focus", 44572) == nil --deep freeze
    and UnitDebuffID("focus", 30283) == nil --shadowfury
    and UnitDebuffID("focus", 15487) == nil --silence
    and UnitDebuffID("focus", 12826) == nil --polymorph
    and UnitDebuffID("focus", 47476) == nil --strangulate
    and UnitDebuffID("focus", 6215) == nil --fear
    and UnitDebuffID("focus", 10890) == nil --psychic scream
    and UnitDebuffID("focus", 6358) == nil --seduction
    and UnitDebuffID("focus", 2139) == nil --counter spell
    and UnitDebuffID("focus", 17928) == nil --howl of terror
    and UnitDebuffID("focus", 60210) == nil --freezing arrow
    and UnitDebuffID("focus", 14309) == nil --freezing trap
    and UnitDebuffID("focus", 2094) == nil --blind
    and UnitDebuffID("focus", 1776) == nil --gouge
    and UnitDebuffID("focus", 1833) == nil --cheapshot
    and UnitDebuffID("focus", 8643) == nil --kidney
    and UnitDebuffID("focus", 33786) == nil --cyclone
    and UnitDebuffID("focus", 8983) == nil --bear stun
    and UnitDebuffID("focus", 5246) == nil --intimidating shout
    and UnitBuffID("focus", 642) == nil --divine shield
    and UnitBuffID("focus", 10278) == nil --HoP
    and UnitBuffID("focus", 8178) == nil --grounding
    and UnitBuffID("focus", 48707) == nil --AMS
    and UnitBuffID("focus", 48792) == nil --IBF
    and UnitBuffID("focus", 31224) == nil --cloak of shadows
    and UnitBuffID("focus", 23920) == nil --reflect
    and UnitPower("player") >= 131 then
      _castSpell(51514, "focus")
    end
--Stoneclaw
    if getHp("player") <= 60 then
      _castSpell(58582)
    end
--Gift of Naruu
    if getHp("player") <= 60 then
      _castSpell(59547)
    end
--Blood Fury
    if UnitExists("target") == 1
    and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("target") < 70 then 
      _castSpell(33697)
    end
--Bloodlust
    if UnitExists("target") == 1
    and _LoS("target")
  	and rangeCheck(17364, "target") == true
    and UnitCanAttack("player","target") ~= nil
  	and UnitDebuffID("player", 57724) == nil
    and getHp("target") < 70 then 
      _castSpell(2825)
    end
--Feral Spirit
    if UnitExists("target") == 1
    and _LoS("target")
  	and rangeCheck(17364, "target") == true
    and UnitCanAttack("player","target") ~= nil
    and getHp("target") < 70 then 
      _castSpell(51533)
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
--Heal 3v3
    local _,_,_,hasMaelstrom = UnitBuffID("player", 53817)

    if getHp(lowest) < 80 
    and hasMaelstrom == 5 then 
      _castSpell(49273, lowest)
    end
--Frost Shock 15yds <=
    if ValidUnit("target", "enemy")
	and GetDistanceBetweenObjects("player", "target") >= 15 then
      _castSpell(49236,"target")
    end
--Purgeb4dmg
    if ValidUnit("target", "enemy") 
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      for i=1, #Purgeb4dmgList do
        if UnitBuffID("target", Purgeb4dmgList[i]) then
          _castSpell(8012,"target")
        end
      end
    end
--Stormstrike
    if ValidUnit("target", "enemy") 
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 10278) == nil --hand of protection
    and rangeCheck(17364, "target") == true
    and _LoS("target")
    then
      RunMacroText("/startattack")
      RunMacroText("/petattack")
      _castSpell(17364,"target")
    end
--Insta Lightning
    local _,_,_,hasMaelstrom = UnitBuffID("player", 53817)
    if hasMaelstrom == 5 
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    then
      _castSpell(49238,"target")
    end
--Flame Shock
    if UnitDebuffID("target", 49233) == nil
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    then
      _castSpell(49233,"target")
    end
--Earthbind
    for i=1, #EBindList do
      if UnitDebuffID("player", EBindList[i]) then
        _castSpell(2484)
      end
    end
--Purge
    if ValidUnit("target", "enemy") 
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then
      for i=1, #PurgeList do
        if UnitBuffID("target", PurgeList[i]) then
          _castSpell(8012,"target")
        end
      end
    end
--Ghost Wolf
    if UnitExists("target") == 1
    and IsMounted() ~= 1
    and not UnitIsDeadOrGhost("target")
    and not UnitIsDeadOrGhost("player")
    and UnitCanAttack("player","target") ~= nil
    and not UnitBuffID("player", 2645)
    and rangeCheck(17364, "target") ~= true then
      _castSpell(2645)
    end

    if UnitExists("target") == 1
    and IsMounted() ~= 1
    and not UnitIsDeadOrGhost("target")
    and not UnitIsDeadOrGhost("player")
    and UnitCanAttack("player","target") ~= nil
    and UnitBuffID("player", 2645)
    and rangeCheck(17364, "target") == true then
      RunMacroText("/cancelaura Ghost Wolf")
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
--Buff
    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 546)
      and UnitBuffID("player", 32727) then 
        _castSpell(546, unit)
      end
    end

    for _, unit in ipairs(PartyList) do
      if not UnitBuffID(unit, 131)
      and UnitBuffID("player", 32727) then 
        _castSpell(131, unit)
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

  print("Arc Sham Enh 3v3")

end

-- Script
if enabled then
  Disable()
else
  Enable()
end