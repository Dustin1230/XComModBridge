Class ModBridge extends XComMod
 config(ModBridge);

var string valStrValue0;
var string valStrValue1;
var string valStrValue2;
var int valIntValue0;
var int valIntValue1;
var int valIntValue2;
var array<string> valArrStr;
var array<int> valArrInt;
var TTableMenu valTMenu;
var string functionName;
var string functParas;
var string ModInitError;
var bool bModReturn;
var class<CheatManager> ModCheatClass;
var array<XComMod> MBMods;
var config bool verboseLog;
var config array<string> ModList;

simulated function StartMatch()
{
	local XComMod Mod;
	local string ModName;
	local int i;
	local bool bFound;

	if(MBMods.Length > 0)
		MBMods.Length = 0;

	functionName = "ModInit";

	class'Engine'.static.GetCurrentWorldInfo().Game.SetTimer(1.0f, true, 'OverwriteCheatClass', self);

	AssignMods();

	`Log("Start ModInit", verboseLog, 'ModBridge');


	foreach MBMods(Mod, i)
	{
		ModInitError = "";
		bFound = false;
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log(ModName @ "ModInit attempt", verboseLog, 'ModBridge');

		MBMods[i].StartMatch();
		bFound = true;
			
		`Log(ModName $ ", ModInitError= \"" $ ModInitError $ "\"", (bFound && (ModInitError != "")), 'ModBridge');
		`Log(ModName @ "ModInit Successful", (bFound && (ModInitError == "")), 'ModBridge');
	}

	foreach XComGameInfo(Outer).ModNames(ModName, i)
	{
		foreach MBMods(Mod)
		{
			bFound = false;
			if(ModName == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
			{
				bFound = true;
				`Log("XComMod|" $ ModName @ "Found as:" @ "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class) $ ", skipping ModInit", verboseLog, 'ModBridge');
				break;
			}
		}

		if((XComGameInfo(Outer).Mods[i] != self) && (!bFound))
		{
			`Log("XComMod|" $ ModName @ "ModInit attempt", verboseLog, 'ModBridge');

			ModInitError = "";
			XComGameInfo(Outer).Mods[i].StartMatch();

			`Log("XComMod|" $ ModName $ ", ModInitError= \"" $ ModInitError $ "\"", (ModInitError != ""), 'ModBridge');
			`Log("XComMod|" $ ModName @ "ModInit Successful", (verboseLog && (ModInitError == "")), 'ModBridge');

		}
	}

	`Log("Overwrite Checkpoint classes", verboseLog, 'ModBridge');

	XComGameInfo(Outer).TacticalSaveGameClass = class'Mod_Checkpoint_TacticalGame';
	XComGameInfo(Outer).TransportSaveGameClass = class'Mod_Checkpoint_StrategyTransport';

	if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
	{
		`Log("StrategyGame Detected, Checkpoint class overwrite", verboseLog, 'ModBridge');

		XComGameInfo(Outer).StrategySaveGameClass = class'Mod_Checkpoint_StrategyGame';
	}

	`Log("End of StartMatch", verboseLog, 'ModBridge');

	functionName = "";
}

function ModError(string Error)
{
	`Log("Mod Function \"" $ GetCallingMod() $ "\" Error=" @ Error, true, 'ModBridge');
}

function bool ModRecordActor(string Checkpoint, class<Actor> ActorClasstoRecord)
{

	local int I;
	local bool bFound;
 
	if(Checkpoint ~= "Tactical")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to TacticalGame Checkpoint", verboseLog, 'ModBridge');

		for(I=0; I<class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

		if(bFound || class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}

	if(Checkpoint ~= "Transport")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to StrategyTransport Checkpoint", verboseLog, 'ModBridge');

		for(I=0; I<class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
			                                                                                                
		if(bFound || class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}
	if(Checkpoint ~= "Strategy")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to StrategyGame Checkpoint", verboseLog, 'ModBridge');

		for(I=0; I<class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length; I++)
		{
			if(class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord[I] == ActorClasstoRecord)
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
			class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

		if(bFound || class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}

	return false;
}

function OverwriteCheatClass()
{
	local WorldInfo WI;
	local PlayerController PC;
	local class<CheatManager> ShellClass;
	local XComMod ShellClassScript;

	WI = class'Engine'.static.GetCurrentWorldInfo();
	PC = WI.GetALocalPlayerController();

	if(PC == none)
		return;

	`Log("PlayerController initalised, overwriting CheatManager", verboseLog, 'ModBridge');

	WI.Game.ClearTimer('OverwriteCheatClass', self);

	if(PC.IsA('XComShellController'))
	{
		ShellClassScript = new (self) Class<XComMod>(DynamicLoadObject("XComModBridge_Shell.ShellClassScript", class'Class'));

		ShellClassScript.StartMatch();

		ShellClass = ModCheatClass;

		`Log("Shell detected, using ShellCheatManager", verboseLog, 'ModBridge');
		PC.CheatClass = ShellClass;
		PC.CheatManager = new (XComPlayerControllerNativeBase(PC)) ShellClass;
	}
	if(PC.IsA('XComHeadquartersController'))
	{
		`Log("Strategy detected, using StrategyCheatManager", verboseLog, 'ModBridge');
		PC.CheatClass = class'Mod_StrategyCheatManager';
		PC.CheatManager = new (XComHeadquartersController(PC)) class'Mod_StrategyCheatManager';
	}
	if(PC.IsA('XComTacticalController'))
	{
		`Log("Tactical detected, using TacticalCheatManager", verboseLog, 'ModBridge');
		PC.CheatClass = class'Mod_TacticalCheatManager';
		PC.CheatManager = new (XComTacticalController(PC)) class'Mod_TacticalCheatManager';
	}

}

function SwitchCheatManager(string modpackage)
{
	local bool bFound;
	local XComMod Mod, ShellClassScript;
	local class<CheatManager> ShellClass;
	local WorldInfo WI;
	local PlayerController PC;

	`Log("SwitchCheatManager", verboseLog, 'ModBridge');

	if(modpackage == "")
	{
		`Log("Switching to base Mod Cheat class", verboseLog, 'ModBridge');
		OverwriteCheatClass();
		return;
	}

	WI = class'Engine'.static.GetCurrentWorldInfo();
	PC = WI.GetALocalPlayerController();

	foreach MBMods(Mod)
	{
		if(string(Mod.Class.GetPackageName()) == modpackage)
		{
			bFound = true;
			break;
		}
	}
	if(!bFound)
	{
		foreach XComGameInfo(Outer).Mods(Mod)
		{
			if(Mod != self && string(Mod.Class.GetPackageName()) == modpackage)
			{
				bFound = true;
				break;
			}
		}
	}

	if(!bFound)
	{
		`Log("Switching to base Mod Cheat class", verboseLog, 'ModBridge');
		OverwriteCheatClass();
		return;
	}
	else
	{
		`Log("looking for CheatManager in \"" $ Mod.Class $ "\"", verboseLog, 'ModBridge');  

		bFound = false;

		functionName = "SwitchCheatManager";

		if(PC.IsA('XComShellController'))
		{
			ShellClassScript = new (self) class<XComMod>(DynamicLoadObject("XComModBridge_Shell.ShellClassScript", class'Class'));

			ShellClassScript.StartMatch();

			ShellClass = ModCheatClass;


			functParas = "Shell";
			Mod.StartMatch();
			if(ClassIsChildOf(ModCheatClass, ShellClass))
			{
				`Log("Found CheatManager: \"" $ ModCheatClass $ "\" for Shell", verboseLog, 'ModBridge');
				PC.CheatClass = ModCheatClass;
				PC.CheatManager = new (XComPlayerControllerNativeBase(PC)) ModCheatClass;
				bFound = true;
			}
		}
		else if(PC.IsA('XComHeadquartersController'))
		{
			functParas = "Strategy";
			Mod.StartMatch();
			if(ClassIsChildOf(ModCheatClass, class'Mod_StrategyCheatManager'))
			{
				`Log("Found CheatManager: \"" $ ModCheatClass $ "\" for Strategy", verboseLog, 'ModBridge');
				PC.CheatClass = ModCheatClass;
				PC.CheatManager = new (XComHeadquartersController(PC)) ModCheatClass;
				bFound = true;
			}
		}
		else if(PC.IsA('XComTacticalController'))
		{
			functParas = "Tactical";
			Mod.StartMatch();
			if(ClassIsChildOf(ModCheatClass, class'Mod_TacticalCheatManager'))
			{
				`Log("Found CheatManager: \"" $ ModCheatClass $ "\" for Tactical", verboseLog, 'ModBridge');
				PC.CheatClass = ModCheatClass;
				PC.CheatManager = new (XComTacticalController(PC)) ModCheatClass;
				bFound = true;
			}
		}

		if(!bFound)
		{
			if(ClassIsChildOf(ModCheatClass, class'Mod_CheatManager'))
			{
				`Log("Found Generic CheatManager: \"" $ ModCheatClass $ "\"", verboseLog, 'ModBridge');
				PC.CheatClass = ModCheatClass;
				PC.CheatManager = new (XComPlayerControllerNativeBase(PC)) ModCheatClass;
			}
			else
			{
				`Log("Switching to base Mod Cheat class", verboseLog, 'ModBridge');
				OverwriteCheatClass();
			}
		}
	}

	ModCheatClass = none;
	functionName = "";
	functParas = "";

}

