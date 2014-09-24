-- Server code
Roster = {};
GVAR = {};
GVAR.UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
UIWidgets = {}		 -- UI Widgets

PVPHelperServer_Save = {};

PvPHelperServer = {}
PvPHelperServer_MainFrame = {}
PvPHelperServer.__index = PvPHelperServer; -- failed table lookups on the instances should fallback to the class table, to get methods

local xDebug = false
local L = PVPHelper_LocalizationTable;

-- Globals Section
local AllCCTypes;
local AllDRTypes;
local CONSTANTS = {};


function PvPHelperServer.new (options)
	local self = setmetatable({}, PvPHelperServer)
	
	
	self.NotificationList= NotificationList.new();

	self.Message = deepcopy(Message.new());
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
	self.MessageLog = {}
	self.MessageLog.Sent = {}
	self.MessageLog.Received= {}

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
	self.FoeList = options.FoeList
	self.GlobalCCTypesList = CCTypeList:LoadAllCCTypes();
	self.GlobalCCDRList = CCDRList.LoadAllDRSpells();
	
	for i, k in pairs(self.FriendList) do
		if (k.Name) then
				--print("DEBUG:PvPHelperServer:ResetFriendsAndFoes - Asking .." .. k.Name .. " for spells");
				self:SendMessage("WhatSpellsDoYouHave", 1234556, k.Name);
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
			--print("PvPH_Server:Apply_Aura -CAST SPELL 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID..", ccName: "..objFriendSpell.CCName .." ccType)"..objFriendSpell.CCType)
			objFriendSpell:CastSpell();


		local objFoundFoe = self.FoeList:LookupGUID(destGUID);
	-- In the foe when we apply the aura, it will start timers on both the ActiveCC and the DR Duration
	if objFoundFoe and objFriendSpell then
		objFoundFoe:CCAuraApplied(objFriendSpell)
	end

		
		else
--			print("PvPH_Server:Apply_Aura 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID)
			print("PvPH_Server:Apply_Aura - Cannot find friend spell"..sourceSpellId)
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
      print("Cannot find cctype");
		end
  else
    print("Cannot find Foe");
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
					
					local isAvail;
					if (objFriendSpell:IsAvailable()) then
						isAvail = "Available";
					else
						isAvail = "COOLDOWN";
					end
			
					
					local cdExpires = objFriendSpell:CooldownExpires();
		
					local objDR = objFoundFoe.DRList:LookupDRType(objFriendSpell.DRType);
					local drLevel = 0;
					local drExpires	= 0;
					if (objDR) then 
						objDR:Recalculate();
						drExpires = objDR.DRExpires -- relative_valueof(objDR.DRExpires);
						drLevel = objDR:DRLevel();
					else
						drExpires = 0;
					end
			
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
					if (x.CDExpires <= y.CDExpires) then
						if (x.DRXpires <= y.DRXpires) then
							if (x.Spell.Weighting <= y.Spell.Weighting) then
								retval = true;
							end
						end
					end
					return retval;
				end
		);
	
	return objOrderedCCSpells;
	
end


function PvPHelperServer:SetNotification(notification)

--	if (self.LastSentNotification.To == notification.To and self.LastSentNotification.SpellId == notification.SpellId) then
--		--print("DEBUG: Notification: Have sent before");
--		-- So we have already notified this person about this spell before
--		-- So, if we've told them to act in 10sec, but suddenly want to tell them to act now, then override that way.
----		if (notification.Seconds == 0 and self.LastSentNotification.Seconds > 0) then
----			print("DEBUG: Notification: Updating notification");
----			self.Notification.Seconds = 0;
----			self.Notification.ExecutionTime = GetTime();
----		end
--	else
--		-- Ok, so this is the first time this person+Spell combination has been called.
--		-- Normally will be a "Prepare to Act" kind of instruction, but could be an "Act Now" action too.
--		print("DEBUG: Notification: First notification");
--		self.Notification = deepcopy(notification);
--
--	end		
--	
	self.Notification = deepcopy(notification);
	self.Notification.TimeLastApplied = GetTime();
	
