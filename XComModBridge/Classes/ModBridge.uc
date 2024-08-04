Class ModBridge extends XComMod
	dependson(ModBridgeMod)
	config(ModBridge);

struct RecordRecord
{
	var array<string> Tactical;
	var array<string> Transport;
	var array<string> Strategy;
};

struct RecordDestory
{
	var array<bool> Tactical;
	var array<bool> Transport;
	var array<bool> Strategy;
};

struct RecordNotDestory
{
	var array<bool> Tactical;
	var array<bool> Transport;
	var array<bool> Strategy;
};

struct hooksub
{
	var array<string> hookname;
	var array< delegate<ModBridgeMod.hookType> > funcRef;
};

var string valStrValue0;
var string valStrValue1;
var string valStrValue2;
var int valIntValue0;
var int valIntValue1;
var int valIntValue2;
var array<string> valArrStr;
var array<int> valArrInt;
var TTableMenu valTMenu;
var Object valObject;
var string functionName;
var string functParas;

var private bool m_bFromSLoad;
var private bool m_bFromTLoad;

var string ModInitError;
var bool bModReturn;
var class<CheatManager> ModCheatClass;

var private array<ModBridgeMod> MBMods;
var private ModBridgeCheckpoint MBCheckpoint;
var private ModBridgeCheckpoint MBCheckpointWaitingForLoad;
var private array<ModBridgeMod> LoadedMods;
var private array<string> LoadedModNames;
var private array<string> ModAddedBy;
var private RecordRecord RecordAddedBy;
var private RecordDestory DestoryRecords;
var private RecordNotDestory NotDestoryRecords;

var config bool verboseLog;

var private config array<string> ModList;

var array<hooksub> hooksubs;
var ModBridgeConsole MBConsole;

function WorldInfo WorldInfo()
{
	return class'Engine'.static.GetCurrentWorldInfo();
}

function protected InitModBridgeVals(ModBridgeMod Mod)
{
	valStrValue0    	= Mod.valStrValue0;
	valStrValue1    	= Mod.valStrValue1;
	valStrValue2    	= Mod.valStrValue2;
	valIntValue0    	= Mod.valIntValue0;
	valIntValue1    	= Mod.valIntValue1;
	valIntValue2    	= Mod.valIntValue2;
	valArrStr		= Mod.valArrStr;
	valArrInt		= Mod.valArrInt;
	valTMenu		    = Mod.valTMenu;
	valObject       = Mod.valObject;
	functionName	    = Mod.functionName;
	functParas		= Mod.functParas;
	ModInitError    	= Mod.ModInitError;
	bModReturn		= Mod.bModReturn;
	ModCheatClass	= Mod.ModCheatClass;
	verboseLog		= Mod.verboseLog;
}

