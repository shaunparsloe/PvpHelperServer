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
  local objDR = self.DRList:LookupDRType(objCCSpell.DRType);
  if objDR then
    objDR:ApplyDR();
  else
    objDR = deepcopy(FoeDR.new(strDRType));
    objDR:ApplyDR(objCCSpell.Duration);
    self.DRList:Add(objDR);
    
    local objCC = deepcopy(objCCSpell)
    objCC:CastSpell();
    self.CCTypeList:Add(objCC)
    
  end

  return objDR;
end
  
function Foe:CCAuraRemoved(objCCSpell)
  
  local objDR = self.DRList:LookupDRType(objCCSpell.DRType);
  if objDR then
    objDR:ResetDR();
  end

  local objCC = self.CCTypeList:LookupSpellId(objCCSpell.SpellId);
  if objCC then
    objCC:RemoveActiveCC();
  end

end
-- *********************************************************
-- FOE class
-- *********************************************************
