{
  iB * 03/23/95 - All Routines need to maintain User Files/Index etc.
  iB * 08/07/95 - Added Delete User procedure.
  iB * 08/08/95 - Fixed ReadUser and FindUser seeking problem.
  iB * 08/12/95 - Cleaned out urec. Was allow logins as last user in .NDX
}

{$I+}
Unit User;

Interface

Uses Dos,Records,Vars,GenSubs,CnfgRec,IO;

Procedure CleanURec;
Procedure WriteUFile(U:UserRec; N:Integer);
Procedure WriteUser(U:UserRec);
Function ReadUser(Var U:UserRec):Integer;
Function ValidUserName(N:Str25):Boolean;
Procedure SeekUFile(N:Integer);
Function DupHandle(U:Str25):Boolean;
Procedure FindUser(S:Str25; Var Num:Integer);
Procedure AddUser(U:UserRec);
Procedure DeleteUser(I:Integer);
Procedure OpenUserNDX(U:String);
Procedure CloseUserNDX;
Procedure OpenUFile(U:String);
Procedure CloseUFile;
Procedure OpenUFiles(U:String);
Procedure CloseUFiles;
Procedure ReCreateUserNDX(U:String);
Function NumUsers:integer;
Procedure CheckUsers(U:String);
Procedure SetUserProfile(Var U:UserRec; ProFile:Byte);
Procedure UserUpgrades;
Procedure FixRec(P1:Integer);

Implementation

Var UFile:File Of UserRec;
    UIndex:File of Str25;

