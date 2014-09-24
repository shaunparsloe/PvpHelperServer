-- ****************************************************
-- Class FoeDR
-- ****************************************************
FoeDR={};
FoeDR.__index = FoeDR; -- failed table lookups on the instances should fallback to the class table, to get methods

CONSTANTS = {}
CONSTANTS.DRTIME = 18;	-- DR lasts for 18 seconds

function FoeDR.new(strDRType)
	-- the new instance
	local self = setmetatable(
		{
		DRType = strDRType,
		_DRLevel = 0,
		_TimeLastApplied = GetTime(),
		_Expires = GetTime(),
		_DRExpires = 0
		}, FoeDR)	
	 -- return the instance
	return self
end

function FoeDR:ApplyDR(duration)
	if self._DRLevel < 3 then
			self._DRLevel = self._DRLevel + 1;
			self._TimeLastApplied = GetTime();
			self._Expires = GetTime() + CONSTANTS.DRTIME + duration;
	end
	--print(self.DRType.." _DRLevel is now " .._DRLevel)
end

function FoeDR:ResetDR()
	--print("DEBUG:FoeDR:ResetDR()")
	self._TimeLastApplied = GetTime();
	self._Expires = GetTime() + CONSTANTS.DRTIME;
	--print("DEBUG:FoeDR:ResetDR()"..self.DRType.." _DRLevel is now " ..self._DRLevel)
end


function FoeDR:DRLevel()
--	print("DEBUG:FoeDR:_CalculateDR(), "..tostring(self._Expires));
	if (GetTime() >= self._Expires) then
			self._DRLevel = 0;
	end
	return self._DRLevel;
end


function FoeDR:DRExpires()
	local clocktime = GetTime();
	local expSeconds = 0
	if self._Expires <= clocktime then 
		expSeconds = 0;
	else
		expSeconds = self._Expires - clocktime;
	end
	self._DRExpires = expSeconds;
	return self._DRExpires;
end

-- ****************************************************
-- Class FoeDR
-- ****************************************************
