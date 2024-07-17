class ModBridgeConsole extends Console;

struct removeCommand
{
	var string Command;
	var int num;
};

var private bool CulDone;
var private array<int> CulIndices;
var private array<string> CommandsToRemove;

function UpdateCompleteIndices()
{
	local int i;

	super.UpdateCompleteIndices();
	
	if(!CulDone)
	{
		for(i=0; i<CommandsToRemove.Length; i++)
		{
			RemoveDupCommands(CommandsToRemove[i]);
			//RemoveDupCommands("SwitchCheatManager");
			//RemoveDupCommands("TestModBridge");
		}
		
		CulDone = true;
	}

	for(i=0; i<CulIndices.Length; i++)
	{
		AutoCompleteIndices.RemoveItem(CulIndices[i]);
	}
}

function RemoveDupCommands(string Command)
{
	local int i;
	local bool bIsNotFirst;

	for(i=0; i<AutoCompleteList.Length; i++)
	{
		if(InStr(AutoCompleteList[i].Command, Command) != -1)
		{
			if(bIsNotFirst)
			{
				CulIndices.AddItem(i);
			}
			bIsNotFirst = true;
		}
	}
}

DefaultProperties
{
}