function InitModVals(ModBridgeMod Mod)
{
	local string CallingMod;
	local int index;
	local bool bFound;

	CallingMod = GetCallingMod();

	if(Left(CallingMod, InStr(CallingMod, ":")) != "XComModBridge.ModBridge")
	{
		if(Left(CallingMod, InStr(CallingMod, ".")) != string(Mod.Class.GetPackageName))
		{
			for(index=0; index<MBMods.Length; index++)
			{
				if(MBMods[index] == Mod)
				{
					if(Left(CallingMod, InStr(CallingMod, ".")) == ModAddedBy[index])
					{
						bFound = true;
					}
					break;
				}
			}
			if(!bFound)
			{
				`Log("Error \"" $ CallingMod $ "\" is unathorised to InitModVals for \"" $ Mod $ "\"", verboseLog, 'ModBridge');
				return;
			}
		}
	}

	Mod.valStrValue0 	= valStrValue0;
	Mod.valStrValue1 	= valStrValue1;
	Mod.valStrValue2 	= valStrValue2;
	Mod.valIntValue0 	= valIntValue0;
	Mod.valIntValue1 	= valIntValue1;
	Mod.valIntValue2 	= valIntValue2;
	Mod.valArrStr		= valArrStr;
	Mod.valArrInt 		= valArrInt;
	Mod.valTMenu 		= valTMenu;
	Mod.valObject       = valObject;
	Mod.functionName 	= functionName;
	Mod.functParas 		= functParas;
	Mod.m_bFromSLoad    = m_bFromSLoad;
	Mod.m_bFromTLoad    = m_bFromTLoad;
	Mod.ModCheatClass 	= ModCheatClass;
	Mod.MBMods 			= MBMods;
	Mod.ModList 		    = ModList;
	Mod.verboseLog 		= verboseLog;

	`Log("InitModVals for \"" $ Mod $ "\" done by \"" $ CallingMod $ "\"", verboseLog, 'ModBridge');
}

function StartMatch()
{
	local ModBridgeMod Mod;
	local string ModName, CalledBy;
	local int i;
	local bool bFound;

	CalledBy = GetCallingMod();

	if(CalledBy != "XComGame.XComGameInfo:InitGame")
	{
		`Log("Error, \"" $ CalledBy $ "\" unautherised to Init ModBridge", verboseLog, 'ModBridge');
		return;
	}

	GetLoadStatus();

	if(MBMods.Length > 0)
	{
		`log("Mod list dirty, performing cleanup", verboseLog, 'ModBridge');
		foreach MBMods(Mod)
		{
			if(Mod != none)
			{
				`Log("Destorying " $ `ShowVar(Mod), verboseLog, 'ModBridge');
				Mod.Destroy();
			}
			if(Mod != none)
			{
				`Log(`ShowVar(Mod) $ " not currently destroyed", verboseLog, 'ModBridge');
			}
		}
		MBMods.Length = 0;
	}

	class'Engine'.static.GetCurrentWorldInfo().Game.SetTimer(1.0f, true, 'OverwriteCheatClass', self);

	AssignMods();

	`Log("Start ModInit", verboseLog, 'ModBridge');
	functionName = "ModInit";

	foreach MBMods(Mod, i)
	{
		if(Mod == none)
			continue;

		ModInitError = "";
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log(ModName @ "ModInit attempt", verboseLog, 'ModBridge');

		InitModVals(MBMods[i]);
		MBMods[i].StartMatch();
		MBMods[i].ModInit();
		InitModBridgeVals(MBMods[i]);
			
		`Log(ModName $ ", ModInitError= \"" $ ModInitError $ "\"", ModInitError != "", 'ModBridge');
		`Log(ModName @ "ModInit Successful", (verboseLog && (ModInitError == "")), 'ModBridge');
	}

	foreach XComGameInfo(Outer).ModNames(ModName, i)
	{
		foreach MBMods(Mod)
		{
			bFound = false;
			if(Mod != none && ModName == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
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

	ModRecordActor("Transport", class'ModBridgeCheckpoint');
	
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

function SetHookSub(string hookname, delegate<ModBridgeMod.hookType> funcRef)
{
	local string CallingMod;
	local int i, modnum;
	local ModBridgeMod Mod;

	CallingMod = GetCallingMod(4);
	CallingMod = Left(CallingMod, InStr(CallingMod, ":"));
	
	modnum = -1;	

	`Log(`ShowVar(CallingMod));

	foreach MBMods(Mod, i)
	{
		`Log("Mod:'" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class) $ "'");
		if(CallingMod == (string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class)))
		{
			modnum = i;
			break;
		}
	}
	
	if(modnum == -1)
	{
		`log("Error, Mod not found in SetHookSub",, 'ModBridge');
		return;
	}

	if(hooksubs.Length < modnum+1)
	{
		hooksubs.Length = modnum+1;
	}

	hooksubs[modnum].hookname.AddItem(hookname);
	hooksubs[modnum].funcRef.AddItem(funcRef);

}

function SetModList(array<ModBridgeMod> MBList)
{
	if(GetCallingMod() == "XComModBridge.ModBridgeActor:GetModList")
	{
		MBMods = MBList;
	}
	else
	{
		`Log("Error, \"" $ GetCallingMod() $ "is unautherised to SetModList",, 'ModBridge');
	}
}

