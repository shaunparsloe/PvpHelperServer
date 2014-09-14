-- ****************************************************
-- Class FriendCCType
-- ****************************************************
FriendCCType={};
FriendCCType.__index = FriendCCType; -- failed table lookups on the instances should fallback to the class table, to get methods

function FriendCCType.new(options)
  -- the new instance
  local self = setmetatable(
    {
      CCType = options.CCType,
      SpellId = options.SpellId,
      DRType = options.DRType,
      Weighting = options.Weighting,
      FriendGUID = options.FriendGUID,
      FriendName = options.FriendName
    }, FriendCCType)  
   -- return the instance
  return self
end
-- ****************************************************
-- Class FriendCCType
-- ****************************************************
