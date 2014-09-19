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
    SentTime = 0,
    TimeDiff = 0,
    ExecutionTime = time() + options.Seconds
  }
  , Notification)
  -- return the instance
  return self;
end
