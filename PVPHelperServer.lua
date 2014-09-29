Roster = {};
GVAR = {};
GVAR.UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
UIWidgets = {}		 -- UI Widgets

PvPHelperServer = {}
PvPHelperServer_MainFrame = {}
PvPHelperServer.__index = PvPHelperServer; -- failed table lookups on the instances should fallback to the class table, to get methods

local L = PVPHelper_LocalizationTable;

-- Globals Section
local AllCCTypes;
local AllDRTypes;
local CONSTANTS = {};


function PvPHelperServer.new (options)
	local self = setmetatable({}, PvPHelperServer)
	
	
	self.NotificationList= NotificationList.new();

	self.Message = Message.new();
	self.Message.ReceivePrefix = "PvPHelperServer";	

	self.FriendList = FriendList.new();
	self.FoeList = FoeList.new();
	self.GlobalCCTypesList = {}
	self.GlobalCCDRList = {}

	local objDRTypesList = CCDRList.new()
	GVAR.AllDRTypes = objDRTypesList.LoadAllDRSpells()

	local objList = nil;
	objList = CCTypeList.new();
	GVAR.AllCCTypes = objList:LoadAllCCTypes()	
	
	self:Initialize();

	PvPHelperServer_MainFrame = CreateUIElements(self);

	RegisterMainFrameEvents(self);

	return self;
end


function PvPHelperServer:Initialize()
	--print("DEBUG: PvpHelperServer - Initializing");
	--self.MessageLog = {}
	--self.MessageLog.Sent = {}
	--self.MessageLog.Received= {}

	self.NotificationList= NotificationList.new();

		local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player").."-"..GetRealmName(), CCTypes=objCCTypeList})
		local objFriendList = FriendList.new()
		objFriendList:Add(objFriend)
    

		--print("Clearing FoeList");
		local objFoeList = FoeList.new()
		self:ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})



	self.UI = {};
	
end


function PvPHelperServer:ResetFriendsAndFoes(options)
  -- the new instance
	--print("Resetting the PvPHelperServer:ResetFriendsAndFoes instance");
  
  
	self.FriendList = options.FriendList
	self:UpdateParty();
  		local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player").."-"..GetRealmName(), CCTypes=objCCTypeList})

  self.FriendList:Add(objFriend);
  
  self.FoeList = options.FoeList
	self.GlobalCCTypesList = CCTypeList:LoadAllCCTypes();
	self.GlobalCCDRList = CCDRList.LoadAllDRSpells();
	
	for i, k in pairs(self.FriendList) do
		if (k.Name) then
				--print("DEBUG:PvPHelperServer:ResetFriendsAndFoes - Asking .." .. k.Name .. " for spells");
				self:SendMessage("WhatSpellsDoYouHave",nil, k.Name);
			--self:SendMessage("PrepareToAct", "64044,25", k.Name);					
				--self:SendMessage("DummyTestMessage", nil, k.Name)
			end
	end
	
	return self;
end


function PvPHelperServer:Apply_Aura(sourceGUID, sourceSpellId, destGUID)
	local objFoundFriend = self.FriendList:LookupGUID(sourceGUID);
	local objFriendSpell
	if objFoundFriend then
		objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(sourceSpellId);
		if objFriendSpell then
			print("DEBUG:PvPHelperServer:Apply_Aura -CAST SPELL 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID..", ccName: "..objFriendSpell.CCName .." ccType)"..objFriendSpell.CCType)
			objFriendSpell:CastSpell();
      self.NotificationList:Reset(sourceGUID);



		local objFoundFoe = self.FoeList:LookupGUID(destGUID);
	-- In the foe when we apply the aura, it will start timers on both the ActiveCC and the DR Duration
    if objFoundFoe and objFriendSpell then
      objFoundFoe:CCAuraApplied(objFriendSpell)
    end

		
		else
