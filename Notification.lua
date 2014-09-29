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
    ToTime = GetPvPClockTime() + options.Seconds, 
    ToMessage = options.Message,
    OrderId = options.OrderId
  }
  , Notification)
  -- return the instance

  self.Flags = {};
  self.Flags.ActNow = {};
  self.Flags.PrepareToAct = {};
  
  self.Spells = {};
  self.Spells.ActNow = {};
  self.Spells.PrepareToAct = {};
  
  self.Spells.PrepareToAct.SentSpellId = 0;
  self.Spells.PrepareToAct.SentTime = 0;
  self.Spells.PrepareToAct.SentMessage = "";
  self.Spells.ActNow.SentSpellId = 0;
  self.Spells.ActNow.SentTime = 0;
  self.Spells.ActNow.SentMessage = "";

  self.Message = Message.new();
  return self;
end

function Notification:Update (options)
 --print("DEBUG:Notification:Update() from ("..self.ToSpellId..")"..self.ToTime.." to ("..options.ToSpellId..")"..options.ToTime);
  self.To = options.To
  self.ToSpellId = options.ToSpellId
  self.ToTime = options.ToTime
  self.ToMessage = options.Message
  self.OrderId = options.OrderId
  return self;
end

function Notification:Reset (options)
 --print("DEBUG:Resetting Notification for "..self.To.Name);
  
  self.ToSpellId = 0  -- Change Spell Id to 0 to reset the notifications
  
  self.Flags.ActNow = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.
  self.Spells.ActNow = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.

  self.Flags.PrepareToAct = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.
  self.Spells.PrepareToAct = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.

  return self;
end


