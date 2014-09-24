-- ****************************************************
-- OrderedCCList
-- ****************************************************
OrderedCCList={};
OrderedCCList.__index = OrderedCCList -- failed table lookups on the instances should fallback to the class table, to get methods

local L = PVPHelperLib_LocalizationTable;

-- Intialise the List
function OrderedCCList.new()
  -- the new instance
  local self = setmetatable({}, OrderedCCList)
  self.FriendGUIDLookup = {}
  return self;
end

function OrderedCCList:Add(options)
    objOrderedCCItem = {
      Friend=options.Friend,
      Foe = options.Foe,
      Spell = options.Spell,
      CDExpires= options.CDExpires,
      DRLevel= options.DRLevel,
      DRXpires= options.DRXpires}
  table.insert(self, objOrderedCCItem);
  self.FriendGUIDLookup[tostring(options.Friend.GUID)] = table.getn(self); 	-- Add to lookup table.
end


-- Reverse lookup the SpellId.  Return found spell.
function OrderedCCList:LookupFriendGuid(friendGUID)
  local foundId = self.FriendGUIDLookup[tostring(friendGUID)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end




