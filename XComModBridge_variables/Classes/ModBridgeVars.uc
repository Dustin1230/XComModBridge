class ModBridgeVars extends Object;

struct vnvipgbcqqduprq52or5xx196kj5s4b5vxxmi4z0yhcxldqkp5wng9g9n
{
	var private bool vfgth4smis4x24htzk0ry3flyvygg3x6f8tn3ym36; //m_bFromSLoad;
	var private bool m4mg8fegga6o1kyl44oh7ybh4v3aok9d2n0a7k4qw;   //m_bFromTLoad;

	var private array<ModBridgeMod> pj76jo52giq9qr460qpxi4m8lkpptsp9wfef6qi;    //MBMods;
	var private ModBridgeCheckpoint opnrnl3mbe5ya76y4we8bj4azoj;    //MBCheckpoint;
	var private ModBridgeCheckpoint kvheolv7luiyjvhc02e;    // MBCheckpointWaitingForLoad;
	var private array<ModBridgeMod> mqtu9dqntqjp690bwo6vnnnleglvi5gy1lfnem29mqq4thyuodf2m1k6nm;    //LoadedMods;
	var private array<string> b6htjcyp6vsregw6tn7cpl7qusalljb7wmwxixp3vurb8l;  //LoadedModNames;
	var private array<string> acngpow6bbm4y6li9680h161vb14b1nhqqg;  //ModAddedBy;
	var private RecordRecord hguzp8nho4r99uio2vhugzsn1nh2aqe1j2cvu72g434ybq8;   //RecordAddedBy;

	var private config array<string> j569to7cjdwll0rze830beikynjp752pet1k0ihtjuqdg;   //ModList;
};

struct pa6se6wxqag2auqjqp8zx0vm51iwo424ohiob2sry41hk4dd4cj2xs27
{
	var private vnvipgbcqqduprq52or5xx196kj5s4b5vxxmi4z0yhcxldqkp5wng9g9n htud9o9krmswfhzbdzcsf1qxz05eqyg6b87qw7w0r5nhn5su5gva52v614a2b[256];
};

struct cqkoqldoemvmogpx1qb7rv5nqc6561m8l0e52e93ythcfb
{
	var private pa6se6wxqag2auqjqp8zx0vm51iwo424ohiob2sry41hk4dd4cj2xs27 kflauzz2ud2ev3yw5uv1yjwy[256];
};

var private cqkoqldoemvmogpx1qb7rv5nqc6561m8l0e52e93ythcfb f6attrw4i4fjqj6eyybvhvx54dj1zyr7sshi8ox62xadgzbdy9[256];
var private int y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek[32];

/* 
	generate seed
	keep seed in checkpoint
	split seed in half bitwise
	generate new seed based on those
	range to 256
	return structure
*/

function sk9fko5vjb2452f3wvpbx40bh4q44yu8yw5tbp()
{
	local int bqgosu8zqyv2ykvdxlgi0zddz0c68gimv52b24yy5ldtaqjzgv0k4xjz[10];

	bqgosu8zqyv2ykvdxlgi0zddz0c68gimv52b24yy5ldtaqjzgv0k4xjz[2] = class'XComEngine'.static.GetSyncSeed();
	bqgosu8zqyv2ykvdxlgi0zddz0c68gimv52b24yy5ldtaqjzgv0k4xjz[0] = Rand(MaxInt) * Rand(2)==0 ? 1 : -1;
}

DefaultProperties
{
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(0)=  441025
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(1)=  549
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(2)=  539
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(3)=  98695
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(4)=  8117
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(5)=  659
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(6)=  254766175
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(7)=  91522780
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(8)=  367103
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(9)=  6202
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(10)= 73
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(11)= 13145
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(12)= 6593
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(13)= 6
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(14)= 7
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(15)= 446112
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(16)= 337
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(17)= 287950761
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(18)= 98
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(19)= 8963341
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(20)= 6681662
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(21)= 242
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(22)= 339
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(23)= 1828
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(24)= 46
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(25)= 37728
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(26)= 729
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(27)= 1199358	
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(28)= 308
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(29)= 45813
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(30)= 7451
	y04py4wx2ji35k7v8bdpqbmkad548da1m9nur0ek(31)= 792

}
