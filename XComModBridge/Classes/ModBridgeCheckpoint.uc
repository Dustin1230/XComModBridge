class ModBridgeCheckpoint extends Actor;

struct CheckpointRecord
{
	var array< class<actor> > Checkpoint_TacticalGameClasses;
	var array< class<actor> > Checkpoint_StrategyTransportClasses;
	var array< class<actor> > Checkpoint_StrategyGameClasses;
	var array<string> ModAddedBy;
	var RecordRecord RecordAddedBy;
};

var array< class<actor> > Checkpoint_TacticalGameClasses;
var array< class<actor> > Checkpoint_StrategyTransportClasses;
var array< class<actor> > Checkpoint_StrategyGameClasses;
var array<string> ModAddedBy;
var RecordRecord RecordAddedBy;

DefaultProperties
{
}
