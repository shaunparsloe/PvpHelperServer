Roster = {};
GVAR = {};
GVAR.UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
UIWidgets = {}     -- UI Widgets

PVPHelperServer_Save = {};

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
  
	self.Message = Message.new();
	self.Message.Prefix = "PvPHelperClient";

	self.FriendList = FriendList.new();
	self.FoeList = FoeList.new();
	self.GlobalCCTypesList = {}
	self.GlobalCCDRList = {}
	self.InCombat = false;
	
	objDRTypesList = CCDRList.new()
	GVAR.AllDRTypes = objDRTypesList.LoadAllDRSpells()
	
	objList = nil;
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

    local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player").."-"..GetRealmName(), CCTypes=objCCTypeList})
    local objFriendList = FriendList.new()
    objFriendList:Add(objFriend)
    print("Clearing FoeList");
    local objFoeList = FoeList.new()
    self:ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})

  self.UI = {};
  
  self.Initialized = true;
end


function PvPHelperServer:ResetFriendsAndFoes(options)
  -- the new instance
  print("Resetting the PvPHelperServer:ResetFriendsAndFoes instance");
  self.FriendList = options.FriendList
  self.FoeList = options.FoeList
  self.GlobalCCTypesList = CCTypeList:LoadAllCCTypes();
  self.GlobalCCDRList = CCDRList.LoadAllDRSpells();
  
  	for i, k in pairs(self.FriendList) do
		if (k.Name) then
	  		print("PvPHelperServer:ResetFriendsAndFoes - Asking .." .. k.Name .. " for spells");
	  		self:SendMessage("WhatSpellsDoYouHave", nil, k.Name);
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
      print("PvPH_Server:Apply_Aura 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID..", ccName: "..objFriendSpell.CCName .." ccType)"..objFriendSpell.CCType)
      objFriendSpell:CastSpell();
    else
-- 		Don't bother with aura's that are applied by a non-CC spell
--      print("PvPH_Server:Apply_Aura 1) "..sourceGUID.." 2)"..sourceSpellId.." 3)"..destGUID)
--      print("PvPH_Server:Apply_Aura - Cannot find friend spell"..sourceSpellId)
    end
  else
    -- This aura wasn't applied by one of my friends:
  end
  
  local objFoundFoe = self.FoeList:LookupGUID(destGUID);
	-- In the foe when we apply the aura, it will start timers on both the ActiveCC and the DR Duration
  if objFoundFoe and objFriendSpell then
    objFoundFoe:CCAuraApplied(objFriendSpell)
  end

end  

-- When the aura is removed, that's when the countdown starts for the CC Cooldowns.
function PvPHelperServer:Remove_Aura(destGUID, spellId)
  local objFoundFoe = self.FoeList:LookupGUID(destGUID);

  if objFoundFoe then
    local cctype = GVAR.AllCCTypes:LookupSpellId(spellId)
    if cctype then
      objFoundFoe:CCAuraRemoved(cctype)
    end
  end
end  



-- This is an important function.  It will compile a list of all our CC spells and 
-- rank them based on which is on priority and cooldown and DR remaining.
function PvPHelperServer:OrderedCCSpells(CCTarget1GUID)
  local OrderedCCSpells = {};

	if (CCTarget1GUID) then
		--print("DEBUG: looking for FOE GUID "..CCTarget1GUID)
	  	local objFoundFoe = self.FoeList:LookupGUID(CCTarget1GUID);
		if objFoundFoe then
		
			--print("DEBUG: Found FOE GUID "..CCTarget1GUID)
  			local allFriendCCTypes = self.FriendList.FriendCCTypesList;

		    for i, ccFriendSpell in ipairs(allFriendCCTypes) do
		    
		      --print("FriendSpell "..i.."). "..ccFriendSpell.SpellId)
		      local objFoundFriend = self.FriendList:LookupGUID(ccFriendSpell.FriendGUID);
		      if objFoundFriend then
			
				local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(ccFriendSpell.SpellId);
		
				
				local cdExpires = objFriendSpell:CooldownExpires();

				local objDR = objFoundFoe.DRList:LookupDRType(objFriendSpell.DRType);
				local drLevel = 0;
				local drExpires  = 0;
				if (objDR) then 
					objDR:Recalculate();
					drExpires = objDR.DRExpires -- relative_valueof(objDR.DRExpires);
