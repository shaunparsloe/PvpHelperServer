--local filepath = "\\Users\\sparsloe\\Downloads\\ZeroBane\\myprograms\\PVPHelperServer\\"
local filepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelperServer\\"
local libfilepath = "\\Games\\World of Warcraft\\Interface\\AddOns\\PVPHelperLibrary\\"
dofile(libfilepath.."Test_MockWoWFunctions.lua")
dofile(libfilepath.."Message.lua")
dofile(libfilepath.."Utils.lua")
dofile(libfilepath.."Localization.lua")
dofile(filepath.."CCDR.lua")
dofile(filepath.."CCDRList.lua")
dofile(libfilepath.."CCType.lua")
dofile(libfilepath.."CCTypeList.lua")
dofile(filepath.."Foe.lua")
dofile(filepath.."FoeList.lua")
dofile(filepath.."FoeDR.lua")
dofile(filepath.."FoeDRList.lua")
dofile(filepath.."Friend.lua")
dofile(filepath.."FriendList.lua")
dofile(filepath.."FriendCCType.lua")
dofile(filepath.."FriendCCTypeList.lua")
dofile(filepath.."Notification.lua")
dofile(filepath.."NotificationList.lua")
dofile(filepath.."OrderedCCList.lua")	
dofile(filepath.."UI.lua")	
dofile(filepath.."SlashCommands.lua")

dofile(filepath.."PvPHelperServer.lua")

--CCDR
function TEST_CCDR()
  --objCCDR = CCDR.new()
  objCCDR = CCDR.new("Freeze", "CR");
  TESTAssert("Freeze", objCCDR.CCName, "objCCDR.CCName")
  TESTAssert("CR", objCCDR.DRType, "objCCDR.DRType")
end
--CCDRList
function TEST_CCDRLIST()
  local objLookup
  local objList=CCDRList.new();
  objList:Add(CCDR.new("Freeze", "CR"));
  objList:Add(CCDR.new("Kidney Shot", "CS"));
  objList:Add(CCDR.new("Gouge", "DO"));
  
  TESTAssert("Freeze", objList[1].CCName, "objList[1].CCName")
  TESTAssert("CR", objList[1].DRType, "objList[1].DRType")
  
  objLookup = objList:LookupCCName("Kidney Shot")
  TESTAssert("Kidney Shot", objLookup.CCName, "1.objLookup.CCName")
  TESTAssert("CS", objLookup.DRType, "1.objLookup.DRType")
  
  --objList = nil;
  objList = objList:LoadAllDRSpells();
  
  objLookup = objList:LookupCCName("Silencing Shot")
  TESTAssert("Silencing Shot", objLookup.CCName, "2.objLookup.CCName")
  TESTAssert("S", objLookup.DRType, "2.objLookup.DRType")
end

--CCType
function TEST_CCTYPE()
  local objcctype =  CCType.new({SpellId=5246, Class="WARRIOR", CCType="CC", CCName="Intimidating Shout", DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=4, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=-3149})

  TESTAssert("CC", objcctype.CCType, "CCTYPE")
  TESTAssert(5246, objcctype.SpellId, "SpellId")
  TESTAssert("WARRIOR", objcctype.Class, "Class")
  TESTAssert("Intimidating Shout", objcctype.CCName, "CCName")
  TESTAssert("F", objcctype.DRType, "DRType")
  TESTAssert(8, objcctype.Duration, "Duration")
  TESTAssert(false, objcctype.IsCore, "IsCore")
  TESTAssert(0, objcctype.CastTime, "CastTime")
  TESTAssert(4, objcctype.Cooldown, "Cooldown")
  TESTAssert(true, objcctype.Targeted, "Targeted")
  TESTAssert(false, objcctype.Ranged, "Ranged")
  TESTAssert(false, objcctype.RequiresStealth, "RequiresStealth")
  TESTAssert(false, objcctype.IsChannelled, "IsChannelled")
  TESTAssert(-3149, objcctype.Weighting, "Weighting")

  TESTAssert(true, objcctype:IsAvailable(), "IsAvailable")
  TESTAssert(0, objcctype:CooldownExpires(), "CooldownExpires")

  --Casting spell - this should set cooldown to the same as object.cooldown 
  --and IsAvailable to false until cooldown ends
    objcctype:CastSpell()
  TESTAssert(false, objcctype:IsAvailable(), "IsAvailable")
  TESTAssert(4, math.round(objcctype:CooldownExpires()), "CooldownExpires")
  
  
  -- Sleep for 3 seconds
  -- NOTE: Should not access _CooldownExpires directly! Only for Testing  
  objcctype._CooldownExpires = objcctype._CooldownExpires - 3;
    
  -- After 3 seconds, the CoolownExpires should now be 1 seconds
  TESTAssert(1, math.round(objcctype:CooldownExpires()), "CooldownExpires")
  
  
  -- Sleep for 3 seconds
  -- NOTE: Should not access _CooldownExpires directly! Only for Testing  
  objcctype._CooldownExpires = objcctype._CooldownExpires - 3;
  
  -- _CooldownExpires is now -2 seconds.  IsAvailable should be true
  -- and CooldownExpires should return 0
  TESTAssert(true, objcctype:IsAvailable(), "IsAvailable")
  TESTAssert(0, objcctype:CooldownExpires(), "CooldownExpires")
    

end

--CCTypeList
function TEST_CCTYPELIST()
  local objList = TEST_CreateTestCCTypesList()

  -- Assert that 1st object in the list is correct
  TESTAssert(5246, objList[1].SpellId, "objlist[1].SpellId")

  -- Assert that the ListSpellIds function returns the expected result
  TESTAssert("5246,64044,2094", objList:ListSpellIds(), "objList:ListSpellIds()")

  -- Test that the LoadAllCCTypes function works
  objList = nil;
  objList = CCTypeList.new();
  objList = objList:LoadAllCCTypes()
  
  --Test for Lookup on SpellID
  local cctype = objList:LookupSpellId(6789);
  -- Assert that we have found the correct spell
  TESTAssert(6789, cctype.SpellId, "cctype.SpellId")
  TESTAssert("Mortal Coil (talent)", cctype.CCName, "cctype.CCName")

end
function TEST_CreateTestCCTypesList()
  local objList = CCTypeList.new();

  -- Test that the List loads
  objList:Add(CCType.new({SpellId=5246, Class="WARRIOR", CCType="CC", CCName="Intimidating Shout", DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=90, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=-3149}))
  objList:Add(CCType.new({SpellId=64044, Class="PRIEST", CCType="CC", CCName="Psychic Horror", DRType="H", Duration=1, IsCore=false, CastTime=0, Cooldown=45, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=6378}))
  objList:Add(CCType.new({SpellId=2094, Class="ROGUE", CCType="CC", CCName="Blind", DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=60, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=-1815}))
  return objList;
end
--FoeDR
function TEST_FOEDR()

  objFoeDR = FoeDR.new("SILENCE")
  local level = objFoeDR:DRLevel();
  
  -- A new DR should have no DR level or Expiry
  TESTAssert(0, objFoeDR:DRLevel());
  TESTAssert(0, math.round(objFoeDR:DRExpires()));
  
  objFoeDR:ApplyDR(3)
  -- When you Add a DR, then the DR level should go up by 1
  -- and the expiry should be set to 18 seconds
  TESTAssert(1, objFoeDR:DRLevel(), "Added DR. DRLevel");
  TESTAssert(21, math.round(objFoeDR:DRExpires()), "Expires with 3sec DR");

  -- Wait 2 seconds
  -- NOTE: Accessing _Expires directly is bad practise!  Only for testing!
  objFoeDR._Expires = objFoeDR._Expires - 2;
  
  -- After 2 seconds, the DRLevel should still be 1
  -- but the Expiry should be down to 16 seconds
  TESTAssert(1, objFoeDR:DRLevel(), "2.DRLevel");
  TESTAssert(19, math.round(objFoeDR:DRExpires()), "Expires after 2 sec");
  
  objFoeDR:ResetDR();
  -- When we remove the Aura, we shoudl reset the DR
  -- The DRLevel should stay at 1, and the time reset to 18seconds
  TESTAssert(1, objFoeDR:DRLevel(), "RESET DR. DRLevel");
  TESTAssert(18, math.round(objFoeDR:DRExpires()), "Expires - reset");
  
  -- Wait 10 seconds
  -- NOTE: Accessing _Expires directly is bad practise!  Only for testing!
  objFoeDR._Expires = objFoeDR._Expires - 10;
  
  -- After 10 seconds, the DRLevel should still be 1
  -- but the Expiry should be down to 8 seconds
  TESTAssert(1, objFoeDR:DRLevel(), "3.DR. DRLevel");
  TESTAssert(8, math.round(objFoeDR:DRExpires()), "Expires after 10sec");
  
  objFoeDR:ApplyDR(3)
  -- When you Add another DR, then the DR level should go up by 1
  -- The DRLevel should now be 2
  -- and the expiry should be set to 18 seconds
  TESTAssert(2, objFoeDR:DRLevel(), "Added DR. DRLevel");
  TESTAssert(21, math.round(objFoeDR:DRExpires()), "Expires with new DR");


