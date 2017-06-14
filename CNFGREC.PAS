Unit CNFGRec;

Interface

Uses Records;

Type
  ConfigRec = Record
    ConfigVersionCode:Byte;
{*} FullSysName,
{*} RegNumber,   { Change To: RegString }
{*} SysOpName:       Str80;
{*} UseAutoLogin,
{*} WFC50,
{*} PrivateBBS,
{*} UseDirectVideo,
{*} UseSnowCheck,
{*} UseExtMnu,
{*} UseLoginBell,
{*} UseBulletins,
{*} UseTheWall,
{*} UseFamousDay,
{*} UseEMS,
{*} MaximumDosShell,
{*} UsePrinterLog,
{*} UseStatLine      :Boolean;
    ScreenSaveMin:   integer;

{*} SysDir,
{*} MsgDir,
{*} UpLoadDir,    {XferDir}
{*} SysLogDir,
{*} SwapDir,
{*} MenuDir,
{*} DoorDir,
{*} WorkDir,
{*} NetDir,
{*} DszLog,
    DataDir,
    FileMailDir,
    MenuDataDir,

{*} PWString,
{} SysOpPW,
{} System1PW,
{} System2PW,
{} System3PW,
{} NewUserPW,
{} LockOutBaudPass,
{*} ChatPW : Str40;

{*} ModemPort:Byte;
{*} ModemINITStr,
{*} ModemHangUpStr,
{*} ModemDialStr,
{*} ModemDialSuff:   Str40;
{*} DefBaudRate,
{*} MinBaudRate:     Word;
    ModemMethod: byte;
  { 1 - Async Driver output - Faster by FAR
    2 - Fossil Driver - slow and shitty, but able to support a wide variety
        of hardware
  }


{*} UseLeechWeek:    Boolean;
{*} LeechListUD,
{*} LeechListK:      integer;
{*} UseTimeBank:     boolean;
{*} MaxTimeBank,
{*} TimeBankLvl,
{*} PrivLvl:         Integer;
{*} PrivBegin,
{*} PrivEnd:         Str10;
{*} RemoteDoors      :Boolean;
{*} EventTime:       Str10;
{*} EventBatchFile:  Str12;
{*} SysOpIn,
{*} SysOpOut         :Str10;
{*} TimeOutTime:     Byte;
{*} MultiNode:       boolean;
{*} NodeNumber:      Byte;

{*} MatrixType:       Byte;
{*} MatrixCmd:Array[1..8] Of Str10;
{*} MatrixDesc:Array[1..8] Of Str25;

{*} SysNormalColor,
{*} SysTopColor,
{*} SysOutLockColor,
{*} SysLineColor,
{*} SysStatBarColor,
{*} DefStat,
{*} DefInput,
{*} DefPrompt,
{*} DefReg,
{*} DefBox,
{*} DefInside,
{*} DefCmd,
{*} DefMisc:Byte;

{*} HangUpOnNew,
    UseRIPDetect,
{*} UseAnsiDetect:boolean;
    NumGoodByes,
    NumPreLogins,
{*} NumWelcomes:  Byte;

{*} AllowChat,
{*} AllowFeedBack:     boolean;
    StartUpMenu : String[8];

{*} UseNUV,
{*} AutoKillNUV:BooLean;
{*} NUVLvl,
{*} NUVYes,
{*} NUVNo,
{*} DefNUVLvl,
{*} DefNUVXLvl,
{*} DefNUVFpts: integer;
    DefNUVACSFlags:Str40;

{*} DefNote:    Str40;
{*} DefLvl,
{*} DefXlvl,
{*} DefFpts,

{*} ExemptPCR,
{*} MinPCR,
{*} MinUDK,
{*} MinUDR:     Integer;
    DefACSFlags:Str40;

{*} NumInfoForms :integer;
{*} Info:array [1..5] of Str80;
{*} ForceInfo:Array[1..5] Of Boolean;

{*} SysOpLvl,
{*} SecCallLvl,
{*} SecCallFileLvl,
{*} SecCallPts,
{*} ListUsersLvl,
{*} ListLastUsrsLvl:   integer;

{*} UserTime:array [1..100] of integer;

{*} FilesOpen,
{*} FilesClosed:       Str10;
{*} UseComment,
{*} AddCmtToZip:Boolean;
    IncFile:Str25;
{*} MinKBFree,
{*} LogSize,
{*} UploadMultiple,
{*} PercentBack,
{*} AutoPts:     integer;
{*} UsePtsComp:  boolean;

{*} PostLvl,
{*} AnonymousLvl :Integer;
{*} UseNewScanPrompt:Boolean;
    MsgPts:Byte;

End;

 ScreenType = array [0..3999] of Byte;

Procedure WriteConfig;
Procedure ReadConfig;
Procedure SetupConfig;

Var  CNF      :^ConfigRec;
     CnfFile:File Of ConfigRec;

Implementation

Procedure WriteConfig;
Begin
  Assign(CnfFile,'CONFIG.DAT');
  ReWrite(CnfFile);
  Write(CnfFile,Cnf^);
  Close(CnfFile);
  Dispose(Cnf);
End;

Procedure Readconfig;
Begin
  Assign(CnfFile,'CONFIG.DAT');
  Reset(CnfFile);
  New(CNF);
  Read(CnfFile,Cnf^);
  Close(CnfFile);
End;

