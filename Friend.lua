-- *********************************************************
-- FRIEND class
-- *********************************************************
Friend = {}
Friend.__index = Friend; -- failed table lookups on the instances should fallback to the class table, to get methods

function Friend.new (options)
  local self = setmetatable({}, Friend)
  self.ContainedInLists = {}
  self.GUID = options.GUID
  self.Name = options.Name
  --print("My name is: "..self.Name);
  self.CCTypes = options.CCTypes
  self.CC_InRange = true
  return self
end

function Friend:UpdateSpells(strNewCCTypesString, objAllCCTypes)
  -- First split each of these CCTypes into a string
  -- Then build a list of CCTypes with them  
  --Test for Lookup on SpellID  
  local ccTypesTable = string_split( strNewCCTypesString, ",")
  
  local newCCTypes = CCTypeList.new();
  for i, strCCType in ipairs(ccTypesTable) do
    local cctype = objAllCCTypes:LookupSpellId(strCCType);
    local cctypeCopy = deepcopy(cctype);
    if (cctypeCopy) then
      print("Friend:UpdateSpells - Adding CCTYPE:"..strCCType)
      newCCTypes:Add(cctypeCopy);
    else
      print("Friend:UpdateSpells - CAN'T FIND CCTYPE:"..strCCType)
    end
  end
  self.CCTypes = newCCTypes
  -- Need to action the friendlist to update all spells now
  for i, containedInList in ipairs(self.ContainedInLists) do
    containedInList:SpellsUpdated();
  end
end