end
--FoeDRList
function TEST_FOEDRLIST()
  objFoeDRList = FoeDRList.new()
  objFoeDR1 = FoeDR.new("A")
  objFoeDR2 = FoeDR.new("B")
  objFoeDR3 = FoeDR.new("C")
  
  objFoeDRList:Add(objFoeDR1)
  objFoeDRList:Add(objFoeDR2)
  objFoeDRList:Add(objFoeDR3)
  
  TESTAssert("A", objFoeDRList[1].DRType, "objFoeDRList[1].DRType")
  TESTAssert(0, objFoeDRList[1]:DRLevel(), "objFoeDRList[1]:DRLevel()");
  TESTAssert(0, math.round(objFoeDRList[1]:DRExpires()), "objFoeDRList[1]:DRExpires()");
  TESTAssert("B", objFoeDRList[2].DRType, "objFoeDRList[2].DRType")
  TESTAssert("C", objFoeDRList[3].DRType, "objFoeDRList[3].DRType")
  
  --objFoeDRList:ListDRs();
  
  objDR = objFoeDRList:LookupDRType("X")
  TESTAssert(nil, objDR, "Lookup Invalid DRType")
  
  objDR = objFoeDRList:LookupDRType("A")
  TESTAssert("A", objDR.DRType, "Lookup DRType 'A'")
  
  objDR = objFoeDRList:LookupDRType("B")
  TESTAssert("B", objDR.DRType, "Lookup DRType 'B'")
  
  objDR = objFoeDRList:LookupDRType("C")
  TESTAssert("C", objDR.DRType, "Lookup DRType 'C'")

end  
--Foe
function TEST_FOE()
  objFoe = Foe.new({GUID="GUID1234", Name="Karen", Class="WARLOCK"})
  TESTAssert("GUID1234", objFoe.GUID, "objFoe.GUID")
  TESTAssert("Karen", objFoe.Name, "objFoe.Name")
  TESTAssert("WARLOCK", objFoe.Class, "objFoe.Class")
  -- Shouldn't be any DR's
  objDR = objFoe.DRList:LookupDRType("A")
  TESTAssert(nil, objDR, "objDR shouldn't exist yet")
  
  
  -- Build DRList
  -- When the CC is applied, then DRType must go up and Time should start ticking
  local ccdrtype = GVAR.AllCCTypes:LookupSpellId(107570)
  
  objCCType = ccdrtype;
  objFoe:CCAuraApplied(objCCType)
  TESTAssert("CS", objFoe.DRList[1].DRType, "1.objFoeDRList[1].DRType")
  TESTAssert(1, objFoe.DRList[1]:DRLevel(), "1.objFoeDRList[1]:DRLevel()");
  TESTAssert(22, math.round(objFoe.DRList[1]:DRExpires()), "1.objFoeDRList[1]:DRExpires()");

  -- For our testing, pretend 13 seconds have passed, so Expires should now be 5sec
  objFoe.DRList[1]._Expires = GetTime() + 5 -- NOTE: we are accessing _Expires directly - not best practise! Only for tests!
  TESTAssert(5, math.round(objFoe.DRList[1]:DRExpires()), "1.objFoeDRList[1]:DRExpires()");

  -- When cc is applied again, the Expiry time should be reset to 18 and DRLevel should be 2 now
  objFoe:CCAuraApplied(objCCType)
  TESTAssert("CS", objFoe.DRList[1].DRType, "2.objFoeDRList[1].DRType")
  TESTAssert(2, objFoe.DRList[1]:DRLevel(), "2.objFoeDRList[1]:DRLevel()");
  TESTAssert(22, math.round(objFoe.DRList[1]:DRExpires()), "2.objFoeDRList[1]:DRExpires()");
  
    -- For our testing, pretend 13 seconds have passed, so Expires should now be 5sec
  objFoe.DRList[1]._Expires = GetTime() + 5 -- NOTE: we are accessing _Expires directly - not best practise! Only for tests!
  TESTAssert(5, math.round(objFoe.DRList[1]:DRExpires()), "1.objFoeDRList[1]:DRExpires()");

-- Now we see that the CC is removed from the Foe, this should reset the DR timer to 18sec.
-- THe DRLevel should not change
  objFoe:CCAuraRemoved(objCCType)
  TESTAssert("CS", objFoe.DRList[1].DRType, "3.objFoeDRList[1].DRType")
  TESTAssert(2, objFoe.DRList[1]:DRLevel(), "3.objFoeDRList[1]:DRLevel()");
  TESTAssert(18, math.round(objFoe.DRList[1]:DRExpires()), "3.objFoeDRList[1]:DRExpires()");


    -- For our testing, pretend 20 seconds have passed, so Expires should now be -2sec in the past
  objFoe.DRList[1]._Expires = GetTime() - 2 -- NOTE: we are accessing _Expires directly - not best practise! Only for tests!
  -- Once the time has elapsed, we should see the DRLevel drop to 0 
  -- and the Expires time set to 0
  TESTAssert(0, objFoe.DRList[1]:DRLevel(), "4.objFoeDRList[1]:DRLevel()");
  TESTAssert(0, math.round(objFoe.DRList[1]:DRExpires()), "4.objFoeDRList[1]:DRExpires()");

end






--FoeList
function TEST_FOELIST()
  objFoeList = FoeList.new()

  -- Test that we can Add foes to the list
  objFoeList:Add(Foe.new({GUID="GUID1", Name="APersonName", Class="ROGUE"}))
  objFoeList:Add(Foe.new({GUID="GUID2", Name="BPersonName", Class="PRIEST"}))
  objFoeList:Add(Foe.new({GUID="GUID3", Name="CPersonName", Class="WARLOCK"}))
  
  -- Asser that Foe1 has loaded correctly
  TESTAssert("GUID1", objFoeList[1].GUID, "objFoeList[1].GUID")
  TESTAssert("APersonName", objFoeList[1].Name, "objFoeList[1].Name");
  TESTAssert("ROGUE", objFoeList[1].Class, "objFoeList[1].Class");
  -- Assert that the other 2 have loaded too
  TESTAssert("GUID2", objFoeList[2].GUID, "objFoeList[2].GUID")
  TESTAssert("GUID3", objFoeList[3].GUID, "objFoeList[3].GUID")
  
  -- Lookup an invalid GUID shoudl return nil
  objDR = objFoeList:LookupGUID("X")
  TESTAssert(nil, objDR, "Lookup Invalid DRType")
  
  -- Loolkup a Valid Guid should return the correct foe
  objFoe = objFoeList:LookupGUID("GUID2")
  -- Assert that we have the correct foe returned
  TESTAssert("GUID2", objFoe.GUID, "Lookup GUID.GUID")
  TESTAssert("BPersonName", objFoe.Name, "Lookup GUID.Name")
  TESTAssert("PRIEST", objFoe.Class, "Lookup GUID.Class")
  
end 


--FriendCCType
function TEST_FRIENDCCTYPE()
  local objFriendCCType = FriendCCType.new({CCType="CC", SpellId=5246, DRType="F", Weighting=-3149,FriendGUID = "TESTGUID",FriendName = "TestName"})
  TESTAssert("CC", objFriendCCType.CCType, "objFriendCCType.CCType")
  TESTAssert(5246, objFriendCCType.SpellId, "objFriendCCType.SpellId")
  TESTAssert("F", objFriendCCType.DRType, "objFriendCCType.DRType")
  TESTAssert(-3149, objFriendCCType.Weighting, "objFriendCCType.Weighting")
  TESTAssert("TESTGUID", objFriendCCType.FriendGUID, "objFriendCCType.FriendGUID")
  TESTAssert("TestName", objFriendCCType.FriendName, "objFriendCCType.FriendName")

end

--FriendCCTypeList
function TEST_FRIENDCCTYPELIST()
  --Arrange
    local objFriendCCType1 = FriendCCType.new({CCType="CC", SpellId=1234, DRType="F", Weighting=1000,FriendGUID = "FRIEND001",FriendName = "FirstFriend"})
  local objFriendCCType2 = FriendCCType.new({CCType="CC", SpellId=4567, DRType="F", Weighting=1000,FriendGUID = "FRIEND002",FriendName = "SecondFriend"})
  local objFriendCCType3 = FriendCCType.new({CCType="CC", SpellId=7890, DRType="S", Weighting=900,FriendGUID = "FRIEND001",FriendName = "FirstFriend"})

  -- Act
  local objFriendCCTypeList = FriendCCTypeList.new()
  
  objFriendCCTypeList:Add(objFriendCCType1)
  objFriendCCTypeList:Add(objFriendCCType2)
  objFriendCCTypeList:Add(objFriendCCType3)
  
  -- Assert
  TESTAssert(1234, objFriendCCTypeList[1].SpellId, "objFriendCCTypeList[1].SpellId")
  TESTAssert("FRIEND001", objFriendCCTypeList[1].FriendGUID, "objFriendCCTypeList[1].FriendGUID")
  TESTAssert(4567, objFriendCCTypeList[2].SpellId, "objFriendCCTypeList[2].SpellId")
  TESTAssert("FRIEND002", objFriendCCTypeList[2].FriendGUID, "objFriendCCTypeList[2].FriendGUID")
  TESTAssert(7890, objFriendCCTypeList[3].SpellId, "objFriendCCTypeList[3].SpellId")
  TESTAssert("FRIEND001", objFriendCCTypeList[3].FriendGUID, "objFriendCCTypeList[3].FriendGUID")
  
  
end

--Friend
function TEST_FRIEND()
  
  local objCCTypesList = TEST_CreateTestCCTypesList()


  -- Test that the FriendNew function works
  objFriend = Friend.new({GUID="GUID123", Name="MrFriendly", CCTypes=objCCTypesList})
  --Assert that the values have all been loaded
  TESTAssert("GUID123", objFriend.GUID, "GUID")
  TESTAssert("MrFriendly", objFriend.Name, "Name")
  TESTAssert(5246, objFriend.CCTypes[1].SpellId, "objFriend.CCTypes[1].SpellId")
  TESTAssert(true, objFriend.CC_InRange, "objFriend.CC_InRange")
  
end


