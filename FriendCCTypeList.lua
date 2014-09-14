-- ****************************************************
-- Class FriendCCTypeList
-- ****************************************************
FriendCCTypeList={};
FriendCCTypeList.__index = FriendCCTypeList -- failed table lookups on the instances should fallback to the class table, to get methods

-- Intialise the List
function FriendCCTypeList.new()
  -- the new instance
  local self = setmetatable({}, FriendCCTypeList)
  self.CCNameReverseLookupTable = {}
  return self;
end

-- Add to the list
function FriendCCTypeList:Add(objFriendCCType)
  table.insert(self, objFriendCCType)
  self.CCNameReverseLookupTable[tostring(objFriendCCType.CCName)] = table.getn(self)
end

function FriendCCTypeList:ListSpellIds()
  local strJoin = "";
  local strResult = "";
  for i,cctype in ipairs(self) do
    strResult = strResult..strJoin..tostring(cctype.SpellId)
    strJoin = ",";
  end  
  return strResult;
end