function ModError(string Error)
{
	`Log("Mod Function \"" $ GetCallingMod() $ "\" Error=" @ Error,, 'ModBridge');
}

function bool ModRecordActor(string Checkpoint, class<Actor> ActorClasstoRecord, optional bool bDontDestory, optional bool bDoNotDestory)
{
	local bool bFound;
	local string ModPackage;

	/*

	ModPackage = GetCallingMod();
	ModPackage = Left(ModPackage, InStr(ModPackage, "."));

	if(Checkpoint ~= "Tactical")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to TacticalGame Checkpoint", verboseLog, 'ModBridge');


		if(class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Find(ActorClasstoRecord) != -1)
			bFound = true;

		if(!bFound)
		{
			class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
			if(ClassIsChildOf(ActorClasstoRecord, class'ModBridgeMod'))
				MBCheckpoint.Checkpoint_TacticalGameClasses.AddItem(class<ModBridgeMod>(ActorClasstoRecord));
			RecordAddedBy.Tactical[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] = ModPackage;
			if(!bDontDestory)
			{
				class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToDestroy.AddItem(ActorClasstoRecord);
				DestoryRecords.Tactical[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] = true;
			}
			if(bDoNotDestory)
			{
				class'Mod_Checkpoint_TacticalGame'.default.ActorClassesNotToDestroy.AddItem(ActorClasstoRecord);
				NotDestoryRecords.Tactical[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] = true;
			}
			MBCheckpoint.RecordAddedBy = RecordAddedBy;
		}

		if(bFound || class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Length-1] == ActorClasstoRecord)
			return true;

	}
	else if(Checkpoint ~= "Transport")
	{
		`Log("Adding Actor Class \"" $ string(ActorClasstoRecord) $ "\" to StrategyTransport Checkpoint", verboseLog, 'ModBridge');

		
		if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Find(ActorClasstoRecord) != -1)
			bFound = true;

		if(!bFound)
		{
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
			if(ClassIsChildOf(ActorClasstoRecord, class'ModBridgeMod'))
				MBCheckpoint.Checkpoint_StrategyTransportClasses.AddItem(class<ModBridgeMod>(ActorClasstoRecord));
			RecordAddedBy.Transport[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] = ModPackage;
			if(!bDontDestory)
			{
				class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.AddItem(ActorClasstoRecord);
				DestoryRecords.Transport[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] = true;
			}
			if(bDoNotDestory)
			{
				class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesNotToDestroy.AddItem(ActorClasstoRecord);
				NotDestoryRecords.Transport[class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Length-1] = true;
			}
			MBCheckpoint.RecordAddedBy = RecordAddedBy;
		}
			                                                                                                
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
			{
				class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.AddItem(ActorClasstoRecord);
				if(ClassIsChildOf(ActorClasstoRecord, class'ModBridgeMod'))
					MBCheckpoint.Checkpoint_StrategyGameClasses.AddItem(class<ModBridgeMod>(ActorClasstoRecord));
				RecordAddedBy.Strategy[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] = ModPackage;
				if(!bDontDestory)
				{
					class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToDestroy.AddItem(ActorClasstoRecord);
					DestoryRecords.Strategy[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] = true;
				}
				if(bDoNotDestory)
				{
					class'Mod_Checkpoint_StrategyGame'.default.ActorClassesNotToDestroy.AddItem(ActorClasstoRecord);
					NotDestoryRecords.Strategy[class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Length-1] = true;
				}
				MBCheckpoint.RecordAddedBy = RecordAddedBy;
			}

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

	return false;

	*/
}