function TEST_CreateTestFriendList()
  
  local L = PVPHelperLib_LocalizationTable;

  -- Get the list of CCTypes
  objPriestCCTypesList = CCTypeList.new();
  objPriestCCTypesList:Add(CCType.new({SpellId=605, Class=L["PRIEST"], CCType="CC", CCName=L["Dominate Mind"], DRType="dommind", Duration=6, IsCore=true, CastTime=1.8, Cooldown=0, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=true, Weighting=22120}))
  objPriestCCTypesList:Add(CCType.new({SpellId=8122, Class=L["PRIEST"], CCType="CC", CCName=L["Psychic Scream, Psychic Terror (Psyfiend fear, talent)"], DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=30, Targeted=false, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=8185}))
  objPriestCCTypesList:Add(CCType.new({SpellId=15487, Class=L["PRIEST"], CCType="CC", CCName=L["Silence (Shadow)"], DRType="S", Duration=5, IsCore=false, CastTime=0, Cooldown=45, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=6458}))
  objPriestCCTypesList:Add(CCType.new({SpellId=64044, Class=L["PRIEST"], CCType="CC", CCName=L["Psychic Horror"], DRType="H", Duration=1, IsCore=false, CastTime=0, Cooldown=45, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=6378}))



  objRogueCCTypesList = CCTypeList.new();
  objRogueCCTypesList:Add(CCType.new({SpellId=1776, Class=L["ROGUE"], CCType="CC", CCName=L["Gouge"], DRType="DO", Duration=4, IsCore=false, CastTime=0, Cooldown=10, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=6105}))
  objRogueCCTypesList:Add(CCType.new({SpellId=2094, Class=L["ROGUE"], CCType="CC", CCName=L["Blind"], DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=60, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=-1815}))  
  
  
  
  objWarriorCCTypesList = CCTypeList.new();
  objWarriorCCTypesList:Add(CCType.new({SpellId=107570, Class=L["WARRIOR"], CCType="CC", CCName=L["Storm Bolt (talent)"], DRType="CS", Duration=4, IsCore=false, CastTime=0, Cooldown=30, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=9105}))
  objWarriorCCTypesList:Add(CCType.new({SpellId=100, Class=L["WARRIOR"], CCType="CC", CCName=L["Charge"], DRType="CS", Duration=4, IsCore=false, CastTime=0, Cooldown=40, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=7105}))
  objWarriorCCTypesList:Add(CCType.new({SpellId=46968, Class=L["WARRIOR"], CCType="CC", CCName=L["Shockwave"], DRType="CS", Duration=4, IsCore=false, CastTime=0, Cooldown=40, Targeted=true, Ranged=true, RequiresStealth=false, IsChannelled=false, Weighting=7105}))
  objWarriorCCTypesList:Add(CCType.new({SpellId=5246, Class=L["WARRIOR"], CCType="CC", CCName=L["Intimidating Shout"], DRType="F", Duration=8, IsCore=false, CastTime=0, Cooldown=90, Targeted=true, Ranged=false, RequiresStealth=false, IsChannelled=false, Weighting=-3149}))
  
  
  local objFriend1 = Friend.new({GUID="PRIEST123", Name="FriendlyPriest", CCTypes=objPriestCCTypesList})
  local objFriend2 = Friend.new({GUID="ROGUE123", Name="FriendlyRogue", CCTypes=objRogueCCTypesList})
  local objFriend3 = Friend.new({GUID="WARR123", Name="FriendlyWarrior", CCTypes=objWarriorCCTypesList})


  -- Test that we can create a friends list
  local objFriendList = FriendList.new();
  -- Test that we can add friends to the list
  objFriendList:Add(objFriend1);
  objFriendList:Add(objFriend2);  
  objFriendList:Add(objFriend3);

  return objFriendList;
end

function TEST_FRIENDLIST()

  local objFriendList = TEST_CreateTestFriendList()
  -- Assert that the valuss are loaded correctly
  TESTAssert("PRIEST123", objFriendList[1].GUID, "1.objFriendList[1].GUID")
  TESTAssert("FriendlyPriest", objFriendList[1].Name, "1.objFriendList[1].Name")
  TESTAssert(605, objFriendList[1].CCTypes[1].SpellId, "1.objFriendList[1].CCTypes[1].SpellId")
  TESTAssert("ROGUE123", objFriendList[2].GUID, "1.objFriendList[2].GUID")
  TESTAssert("WARR123", objFriendList[3].GUID, "1.objFriendList[3].GUID")
  
  --Check that the _BuildAllCCTypesList function worked correctly
  local objFriendCCTypesList = objFriendList.FriendCCTypesList
  TESTAssert(605, objFriendCCTypesList[1].SpellId, "objFriendCCTypesList[1].SpellId")
  TESTAssert(107570, objFriendCCTypesList[2].SpellId, "objFriendCCTypesList[2].SpellId")
  TESTAssert(8122, objFriendCCTypesList[3].SpellId, "objFriendCCTypesList[3].SpellId")
  TESTAssert(46968, objFriendCCTypesList[4].SpellId, "objFriendCCTypesList[4].SpellId")
  TESTAssert(100, objFriendCCTypesList[5].SpellId, "objFriendCCTypesList[5].SpellId")
  TESTAssert(15487, objFriendCCTypesList[6].SpellId, "objFriendCCTypesList[6].SpellId")
  TESTAssert(64044, objFriendCCTypesList[7].SpellId, "objFriendCCTypesList[7].SpellId")
  TESTAssert(1776, objFriendCCTypesList[8].SpellId, "objFriendCCTypesList[8].SpellId")
  TESTAssert(2094, objFriendCCTypesList[9].SpellId, "objFriendCCTypesList[9].SpellId")
  TESTAssert(5246, objFriendCCTypesList[10].SpellId, "objFriendCCTypesList[10].SpellId")
  
  --for i, v in ipairs(objFriendCCTypesList) do
  --  print(i..") id="..v.SpellId..", Weighting="..v.Weighting..", Class="..v.FriendName)
  --end
  
  -- Test that we can lookup GUIDs
  local objFoundFriend = objFriendList:LookupName("FriendlyPriest");
  -- Assert that we have the correct person
  TESTAssert("PRIEST123", objFoundFriend.GUID, "2.objFoundFriend - search by Name")
  
  -- Test that we can lookup GUIDs
  objFoundFriend = objFriendList:LookupGUID("ROGUE123");
  -- Assert that we have the correct person
  TESTAssert("FriendlyRogue", objFoundFriend.Name, "2.objFoundFriend Search by GUID")
  
  -- Test that we can delete a friend from the friend list
  objFriendList:Delete(objFoundFriend)
  
  -- Look for him again
  objFoundFriend = objFriendList:LookupGUID("ROGUE123");
  -- Assert that we can't find him!
  TESTAssert(nil, objFoundFriend, "3. Deleted objFoundFriend")
 
 
  --Check that the _BuildAllCCTypesList function worked correctly
  -- and now does not show the Rogue spells (1776 and 2094)
  objFriendCCTypesList = nil;
  objFriendCCTypesList = objFriendList.FriendCCTypesList
  TESTAssert(605, objFriendCCTypesList[1].SpellId, "2.objFriendCCTypesList[1].SpellId")
  TESTAssert(107570, objFriendCCTypesList[2].SpellId, "2.objFriendCCTypesList[2].SpellId")
  TESTAssert(8122, objFriendCCTypesList[3].SpellId, "2.objFriendCCTypesList[3].SpellId")
  TESTAssert(46968, objFriendCCTypesList[4].SpellId, "2.objFriendCCTypesList[4].SpellId")
  TESTAssert(100, objFriendCCTypesList[5].SpellId, "2.objFriendCCTypesList[5].SpellId")
  TESTAssert(15487, objFriendCCTypesList[6].SpellId, "2.objFriendCCTypesList[6].SpellId")
  TESTAssert(64044, objFriendCCTypesList[7].SpellId, "2.objFriendCCTypesList[7].SpellId")
  TESTAssert(5246, objFriendCCTypesList[8].SpellId, "2.objFriendCCTypesList[8].SpellId")
  

end

function TEST_AURA_APPLIED()
    --Test what happens when we get notice that a friend has applied a spell
  local sourceGUID = "WARR123"
  local sourceSpellId = 107570 -- Storm Bolt
  local destGUID = "FOEGUID2"
  
--ARRANGE  
  local objFriendList = TEST_CreateTestFriendList()
  
  --Check that the _BuildAllCCTypesList function worked correctly
  -- Spells in order should be 
  --1). Dominate Mind, 2). Storm Bolt, 3). Psychic Scream
  local objFriendCCTypesList = objFriendList.FriendCCTypesList
  TESTAssert(605, objFriendCCTypesList[1].SpellId, "objFriendCCTypesList[1].SpellId")
  TESTAssert("PRIEST123", objFriendCCTypesList[1].FriendGUID, "objFriendCCTypesList[1].FriendGUID")
  
  TESTAssert(107570, objFriendCCTypesList[2].SpellId, "objFriendCCTypesList[2].SpellId")
  TESTAssert("WARR123", objFriendCCTypesList[2].FriendGUID, "objFriendCCTypesList[2].FriendGUID")

  TESTAssert(8122, objFriendCCTypesList[3].SpellId, "objFriendCCTypesList[3].SpellId")
  TESTAssert("PRIEST123", objFriendCCTypesList[3].FriendGUID, "objFriendCCTypesList[3].FriendGUID")
  
  
  -- build the foe list
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID1", Name="BadPersonA", Class="MAGE"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID2", Name="BadPersonB", Class="SHAMAN"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID3", Name="BadPersonC", Class="WARLOCK"}))


  local objFoundFriend = objFriendList:LookupGUID(sourceGUID);
  -- Assert that we have the correct friend
  TESTAssert("FriendlyWarrior", objFoundFriend.Name, "2.objFoundFriend.Name")
  -- Lookup those items
  local objSpell = objFoundFriend.CCTypes:LookupSpellId(sourceSpellId);
  local objFoundFoe = objFoeList:LookupGUID(destGUID);

  -- Assert that we have the correct spell
  TESTAssert(107570, objSpell.SpellId, "objSpell.SpellId")
  TESTAssert("Storm Bolt (talent)", objSpell.CCName, "objSpell.CCName")
  TESTAssert("CS", objSpell.DRType, "objSpell.DRType")
  
  -- Assert first that this spell should not be on cooldown
  TESTAssert(true, objSpell:IsAvailable(), "IsAvailable")
  TESTAssert(0, math.round(objSpell:CooldownExpires()), "CooldownExpires")
  
  -- Assert that we have the correct Foe
  TESTAssert("BadPersonB", objFoundFoe.Name, "3.objFoundFoe.Name")
  
  -- There should be no DR on the Foe at this time
  TESTAssert(nil, objFoundFoe.DRList:LookupDRType(objSpell.DRType), "3.LookupDRType")
  