Procedure CleanURec;
Begin
  UNum:=-1;
  FillChar(Urec^,SizeOf(UserRec),#0);
  With Urec^ do
  Begin
    Lvl:=0;
    XLvl:=0;
    Password[1]:='';
    TimeLeft:=-1;
  End;
  Urec^.Regularcolor:=7;
  Urec^.Statcolor:=11;
  Urec^.Inputcolor:=3;
  Urec^.CmdColor:=15;
  Urec^.MiscColor:=8;
  Urec^.InsideColor:=9;
  Urec^.BoxColor:=8;
End;

Procedure OpenUserNDX(U:String);
Begin
  Assign(UIndex,CNF^.DataDir+U+'.NDX'); ReSet(UIndex);
End;

Procedure CloseUserNDX;
Begin
  Close(UIndex);
End;

Procedure OpenUFile(U:String);
Begin
  Assign(Ufile,CNF^.DataDir+U+'.LST'); ReSet(Ufile);
End;

Procedure CloseUFile;
Begin
  Close(Ufile);
End;

Procedure OpenUFiles(U:String);
Begin
  {UOpenStr:=UOpenStr+'þ';}
  OpenUFile(U);
  OpenUserNDX(U);
End;

Procedure CloseUFiles;
Begin
{  Delete(UOpenStr,1,Length(UOpenStr));}
  CloseUFile;
  CloseUserNDX;
End;

Procedure ReCreateUserNDX(U:String);
Begin
  If ParamCount=0 Then Writeln('þ Recreating User Index');
  OpenUFile(U);
  If Exist(U+'.NDX') Then OpenUserNDX(U) Else
  Begin
    Assign(UIndex,CNF^.DataDir+U+'.NDX');
    ReWrite(UIndex);
  End;
  While Not EOF(Ufile) do
  Begin
    Read(Ufile,Urec^);
    Write(UIndex,Urec^.Handle);
  End;
  CloseUFiles;
  FixRec(0);
End;

Procedure SeekUFile(N:Integer);
Begin
  If (N<0) or (N>FileSize(Ufile)) Then Exit;
  Seek(UFile,N);
End;

Procedure WriteUFile(U:UserRec; N:Integer);
Begin
  Seek(UFile,N);  Write(UFile,U);
  Seek(UIndex,N); Write(UIndex,U.Handle);
End;

Procedure WriteUser(U:UserRec);
Begin
  If UNum<0 then Exit;
  OpenUFiles(CurUfile);
  WriteUFile(U,Unum);
  CloseUfiles;
End;

Function ReadUser(Var U:UserRec):Integer;
Begin
  Read(UFile,U);
{  UName:=U.Handle;}
  MLevel:=U.Lvl;
  ReadUser:=FilePos(Ufile)-1;
End;

Function ValidUserName(N:Str25):Boolean;
Var X:Byte;
Begin
  ValidUserName:=False;
  If Length(N)<>0 Then 
  Begin
    For X:=1 to Length(N) Do
    Begin
      If Not (N[X] in ['!','@','$','#','%','^','&','*','(',')','+','='])
         and Not (N[X] in ['[',']','{','}',';','"',':','?','>','<','.','/','~','`'])
         THen ValidUserName:=True;
    End;
  End;
End;

Procedure FindUser(S:Str25; Var Num:Integer);
Var Tmp:Str25;
Begin
  Num:=-1;
  If Length(S)=0 Then Exit;
  Seek(UIndex,1);
  While Not EOF(UIndex) do
  Begin
    Read(Uindex,Tmp);
    If Match(Tmp,S) Then
    Begin
      Num:=FilePos(UIndex);
      Exit;
    End Else Num:=-1;
  End;
End;

Function DupHandle(U:Str25):Boolean;
Var Tmp:Str25;
Begin
  Reset(UIndex);
  DupHandle:=False;
  While Not EOF(UIndex) do
  Begin
    Read(Uindex,Tmp);
    If Match(Tmp,U) then DupHandle:=True;
  End;
End;
  
Function FindFreeURec:Integer;
Var Tmp:UserRec;
Begin
  ReSet(UFile);
  While Not EOF(UFile) Do
  Begin
    Read(UFile,Tmp);
    If ((Length(Tmp.Handle)=0) and (FilePos(Ufile)-1<>0)) Then
    Begin
      FindFreeUrec:=FilePos(Ufile)-1;
      Exit;
    End;
  End;
  FindFreeUrec:=FilePos(Ufile);
End;

Procedure AddUser(U:UserRec);
Var Tmp:UserRec;
    P:Integer;
Begin
  P:=FindFreeUrec;
  Seek(UFile,P);  Write(Ufile,U);
  Seek(UIndex,P); Write(UIndex,U.Handle);
End;

Procedure DeleteUser(I:Integer);
Var TmpU:UserRec;
    Ts:Str25;
Begin
  SeekUfile(i);
  Seek(UIndex,i-1);
  ReadUser(TmpU);
  Read(UIndex,Ts);
  FillChar(TmpU,SizeOf(TmpU),#0);
  FillChar(TS,SizeOf(Ts),#0);
  Seek(UIndex,i-1);
  Write(Uindex,Ts);
  SeekUfile(i);
  Seek(UIndex,i-1);
  Write(Ufile,TmpU);
End;

Procedure CheckUsers(U:String);
Begin
  If ParamCount=0 Then Writeln('þ Checking Users File '+CNF^.DataDir+U+'.LST...');
  If Not Exist(CNF^.DataDir+U+'.LST') Then
  Begin
    Writeln('þ Building Users File...');
    Assign(UFile,CNF^.DataDir+U+'.LST');
    ReWrite(UFile);
    CleanUrec;
    {
      maybe use this for some kinda registration checking?
      Have lots of ideas for record 0, in users file!!!
    }
    With Urec^ Do
    Begin 
      {fill in record 0}
      Handle:='!ShockWavE:PRO!';
      Realname:='Ver:'+VerStr;
      UserVersion:=Revision;
      Password[1]:='¥AþúûAèÜ½Û';  { Encryption key for passwords? }
      Password[2]:=DateStr(Now);
      Password[3]:=TimeStr(Now);
      Password[4]:=CNF^.RegNumber;
      Lvl:=-1;
      Xlvl:=-1;
    End;
    Write(Ufile,Urec^);

    CleanUrec;

    With Urec^ Do
    Begin
      Handle:=CNF^.SysOpName;
      RealName:=Handle;
      SysOpNote:='Sys: '+CNF^.FullSysName;
      UserNote:= SysOpNote;
      Phone[1]:='0005551212';
      Lvl:=CNF^.SysOpLvl+1;
      XLvl:=CNF^.SysOpLvl+1;
      TimeLeft:=100;
      TimeLimit:=100;
      Password[1]:='SysOp';
      AccessFlags:='ABCDEFGHIJKLMNOPQRSTUVWXY';
      Regularcolor:=7;
      Promptcolor:=9;
      Statcolor:=11;
      Inputcolor:=3;
      CmdColor:=15;
      MiscColor:=8;
      InsideColor:=9;
      BoxColor:=8;
      MsgHeader:=1;
    End;
    Write(Ufile,Urec^);
    Close(Ufile);

    ReCreateUserNDX(U);
  End
 Else ReCreateUserNDX(U);
End;

Function NumUsers:Integer;
Begin
  NumUsers:=FileSize(UFile)-1;
End;

Procedure SetUserProfile(Var U:UserRec; ProFile:Byte);
Var     UProfile:ProfileRec;
    FProFile:File Of ProFileRec;

Begin
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
  ReSet(FProFile);
  If ProFile<=FileSize(FProFile) Then
  Begin
    Seek(FProFile,ProFile);
    Read(FProFile,UProFile);
    Close(FProFile);
    With UProFile Do
    Begin
      U.Lvl:=AcLvl;
      U.XLvl:=XferLvl;
      U.FilePts:=Fpoints;
      U.AccessFlags:=AcFlags;
      U.UserNote:=UserNote;
      U.ExpDate:=ExpDate;
      U.Up_Down_Ratio:=UDR;
      U.Up_Down_K_Ratio:=UDKR;
      U.PCR:=PCR;
      U.TimeLimit:=TimeLimit;
    End;
  End;
End;

Procedure UserUpgrades;
Begin
  If (Urec^.MsgHeader<0) or (Urec^.MsgHeader>4) then Urec^.MsgHeader:=1;
  If (Urec^.DefProtocol<0) or (Urec^.DefProtocol>4) then Urec^.DefProtocol:=1;
End;

Procedure FixRec(P1:Integer);
Var UU:UserRec;
Begin
  FillChar(UU,SizeOf(UU),#0);
  OpenUFiles(CurUFile);
  WriteUFile(UU,P1);
  CloseUFiles;
End;


Begin
End.