FoeList = {}
FoeList.__index = FoeList; -- failed table lookups on the instances should fallback to the class table, to get methods

function FoeList.new ()
  print("DEBUG:FoeList():Setting up new FoeList");
  local self = setmetatable({}, FoeList)
  self._GUIDLookupTable = {}
  self._allCCTypesList = {}
  
  return self
end

function FoeList:Add(objFoe)
    table.insert(self, objFoe);
    -- Also build the Lookup Table when building the List
    self._GUIDLookupTable[tostring(objFoe.GUID)] = table.getn(self)
end

-- Reverse lookup the GUID
function FoeList:LookupGUID(strGUID)
  local foundId = self._GUIDLookupTable[tostring(strGUID)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end