--ACT 
--local pvpHelperServer = PvPHelperServer.new();
    
  local objPvPHelperServer = PvPHelperServer.new()
  objPvPHelperServer.FriendList = objFriendList
  objPvPHelperServer.FoeList = objFoeList


  objPvPHelperServer:Apply_Aura(sourceGUID, sourceSpellId, destGUID);

 
--ASSERT  
  -- Assert that after the aura is applied, the spell must not be available, and that the cooldown should expire in 30 sec (Storm bolt has 30sec cooldown)
  TESTAssert(false, objSpell:IsAvailable(), "IsAvailable")
  TESTAssert(30, objSpell:CooldownExpires(), "CooldownExpires")
--ASSERT  
  -- Now there should be a DR on that Foe
  local founddrtype = objFoundFoe.DRList:LookupDRType(objSpell.DRType);
  TESTAssert("CS", founddrtype.DRType, "4.LookupDRType.DRType")
  TESTAssert(1, founddrtype:DRLevel(), "4.LookupDRType.DRLevel")
  TESTAssert(18+objSpell.Duration, math.round(founddrtype:DRExpires()), "4.LookupDRType.DRExpires")
  
  
end


function TEST_AURA_REMOVED()
  --Test what happens when we get notice that an aura has been removed
  local sourceGUID = "WARR123"
  local sourceSpellId = 107570 -- Storm Bolt
  local destAuraName = "Storm Bolt"
  local destGUID = "FOEGUID2"
  
--ARRANGE  
  local objFriendList = TEST_CreateTestFriendList()
  
  -- build the foe list
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID1", Name="BadPersonA", Class="MAGE"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID2", Name="BadPersonB", Class="SHAMAN"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID3", Name="BadPersonC", Class="WARLOCK"}))


  local objFoundFriend = objFriendList:LookupGUID(sourceGUID);
  local objSpell = objFoundFriend.CCTypes:LookupSpellId(sourceSpellId);
  local objFoundFoe = objFoeList:LookupGUID(destGUID);
 
    
  local objPvPHelperServer = PvPHelperServer.new()
  objPvPHelperServer.FriendList = objFriendList
  objPvPHelperServer.FoeList = objFoeList

  -- First apply the aura 
  -- This should set Cooldowns on the spell and a DR on the foe
  objPvPHelperServer:Apply_Aura(sourceGUID, sourceSpellId, destGUID);

  -- Check that the start position is correct
  -- Assert that after the aura is applied, the spell must not be available, and that the cooldown should expire in 30 sec (Storm bolt has 30sec cooldown)
  TESTAssert(false, objSpell:IsAvailable(), "IsAvailable")
  TESTAssert(30, objSpell:CooldownExpires(), "CooldownExpires")
--ASSERT  
  -- Now there should be a DR on that Foe
  local founddrtype = objFoundFoe.DRList:LookupDRType(objSpell.DRType);
  TESTAssert("CS", founddrtype.DRType, "1.LookupDRType.DRType")
  TESTAssert(1, founddrtype:DRLevel(), "1.LookupDRType.DRLevel")
  TESTAssert(22, math.round(founddrtype:DRExpires()), "1.LookupDRType.DRExpires")
  
  
  -- Wait 5 seconds
  -- NOTE: Accessing _Expires directly is bad practise!  Only for testing!
  founddrtype._Expires = objFoeDR._Expires - 5;
  TESTAssert("CS", founddrtype.DRType, "1.LookupDRType.DRType")
  TESTAssert(16, math.round(founddrtype:DRExpires()), "2.LookupDRType.DRExpires")

  local objAllCCDRList = CCDRList.new()
  objAllCCDRList = objAllCCDRList:LoadAllDRSpells();
  TESTAssert("Freeze", objAllCCDRList[1].CCName, "objAllCCDRList LoadAll")
  local drtype = objAllCCDRList:LookupCCName("Storm Bolt");
  TESTAssert("Storm Bolt", drtype.CCName, "DRType lookup Freeze")
  drtype = objAllCCDRList:LookupCCName(destAuraName);
  TESTAssert(destAuraName, drtype.CCName, "DRType lookup destAuraName")

  
  objPvPHelperServer:Remove_Aura(destGUID, sourceSpellId);
  -- The DR 
  -- The Expiry should have now reset to 18 seconds
  TESTAssert("CS", founddrtype.DRType, "1.LookupDRType.DRType")
  TESTAssert(1, founddrtype:DRLevel(), "3.LookupDRType.DRLevel")
  TESTAssert(18, math.round(founddrtype:DRExpires()), "3.LookupDRType.Expires")
  

end

function TEST_BuildPvPHelperServer()
--ARRANGE  
  local objFriendList = TEST_CreateTestFriendList()
  
  -- build the foe list
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID1", Name="BadPersonA", Class="MAGE"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID2", Name="BadPersonB", Class="SHAMAN"}))
  objFoeList:Add(Foe.new({GUID="FOEGUID3", Name="BadPersonC", Class="WARLOCK"}))
  
  TESTAssert(605, objFriendList.FriendCCTypesList[1].SpellId, "objFriendCCTypesList[1].SpellId")
  TESTAssert(107570, objFriendList.FriendCCTypesList[2].SpellId, "objFriendCCTypesList[2].SpellId")
  TESTAssert(8122, objFriendList.FriendCCTypesList[3].SpellId, "objFriendCCTypesList[3].SpellId")
  TESTAssert(46968, objFriendList.FriendCCTypesList[4].SpellId, "objFriendCCTypesList[4].SpellId")
  TESTAssert(100, objFriendList.FriendCCTypesList[5].SpellId, "objFriendCCTypesList[5].SpellId")
  TESTAssert(15487, objFriendList.FriendCCTypesList[6].SpellId, "objFriendCCTypesList[6].SpellId")
  TESTAssert(64044, objFriendList.FriendCCTypesList[7].SpellId, "objFriendCCTypesList[7].SpellId")
  TESTAssert(1776, objFriendList.FriendCCTypesList[8].SpellId, "objFriendCCTypesList[8].SpellId")
  TESTAssert(2094, objFriendList.FriendCCTypesList[9].SpellId, "objFriendCCTypesList[9].SpellId")
  TESTAssert(5246, objFriendList.FriendCCTypesList[10].SpellId, "objFriendCCTypesList[10].SpellId")
--	605	Priest Dominate Mind	0
--	107570	Warrior Storm Bolt (talent)	30
--	8122	Priest Psychic Scream, Psychic Terror (Psyfiend fear, talent)	30
--	46968	Warrior Combo Charge+Shockwave	40
--	100	Warrior Combo Charge+Shockwave	40
--	15487	Priest Silence (Shadow)	45
--	64044	Priest Psychic Horror	45
--	1776	Rogue Gouge, Sap	10
--	2094	Rogue Blind	60
--	5246	Warrior Intimidating Shout	90

  
  local objPvPHelperServer = PvPHelperServer.new()
  objPvPHelperServer.FriendList = objFriendList
  objPvPHelperServer.FoeList = objFoeList
  return objPvPHelperServer;
end

function TEST_GETNEXTSPELL_STANDARD()
  
--	605	dommind	Priest Dominate Mind	0
--	107570	CS	Warrior Storm Bolt (talent)	30
--	8122	F	Priest Psychic Scream, Psychic Terror (Psyfiend fear, talent)	30
--	46968	CS	Warrior Combo Charge+Shockwave	40
--	100	CS	Warrior Combo Charge+Shockwave	40
--	15487	S	Priest Silence (Shadow)	45
--	64044	H	Priest Psychic Horror	45
--	1776	DO	Rogue Gouge, Sap	10
--	2094	F	Rogue Blind	60
--	5246	F	Warrior Intimidating Shout	90

  local CCGUID1 = "FOEGUID2";
  local objPvPHelperServer = TEST_BuildPvPHelperServer();
  local nextSpell;
 
--	605	dommind	Priest Dominate Mind	0
  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(605, nextSpell.SpellId, "1.NextSpell SpellId")
  TESTAssert("PRIEST123", nextSpell.FriendGUID, "1.NextSpell FriendGUID")  
  TESTAssert(107570, followingSpell.SpellId, "1.followingSpell SpellId")
  TESTAssert("WARR123", followingSpell.FriendGUID, "1.followingSpell FriendGUID")  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  objPvPHelperServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);
  
--	107570	CS	Warrior Storm Bolt (talent)	30
  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(107570, nextSpell.SpellId, "2.NextSpell SpellId")
  TESTAssert("WARR123", nextSpell.FriendGUID, "2.NextSpell FriendGUID")  
  TESTAssert(8122, followingSpell.SpellId, "2.followingSpell SpellId")
  TESTAssert("PRIEST123", followingSpell.FriendGUID, "2.followingSpell FriendGUID")  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  objPvPHelperServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);
  
--	8122	F	Priest Psychic Scream, Psychic Terror (Psyfiend fear, talent)	30
  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(8122, nextSpell.SpellId, "3.NextSpell SpellId")
  TESTAssert("PRIEST123", nextSpell.FriendGUID, "3.NextSpell FriendGUID")  
  TESTAssert(15487, followingSpell.SpellId, "3.followingSpell SpellId")
  TESTAssert("PRIEST123", followingSpell.FriendGUID, "3.followingSpell FriendGUID")  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  objPvPHelperServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);
  
  -- The next two should not fire as CS is still on cooldown
  --	46968	CS	Warrior Combo Charge+Shockwave	40
  --	100	CS	Warrior Combo Charge+Shockwave	40
  
