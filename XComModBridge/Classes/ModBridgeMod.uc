class ModBridgeMod extends Actor;

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
var string ModInitError;
var bool bModReturn;
var class<CheatManager> ModCheatClass;
var array<ModBridgeMod> MBMods;
var bool verboseLog;
var array<string> ModList;

function ModBridge ModBridge()
{
	return ModBridge(XComGameInfo(WorldInfo.Game).Mods[0]);
}

function InitModBridge()
{
	valStrValue0 	= ModBridge().valStrValue0;
	valStrValue1 	= ModBridge().valStrValue1;
	valStrValue2 	= ModBridge().valStrValue2;
	valIntValue0 	= ModBridge().valIntValue0;
	valIntValue1 	= ModBridge().valIntValue1;
	valIntValue2 	= ModBridge().valIntValue2;
	valArrStr		= ModBridge().valArrStr;
	valArrInt 		= ModBridge().valArrInt;
	valTMenu 		= ModBridge().valTMenu;
	functionName 	= ModBridge().functionName;
	functParas 		= ModBridge().functParas;
	ModCheatClass 	= ModBridge().ModCheatClass;
	MBMods 			= ModBridge().MBMods;
	ModList 		= ModBridge().ModList;
	verboseLog 		= ModBridge().verboseLog;
}

function StartMatch()
{
}

function ModError(string Error)
{
	ModBridge().ModError(Error);
}

function bool ModRecordActor(string Checkpoint, class<Actor> ActorClasstoRecord)
{
	return ModBridge().ModRecordActor(Checkpoint, ActorClasstoRecord);
}

function ModRemoveRecordActor(string Checkpoint, class<actor> ActorClassToRemove)
{
	ModBridge().ModRemoveRecordActor(Checkpoint, ActorClassToRemove);
}

function OverwriteCheatClass()
{
	ModBridge().OverwriteCheatClass();
}

function SwitchCheatManager(string modpackage)
{
	ModBridge().SwitchCheatManager(modpackage);
}

function string GetCallingMod(optional int backlevels = 3)
{
	return ModBridge().GetCallingMod(backlevels);	
}

function string StrValue0(optional string str, optional bool bForce)
{
	local string outstr;

	outstr = ModBridge().StrValue0(str, bForce);
	InitModBridge();
	return outstr;
}

function string StrValue1(optional string str, optional bool bForce)
{
	local string outstr;

	outstr = ModBridge().StrValue1(str, bForce);
	InitModBridge();
	return outstr;
}

function string StrValue2(optional string str, optional bool bForce)
{
	local string outstr;

	outstr = ModBridge().StrValue2(str, bForce);
	InitModBridge();
	return outstr;
}

function string IntValue0(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue0(I, bForce);
	InitModBridge();
	return outint;
}

function string IntValue1(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue1(I, bForce);
	InitModBridge();
	return outint;
}

function string IntValue2(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue2(I, bForce);
	InitModBridge();
	return outint;
}

function array<string> arrStrings(optional array<string> arrStr, optional bool bForce)
{
	local array<string> outarr;
	
	outarr = ModBridge().arrStrings(arrStr, bForce);
	InitModBridge();
	return outarr;
}

function array<int> arrInts(optional array<int> arrInt, optional bool bForce)
{
	local array<int> outarr;

	outarr = ModBridge().arrInts(arrInt, bForce);
	InitModBridge();
	return outarr;
}

function Object Object(optional Object inObj, optional bool bForce)
{
	local Object outObj;

	outObj = ModBridge().Object(inObj, bForce);
	InitModBridge();
	return outObj;
}

function TTableMenu TMenu(optional TTableMenu menu, optional bool bForce)
{
	local TTableMenu outtmenu;

	outtmenu = ModBridge().TMenu(menu, bForce);
	InitModBridge();
	return outtmenu;
}