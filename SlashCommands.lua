function PVPHelperServer_Command(msg)
	local setting = strsub(string.lower(msg), 1, 4);
	if( setting == "hour" ) then
		PVPHelperServer_Save["HourOff"] = strsub(msg, 6, strlen(msg));
		ChatFrame1:AddMessage("Hour offset set to "..PVPHelperServer_Save["HourOff"]);
	elseif( setting == "mnut" ) then
		PVPHelperServer_Save["MinuteOff"] = strsub(msg, 6, strlen(msg));
		ChatFrame1:AddMessage("Minute offset set to "..PVPHelperServer_Save["MinuteOff"]);
	elseif( setting == "show" ) then
		PVPHelperServer_MainFrame:Show();
		PVPHelperServer_Save['Visible'] = true;
	elseif( setting == "hide" ) then
		PVPHelperServer_MainFrame:Hide();
		PVPHelperServer_Save['Visible'] = false;
	else
		ChatFrame1:AddMessage("Commands are:"); 
		ChatFrame1:AddMessage("'/PVPHelperServer show' Show the clock");
		ChatFrame1:AddMessage("'/PVPHelperServer hide' Hide the clock");
	end
end

function RegisterSlashCommands()
	SlashCmdList["PVPHelperServerCMD"] = PVPHelperServer_Command;
	SLASH_PVPHelperServerCMD1 = "/PVPHelperServer";
	SLASH_PVPHelperServerCMD2 = "/PVPHS";
end