--			print("PvPH_Server:Apply_Aura 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID)
			print("PvPH_Server:Apply_Aura - Cannot find friend spell "..sourceSpellId)
		end
	else
		-- This aura wasn't applied by one of my friends:
	end


end	

-- When the aura is removed, that's when the countdown starts for the CC Cooldowns.
function PvPHelperServer:Remove_Aura(destGUID, spellId)
	local objFoundFoe = self.FoeList:LookupGUID(destGUID);

	if objFoundFoe then
		--local drtype = self.GlobalCCDRList:LookupCCName(strSpellName);
		local cctype = GVAR.AllCCTypes:LookupSpellId(spellId)
		-- And apply to foe
		if cctype then
			objFoundFoe:CCAuraRemoved(cctype)
    else
      --print("DEBUG:PvPHelperServer:Remove_Aura:Cannot find cctype");
		end
  else
    --print("DEBUG:PvPHelperServer:Remove_Aura:Cannot find Foe");
	end
end	


function PvPHelperServer:OrderedCCSpells(CCTarget1GUID)
	local objOrderedCCSpells = OrderedCCList.new()
	
	if (CCTarget1GUID) then
		--print("DEBUG: looking for FOE GUID "..CCTarget1GUID)
			local objFoundFoe = self.FoeList:LookupGUID(CCTarget1GUID);
			--objFoundFoe.DRList:ListDRs();
		if objFoundFoe then
		--print("DEBUG: Found FOE GUID "..CCTarget1GUID)
			local allFriendSpells = self.FriendList.FriendCCTypesList;

			
			for i, ccFriendSpell in ipairs(allFriendSpells) do
			
				--print("FriendSpell "..i.."). "..ccFriendSpell.SpellId)
				local objFoundFriend = self.FriendList:LookupGUID(ccFriendSpell.FriendGUID);
				if objFoundFriend then
					local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(ccFriendSpell.SpellId);			
					
					local cdExpires = objFriendSpell:CooldownExpires();
		
					local objDR = objFoundFoe.DRList:LookupDRType(objFriendSpell.DRType);
					local drLevel = 0;
					local drExpires	= 0;
					if (objDR) then 
						drExpires = objDR:DRExpires() -- relative_valueof(objDR.DRExpires);
						drLevel = objDR:DRLevel();
					else
						drExpires = 0;
					end
          --print("DEBUG:OrderedCC:DRtype "..objFriendSpell.DRType.." expires in "..drExpires.." sec("..objFriendSpell.CCName..")");
			
					if objFriendSpell then
						objOrderedCCSpells:Add(
						{
						Friend=objFoundFriend,
						Foe=objFoundFoe, 
						Spell=objFriendSpell, 
            CDExpires=cdExpires,
						DRLevel=drLevel,
						DRXpires=drExpires
						});
		
					else
						print("Cannot find friendSpell for " .. ccFriendSpell.CCName);
					end
				else
					print("Cannot find friend with GUID " ..FriendGUID.. " in FriendList");
				end
			end	
		else
			print("Cannot find foe with GUID " .. CCTarget1GUID .. " in FOELIST")
		end
	else 
		print("No Guid Passed To calculate OrderedCCSpells");
	end		

	-- Order by Cooldown, DR Remaining, Spell Weighting		
	table.sort(objOrderedCCSpells, 
				function(x,y)
					local retval = false;
					if (math.max(x.CDExpires, x.DRXpires) < math.max(y.CDExpires, y.DRXpires)) then
            retval = true;
          elseif (math.max(x.CDExpires, x.DRXpires) == math.max(y.CDExpires, y.DRXpires)) then
            if (y.Spell.Weighting > x.Spell.Weighting) then
                retval = true;
            elseif(x.Spell.Weighting == y.Spell.Weighting) then
                if(x.Spell.SpellId < y.Spell.SpellId) then
                  retval = true;
                end
            end
					end
					return retval;
				end
		);
  
	
	return objOrderedCCSpells;
	
end



function PvPHelperServer:MessageReceived(strPrefix, strMessage, strType, strSender)
	--print("DEBUG: PvpHelperServer - Message Received "..strMessage..", "..tostring(strType)..", "..strSender);
	
	-- TODO: REmove this comment - it could be that we're pinging back message received comments every time!!!
	-- We have commented this out to try to fix a bug with 2x CCTypes messages causing errors.
	self.Message:Format(strPrefix, strMessage, strType, strSender)
	
	if (self.Message.Header)=="MySpells" then -- 0020 = MySpells	
		self:SetFriendSpells(self.Message.Body, self.Message.From)
	elseif (self.Message.Header)=="SpellCoolDown" then -- 0080 = ThisSpellIsOnCooldown
		self:SetFriendSpellOnCooldown(self.Message.Body, self.Message.From)
	elseif (self.Message.Header)=="SpellOffCooldown" then -- 0090 = SpellOffCooldown
		self:SetFriendSpellOffCooldown(self.Message.Body, self.Message.From)
	elseif (self.Message.Header)=="Testing" then
    -- Ignore for testing only
  else
    print("PvpHelperServer - Unknown Message Received ("..self.Message.Header..") "..strMessage..", "..tostring(strType)..", "..strSender);
	end
end

function PvPHelperServer:SendMessage(strMessage, strTarget, strTo)
	local objSentMessage = self.Message:SendMessagePrefixed("PvPHelperClient", strMessage, strTarget, strTo);
  --table.insert(self.MessageLog.Sent, deepcopy(objSentMessage));
end

function PvPHelperServer:SetFriendSpells(strSpellsList, strFrom)
	-- should get the guid as well as spells list.
	local objFriend = self.FriendList:LookupName(strFrom)
	if (objFriend) then
		objFriend:UpdateSpells(strSpellsList, GVAR.AllCCTypes);
	else
		print("PvPHelperServer:SetFriendSpells - "..strFrom.." not found")
	end
end

function PvPHelperServer:UpdateParty()
  local objFriendList = FriendList.new()
  
  print("CHecking party of "..GetNumGroupMembers());
  for i=1,GetNumGroupMembers() do
    local unittowatch = "party"..i;
    print(unittowatch);
    local _,isdead,online,name,class,guid;
    isdead = UnitIsDeadOrGhost(unittowatch);
    name = UnitName(unittowatch);
    print("unitName="..tostring(name));
    online = UnitIsConnected(unittowatch);
    _,class = UnitClass(unittowatch);
    guid = UnitGUID(unittowatch);
    print("unitGUID="..tostring(guid));
    
    local objFriend = Friend.new({GUID=guid, Name=name, CCTypes=CCTypeList.new()})
    print("DEBUG: PvpHelperServer PARTY_MEMBERS_CHANGED- adding " .. tostring(name) .. " to friendlist");

    objFriendList:Add(objFriend)
  end

  self.FriendList = nil;
  self.FriendList = objFriendList
end

function PvPHelperServer:SetFriendSpellOnCooldown(strSpellId, strFrom)
	print("DEBUG:PvPHelperServer:SetFriendSpellOnCooldown "..strSpellId..", "..strFrom..")")
  local objFoundFriend = self.FriendList:LookupName(strFrom);
  if objFoundFriend then
    local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(strSpellId);
    if objFriendSpell then
      --print("putting spell "..tostring(objFriendSpell.SpellId).." on cooldown")--
      objFriendSpell:CastSpell()	-- Mark this as cast to set timeout and cooldown
      self.NotificationList:Reset(objFoundFriend.GUID);
    else
      print("SetFriendSpellOnCooldown cannot find friendspell : "..strSpellId)
    end
  else
    print("SetFriendSpellOnCooldown cannot find friend : "..strFrom)
  end
end

function PvPHelperServer:SetFriendSpellOffCooldown(strSpellId, strFrom)
	--print(" PvPHelperServer:SetFriendSpellOffCooldown "..strSpellId..", "..strFrom..")")
		local objFoundFriend = self.FriendList:LookupName(strFrom);
		if objFoundFriend then
			local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(strSpellId);
			if objFriendSpell then
				--print("putting spell "..tostring(objFriendSpell.SpellId).." off cooldown")--
				objFriendSpell:Reset()	-- Mark this as reset
			else
				print("SetFriendSpellOnCooldown cannot find friendspell : "..strSpellId)
			end
		else
			print("SetFriendSpellOnCooldown cannot find friend : "..strFrom)
		end
end

-- OnEvent
function PVPHelperServer_OnEvent(self, event, ...)
		local timestamp, Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, param15,
		param16, param17, param18, param19, param20, param21, param22, param23=...
	local frame = self;

	local objPvPServer = frame.PvPHelperServer
	
	
	if event == "PLAYER_LOGIN" then
	 objPvPServer:Initialize();

	elseif(event=="RAID_ROSTER_UPDATE") then
	
		if not(UnitInRaid("player")) then
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED"); --reactive party watching on raid leave
			return;
		end
		
    local _,name,class,online,role
		--		objPvPServer = PvPHelperServer.ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})
