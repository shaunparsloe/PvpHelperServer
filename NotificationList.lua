NotificationList = {}
NotificationList.__index = NotificationList; -- failed table lookups on the instances should fallback to the class table, to get methods

function NotificationList.new ()
  local self = setmetatable({}, NotificationList)
  self._GUIDLookupTable = {}
  self._allCCTypesList = {}
  
  return self
end

-- Update/Insert notification
function NotificationList:Add(objNotification)

  -- Check if we've already got this guid in our list
  objNote = self:LookupGUID(objNotification.To.GUID);
  if objNote then
    --print("Already got a notification for "..objNotification.To.Name);
    objNote.Update(objNotification);
  else
    --print("Adding notification for "..objNotification.To.Name);
    objNote =  deepcopy(objNotification);
    table.insert(self, objNote);
    -- Also build the Lookup Table when building the List
    self._GUIDLookupTable[tostring(objNote.To.GUID)] = table.getn(self)
  end
      
end

-- Reverse lookup the GUID
function NotificationList:LookupGUID(strGUID)
  local foundId = self._GUIDLookupTable[tostring(strGUID)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end

function NotificationList:SendNotifications()
  for i,note in ipairs(self) do
    note:Send();
  end
end



