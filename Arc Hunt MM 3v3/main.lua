if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

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
--Kill Shot
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if UnitDebuffID(unit, 51724) == nil --sap
        and UnitDebuffID(unit, 33786) == nil --cyclone
        and UnitDebuffID(unit, 12826) == nil --poly
        and UnitBuffID(unit, 45438) == nil --ice block
        and UnitBuffID(unit, 642) == nil --bubble
        and UnitBuffID(unit, 19263) == nil --deterrance
        and getHp(unit) <= 20 then
          _castSpell(61006, unit)
        end
      end
    end

--Roar of Sacrifice
    for _, unit in ipairs(PlayersList) do
      if getHp(unit) < 40 then 
	      _castSpell(53480,unit)
      end
    end

--Silence CC
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
                SpellStopCasting()
                _castSpell(34490, unit)
              end
            end
          end
        end
      end
    end
	
--Silence Channel
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
          _castSpell(34490, unit)
        end
      end
    end
	
--Trap on Scatter
    for _, unit in ipairs(EnemyList) do
      local X,Y,Z = ObjectPosition(unit)
      if ( UnitDebuffID(unit, 19503) 
        or UnitDebuffID(unit, 10308) )
      and UnitDebuffID(unit, 49001) == nil then
        _castSpell(60192)
        if SpellIsTargeting() then
          ClickPosition(X, Y, Z)
        end
      end
    end

--Scatter Focus
    if UnitDebuffID("focus", 10308) == nil --hoj
    and UnitDebuffID("focus", 20066) == nil --repentance
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
    and UnitDebuffID("focus", 51514) == nil --hex
    and UnitDebuffID("focus", 33786) == nil --cyclone
    and UnitDebuffID("focus", 8983) == nil --bear stun
    and UnitDebuffID("focus", 5246) == nil --intimidating shout
    and UnitBuffID("focus", 642) == nil --divine shield
    and UnitBuffID("focus", 10278) == nil --HoP
    and UnitBuffID("focus", 8178) == nil --grounding
    and UnitPower("player")>=403 then
      _castSpell(19503, "focus")
    end

--Scatter Heal
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
        for i=1, #HealList do
          if GetSpellInfo(HealList[i]) == spellName 
          and canInterrupt == false then
            if ((endCast/1000) - GetTime()) < .9 then
              SpellStopCasting()
              _castSpell(19503, unit)
            end
          end
        end
      end
    end

--Silence Heal
    for _, unit in ipairs(EnemyList) do
      if ValidUnit(unit, "enemy") then
        if not UnitBuffID(unit, 54748) --Burning Determination
        and not UnitBuffID(unit, 31821) --Aura Mastery
        then
          local spellName, _, _, _, startCast, endCast, _, _, canInterrupt = UnitCastingInfo(unit) 
          for i=1, #HealList do
            if GetSpellInfo(HealList[i]) == spellName 
            and cdRemains(19503) > 2
            and canInterrupt == false then
              if ((endCast/1000) - GetTime()) < .5 then
                SpellStopCasting()
                _castSpell(34490, unit)
              end
            end
          end
        end
      end
    end

--Readiness
    if cdRemains(19263) ~= 0
    and cdRemains(53271) ~= 0
    and cdRemains(781) ~= 0 then
      _castSpell(23989)
    end

--Master's Call
    for _, unit in ipairs(PlayersList) do
      if UnitExists(unit) == 1 then
          for i=1, #RootList do
            if UnitDebuffID(unit, RootList[i]) then
              _castSpell(53271, unit)
            end
          end
        end
      end

--Pet Last Stand
    if UnitExists("playerpet") == 1
    and not UnitBuffID("player", 32727)   
    and getHp("playerpet") < 50 then 
      _castSpell(53478)
    end

--Mend Pet
    if UnitExists("playerpet") == 1
    and not UnitBuffID("playerpet", 48990)    
    and getHp("playerpet") < 70
    and not UnitIsDeadOrGhost("playerpet") then 
      _castSpell(48990)
    end
--Aspects
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if PlayerMana < 10 
    and not UnitBuffID("player", 34074) then
      _castSpell(34074)
    end

    if PlayerMana > 90
    and not UnitBuffID("player", 61847) then
      _castSpell(61847)
    end

--Pet Attack Totems
    if UnitExists("mouseover")
    and UnitCreatureType("mouseover") == "Totem" then 
      PetAttack("mouseover")
    end

--Raptor Strike
    if rangeCheck(53339,"target") == true then
      _castSpell(48996,"target")
    end

--Mongoose Bite
    _castSpell(53339,"target")

--Wing Clip
    if UnitDebuffID("target", 2974) == nil then
      _castSpell(2974,"target")
    end

--Concussive Shot
    if UnitExists("target") == 1
    and not UnitDebuffID("target", 5116)
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitDebuffID("target", 64695) == nil --Earthbind Root
    and UnitDebuffID("target", 63685) == nil --enhance nova
    and UnitDebuffID("target", 42917) == nil --frost nova
    and UnitDebuffID("target", 12494) == nil --frost bite
    and UnitDebuffID("target", 33395) == nil --pet nova
    and UnitDebuffID("target", 53313) == nil --nature's grasp
    and UnitDebuffID("target", 53308) == nil --entangling roots
    and UnitDebuffID("target", 42842) == nil --frostbolt max rank
    and UnitDebuffID("target", 116) == nil --frostbolt r1
    and UnitDebuffID("target", 42931) == nil --cone of cold
    and UnitDebuffID("target", 47610) == nil --frostfire bolt
    and UnitDebuffID("target", 59638) == nil --mirrand images
    and UnitDebuffID("target", 7321) == nil --chilled
    and UnitDebuffID("target", 31589) == nil --slow
    and UnitDebuffID("target", 49236) == nil --frost shock
    and UnitDebuffID("target", 3600) == nil --earthbind
    and UnitDebuffID("target", 61291) == nil --shadow flame
    and UnitDebuffID("target", 18118) == nil --conflagrate aftermath daze
    and UnitDebuffID("target", 58181) == nil --feral disease
    and UnitDebuffID("target", 3409) == nil --rogue crippling poison
    and UnitDebuffID("target", 45524) == nil --chains of ice
    then 
      _castSpell(5116,"target")
    end