--print("DEBUG: Raid roster update");
		local objFriendList = FriendList.new()
		local i
		for i=1,GetNumRaidMembers() do
			name,_,_,_,_,class,_,online,_,_,_,role = GetRaidRosterInfo(i);
			local objFriend = Friend.new({GUID=UnitGUID(name), Name=name, CCTypes=CCTypeList.new()})
				--print("DEBUG: PvpHelperServer RAID_ROSTER_UPDATE- adding " .. tostring(name) .." to friendlist");

			objFriendList:Add(objFriend)
		end
	
		objPvPServer.FriendList = nil;
		objPvPServer.FriendList = objFriendList

	elseif(event=="PARTY_MEMBERS_CHANGED") then
  print("PARTY MEMBERS CHANGED");
		if UnitInRaid("player") then
			frame:UnregisterEvent("PARTY_MEMBERS_CHANGED"); --no need to use this if in raid
			return
		elseif not(UnitInParty("player")) then
			return
		end
    self:UpdateParty();

	elseif event == "PLAYER_ENTERING_WORLD" then
	 objPvPServer:Initialize();
	
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		print("Event ZONE_CHANGED_NEW_AREA fired")
		objPvPServer:Initialize();
    
	elseif event == "CHAT_MSG_ADDON" then
	--print("PvPHelperServer-MESSAGE RECEIVED with stamp "..timestamp.." - "..tostring(Event))
		if (timestamp == "PvPHelperServer") then
			objPvPServer:MessageReceived(tostring(timestamp), tostring(Event), tostring(hideCaster), tostring(sourceGUID))
