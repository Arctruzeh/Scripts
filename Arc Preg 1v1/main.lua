if not funcs then funcs = true

  StunList = {
    10308, --HoJ
    44572, --Deep Freeze
    8643, --Kidney Shot
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

  DKList = {
    55095, --frost fever
    51735, --ebon plague
    55078, --blood plague
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
--Divine Protection
    if cdRemains(642) > 10
    and getHp("player") <= 10 
    and UnitDebuffID("player",25771 ) == nil then
      _castSpell(498)
    end
--HoF Stun Player
    if UnitDebuffID("player", 10308) --HoJ
    or UnitDebuffID("player", 44572) --Deep Freeze
    or UnitDebuffID("player", 30283) --Shadowfury
    or UnitDebuffID("player", 8643) --kidney
    then _castSpell(1044,"player")
    end
--Turn Evil Undead Target
    if UnitExists("target") == 1
    and UnitIsEnemy("player", "target")
    and UnitIsDead("target") == nil
    and UnitCreatureType("target") == "Undead" then 
      _castSpell(10326, "target")
    end
--Turn Evil Gargoyle
for i = 1, ObjectCount() do
  local object = ObjectWithIndex(i)
  if string.find(select(1, ObjectName(object)), "Ebon Gargoyle") ~= nil  
  and UnitIsEnemy(object, "player") 
  and not UnitDebuffID(object, 10326)
  and UnitCanAttack("player", object) == 1 then
    _castSpell(10326, object)
  end
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
--HoJ Arena1
    if UnitExists("arena1") == 1
    and UnitDebuffID("arena1", 20066) == nil --repentance
    and UnitBuffID("arena1", 642) == nil --divine shield
    and UnitBuffID("arena1", 10278) == nil --HoP
    and UnitBuffID("arena1", 8178) == nil --grounding
    and UnitBuffID("arena1", 48707) == nil --AMS
    and UnitBuffID("arena1", 48792) == nil --IBF
    and UnitBuffID("arena1", 31224) == nil --cloak of shadows
    and UnitPower("player")>=117 then
      _castSpell(10308, "arena1")
    end
--Sacred BG Player
    if not UnitBuffID("player", 53601) then
      _castSpell(53601, "player")
    end
--Mana Divine Plea
    local PlayerMana = 100 * UnitPower("player") / UnitPowerMax("player")

    if cdRemains(54428) == 0
    and PlayerMana <= 60  then
      _castSpell(54428)
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
    and GetDistanceBetweenObjects ("player", "target") < 6
    --and getHp("player") <= 80 
    and UnitPower("player") > 197
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
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --AMS
    and UnitBuffID("target", 48066) == nil --PW:S
    and UnitBuffID("target", 43039) == nil --Ice Barrier
    then
      _castSpell(53407,"target")
    end
--Shield of Righteousness
    if UnitExists("target") == 1
    and UnitPower("player") > 26
    and UnitBuffID("target", 45438) == nil --ice block
    and UnitBuffID("target", 642) == nil --bubble
    and UnitBuffID("target", 19263) == nil --deterrance
    and UnitBuffID("target", 48707) == nil --anti magic shell
    then 
      _castSpell(61411,"target")
    end
--Cleanse Root Player
    if UnitExists("player") == 1 then
      for i=1, #RootList do
        if UnitDebuffID("player", RootList[i]) then
          _castSpell(4987, "player")
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
--Cleanse DoT's Player
    ----dk dots
    if UnitDebuffID("player",49194 ) == nil
    and (
      UnitDebuffID("player", 55095) --frost fever
      or UnitDebuffID("player", 51735) --ebon plague
      or UnitDebuffID("player", 55078) --blood plague
    )
    then _castSpell(4987, "player")
    end
    ----dots
    if UnitDebuffID("player", 47811) --Immolate
    or UnitDebuffID("player", 47813) --corruption
    or UnitDebuffID("player", 49233) --flame shock
    or UnitDebuffID("player", 48300) --devouring plague
    then _castSpell(4987,"player")
    end
--Buff Righteous Fury
    if not UnitBuffID("player", 25780) then
      _castSpell(25780)
    end
--Buff Seal of Vengeance
    if not UnitBuffID("player", 31801) then
      _castSpell(31801)
    end
--Buff Sanctuary
    if not UnitBuffID("player", 20911)--sanctuary
    and UnitPower("player")>=5000 then 
      _castSpell(20911, "player")
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

  print("Arc Preg 1v1")

end

-- Script
if enabled then Disable() else Enable() end