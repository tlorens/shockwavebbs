
Unit StartUp;

Interface

Procedure Start(N:Byte);  { pass in node }

Implementation

Uses OpCrt,Dos,Records,Gensubs,Vars,CnfgRec,User,IO,Windows,Misc,
     Multi,iCEMouse;

Procedure StatWrite(S:String);
Begin
  If ParamCount=0 Then Writeln(S);
End;

Procedure CheckConfig;
Begin
  StatWrite('þ Checking Config...');
  If Not Exist('CONFIG.DAT') then
  Begin
    StatWrite('þ CONFIG.DAT not found. You must run CONFIG.EXE first');
    SWDone(255);
  End;
End;

Procedure CheckStrings;
Begin
  StatWrite('þ Checking Strings...');
  If Not Exist(CNF^.DataDir+'STRINGS.DAT') Then
  Begin
    Writeln('þ ', Cnf^.Datadir + 'STRINGS.DAT was not found');
    Writeln('  You must run CONFIG.EXE first');
    SWDone(255);
  End;
End;

Procedure CheckPaths;
Begin
  StatWrite('þ Checking Paths...');
  StatWrite('ú    PATH Ä> '+GetEnv('PATH'));
  StatWrite('ú COMSPEC Ä> '+GetEnv('COMSPEC'));
  StatWrite('ú  DSZLOG Ä> '+GetEnv('DSZLOG'));
End;

Procedure Readconfig;
Begin
  StatWrite('þ Reading Config...');
  Assign(CnfFile,'CONFIG.DAT');
{$I-}  Reset(CnfFile); {$I+}
  If IOresult<>0 then SWDone(255);
  Read(CnfFile,CNF^);
  Close(CnfFile);
End;

Procedure ReadStrings;
Var MyStrFile:File Of StringRec;
Begin
  StatWrite('þ Reading Strings...');
  Assign(MyStrFile,CNF^.DataDir+'STRINGS.DAT');
  {$I-} ReSet(MyStrFile); {$I+}
  If IOResult<>0 Then SWDone(255);
  Read(MyStrFile,MyStr^);
  Close(MyStrFile);
End;

Procedure MultiChatInit;
Var Cnt:Byte;
Begin
  If CNF^.MultiNode Then
  Begin
{    Assign (nodefile, CNF^.DataDir+Node_filename);
    If Not Exist(CNF^.DataDir+Node_FileName) Then InitNodeFile;}
  End;
End;

Procedure Start(N:Byte);  { pass in node }
Var T:File;
Begin
  TimeLeft:=60;
  CurStat:=1;
  RemoteInput:=True;
  DirectVideo:=True;
  Dots:=False;
  CurUFile:='USERS';
  TextColor(7);
  TextBackGround(0);
  ClrScr;
  Writeln('þ Starting ShockWavE...');
  New(Cnf);
  New(Urec);
  New(MyStr);
  CheckPaths;
  CheckConfig;  ReadConfig;
  CheckStrings; ReadStrings;
  CheckUsers(CurUFile);
  CurMenuFile:=CNF^.StartUpMenu;
  Node:=CNF^.NodeNumber;
  Writeln('þ Starting Node: ',Node);
  If Exist(CNF^.SysDir+'BATCH.LST') Then
  Begin
    Assign(T,CNF^.SysDir+'BATCH.LST');
    Erase(T);
  End;
  MakeWin(1,1,1,80,25);  { FullScreen }
  MakeWin(2,1,1,80,24);  { FullScreen with 1 Line StatBar }
  GotoWindow(1);

  If Carrier then
  Begin
    IOMethod:=Normal;
    LocalLogin:=False;
  End
 Else
  Begin
    IOMethod:=Local;
    LocalLogin:=True;
  End;
  MouseOn;
End;

Begin
End.