--					print("DRType = "..objDR.DRType.."drLevel = "..objDR.DRLevel.." cooldown="..objDR.DRExpires)
					drLevel = objDR.DRLevel;
				
				else
					drExpires = 0;
				end
--		
--		
		        --print("\nFriendSpell "..i.."). "..tostring(objFoundFriend.Name).." "..tostring(objFriendSpell.CCName))
		        --ccSpell = self.GlobalCCTypesList:LookupSpellId(ccFriendSpell.SpellId);
		    --    dr = CCTarget1.
		        --print("DRTYPE:"..tostring(objFriendSpell.DRType))
		        if objFriendSpell then
		        	table.insert(OrderedCCSpells, 
		        	{
		        	Friend=objFoundFriend,
		        	Foe=objFoundFoe, 
		        	FreindSpell=objFriendSpell, 
		        	FriendName=objFoundFriend.Name, 
		        	FriendSpellName=objFriendSpell.CCName, 
			    	CDExpires=cdExpires,
		        	Duration=objFriendSpell.Duration,
		        	DRLevel=drLevel,
		        	DRExpires=drExpires,
		        	Weighting=objFriendSpell.Weighting
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



	-- Sort by Cooldown,DRExpiry and spell weighting    
	table.sort(OrderedCCSpells, 
        function(x,y)
        	local retval = false;
        	if (x.CDExpires <= y.CDExpires) then
        		if (x.DRExpires <= y.DRExpires) then
        			if (x.Weighting <= y.Weighting) then
        				retval = true;
        			end
        		end
        	end
            return retval;
        end
    );
  
  return OrderedCCSpells;
  
end




function PvPHelperServer:MessageReceived(strPrefix, strMessage, strType, strSender)
  print("DEBUG: PvpHelperServer - Message Received "..strMessage);
--  print("DEBUG: PvpHelperServer - Message Received "..self.Message.Header..strSender);
  
  self.Message:Format(strPrefix, strMessage, strType, strSender)
  
	if (self.Message.Header)=="MySpells" then -- 0020 = MySpells  
		self:SetFriendSpells(self.Message.Body, self.Message.From)
  elseif (self.Message.Header)=="SpellCoolDown" then -- 0080 = ThisSpellIsOnCooldown
    self:SetFriendSpellOnCooldown(self.Message.Body, self.Message.From)
  elseif (self.Message.Header)=="ThisSpellIsOffCooldown" then -- 0090 = ThisSpellIsOffCooldown
    self:SetFriendSpellOffCooldown(self.Message.Body, self.Message.From)
	end
end

function PvPHelperServer:SendMessage(strMessage, strTarget, strTo)
  local objSentMessage = self.Message:SendMessagePrefixed("PvPHelperClient", strMessage, strTarget, strTo);
--  self.MessageLog.Sent[strMessage] = Message:Clone(objSentMessage)
  self.MessageLog.Sent[strMessage] = Message:Clone(objSentMessage)
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

function PvPHelperServer:SetFriendSpellOnCooldown(PaddedstrSpellId, strFrom)
 print(" PvPHelperServer:SetFriendSpellOnCooldown "..PaddedstrSpellId..", "..strFrom..")")
	strSpellId = strsub(PaddedstrSpellId, 7);
    local objFoundFriend = self.FriendList:LookupName(strFrom);
    if objFoundFriend then
      local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(strSpellId);
      if objFriendSpell then
        print("putting spell "..tostring(objFriendSpell.SpellId).." on cooldown")--
        objFriendSpell:CastSpell()  -- Mark this as cast to set timeout and cooldown
      else
        print("SetFriendSpellOnCooldown cannot find friendspell : "..strSpellId)
      end
    else
      print("SetFriendSpellOnCooldown cannot find friend : "..strFrom)
    end
    
    
end

function PvPHelperServer:SetFriendSpellOffCooldown(strSpellId, strFrom)
	--print("DEBUG: PvPHelperServer:SetFriendSpellOFFCooldown("..strSpellId..", "..strFrom..")")
	local objFoundFriend = self.FriendList:LookupName(strFrom);
    if objFoundFriend then
    	local objFriendSpell = objFoundFriend.CCTypes:LookupSpellId(strSpellId);
      	if objFriendSpell then
      		--print("DEBUG: putting spell "..tostring(objFriendSpell.SpellId).." OFF cooldown")--
        	objFriendSpell:Reset()  -- Mark this as cast to set timeout and cooldown
      	else
        	--print("DEBUG: SetFriendSpellOnCooldown cannot find friendspell : "..strSpellId)
      	end
    else
      	--print("DEBUG: SetFriendSpellOnCooldown cannot find friend : "..strFrom)
    end
end



-- OnEvent
function PVPHelperServer_OnEvent(self, event, ...)
		local timestamp, Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, param15,
		param16, param17, param18, param19, param20, param21, param22, param23=...
  local frame = self;

	objPvPServer = frame.PvPHelperServer
  
  
	if event == "PLAYER_LOGIN" then
	 objPvPServer:Initialize();
--    objCCTypeList = CCTypeList.new()
    
--    --print(objList:ListSpellIds())
--    for i,cctype in ipairs(GVAR.AllCCTypes) do
--      if IsSpellKnown(cctype.SpellId) then
--        print(i..") "..cctype.CCName)
--        objCCTypeList:Add(cctype)
--      end
--    end


  elseif(event=="RAID_ROSTER_UPDATE") then
    --UpdateFriendsList()
  
		if not(UnitInRaid("player")) then
			frame:RegisterEvent("PARTY_MEMBERS_CHANGED"); --reactive party watching on raid leave
			return;
		end
		local _,name,class,role
    
--    local objFriend = Friend.new({GUID=UnitGUID("player"), Name=UnitName("player"), CCTypes=objCCTypeList})
--    --objFriendList:Add(objFriend)
--    local objFoeList = FoeList.new()
--    objPvPServer = PvPHelperServer.ResetFriendsAndFoes({FriendList = objFriendList, FoeList = objFoeList})
print("DEBUG: Raid roster update");
    local objFriendList = FriendList.new()
    
		for i=1,GetNumRaidMembers() do
			name,_,_,_,_,class,_,online,_,_,_,role = GetRaidRosterInfo(i);
      local objFriend = Friend.new({GUID=UnitGUID(name), Name=name, CCTypes=CCTypeList.new()})
        print("DEBUG: PvpHelperServer RAID_ROSTER_UPDATE- adding " + name + " to friendlist");

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
	              print("DEBUG: PvpHelperServer PARTY_MEMBERS_CHANGED- adding " + name + " to friendlist");
	
	      objFriendList:Add(objFriend)
		end
  
	    objPvPServer.FriendList = nil;
	    objPvPServer.FriendList = objFriendList
	
	elseif event == "PLAYER_REGEN_DISABLED" then
		objPvPServer.InCombat = true;
		
	elseif event == "PLAYER_REGEN_ENABLED" then
		objPvPServer.InCombat = false;




  elseif event == "PLAYER_ENTERING_WORLD" then
	 objPvPServer:Initialize();
  
  elseif event == "ZONE_CHANGED_NEW_AREA" then
--    print("Event ZONE_CHANGED_NEW_AREA fired")
    objPvPServer:Initialize();
  elseif event == "CHAT_MSG_ADDON" then
--	print("PvPHelperServer-MESSAGE RECEIVED with stamp "..timestamp.." - "..tostring(Event))
    if (timestamp == "PvPHelperServer") then
      objPvPServer:MessageReceived(tostring(timestamp), tostring(Event), tostring(hideCaster), tostring(sourceGUID))
--	else
--		print("PvpHelperServer ERROR Message Received with stamp "..timestamp)
    end

    
  elseif event=="COMBAT_LOG_EVENT_UNFILTERED" then
		if Event=="SPELL_AURA_REMOVED" then
        	 objPvPServer:Remove_Aura(destGUID, spellId)   
    	elseif Event=="SPELL_AURA_APPLIED" or Event=="SPELL_AURA_REFRESH" then
    		objPvPServer:Apply_Aura(sourceGUID, spellId, destGUID)
		end
	end
end



function RegisterMainFrameEvents(self)

	PvPHelperServer_MainFrame.TimeSinceLastUpdate = 0;

	PvPHelperServer_MainFrame:SetScript("OnUpdate", PVPHelperServer_OnUpdate)
	PvPHelperServer_MainFrame:SetScript("OnEvent", PVPHelperServer_OnEvent)
	
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PvPHelperServer_MainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_LOGIN");
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PvPHelperServer_MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	PvPHelperServer_MainFrame:RegisterEvent("CHAT_MSG_ADDON");
	PvPHelperServer_MainFrame:RegisterEvent("RAID_ROSTER_UPDATE");
	PvPHelperServer_MainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	PvPHelperServer_MainFrame:RegisterEvent("PLAYER_REGEN_ENABLED");

end



  
-- Functions Section
function PVPHelperServer_OnUpdate(frame, elapsed)

  frame.TimeSinceLastUpdate = frame.TimeSinceLastUpdate + elapsed; 	

  if (frame.TimeSinceLastUpdate > GVAR.UpdateInterval) then
		--PVPHelperServerText:SetText(TimeString.." "..string.format("%.2f\n", seconds));
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
	--frame.MessageFrame:AddMessage("TEST",1,1,1);
	
	
	--frame.PVPHelperServer_MessageFrame.AddMessage("TESTING");
	frame.MessageFrame:Clear();
	local objPvPServer
	objPvPServer = frame.PvPHelperServer;
	
	
	local btnCCTarget1 = UIWidgets.CCButton[1];
	if (btnCCTarget1) then
		if (btnCCTarget1.Foe) then
			local allSpells = objPvPServer:OrderedCCSpells(btnCCTarget1.Foe.GUID);
			frame.MessageFrame:Clear();
			frame.MessageFrame:AddMessage("CDExpires, DRExpires, SPELL NAME, IsCD, Duration, DRLevel");
			if (allSpells) then
				local objFirstSpell = allSpells[1];
				local objFoe = objFirstSpell.Foe;
				local nextCast = math.max(objFirstSpell.DRExpires, objFirstSpell.CDExpires);
				local maxActiveCC = objFoe.CCTypeList:MaxActiveCCExpires();

				print("Must tell "..objFirstSpell.FriendName.." to cast "..objFirstSpell.FriendSpellName.." in " ..tostring(nextCast+maxActiveCC).."sec");

			else
					frame.MessageFrame:AddMessage("No CC Spells available");
			end
		else
	--		print("got no CCtarget1 foe");
		end
	else
		print("Got no CCTarget1 button");
	end

--	print("For now, for testing only, hard-code GUID")
--
--  local objPvPServer
--  objPvPServer = frame.parent.PvPServer;
--

--    local btnCCTarget1 = UIWidgets.CCButton[1];
--    if (btnCCTarget1) then
--      if (btnCCTarget1.Foe) then
--        --print("Got Button btnCCTarget1 FOE:"); 
--          friendcc, doNextCC = objPvPServer:NextCCSpell(btnCCTarget1.Foe.GUID)
--          if (friendcc) then
--            local ccdrtype = GVAR.AllCCTypes:LookupSpellId(friendcc.SpellId)
--            local objLastMessage = frame.parent.MessageLog.Sent["DoActionNow"]
--            if (not objLastMessage) or (not (objLastMessage.To == friendcc.FriendName and tonumber(objLastMessage.Payload) == friendcc.SpellId and objLastMessage.Time + 5 >= time())) then
--            -- DoActionNow
--            frame.parent:SendMessage("DoActionNow", friendcc.SpellId, friendcc.FriendName)
--            
--            --SendAddonMessage( "PvPHelper", "0060:"..friendcc.SpellId, "WHISPER", friendcc.FriendName);
----              LastMessage.To = friendcc.FriendName;
----              LastMessage.SpellId = friendcc.SpellId
----              LastMessage.SentTime = time();
--            end
--          else
--            print("No available CC's")
--          end
--        
--          if (doNextCC) then
--            local ccdrtype = GVAR.AllCCTypes:LookupSpellId(doNextCC.SpellId)
--            local objLastMessage = frame.parent.MessageLog.Sent["PrepareToAct"]
--            --if objLastMessage then
--            --  print ("Compare lastmessage to donextcc")
--            --  print (objLastMessage.To.." == "..doNextCC.FriendName)
--            --  print (tostring(objLastMessage.Text).." == "..tostring(doNextCC.SpellId))
--            --  print (tostring(objLastMessage.Payload).." == "..tostring(doNextCC.SpellId))
--            --  print (tostring(objLastMessage.Prefix).." == "..tostring(doNextCC.SpellId))
--            --  print (tostring(objLastMessage.Body).." == "..tostring(doNextCC.SpellId))
--            --  print (tostring(objLastMessage.Time).." >= "..tostring(time()))
--            --end
--            if (not objLastMessage) or (not (objLastMessage.To == doNextCC.FriendName and tonumber(objLastMessage.Payload) == doNextCC.SpellId and objLastMessage.Time + 5 >= time())) then
--              -- DoActionNow
--              frame.parent:SendMessage("PrepareToAct", doNextCC.SpellId, doNextCC.FriendName)
--              --SendAddonMessage( "PvPHelper", "0060:"..friendcc.SpellId, "WHISPER", friendcc.FriendName);
----              LastMessage.To = friendcc.FriendName;
----              LastMessage.SpellId = friendcc.SpellId
----              LastMessage.SentTime = time();
--            end
--          else
--            print("No doNextCC CC's")
--          end
--
--        if (UnitGUID("target")) then
--          --print("I have a target:"); 
--          --print("TargetA GUID = "..tostring(btnCCTarget1.GUID)); 
--          --print("TargetB GUID = "..tostring(UnitGUID("target"))); 
--          
--          if (tostring(btnCCTarget1.Foe.GUID) == tostring(UnitGUID("target"))) then
--            UIWidgets.AssistButton:SetAlpha(0);
--            local maxHealth = UnitHealthMax("target")
--            --print("Max health = ".. maxHealth )
--            if maxHealth then
--              local health = UnitHealth("target")
--              --print("Setting Health" )
--              SetButtonHealth(btnCCTarget1, maxHealth, health);
--              --local foundfoe = GVAR.FoeList.LookupGUID(btnCCTarget1.Foe.GUID)
--              --PVPHelperServerText:SetText(foundfoe.DRList:ListDRs());
--            end
--          else
--            UIWidgets.AssistButton:SetAlpha(1);
--          end
--        else
--          UIWidgets.AssistButton:SetAlpha(1);
--        end
--      end
--    else 
--      print("No UIWidgets.CCButton[1] set up");
--    end
--  
	  frame.TimeSinceLastUpdate = 0;
  end
end

function FixedSizeString(pstring, len)
 local paddedString = pstring .. "                                                  ";
 return string.sub(paddedString, 1, len);
end


local pvpHelperServer = PvPHelperServer.new();


RegisterSlashCommands();


--RegisterAddonMessagePrefix("PvPHelperClient");
RegisterAddonMessagePrefix("PvPHelperServer");
