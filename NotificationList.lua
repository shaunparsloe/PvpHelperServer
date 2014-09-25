NotificationList = {}
NotificationList.__index = NotificationList; -- failed table lookups on the instances should fallback to the class table, to get methods

function NotificationList.new ()
  local self = setmetatable({}, NotificationList)
  return self
end

-- Update/Insert notification
function NotificationList:Add(objNotification)

  -- Check if we've already got this guid in our list
  local objNote
  for i,v in ipairs(self) do
    if v.To.GUID == objNotification.To.GUID then
      objNote = v;
    end
  end
  
  if objNote then
    --print("Already got a notification for "..objNotification.To.Name.." orderid="..objNotification.OrderId);
    objNote:Update(deepcopy(objNotification));
  else
    --print("Adding notification for "..objNotification.To.Name.." orderid="..objNotification.OrderId);
    objNote =  deepcopy(objNotification);
    table.insert(self, objNote);
    -- Also build the Lookup Table when building the List
  end
      
  
end


function NotificationList:SendNotifications()
  
  -- Send them in order of OrderId
  local iCount = 0;
  for i,note in ipairs(self) do
    iCount = iCount + 1
    for j,note in ipairs(self) do
      if note.OrderId == iCount then
        --print("sending "..note.OrderId..") to "..note.To.Name);
        note:Send();
      end
    end
  end
  
end

function NotificationList:ResetOrder();
  for i,note in ipairs(self) do
    note.OrderId = 100;
  end
end

function NotificationList:Sort()
  
  table.sort(self, 
				function(x,y)
					local retval = false;
        
          if (x.OrderId < y.OrderId) then
              retval = true;
					end
					return retval;
				end
		);
 end 

