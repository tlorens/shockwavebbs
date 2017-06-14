{
  ShockWavE:PRO * Started: 03/23/95
  Re-Write By: iCE Breaker and Digital Parasite

  iB * 07/01/95 - ShockWavE Welcomes Nick-oli to the team.
  Dp * 08/09/95 - TpCrt replaced with OpCrt
                  This file is now the shell that will spawn the main
                  shockwave module (SHKDATA)
  iB * 03/09/96 - Digital Parasite and Nickoli haven't been seen
                  in a LONG Time! Almost a year, and still not complete!
  iB * 04/03/97 - Long overdue work has begun again..                    
}

{$D-,L-,I+}
{$M 32000,32080,64000}
Program ShockWavE_Shell;

Uses Dos,
     OpCrt,    { Object Professional Crt }
     Stack,
     OpenFiles, { displays list of open files upon exit }
     StartUp,  { Inits all vars }
     Vars,     { global vars }
     CnfgRec,  { config recs }
     ShkMenus, { shockwave menuediting }
     WaitCall, { WFC routines }
     GenSubs,  { Convertors, Time/Date routines }
(*     ShowErr,  { Runtime Errors Defined }*)
     Windows,
     Misc,

     User,     { User Routines }
     IO;       { ALL user/system IO }

Var PCnt:Byte;

Procedure Help;
Begin
  ClrScr;
  TextColor(11);
  Writeln;
  Writeln('ShockWavE:BBS Command Line Help');
  Writeln;
  TextColor(3);
  Writeln('/U       User Number');
  Writeln('/B       BaudRate');
  Writeln('/N       Node Number');
  Writeln('/M       Menu to Run');
  Writeln('/F       Filename Of Users List');
  Writeln('/LOCAL   Local Login');
  Writeln('/ANSI    Use ANSI');
  Writeln('/RIP     Use RIP');
  Writeln('/NOANSI  Don''t Use ANSI');
  Halt;
End;

Begin
  DebugMode:=True;
  SetCBreak(DeBugMode);
  Node:=0;
  UNum:=-1;
  BaudRate:=0;
  ReturnTo:='';
  CurConf:=1;

  If ParamCount>0 then
  Begin
    GotoWindow(2);
    For Pcnt:=1 to ParamCount Do
    Begin
      If UpString(ParamStr(PCnt))='/U' Then UNum:=Valu(ParamStr(PCnt+1)) Else
      If UpString(ParamStr(PCnt))='/B' Then BaudRate:=Valu(ParamStr(PCnt+1)) Else
      If UpString(ParamStr(PCnt))='/N' Then Node:=Valu(ParamStr(PCnt+1)) Else
      If UpString(ParamStr(PCnt))='/M' Then ReturnTo:=ParamStr(PCnt+1) Else
      If UpString(ParamStr(PCnt))='/F' Then CurUFile:=ParamStr(PCnt+1) Else
      If UpString(ParamStr(PCnt))='/LOCAL' Then IOMethod:=Local Else
      If UpString(ParamStr(PCnt))='/REMOTE' Then IOMethod:=Normal Else
      If UpString(ParamStr(PCnt))='/ANSI' Then Emulation:=1 Else
      If UpString(ParamStr(PCnt))='/RIP' Then Emulation:=3 Else
      If UpString(ParamStr(PCnt))='/NOANSI' Then Emulation:=2 Else
      If UpString(ParamStr(PCnt))='/?' Then Help;
    End;
  End;

  Start(Node); { pass in Node to START up }
  If (CNF^.ModemPort<>0) and (Not Carrier) and (ParamCount=0) Then 
  Begin
    Writeln('þ Init Modem');
    InitModem(Cnf^.DefBaudRate);
    SendInit(CNF^.ModemInitStr);
  End;

  If ((BaudRate>0) and (UNum=-1)) Then RunMenu Else
  If ((UNum>0) and (Length(ReturnTo)>0)) Then
  Begin
    OpenUFiles(CurUfile);
    SeekUFile(UNum);
    UNum:=ReadUser(Urec^);
    UseHotKey:=Urec^.MenuType=1;
    CloseUfiles;
    CurMenuFile:=ReturnTo;
    RunMenu;
  End 
 Else 
  WaitForCall; { else, we just start up the WFC screen.}
  SWDone(255);
End.