--	15487	S	Priest Silence (Shadow)	45
  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(15487, nextSpell.SpellId, "4.NextSpell SpellId")
  TESTAssert("PRIEST123", nextSpell.FriendGUID, "4.NextSpell FriendGUID")  
  TESTAssert(64044, followingSpell.SpellId, "4.followingSpell SpellId")
  TESTAssert("PRIEST123", followingSpell.FriendGUID, "4.followingSpell FriendGUID")  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  objPvPHelperServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);


  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(64044, nextSpell.SpellId, "5.NextSpell SpellId")
  TESTAssert("PRIEST123", nextSpell.FriendGUID, "5.NextSpell FriendGUID")  
  TESTAssert(1776, followingSpell.SpellId, "5.followingSpell SpellId")
  TESTAssert("ROGUE123", followingSpell.FriendGUID, "5.followingSpell FriendGUID")  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  objPvPHelperServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);


  nextSpell, followingSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(1776, nextSpell.SpellId, "6.NextSpell SpellId")
  TESTAssert("ROGUE123", nextSpell.FriendGUID, "6.NextSpell FriendGUID")  
  TESTAssert("nil", tostring(followingSpell), "6.no further followingSpell")



--  PvPH_Server:NextCCSpell(CCGUID1);

end

function TEST_GETNEXTSPELL_CHECKS()
  
--	605	dommind	Priest Dominate Mind	0
--	107570	CS	Warrior Storm Bolt (talent)	30
--	8122	F	Priest Psychic Scream, Psychic Terror (Psyfiend fear, talent)	30
--	46968	CS	Warrior Combo Charge+Shockwave	40
--	100	CS	Warrior Combo Charge+Shockwave	40
--	15487	S	Priest Silence (Shadow)	45
--	64044	H	Priest Psychic Horror	45
--	1776	DO	Rogue Gouge, Sap	10
--	2094	F	Rogue Blind	60
--	5246	F	Warrior Intimidating Shout	90

  local CCGUID1 = "FOEGUID2";
  local objPvPHelperServer = TEST_BuildPvPHelperServer();
  local nextSpell;
  
  local objFriend1 = objPvPHelperServer.FriendList:LookupGUID("PRIEST123")
  objFriend1.CC_InRange = false;
  local objFriend2 = objPvPHelperServer.FriendList:LookupGUID("ROGUE123")
  objFriend2.CC_InRange = false;
  local objFriend3 = objPvPHelperServer.FriendList:LookupGUID("WARR123")
  objFriend3.CC_InRange = false;
 
-- RANGE CHECKS 
  -- Nobody is in range, should get no spells
  nextSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(nil, nextSpell, "1.None in range")
  
  -- Bring rogue in range, should have gouge as first spell
  objFriend2.CC_InRange = true;
  nextSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(1776, nextSpell.SpellId, "2.Rogue in range")
  
  -- Bring rogue and warrior in range, should have Storm Bolt as first spell
  objFriend3.CC_InRange = true;
  nextSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(107570, nextSpell.SpellId, "3.Rogue+Warrior in range")
  
-- AVAILABILITY CHECKS
  -- Place Storm bolt  on cooldown
    local objFoundFriend = objPvPHelperServer.FriendList:LookupGUID("WARR123");
    local objSpell = objFoundFriend.CCTypes:LookupSpellId(107570);
    objSpell._IsCooldown = true;
    objSpell._CooldownExpires = GetTime() + 30;
  -- Assert should be charge + shockwave  
  nextSpell = objPvPHelperServer:NextCCSpell(CCGUID1);
  TESTAssert(46968, nextSpell.SpellId, "4.Storm Bolt is not available")


end

function TEST_EVENT_CHATMESSAGE()
  -- Arrange
  objPvPHelperServer = PvPHelperServer.new()
  
    local objFriendList = TEST_CreateTestFriendList()
  
  objPvPHelperServer.FoeList = objFoeList;
  objPvPHelperServer.FriendList = objFriendList;


  objPvPHelperServer.Message.Header = "BLANK";
    PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "CHAT_MSG_ADDON", "PvPHelper", "Testing.Message Body String", "WHISPER", "WARR123")   -- 0030 = Set CC Target
  --Assert 
  TESTAssert("BLANK", objPvPHelperServer.Message.Header, "Must only process PvPHelperServer messages")

  
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "CHAT_MSG_ADDON", "PvPHelperServer", "Testing.Message Body String", "WHISPER", "WARR123")   -- 0030 = Set CC Target
  
  --Assert 
  TESTAssert("Testing", objPvPHelperServer.Message.Header, "MessageReceived - Header")
  TESTAssert("Message Body String", objPvPHelperServer.Message.Body, "MessageReceived - Body")
  TESTAssert("WARR123", objPvPHelperServer.Message.From, "MessageReceived - From")
  
end


function TEST_EVENT_PLAYER_REGEN_DISABLED()
  objPvPHelperServer = PvPHelperServer.new()
  
  objPvPHelperServer.InCombat = false;
  
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "PLAYER_REGEN_DISABLED", "PvPHelper", Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, foeGUID, foeName, destFlags, destRaidFlags, spellId)
  
  TESTAssert(true, objPvPHelperServer.InCombat, "Should be in combat")

end

function TEST_EVENT_PLAYER_REGEN_ENABLED()
  objPvPHelperServer = PvPHelperServer.new()
  
  objPvPHelperServer.InCombat = true;
  
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "PLAYER_REGEN_ENABLED", "PvPHelper", Event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, foeGUID, foeName, destFlags, destRaidFlags, spellId)
  
  TESTAssert(false, objPvPHelperServer.InCombat, "Should not be in combat")

end

function TEST_EVENT_RAID_ROSTER_UPDATE()
  print(debug.getinfo(1).name.."() IS NOT IMPLEMENTED")
end

function TEST_EVENT_SPELL_AURA_REMOVED()
--ARRANGE  
  objPvPHelperServer = PvPHelperServer.new()
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"}))

  local objFriendList = TEST_CreateTestFriendList()
  
  objPvPHelperServer.FoeList = objFoeList;
  objPvPHelperServer.FriendList = objFriendList;
  
-- Event fires that says that Friendly Priest has applied aura "Dominate Mind" on FoeGUID123
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", "PvPHelper", "SPELL_AURA_APPLIED", hideCaster, "PRIEST123", "FriendlyPriest", sourceFlags, sourceRaidFlags, "FOEGUID123", "MrBadFoe1", destFlags, destRaidFlags, 605, "Dominate Mind")   -- 605 = Dominate Mind
  
--ASSERT  
  local objFoe;
  TESTAssert(1, table.maxn(objPvPHelperServer.FoeList), "Should have found 1 foe")  
  objFoe = objPvPHelperServer.FoeList[1];
  TESTAssert(1, table.maxn(objFoe.DRList), "Should have 1 DR on this foe")  
  TESTAssert("dommind", objFoe.DRList[1].DRType, "Type of DR is DomMind - DRType")
  TESTAssert(1, objFoe.DRList[1]:DRLevel(), "Applied once, so DRLevel =1");
  TESTAssert(18+6, math.round(objFoe.DRList[1]:DRExpires()), "New application so Expires in 18sec + Dominate mind duration of 6sec");

-- Event fires that says that Friendly Priest has applied aura "Dominate Mind" on FoeGUID123
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", "PvPHelper", "SPELL_AURA_REMOVED", hideCaster, "PRIEST123", "FriendlyPriest", sourceFlags, sourceRaidFlags, "FOEGUID123", "MrBadFoe1", destFlags, destRaidFlags, 605, "Dominate Mind")   -- 605 = Dominate Mind
  
--ASSERT  
  TESTAssert(1, table.maxn(objPvPHelperServer.FoeList), "Should have found 1 foe")  
  objFoe = objPvPHelperServer.FoeList[1];
  TESTAssert(1, table.maxn(objFoe.DRList), "Should have 1 DR on this foe")  
  TESTAssert("dommind", objFoe.DRList[1].DRType, "Type of DR is DomMind - DRType")
  TESTAssert(1, objFoe.DRList[1]:DRLevel(), "Removed, so no change in Qty of DR");
  TESTAssert(18, math.round(objFoe.DRList[1]:DRExpires()), "Removed so Duration resets to 18");

end

function TEST_EVENT_SPELL_AURA_APPLIED()
  
  -- Set up the PvPServer and populate the team list with standard friend list
  objPvPHelperServer = PvPHelperServer.new()
  
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"}))

  local objFriendList = TEST_CreateTestFriendList()
  
  objPvPHelperServer.FoeList = objFoeList;
  objPvPHelperServer.FriendList = objFriendList;
  
  -- CHeck that we have the one in FoeList initially
  TESTAssert(1, table.maxn(objPvPHelperServer.FoeList), "No foes initially")  

-- ACT
-- Event fires that says that Friendly Priest has applied aura "Dominate Mind" on FoeGUID123
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", "PvPHelper", "SPELL_AURA_APPLIED", hideCaster, "PRIEST123", "FriendlyPriest", sourceFlags, sourceRaidFlags, "FOEGUID123", "MrBadFoe1", destFlags, destRaidFlags, 605)   -- 605 = Dominate Mind
  
--ASSERT  
  TESTAssert(1, table.maxn(objPvPHelperServer.FoeList), "Should have found 1 foe")  
  local objFoe = objPvPHelperServer.FoeList[1];
  TESTAssert(1, table.maxn(objFoe.DRList), "Should have 1 DR on this foe")  
  TESTAssert("dommind", objFoe.DRList[1].DRType, "Type of DR is DomMind - DRType")
  TESTAssert(1, objFoe.DRList[1]:DRLevel(), "Applied once, so DRLevel =1");
  TESTAssert(18+6, math.round(objFoe.DRList[1]:DRExpires()), "New application so Expires in 18sec + DominateMind duration of 6sec");

end