end

function PvPHelperServer:SendNotifications()
  for i,note in ipairs(self.NotificationList) do
    note:Send();
  end
end

function PvPHelperServer:OLDSendNotifications()
	local note = self.Notification;
	if (note) and not xDebug then
		
		--print("DEBUG: note.ExecutionTime ".. note.ExecutionTime.." time "..currentTime);
		
		local strMessage = nil;
		local strAppend = "";
		local currentTime = GetTime();

		
		if note.ExecutionTime > currentTime then
			strMessage = "PrepareToAct";

			print("Execution time is in the future - so prepare to act");
			--xDebug = true;
			print("lastMsg: Spell:"..tostring(self.LastSentNotification.SpellId).."="..note.SpellId
			..", "..tostring(self.LastSentNotification.Message).."="..tostring(strMessage)
			..", "..tostring(self.LastSentNotification.ExecutionTime).."="..note.ExecutionTime);	
				
			if not (self.LastSentNotification.To == note.To 
				and self.LastSentNotification.SpellId == note.SpellId
				and self.LastSentNotification.Message == strMessage
				and math.abs(self.LastSentNotification.ExecutionTime - note.ExecutionTime) < 0.5	) then
				-- First time we have had to Prepare - send now
				print("PvPHelperServer DEBUG: About to send message: "..strMessage..", "..	note.SpellId..strAppend..", "..note.To);
				strAppend = ","..tostring(note.ExecutionTime - currentTime)
				self:SendMessage(strMessage, note.SpellId..strAppend, note.To);
				note.Message = strMessage;
				self.LastSentNotification = deepcopy(note);
			end		
		else
		print("Execution time Current Or Past. LastSent:"..currentTime - self.LastSentNotification.ExecutionTime);
			local sendTime = nil;
			if self.LastSentNotification.ExecutionTime + 13 <= currentTime then
					-- Bah, don't bother, if they've not responded in 11sec, they wont!
				print("Bah - dont't bother");
			elseif self.LastSentNotification.ExecutionTime + 11 <= currentTime then
				print("5");
				strMessage = "VeryLateActNow";
				sendTime = self.LastSentNotification.ExecutionTime + 11
			elseif self.LastSentNotification.ExecutionTime + 8 <= currentTime then
				print("4");
				strMessage = "VeryLateActNow";
				sendTime = self.LastSentNotification.ExecutionTime + 8;
			elseif self.LastSentNotification.ExecutionTime + 6 <= currentTime then
				print("3");
				strMessage = "LateActNow";
				sendTime = self.LastSentNotification.ExecutionTime + 6;
			elseif self.LastSentNotification.ExecutionTime + 4 <= currentTime then
				print("2");
				strMessage = "LateActNow";
				sendTime = self.LastSentNotification.ExecutionTime + 4;
			elseif self.LastSentNotification.ExecutionTime + 1 <= currentTime then
				print("1");
				strMessage = "ActNow";
				sendTime = self.LastSentNotification.ExecutionTime;
			elseif self.LastSentNotification.ExecutionTime <= currentTime then
				print("0");
				strMessage = "ActNow";
				sendTime = self.LastSentNotification.ExecutionTime;
			end	
			if strMessage then

			print("lastMsg: Spell:"..tostring(self.LastSentNotification.SpellId).."="..note.SpellId
			..", "..tostring(self.LastSentNotification.Message).."="..tostring(strMessage)
			..", "..tostring(self.LastSentNotification.ExecutionTime).."="..sendTime);	

				
				if not (self.LastSentNotification.To == note.To 
					and self.LastSentNotification.SpellId == note.SpellId
					and self.LastSentNotification.Message == strMessage
					and math.abs(self.LastSentNotification.ExecutionTime - sendTime) < 0.5	) then
				-- First time we have had to Prepare - send now
					print("PvPHelperServer DEBUG: About to send message: "..strMessage..", "..	note.SpellId..", "..note.To);
					self:SendMessage(strMessage, note.SpellId, note.To);
					note.Message = strMessage;
					self.LastSentNotification = deepcopy(note);
				end
			end
			
		end
	end
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
  table.insert(self.MessageLog.Sent, deepcopy(objSentMessage));
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

