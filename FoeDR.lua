-- ****************************************************
-- Class FoeDR
-- ****************************************************
FoeDR={};
FoeDR.__index = FoeDR; -- failed table lookups on the instances should fallback to the class table, to get methods

CONSTANTS = {}
CONSTANTS.DRTIME = 18;  -- DR lasts for 18 seconds

function FoeDR.new(strDRType)
  -- the new instance
  local self = setmetatable(
    {
    DRType = strDRType,
    DRLevel = 0,
    _TimeLastApplied = time(),
    _Expires = time(),
    DRExpires = 0
    }, FoeDR)  
   -- return the instance
  return self
end

function FoeDR:ApplyDR(duration)
	if self.DRLevel < 3 then
    	self.DRLevel = self.DRLevel + 1;
    	self._TimeLastApplied = time();
    	self._Expires = time() + CONSTANTS.DRTIME + duration;
	end
  --print(self.DRType.." DRLevel is now " ..DRLevel)
end

function FoeDR:ResetDR()
	--print("DEBUG:FoeDR:ResetDR()")
	self._TimeLastApplied = time();
	self._Expires = time() + CONSTANTS.DRTIME;
  --print("DEBUG:FoeDR:ResetDR()"..self.DRType.." DRLevel is now " ..self.DRLevel)
end

function FoeDR:Recalculate()
	self:CalculateDRLevel();
	self:CalculateExpiry();
--	print("DEBUG:FoeDR:Recalculate(), DRType".. self.DRType ..", DRLevel:"..tostring(self.DRLevel)..", Expiry:"..tostring(self.DRExpires));
end

function FoeDR:CalculateDRLevel()
--	print("DEBUG:FoeDR:_CalculateDR(), "..tostring(self._Expires));
  if (time() >= self._Expires) then
      self.DRLevel = 0;
  end
  return self.DRLevel;
end


function FoeDR:CalculateExpiry()
  local clocktime = time();
  local expSeconds = 0
  if self._Expires <= clocktime then 
    expSeconds = 0;
  else
    expSeconds = self._Expires - clocktime;
  end
  self.DRExpires = expSeconds;
  return self.DRExpires;
end

-- ****************************************************
-- Class FoeDR
-- ****************************************************