function TEST_MESSAGERECEIVED_PLAYERSPELLS()
  -- Arrange
  objPvPHelperServer = PvPHelperServer.new()
--  local objCCTypeList = CCTypeList.new();
  local objFoeList = FoeList.new()
  local objFriendList = TEST_CreateTestFriendList()

  objPvPHelperServer.FriendList = objFriendList;
  objPvPHelperServer.FoeList = objFoeList;


  TESTAssert("605,107570,8122,46968,100,15487,64044,1776,2094,5246", tostring(objPvPHelperServer.FriendList.FriendCCTypesList:ListSpellIds()), "PvPServer set up with standard spells initially")  

  local objPlayer = objPvPHelperServer.FriendList:LookupGUID("ROGUE123")
  TESTAssert("1776,2094", tostring(objPlayer.CCTypes:ListSpellIds()), "Player set up with standard spells initially")  

  -- Act
  objPvPHelperServer:MessageReceived("PvPHelperServer", "MySpells.1776,2094,113506", "WHISPER", "FriendlyRogue")   -- 0020 = Myspells are
 
  -- Assert that when this message is received, it must change the spells for that player
  --Assert
  TESTAssert("MySpells", objPvPHelperServer.Message.Header, "MessageReceived - Header")
  TESTAssert("1776,2094,113506", objPvPHelperServer.Message.Body, "MessageReceived - Body")
  TESTAssert("FriendlyRogue", objPvPHelperServer.Message.From, "MessageReceived - From")

  objPlayer = objPvPHelperServer.FriendList:LookupGUID("ROGUE123")
  TESTAssert("ROGUE123", tostring(objPlayer.GUID), "Found Player GUID")
  TESTAssert("FriendlyRogue", tostring(objPlayer.Name), "Player Name")  
  TESTAssert("1776,2094,113506", tostring(objPlayer.CCTypes:ListSpellIds()), "Player now should have correct spells in list.")  

  TESTAssert("113506,605,107570,8122,46968,100,15487,64044,1776,2094,5246", tostring(objPvPHelperServer.FriendList.FriendCCTypesList:ListSpellIds()), "PvPServer set up with Updated spells after spell update")  

end

function TEST_MESSAGERECEIVED_PLAYERSPELLONCOOLDOWN()
  -- Arrange
  objPvPHelperServer = PvPHelperServer.new()
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"}))

  local objFriendList = TEST_CreateTestFriendList()
  objPvPHelperServer.FriendList = objFriendList;
  objPvPHelperServer.FoeList = objFoeList;

  
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells("FOEGUID123");  
  
  TESTAssert("5246", tostring(objOrderedCCSpells[1].Spell.SpellId), "Initial CC Spell before cooldowns should be Intimidating Shout")  
  TESTAssert("WARR123", tostring(objOrderedCCSpells[1].Friend.GUID), "Friend GUID of Initial CC Spell before cooldowns")  

  TESTAssert("2094", tostring(objOrderedCCSpells[2].Spell.SpellId), "Then Blind")  
  TESTAssert("ROGUE123", tostring(objOrderedCCSpells[2].Friend.GUID), "Rogue should CC next")  

  TESTAssert(0, objOrderedCCSpells[1].Spell:CooldownExpires(), "Not on cooldown") 

  -- Act
  objPvPHelperServer:MessageReceived("PvPHelperServer", "SpellCoolDown.5246", "WHISPER", "FriendlyWarrior")   -- SpellCoolDown = Cooldown

  -- Now get the new list of ordered spells.
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells("FOEGUID123");

  for i, cc in ipairs(objOrderedCCSpells) do
    if cc.Spell.SpellId == 5246 then
      --print("Found "..cc.Spell.SpellId);
      TESTAssert(90, cc.Spell:CooldownExpires(), "Should be on cooldown") 
      break;
    end
  end

  TESTAssert("2094", tostring(objOrderedCCSpells[1].Spell.SpellId), "Now Blind should be first in list")  
  TESTAssert("ROGUE123", tostring(objOrderedCCSpells[1].Friend.GUID), "Rogue should CC next")  


end

function TEST_MESSAGERECEIVED_PLAYERSPELLOFFCOOLDOWN()
  -- Arrange
  objPvPHelperServer = PvPHelperServer.new()
  local objFoeList = FoeList.new()
  objFoeList:Add(Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"}))

  local objFriendList = TEST_CreateTestFriendList()
  objPvPHelperServer.FriendList = objFriendList;
  objPvPHelperServer.FoeList = objFoeList;

  objWarr = objPvPHelperServer.FriendList:LookupGUID("WARR123");
  objSpell = objWarr.CCTypes:LookupSpellId(5246)
  objSpell:CastSpell();
  
  -- Get the list of Ordered Spells before we act
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells("FOEGUID123");  
  
  -- Check that Intimidating shout is on Cooldown
  for i, cc in ipairs(objOrderedCCSpells) do
    if cc.Spell.SpellId == 5246 then
      --print("Found "..cc.Spell.SpellId);
      TESTAssert(90, cc.Spell:CooldownExpires(), "Should be on cooldown") 
      break;
    end
  end

 -- Check that Blind should be 1st if intimidating shout is on Cooldown
  TESTAssert("2094", tostring(objOrderedCCSpells[1].Spell.SpellId), "Blind should be 1st if Intimidating shout is on Cooldown")  
  TESTAssert("ROGUE123", tostring(objOrderedCCSpells[1].Friend.GUID), "Rogue should CC next")  
   

  -- Act
  -- We are now told that Intimidating shout is off cooldown
  objPvPHelperServer:MessageReceived("PvPHelperServer", "SpellOffCooldown.5246", "WHISPER", "FriendlyWarrior")

  -- Now get the new list of ordered spells.
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells("FOEGUID123");

  for i, cc in ipairs(objOrderedCCSpells) do
    if cc.Spell.SpellId == 5246 then
      --print("Found "..cc.Spell.SpellId);
      TESTAssert(0, cc.Spell:CooldownExpires(), "Intimidating shout Should now be OFF cooldown") 
      break;
    end
  end
  
  TESTAssert("5246", tostring(objOrderedCCSpells[1].Spell.SpellId), "Intimidating Shout should now be 1st")  
  TESTAssert("WARR123", tostring(objOrderedCCSpells[1].Friend.GUID), "Cast by Warrior")  

  TESTAssert("2094", tostring(objOrderedCCSpells[2].Spell.SpellId), "Then Blind should be 2nd")  
  TESTAssert("ROGUE123", tostring(objOrderedCCSpells[2].Friend.GUID), "Rogue should CC next")  


end

function TEST_EVENT_RAID_ROSTER_UPDATE()
    
--ARRANGE  
  objPvPHelperServer = PvPHelperServer.new()
  
  -- CHeck that we intially only have ourself in the friendlist
  TESTAssert(1, table.maxn(objPvPHelperServer.FriendList), "Only player in friendlist initially")  

-- ACT
-- Event fires that says that Friendly Priest has applied aura "Dominate Mind" on FoeGUID123

  -- Set debug value for UnitInRaid to return True for "player"
  
  DEBUG.GetRaidRosterInfo = {}
  DEBUG.GetRaidRosterInfo[1] = {}
  DEBUG.GetRaidRosterInfo[1].name = "FriendlyPriest"
  DEBUG.GetRaidRosterInfo[1].rank = 1
  DEBUG.GetRaidRosterInfo[1].subgroup = 1
  DEBUG.GetRaidRosterInfo[1].level = 90
  DEBUG.GetRaidRosterInfo[1].class  = "Priest"
  DEBUG.GetRaidRosterInfo[1].fileName = "UnknownFileName"
  DEBUG.GetRaidRosterInfo[1].zone = "UnknownZone"
  DEBUG.GetRaidRosterInfo[1].online = true
  DEBUG.GetRaidRosterInfo[1].isDead = false
  DEBUG.GetRaidRosterInfo[1].role = "DPS"
  DEBUG.GetRaidRosterInfo[1].isML = false;

  DEBUG.GetRaidRosterInfo[2] = {}
  DEBUG.GetRaidRosterInfo[2].name = "FriendlyWarrior"
  DEBUG.GetRaidRosterInfo[2].rank = 1
  DEBUG.GetRaidRosterInfo[2].subgroup = 1
  DEBUG.GetRaidRosterInfo[2].level = 90
  DEBUG.GetRaidRosterInfo[2].class  = "Warrior"
  DEBUG.GetRaidRosterInfo[2].fileName = "UnknownFileName"
  DEBUG.GetRaidRosterInfo[2].zone = "UnknownZone"
  DEBUG.GetRaidRosterInfo[2].online = true
  DEBUG.GetRaidRosterInfo[2].isDead = false
  DEBUG.GetRaidRosterInfo[2].role = "DPS"
  DEBUG.GetRaidRosterInfo[2].isML = false;

  -- Set the number of raid members that should be reported
  -- and that the player is in a raid
  DEBUG.GetNumRaidMembers = 2
  DEBUG.UnitInRaid = {};
  DEBUG.UnitInRaid["player"]= {};
  DEBUG.UnitInRaid["player"].retval = true;
  
  DEBUG.GetNumPartyMembers = 0 
  DEBUG.UnitInParty = {};
  DEBUG.UnitInParty["player"]= {};
  DEBUG.UnitInParty["player"].retval = false;
  

  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "RAID_ROSTER_UPDATE", "PvPHelper", Event, hideCaster, "WARRIOR123", "FriendlyWarrior", sourceFlags, sourceRaidFlags, foeGUID, foeName, destFlags, destRaidFlags, spellId)
  
--ASSERT  
  TESTAssert(2, table.maxn(objPvPHelperServer.FriendList), "Should have found 2 Friend")  
  local objFriend = objPvPHelperServer.FriendList[2];
  TESTAssert("FriendlyWarrior", objFriend.Name, "Should have found 2 Friends name correctly")  

end

function TEST_EVENT_PARTY_MEMBERS_CHANGED()
    
