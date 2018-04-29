Class ModBridge extends XComMod
 config(ModBridge);

var privatewrite string valStrValue0;
var privatewrite string valStrValue1;
var privatewrite string valStrValue2;
var privatewrite int valIntValue0;
var privatewrite int valIntValue1;
var privatewrite int valIntValue2;
var privatewrite array<string> valArrStr;
var privatewrite array<int> valArrInt;
var privatewrite TTableMenu valTMenu;
var privatewrite Object valObject;
var privatewrite string functionName;
var privatewrite string functParas;
var string ModInitError;
var bool bModReturn;
var class<CheatManager> ModCheatClass;
var array<ModBridgeMod> MBMods;
var config bool verboseLog;
var config array<string> ModList;

function WorldInfo WorldInfo()
{
	return class'Engine'.static.GetCurrentWorldInfo();
}

function InitModBridge(ModBridgeMod Mod)
{
	valStrValue0	= Mod.valStrValue0;
	valStrValue1	= Mod.valStrValue1;
	valStrValue2	= Mod.valStrValue2;
	valIntValue0	= Mod.valIntValue0;
	valIntValue1	= Mod.valIntValue1;
	valIntValue2	= Mod.valIntValue2;
	valArrStr		= Mod.valArrStr;
	valArrInt		= Mod.valArrInt;
	valTMenu		= Mod.valTMenu;
	valObject       = Mod.valObject;
	functionName	= Mod.functionName;
	functParas		= Mod.functParas;
	ModInitError	= Mod.ModInitError;
	bModReturn		= Mod.bModReturn;
	ModCheatClass	= Mod.ModCheatClass;
	verboseLog		= Mod.verboseLog;
}

function ModInit()
{
	local ModBridgeMod Mod;
	local string ModName;
	local int i;
	local bool bFound;

	if(MBMods.Length > 0)
	{
		foreach MBMods(Mod)
		{
			Mod.Destroy();
		}
		MBMods.Length = 0;
	}

	class'Engine'.static.GetCurrentWorldInfo().Game.SetTimer(1.0f, true, 'OverwriteCheatClass', self);

	AssignMods();

	`Log("Start ModInit", verboseLog, 'ModBridge');
	functionName = "ModInit";

	foreach MBMods(Mod, i)
	{
		ModInitError = "";
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log(ModName @ "ModInit attempt", verboseLog, 'ModBridge');

		MBMods[i].StartMatch();
			
		`Log(ModName $ ", ModInitError= \"" $ ModInitError $ "\"", ModInitError != "", 'ModBridge');
		`Log(ModName @ "ModInit Successful", (verboseLog && (ModInitError == "")), 'ModBridge');
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
	local bool bFound;
 
	/**
	if(Checkpoint ~= "Tactical")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to TacticalGame Checkpoint", verboseLog, 'ModBridge');


		if(class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Find(ActorClasstoRecord) != -1)
			bFound = true;

		if(!bFound)
			class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

		if(bFound || class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}
	else if(Checkpoint ~= "Transport")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to StrategyTransport Checkpoint", verboseLog, 'ModBridge');

		
		if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Find(ActorClasstoRecord) != -1)
			bFound = true;

		if(!bFound)
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
			                                                                                                
		if(bFound || class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}
	else if(Checkpoint ~= "Strategy")
	{
		if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
		{
			`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to StrategyGame Checkpoint", verboseLog, 'ModBridge');

			if(class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Find(ActorClasstoRecord) != -1)
				bFound = true;

			if(!bFound)
				class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);

			if(bFound || class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
				return true;
		}
		else
		{
			`Log("ModRecordActor failed, Strategy Checkpoint specified while not in StrategyGame.", verboseLog, 'ModBridge');
		}

	}
	else
	{
		`Log("ModRecordActor failed, invalid Checkpoint type specified.", verboseLog, 'ModBridge');
	}
	*/

	return false;
}

function ModRemoveRecordActor(string Checkpoint, class<actor> ActorClassToRemove)
{
	/** 
	if(Checkpoint ~= "Tactical")
	{
		`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from TacticalGame Checkpoint", verboseLog, 'ModBridge');

		class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Remove(ActorClassToRemove);
	}
	else if(Checkpoint ~= "Transport")
	{
		`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from StrategyTransport Checkpoint", verboseLog, 'ModBridge');

		class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Remove(ActorClassToRemove);
	}
	else if(Checkpoint ~= "Strategy")
	{
		if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
		{
			`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from StrategyGame Checkpoint", verboseLog, 'ModBridge');

			class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Remove(ActorClassToRemove);
		}
		else
		{
			`Log("ModRemoveRecordActor failed, Strategy Checkpoint specified while not in StrategyGame.", verboseLog, 'ModBridge');
		}
	}
	else
	{
		`Log("ModRemoveRecordActor failed, invaild Checkpoint type specified.", verboseLog, 'ModBridge');
	}
	*/
}




