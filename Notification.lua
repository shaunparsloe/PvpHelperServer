-- ****************************************************
-- Class Notification Server
-- ****************************************************
NotificationServer={};
NotificationServer.__index = NotificationServer -- failed table lookups on the instances should fallback to the class table, to get methods

-- Create this cover function to check mandatory and optional parameters for NotificationS
function NotificationServer.new (pvpServer)
	local self = setmetatable(
  	{
		Parent=pvpServer,	-- Circular reference back to the parent 
		Notification=nil,
		LastSentNotification = Notification.new();
  	}, Notification)
	-- return the instance
	return self;
end


function NotificationServer:SetNotification(notification)
{
	if (self.Notification.To == notification.To and self.Notification.SpellId == notification.SpellId) then
		-- So we have already notified this person about this spell before
		if (notification.Seconds == 0) then
			-- Act Now!
			-- So, if we've told them to act in 10sec, but suddenly want to tell them to act now, then override that way.
			if self.Notification.Seconds > 0 then
				self.Notification.Seconds = 0;
				self.Notification.ExecutionTime = time();
			endif
		else
--			-- Prepare to act
--			self.Notification.Seconds = notification.Seconds, 			 
--			self.Notification.ExecutionTime = time() + notification.Seconds
--
		end

--		self.Notification.Message = notification.Message,
		self.Notification._TimeLastApplied = time(),

	else
		self.Notification = deepcopy(notification);
	end		
}

-- 1..2..3..4..5...6..7..8..9..10..11..12..13..14
--                 4            X                    
function NotificationServer:SendNotifications()
{
	local note = self.Notification;
	if (note)
		
		if (false) then
		elseif (note.ExecutionTime + 11 <= time()) then
			strMessage = "VeryLateActNow";
		elseif (note.ExecutionTime + 8 <= time()) then
			strMessage = "VeryLateActNow";
		elseif (note.ExecutionTime + 6 <= time()) then
			strMessage = "LateActNow";
		elseif (note.ExecutionTime + 4 <= time()) then
			strMessage = "LateActNow";
		elseif (note.ExecutionTime + 1 <= time()) then
			strMessage = "ActNow";
		elseif (note.ExecutionTime <= time()) then
			strMessage = "ActNow";
		elseif (note.ExecutionTime -4 <= time() ) then
			strMessage = "PrepareToAct";
	
		local strMessage = "PrepareToAct";
		self.Parent:SendMessage(strMessage, note.SpellId, note.To)
	end
}

-- ****************************************************
-- Class Notification
-- ****************************************************
Notification={};
Notification.__index = Notification -- failed table lookups on the instances should fallback to the class table, to get methods

-- Create this cover function to check mandatory and optional parameters for NotificationS
function Notification.new (options)
  -- the new instance
  local self = setmetatable(
  {  
    To = options.To,
    SpellId = options.SpellId,
    Seconds = options.Seconds, 
    Message = options.Message,
    _TimeLastApplied = time(),
    ExecutionTime = time() + options.Seconds
  }
  , Notification)
  -- return the instance
  return self;
end
