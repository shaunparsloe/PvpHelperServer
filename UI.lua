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

	local fontstring = frame:CreateFontString("PVPHelperServerText", "ARTWORK","GameFontNormal")
	fontstring:SetPoint("TOPLEFT", 5, -15);
	fontstring:SetSize(128, 12);

	frame.PvPHelperServer = parent;
	PvPHelperServer_MainFrame = frame;
	
	--CreateAssistButton();
    CreateCCButtons(parent);
    
    --CreateMessageFrame(frame);
    
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


function CreateCCButtons(pvpHelperServer)

  GVAR.PVPHelperServer = pvpHelperServer;
  
	UIWidgets.CCButton = {};
	UIWidgets.CCButton[1] = CreateCCButton("btnCCTarget1",10,100,60);

  UIWidgets.SetCCButton = {};
	UIWidgets.SetCCButton[1] = CreateSetCCButton("btnSetCCTarget1",10,40,30, UIWidgets.CCButton[1] );
	
	UIWidgets.SetCCButton[1]:SetScript("OnClick", SetupButtonWithClass);


end

function CreateSetCCButton(strButtonName, iLeft, iWidth, iHeight, setButton)

  local button = CreateFrame("Button", strButtonName, PvPHelperServer_MainFrame, "SecureActionButtonTemplate")
  button:SetPoint("TOPLEFT", iLeft, 0)
  button:SetWidth(iWidth)
  button:SetHeight(iHeight)
      
  button:SetText("SET")
    
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

		--print("DEBUG:UI:Created button "..strButtonName); 
		return button;
end


function SetupButtonWithClass(setbutton)
  local button = setbutton.SetButton;
  local focusName = UnitName("focus"); 

  if focusName then -- Have I focussed on anyone?
    local focusGuid = UnitGUID("focus"); 
    local focusID = UnitGUID("focus"); 
    local focusName = UnitName("focus")
    local localizedClass, focusClassName = UnitClass("focus")
    local focusClassColour = RAID_CLASS_COLORS[focusClassName]


    local foe
    local foundfoe = GVAR.PVPHelperServer.FoeList:LookupGUID(focusGuid)
    if foundfoe then
      foe = foundfoe;
      print("DEBUG:UI:SetupButtonWithClass():FOUND FOE "..tostring(foe.Class).." "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") IN FOE LIST")
    else 
      foe = Foe.new ({GUID=focusGuid, Name=focusName, Class=focusClassName})
      print("DEBUG:UI:SetupButtonWithClass():ADDED FOE "..tostring(localizedClass).." "..tostring(foe.Name).." (".. tostring(foe.GUID) ..") TO FOE LIST")
      GVAR.PVPHelperServer.FoeList:Add(foe);
    end
    
    local colR = focusClassColour.r
    local colG = focusClassColour.g
    local colB = focusClassColour.b
      
    if not inCombat or not InCombatLockdown() then
      
      button.Foe = foe;
      
      button.colR  = colR
      button.colG  = colG
      button.colB  = colB
      button.colR5 = colR*0.5
      button.colG5 = colG*0.5
      button.colB5 = colB*0.5
      button.ClassColorBackground:SetTexture(button.colR5, button.colG5, button.colB5, 1)
      button.HealthBar:SetTexture(colR, colG, colB, 1)

      --print("healthbar texture set")

      button.Name:SetText(focusName)
      
    
      button:SetText("ASSIST")
      button:SetAttribute("type1", "macro") -- left click causes macro
      
      --button:SetAttribute("macrotext1", "/target arena1; /focus arena2"); -- text for macro on left click

      button:SetAttribute("macrotext1", "/focus "..focusName)
      print("Set the Macro to /focus "..focusName)
      
  --    UIWidgets.AssistButton:SetAttribute("macrotext2", "/targetexact "..qname.."\n/focus\n/targetlasttarget")
  
      local maxHealth = UnitHealthMax("focus")
      --print("Max health = ".. maxHealth )
      if maxHealth then
        local health = UnitHealth("focus")
        SetButtonHealth(button, maxHealth, health);
      end

    end

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
      
      --print("health percent = ".. percent .."%")
      button.HealthBar:SetWidth(width)
      button.HealthText:SetText(percent)
    end
  end
  return button;
end
