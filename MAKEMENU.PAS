PRogram MakeANSiMenus;

Uses opCrt,Dos,Vars,Records,GenSubs,Cnfgrec,PullBarz;

Const VerNum='0.10';
      VerDate='12/22/96';

Var   MenuArray:Array[1..50] of String[13];
      CmdList : String[78];
      FTmpMenu: File Of CommandRec;
      TmpMenuCmd: CommandRec;
      Total,Tim,X,Sub,Cnt,Count:Byte;
      FileN:Text;
      FMenuCmd:File Of CommandRec;           { Remove from global var list }
      MenuCmd:Array[1..68] of ^CommandRec;   { 68 MAX }
      CurMenu:MenuRec;
      FCurMenu:File Of MenuRec;              { Remove from global var list }
      CmdHolder:String[70];

Procedure GetMenus;
Var DirInfo: SearchRec;
Begin
  Count:=0;
  FindFirst(CNF^.MenuDataDir+'*.DAT', Archive, DirInfo);
  TextColor(7);
  Write('Gathering menus.');
  While (DosError=0) and (Count<50) do
  Begin
    Inc(Count);
    MenuArray[Count]:=DirInfo.Name;
    Write('.');
    FindNext(DirInfo);
  End;
  Writeln('   Total: ',Count,^M);
End;

Procedure ANSiTab(n:Str255; np:integer);
var cnt:integer;
begin
  write(FileN,N);
  for cnt:=length(n) to np-1 do write(FileN,' ')
end;

Procedure TxtColor(Color:Byte);
Begin
  Case Color Of
    0 : Write(FileN,#27'[0m',#27'[30m');
    1 : Write(FileN,#27'[0m',#27'[34m');
    2 : Write(FileN,#27'[0m',#27'[32m');
    3 : Write(FileN,#27'[0m',#27'[36m');
    4 : Write(FileN,#27'[0m',#27'[31m');
    5 : Write(FileN,#27'[0m',#27'[35m');
    6 : Write(FileN,#27'[0m',#27'[33m');
    7 : Write(FileN,#27'[0m',#27'[37m');
    8 : Write(FileN,#27'[0m',#27'[1;30m');
    9 : Write(FileN,#27'[0m',#27'[1;34m');
    10 : Write(FileN,#27'[0m',#27'[1;32m');
    11 : Write(FileN,#27'[0m',#27'[1;36m');
    12 : Write(FileN,#27'[0m',#27'[1;31m');
    13 : Write(FileN,#27'[0m',#27'[1;35m');
    14 : Write(FileN,#27'[0m',#27'[1;33m');
    15 : Write(FileN,#27'[0m',#27'[1;37m');
    99 : Write(FileN,#27'[0m');
  End;
End;

Function FileName(S:String):String;
Begin
  Delete(S,Pos('.',S),4);
  FileName:=S;
End;

Procedure GenerateANSi;
Var iCE:Byte;
Begin

  For X:=1 to Count Do
  Begin
    Tim:=0;
    Cnt:=0;
    For iCE:=1 To 68 Do New(MenuCmd[iCE]);
    Assign(FMenuCmd,CNF^.MenuDataDir+MenuArray[X]);
    ReSet(FMenuCmd);
    While Not EOF(FMenuCmd) Do
    Begin
      Read(FMenuCmd,MenuCmd[FilePos(FMenuCmd)+1]^);
      Inc(Cnt);
    End;
    Close(FMenuCmd);

    TextColor(7); Writeln(X,': Creating Menu: ',FileName(MenuArray[X])+'.ANS');
    Assign(FileN,CNF^.MenuDir+FileName(MenuArray[X])+'.ANS');
    ReWrite(FileN);
    Write(FileN,#27'[2J');
    TxtColor(15);
    Writeln(FileN,'                                  ShockWavE:Pro                                ');
    TxtColor(8);
    Writeln(FileN,'  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커  ');
    Writeln(FileN,'컴냐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캐컴');
    Writeln(FileN,'  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸  ');
    FillChar(CmdHolder,SizeOf(CmdHolder),#0);
    While Tim<Cnt Do
    Begin
      Sub:=0;
      TxtColor(8); Write(FileN,'              ');
      Repeat
        Inc(Tim);
        If Pos(MenuCmd[Tim]^.Key,CmdHolder)=0 Then 
        Begin
          Inc(Sub);
          CmdHolder:=CmdHolder+MenuCmd[Tim]^.Key;
          With MenuCmd[Tim]^ do
          Begin
            TxtColor(4);  Write(FileN,'['); TxtColor(12); Write(FileN,Key[1]); TxtColor(4); Write(FileN,'] ');
            TxtColor(7);  ANSiTab(Copy(Desc,1,14),15); {9}
          End;
        End;
      Until (Sub=3) or (Tim=Cnt);
      Writeln(FileN,'');
    End;
    TxtColor(8);
    Writeln(FileN,'  旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커  ');
    Writeln(FileN,'컴냐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캐컴');
    Writeln(FileN,'  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸  ');
    Writeln(FileN,'                                                                               ');
    TxtColor(7);
    Close(FileN);
    For iCE:=1 To 68 Do Dispose(MenuCmd[iCE]);
  End;
End;

Function FixParamStr(S:String):String;
Var Tmp:String;
Begin
  If Pos('.',S)<>0 then
  Repeat
    Delete(S,Length(s),1);
  Until Pos('.',S)=0;
  FixParamStr:=S;
End;

Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('� Make ANSi-Menus �                           ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerNum); ClrEol;
  Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
  Window(1,3,80,25);
  ReadConfig;
  If ParamCount<1 then GetMenus Else
  Begin
    Count:=1;
    MenuArray[Count]:=FixParamStr(ParamStr(1))+'.DAT';
  End;
  GenerateANSi;
End.