--Blood Fury
    if UnitExists("target") == 1
    and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("target") < 70 then 
      _castSpell(20572)
    end

--Rapid Fire
    if UnitExists("target") == 1
    and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and getHp("target") < 70 then 
      _castSpell(3045)
    end

--Tranq Shot
    if UnitBuffID("target", 48066) --power word: shield
    or UnitBuffID("target", 32182) --heroism
    or UnitBuffID("target", 2825) --bloodlust
    or UnitBuffID("target", 43309) --ice barrier
    or UnitBuffID("target", 12472) --icy veins
    or UnitBuffID("target", 12042) --arcane power
    or UnitBuffID("target", 12043) --presence of mind
    or UnitBuffID("target", 16188) --shaman nature's swiftness
    or UnitBuffID("target", 17116) --druid nature'es swiftness
    or UnitBuffID("target", 54428) --divine plea
    or UnitBuffID("target", 53601) --sacred shield
    or UnitBuffID("target", 31884) --wings
    or UnitBuffID("target", 64205) --divine sacrifice
    or UnitBuffID("target", 6940) --hand of sacrifice
    or UnitBuffID("target", 10060) --power infusion
    or UnitBuffID("target", 29166) --innervate
    or UnitBuffID("target", 54833) --innervate glyph
    or UnitBuffID("target", 10278) --hand of protection
    or UnitBuffID("target", 498) --divine protection
    or UnitBuffID("target", 1044) --hand of freedom
    or UnitBuffID("target", 64701) --elemental mastery
    or UnitBuffID("target", 16166) --elemantal mastery 2
    or UnitBuffID("target", 6346) --fear ward
    then 
      if rangeCheck(19801,"target") == true
      and _LoS("target")
      and cdRemains(19801) == 0
      and UnitDebuffID("target", 33786) == nil --cyclone
      and UnitBuffID("target", 45438) == nil --ice block
      and UnitBuffID("target", 642) == nil --bubble
      and UnitBuffID("target", 19263) == nil --deterrance
      and UnitBuffID("target", 31224) == nil --cloak of shadows
      then
        _castSpell(19801,"target")
      end
    end

--Aimed Shot
    if UnitExists("target") == 1
    and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    then 
      _castSpell(49050,"target")
    end

--Pet Kill Cleansing
    for i = 1, ObjectCount() do
      local object = ObjectWithIndex(i)
      if string.find(select(1, ObjectName(object)), "Cleansing Totem") ~= nil  
      and UnitBuffID("target", 8170)
      and UnitIsEnemy(object, "player") 
      and UnitCanAttack("player", object) == 1 then
        RunMacroText("/petattack [@"..object.."]")
      end
    end

--Serpent Sting
    if UnitExists("target") == 1
    and _LoS("target")
    and not UnitBuffID("player", 34074)    
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 49001) == nil --ss
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitPower("player") > 454
    and rangeCheck(49001,"target") == true then 
      _castSpell(49001,"target")
    end

--Chimera Shot
    if UnitExists("target") == 1
    and _LoS("target")
    and not UnitBuffID("player", 34074)    
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 49001) ~= nil --ss
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then 
      _castSpell(53209,"target")
    end

--Arcane Shot
    if UnitExists("target") == 1
    and _LoS("target")
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    then 
      _castSpell(49045,"target")
    end

--Hunter's Mark
    if not  UnitDebuffID("target", 53338)
    and _LoS("target")
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 31224) == nil --cloak of shadows
    and UnitBuffID("target", 48707) == nil --anti magic shell
    then
      _castSpell(53338, "target")
    end

--Steady Shot
    if UnitExists("target") == 1
    and _LoS("target")
    and cdRemains(49052) == 0
    and UnitCanAttack("player","target") ~= nil
    and UnitDebuffID("target", 51724) == nil --sap
    and UnitDebuffID("target", 33786) == nil --cyclone
    and UnitDebuffID("target", 12826) == nil --poly
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and rangeCheck(49052,"target") == true then 
      _castSpell(49052,"target")
    end

--Trueshot Aura
    if not UnitBuffID("player", 19506) then
      _castSpell(19506)
    end

--Call Pet Arena
    if UnitExists("playerpet") ~= 1
    and UnitBuffID("player", 32727) then 
      _castSpell(883)
    end

    if UnitExists("playerpet") == 1
    and UnitIsDeadOrGhost("playerpet")
    and UnitBuffID("player", 32727) then 
      _castSpell(982)
    end

    if UnitExists("playerpet") == 1
    and not UnitBuffID("playerpet", 48990)
    and getHp("playerpet") < 100
    and UnitBuffID("player", 32727) then 
      _castSpell(48990)
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

  print("Arc Hunter MM 3v3")

end