function ModRemoveRecordedActor(string Checkpoint, class<actor> ActorClassToRemove)
{
	/*

	local int index;
	local string modpackage;
	local bool bSuccess, indexFound;
	
	modpackage = GetCallingMod();
	modpackage = Left(modpackage, InStr(modpackage, "."));

	if(Checkpoint ~= "Tactical")
	{
		index = class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Find(ActorClassToRemove);
		
		if(index != -1)
		{
			indexFound = true;

			if(string(ActorClassToRemove.GetPackageName()) == modpackage || RecordAddedBy.Tactical[index] == modpackage)
			{
				`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from TacticalGame Checkpoint", verboseLog, 'ModBridge');

				class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord[index] = none;
				if(ClassIsChildOf(ActorClasstoRemove, class'ModBridgeMod') && MBCheckpoint.Checkpoint_TacticalGameClasses.Find(class<ModBridgeMod>(ActorClassToRemove)) != -1)
					MBCheckpoint.Checkpoint_TacticalGameClasses.RemoveItem(class<ModBridgeMod>(ActorClassToRemove));
				if(NotDestoryRecords.Tactical[index])
				{
					class'Mod_Checkpoint_TacticalGame'.default.ActorClassesNotToDestroy.RemoveItem(ActorClassToRemove);
					NotDestoryRecords.Tactical[index] = false;
				}
				DestoryRecords.Tactical[index] = false;
				RecordAddedBy.Tactical[index] = "";
				MBCheckpoint.RecordAddedBy = RecordAddedBy;
				bSuccess = true;
			}
		}
		
	}
	else if(Checkpoint ~= "Transport")
	{
		index = class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Find(ActorClassToRemove);
		
		if(index != -1)
		{
			indexFound = true;

			if(string(ActorClassToRemove.GetPackageName()) == modpackage || RecordAddedBy.Transport[index] == modpackage)
			{
				`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from StrategyTransport Checkpoint", verboseLog, 'ModBridge');

				class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.RemoveItem(ActorClassToRemove);
				if(ClassIsChildOf(ActorClasstoRemove, class'ModBridgeMod') && MBCheckpoint.Checkpoint_StrategyTransportClasses.Find(class<ModBridgeMod>(ActorClassToRemove)) != -1)
					MBCheckpoint.Checkpoint_StrategyTransportClasses.RemoveItem(class<ModBridgeMod>(ActorClassToRemove));
				if(NotDestoryRecords.Transport[index])
				{
					class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesNotToDestroy.RemoveItem(ActorClassToRemove);
					NotDestoryRecords.Transport[index] = false;
				}
				DestoryRecords.Transport[index] = false;
				RecordAddedBy.Transport[index] = "";
				MBCheckpoint.RecordAddedBy = RecordAddedBy;
				bSuccess = true;
			}
		}
	}
	else if(Checkpoint ~= "Strategy")
	{
		if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
		{
			index = class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Find(ActorClassToRemove);
		
			if(index != -1)
			{
				indexFound = true;

				if(string(ActorClassToRemove.GetPackageName()) == modpackage || RecordAddedBy.Strategy[index] == modpackage)
				{
					`Log("Removing Actor Class \"" $ string(ActorClassToRemove) $ "\" from StrategyGame Checkpoint", verboseLog, 'ModBridge');

					class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.RemoveItem(ActorClassToRemove);
					if(ClassIsChildOf(ActorClasstoRemove, class'ModBridgeMod') && MBCheckpoint.Checkpoint_StrategyGameClasses.Find(class<ModBridgeMod>(ActorClassToRemove)) != -1)
						MBCheckpoint.Checkpoint_StrategyGameClasses.RemoveItem(class<ModBridgeMod>(ActorClassToRemove));
					if(NotDestoryRecords.Strategy[index])
					{
						class'Mod_Checkpoint_StrategyGame'.default.ActorClassesNotToDestroy.RemoveItem(ActorClassToRemove);
						NotDestoryRecords.Strategy[index] = false;
					}
					DestoryRecords.Strategy[index] = false;
					RecordAddedBy.Strategy[index] = "";
					MBCheckpoint.RecordAddedBy = RecordAddedBy;
					bSuccess = true;
				}
			}
		}
		else
		{
			`Log("ModRemoveRecordedActor failed, Strategy Checkpoint specified while not in StrategyGame.", verboseLog, 'ModBridge');
			return;
		}
	}
	else
	{ 
		`Log("ModRemoveRecordedActor failed, invaild Checkpoint type specified.", verboseLog, 'ModBridge');
	}

	if(!bSuccess)
	{
		if(indexFound)
		{
			`Log("Error, \"" $ modpackage $ "\" is unauthorised to Remove Actor \"" $ string(ActorClassToRemove) $ "\" from Record List",, 'ModBridge');
		}
		else
		{
			`Log("ModRemoveRecordedActor failed, Actor not found in specified Checkpoint Record List", verboseLog, 'ModBridge');
		}
	}
	*/
}

function ModRemoveDestoryActor(string Checkpoint, class<actor> ActorClassToRemove)
{
	/*
	if(Checkpoint ~= "Tactical")
	{
		if(class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToRecord.Find(ActorClassToRemove) == -1)
			class'Mod_Checkpoint_TacticalGame'.default.ActorClassesToDestroy.RemoveItem(ActorClassToRemove);
	}
	else if(Checkpoint ~= "Transport")
	{
		if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToRecord.Find(ActorClassToRemove) == -1)
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.RemoveItem(ActorClassToRemove);

	}
	else if(Checkpoint ~= "Strategy")
	{
		if(XComHeadquartersGame(XComGameInfo(Outer)) != none)
		{
			if(class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToRecord.Find(ActorClassToRemove) == -1)
				class'Mod_Checkpoint_StrategyGame'.default.ActorClassesToDestroy.RemoveItem(ActorClassToRemove);
		}

	}
	*/
}

