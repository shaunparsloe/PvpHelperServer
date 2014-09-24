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
    SentMessage = ""
  }
  , Notification)
  -- return the instance
  return self;
end


function Notification:Send()
  
  local currentTime = GetTime();
  
  if self.ToTime > currentTime then
    self.ToMessage = "PrepareToAct";
  else
    self.ToMessage = "ActNow";
  end

 print("lastMsg: Spell:"..tostring(self.SentSpellId).."="..self.ToSpellId
  ..", "..tostring(self.SentTime).."="..tostring(self.ToTime)
  ..", "..tostring(self.SentMessage).."="..self.ToMessage);	

  if self.ToTime > currentTime then
    print("Execution time is in the future - so prepare to act");
  else
		print("Execution time Current Or Past.");
  end

end