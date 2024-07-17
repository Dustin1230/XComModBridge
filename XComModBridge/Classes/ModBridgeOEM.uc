class ModBridgeOEM extends XComOnlineEventMgr;

/*

event Init()
{
	super.Init();
}

event ShowPostLoadMessages()
{
	super.ShowPostLoadMessages();
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
}

private final event PreloadSaveGameData(byte LocalUserNum, bool Success, int GameNum, int SaveID)
{
	super.PreloadSaveGameData(LocalUserNum, Success, GameNum, SaveID);
}

event FillInHeaderForSave(out SaveGameHeader Header, out string SaveFriendlyName)
{
	super.FillInHeaderForSave(Header, SaveFriendlyName);
}

event OnDeleteSaveGameDataComplete(byte LocalUserNum)
{
	super.OnDeleteSaveGameDataComplete(LocalUserNum);
}

private final event DeleteSaveGameData(byte LocalUserNum, int DeviceID, string Filename)
{
	super.DeleteSaveGameData(LocalUserNum, DeviceID, Filename);
}

event OnSaveAsyncTaskComplete()
{
	super.OnDeleteSaveGameDataComplete();
}

event OnMPLoadTimeout()
{
	super.OnMPLoadTimeout();
}

private final event ReadSaveGameData(byte LocalUserNum, int DeviceID, string FriendlyName, string Filename, string SaveFileName)
{
    local OnlineContentInterface ContentInterface;

    ContentInterface = OnlineSub.ContentInterface;
    // End:0x95
    if(NotEqual_InterfaceInterface(ContentInterface, (none)))
    {
        ContentInterface.ReadSaveGameData(LocalUserNum, DeviceID, FriendlyName, Filename, SaveFileName);
    }
    //return;    
}

private final event WriteSaveGameData(byte LocalUserNum, int DeviceID, string Filename, bool IsAutosave, bool IsQuicksave, int SaveID, const out array<byte> SaveGameData, int SaveDataCRC)
{
    local OnlineContentInterface ContentInterface;
    local SaveGameHeader SaveHeader;
    local string FriendlyName;
    local bool bWritingSaveGameData;	

    ContentInterface = OnlineSub.ContentInterface;
    // End:0x191
    if(NotEqual_InterfaceInterface(ContentInterface, (none)))
    {
        StorageWriteCooldownTimer = 3.0;
        SaveHeader.bIsAutosave = IsAutosave;
        SaveHeader.bIsQuicksave = IsQuicksave;
        FillInHeaderForSave(SaveHeader, FriendlyName);

		SaveHeader.DLCPacks = SaveHeader.DLCPacks $ "-ModBridge";

        SaveHeader.SaveID = SaveID;
        SaveHeader.SaveDataCRC = SaveDataCRC;
        bWritingSaveGameData = ContentInterface.WriteSaveGameData(LocalUserNum, DeviceID, FriendlyName, Filename, Filename, SaveGameData, SaveHeader);
        // End:0x191
        if(bWritingSaveGameData)
        {
            ShowSaveIndicator();
        }
    }
    //return;   
}

*/