function bool AddModToList(ModBridgeMod ModToAdd)
{
	local string modpackage;

	modpackage = GetCallingMod();
	modpackage = Left(modpackage, InStr(modpackage, "."));
	
	if(ModToAdd != none)
	{
		if(MBMods.Find(ModToAdd) == -1)
		{
			`log("Mod \"" $ string(ModToAdd.Class.GetPackageName()) $ "." $ string(ModToAdd.Class) $ "\" added to modlist by \"" $ modpackage $ "\"", verboseLog, 'ModBridge');
		
			MBMods.AddItem(ModToAdd);
			ModAddedBy[MBMods.Length-1] = modpackage;
			return true;
		}
		else
		{
			`log("Mod \"" $ string(ModToAdd.Class.GetPackageName()) $ "." $ string(ModToAdd.Class) $ "\" attempted to be added to modlist by \"" $ modpackage $ "\" was skipped because it is already in modlist", verboseLog, 'ModBridge');
			return true;
		}
	}
	else
	{
		`log("Failed to Add Mod to list by \"" $ modpackage $ "\" ModToAdd == none",, 'ModBridge');
		return false;
	}
}

function bool RemoveModFromList(ModBridgeMod ModToRemove)
{
	local string modpackage;
	local int modposition;

	modpackage = GetCallingMod();
	modpackage = Left(modpackage, InStr(modpackage, "."));
	
	if(ModToRemove != none)
	{
		modposition = MBMods.Find(ModToRemove);
		if(modposition != -1)
		{
			if(string(ModToRemove.Class.GetPackageName()) == modpackage || ModAddedBy[modposition] == modpackage)
			{
				`log("Mod \"" $ string(ModToRemove.Class.GetPackageName()) $ "." $ string(ModToRemove.Class) $ "\" removed from modlist by \"" $ modpackage $ "\"", verboseLog, 'ModBridge');
				
				MBMods[modposition] = none;
				ModAddedBy[modposition] = "";
				return true;
			}
			else
			{
				`log("Mod \"" $ string(ModToRemove.Class.GetPackageName()) $ "." $ string(ModToRemove.Class) $ "\" attempted to be removed from modlist by \"" $ modpackage $ "\" failed because instigator is unautherized",, 'ModBridge');
				return false;
			}
		}
		else
		{
			`log("Mod \"" $ string(ModToRemove.Class.GetPackageName()) $ "." $ string(ModToRemove.Class) $ "\" attempted to be removed from modlist by \"" $ modpackage $ "\" was skipped because it is not in modlist", verboseLog, 'ModBridge');
			return true;
		}
	}
	else
	{
		`log("Failed to remove mod from list by \"" $ modpackage $ "\" ModToRemove == none",, 'ModBridge');
		return false;
	}

}

function GetLoadStatus()
{
	local XComOnlineEventMgr OEM;

	`log("Started GetLoadStatus", verboseLog, 'ModBridge');

	OEM = XComOnlineEventMgr(GameEngine(class'Engine'.static.GetEngine()).OnlineEventManager);

	m_bFromSLoad = OEM.bPerformingStandardLoad;
	m_bFromTLoad = OEM.bPerformingTransferLoad;

	if(m_bFromSLoad || m_bFromTLoad)
	{
		`log("loaded game detected", verboseLog, 'ModBridge');
		
		MBCheckpoint = WorldInfo().Spawn(class'ModBridgeCheckpoint');
	}
	else
	{
		`log("not loaded game, spawning MBCheckpoint", verboseLog, 'ModBridge');
		MBCheckpoint = WorldInfo().Spawn(class'ModBridgeCheckpoint');
	}
	
	`log(`ShowVar(MBCheckpoint), verboseLog, 'ModBridge');
	
}


/**
 * Overwrites currently used cheat classes with ModBridge ones. 
 * Used to replace base classes on init or to go back to modbridge defaults.
 */