--	else
--		print("PvpHelperServer ERROR Message Received with stamp "..timestamp)
		end

	elseif event == "PLAYER_REGEN_DISABLED" then
    objPvPServer.InCombat = true;
		
	elseif event == "PLAYER_REGEN_ENABLED" then
    objPvPServer.InCombat = false;
		
	elseif event=="COMBAT_LOG_EVENT_UNFILTERED" then
		if Event=="SPELL_AURA_REMOVED" then
					 objPvPServer:Remove_Aura(destGUID, spellId)	 
			elseif Event=="SPELL_AURA_APPLIED" or Event=="SPELL_AURA_REFRESH" then
					objPvPServer:Apply_Aura(sourceGUID, spellId, destGUID)
			end
	end
end

function UpdateFriendList()
	local objFriend = {}
	local objFriendList = FriendList.new()
	
end


function RegisterMainFrameEvents(self)
	
	PvPHelperServer_MainFrame.TimeSinceLastUpdate = 0;
	PvPHelperServer_MainFrame:SetScript("OnUpdate", PVPHelperServer_OnUpdate)

	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PvPHelperServer_MainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  
  
  PvPHelperServer_MainFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
  PvPHelperServer_MainFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
  
  
	--PvPHelperServer_MainFrame:RegisterEvent("PLAYER_LOGIN")
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	PvPHelperServer_MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	PvPHelperServer_MainFrame:RegisterEvent("CHAT_MSG_ADDON")
	PvPHelperServer_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE")
	PvPHelperServer_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
	PvPHelperServer_MainFrame:SetScript("OnEvent", PVPHelperServer_OnEvent)