--ARRANGE  
  objPvPHelperServer = PvPHelperServer.new()
  
  -- CHeck that we have an empty FoeList initially
  TESTAssert(1, table.maxn(objPvPHelperServer.FriendList), "One friend initially")  

-- ACT
-- Event fires that says that Friendly Priest has applied aura "Dominate Mind" on FoeGUID123

  -- Set debug value for UnitInRaid to return True for "player"

  DEBUG.GetRaidRosterInfo = {}
  DEBUG.GetRaidRosterInfo[1] = {}
  DEBUG.GetRaidRosterInfo[1].name = "FriendlyPriest"
  DEBUG.GetRaidRosterInfo[1].rank = 1
  DEBUG.GetRaidRosterInfo[1].subgroup = 1
  DEBUG.GetRaidRosterInfo[1].level = 90
  DEBUG.GetRaidRosterInfo[1].class  = "Priest"
  DEBUG.GetRaidRosterInfo[1].fileName = "UnknownFileName"
  DEBUG.GetRaidRosterInfo[1].zone = "UnknownZone"
  DEBUG.GetRaidRosterInfo[1].online = true
  DEBUG.GetRaidRosterInfo[1].isDead = false
  DEBUG.GetRaidRosterInfo[1].role = "DPS"
  DEBUG.GetRaidRosterInfo[1].isML = false;

  DEBUG.GetRaidRosterInfo[2] = {}
  DEBUG.GetRaidRosterInfo[2].name = "FriendlyWarrior"
  DEBUG.GetRaidRosterInfo[2].rank = 1
  DEBUG.GetRaidRosterInfo[2].subgroup = 1
  DEBUG.GetRaidRosterInfo[2].level = 90
  DEBUG.GetRaidRosterInfo[2].class  = "Warrior"
  DEBUG.GetRaidRosterInfo[2].fileName = "UnknownFileName"
  DEBUG.GetRaidRosterInfo[2].zone = "UnknownZone"
  DEBUG.GetRaidRosterInfo[2].online = true
  DEBUG.GetRaidRosterInfo[2].isDead = false
  DEBUG.GetRaidRosterInfo[2].role = "DPS"
  DEBUG.GetRaidRosterInfo[2].isML = false;

  -- Set the number of raid members that should be reported
  -- and that the player is in a raid
  DEBUG.GetNumRaidMembers = 0   
  DEBUG.UnitInRaid = {};
  DEBUG.UnitInRaid["player"]= {};
  DEBUG.UnitInRaid["player"].retval = false;
  
  DEBUG.GetNumPartyMembers = 2 
  DEBUG.UnitInParty = {};
  DEBUG.UnitInParty["player"]= {};
  DEBUG.UnitInParty["player"].retval = true;
  
  DEBUG.UnitName = {};
  DEBUG.UnitName["player"] = "FriendlyPriest";
  DEBUG.UnitName["party1"] = "FriendlyPriest";
  DEBUG.UnitName["party2"] = "FriendlyWarrior";
  
  DEBUG.UnitGUID = {};
  DEBUG.UnitGUID["player"] = "PRIEST123";
  DEBUG.UnitGUID["party1"] = "PRIEST123";
  DEBUG.UnitGUID["party2"] = "WARR123";


  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "PARTY_MEMBERS_CHANGED", "PvPHelper", Event, hideCaster, "WARRIOR123", "FriendlyWarrior", sourceFlags, sourceRaidFlags, foeGUID, foeName, destFlags, destRaidFlags, spellId)


--ASSERT  
  TESTAssert(2, table.maxn(objPvPHelperServer.FriendList), "Should have found 2 Friends")  
  local objFriend = objPvPHelperServer.FriendList[1];
  TESTAssert("FriendlyPriest", objFriend.Name, "Should have found 1 Friends name correctly")  
  TESTAssert("PRIEST123", objFriend.GUID, "Should have found 1 Friends GUID correctly")  

  objFriend = objPvPHelperServer.FriendList[2];
  TESTAssert("FriendlyWarrior", objFriend.Name, "Should have found Friend[2] name correctly")  
  TESTAssert("WARR123", objFriend.GUID, "Should have found Friend[2] GUID correctly")  
  

end


function TEST_CLOCK()

  DEBUG.SetClockSeconds = 100;
  TESTAssert(100, GetTime(), "Set the clock correctly for debugging")  
  
  DEBUG.SetClockSeconds = 102;
  TESTAssert(102, GetTime(), "Set the clock correctly for debugging")  

end

function TEST_ONUPDATE_IF_NO_SPELL_CAST_SHOULD_KEEP_NOTIFYING()
  -- Each second, the onupdate function runs.  
  -- It must keep track of which is the current and next CC action to cast
  -- It must notify each client of which CC action to do and when to do it
  -- E.g. CC1 now, CC2 in <cc1.cooldown> seconds
  -- Then when the CC action changes, it must notify the clients.
  
  DEBUG.SetClockSeconds = 100;
  DEBUG.LogMessages = true;
  GVAR.MessageLog = {};
  
  objPvPHelperServer = PvPHelperServer.new()
  local objFoeList = FoeList.new()
  local objFoe = Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"});
  objFoeList:Add(objFoe)

  local objFriendList = TEST_CreateTestFriendList()
  objPvPHelperServer.FriendList = objFriendList;
  objPvPHelperServer.FoeList = objFoeList;

  local btnCCTarget1 = UIWidgets.CCButton[1];
  
  btnCCTarget1.Foe = deepcopy(objFoe);
  
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells(objFoe.GUID);  
  
  TESTAssert("5246", tostring(objOrderedCCSpells[1].Spell.SpellId), "Initial CC Spell before cooldowns should be Intimidating Shout")  
  TESTAssert("WARR123", tostring(objOrderedCCSpells[1].Friend.GUID), "Friend GUID of Initial CC Spell before cooldowns")  
  
  local nextSpell;
  local followingSpell;
  
  if (objOrderedCCSpells) then
    nextSpell =       objOrderedCCSpells[1];
    followingSpell =  objOrderedCCSpells[2];
  else
    print("Got no CC spells");
  end
			
  
  TESTAssert(5246, nextSpell.Spell.SpellId, "1.NextSpell SpellId")
  TESTAssert("WARR123", nextSpell.Friend.GUID, "1.NextSpell FriendGUID")  
  TESTAssert(2094, followingSpell.Spell.SpellId, "1.followingSpell SpellId")
  TESTAssert("ROGUE123", followingSpell.Friend.GUID, "1.followingSpell FriendGUID")  
  
  GVAR.MessageLog = {}
  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  --pvpServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);
  local elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)

  
  TESTAssert(3, table.getn(GVAR.MessageLog), "Should send msg to Warrior, Rogue and Priest");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr first");
  TESTAssert("ActNow", GVAR.MessageLog[1].Header, "Send to Warr to Act Now");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");

  TESTAssert("FriendlyRogue", GVAR.MessageLog[2].To, "Send to Rogue next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[2].Header, "Send to Rogue to Prepare");
  TESTAssert("1776", GVAR.MessageLog[2].Payload2, "Send to Rogue to Gouge");

  TESTAssert("FriendlyPriest", GVAR.MessageLog[3].To, "Send to Priest next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[3].Header, "Send to Priest to Prepare");
  TESTAssert("64044", GVAR.MessageLog[3].Payload2, "Send to Priest to Horrify");
  
  
  --print("Ticking on +2 sec");
  GVAR.MessageLog = {}
  DEBUG.SetClockSeconds = 102;
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  --TESTAssert(1, table.getn(GVAR.MessageLog), "Should send msg to Warrior");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr");
  TESTAssert("ActNow", GVAR.MessageLog[1].Header, "Send to Warr to Act Now");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");



  --print("Ticking on +2 more sec");
  GVAR.MessageLog = {}
  DEBUG.SetClockSeconds = 104;
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)

  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send nothing");


  --print("Ticking on +2 more sec");
  DEBUG.SetClockSeconds = 106;
  GVAR.MessageLog = {}  
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)

  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send msg to Warrior");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr ");
  TESTAssert("LateActNow", GVAR.MessageLog[1].Header, "5 sec late warning");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");


  --print("Ticking on +2 more sec");
  DEBUG.SetClockSeconds = 108;
  GVAR.MessageLog = {}  
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send msg to Warrior");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr 8 sec late");
  TESTAssert("LateActNow", GVAR.MessageLog[1].Header, "8 sec late warning");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");


  --print("Ticking on +2 more sec");
  DEBUG.SetClockSeconds = 110;
  GVAR.MessageLog = {}  
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send nothing after 10 sec");

  
  
  --print("Ticking on +2 more sec");
  DEBUG.SetClockSeconds = 112;
  GVAR.MessageLog = {}  
  elapsed = 2;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send VLate msg to Warrior");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr 11 sec Very late");
  TESTAssert("VeryLateActNow", GVAR.MessageLog[1].Header, "11 sec VERY late warning");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");


  --print("Ticking on +1 sec");
  DEBUG.SetClockSeconds = 113;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");

  
  --print("Ticking on +1 sec");
  DEBUG.SetClockSeconds = 114;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send VLate msg to Warrior");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr 14 sec Very late");
  TESTAssert("VeryLateActNow", GVAR.MessageLog[1].Header, "14 sec VERY late warning");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");


  --print("Ticking on +1 sec");
  DEBUG.SetClockSeconds = 115;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");

  
  --print("Ticking on +1 sec");
  DEBUG.SetClockSeconds = 116;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");

  
  DEBUG.SetClockSeconds = 120;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");

  
  DEBUG.SetClockSeconds = 140;
  GVAR.MessageLog = {}  
  elapsed = 1;
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");
  
  



end




