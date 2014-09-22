-- ****************************************************
-- Class CCDRList
-- ****************************************************
CCDRList={};
CCDRList.__index = CCDRList -- failed table lookups on the instances should fallback to the class table, to get methods

-- Intialise the List
function CCDRList.new()
  -- the new instance
  local self = setmetatable({}, CCDRList)
  self.CCNameReverseLookupTable = {}
  return self;
end
-- Build up a reverse lookup table so we can have an index for the CCName
function CCDRList:Add(objDR)
	table.insert(self, objDR)
	
	--reads the program input line by line, storing all lines in an array: 
	local size = table.getn(self);
	self.CCNameReverseLookupTable[tostring(objDR.CCName)] = table.getn(self)  
    -- Also build the Lookup Table when building the List

end

-- Reverse lookup the Spell Name.  Return found spell.
function CCDRList:LookupCCName(strCCName)
--  ChatFrame1:AddMessage("CCDRLIST REVERSELOOKUP: "..strCCName)
  local foundId = self.CCNameReverseLookupTable[strCCName];
  if foundId then
  --  ChatFrame1:AddMessage("Found "..foundId)
    return self[foundId];
  else
   -- ChatFrame1:AddMessage("NOT FOUND")
    return nil;
  end
end


function CCDRList:LoadAllDRSpells()
  objList=CCDRList.new();
  
  objList:Add(CCDR.new("Freeze", "CR"));
  objList:Add(CCDR.new("Pin", "CR"));
  objList:Add(CCDR.new("Frost Nova", "CR"));
  objList:Add(CCDR.new("Entangling Roots", "CR"));
  objList:Add(CCDR.new("Earthgrab", "CR"));
  objList:Add(CCDR.new("Mass Entanglement", "CR"));
  objList:Add(CCDR.new("Staggering Shout", "CR"));
  objList:Add(CCDR.new("Frozen Power", "CR"));
  objList:Add(CCDR.new("Frostjaw", "CR"));
  objList:Add(CCDR.new("Partial Paralysis", "CR"));
  objList:Add(CCDR.new("Narrow Escape", "CR"));
  objList:Add(CCDR.new("Void Tentrils", "CR"));
  objList:Add(CCDR.new("Disable", "CR"));
  objList:Add(CCDR.new("Mighty Bash", "CS"));
  objList:Add(CCDR.new("Concussion Blow", "CS"));
  objList:Add(CCDR.new("Deep Freeze", "CS"));
  objList:Add(CCDR.new("Demon Charge", "CS"));
  objList:Add(CCDR.new("Gnaw", "CS"));
  objList:Add(CCDR.new("Holy Wrath", "CS"));
  objList:Add(CCDR.new("Inferno Effect", "CS"));
  objList:Add(CCDR.new("Fist of Justice", "CS"));
  objList:Add(CCDR.new("Hammer of Justice", "CS"));
  objList:Add(CCDR.new("Intimidation", "CS"));
  objList:Add(CCDR.new("Kidney Shot", "CS"));
  objList:Add(CCDR.new("Maim", "CS"));
  objList:Add(CCDR.new("Ravage", "CS"));
  objList:Add(CCDR.new("Shadowfury", "CS"));
  objList:Add(CCDR.new("Shockwave", "CS"));
  objList:Add(CCDR.new("Sonic Blast", "CS"));
  objList:Add(CCDR.new("War Stomp", "CS"));
  objList:Add(CCDR.new("Aura of Foreboding", "CS"));
  objList:Add(CCDR.new("Cheap Shot", "CS"));
  objList:Add(CCDR.new("Bear Hug", "CS"));
  objList:Add(CCDR.new("Pounce", "CS"));
  objList:Add(CCDR.new("Axe Toss", "CS"));
  objList:Add(CCDR.new("Demon Leap", "CS"));
  objList:Add(CCDR.new("Web Wrap", "CS"));
  objList:Add(CCDR.new("Bash", "CS"));
  objList:Add(CCDR.new("Warbringer", "CS"));
  objList:Add(CCDR.new("Combustion Impact", "CS"));
  objList:Add(CCDR.new("Remorseless Winter", "CS"));
  objList:Add(CCDR.new("Binding Shot", "CS"));
  objList:Add(CCDR.new("Asphyxiate", "CS"));
  objList:Add(CCDR.new("Storm Bolt", "CS"));
  objList:Add(CCDR.new("Capacitor Totem", "CS"));
  objList:Add(CCDR.new("Charging Ox Wave", "CS"));
  objList:Add(CCDR.new("Leg Sweep", "CS"));
  objList:Add(CCDR.new("Fists of Fury", "CS"));
  objList:Add(CCDR.new("Lullaby", "CS"));
  objList:Add(CCDR.new("Chimera Shot", "DA"));
  objList:Add(CCDR.new("Disarm", "DA"));
  objList:Add(CCDR.new("Dismantle", "DA"));
  objList:Add(CCDR.new("Psychic Horror", "DA"));
  objList:Add(CCDR.new("Snatch", "DA"));
  objList:Add(CCDR.new("Grapple Weapon", "DA"));
  objList:Add(CCDR.new("Dragon's Breath", "DO"));
  objList:Add(CCDR.new("Freezing Arrow", "DO"));
  objList:Add(CCDR.new("Freezing Trap", "DO"));
  objList:Add(CCDR.new("Gouge", "DO"));
  objList:Add(CCDR.new("Hex", "DO"));
  objList:Add(CCDR.new("Hungering Cold", "DO"));
  objList:Add(CCDR.new("Polymorph", "DO"));
  objList:Add(CCDR.new("Repentance", "DO"));
  objList:Add(CCDR.new("Sap", "DO"));
  objList:Add(CCDR.new("Shackle", "DO"));
  objList:Add(CCDR.new("Wyvern Sting", "DO"));
  objList:Add(CCDR.new("Ring of Frost", "DO"));
  objList:Add(CCDR.new("Disorienting Roar", "DO"));
  objList:Add(CCDR.new("Blinding Light", "DO"));
  objList:Add(CCDR.new("Paralysis", "DO"));
  objList:Add(CCDR.new("Blind", "F"));
  objList:Add(CCDR.new("Fear", "F"));
  objList:Add(CCDR.new("Howl of Terror", "F"));
  objList:Add(CCDR.new("Intimidating Shout", "F"));
  objList:Add(CCDR.new("Psychic Scream", "F"));
  objList:Add(CCDR.new("Scare Beast", "F"));
  objList:Add(CCDR.new("Seduction", "F"));
  objList:Add(CCDR.new("Mesmerize", "F"));
  objList:Add(CCDR.new("Turn Evil", "F"));
  objList:Add(CCDR.new("Blood Fear", "F"));
  objList:Add(CCDR.new("Psychic Terror", "F"));
  objList:Add(CCDR.new("Mortal Coil", "H "));
  objList:Add(CCDR.new("Psychic Horror", "H "));
  objList:Add(CCDR.new("Blood Horror", "H "));
  objList:Add(CCDR.new("Frostbite", "RR"));
  objList:Add(CCDR.new("Improved Hamstring", "RR"));
  objList:Add(CCDR.new("Shattered Barrier", "RR"));
  objList:Add(CCDR.new("Improved Cone of Cold", "RR"));
  objList:Add(CCDR.new("Chains of Ice", "RR"));
  objList:Add(CCDR.new("Fire Blossom", "RR"));
  objList:Add(CCDR.new("Improved Fire Nova Totem", "RS"));
  objList:Add(CCDR.new("Revenge Stun", "RS"));
  objList:Add(CCDR.new("Stun", "RS"));
  objList:Add(CCDR.new("Stoneclaw Stun", "RS"));
  objList:Add(CCDR.new("Paralysis", "RS"));
  objList:Add(CCDR.new("Dragon Roar", "RS"));
  objList:Add(CCDR.new("Arcane Torrent", "S"));
  objList:Add(CCDR.new("Silenced - Gag Order", "S"));
  objList:Add(CCDR.new("Garrote - Silence", "S"));
  objList:Add(CCDR.new("Improved Counterspell", "S"));
  objList:Add(CCDR.new("Nether Shock", "S"));
  objList:Add(CCDR.new("Silencing Shot", "S"));
  objList:Add(CCDR.new("Improved Kick", "S"));
  objList:Add(CCDR.new("Shield of the Templar", "S"));
  objList:Add(CCDR.new("Silence", "S"));
  objList:Add(CCDR.new("Spell Lock", "S"));
  objList:Add(CCDR.new("Strangulate", "S"));
  objList:Add(CCDR.new("Disrupting Shout", "S"));
  objList:Add(CCDR.new("Banish", "Banish"));
  objList:Add(CCDR.new("Cyclone", "Cyclone"));
  objList:Add(CCDR.new("Hibernate", "Hibernate"));
  objList:Add(CCDR.new("Entrapment", "Entrapment"));
  objList:Add(CCDR.new("Scatter Shot", "Scatter Shot"));
  objList:Add(CCDR.new("Dominate Mind", "dommind"));
  
  
  -- return the initialised list
  self=objList;
  return self;
end