end



	
-- Functions Section
function PVPHelperServer_OnUpdate(frame, elapsed)
--print ("on update called");

  --print("DEBUG: * ");
  --print("DEBUG:Time is now: "..GetTime());
  --print("DEBUG:PVPHelperServer_OnUpdate()");
  --print("DEBUG: * ");


	frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed; 	
	--print("TimeSinceLastUpdate:"..frame.TimeSinceLastUpdate.." > Update Interval "..GVAR.UpdateInterval);

	if (frame.TimeSinceLastUpdate >= GVAR.UpdateInterval) then
		--PVPHelperServerText:SetText(TimeString.." "..string.format("%.2f\n", seconds));
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
	--frame.MessageFrame:AddMessage("TEST",1,1,1);
	
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
--	frame.MessageFrame:Clear();
	local objPvPServer = frame.PvPHelperServer;
	
  --print("-- Must NOT clear out the Notification List each time!");
  objPvPServer.NotificationList:ResetOrder();
	
  local iNotificationOrder = 0
	local btnCCTarget1 = UIWidgets.CCButton[1];
	if (btnCCTarget1) then
		if (btnCCTarget1.Foe) then
			local objOrderedCCSpells = objPvPServer:OrderedCCSpells(btnCCTarget1.Foe.GUID);
      
      -- DEBUG list CCspells
      objOrderedCCSpells:ListSpells();
			--frame.MessageFrame:Clear();
			--frame.MessageFrame:AddMessage("CDExpires, DRExpires, SPELL NAME, IsCD, IsAvail, Duration, DRLevel");
			if (objOrderedCCSpells) then
        
        local totalSeconds = btnCCTarget1.Foe:MaxActiveCCExpires();
        if totalSeconds > 0 then
          --print("DEBUG:PvPHelperServer:OnUpdate: Current Active CC expires in "..totalSeconds.." sec.");
        end
        --print ("totalSeconds = btnCCTarget1.Foe:MaxActiveCCExpires(); = "..totalSeconds);
        -- Now loop through all of my Friendslist and find the next spell for each  
        local objFriendAssigned = FriendList.new();
        local objDRAssigned = FoeDRList.new();
        for i, objCC in pairs(objOrderedCCSpells) do
          
          if (objCC.Friend) then
             
            --Find the first of each DR Type
            if not objDRAssigned:LookupDRType(objCC.Spell.DRType) then
              -- This is the first of that DRType
              
              local nextCast = math.max(objCC.DRXpires, objCC.CDExpires);
              --print("math.max(objCC.DRXpires, objCC.CDExpires); = "..nextCast);
              local maxActiveCC = objCC.Foe:MaxActiveCCExpires();
              --print("maxActiveCC = objCC.Foe:MaxActiveCCExpires(); = " ..maxActiveCC);
              --local maxSeconds = totalSeconds + math.max(nextCast, maxActiveCC);
              local maxSeconds = math.max(nextCast, totalSeconds);

              --print("Found spell "..objCC.Spell.CCName.."("..objCC.Spell.SpellId..")["..objCC.Spell.DRType.."] for "..objCC.Friend.Name.." cast in "..maxSeconds.." sec")

              local note = Notification.new( 
                {To = objCC.Friend,
                SpellId = objCC.Spell.SpellId,
                Seconds = maxSeconds
                });

              if not objFriendAssigned:LookupGUID(objCC.Friend.GUID) then
                --print("DEBUG:OnUpdate:Add note for Spell "..objCC.Spell.CCName.."("..objCC.Spell.SpellId..")["..objCC.Spell.DRType.."] for "..objCC.Friend.Name.." cast in "..maxSeconds.." sec")
                iNotificationOrder = iNotificationOrder + 1;
                note.OrderId = iNotificationOrder;
                objPvPServer.NotificationList:Add(note);
              end
              
              totalSeconds = maxSeconds + objCC.Spell.Duration;
            
              objFriendAssigned:Add(Friend.new({GUID=objCC.Friend.GUID}));
              objDRAssigned:Add(FoeDR.new(objCC.Spell.DRType));
           
            else
              local nextCast = math.max(objCC.DRXpires, objCC.CDExpires);
              local maxActiveCC = objCC.Foe:MaxActiveCCExpires();
              local maxSeconds = totalSeconds + math.max(nextCast, maxActiveCC);

              --print("IGNORE spell "..objCC.Spell.CCName.."("..objCC.Spell.SpellId..")["..objCC.Spell.DRType.."] for "..objCC.Friend.Name.." cast in "..maxSeconds.." sec as DR will be called")

            end
            --end
          else
            --print("Ignore as for some reason we have a blank CC Record");
          end
        end


			else
				--frame.MessageFrame:AddMessage("No CC Spells available");
			end
		else
			print("got no CCtarget1 foe");
		end
	else
		print("Got no CCTarget1 button");
	end

	objPvPServer.NotificationList:SendNotifications();


		frame.TimeSinceLastUpdate = 0;
	end
end

function FixedSizeString(pstring, len)
	local paddedString = pstring .. "																									";
	return string.sub(paddedString, 1, len);
end


local pvpHelperServer = PvPHelperServer.new();


RegisterSlashCommands();


--RegisterAddonMessagePrefix("PvPHelperClient");
RegisterAddonMessagePrefix("PvPHelperServer");