function TEST_ONUPDATE_SHOULD_NOTIFY_NEXT_ON_SPELLCAST()
  
  DEBUG.SetClockSeconds = 100;
  DEBUG.LogMessages = true;
  GVAR.MessageLog = {};
  
  objPvPHelperServer = PvPHelperServer.new()
  local objFoeList = FoeList.new()
  local objFoe = Foe.new({GUID="FOEGUID123", Name="BadPersonA", Class="MAGE"});
  objFoeList:Add(objFoe)

  local objFriendList = TEST_CreateTestFriendList()
  objPvPHelperServer.FriendList = objFriendList;
  objPvPHelperServer.FoeList = objFoeList;

  local btnCCTarget1 = UIWidgets.CCButton[1];
  
  btnCCTarget1.Foe = objFoe;
  
  objOrderedCCSpells = objPvPHelperServer:OrderedCCSpells(objFoe.GUID);  
  
  TESTAssert("5246", tostring(objOrderedCCSpells[1].Spell.SpellId), "Initial CC Spell before cooldowns should be Intimidating Shout")  
  TESTAssert("WARR123", tostring(objOrderedCCSpells[1].Friend.GUID), "Friend GUID of Initial CC Spell before cooldowns")  
  
  local nextSpell;
  local followingSpell;
  
  if (objOrderedCCSpells) then
    nextSpell =       objOrderedCCSpells[1];
    followingSpell =  objOrderedCCSpells[2];
  else
    print("Got no CC spells");
  end
			
  
  TESTAssert(5246, nextSpell.Spell.SpellId, "1.NextSpell SpellId")
  TESTAssert("WARR123", nextSpell.Friend.GUID, "1.NextSpell FriendGUID")  
  TESTAssert(2094, followingSpell.Spell.SpellId, "1.followingSpell SpellId")
  TESTAssert("ROGUE123", followingSpell.Friend.GUID, "1.followingSpell FriendGUID")  
  
  GVAR.MessageLog = {}
  
  -- Tell the Friend to Cast CC - then wait for the aura to apply
  --pvpServer:Apply_Aura(nextSpell.FriendGUID, nextSpell.SpellId, CCGUID1);
  local elapsed = 2;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)

  
  TESTAssert(3, table.getn(GVAR.MessageLog), "Should send msg to Warrior, Rogue and Priest");
  TESTAssert("FriendlyWarrior", GVAR.MessageLog[1].To, "Send to Warr first");
  TESTAssert("ActNow", GVAR.MessageLog[1].Header, "Send to Warr to Act Now");
  TESTAssert("5246", GVAR.MessageLog[1].Payload2, "Send to Warr to Intimidating Shout");

  TESTAssert("FriendlyRogue", GVAR.MessageLog[2].To, "Send to Rogue next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[2].Header, "Send to Rogue to Prepare");
  TESTAssert("1776", GVAR.MessageLog[2].Payload2, "Send to Rogue to Gouge");

  TESTAssert("FriendlyPriest", GVAR.MessageLog[3].To, "Send to Priest next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[3].Header, "Send to Priest to Prepare");
  TESTAssert("64044", GVAR.MessageLog[3].Payload2, "Send to Priest to Horrify");



  --print("First tick");
  DEBUG.SetClockSeconds = 101;
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Should send no messages");

  -- First thing happens is that we see that the aura is applied
  sourceGUID = "WARR123"
  sourceName = "FriendlyWarrior"
  sourceSpellId = 5246;
  destGUID = "FOEGUID123"

  objPvPHelperServer:Apply_Aura(sourceGUID, sourceSpellId, destGUID);
  
  -- And then we get a message that it's been cast
  objPvPHelperServer:MessageReceived("PvPHelperServer", "SpellCoolDown."..sourceSpellId, "WHISPER", sourceName)  
  
  
  --print("Tick on 1 sec");
  DEBUG.SetClockSeconds = 102;
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);  
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  -- So the warrior has now fired off Intimidating shout, we should have it active on the 
  -- target for 8 seconds
  
  TESTAssert("FOEGUID123", objFoe.GUID, "This is the target");
  TESTAssert(7, objFoe:MaxActiveCCExpires(), "Should have 7 sec active CC now that Warr has Intimidating Shouted him");
  
  --  btnCCTarget1.Foe = objFoe;

  TESTAssert("FriendlyRogue", GVAR.MessageLog[1].To, "Send to Rogue next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[1].Header, "Send to Rogue to Prepare");
--  TESTAssert("1776", GVAR.MessageLog[1].Payload, "Send to Rogue to Gouge");
  TESTAssert("1776", GVAR.MessageLog[1].Payload2, "Send to Rogue to Gouge");

print("**Removed Aura")
  -- Now the foe uses his trinket to remove the aura
  PVPHelperServer_OnEvent(PvPHelperServer_MainFrame, "COMBAT_LOG_EVENT_UNFILTERED", "PvPHelper", "SPELL_AURA_REMOVED", hideCaster, "PRIEST123", "FriendlyPriest", sourceFlags, sourceRaidFlags, "FOEGUID123", "MrBadFoe1", destFlags, destRaidFlags, 5246, "Intimidating Shout")   -- 605 = Dominate Mind
  
  DEBUG.SetClockSeconds = 103;
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages - get rogue to gouge now");
  
  TESTAssert("FriendlyRogue", GVAR.MessageLog[1].To, "Send to Rogue next");
  TESTAssert("ActNow", GVAR.MessageLog[1].Header, "Send to Rogue to Act Now");
  TESTAssert("1776", GVAR.MessageLog[1].Payload2, "Send to Rogue to Gouge");


  DEBUG.SetClockSeconds = 103.5;
  print("DEBUG:Rogue gouges the wrong target!")
  objPvPHelperServer:MessageReceived("PvPHelperServer", "SpellCoolDown.1776", "WHISPER", "FriendlyRogue")  
  
  
  DEBUG.SetClockSeconds = 104;
  
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(2, table.getn(GVAR.MessageLog), "Should send 2 new messages");

  TESTAssert("FriendlyPriest", GVAR.MessageLog[1].To, "Send to Priest next");
  TESTAssert("ActNow", GVAR.MessageLog[1].Header, "Send to Priest to ActNow");
  TESTAssert("64044", GVAR.MessageLog[1].Payload2, "Send to Priest to Horrify");
  
  TESTAssert("FriendlyRogue", GVAR.MessageLog[2].To, "Send to Rogue next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[2].Header, "Send to Rogue to Prepare");
  TESTAssert("1776", GVAR.MessageLog[2].Payload2, "Send to Rogue to Gouge");
  
  print("Priest casts Horrify");
  objPvPHelperServer:Apply_Aura("PRIEST123", 64044, "FOEGUID123");

  DEBUG.SetClockSeconds = 105;
  
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages - get priest to Silence in 8 sec");

  TESTAssert("FriendlyPriest", GVAR.MessageLog[1].To, "Send to Priest next");
  TESTAssert("PrepareToAct", GVAR.MessageLog[1].Header, "Send to Priest to Prepare to Act");
  TESTAssert("15487", GVAR.MessageLog[1].Payload2, "Send to Priest to Silence");

  DEBUG.SetClockSeconds = 110;
  
  GVAR.MessageLog = {}  
  elapsed = 7;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(0, table.getn(GVAR.MessageLog), "Send nothing");

  
  -- And then we get a message that it's been cast
  --objPvPHelperServer:MessageReceived("PvPHelperServer", "SpellCoolDown.64044", "WHISPER", sourceName)  

  print("Priest casts Silence 1 second early");
  objPvPHelperServer:Apply_Aura("PRIEST123", 15487, "FOEGUID123");
  
  DEBUG.SetClockSeconds = 111;
  
  GVAR.MessageLog = {}  
  elapsed = 7;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(2, table.getn(GVAR.MessageLog), "Tell warr to charge now and Priest to prep to dominate mind");

  
  print("Warrior Charges");
  objPvPHelperServer:Apply_Aura("WARR123", 100, "FOEGUID123");

  DEBUG.SetClockSeconds = 112;
  
  GVAR.MessageLog = {}  
  elapsed = 1;
  print("Time now is "..DEBUG.SetClockSeconds);
  PVPHelperServer_OnUpdate(PvPHelperServer_MainFrame, elapsed)
  
  TESTAssert(1, table.getn(GVAR.MessageLog), "Should send new messages - Warr to Shockwave");


end

--END FUNCTIONS
-- TESTS TO PERFORM
print("--START TESTS--\n")
--TEST_CCDR()
--TEST_CCDRLIST()
--TEST_CCTYPE()
--TEST_CCTYPELIST()
--TEST_FOEDR()
--TEST_FOEDRLIST()
--TEST_FOE()
--TEST_FOELIST()
--TEST_FRIEND()
--TEST_FRIENDLIST()
--TEST_FRIENDCCTYPE()
--TEST_FRIENDCCTYPELIST()
TEST_AURA_APPLIED()
--TEST_AURA_REMOVED()
----TEST_GETNEXTSPELL_STANDARD()
----TEST_GETNEXTSPELL_CHECKS()
--TEST_EVENT_CHATMESSAGE()
--TEST_EVENT_PLAYER_REGEN_DISABLED()
--TEST_EVENT_PLAYER_REGEN_ENABLED()
--TEST_EVENT_RAID_ROSTER_UPDATE()
--TEST_EVENT_SPELL_AURA_REMOVED()
--TEST_EVENT_SPELL_AURA_APPLIED()
--TEST_MESSAGERECEIVED_PLAYERSPELLS()
--TEST_MESSAGERECEIVED_PLAYERSPELLONCOOLDOWN()
--TEST_MESSAGERECEIVED_PLAYERSPELLOFFCOOLDOWN()
--TEST_EVENT_RAID_ROSTER_UPDATE()
--TEST_EVENT_PARTY_MEMBERS_CHANGED()
--TEST_CLOCK()
--TEST_ONUPDATE_IF_NO_SPELL_CAST_SHOULD_KEEP_NOTIFYING()
TEST_ONUPDATE_SHOULD_NOTIFY_NEXT_ON_SPELLCAST()
print("--END TESTS--\n")






