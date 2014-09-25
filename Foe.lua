-- *********************************************************
-- FOE class
-- *********************************************************
Foe = {}
Foe.__index = Foe; -- failed table lookups on the instances should fallback to the class table, to get methods

function Foe.new (options)
  local self = setmetatable({}, Foe)
 
  self.GUID = options.GUID 
  self.Name = options.Name
  self.Class = options.Class
  self.DRList = FoeDRList.new()
  self.CCTypeList = CCTypeList.new();
 
  return self
end

function Foe:CCAuraApplied(objCCSpell)
	--print("DEBUG:Foe:CCAuraApplied: "..objCCSpell.DRType);
  	local objDR = self.DRList:LookupDRType(objCCSpell.DRType);
  	if objDR then
  		--print("Found DRTYPE = "..objCCSpell.DRType..", Updating it!");
    	objDR:ApplyDR(objCCSpell.Duration);
  	else
  		--print("Didn't find DRTYPE = "..objCCSpell.DRType..", Adding it new");
  		local foeDR = FoeDR.new(objCCSpell.DRType);
  		objDR = deepcopy(foeDR);
    	objDR:ApplyDR(objCCSpell.Duration);
    	
    	self.DRList:Add(objDR);
	end

	local objCC = self.CCTypeList:LookupSpellId(objCCSpell.SpellId);
	if objCC then
		--print("Found FOECCTYPE = "..objCCSpell.SpellId..", Casting it!");
		objCC:CastSpell();
	else
		--print("Did Not Find FOECCTYPE = "..objCCSpell.SpellId..", Adding it!");
		objCC = deepcopy(GVAR.AllCCTypes:LookupSpellId(objCCSpell.SpellId));
    if (objCC) then
      objCC:CastSpell();
      local objCCDR = deepcopy(objCC)
      self.CCTypeList:Add(objCCDR)
    end
	end
	
  	return objDR;
end
  
function Foe:CCAuraRemoved(objCCSpell)
  
  --print("DEBUG:Foe:CCAuraRemoved: "..objCCSpell.DRType);
  local objDR = self.DRList:LookupDRType(objCCSpell.DRType);
  if objDR then
    objDR:ResetDR();
  else
    print("ERROR: Cannot find DRType '"..objCCSpell.DRType.."' in list of DR's");
  end

  local objCC = self.CCTypeList:LookupSpellId(objCCSpell.SpellId);
  if objCC then
    --print("Removing active cc");
    objCC:RemoveActiveCC();
  else
      print("ERROR: Cannot find spellId "..objCCSpell.SpellId.." in list of Active CC's");
  end

end

function Foe:MaxActiveCCExpires()
  local maxActiveCCExpires = 0
  for i, objCCSpell in ipairs(self.CCTypeList) do
    maxActiveCCExpires = math.max(objCCSpell:ActiveCCExpires(), maxActiveCCExpires);
  end

  return maxActiveCCExpires;
end

-- *********************************************************
-- FOE class
-- *********************************************************
