-- List of things to do
-- Rename frame.parent to frame.PvPHelperSserver
-- From the UI, when I click it, how do I run an LUA function rather than a simple /assist or /target?
-- Find that out then set the "Set CC button" to run the SendMessage commands that actually work.


function CreateUIElements(parent)
	--print("This is CreateUIElements Func"); 

	local frame = CreateFrame("Frame", "PVPHelperServer_MainFrame", UIParent);
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetResizable(true)
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)

	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	frame:SetBackdrop( { 
	  bgFile = "Interface/DialogFrame/UI-DialogBox-Background"
	  , edgeFile = "Interface/DialogFrame/UI-DialogBox-Border"
	  , tile = true
	  , tileSize = 32
	  , edgeSize = 16, 
	  insets = { left = 5, right = 5, top = 5, bottom = 5 }
	});

	frame:SetPoint("CENTER"); 
	frame:SetWidth(110); 
	frame:SetHeight(100);

	fontstring = frame:CreateFontString("PVPHelperServerText", "ARTWORK","GameFontNormal")
	fontstring:SetPoint("TOPLEFT", 5, -15);
	fontstring:SetSize(128, 12);

	frame.PvPHelperServer = parent;
	PvPHelperServer_MainFrame = frame;
	
	--CreateAssistButton();
    CreateCCButtons(parent);
    
    CreateMessageFrame(frame);
    
  return frame;
end


function PVPHelperServer_DragStart()
print("Called PVPHelperServer_DragStart()")
	PVPHelperServer_MainFrame:StartMoving();
end

function PVPHelperServer_DragStop()
print("Called PVPHelperServer_DragStop()")
	PVPHelperServer_MainFrame:StopMovingOrSizing();
end


--function CreateAssistButton()
--	--print("Starting to create Assist button..."); 
--
--  local button = CreateFrame("Button", "AssistButton", PvPHelperServer_MainFrame, "SecureActionButtonTemplate")
--      
----  button:SetText("ASSIST")
--  
--  button:SetAttribute("type1", "macro") -- left click causes macro
--  button:SetAttribute("macrotext1", "/say zomg a left click!"); -- text for macro on left click
--  
--  --button:SetTexture(1, 1, 1, 1)
--    
--  button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
--  button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
--  button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
--
--  button:SetPoint("TOPLEFT", -80, 50)
--  button:SetWidth(100)
--  button:SetHeight(60)
--  
--  UIWidgets.AssistButton = button;
--end
--

function CreateCCButtons(pvpHelperServer)

  GVAR.PVPHelperServer = pvpHelperServer;
  
	UIWidgets.CCButton = {};
	UIWidgets.CCButton[1] = CreateCCButton("btnCCTarget1",10,100,60);
	--UIWidgets.CCButton[2] = CreateCCButton("btnCCTarget2",120,100,60);
	
  UIWidgets.SetCCButton = {};
	UIWidgets.SetCCButton[1] = CreateSetCCButton("btnSetCCTarget1",10,40,30, UIWidgets.CCButton[1] );
	--UIWidgets.SetCCButton[2] = CreateSetCCButton("btnSetCCTarget2",120,40,30, UIWidgets.CCButton[2]);
  
	
	UIWidgets.SetCCButton[1]:SetScript("OnClick", SetupButtonWithClass);
	--UIWidgets.SetCCButton[2]:SetScript("OnClick", SetupButtonWithClass);

end

function CreateSetCCButton(strButtonName, iLeft, iWidth, iHeight, setButton)

  local button = CreateFrame("Button", strButtonName, PvPHelperServer_MainFrame, "SecureActionButtonTemplate")
  button:SetPoint("TOPLEFT", iLeft, 0)
  button:SetWidth(iWidth)
  button:SetHeight(iHeight)
      
--  button:SetText("ASSIST")
  
  
  --button:SetTexture(1, 1, 1, 1)
    
  button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
  button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

  button.SetButton = setButton
  return button;
--  UIWidgets.AssistButton = button;
end

function CreateCCButton(strButtonName, iLeft, iWidth, iHeight)
		--print("Starting to create button..."); 

		local button = CreateFrame("Button", strButtonName, PvPHelperServer_MainFrame, "SecureActionButtonTemplate")
    button:SetPoint("LEFT", iLeft, -40)
    button:SetWidth(iWidth)
    button:SetHeight(iHeight)
        
    --button:SetText(strButtonName)
--    button:SetNormalFontObject("GameFontNormalSmall")
    
    local qcolor = RAID_CLASS_COLORS["WARRIOR"]
    --button:SetTexture(1, 1, 1, 1)
    
  --  button:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
  --  button:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
  --  button:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
	
		button.Name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.Name:SetPoint("TOPLEFT",button,"TOPLEFT",0,0)
		button.Name:SetShadowOffset(0, 0)
		button.Name:SetShadowColor(0, 0, 0, 0)
		button.Name:SetTextColor(1, 1, 1, 1)


    button.ClassColorBackground = button:CreateTexture(nil, "BORDER")
    button.ClassColorBackground:SetTexture(.5, .5, .5, .5)
    button.ClassColorBackground:SetWidth(iWidth)
    button.ClassColorBackground:SetHeight(iHeight)
    button.ClassColorBackground:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)


    button.HealthBar = button:CreateTexture(nil, "ARTWORK")
    button.HealthBar:SetTexture(.6, .6, .6, .5)
    button.HealthBar:SetWidth(iWidth)
    button.HealthBar:SetHeight(iHeight/2)
		button.HealthBar:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -iHeight/2)
    
    button.HealthText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.HealthText:SetPoint("TOPLEFT",button,"TOPLEFT",0,-iHeight/2)
		button.HealthText:SetShadowOffset(0, 0)
		button.HealthText:SetShadowColor(0, 0, 0, 0)
		button.HealthText:SetTextColor(1, 1, 1, 1)
    button.HealthText:SetWidth(iWidth)


    --button.flashing = 1;
		--print("Created button "..strButtonName); 
		return button;
