-- ****************************************************
-- Class Notification Server
-- ****************************************************
NotificationServer={};
NotificationServer.__index = NotificationServer -- failed table lookups on the instances should fallback to the class table, to get methods

-- Create this cover function to check mandatory and optional parameters for NotificationS
function NotificationServer.new (pvpServer)
	local self = setmetatable(
  	{
		Notification=nil,
		LastSentNotification = Notification.new({Seconds=0});
  	}, NotificationServer)
	-- return the instance

	return self;
end


function NotificationServer:SetNotification(notification)

	if (self.LastSentNotification.To == notification.To and self.LastSentNotification.SpellId == notification.SpellId) then
	--	print("DEBUG: Notification: Have sent before");
		-- So we have already notified this person about this spell before
		-- So, if we've told them to act in 10sec, but suddenly want to tell them to act now, then override that way.
		if (notification.Seconds == 0 and self.LastSentNotification.Seconds > 0) then
			print("DEBUG: Notification: Updating notification");
			self.Notification.Seconds = 0;
			self.Notification.ExecutionTime = time();
		end
	else
		-- Ok, so this is the first time this person+Spell combination has been called.
		-- Normally will be a "Prepare to Act" kind of instruction, but could be an "Act Now" action too.
		print("DEBUG: Notification: First notification");
		self.Notification = deepcopy(notification);
	end		
	
	self.Notification.Message = notification.Message;
	self.Notification.TimeLastApplied = time();
	
end

-- 1..2..3..4..5...6..7..8..9..10..11..12..13..14
--                 4            X                    
function NotificationServer:SendNotifications()
	local note = self.Notification;
	if (note) then
		print("DEBUG: note.ExecutionTime ".. note.ExecutionTime.." time "..time());
		
		local strMessage = "PrepareToAct";
		
		if (note.ExecutionTime + 11 <= time()) then
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
		end
		
		-- Debug testing!
		--self:SendMessage(strMessage, note.SpellId, note.To)
		print("DEBUG: About to send message: "..strMessage..", "..	note.SpellId..", "..note.To);
		local objMessage = Message.new();
		objMessage.Prefix = "PvPHelperClient";
		objMessage:SendMessagePrefixed("PvPHelperClient", strMessage, note.SpellId, note.To)

	end
end




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
    TimeLastApplied = time(),
    ExecutionTime = time() + options.Seconds
  }
  , Notification)
  -- return the instance
  return self;
end
