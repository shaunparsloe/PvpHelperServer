-- ****************************************************
-- Class FoeDRList
-- ****************************************************
FoeDRList=nil
FoeDRList={};
FoeDRList.__index = FoeDRList -- failed table lookups on the instances should fallback to the class table, to get methods

-- Intialise the List
function FoeDRList.new()
  -- the new instance
  local self = setmetatable({}, FoeDRList)
  self.DRTypeReverseLookupTable = {}
  return self;
end

-- Build up a reverse lookup table so wek can have an index for the CCName
function FoeDRList:Add(objDR)
	--print("ADDING DR: " ..objDR.DRType);
  table.insert(self, objDR)
  self.DRTypeReverseLookupTable[tostring(objDR.DRType)] = table.getn(self)
  --print("Inserted DRTYPE ["..objDR.DRType.."]");
  --self:ListDRs();
end

-- Reverse lookup the DRType.  Return found FoeDR
function FoeDRList:LookupDRType(strDRType)
	--print("looking up ["..strDRType.."]")
  local foundId = self.DRTypeReverseLookupTable[tostring(strDRType)];
  if foundId then
    return self[foundId];
  else
    return nil;
  end
end

function FoeDRList:ListDRs()
  local strJoin = "";
  local strResult = "";
  for i,drtype in ipairs(self) do
    local strDR = "("..tostring(drtype.DRType)..") Level "..tostring(drtype:DRLevel()).." expires in "..tostring(drtype:DRExpires()).."sec\n  "
    strJoin = ",";
    print(tostring(i)..") DRTable "..strDR)
    strResult = strResult..strJoin..strDR
  end  
  print("DRs "..strResult)
  return strResult;
end




-- ****************************************************
-- Class FoeDRList
-- ****************************************************
