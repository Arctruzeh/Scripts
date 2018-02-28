if not funcs then funcs = true

  PartyUnits = { "player", "party1", "party2" }

  PartyPetUnits = { "playerpet", "partypet1", "partypet2" }

  PartyList = { "player", "party1", "party2", "playerpet", "partypet1", "partypet2" }

  EnemyList = { "target", "focus", "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" }

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

--Pet Kill Cleansing
  function KillCleansing()
    for i = 1, ObjectCount() do
      local object = ObjectWithIndex(i)
      if string.find(select(1, ObjectName(object)), "Cleansing Totem") ~= nil  
      and UnitIsEnemy(object, "player") 
      and UnitCanAttack("player", object) == 1 then
        RunMacroText("/petattack [@"..object.."]")
      end
    end
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
    if getHp(lowest) < 40 then _castSpell(53480, lowest) end

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
      if ( UnitDebuffID(unit, 19503) or UnitDebuffID(unit, 10308) )
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
    if cdRemains(19263) ~= 0 and cdRemains(53271) ~= 0 and cdRemains(781) ~= 0 then _castSpell(23989) end

--Master's Call
    for _, unit in ipairs(PartyList) do
      if UnitExists(unit) == 1 then
        for i=1, #RootList do
          if UnitDebuffID(unit, RootList[i]) then
            _castSpell(53271, unit)
          end
        end
      end
    end

--Pet Last Stand
    if UnitExists("playerpet") and not UnitBuffID("player", 32727) and getHp("playerpet") < 50 then _castSpell(53478) end

--Mend Pet
    if UnitExists("playerpet")
    and not UnitBuffID("playerpet", 48990)    
    and getHp("playerpet") < 70
    and not UnitIsDeadOrGhost("playerpet") then 
      _castSpell(48990)
    end

--Aspects
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if PlayerMana < 10 and not UnitBuffID("player", 34074) then _castSpell(34074) end

    if PlayerMana > 70 and not UnitBuffID("player", 61847) then _castSpell(61847) end

--Raptor Strike
    if rangeCheck(53339,"target") == true then _castSpell(48996,"target") end

--Mongoose Bite
    _castSpell(53339,"target")

--Wing Clip
    if not UnitDebuffID("target", 2974) then _castSpell(2974,"target") end

--Concussive Shot
    if UnitExists("target")
    and UnitCanAttack("player","target")
    and not UnitBuffID("target", 45438) --ice block
    and not UnitBuffID("target", 642)   --bubble
    and not UnitBuffID("target", 19263) --deterrance
    and not UnitBuffID("target", 31224) --cloak of shadows
    and not UnitBuffID("target", 48707) --anti magic shell
    and not UnitDebuffID("target", 5116)
    and not UnitDebuffID("target", 51724) --sap
    and not UnitDebuffID("target", 33786) --cyclone
    and not UnitDebuffID("target", 12826) --poly
    and not UnitDebuffID("target", 64695) --Earthbind Root
    and not UnitDebuffID("target", 63685) --enhance nova
    and not UnitDebuffID("target", 42917) --frost nova
    and not UnitDebuffID("target", 12494) --frost bite
    and not UnitDebuffID("target", 33395) --pet nova
    and not UnitDebuffID("target", 53313) --nature's grasp
    and not UnitDebuffID("target", 53308) --entangling roots
    and not UnitDebuffID("target", 42842) --frostbolt max rank
    and not UnitDebuffID("target", 116)   --frostbolt r1
    and not UnitDebuffID("target", 42931) --cone of cold
    and not UnitDebuffID("target", 47610) --frostfire bolt
    and not UnitDebuffID("target", 59638) --mirrand images
    and not UnitDebuffID("target", 7321)  --chilled
    and not UnitDebuffID("target", 31589) --slow
    and not UnitDebuffID("target", 49236) --frost shock
    and not UnitDebuffID("target", 3600)  --earthbind
    and not UnitDebuffID("target", 61291) --shadow flame
    and not UnitDebuffID("target", 18118) --conflagrate aftermath daze
    and not UnitDebuffID("target", 58181) --feral disease
    and not UnitDebuffID("target", 3409)  --rogue crippling poison
    and not UnitDebuffID("target", 45524) then --chains of ice
      _castSpell(5116,"target")
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
      if UnitDebuffID("target", 33786) == nil --cyclone
      and UnitBuffID("target", 45438) == nil --ice block
      and UnitBuffID("target", 642) == nil --bubble
      and UnitBuffID("target", 19263) == nil --deterrance
      and UnitBuffID("target", 31224) == nil --cloak of shadows
      then
        _castSpell(19801,"target")
      end
    end

--DMG
    if UnitExists("target")
    and UnitCanAttack("player", "target")
    and not UnitDebuffID("target", 51724) --sap
    and not UnitDebuffID("target", 33786) --cyclone
    and not UnitDebuffID("target", 12826) --poly
    and not UnitBuffID("target", 45438) --ice block
    and not UnitBuffID("target", 642) --bubble
    and not UnitBuffID("target", 19263) then --deterrance

      _castSpell(49050, "target") --Aimed Shot

      if not UnitBuffID("player", 34074) then --Aspect of the Viper

        if not UnitBuffID("target", 31224) --cloak of shadows
        and not UnitBuffID("target", 48707) then --anti magic shell

          if not UnitDebuffID("target", 49001) then --SS
            _castSpell(49001, "target") --SS
          end

          if getHp("target") < 70 then
            _castSpell(20572) --Blood Fury
            _castSpell(3045) --Rapid Fire
          end

          if UnitDebuffID("target", 49001) then --SS
            _castSpell(53209,"target") --Chimera Shot
          end

          _castSpell(49045,"target")--Arcane Shot

          if not UnitDebuffID("target", 53338) then --Hunter's Mark
            _castSpell(53338, "target") --Hunter's Mark
          end

        end

        _castSpell(49052,"target")--Steady Shot

      end

    end

--Trueshot Aura
    if not UnitBuffID("player", 19506) then _castSpell(19506) end

--Call Pet Arena
    if UnitBuffID("player", 32727) then
      if UnitExists("playerpet") ~= 1 then _castSpell(883) end
      if UnitExists("playerpet") == 1 then
        if UnitIsDeadOrGhost("playerpet") then _castSpell(982) end
        if getHp("playerpet") < 100 and not UnitBuffID("playerpet", 48990) then _castSpell(48990) end
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

  print("Arc Hunter MM 3v3")

end

-- Script
if enabled then Disable() else Enable() end