function PvPHelperServer:SetFriendSpellOnCooldown(strSpellId, strFrom)
	--print(" PvPHelperServer:SetFriendSpellOnCooldown "..strSpellId..", "..strFrom..")")
	--strSpellId = strsub(PaddedstrSpellId, 7);
		local objFoundFriend = self.FriendList:LookupName(strFrom);
		if objFoundFriend then
			local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(strSpellId);
			if objFriendSpell then
				--print("putting spell "..tostring(objFriendSpell.SpellId).." on cooldown")--
				objFriendSpell:CastSpell()	-- Mark this as cast to set timeout and cooldown
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
--		objCCTypeList = CCTypeList.new()
		
--		--print(objList:ListSpellIds())
--		for i,cctype in ipairs(GVAR.AllCCTypes) do
--			if IsSpellKnown(cctype.SpellId) then
--				print(i..") "..cctype.CCName)
--				objCCTypeList:Add(cctype)
--			end
--		end


	elseif(event=="RAID_ROSTER_UPDATE") then
		--UpdateFriendsList()
	
		if not(UnitInRaid("player")) then
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED"); --reactive party watching on raid leave
			return;
		end
		local _,name,class,role
		
--		local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player"), CCTypes=objCCTypeList})
--		--objFriendList:Add(objFriend)
--		local objFoeList = FoeList.new()
--		objPvPServer = PvPHelperServer.ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})
--print("DEBUG: Raid roster update");
		local objFriendList = FriendList.new()
		
		for i=1,GetNumRaidMembers() do
			name,_,_,_,_,class,_,online,_,_,_,role = GetRaidRosterInfo(i);
			local objFriend = Friend.new({GUID=UnitGUID(name), Name=name, CCTypes=CCTypeList.new()})
				--print("DEBUG: PvpHelperServer RAID_ROSTER_UPDATE- adding " .. tostring(name) .." to friendlist");

			objFriendList:Add(objFriend)
		end
	
		objPvPServer.FriendList = nil;
		objPvPServer.FriendList = objFriendList

	elseif(event=="PARTY_MEMBERS_CHANGED") then

		if UnitInRaid("player") then
			frame:UnregisterEvent("PARTY_MEMBERS_CHANGED"); --no need to use this if in raid
			return
		elseif not(UnitInParty("player")) then
			return
		end

		local objFriendList = FriendList.new()
		
		for i=1,GetNumPartyMembers() do
			unittowatch = "party"..i;
			local _,isdead,online,name,class,guid;
			isdead = UnitIsDeadOrGhost(unittowatch);
			name = UnitName(unittowatch);
			online = UnitIsConnected(unittowatch);
			_,class = UnitClass(unittowatch);
			guid = UnitGUID(unittowatch);
			
			local objFriend = Friend.new({GUID=guid, Name=name, CCTypes=CCTypeList.new()})
			--print("DEBUG: PvpHelperServer PARTY_MEMBERS_CHANGED- adding " .. name .. " to friendlist");

			objFriendList:Add(objFriend)
		end
	
		objPvPServer.FriendList = nil;
		objPvPServer.FriendList = objFriendList



	elseif event == "PLAYER_ENTERING_WORLD" then

