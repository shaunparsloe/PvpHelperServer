FriendList = {}
FriendList.__index = FriendList; -- failed table lookups on the instances should fallback to the class table, to get methods

function FriendList.new()
  local self = setmetatable({}, FriendList)
  self.GUIDLookupTable = {}
  self.FriendCCTypesList = {}
  
  return self
end

function FriendList:Add(friend)

	local foundId = self.GUIDLookupTable[tostring(friend.GUID)];
	if foundId then
    	self[foundId] = friend;
    	print("DEBUG: PvpHelperServer FriendList:Add- UPDATING " .. friend.Name .. " in friendlist");
  	else
	    print("DEBUG: PvpHelperServer FriendList:Add- adding " .. friend.Name .. " to friendlist");	
	    table.insert(friend.ContainedInLists, self)
	    table.insert(self, friend);
    end
    self.GUIDLookupTable[tostring(friend.GUID)] = table.getn(self)
    self:_BuildFriendCCTypesList();
end

function FriendList:Delete(friend)
  friend.ContainedInLists = nil;
  friend.ContainedInLists = {};
  local foundId = self.GUIDLookupTable[tostring(friend.GUID)];
  if foundId then
    -- Remove from the table
    table.remove(self, foundId)
    -- remove from the GUID lookup table too
    self.GUIDLookupTable[tostring(friend.GUID)] = nil;
  end
  self:_BuildFriendCCTypesList();
end

-- Reverse lookup the SpellId.  Return found spell.
function FriendList:LookupGUID(strGUID)
  local foundId = self.GUIDLookupTable[tostring(strGUID)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end

-- Slower lookup function as it has to iterate through the whole list
function FriendList:LookupName(strFriendName)
  local retval
  for i, friend in ipairs(self) do
    if friend.Name == strFriendName then
      retval = friend
    end
  end
  return retval
end

function FriendList:SpellsUpdated()
  self:_BuildFriendCCTypesList();
end

-- Build up the FriendCCTypesList
function FriendList:_BuildFriendCCTypesList()
  self.FriendCCTypesList = nil;
  self.FriendCCTypesList = FriendCCTypeList.new()

  for i, friend in ipairs(self) do
  	if (friend.CCTypes) then	
	    for i2, cctype in ipairs(friend.CCTypes) do
	      local friendCCType = FriendCCType.new(
	        { CCType = cctype.CCType,
	          SpellId = cctype.SpellId,
	          DRType = cctype.DRType,
	          Weighting = cctype.Weighting,
	          FriendGUID = friend.GUID,
	          FriendName = friend.Name
	        })
	      self.FriendCCTypesList:Add(deepcopy(friendCCType));
	    end
	else
		print("No CC Types list for "..friend.Name);
    end
  end

  local function compareWeighting(a,b)
    local retval = false;
    if a.Weighting > b.Weighting then
      retval = true
    else
      if a.Weighting == b.Weighting then
        if (a.SpellId) > (b.SpellId) then
          retval = true
        else
          retval = false
        end
      else
        retval = false
      end
    end
    return retval
  end

  table.sort(self.FriendCCTypesList, compareWeighting)  
end






