{
  iB * 04/13/96 - Mostly LOCAL sysop Routines. Used with GlobKey.PAS
}

Unit Options;

Interface

Uses Opcrt,DOS,IO,Vars,CnfgRec,PullBarz,Chat,DoShell,Display,Windows,
     Grafx,User;

Procedure Debugger;
Procedure LocalHelp;
Procedure FullUserStats;
Procedure DOSShell;
Procedure LocalMenus;
Procedure ToggleOutPut;
Procedure ToggleInPut;
Procedure ToggleTempSysOp;
Procedure FlipStatBar;
Procedure MoreTime;
Procedure LessTime;
Procedure SaveUserStats;
Procedure NukeUser;
Procedure SysOpChat;
Procedure RunConfig;

Var Stats,Help:Boolean;

Implementation

Var PullRec:PullBarzRec;

Procedure Debugger;
Begin
  If Stats Then Stats:=False;
  Help:=Not Help;
  If Help Then
  Begin
    MakeWin(3,1,1,80,13);
    MakeWin(2,1,14,80,24);
    GotoWindow(3);
    ClrScr;
    Box(1,1,79,12,'Debugger');
    GotoXy(3,2);  Write('UFile: ',CurUfile,' CurMenu: ',CurMenuFile);
    GotoXy(3,3);  Write('Conf: ',CurConf,' ³ Msg: [',CurMsgArea,']',CurMsgAreaName,
                        ' ³ Xfer: [',CurFileArea,']',CurFileAreaName);
    GotoXy(3,4);  Write('Local: ',LocalLogin);
    GotoXy(3,5);  With urec^ do Write('[',UNum,']',Handle,' ',Lvl,'/',Xlvl,'/',AccessFlags,'/',TimeLeft,
                                      ' ',BaudRate,' ',Node); 
    GotoXy(3,6);  Write('MaxAvail: ',MaxAvail,' MaxMem: ',MemAvail); 
    GotoXy(3,7);  WriteOp('      Less Time');
    GotoXy(3,8);  WriteOp('      More Time');
    GotoXy(3,9);  WriteOp('Alt+N  Nuke User');

  End
 Else
  Begin
    GotoWindow(3);
    ClrScr;
    MakeWin(2,1,1,80,24);
    DelWin(3);
  End;
  GotoWindow(2);
End;


Procedure LocalHelp;
Begin
  If Stats Then Stats:=False;
  Help:=Not Help;
  If Help Then
  Begin
    MakeWin(3,1,1,80,13);
    MakeWin(2,1,14,80,24);
    GotoWindow(3);
    ClrScr;
    Box(1,1,79,12,'Help');
    GotoXy(3,2);  WriteOp('Alt+X  Exit ShockWavE     Alt+V  Validate');
    GotoXy(3,3);  WriteOp('Alt+J  DOS Shell          Alt+N  Nuke User');
    GotoXy(3,4);  WriteOp('Alt+S  Users Stats        Alt+W  Write Stats');
    GotoXy(3,5);  WriteOp('Alt+T  Temp SysOp         Alt+D  Debug Stats');
    GotoXy(3,6);  WriteOp('Alt+H  This Help          Alt+B  StatBar Toggle');
    GotoXy(3,7);  WriteOp('F1     Chat               F2     Console Menu');
    GotoXy(3,6);  WriteOp('F9     Toggle Output      F10    Toggle Input');
    GotoXy(3,8);  WriteOp('      Less Time                More Time');
  End
 Else
  Begin
    GotoWindow(3);
    ClrScr;
    MakeWin(2,1,1,80,24);
    DelWin(3);
  End;
  GotoWindow(2);
End;



Procedure FullUserStats;
Begin
  If Help Then Help:=False;
  Stats:=Not Stats;
  If Stats Then
  Begin
    MakeWin(3,1,1,80,13);
    MakeWin(2,1,14,80,24);
    GotoWindow(3);
    ClrScr;
    Box(1,1,79,12,'Users Stats');
  End
 Else
  Begin
    GotoWindow(3);
    ClrScr;
    MakeWin(2,1,1,80,24);
    DelWin(3);
  End;
  GotoWindow(2);