end

function SetupButtonWithClass(setbutton)
  button = setbutton.SetButton;
  local name = UnitName("target"); 
  if name then
    local guid = UnitGUID("target"); 
    --button.GUID = UnitGUID("target");
    print(name.." has the GUID: "..guid);
    local targetID = UnitGUID("target"); 
    local qname       = UnitName("target")
    print("Unitname = "..tostring(qname))
    local qclass, qclassFileName = UnitClass("target")
    print("qclass = "..tostring(qclass)..", qclassFileName= "..tostring(qclassFileName))
    local qcolor = RAID_CLASS_COLORS[qclassFileName]

    local foe = Foe.new ({GUID=guid, Name=name, Class=strupper(qclass)})
    button.Foe = foe;
    local foundfoe = GVAR.PVPHelperServer.FoeList:LookupGUID(guid)
    if not foundfoe then
      print("ADDED FOE "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") TO FOE LIST")
      GVAR.PVPHelperServer.FoeList:Add(foe);
    else
      print("FOUND FOE "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") IN FOE LIST")
    end

    --print(qclass, qcolor.r, qcolor.g, qcolor.b)
    

    local qSpec = GetSpecialization("target")
    print("qSpec = "..tostring(qSpec))

    local qSpecName = qSpec and select(2, GetSpecializationInfo(qSpec)) or "None"
    print("qSpecName = "..tostring(qSpecName))
    local qInspectSpec =  GetInspectSpecialization("target") 
    print("qInspectSpec = "..tostring(qInspectSpec))

    
    --local qclassToken = ENEMY_Data[i].classToken
    --local qspecNum    = ENEMY_Data[i].specNum
    --local qtalentSpec = ENEMY_Data[i].talentSpec

    --ENEMY_Name2Button[qname] = i
    --button.buttonNum = i

  --local qcolor = RAID_CLASS_COLORS[classFileName]
    --print(class, qcolor.r, qcolor.g, qcolor.b)
    

    local colR = qcolor.r
    local colG = qcolor.g
    local colB = qcolor.b
    button.colR  = colR
    button.colG  = colG
    button.colB  = colB
    button.colR5 = colR*0.5
    button.colG5 = colG*0.5
    button.colB5 = colB*0.5
    button.ClassColorBackground:SetTexture(button.colR5, button.colG5, button.colB5, 1)
    button.HealthBar:SetTexture(colR, colG, colB, 1)

    --print("healthbar texture set")

    button.Name:SetText(qname)
    
  
    button:SetText("ASSIST")
    button:SetAttribute("type1", "macro") -- left click causes macro
    button:SetAttribute("macrotext1", "/say zomg a left click!"); -- text for macro on left click

    if not inCombat or not InCombatLockdown() then
      button:SetAttribute("macrotext1", "/target "..qname)
      print("Set the Macro to /target "..qname)
      
  --    UIWidgets.AssistButton:SetAttribute("macrotext2", "/targetexact "..qname.."\n/focus\n/targetlasttarget")
    end

    DEFAULT_CHAT_FRAME:AddMessage( "target health ="..UnitHealth("target") )

    local maxHealth = UnitHealthMax("target")
    --print("Max health = ".. maxHealth )
    if maxHealth then
      local health = UnitHealth("target")
      SetButtonHealth(button, maxHealth, health);
    end


    --button:SetScript("OnClick", nil);
  end

  
  return button;
end

function SetButtonHealth(button, maxHealth, health)
  if maxHealth then
    local healthBarWidth = button.ClassColorBackground:GetWidth();
    if health then
      local width = 0.01
      local percent = 0
      if maxHealth > 0 and health > 0 then
        local hvalue = maxHealth / health
        width = healthBarWidth / hvalue
        width = math.max(0.01, width)
        width = math.min(healthBarWidth, width)
        percent = math.floor( (100/hvalue) + 0.5 )
        percent = math.max(0, percent)
        percent = math.min(100, percent)
      end
      --ENEMY_Name2Percent[targetName] = percent
      --print("health percent = ".. percent .."%")
      button.HealthBar:SetWidth(width)
      button.HealthText:SetText(percent)
    end
  end
  return button;
end

function CreateMessageFrame(parent)
	local messageFrame = CreateFrame("MessageFrame", nil, parent);

--	local t = f:CreateTexture(nil,"BACKGROUND")
--	t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
--	t:SetAllPoints(f)
--	f.texture = t

	messageFrame:SetBackdrop( { 
	  bgFile = "Interface/DialogFrame/UI-DialogBox-Background"
	  , edgeFile = "Interface/DialogFrame/UI-DialogBox-Border"
	  , tile = true
	  , tileSize = 32
	  , edgeSize = 16, 
	  insets = { left = 5, right = 5, top = 5, bottom = 5 }
	});

	messageFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT");
	messageFrame:SetWidth(500); 
	messageFrame:SetHeight(300);
	
	messageFrame:SetFontObject(GameFontNormal)
	messageFrame:SetTextColor(1, 1, 1, 1) -- default color
	messageFrame:SetJustifyH("LEFT")
	messageFrame:SetFading(false)
--	messageFrame:SetMaxLines(25)

	parent.MessageFrame = messageFrame;
	
--	
--	for i = 1, 25 do
--		messageFrame:AddMessage(i .. ". Here is a message!")
--	end

end