function Notification:Send()
  
  local currentTime = GetPvPClockTime();
  

  local mustSend = nil;
  local spellHasChanged = nil
  local appendSeconds = "";


  if self.ToTime > currentTime then
     
    --print("DEBUG:Prepare:lastMsg: Spell:"..tostring(self.Spells.PrepareToAct.SentSpellId).."="..tostring(self.ToSpellId)..", "..tostring(self.Spells.PrepareToAct.SentTime).."="..tostring(self.ToTime));

    self.Flags.ActNow = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.
    self.Spells.ActNow = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.


    if not (self.Spells.PrepareToAct.SentSpellId == self.ToSpellId) then
      --print("DEBUG:Prepare:Spell has changed");
      spellHasChanged = true
    end

    appendSeconds = ","..(self.ToTime - currentTime);
    --print("DEBUG:Prepare:Execution time is in the future - so prepare to act");
    if self.OrderId==1 and not self.Flags.PrepareToAct.FirstNotificationPrepare then
      --print("DEBUG:Prepare:First Notification");
      self.ToMessage = "PrepareToAct";
      self.Flags.PrepareToAct.FirstNotificationPrepare  = true;
      mustSend = true;
    end
 
    if self.OrderId ~= 1 then
      self.Flags.ActNow.FirstNotificationPrepare = nil;
    end


    if spellHasChanged or ( self.ToTime - 40 <= currentTime and not self.Flags.PrepareToAct.PrepareMinus40) then
      --print("DEBUG:Prepare:-20-PrepareToAct");
      self.ToMessage = "PrepareToAct";
      self.Flags.PrepareToAct.PrepareMinus40 = true;
      mustSend = true;
      self.Flags.ActNow = {}  -- Wipe out the act now flags so that if we call it again next it works.
    end
 
 
    if mustSend then
     
      --print("DEBUG:Prepare:send message to "..self.To.Name);
      
      -- Remember that SpellId 0 is the reset spell Id.
      if self.ToSpellId == 0 then
        --print("DEBUG:Notification:Send() - Reset Spell Id");
      else
        self:SendMessage(self.ToMessage, self.ToSpellId..appendSeconds, self.To.Name);
      end
      
      self.Spells.PrepareToAct.SentSpellId = self.ToSpellId 
      -- Only set the sent time the first time the message is sent.
      if not self.Spells.PrepareToAct.SentTime or self.Spells.PrepareToAct.SentTime == 0 then
        self.Spells.PrepareToAct.SentTime = self.ToTime
      end
      self.Spells.PrepareToAct.SentMessage = self.ToMessage      
      
    else
      --print("DEBUG:Prepare:nothing to send");
    end

 
  else
    
    --print("DEBUG:ActNow:lastMsg: Spell:"..tostring(self.Spells.ActNow.SentSpellId).."="..tostring(self.ToSpellId)..", "..tostring(self.Spells.ActNow.SentTime).."="..tostring(self.ToTime));

    self.Flags.PrepareToAct = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.
    self.Spells.PrepareToAct = {}  -- Wipe out the prepare to act flag so that if we call it again next it works.

    if not (self.Spells.ActNow.SentSpellId == self.ToSpellId) then
      --print("DEBUG:ActNow:Spell has changed");
      spellHasChanged = true
    end

	  --print("DEBUG:ActNow:Execution time Current Or Past.");
    if self.OrderId==1 and not self.Flags.ActNow.FirstNotificationAct then
      --print("DEBUG:ActNow:First Notification");
      self.ToMessage = "ActNow";
      self.Flags.ActNow.FirstNotificationAct  = true;
      mustSend = true;
    end
    
    
    if self.OrderId ~= 1 then
      self.Flags.ActNow.FirstNotificationAct  = nil;
    end

  
    if not spellHasChanged and self.Spells.ActNow.SentTime + 18 <= currentTime then
      --print("DEBUG:ActNow:Bah, don't bother, if they've not responded by now then they wont! ActNow.SentTime+13="..(self.Spells.ActNow.SentTime + 13).." currentTime="..currentTime);
    elseif not spellHasChanged and self.Spells.ActNow.SentTime + 14 <= currentTime and not self.Flags.ActNow.SendPlus14 then
      --print("DEBUG:ActNow:14-VLate");
      self.ToMessage = "VeryLateActNow";
      self.Flags.ActNow.SendPlus14 = true;
      mustSend = true;

    elseif not spellHasChanged and self.Spells.ActNow.SentTime + 11 <= currentTime and not self.Flags.ActNow.SendPlus11 then
      --print("DEBUG:ActNow:11-VLate");
      self.ToMessage = "VeryLateActNow";
      self.Flags.ActNow.SendPlus11 = true;
      mustSend = true;

    elseif not spellHasChanged and self.Spells.ActNow.SentTime + 8 <= currentTime and not self.Flags.ActNow.SendPlus08 then
      --print("DEBUG:ActNow:8-Late");
      self.ToMessage = "LateActNow";
      self.Flags.ActNow.SendPlus08 = true;
      mustSend = true;

    elseif not spellHasChanged and self.Spells.ActNow.SentTime + 5 <= currentTime and not self.Flags.ActNow.SendPlus05 then
      --print("DEBUG:ActNow:5-Late");
      self.ToMessage = "LateActNow";
      self.Flags.ActNow.SendPlus05 = true;
      mustSend = true;

    elseif not spellHasChanged and self.Spells.ActNow.SentTime + 2 <= currentTime and not self.Flags.ActNow.SendPlus02 then
      --print("DEBUG:ActNow:2-ActNow");
      self.ToMessage = "ActNow";
      self.Flags.ActNow.SendPlus02 = true;
      mustSend = true;

    elseif spellHasChanged or (self.Spells.ActNow.SentTime + 0 <= currentTime and not self.Flags.ActNow.SendPlus00) then
      --print("DEBUG:ActNow:0-ActNow");
      self.ToMessage = "ActNow";
      self.Flags.ActNow.SendPlus00 = true;
        mustSend = true;
    end


    if mustSend then
      
      --print("DEBUG:ActNow:send message to "..self.To.Name);
      
      -- Remember that SpellId 0 is the reset spell Id.
      if self.ToSpellId == 0 then
        --print("DEBUG:ActNow:Notification:Send() - Reset Spell Id");
      else
        self:SendMessage(self.ToMessage, self.ToSpellId..appendSeconds, self.To.Name);
      end
    
      self.Spells.ActNow.SentSpellId = self.ToSpellId 
      -- Only set the sent time the first time the message is sent.
      if not self.Spells.ActNow.SentTime or self.Spells.ActNow.SentTime == 0 then
        self.Spells.ActNow.SentTime = self.ToTime
      end
      self.Spells.ActNow.SentMessage = self.ToMessage      
      
    else
      --print("DEBUG:ActNow:nothing to send");
    end

  end



end

function Notification:ResetCounters()
  self.Flags = {}
end

function Notification:SendMessage(strMessage, strTarget, strTo)
	local objSentMessage = self.Message:SendMessagePrefixed("PvPHelperClient", strMessage, strTarget, strTo);
end