Procedure SetUpConfig;
Var Cnt:Byte;
Begin
  New(CNF);
  With Cnf^ Do
  Begin
    FullSysName[0] :=#0;
    RegNumber[0]   :=#0;
    SysOpName[0]   :=#0;
    UseAutoLogin   :=True;
    WFC50          :=False;
    PrivateBBS     :=False;
    UseDirectVideo :=True;
    UseSnowCheck   :=False;
    UseExtMnu      :=True;
    UseLoginBell   :=False;
    UseStatLine    :=True;
    UseTheWall     :=true;
    UseFamousDay   :=false;
    UseNewScanPrompt:=True;
    SysOpIn        :='6:00 pm';
    SysOpOut       :='11:00 pm';
    PrivBegin      :='10:00 am';
    PrivEnd        :='10:00 am';
    TimeOutTime    :=3;

    GetDir(0,SysDir);
    If SysDir[Length(SysDir)]<>'\' then SysDir:=SysDir+'\';
    MsgDir         :=SysDir+'MESSAGE\';
    UpLoadDir      :=SysDir+'UPLOADS\';
    SysLogDir      :=SysDir+'LOGS\';
    SwapDir        :=SysDir+'SWAP\';
    MenuDir        :=SysDir+'MENUS\';
    DoorDir        :=SysDir+'DOORS\';
    WorkDir        :=SysDir+'WORK\';
    NetDir         :=SysDir+'INCLUDES\';
    DSZLog         :='DSZXFER.LOG';
    DataDir        :=SysDir+'DATA\';
    FileMailDir    :=SysDir+'FILEMAIL\';
    MenuDataDir    :=SysDir+'MENUDATA\';
    ModemINITStr   :='ATZ|~~ATV1E1H0M0N1L1S0=1S1=1|';
    ModemHangUpStr :='+++~~~ATH0|';
    ModemDialStr   :='ATDT';
    ModemDialSuff  :='|';
    DefBaudRate    :=19200;
    MinBaudRate    :=2400;
    ModemPort      :=2;

    System1PW:='ShockWavE';
    System2PW:='';
    System3PW:='';
    NewUserPW:='';
    SysOpPW:='SysOp';
    ChatPW:='Chat';
    LockOutBaudPass:='Locked!';
    PwString:='ShockWavE';

    UseTimeBank:=true;
    MaxTimeBank:=60;
    TimeBankLvl:=30;
    NumWelcomes:=1;

    AnonymousLvl:=25;
    SysOpLvl:=500;
    ListUsersLvl:=25;
    ListLastUsrsLvl:=25;

    SysNormalColor:=3;
    SysTopColor:=11;
    SysOutLockColor:=9;
    SysLineColor:=13;
    SysStatBarColor:=2;

    UploadMultiple:=1;

    UseComment:=true;
    AddCmtToZip:=True;
    FilesOpen:='3:00 am';
    FilesClosed:='3:00 am';
    IncFile:='';
    for cnt:=1 to 100 do UserTime[cnt]:=60;

    SecCallLvl:=1;
    SecCallFileLvl:=0;
    SecCallPts:=0;
    PostLvl:=20;

    RemoteDoors:=false;
    EventTime[0]:=#0;
    EventBatchFile[0]:=#0;
    MatrixType:=1;

    MinPCR:=25;
    ExemptPCR:=50;
    DefLvl:=25;
    DefXLvl:=25;
    DefFpts:=5;
    DefNote:='Validated User';
    DefACSFlags :='A';
    MinUDR:=25;
    MinUDK:=25;
    PercentBack:=50;
    UseLeechWeek:=false;
    AllowChat:=true;
    AllowFeedback:=true;
    MatrixCmd[1]:='1';
    MatrixCmd[2]:='2';
    MatrixCmd[3]:='3';
    MatrixCmd[4]:='4';
    MatrixCmd[5]:='5';
    MatrixCmd[6]:='6';
    MatrixCmd[7]:='7';
    MatrixCmd[8]:='8';
    MatrixDesc[1]:='Enter Main System';
    MatrixDesc[2]:='Enter Second System';
    MatrixDesc[3]:='Enter Third System';
    MatrixDesc[4]:='Apply as a NewUser';
    MatrixDesc[5]:='Check For Access';
    MatrixDesc[6]:='Log-Off';
    MatrixDesc[7]:='Send E-Mail To SysOp';
    MatrixDesc[8]:='Request Chat';
    LeechListUD:=25;
    LeechListK:=10;
    PrivLvl:=50;
    MinKBFree:=500;
    NUmInfoForms:=1;
    info[1]:='New User Application';
    info[2]:='Unused';
    info[3]:='Unused';
    info[4]:='Unused';
    info[5]:='Unused';
    ForceInfo[1]:=true;
    ForceInfo[2]:=false;
    ForceInfo[3]:=false;
    ForceInfo[4]:=false;
    ForceInfo[5]:=false;
    LogSize:=10;
    DefStat:=15;
    DefInput:=3;
    DefPrompt:=11;
    DefReg:=7;
    DefBox:=8;
    DefInside:=11;
    DefCmd:=9;
    DefMisc:=8;
    AutoPts:=0;
    UsePtsComp:=false;
    UseEMS:=false;
    MaximumDosShell:=False;
    HangUpOnNew:=true;

    StartUpMenu:='STARTUP';
    NumWelcomes:=1;
    NumPrelogins:=1;
    NumGoodByes:=1;

    UsePrinterLog:=False;
    ScreenSaveMin:=0;
    MultiNode:=false;
    NodeNumber:=1;

    UseNUV:=True;
    AutoKillNUV:=True;
    NUVLvl:=50;
    NUVYes:=5;
    NUVNo:=10;
    DefNUVLvl:=25;
    DefNUVXLvl        :=25;
    DefNUVFpts        :=5;
    DefNUVACSFlags    :='A';
    UseRIPDetect      :=False;
    UseAnsiDetect     :=True;
    ConfigVersionCode :=1;
 End;
 WriteConfig;
End;

Begin
End.