function string GetCallingMod(optional int backlevels = 3)
{
	local array<string> arrStr;

	arrStr = SplitString(GetScriptTrace(), "Function ");
	return left(arrStr[arrStr.Length-backlevels], Len(arrStr[arrStr.Length-backlevels])-2);
}

function AssignMods()
{
	local XComMod Mod;
	local string ModName;
	local int i;
	local bool bFound;

	`Log("Started AssignMods", verboseLog, 'ModBridge');

	foreach ModList(ModName, i)
	{
		Mod = new (self) class<XComMod>(DynamicLoadObject(ModName, class'Class'));
		`Log( "adding \"" $ ModName $ "\" to modlist", verboseLog, 'ModBridge');
		MBMods[i] = Mod;
	}

	for(i=0; i<XComGameInfo(outer).ModNames.Length; i++)
	{
		ModName = XComGameInfo(outer).ModNames[i];
		bFound = false;
		foreach XComGameInfo(outer).Mods(Mod)
		{
			if(ModName == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
			{
				bFound = true;
				break;
			}
		}

		if(!bFound)
		{
			`Log("removing \"" $ ModName $ "\" from XComGameInfo.ModNames", verboseLog, 'ModBridge');
			XComGameInfo(outer).ModNames.Remove(i, 1);
			-- i;
		}

	}

	while(XComGameInfo(Outer).Mods[XComGameInfo(Outer).Mods.Length-1] == none)
		XComGameInfo(Outer).Mods.Remove(XComGameInfo(Outer).Mods.Length-1, 1);

	`Log("End of AssignMods", verboseLog, 'ModBridge');

}

function ModsStartMatch()
{

	local XComMod Mod;
	local string ModName;
	local int i;

	
	bModReturn = false;
	foreach MBMods(Mod, i)
	{
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log("Executing StartMatch function in \"" $ ModName $ "\"", verboseLog, 'ModBridge');
		MBMods[i].StartMatch();
		if(bModReturn)
		{
			`Log("AllMods loop stopped due to bModReturn being set by: \"" $ ModName $ "\"", verboseLog, 'ModBridge');
			break;
		}
	}

	for(i=1; i<XComGameInfo(outer).Mods.Length; I++)
	{
		`Log("Executing StartMatch function in \"" $ "XComMod|" $ XComGameInfo(outer).ModNames[i] $ "\"", verboseLog, 'ModBridge');
		XComGameInfo(outer).Mods[i].StartMatch();
		if(bModReturn)
		{
			`Log("AllMods loop stopped due to bModReturn being set by: \"" $ "XComMod|" $ XComGameInfo(outer).ModNames[i] $ "\"", verboseLog, 'ModBridge');
			break;
		}
	}

}

function string StrValue0(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return StrValue0= \"" $ valStrValue0 $ "\"", verboseLog, 'ModBridge');

		return valStrValue0;
	}
	else
	{

		`Log("\"" $ GetCallingMod() $ "\" accessed store StrValue0= \"" $ str $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue0 = str;
		return "";
	}
}

function string StrValue1(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return StrValue1= \"" $ valStrValue1 $ "\"", verboseLog, 'ModBridge');

		return valStrValue1;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store StrValue1= \"" $ str $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue1 = str;
		return "";
	}
}

function string StrValue2(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return StrValue2= \"" $ valStrValue2 $ "\"", verboseLog, 'ModBridge');

		return valStrValue2;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store StrValue2= \"" $ str $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valStrValue2 = str;
		return "";
	}
}

function int IntValue0(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return IntValue0= \"" $ string(valIntValue0) $ "\"", verboseLog, 'ModBridge');

		return valIntValue0;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store IntValue0= \"" $ string(I) $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue0 = I;
		return 0;
	}
}

