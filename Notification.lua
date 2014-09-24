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
    Flags = {}
  }
  , Notification)
  -- return the instance
  return self;
end

function Notification:Update (options)

  self.To = options.To
  self.ToSpellId = options.ToSpellId
  self.ToTime = options.ToTime
  self.ToMessage = options.Message

  return self;
end

function Notification:Send()
  
  local currentTime = GetTime();
  
  if self.ToTime > currentTime then
    self.ToMessage = "PrepareToAct";
  else
    self.ToMessage = "ActNow";
  end

 print("lastMsg: Spell:"..tostring(self.SentSpellId).."="..tostring(self.ToSpellId)
  ..", "..tostring(self.SentTime).."="..tostring(self.ToTime)
  ..", "..tostring(self.SentMessage).."="..tostring(self.ToMessage));	

  if self.ToTime > currentTime then
    print("Execution time is in the future - so prepare to act");
    
    if not (self.SentSpellId == self.ToSpellId 
      and self.SentTime == self.ToTime
      and self.SentMessage == self.ToMessage) then

      print("send message to "..self.To.Name);
      self.SentSpellId = self.ToSpellId 
      self.SentTime = self.ToTime
      self.SentMessage = self.ToMessage
      
    else
      print("nothing to send");
    end
  else
		print("Execution time Current Or Past.");
      if not (self.SentSpellId == self.ToSpellId 
      and self.SentTime == self.ToTime
      and self.SentMessage == self.ToMessage) then

      print("send message to "..self.To.Name);
      self.SentSpellId = self.ToSpellId 
      self.SentTime = self.ToTime
      self.SentMessage = self.ToMessage
      
    else
      print("nothing to send");
    end
  end

end

function Notification:ResetCounters()
  self.Flags = {}
end