function OverwriteCheatClass()
{
	local WorldInfo WI;
	local PlayerController PC;

	WI = class'Engine'.static.GetCurrentWorldInfo();
	PC = WI.GetALocalPlayerController();

	if(PC == none)
		return;


	if(WI.Game.IsTimerActive('OverwriteCheatClass', self))
	{
		WI.Game.ClearTimer('OverwriteCheatClass', self);
		`Log("PlayerController initalised, overwriting CheatManager", verboseLog, 'ModBridge');
	}
	else
	{
		`Log("Switching to base Mod Cheat class", verboseLog, 'ModBridge');
	}

	if(PC.IsA('XComShellController'))
	{
		`Log("Shell detected, using ShellCheatManager", verboseLog, 'ModBridge');
		PC.CheatClass = class<CheatManager>(DynamicLoadObject("XComModBridge_Shell.Mod_ShellCheatManager", class'Class', true));
		PC.CheatManager = new (XComPlayerControllerNativeBase(PC)) PC.CheatClass;
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
	local ModBridgeMod Mod;
	local XComMod XMod;
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
		Mod = none;
		foreach XComGameInfo(Outer).Mods(XMod)
		{
			if(XMod != self && string(XMod.Class.GetPackageName()) == modpackage)
			{
				bFound = true;
				break;
			}
		}
	}

	if(!bFound)
	{
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
			ShellClass = class<CheatManager>(DynamicLoadObject("XComModBridge_Shell.Mod_ShellCheatManager", class'Class', true));

			if(ShellClass != none)
			{
				functParas = "Shell";
				if(Mod != none)
				{
					Mod.InitModBridge();
					Mod.StartMatch();
					InitModBridge(Mod);
				}
				else
					XMod.StartMatch();

				if(ClassIsChildOf(ModCheatClass, ShellClass))
				{
					`Log("Found CheatManager: \"" $ ModCheatClass $ "\" for Shell", verboseLog, 'ModBridge');
					PC.CheatClass = ModCheatClass;
					PC.CheatManager = new (XComPlayerControllerNativeBase(PC)) ModCheatClass;
					bFound = true;
				}
			}
		}
		else if(PC.IsA('XComHeadquartersController'))
		{
			functParas = "Strategy";
			if(Mod != none)
			{
				Mod.InitModBridge();
				Mod.StartMatch();
				InitModBridge(Mod);
			}
			else
				XMod.StartMatch();

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
			if(Mod != none)
			{
				Mod.InitModBridge();
				Mod.StartMatch();
				InitModBridge(Mod);
			}
			else
				XMod.StartMatch();

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
	local ModBridgeMod Mod;
	local XComMod XMod;
	local string ModName;
	local int i;
	local bool bFound;

	`Log("Started AssignMods", verboseLog, 'ModBridge');

	foreach ModList(ModName, i)
	{
		Mod = WorldInfo().Spawn(class<ModBridgeMod>(DynamicLoadObject(ModName, class'Class')));
		`Log( "adding \"" $ "ModBridge|" $ ModName $ "\" to modlist", verboseLog, 'ModBridge');
		MBMods[i] = Mod;
	}

	for(i=0; i<XComGameInfo(outer).ModNames.Length; i++)
	{
		ModName = XComGameInfo(outer).ModNames[i];
		bFound = false;
		foreach XComGameInfo(outer).Mods(XMod)
		{
			if(ModName == (string(XMod.Class.GetPackageName()) $ "." $ string(XMod.Class)))
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

	local ModBridgeMod Mod;
	local string ModName;
	local int i;

	
	bModReturn = false;
	foreach MBMods(Mod, i)
	{
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log("Executing StartMatch function in \"" $ ModName $ "\"", verboseLog, 'ModBridge');
		MBMods[i].InitModBridge();
		MBMods[i].StartMatch();
		InitModBridge(MBMods[i]);
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
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valStrValue0, StrValue0), verboseLog, 'ModBridge');

		return valStrValue0;
	}
	else
	{

		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(str, StrValue0) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

		valStrValue0 = str;
		return "";
	}
}