function int IntValue1(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return IntValue1= \"" $ string(valIntValue1) $ "\"", verboseLog, 'ModBridge');
		return valIntValue1;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store IntValue1= \"" $ string(I) $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue1 = I;
		return 0;
	}
}

function int IntValue2(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return IntValue2= \"" $ string(valIntValue2) $ "\"", verboseLog, 'ModBridge');

		return valIntValue2;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store IntValue2= \"" $ string(I) $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valIntValue2 = I;
		return 0;
	}
}

function array<string> arrStrings(optional array<string> arrStr, optional bool bForce)
{

	local string sArray;

	if(arrStr.Length == 0 && !bForce)
	{
		JoinArray(valArrStr, sArray);
		`Log("\"" $ GetCallingMod() $ "\" accessed return arrStrings= \"" $ sArray $ "\"", verboseLog, 'ModBridge');

		return valArrStr;
	}
	else
	{
		JoinArray(arrStr, sArray);
		`Log("\"" $ GetCallingMod() $ "\" accessed store arrStrings= \"" $ sArray $ "\", bForce=" @ string(bForce), verboseLog, 'ModBridge');

		valArrStr = arrStr;
		arrStr.Length = 0;
		return arrStr;
	}

}

function array<int> arrInts(optional array<int> arrInt, optional bool bForce)
{

	local int I;
	local string sArray;

	if(arrInt.Length == 0 && !bForce)
	{
		if(verboseLog)
		{
			for(I=0; I < valArrInt.Length; I++)
			{
				if(sArray != "")
				{
					sArray $= ", ";
				}
				sArray $= string(valArrInt[I]);
			}
			`Log("\"" $ GetCallingMod() $ "\" accessed return arrInts= \"" $ sArray $ "\"", true, 'ModBridge');
		}
		return valArrInt;
	}
	else
	{
		if(verboseLog)
		{
			for(I=0; I < arrInt.Length; I++)
			{
				if(sArray != "")
				{
					sArray $= ", ";
				}
				sArray $= string(arrInt[I]);
			}
			`Log("\"" $ GetCallingMod() $ "\" accessed store arrInts= \"" $ sArray $ "\", bForce=" @ string(bForce), true, 'ModBridge');
		}
		valArrInt = arrInt;
		arrInt.Length = 0;
		return arrInt;
	}
}

