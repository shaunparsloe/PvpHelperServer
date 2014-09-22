-- ****************************************************
-- UTILS

function deepcopy(o, seen)
  seen = seen or {}
  if o == nil then return nil end
  if seen[o] then return seen[o] end

  local no
  if type(o) == 'table' then
    no = {}
    seen[o] = no

    for k, v in next, o, nil do
      no[deepcopy(k, seen)] = deepcopy(v, seen)
    end
    setmetatable(no, deepcopy(getmetatable(o), seen))
  else -- number, string, boolean, etc
    no = o
  end
  return no
end

--function table.shallow_copy(t)
--  local t2 = {}
--  for k,v in pairs(t) do
--    t2[k] = v
--  end
--  return t2
--end
--

--local clock = os.clock
function sleep(numSecToSleep)  -- seconds
  local startTime = time()
  local sec1 = startTime + 1;
  while time() - startTime <= numSecToSleep do 
    --if clock() > sec1 then
    --  sec1 = sec1 + 1;
    --  print("Sleep 1sec...");
    --end
  end
end

--- Pads str to length len with char from left
function string.rpad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

-- Extend math function to round to nearest integer
function math.round(x)
  if x%2 ~= 0.5 then
    return math.floor(x+0.5)
  end
  return x-0.5
end

function string_split(strToSplit, sep)
    local sep, fields = sep or ":", {}
	if (strToSplit) then
    	local pattern = string.format("([^%s]+)", sep)
    	strToSplit:gsub(pattern, function(c) fields[#fields+1] = c end)		
	end        
    return fields
end


local function ClassHexColor(class)
	local hex
	if classcolors[class] then
		hex = format("%.2x%.2x%.2x", classcolors[class].r*255, classcolors[class].g*255, classcolors[class].b*255)
	end
	return hex or "cccccc"
end


function TESTAssert(expected, actual, description)
  local blnRetval = false
  local join = ": "
  local calledfrom = debug.getinfo(2).name;
  local currentline = debug.getinfo(2).currentline;
  local linedefined = debug.getinfo(2).linedefined;
  if (actual == expected) then
    blnRetval = true;
  else
    if not description then
      description = ""
      join = ""
    end
    --print(tostring(currentline)..","..tostring(linedefined));
    print("[TESTERROR:"..calledfrom.."("..tostring(currentline)..")] "..description..join.."Expected value: ["..tostring(expected).."] Actual value: ["..tostring(actual).."]");
  end
  return blnRetval
end

--Conditional depending on test/live
if (os) then
  function time()
    return os.clock()
  end
else
  function print(message)
    ChatFrame1:AddMessage(message)
  end
end
-- ****************************************************
-- UTILS
-- ****************************************************
