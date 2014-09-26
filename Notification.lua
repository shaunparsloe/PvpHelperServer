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
    ToSpellId = options.SpellId,
    ToTime = GetTime() + options.Seconds, 
    ToMessage = options.Message,
    SentSpellId = 0,
    SentTime = 0, 
    SentMessage = "",
    OrderId = options.OrderId
  }
  , Notification)
  -- return the instance
  self.Flags = {};
  self.Message = Message.new();
  return self;
end

function Notification:Update (options)
 --print("updating from "..self.ToTime.." to "..options.ToTime);
  self.To = options.To
  self.ToSpellId = options.ToSpellId
  self.ToTime = options.ToTime
  self.ToMessage = options.Message
  self.OrderId = options.OrderId
  return self;
end

function Notification:Send()
  
  local currentTime = GetTime();
  

 --print("lastMsg: Spell:"..tostring(self.SentSpellId).."="..tostring(self.ToSpellId)..", "..tostring(self.SentTime).."="..tostring(self.ToTime));

  local mustSend = nil;
  local spellHasChanged = nil
  if not (self.SentSpellId == self.ToSpellId) then
    --print("Spell has changed");
    spellHasChanged = true
  end


  if self.ToTime > currentTime then
    --print("Execution time is in the future - so prepare to act");
    if self.OrderId==1 and not self.Flags.FirstNotificationPrepare then
      --print("First Notification");
      self.ToMessage = "PrepareToAct";
      self.Flags.FirstNotificationPrepare  = true;
      mustSend = true;
    end
 
    if spellHasChanged or ( self.ToTime - 40 <= currentTime and not self.Flags.Prepare) then
      --print("-20-PrepareToAct");
      self.ToMessage = "PrepareToAct";
      self.Flags.Prepare = true;
      mustSend = true;
    end
 
 
  else
    
		--print("Execution time Current Or Past.");
    if self.OrderId==1 and not self.Flags.FirstNotificationAct then
      --print("First Notification");
      self.ToMessage = "ActNow";
      self.Flags.FirstNotificationAct  = true;
      mustSend = true;
      self.Flags.Prepare = nil  -- Wipe out the prepare to act flag so that if we call it again next it works.
    end
  
    if not spellHasChanged and self.SentTime + 18 <= currentTime then
      --print("Bah, don't bother, if they've not responded by now then they wont! SentTime+13="..(self.SentTime + 13).." currentTime="..currentTime);
    elseif not spellHasChanged and self.SentTime + 14 <= currentTime and not self.Flags.SendPlus14 then
      --print("14-VLate");
      self.ToMessage = "VeryLateActNow";
      self.Flags.SendPlus14 = true;
      mustSend = true;

    elseif not spellHasChanged and self.SentTime + 11 <= currentTime and not self.Flags.SendPlus11 then
      --print("11-VLate");
      self.ToMessage = "VeryLateActNow";
      self.Flags.SendPlus11 = true;
      mustSend = true;

    elseif not spellHasChanged and self.SentTime + 8 <= currentTime and not self.Flags.SendPlus08 then
      --print("8-Late");
      self.ToMessage = "LateActNow";
      self.Flags.SendPlus08 = true;
      mustSend = true;

    elseif not spellHasChanged and self.SentTime + 5 <= currentTime and not self.Flags.SendPlus05 then
      --print("5-Late");
      self.ToMessage = "LateActNow";
      self.Flags.SendPlus05 = true;
      mustSend = true;

    elseif not spellHasChanged and self.SentTime + 2 <= currentTime and not self.Flags.SendPlus02 then
      --print("2-ActNow");
      self.ToMessage = "ActNow";
      self.Flags.SendPlus02 = true;
      mustSend = true;

    elseif spellHasChanged or (self.SentTime + 0 <= currentTime and not self.Flags.SendPlus00) then
      --print("0-ActNow");
      self.ToMessage = "ActNow";
      self.Flags.SendPlus00 = true;
        mustSend = true;
    end

  end


  if mustSend then
    
    --print("send message to "..self.To.Name);
    
    self:SendMessage(self.ToMessage, self.ToSpellId, self.To.Name);

    self.SentSpellId = self.ToSpellId 
    -- Only set the sent time the first time the message is sent.
    if not self.SentTime or self.SentTime == 0 then
      self.SentTime = self.ToTime
    end
    self.SentMessage = self.ToMessage      
    
  else
    --print("nothing to send");
  end

end

function Notification:ResetCounters()
  self.Flags = {}
end

function Notification:SendMessage(strMessage, strTarget, strTo)
	local objSentMessage = self.Message:SendMessagePrefixed("PvPHelperClient", strMessage, strTarget, strTo);
end