function string StrValue1(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valStrValue1, StrValue1), verboseLog, 'ModBridge');

		return valStrValue1;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(str, StrValue1) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

		valStrValue1 = str;
		return "";
	}
}

function string StrValue2(optional string str, optional bool bForce)
{
	if(str == "" && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valStrValue2, StrValue2), verboseLog, 'ModBridge');

		return valStrValue2;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(str, StrValue2) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

		valStrValue2 = str;
		return "";
	}
}

function int IntValue0(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valIntValue0, IntValue0), verboseLog, 'ModBridge');

		return valIntValue0;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(I, IntValue0) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

		valIntValue0 = I;
		return 0;
	}
}

function int IntValue1(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valIntValue1, IntValue1), verboseLog, 'ModBridge');
		return valIntValue1;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(I, IntValue1) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

		valIntValue1 = I;
		return 0;
	}
}

function int IntValue2(optional int I = -1, optional bool bForce)
{
	if((I == 0 || I == -1) && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valIntValue2, IntValue2), verboseLog, 'ModBridge');

		return valIntValue2;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(I, IntValue2) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

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
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(sArray, arrInts), verboseLog, 'ModBridge');

		return valArrStr;
	}
	else
	{
		JoinArray(arrStr, sArray);
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(sArray, arrInts) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

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
			`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(sArray, arrInts), true, 'ModBridge');
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
			`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(sArray, arrInts) $ ", " $ `ShowVar(bForce), true, 'ModBridge');
		}
		valArrInt = arrInt;
		arrInt.Length = 0;
		return arrInt;
	}
}

function Object Object(optional Object inObj, optional bool bForce)
{
	if(inObj != none && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valObject, Object), verboseLog, 'ModBridge');
		return valObject;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(inObj, Object) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');
		return none;
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


function Object Mods(string ModName, optional string funcName, optional string paras)
{

	local int i;
	local string mod;
	local ModBridgeMod MBMod;
	local bool bFound;


	`Log("funcName= \"" $ funcName $ "\", paras= \"" $ paras $ "\"", verboseLog, 'ModBridge');


	if(ModName == "")
	{
		`Log("Error, ModName not specified", true, 'ModBridge');
		return none;
	}

	if(verboseLog && (int(ModName) > 0))
	{
		if( (int(ModName) > MBMods.Length) && (int(ModName) <= (MBMods.Length + XComGameInfo(Outer).Mods.Length)) )
		{
			if(XComGameInfo(Outer).Mods[int(ModName)-MBMods.Length] != none)
				mod = "XComMod|" $ string(XComGameInfo(Outer).Mods[int(ModName)-MBMods.Length].Class.GetPackageName()) $ "." $ string(XComGameInfo(Outer).Mods[int(ModName)-MBMods.Length].Class);
			else
				mod = "none";

			bFound = true;
		}
		else if(int(ModName) <= MBMods.Length)
		{
			if(MBMods[int(ModName)] != none)
				mod = "ModBridge|" $ string(MBMods[int(ModName)].Class.GetPackageName()) $ "." $ string(MBMods[int(ModName)].Class);
			else
				mod = "none";
			
			bFound = true;
		}
		else
		{
			`Log("Mod number" @ ModName @ "is out of range", true, 'ModBridge');
		}
		`Log("Mod number" @ ModName @ "is \"" $ mod $ "\"", bFound, 'ModBridge');
		bFound = false;
	}
	else
	{
		if(ModName == "AllMods")
		{
			bFound = true;
		}
		else
		{
			foreach MBMods(MBMod)
			{
				if(ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
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
			return none;
		}

		if(verboseLog && (ModName != "AllMods"))
		{
			bFound = false;
			foreach MBMods(MBMod, i)
			{
				if(ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
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

		if(!(funcName == " " || funcName == ""))
		{
			functionName = funcName;
			functParas = paras;
			if(ModName == "AllMods")
			{
				`Log("Looping over all Mods", verboseLog, 'ModBridge');
				ModsStartMatch();
			}
			else
			{
				bFound = false;
				foreach MBMods(MBMod, i)
				{
					if(ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
					{
						mod = "ModBridge|" $ string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class);
						`Log("Executing \"" $ mod $ "\":StartMatch", verboseLog, 'ModBridge');
						MBMods[i].InitModBridge();
						MBMods[i].StartMatch();
						InitModBridge(MBMods[i]);
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
			foreach MBMods(MBMod, i)
			{
				if(ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
				{
					mod = "ModBridge|" $ string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class);
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