End;

Procedure DOSShell;
Begin
  MCiPrintln(MyStr^.SysOpInDosStr);
  ExecShell('');
End;

Procedure RunConfig;
Begin
  MCiPrintln(MyStr^.SysOpInDosStr);
  ExecShell('CONFIG.EXE');
End;

Procedure RunEditor;
Begin
  MCiPrintln(MyStr^.SysOpInDosStr);
  ExecShell('Q.EXE');
End;

Procedure ExitToDos;
Begin
  MCiPrintln(MyStr^.SysOpInDosStr);
  Halt(255);
End;

Procedure ToggleOutPut;
Begin
  If IOMethod=Normal Then IOMethod:=Local Else
  If IOMethod=Local Then IOMethod:=Normal;
End;

Procedure ToggleInput;
Begin
  RemoteInput:=(Not RemoteInput);
End;

Procedure ToggleTempSysOp;
Begin
  TmpSysOp:=Not TmpSysOp;
  If TmpSysOp Then
  Begin
    MLevel:=Urec^.Lvl;
    XLevel:=Urec^.XLvl;
    OldFlags:=Urec^.AccessFlags;
    Urec^.Lvl:=CNF^.SysOpLvl;
    Urec^.XLvL:=CNF^.SysOpLvl;
    Urec^.AccessFlags:='ABCDEFGHIJKLMNOPQRSTUVWXY';
  End
 Else
  Begin
    Urec^.Lvl:=MLevel;
    Urec^.XLvl:=XLevel;
    Urec^.AccessFlags:=OldFlags;
  End;
  StatusBar(CurStat);
End;

Procedure MainMenus;
Begin
  With PullRec Do
  Begin
      MenuName    :='Local SysOp Menu';
      Choice[1]   :='1 DOS Shell';
      Choice[2]   :='2 Text Editor';
      Choice[3]   :='3 BBS Config';
      Choice[4]   :='4 Exit To DOS';
      Choice[5]   :='5 Back To BBS';
      NumChoices  :=5;
      DefChoice   :=1;
      KeyCmds     :='12345';
    End;
End;

Procedure LocalMenus;
Var Quit:Boolean;
    O:Byte;
Begin
  MCIWriteln(MyStr^.SysOpWait);
  Quit:=False;
  SaveScreen;
  GotoWindow(1);
  ClrScr;
  GotoXY(1,1); TextColor(15); TextBackGround(1);
  Write('[ ShockWavE ] '); ClrEol;
  Repeat
    MainMenus;
    O:=MenuBar(1,10,5,3,0,15,1,11,1,0,PullRec);
    Case O Of
      1:DOSShell;
      2:RunEditor;
      3:RunConfig;
      4:ExitToDos;
      5:Quit:=True;
    End;
  Until Quit;
  GotoWindow(2);
  ReStoreScreen;
End;

Procedure FlipStatBar;
Begin
  Inc(CurStat);
  If CurStat>7 Then CurStat:=0;
  StatusBar(CurStat);
End;

Procedure MoreTime;
Begin
  Inc(Urec^.TimeLeft);
  StatusBar(CurStat);
End;

Procedure LessTime;
Begin
  Dec(Urec^.TimeLeft);
  StatusBar(CurStat);
End;

Procedure SaveUserStats;
Begin
  WriteUser(Urec^);
End;

Procedure NukeUser;
Begin
  MCiPrintln(MyStr^.MatrixHangUpStr);
  HangUp;
End;

Procedure SysOpChat;
Begin
  If Carrier Then
  Begin
    MCiPrintln(MyStr^.EnterChatStr);
    SplitScreenChat;
    MCiPrintln(MyStr^.ExitChatStr);
  End Else MCiPrintln('Huh? you want to chat with yourself?');
End;

Procedure ToggleAvail;
Begin
End;

Begin
  Help:=False;
  Stats:=False;
End.