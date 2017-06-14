{
  iB * 10/21/95 - Added EMULATION var, for user to set apon login or from a menu
  iB * 11/13/95 - Added DebugMode Var, for screen spamming, and data reports
}

Unit Vars;

interface

Uses Records,CnfgRec;

{Type SysFlags=(SysOpIn,SysOpOut,None,ANSi,Mono,RIP,VT100,ShockWavE,Debug,
               RemoteInput,IOMethod,LocalLogin,TmpSysOp);
 }
Var RemoteInput:Boolean;
    DebugMode:Boolean;  { 0=No 1=Yes }
    Emulation:Byte;     { 0=None, 1=ANSi, 2=Mono, 3=RIP 4=VT100/VT102 9=ShockTerm }
    MLevel,XLevel:Integer; { Holders for TempSysOp/Xfer2User/Shells/etc }
    OldFlags:Str80;        { "     " }
    TmpSysOp:Boolean;      { Is TempSysOp Enabled or Not. }
    UNum:Integer;       { Global for User Number }
    LocalLogin:Boolean; { some login/matrix vars }
    TimeLeft:Integer;
    LogOnTime:LongInt;
    BaudRate:Word;      { Current Connected Baud Rate }
    CurStat:Byte;       { Current Status bar}
    Node:Byte;          { Current Node Running }
    ReturnTo:Str25;    { Filename of menu to run }
    Input:String;       { Global User Input var }
    CurUFile:Str80;    { Current Login User file }
    YN:Boolean;         { Used for YeaNa prompts }
    UseHotKey:Boolean;
    Dots:Boolean; { Dots for password input; ResetSystem for sysop logoff option }
    CurFileArea,CurMsgArea,CurConf:Byte; { Current File/Msg/Conf Number }
    CurFileAreaName,CurMsgAreaName,CurConfName:Str25; { Current Names }
    AnsiMethod: byte; {0=None 1=Internal 2=ANSi.SYS 3=Direct
                      {4=Int ANSi Mono 5=Int ANSi 7bit 6=Int ANSi 7bit Mono}

    Msg :MsgTxt;  { Global MsgBody }
    MHdr:MsgHdr;  { Global MsgHeader }

    QMsg:MsgTxt;  { Quoting MsgBody }
    QHdr:MsgHdr;  { Quoting MsgHeader }

    MenuBarz    :^MenuBarRec;
    CurMenu     :MenuRec;
    PrevMenuFile:Str25;
    CurMenuFile :Str25;
    FallBackMenu:Str25;

    MyStr    :^StringRec;   { System Strings  }

    Urec:^UserRec;         { User Record }

(* Global Counters,  etc.  *)
    CntB:Byte;
    CntI:Integer;
    TmpStr:Str80;

Implementation

Begin
End.