--		local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player").."-"..GetRealmName(), CCTypes=objCCTypeList})
--		local objFriendList = FriendList.new()
--		objFriendList:Add(objFriend)
--		print("Clearing FoeList");
--		local objFoeList = FoeList.new()
--		objPvPServer:ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})
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

	frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed; 	

	if (frame.TimeSinceLastUpdate > GVAR.UpdateInterval) then
		--PVPHelperServerText:SetText(TimeString.." "..string.format("%.2f\n", seconds));
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
	--frame.MessageFrame:AddMessage("TEST",1,1,1);
	
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
	frame.MessageFrame:Clear();
	local objPvPServer = frame.PvPHelperServer;
	
	
	local btnCCTarget1 = UIWidgets.CCButton[1];
	if (btnCCTarget1) then
		if (btnCCTarget1.Foe) then
			local objOrderedCCSpells = objPvPServer:OrderedCCSpells(btnCCTarget1.Foe.GUID);
			--frame.MessageFrame:Clear();
			--frame.MessageFrame:AddMessage("CDExpires, DRExpires, SPELL NAME, IsCD, IsAvail, Duration, DRLevel");
			if (objOrderedCCSpells) then
        
        -- Now loop through all of my Friendslist and find the next spell for each  
        objAssigned = FriendList.new();
        for i, objCC in pairs(objOrderedCCSpells) do
          
          if (objCC.Friend) then
             
            if not objAssigned:LookupGUID(objCC.Friend.GUID) then
              -- Not assigned yet
              objAssigned:Add(Friend.new({GUID=objCC.Friend.GUID}));
              print("Found spell "..objCC.Spell.CCName.." for "..objCC.Friend.Name)
              
              local nextCast = math.max(objCC.DRXpires, objCC.CDExpires);
              local maxActiveCC = objFoe.CCTypeList:MaxActiveCCExpires();

              local note = Notification.new( 
                {To = objCC.Friend,
                SpellId = objSpell.SpellId,
                Seconds = math.max(nextCast, maxActiveCC)});
            
              objPvPServer.NotificationList:Add(note);
              
            end
          else
            print("Ignore as for some reason we have a blank CC Record");
          end
        end

              
--				local objFirstSpell = objOrderedCCSpells[1];
--				local objFoe = objFirstSpell.Foe;
--				local objSpell = objFirstSpell.FriendSpell;
--				local nextCast = math.max(objFirstSpell.DRXpires, objFirstSpell.CDExpires);
				--print("DEBUG:PVPHelperServer_OnUpdate: Must tell "..objFirstSpell.FriendName.." to cast "..objSpell.CCName.."("..tostring(objSpell.SpellId)..") in " ..tostring(math.max(nextCast+maxActiveCC)).."sec ("..nextCast.."/"..maxActiveCC..")");
--				local note = Notification.new( {To = objFirstSpell.FriendName,
--          SpellId = objSpell.SpellId,
--          Seconds = math.max(nextCast, maxActiveCC), 
--          Message = ""});
  --      objPvPServer:SetNotification(note);
      
--        for i, objCCSpell in ipairs(objOrderedCCSpells) do
--         objFoe = objCCSpell.Foe;
--          objFriendSpell = objCCSpell.FriendSpell;
--          nextCast = math.max(objCCSpell.DRXpires, objCCSpell.CDExpires);
--          maxActiveCC = objFoe.CCTypeList:MaxActiveCCExpires();
--          frame.MessageFrame:AddMessage(
--          tostring(objCCSpell.CDExpires)
--          ..", "..tostring(objCCSpell.DRXpires)
--          ..", "..tostring(objFriendSpell.CCName)
--          ..", "..tostring(objFriendSpell._IsCooldown)
--          ..", "..tostring(objFriendSpell:IsAvailable())
--          ..", "..tostring(objFriendSpell.Duration)
--          ..", "..tostring(objCCSpell.DRLevel)
--          
--          );
--        end

			else
				frame.MessageFrame:AddMessage("No CC Spells available");
			end
		else
			print("got no CCtarget1 foe");
		end
	else
		print("Got no CCTarget1 button");
	end

	--print("SendNotifications");
			--objPvPServer:SendMessage("BLAHBLAH", "15487", "Vordermann-Hellfire");
	objPvPServer:SendNotifications()	;

--	print("For now, for testing only, hard-code GUID")
--
--	local objPvPServer
--	objPvPServer = frame.parent.PvPServer;
--

