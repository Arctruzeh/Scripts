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
    18658, --Hibernate
    6215, --Fear
    17928, --Howl of Terror
    605, --Mind Control
    33786, --clone
    49803, --pounce
    8983, --bash
    51724, --sap
    2094, --blind
    1833, --cheap shot
    8643, --kidney
    51722, --dismantle
    10308, --hoj
    20066, --repentance
    47481, --gnaw
    7922, --charge
    20253, --intercept
    12809, --concussion blow
    46968, --shockwave
    676, --disarm
    19503, --scatter
    60210, --freezing arrow effect
    14309, --freezing trap effect
    64346, --fire mage disarm
    42950, --dragon's breath
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

  CastList = {
    --Shaman
    49276, --Lesser Healing Wave : Rank 9
    49273, --Healing Wave
    51514, --Hex
    --Paladin
    48785, --Flash of Light
    48782, --Holy Light
    --Priest
    48071, --Flash Heal
    48120, --Binding Heal
    605, --Mind Control
    --Druid
    48443, --Regrowth
    50464, --Nourish
    48378, --Healing Touch
    33786, --Cyclone
    18658, --Hibernate
    53308, --Entangline Roots
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

  --[[function WillDC()
    for i=1, #CCList do
      if UnitBuffID("player", 19263) --deterrance
      or UnitDebuffID("player", CCList[i]) then
        return true
      else
        return false
      end
    end
  end]]

  function WillDC()
    if UnitBuffID("player", 19263) --deterrance
    or UnitBuffID("player", 10278) --HoP
    --mage
    or UnitDebuffID("player", 51514) --Hex
    or UnitDebuffID("player", 12826) --Sheep
    or UnitDebuffID("player", 28271) --Turtle
    or UnitDebuffID("player", 61721) --Rabbit
    or UnitDebuffID("player", 61305) --Black Cat
    or UnitDebuffID("player", 28272) --Pig
    or UnitDebuffID("player", 64346) --fire mage disarm
    or UnitDebuffID("player", 42950) --dragon's breath
    or UnitDebuffID("player", 44572) --deep freeze
    --druid
    or UnitDebuffID("player", 33786) --Cyclone
    or UnitDebuffID("player", 18658) --Hibernate
    or UnitDebuffID("player", 49803) --pounce
    or UnitDebuffID("player", 8983) --bash
    --warlock
    or UnitDebuffID("player", 6215) --Fear
    or UnitDebuffID("player", 17928) --Howl of Terror
    or UnitDebuffID("player", 6358) --Seduction
    or UnitDebuffID("player", 47847) --Shadowfury
    or UnitDebuffID("player", 47860) --Death Coil
    --priest
    or UnitDebuffID("player", 605) --Mind Control
    or UnitDebuffID("player", 10890) --Psychic Scream
    or UnitDebuffID("player", 64044) --Psychic Horror
    --rogue
    or UnitDebuffID("player", 51724) --sap
    or UnitDebuffID("player", 2094) --blind
    or UnitDebuffID("player", 1833) --cheap shot
    or UnitDebuffID("player", 8643) --kidney
    or UnitDebuffID("player", 51722) --dismantle
    or UnitDebuffID("player", 1776) --Gouge
    --paladin
    or UnitDebuffID("player", 10308) --hoj
    or UnitDebuffID("player", 20066) --repentance
    --dk
    or UnitDebuffID("player", 47481) --gnaw
    or UnitDebuffID("player", 51209) --Hungering Cold
    --shaman
    or UnitDebuffID("player", 51514) --Hex
    --warrior
    or UnitDebuffID("player", 7922) --charge
    or UnitDebuffID("player", 20253) --intercept
    or UnitDebuffID("player", 12809) --concussion blow
    or UnitDebuffID("player", 46968) --shockwave
    or UnitDebuffID("player", 676) --disarm
    --hunter
    or UnitDebuffID("player", 19503) --scatter
    or UnitDebuffID("player", 60210) --freezing arrow effect
    or UnitDebuffID("player", 14309) --freezing trap effect
    then
      return true
    else
      return false
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

--Volley+Aspect of the Viper
  function Volley()
    if enabled then Disable() end
    if not UnitBuffID("player", 34074) then _castSpell(34074) end
    _castSpell(58434)
    if SpellIsTargeting() then CameraOrSelectOrMoveStart() CameraOrSelectOrMoveStop() end
    --if enabled then Disable() else Enable() end
  end

  ------------------
  --ROTATION START--
  ------------------
  function Rotation()

--freezing arrow focus
if UnitExists("focus") == 1 
and GetKeyState(0xC0) == true then --tilde ~
  local X,Y,Z = ObjectPosition("focus")
  _castSpell(60192)
  if SpellIsTargeting() then
    ClickPosition(X, Y, Z)
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

--Mend Pet
      if UnitExists("playerpet")
      and not UnitBuffID("playerpet", 48990)    
      and getHp("playerpet") < 80
      and not UnitIsDeadOrGhost("playerpet") then 
        _castSpell(48990)
      end

--Hunter's Mark on Rogue
      for _, unit in ipairs(EnemyList) do
        if ValidUnit(unit, "enemy")
        and UnitClass(unit) == "Rogue"
        and not UnitDebuffID(unit, 53338) then
          _castSpell(53338, unit)
        end
      end
      
--Freezing Arrow on Focus Cast/Channel
      if ValidUnit("focus", "enemy") then 
        local X,Y,Z = ObjectPosition("focus")
        local name, _, _, _, _, _, _, _, _ = UnitCastingInfo("focus") 
        for i=1, #CastList do
          if ( UnitChannelInfo("focus") == ("Penance")
            or UnitChannelInfo("focus") == ("Divine Hymn") 
            or UnitChannelInfo("focus") == ("Hymn of Hope") 
            or UnitChannelInfo("focus") == ("Mind Control") )
          or GetSpellInfo(CastList[i]) == name then
            _castSpell(60192)
            if SpellIsTargeting() then
              ClickPosition(X, Y, Z)
            end
          end
        end
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

--Pet Attack
      if UnitExists("target")
      and UnitExists("playerpet")
      and UnitCanAttack("player", "target")
      --and WillDC() == false
      and GetDistanceBetweenObjects ("playerpet", "target") < 36
      and _LoS("target")
      and ( GetDistanceBetweenObjects ("playerpet", "target") >= 6 or UnitPower("playerpet") == 100 ) then 
        RunMacroText("/petattack target")
      end

--Concussive Shot
      if UnitExists("target")
      and UnitCanAttack("player", "target")
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
      and GetDistanceBetweenObjects ("player", "target") < 36
      and _LoS("target")
      and not UnitDebuffID("target", 51724) --sap
      and not UnitDebuffID("target", 33786) --cyclone
      and not UnitDebuffID("target", 12826) --poly
      and not UnitBuffID("target", 45438) --ice block
      and not UnitBuffID("target", 642) --bubble
      and not UnitBuffID("target", 19263) then --deterrance

        _castSpell(49050, "target") --Aimed Shot

        if not UnitBuffID("player", 34074) then --Aspect of the Viper

          --Pet
          if UnitExists("playerpet") and getHp("target") < 80 then
            if GetDistanceBetweenObjects ("playerpet", "target") > 8
            and GetDistanceBetweenObjects ("playerpet", "target") < 25 then
              _castSpell(61685, "target") --Charge
            end
            if GetDistanceBetweenObjects ("playerpet", "target") > 5 then
              _castSpell(61684, "target") --Dash
            end
            _castSpell(19574) --Besial Wrath
            _castSpell(34026) --Kill Command
            _castSpell(3045) --Rapid Fire
            _castSpell(20572) --Blood Fury
            _castSpell(53401) --Rabid
            _castSpell(53434) --Call of the Wild
            if not UnitBuffID("target", 48792) then --ibf
              _castSpell(19577) --Intimidation
            end
          end

          if not UnitBuffID("target", 31224) --cloak of shadows
          and not UnitBuffID("target", 48707) then --anti magic shell

            _castSpell(49045,"target")--Arcane Shot

            if not UnitDebuffID("target", 49001) then --SS
              for i = 1, ObjectCount() do
                local object = ObjectWithIndex(i)
                if string.find(select(1, ObjectName(object)), "Cleansing Totem") == nil then
                  _castSpell(49001, "target") --SS
                end
              end
            end

            if not UnitDebuffID("target", 53338) 
            and UnitClass("arena1") ~= "Rogue"
            and UnitClass("arena2") ~= "Rogue"
            and UnitClass("arena3") ~= "Rogue" then --Hunter's Mark
              _castSpell(53338, "target") --Hunter's Mark
            end

          end

          _castSpell(49052,"target")--Steady Shot

        end

      end

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
      if enabled and rate_counter > ahk_rate and WillDC() == false then            
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

  print("Arc Hunter BM BG")

end

-- Script
if enabled then Disable() else Enable() end