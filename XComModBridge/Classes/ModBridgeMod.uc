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
var delegate<hookType> hook;
var string functionName;
var string functParas;
var bool m_bFromSLoad;
var bool m_bFromTLoad;
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

function StartMatch()
{
}

function ModInit()
{
}

delegate hookType(string funcName, string paras);

function SetHookSub(string hookname, delegate<hookType> funcRef)
{
	ModBridge().SetHookSub(hookname, funcRef);
}

function ModError(string Error)
{
	ModBridge().ModError(Error);
}

function bool ModRecordActor(string Checkpoint, class<Actor> ActorClasstoRecord)
{
	return ModBridge().ModRecordActor(Checkpoint, ActorClasstoRecord);
}

function ModRemoveRecordedActor(string Checkpoint, class<actor> ActorClassToRemove)
{
	ModBridge().ModRemoveRecordedActor(Checkpoint, ActorClassToRemove);
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
	ModBridge().InitModVals(self);
	return outstr;
}

function string StrValue1(optional string str, optional bool bForce)
{
	local string outstr;

	outstr = ModBridge().StrValue1(str, bForce);
	ModBridge().InitModVals(self);
	return outstr;
}

function string StrValue2(optional string str, optional bool bForce)
{
	local string outstr;

	outstr = ModBridge().StrValue2(str, bForce);
	ModBridge().InitModVals(self);
	return outstr;
}

function int IntValue0(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue0(I, bForce);
	ModBridge().InitModVals(self);
	return outint;
}

function int IntValue1(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue1(I, bForce);
	ModBridge().InitModVals(self);
	return outint;
}

function int IntValue2(optional int I = -1, optional bool bForce)
{
	local int outint;

	outint = ModBridge().IntValue2(I, bForce);
	ModBridge().InitModVals(self);
	return outint;
}

function array<string> arrStrings(optional array<string> arrStr, optional bool bForce)
{
	local array<string> outarr;
	
	outarr = ModBridge().arrStrings(arrStr, bForce);
	ModBridge().InitModVals(self);
	return outarr;
}

function array<int> arrInts(optional array<int> arrInt, optional bool bForce)
{
	local array<int> outarr;

	outarr = ModBridge().arrInts(arrInt, bForce);
	ModBridge().InitModVals(self);
	return outarr;
}

function Object Object(optional Object inObj, optional bool bForce)
{
	local Object outObj;

	outObj = ModBridge().Object(inObj, bForce);
	ModBridge().InitModVals(self);
	return outObj;
}

function TTableMenu TMenu(optional TTableMenu menu, optional bool bForce)
{
	local TTableMenu outtmenu;

	outtmenu = ModBridge().TMenu(menu, bForce);
	ModBridge().InitModVals(self);
	return outtmenu;
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
	return ModBridge().GetActor(ActorName, BaseClass, Iterator);
}

function Object Mods(string ModName, optional string funcName, optional string paras)
{
	return ModBridge().Mods(ModName, funcName, paras);
}