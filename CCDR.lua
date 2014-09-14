-- ****************************************************
-- Class CCDR
-- ****************************************************
CCDR={};
CCDR.__index = CCDR -- failed table lookups on the instances should fallback to the class table, to get methods
function CCDR.new(strCCName, strDRType)
  -- the new instance
  local self = setmetatable({}, CCDR)
  self.CCName = strCCName
  self.DRType = strDRType
  -- return the instance
  return self
end