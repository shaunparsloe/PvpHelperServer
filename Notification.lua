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
    Time = options.Time, 
    Message = options.Message
  }
  , Notification)
  -- return the instance
  return self;
end