//Force it to be blank by not specifying first parameter: ModBridge.TMenu(, true); /* 1B <TMenu> 0B 27 16 */
function TTableMenu TMenu(optional TTableMenu menu, optional bool bForce)
{
	local TTableMenu lMenu;

	if(menu == lMenu && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return TMenu", verboseLog, 'ModBridge');
		return valTMenu;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store TMenu", verboseLog, 'ModBridge');
		valTMenu = menu;
		return lMenu;
	}
}


function XComMod Mods(string ModName, optional string funtName, optional string paras)
{

	local int i;
	local string mod;
	local XComMod XMod;
	local bool bFound;


	`Log("funtName= \"" $ funtName $ "\", paras= \"" $ paras $ "\"", verboseLog, 'ModBridge');


	if(ModName == "")
	{
		`Log("Error, ModName not specified", true, 'ModBridge');
		return none;
	}

	if(verboseLog && (int(ModName) > 0))
	{
		if(int(ModName) > MBMods.Length)
		{
			mod = "XComMod|" $ XComGameInfo(Outer).ModNames[int(ModName)-MBMods.Length];
		}
		else
		{
			mod = "ModBridge|" $ string(MBMods[int(ModName)].Class.GetPackageName()) $ "." $ string(MBMods[int(ModName)].Class);
		}
		`Log("Mod number" @ ModName @ "is \"" $ mod $ "\"", true, 'ModBridge');
	}
	else
	{
		if(ModName == "AllMods")
		{
			bFound = true;
		}
		else
		{
			foreach MBMods(XMod)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					bFound = true;
					break;
				}
			}
		}

		if(!bFound)
		{
			if(XComGameInfo(outer).ModNames.Find(ModName) != -1)
			{
				bFound = true;
			}
		}

		if(!bFound)
		{
			`Log("Error, ModName \"" $ ModName $ "\" not found", true, 'ModBridge');
			return returnvalue;
		}

		if(verboseLog && (ModName != "AllMods"))
		{
			bFound = false;
			foreach MBMods(XMod, i)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					bFound = true;
					break;
				}
			}
			if(!bFound)
			{
				i = XComGameInfo(outer).ModNames.Find(ModName) + MBMods.Length;
			}

			`Log("Mod \"" $ ModName $ "\" is mod number" @ string(i), true, 'ModBridge');
		}

		if(!(funtName == " " || funtName == ""))
		{
			functionName = funtName;
			functParas = paras;
			if(ModName == "AllMods")
			{
				`Log("Looping over all Mods", verboseLog, 'ModBridge');
				ModsStartMatch();
			}
			else
			{
				bFound = false;
				foreach MBMods(XMod, i)
				{
					if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
					{
						mod = "ModBridge|" $ string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class);
						`Log("Executing \"" $ mod $ "\":StartMatch", verboseLog, 'ModBridge');
						MBMods[i].StartMatch();
						bFound = true;
						break;
					}
				}
				if(!bFound)
				{
					if(XComGameInfo(outer).ModNames.Find(ModName) != -1)
					{
						`Log("Executing \"" $ "XComGameInfo|" $ ModName $ "\":StartMatch", verboseLog, 'ModBridge');
						XComGameInfo(outer).Mods[XComGameInfo(outer).ModNames.Find(ModName)].StartMatch();
					}
				}
			}
			return none;
		}
		else
		{
			foreach MBMods(XMod, i)
			{
				if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
				{
					mod = "ModBridge|" $ string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class);
					`Log("Return Mod, \"" $ mod $ "\"", verboseLog, 'ModBridge');

					return MBMods[i];
				}
			}

			foreach XComGameInfo(outer).ModNames(mod, i)
			{
				if(ModName == mod)
				{
					`Log("Return Mod, \"" $ "XComGameInfo|" $ mod $ "\"", verboseLog, 'ModBridge');

					return XComGameInfo(outer).Mods[i];
				}
			}
		}
	}
	`Log("Error: end of ModBridge.Mods function, this shouldn't appear, please contact ModBridge maintainer", true, 'ModBridge');
}