--		local btnCCTarget1 = UIWidgets.CCButton[1];
--		if (btnCCTarget1) then
--			if (btnCCTarget1.Foe) then
--				--print("Got Button btnCCTarget1 FOE:"); 
--					friendcc, doNextCC = objPvPServer:NextCCSpell(btnCCTarget1.Foe.GUID)
--					if (friendcc) then
--						local ccdrtype = GVAR.AllCCTypes:LookupSpellId(friendcc.SpellId)
--						local objLastMessage = frame.parent.MessageLog.Sent["DoActionNow"]
--						if (not objLastMessage) or (not (objLastMessage.To == friendcc.FriendName and tonumber(objLastMessage.Payload) == friendcc.SpellId and objLastMessage.Time + 5 >= GetTime())) then
--						-- DoActionNow
--						frame.parent:SendMessage("DoActionNow", friendcc.SpellId, friendcc.FriendName)
--						
--						--SendAddonMessage( "PvPHelper", "0060:"..friendcc.SpellId, "WHISPER", friendcc.FriendName);
----							LastMessage.To = friendcc.FriendName;
----							LastMessage.SpellId = friendcc.SpellId
----							LastMessage.SentTime = GetTime();
--						end
--					else
--						print("No available CC's")
--					end
--				
--					if (doNextCC) then
--						local ccdrtype = GVAR.AllCCTypes:LookupSpellId(doNextCC.SpellId)
--						local objLastMessage = frame.parent.MessageLog.Sent["PrepareToAct"]
--						--if objLastMessage then
--						--	print ("Compare lastmessage to donextcc")
--						--	print (objLastMessage.To.." == "..doNextCC.FriendName)
--						--	print (tostring(objLastMessage.Text).." == "..tostring(doNextCC.SpellId))
--						--	print (tostring(objLastMessage.Payload).." == "..tostring(doNextCC.SpellId))
--						--	print (tostring(objLastMessage.Prefix).." == "..tostring(doNextCC.SpellId))
--						--	print (tostring(objLastMessage.Body).." == "..tostring(doNextCC.SpellId))
--						--	print (tostring(objLastMessage.Time).." >= "..tostring(GetTime()))
--						--end
--						if (not objLastMessage) or (not (objLastMessage.To == doNextCC.FriendName and tonumber(objLastMessage.Payload) == doNextCC.SpellId and objLastMessage.Time + 5 >= GetTime())) then
--							-- DoActionNow
--							frame.parent:SendMessage("PrepareToAct", doNextCC.SpellId, doNextCC.FriendName)
--							--SendAddonMessage( "PvPHelper", "0060:"..friendcc.SpellId, "WHISPER", friendcc.FriendName);
----							LastMessage.To = friendcc.FriendName;
----							LastMessage.SpellId = friendcc.SpellId
----							LastMessage.SentTime = GetTime();
--						end
--					else
--						print("No doNextCC CC's")
--					end
--
--				if (UnitGUID("target")) then
--					--print("I have a target:"); 
--					--print("TargetA GUID = "..tostring(btnCCTarget1.GUID)); 
--					--print("TargetB GUID = "..tostring(UnitGUID("target"))); 
--					
--					if (tostring(btnCCTarget1.Foe.GUID) == tostring(UnitGUID("target"))) then
--						UIWidgets.AssistButton:SetAlpha(0);
--						local maxHealth = UnitHealthMax("target")
--						--print("Max health = ".. maxHealth )
--						if maxHealth then
--							local health = UnitHealth("target")
--							--print("Setting Health" )
--							SetButtonHealth(btnCCTarget1, maxHealth, health);
--							--local foundfoe = GVAR.FoeList.LookupGUID(btnCCTarget1.Foe.GUID)
--							--PVPHelperServerText:SetText(foundfoe.DRList:ListDRs());
--						end
--					else
--						UIWidgets.AssistButton:SetAlpha(1);
--					end
--				else
--					UIWidgets.AssistButton:SetAlpha(1);
--				end
--			end
--		else 
--			print("No UIWidgets.CCButton[1] set up");
--		end
--	
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