function OverwriteCheatClass()
{
	local WorldInfo WI;
	local PlayerController PC;
	local Engine GameEngine;

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

	//WorldInfo().Game.SetTimer(1.0, true, 'RDC', self);

	GameEngine = class'Engine'.static.GetEngine();

	GameEngine.ConsoleClass = class'ModBridgeConsole';
	GameEngine.ConsoleClassName = "XComModBridge.ModBridgeConsole";
	MBConsole = new (GameEngine.GameViewport) class'ModBridgeConsole';
	GameEngine.GameViewport.ViewportConsole = MBConsole;
	GameEngine.GameViewport.InsertInteraction(MBConsole, 0);
}

function RDC()
{
	if(LocalPlayer(WorldInfo().GetALocalPlayerController().Player).ViewportClient.ViewportConsole.AutoCompleteList.Length > 0)
	{
		RemoveDupCommands("SwitchCheatManager");
		RemoveDupCommands("TestModBridge");
	}
}

function RemoveDupCommands(string Command)
{
	local WorldInfo WI;
	local PlayerController PC;
	local int i, j, len;

	WI = class'Engine'.static.GetCurrentWorldInfo();
	PC = WI.GetALocalPlayerController();
	len = LocalPlayer(PC.Player).ViewportClient.ViewportConsole.AutoCompleteList.Length;

	if(WI.Game.IsTimerActive('RDC', self))
	{
		WI.Game.ClearTimer('RDC', self);
	}
	
	for(i=0; i<len; i++)
	{
		if(j == 3)
			break;
		if(InStr(LocalPlayer(PC.Player).ViewportClient.ViewportConsole.AutoCompleteList[i].Command, Command) != -1)
		{
			LocalPlayer(PC.Player).ViewportClient.ViewportConsole.AutoCompleteList.Remove(i, 1);
			++ j;
			-- i;
		}
	}
}

/**
 * Swtiches which CheatManager Object the game uses to look for exec functions.
 * 
 * @param modpackage    Specifies which mod package to search in to look for Cheat class. case sensitive.
 */
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
		if(Mod != none && string(Mod.Class.GetPackageName()) == modpackage)
		{
			bFound = true;
			break;
		}
	}
	if(!bFound)
	{
		foreach XComGameInfo(Outer).Mods(XMod)
		{
			if(XMod != none && XMod != self && string(XMod.Class.GetPackageName()) == modpackage)
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
					InitModVals(Mod);
					Mod.StartMatch();
					InitModBridgeVals(Mod);
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
				InitModVals(Mod);
				Mod.StartMatch();
				InitModBridgeVals(Mod);
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
				InitModVals(Mod);
				Mod.StartMatch();
				InitModBridgeVals(Mod);
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

/** 
 * Returns the actor with same spawn name as the specified string.
 * Is fastest if you specify the BaseClass and iterator.
 * Will normally need to be casted to access members (even if BaseClass specified).
 * 
 * @param ActorName   The spawn name of the Actor that will be returned.
 * @param BaseClass   The Actor type to search for. 
 * @param Iterator    (optional) the Iterator to get your Actor. options are: "Dynamic" (default), "All" (slowest), "Based" (fastest).
 * @return            The Actor that was found with the same spawn name as in ActorName.
 */
function Actor GetActor(string ActorName, class<Actor> BaseClass, optional string Iterator = "Dynamic")
{
    local Actor kActor, tempActor;

    if(Iterator == "Dynamic")
    {
        foreach WorldInfo().DynamicActors(BaseClass, kActor)
        {
            if(string(kActor) == ActorName)
            {
                return kActor;
            }
        }
    }
    else if(Iterator == "All")
    {
        foreach WorldInfo().AllActors(BaseClass, kActor)
        {
            if(string(kActor) == ActorName)
            {
                return kActor;
            }
        }
    }
    else if(Iterator == "Based")
    {
        tempActor = WorldInfo().Spawn(BaseClass);
        foreach tempActor.BasedActors(BaseClass, kActor)
        {
            if(string(kActor) == ActorName)
            {
                tempActor.Destroy();
                return kActor;
            }
        }
        tempActor.Destroy();
    }
    else
    {
        `Log("GetActor failed, invalid Iterator specified", verboseLog, 'ModBridge');
    }
}

function string GetCallingMod(optional int backlevels = 3)
{
	local array<string> arrStr;

	arrStr = class'Object'.static.SplitString(GetScriptTrace(), "Function ");
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
		`Log( "Loading \"" $ "ModBridge|" $ ModName $ "\" into modlist", verboseLog, 'ModBridge');
		Mod = WorldInfo().Spawn(class<ModBridgeMod>(DynamicLoadObject(ModName, class'Class')));

		`Log( "Error \"" $ "ModBridge|" $ ModName $ "\" could not be loaded correctly", Mod == none, 'ModBridge');
		
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

function ModsStartMatch(string funcName, string paras)
{

	local ModBridgeMod Mod;
	local string ModName;
	local int i;

	
	bModReturn = false;
	foreach MBMods(Mod, i)
	{
		if(Mod == none)
			continue;
		
		functionName = funcName;
		functParas = paras;
		ModName = "ModBridge|" $ string(Mod.Class.GetPackageName()) $ "." $ string(Mod.Class);
		`Log("Executing StartMatch function in \"" $ ModName $ "\"", verboseLog, 'ModBridge');
		InitModVals(MBMods[i]);
		MBMods[i].StartMatch();
		InitModBridgeVals(MBMods[i]);
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
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(sArray, arrStrings), verboseLog, 'ModBridge');

		return valArrStr;
	}
	else
	{
		JoinArray(arrStr, sArray);
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(sArray, arrStrings) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');

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
			`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(sArray, arrInts),, 'ModBridge');
		}
		return valArrInt;
	}
	else
	{
		if(verboseLog)
		{
			for(I=0; I<arrInt.Length; I++)
			{
				if(sArray != "")
				{
					sArray $= ", ";
				}
				sArray $= string(arrInt[I]);
			}
			`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(sArray, arrInts) $ ", " $ `ShowVar(bForce),, 'ModBridge');
		}
		valArrInt = arrInt;
		arrInt.Length = 0;
		return arrInt;
	}
}

function Object Object(optional Object inObj, optional bool bForce)
{
	if(inObj == none && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(valObject, Object), verboseLog, 'ModBridge');
		return valObject;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(inObj, Object) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge');
		valObject = inObj;
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

function hooksubtest(string hookname, optional string funcName, optional string paras)
{
	local int i, j;

	for(i=0; i<hooksubs.Length; i++)
	{
		for(j=0; j<hooksubs[i].hookname.Length; j++)
		{
			if(hooksubs[i].hookname[j] == hookname)
			{
				MBMods[i].hook = hooksubs[i].funcRef[j];
				MBMods[i].hook(funcName, paras);
			}
		}
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
		`Log("Error, ModName not specified",, 'ModBridge');
		ScriptTrace();
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
			`Log("Mod number" @ ModName @ "is out of range",, 'ModBridge');
			ScriptTrace();
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
				if(MBMod != none && ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
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
			`Log("Error, ModName \"" $ ModName $ "\" not found",, 'ModBridge');
			ScriptTrace();
			return none;
		}

		if(verboseLog && (ModName != "AllMods"))
		{
			bFound = false;
			foreach MBMods(MBMod, i)
			{
				if(MBMod != none && ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
				{
					bFound = true;
					break;
				}
			}
			if(!bFound)
			{
				i = XComGameInfo(outer).ModNames.Find(ModName) + MBMods.Length;
			}

			`Log("Mod \"" $ ModName $ "\" is mod number" @ string(i),, 'ModBridge');
		}

		if(!(funcName == " " || funcName == ""))
		{
			functionName = funcName;
			functParas = paras;
			if(ModName == "AllMods")
			{
				`Log("Looping over all Mods", verboseLog, 'ModBridge');
				ModsStartMatch(funcName, paras);
			}
			else
			{
				bFound = false;
				foreach MBMods(MBMod, i)
				{
					if(MBMod != none && ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
					{
						mod = "ModBridge|" $ string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class);
						`Log("Executing \"" $ mod $ "\":StartMatch", verboseLog, 'ModBridge');
						InitModVals(MBMods[i]);
						MBMods[i].StartMatch();
						InitModBridgeVals(MBMods[i]);
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
				if(MBMod != none && ModName == (string(MBMod.Class.GetPackageName()) $ "." $ string(MBMod.Class)))
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
	`Log("Error: end of ModBridge.Mods function, this shouldn't appear, please contact ModBridge maintainer",, 'ModBridge');
}