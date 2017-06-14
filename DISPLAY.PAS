Unit Display;

Interface

Uses OpCrt,Dos,IO,Vars,Records,User,CnfgRec,GenSubs,RunProg,Windows;

Procedure SaveXY;
Procedure RestoreXY;
Procedure MCiPrint(S:string);    { for use with user printable strings }
Procedure MCiPrintln(S:string);    { for use with user printable strings }
Procedure MCIWrite(S:String);
Procedure MCIWriteln(S:String);
Procedure PrintInclude(FN:Str80);
Procedure HitKey;
Procedure PrintFile(FN:str80);
Procedure Tab(N:Str80; Len:Integer);
Function TabStr(N:Str80; Len:Integer):String;
Procedure WriteScreen(S:String; x,y,at:Integer);
Procedure ReadScreen(Var S:String; x,y:Integer);
Procedure BackSpace(X,Y,Int:Integer);
Procedure Writehdr(Q:Str80);
Function DotYesNo(b:boolean):Char;
Function YesNo(b:boolean):String;
Function YeaNa(S:String; Def:Boolean):Boolean;
Function BarMenu(M:MenuBarRec):Char;
Function Barz(M:MenuBarRec; Fn:Str40; GetEm:Boolean):Char;
Procedure WriteErr(S:Str80);
Function Prompt(Len:Byte; Str:Str80; HotKey:Boolean): str80;
Function EditPrompt(Len:Byte; Str:String):String;
Function Edit(Var S:String; X,Y,Len:Byte; MultiFields:Boolean):Char;
Procedure PrintMenu(Cmd:CommandRec);

Implementation

Type
  ScreenLine = Array[1..80] Of Record
    C: Char;
    A: Byte;
  End;

  ScreenBuff = Array[1..50] Of ScreenLine;

Var Disp  : ^ScreenBuff;

Procedure SaveXY;
Begin
  If Emulation in [1,3] then Print(#27+'[s') else
  If Emulation=4 Then Print(#27+'7');
End;

Procedure RestoreXY;
Begin
  If Emulation in [1,3] then Print(#27+'[u');
  If Emulation=4 Then Print(#27+'8');
End;

Procedure PrintInclude(FN:Str80);
Var TF:Text;
    Line:String;
Begin
  If Exist(FN) Then
  Begin
    Assign(TF,FN);
    Reset(TF);
    While not (eof(tf)) or (hungupon) do
    Begin
      Readln(TF,Line);
      MCIWrite(Line);
    end;
    close(tf);
  End Else Println('<include file not found>');
end;

Procedure PrintMsgInclude(FN:Str80);
Var TF:Text;
    Line:String;
Begin
  If Exist(FN) Then
  Begin
    Assign(TF,FN);
    Reset(TF);
    While not (eof(tf)) or (hungupon) do
    Begin
      Readln(TF,Line);
      MCIPrintln(Line);
    end;
    close(tf);
  End Else Println('<include file not found>');
end;

Procedure MCIWrite(S:string);  (* Capible of running files *)
Var Pause,I:Integer;
    IncANSi:String[13];
    ExtFile:Str80;
    Chrs:String[2];
    ch : char;
Begin
  If Length(S)=0 then exit;
  I:=1;
  Repeat
    if s[i]='`' then
    Begin
      ch := s[i+ 1];
      i  := i + 2;
      if Ch='0' then AColor(0) else
      If Ch='1' Then AColor(1) else
      If Ch='2' Then AColor(2) else
      If Ch='3' Then AColor(3) else
      If Ch='4' Then AColor(4) else
      If Ch='5' Then AColor(5) else
      If Ch='6' Then AColor(6) else
      If Ch='7' Then AColor(7) else
      If Ch='8' Then AColor(8) else
      If Ch='9' Then AColor(9) else
      If Ch='A' Then AColor(10) else
      If Ch='B' Then AColor(11) else
      If Ch='C' Then AColor(12) else
      If Ch='D' Then AColor(13) else
      If Ch='E' Then AColor(14) else
      If Ch='F' Then AColor(15) else
    end
   else If s[i]='|' then
    Begin
      Chrs:=UpString(Copy(s,i+1,2));
      If Chrs='EC' then ModemPrint(#27) Else
      If Chrs='UN' then Print(Strr(Unum)) Else
      If Chrs='UH' Then Print(Urec^.Handle) Else
      If Chrs='RN' then Print(Urec^.RealName) Else
      If Chrs='AG' Then Print(Strr(Uage(Urec^.Age))) Else
      If Chrs='SX' then Print(Urec^.Gender) Else
      If Chrs='NC' Then Print(Strr(Urec^.NumCalls)) Else
      If Chrs='PS' Then Print(Strr(Urec^.Posts)) Else
      If Chrs='UP' Then Print(Strr(Urec^.Uploads)) Else
      If Chrs='DN' Then Print(Strr(Urec^.Downloads)) Else
      If Chrs='LV' Then Print(Strr(Urec^.Lvl)) Else
      If Chrs='AF' Then Print(Urec^.AccessFlags) Else
      If Chrs='FP' Then Print(Strr(Urec^.FilePts)) Else
      If Chrs='NO' Then Print(Urec^.UserNote) Else
      If Chrs='UK' Then Print(Strr(Urec^.UpK)) Else
      If Chrs='DK' Then Print(Strr(Urec^.DownK)) Else
      If Chrs='TB' Then Print(Strr(Urec^.TimeBank)) Else
      If Chrs='UR' Then Print(Strr(Urec^.Up_Down_Ratio)) Else
      If Chrs='DR' Then Print(Strr(Urec^.Up_Down_K_Ratio)) Else
      If Chrs='PC' Then Print(Strr(Urec^.PCR)) Else
      If Chrs='SY' Then Print(CNF^.FullSysName) Else
      If Chrs='TL' Then Print(Strr(Urec^.Timeleft)) Else
      If Chrs='N#' Then Print(Strr(Node)) Else
      If Chrs='BE' Then Print(^G) Else
      If Chrs='CL' Then Cls Else
      If Chrs='BA' Then Print(Strr(BaudRate)) Else
      If Chrs='NU' Then Begin OpenUFile(CurUfile); Print(Strr(NumUsers)); CloseUFile; End Else
      IF Chrs='DA' Then Print(DateStr(Now)) Else
      If Chrs='TI' Then Print(TimeStr(Now)) Else
      If Chrs='01' Then AColor(1) else
      If Chrs='02' Then AColor(2) else
      If Chrs='03' Then AColor(3) else
      If Chrs='04' Then AColor(4) else
      If Chrs='05' Then AColor(5) else
      If Chrs='06' Then AColor(6) else
      If Chrs='07' Then AColor(7) else
      If Chrs='08' Then AColor(8) else
      If Chrs='09' Then AColor(9) else
      If Chrs='10' Then AColor(10) else
      If Chrs='11' Then AColor(11) else
      If Chrs='12' Then AColor(12) else
      If Chrs='13' Then AColor(13) else
      If Chrs='14' Then AColor(14) else
      If Chrs='15' Then AColor(15) else
      If Chrs='RE' Then AColor(Urec^.RegularColor) Else
      If Chrs='PR' Then AColor(Urec^.PromptColor) Else
      If Chrs='IN' Then AColor(Urec^.InputColor) Else
      If Chrs='BX' Then AColor(Urec^.BoxColor) Else
      If Chrs='ST' Then AColor(urec^.StatColor) Else
      If Chrs='CM' Then AColor(urec^.CmdColor) Else
      If Chrs='MS' Then AColor(Urec^.MiscColor) Else
      If Chrs='IS' Then AColor(Urec^.InSideColor) Else
      If Chrs[1]='~' then Delay(Valu(Chrs[2])*1000) Else
      {If Chrs='HD' Then Begin WriteHdr(Copy(S,i+3,Length(S))); Exit; End Else}
      If Chrs='MB' Then Print(CurMsgAreaName) else
      If Chrs='CR' Then PrintLn('') else
      {If Chrs='RM' Then MCIWrite(RandRumor) else}
      If Chrs='FN' Then Print(Strr(CurFileArea)) else
      If Chrs='FA' Then Print(CurFileAreaName) else
      {If Chrs='FN' then Print(FilePos(AFile)) else}
      If Chrs='CC' Then Print(Strr(CurConf)) else

      If Chrs='%%' Then
      Begin
        IncANSi:=Copy(S,i+3,12);
        Delete(S,I,Length(IncANSi));
        PrintMsgInclude(CNF^.NetDir+INCANSi);
      End
     Else
      If Chrs='##' Then
      Begin
        IncANSi:=Copy(S,i+3,12);
        Delete(S,I,Length(IncANSi));
        PrintInclude(CNF^.MenuDir+INCANSi);
      End
     Else
      If Chrs='@@' Then
      Begin
        ExtFile:=Copy(S,i+3,16);
        Delete(S,I,Length(ExtFile));
        RunFile(ExtFile, '');
      End;
      Inc(I,3);
     End
    Else 
     Begin
       Print(S[i]);
       inc(i);
     End;
    Until I > Length(s);
  End;

Procedure MCIPrint(S:string);

Var Pause,I:Integer;
    IncANSi:String[13];
    ExtFile:Str80;
    Chrs:String[2];
    ch : char;
Begin
  If Length(S)=0 then exit;
  I:=1;
  Repeat
    if s[i]='`' then
    Begin
      ch := s[i+ 1];
      i  := i + 2;
      if Ch='0' then AColor(0) else
      If Ch='1' Then AColor(1) else
      If Ch='2' Then AColor(2) else
      If Ch='3' Then AColor(3) else
      If Ch='4' Then AColor(4) else
      If Ch='5' Then AColor(5) else
      If Ch='6' Then AColor(6) else
      If Ch='7' Then AColor(7) else
      If Ch='8' Then AColor(8) else
      If Ch='9' Then AColor(9) else
      If Ch='A' Then AColor(10) else
      If Ch='B' Then AColor(11) else
      If Ch='C' Then AColor(12) else
      If Ch='D' Then AColor(13) else
      If Ch='E' Then AColor(14) else
      If Ch='F' Then AColor(15) else
    end
   else If s[i]='|' then
    Begin
      Chrs:=UpString(Copy(s,i+1,2));
      If Chrs='EC' then ModemPrint(#27);
      If Chrs='UN' then Print(Strr(Unum));
      If Chrs='UH' Then Print(Urec^.Handle);
      If Chrs='RN' then Print(Urec^.RealName) Else
      If Chrs='AG' Then Print(Strr(Uage(Urec^.Age))) Else
      If Chrs='SX' then Print(Urec^.Gender) Else
      If Chrs='NC' Then Print(Strr(Urec^.NumCalls)) Else
      If Chrs='PS' Then Print(Strr(Urec^.Posts)) Else
      If Chrs='UP' Then Print(Strr(Urec^.Uploads)) Else
      If Chrs='DN' Then Print(Strr(Urec^.Downloads)) Else
      If Chrs='LV' Then Print(Strr(Urec^.Lvl)) Else
      If Chrs='AF' Then Print(Urec^.AccessFlags) Else
      If Chrs='FP' Then Print(Strr(Urec^.FilePts)) Else
      If Chrs='NO' Then Print(Urec^.UserNote) Else
      If Chrs='UK' Then Print(Strr(Urec^.UpK)) Else
      If Chrs='DK' Then Print(Strr(Urec^.DownK)) Else
      If Chrs='TB' Then Print(Strr(Urec^.TimeBank)) Else
      If Chrs='UR' Then Print(Strr(Urec^.Up_Down_Ratio)) Else
      If Chrs='DR' Then Print(Strr(Urec^.Up_Down_K_Ratio)) Else
      If Chrs='PC' Then Print(Strr(Urec^.PCR)) Else
      If Chrs='TL' Then Print(Strr(Urec^.Timeleft));
      If Chrs='BE' Then Print(^G) Else
      If Chrs='CL' Then Cls Else
      If Chrs='BA' Then Print(Strr(BaudRate)) Else
      If Chrs='NU' Then Begin OpenUFile(CurUfile); Print(Strr(NumUsers)); CloseUFile; End Else
      IF Chrs='DA' Then Print(DateStr(Now));
      If Chrs='TI' Then Print(TimeStr(Now));
      If Chrs='01' Then AColor(1) else
      If Chrs='02' Then AColor(2) else
      If Chrs='03' Then AColor(3) else
      If Chrs='04' Then AColor(4) else
      If Chrs='05' Then AColor(5) else
      If Chrs='06' Then AColor(6) else
      If Chrs='07' Then AColor(7) else
      If Chrs='08' Then AColor(8) else
      If Chrs='09' Then AColor(9) else
      If Chrs='10' Then AColor(10) else
      If Chrs='11' Then AColor(11) else
      If Chrs='12' Then AColor(12) else
      If Chrs='13' Then AColor(13) else
      If Chrs='14' Then AColor(14) else
      If Chrs='15' Then AColor(15) else
      If Chrs='RE' Then AColor(Urec^.RegularColor) Else
      If Chrs='PR' Then AColor(Urec^.PromptColor) Else
      If Chrs='IN' Then AColor(Urec^.InputColor) Else
      If Chrs='BX' Then AColor(Urec^.BoxColor) Else
      If Chrs='ST' Then AColor(urec^.StatColor) Else
      If Chrs='CM' Then AColor(urec^.CmdColor) Else
      If Chrs='MS' Then AColor(Urec^.MiscColor) Else
      If Chrs='IS' Then AColor(Urec^.InSideColor) Else
      If Chrs[1]='~' then Delay(Valu(Chrs[2])*1000) Else
      {If Chrs='HD' Then Begin WriteHdr(Copy(S,i+3,Length(S))); End Else}
      If Chrs='MB' Then Print(CurMsgAreaName) else
      If Chrs='CR' Then PrintLn ('') else
      {If Chrs='RM' Then MCIWrite(RandRumor) else}
      If Chrs='FN' Then Print(Strr(CurFileArea)) else
      If Chrs='FA' Then Print(CurFileAreaName) else
      {If Chrs='FN' then Print(FilePos(AFile)) else}
      If Chrs='CC' Then Print(Strr(CurConf));
      If Chrs='%%' Then
      Begin
        IncANSi:=Copy(S,i+3,12);
        Delete(S,I,Length(IncANSi));
        PrintMsgInclude(CNF^.NetDir+INCANSi);
      End
     Else
      If Chrs='##' Then
      Begin
        IncANSi:=Copy(S,i+3,12);
        Delete(S,I,Length(IncANSi));
        PrintInclude(CNF^.MenuDir+INCANSi);
      End;
      If Chrs='SY' Then Print(CNF^.FullSysName) Else
      Inc(I,3);
     End
    Else
     Begin
       Print(S[i]);
       inc(i);
     End;
    Until I > Length(s);
  End;

Procedure MCIPrintLn(S:string);
Begin
  MCiPrint(s);
  PrintLn('');
End;

Procedure MCIWriteLn(S:string);
Begin
  MciWrite(s);
  PrintLn('');
End;

Procedure HitKey;
Var Z:Char;
    B:Boolean;
    Parse:Byte;

Procedure EraseIt(X,Y,Len:integer);
Var I:Integer;
Begin
  GoXY(X,Y);
  For I:=Len downto 1 do Write(^H);
  For I:=1 to Len do Write(' ');
  For I:=Len downto 1 do Write(^H);
End;

Begin
  MCiWrite(MyStr^.HitAKey);
  Repeat Until (CharPressed) or (HungUpOn);
  B:=GetChar(Z);
  For Parse:=1 to Length(MyStr^.HitAKey) Do If MyStr^.HitAKey[Parse]='|' Then Delete(MyStr^.HitAKey,Parse,3);
  EraseIt(WhereX,WhereY,Length(MyStr^.HitAKey));
End;

Function StripANSi(S:String):String;
Var X:Byte;
Begin
  TmpStr:=S;
  For X:=1 to Length(S) Do
  Begin
    If (TmpStr[X]=#27) And (TmpStr[X+1]='[') Then
    Begin
      While (Not (TmpStr[X] in ['A','B','C','D','H','J','K','f','h','l','m','p','s','u'])) do Delete(TmpStr,X,1);
      Delete(TmpStr,X,1);
    End;
  End;
  StripANSi:=TmpStr;
End;

Procedure PrintFile(fn:str80);
Var
  Txt:Text;
  Ch:char;
  Chk:String[2];

Begin
  Assign(Txt,FN);
  ReSet(Txt);

  While (Not Eof(Txt)) and (Not HungUpOn) Do
  Begin
    Read(Txt,Ch);
    If Ch='|' Then
    Begin
      Read(Txt,Ch); Chk:=UpCase(Ch);
      Read(Txt,Ch); Chk:=Chk+UpCase(Ch);
      If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
      If Chk='CL' Then Cls Else
      If Chk='HK' Then HitKey;
      If Chk='UN' then Print(Strr(Unum));
      If Chk='UH' Then Print(Urec^.Handle);
      If Chk='RN' then Print(Urec^.RealName) Else
      If Chk='AG' Then Print(Strr(Uage(Urec^.Age))) Else
      If Chk='SX' then Print(Urec^.Gender) Else
      If Chk='NC' Then Print(Strr(Urec^.NumCalls)) Else
      If Chk='PS' Then Print(Strr(Urec^.Posts)) Else
      If Chk='UP' Then Print(Strr(Urec^.Uploads)) Else
      If Chk='DN' Then Print(Strr(Urec^.Downloads)) Else
      If Chk='LV' Then Print(Strr(Urec^.Lvl)) Else
      If Chk='AF' Then Print(Urec^.AccessFlags) Else
      If Chk='FP' Then Print(Strr(Urec^.FilePts)) Else
      If Chk='NO' Then Print(Urec^.UserNote) Else
      If Chk='UK' Then Print(Strr(Urec^.UpK)) Else
      If Chk='DK' Then Print(Strr(Urec^.DownK)) Else
      If Chk='TB' Then Print(Strr(Urec^.TimeBank)) Else
      If Chk='UR' Then Print(Strr(Urec^.Up_Down_Ratio)) Else
      If Chk='DR' Then Print(Strr(Urec^.Up_Down_K_Ratio)) Else
      If Chk='PC' Then Print(Strr(Urec^.PCR)) Else
      If Chk='TL' Then Print(Strr(Urec^.Timeleft));
      If Chk='BE' Then Print(^G) Else
      If Chk='CL' Then Cls Else
      If Chk='BA' Then Print(Strr(BaudRate)) Else
      If Chk='NU' Then Begin OpenUFile(CurUfile); Print(Strr(NumUsers)); CloseUFile; End Else
      IF Chk='DA' Then Print(DateStr(Now));
      If Chk='TI' Then Print(TimeStr(Now));
      If Chk='01' Then AColor(1) else
      If Chk='02' Then AColor(2) else
      If Chk='03' Then AColor(3) else
      If Chk='04' Then AColor(4) else
      If Chk='05' Then AColor(5) else
      If Chk='06' Then AColor(6) else
      If Chk='07' Then AColor(7) else
      If Chk='08' Then AColor(8) else
      If Chk='09' Then AColor(9) else
      If Chk='10' Then AColor(10) else
      If Chk='11' Then AColor(11) else
      If Chk='12' Then AColor(12) else
      If Chk='13' Then AColor(13) else
      If Chk='14' Then AColor(14) else
      If Chk='15' Then AColor(15) else
      If Chk='RE' Then AColor(Urec^.RegularColor) Else
      If Chk='PR' Then AColor(Urec^.PromptColor) Else
      If Chk='IN' Then AColor(Urec^.InputColor) Else
      If Chk='BX' Then AColor(Urec^.BoxColor) Else
      If Chk='ST' Then AColor(urec^.StatColor) Else
      If Chk='CM' Then AColor(urec^.CmdColor) Else
      If Chk='MS' Then AColor(Urec^.MiscColor) Else
      If Chk='IS' Then AColor(Urec^.InSideColor) Else
      If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
      {If Chk='HD' Then Begin WriteHdr(Copy(S,i+3,Length(S))); Exit; End Else}
      If Chk='MB' Then Print(CurMsgAreaName) else
      If Chk='CR' Then PrintLn('') else
      {If Chk='RM' Then MCIWrite(RandRumor) else}
      If Chk='FN' Then Print(Strr(CurFileArea)) else
      If Chk='FA' Then Print(CurFileAreaName) else
      {If Chk='FN' then Print(FilePos(AFile)) else}
      If Chk='CC' Then Print(Strr(CurConf)) else
      If Chk='SY' Then Print (CNF^.FullSysName) Else
    End 
     Else Print(Ch);
  End;
  Close(Txt);
  If HungUpOn Then HangUp;
End;

Procedure Tab(N:Str80; Len:integer);
Var Cnt:Integer;
Begin
  Print(N);
  For Cnt:=length(n) to Len-1 do Print(' ')
End;

Function TabStr(N:Str80; Len:integer):String;
Var Cnt:Integer;
Begin
  TmpStr:=N;
  For Cnt:=length(n) to Len-1 do TmpStr:=TmpStr+' ';
  TabStr:=TmpStr;
End;

PROCEDURE WriteScreen(s:string; x,y,at:integer);
VAR
  i:integer;
BEGIN
  i:=x;
  WHILE (i<80) AND (i-x+1<=length(s)) DO
  WITH disp^[y][i] DO
  BEGIN
    c:=s[i-x+1];
    a:=at;
    inc(i);
  END;
END;

PROCEDURE ReadScreen(VAR s:string; x,y:integer);
VAR
  i:integer;
BEGIN
  s:='';
  FOR i:=x TO 80 DO s:=s+disp^[y][i].c;
END;

Procedure BackSpace(X,Y,Int:Integer);
Var I:Integer;
Begin
 GoXY(X,Y);
 For I:=1 to Int do Print(' ');
 For I:=Int downto 1 do  Print(^H);
End;

procedure Writehdr(q:Str80);
var ice,cnt,a:integer;
      Rp,K:Char;
      Chrs:String[2];
      TXF:Text;

Function MCiLength(S:Str255):Byte;
Var X:Byte;
Begin
  For X:=1 to Length(S) Do
  Begin
    If (S[X]='|') Then Delete(S,X,3);
  End;
  MCiLength:=Length(S);
End;

const l=40;
Begin
  If Emulation=0 Then 
  Begin
    Println(Q);
    Exit;  { How lazy can I be? This SHOULD be an ELSE statement. }
  End;
  If Not(Exist(CNF^.MenuDir+'HEADER.ANS')) Then
  Begin
    Cls;
    Print('[40m[2J[2;1H[22C[0;34mÜ['+Strr(Length(q)+6)+'CÜ[3;1H[17CÜ  Ü[s');
    Print('[u[1;44mÜ[46mß[44mÜ[37;40mÝ['+Strr(Length(q)+2)+'CÞ[34;44mÜ[46mß[44mÜ[0;34mÜ  Ü');
    Print('[4;1H[15CÜ[1;44mÜ[46mß[44mÜÜ[46mß[36mÜßÜ[37;40mÝ '); MCIWrite(Q); Print(' Þ[s[28C');
    Print('[u[36;46mÜßÜ[34mß[44mÜÜ[46mß[44mÜ[0;34mÜ[5;1H[14Cß[1;44mß[40m[s');
    Print('[u[46mÜ[36mßÜÜß[34mÜ[44mß[46mÜ[37;40mÝ['+Strr(length(q)+2)+'CÞ[34;46mÜ[44mß[40m[s');
    Print('[u[46mÜ[36mßÜÜß[34mÜ[44mß[0;34mß[6;1H[16Cß[1;44mß[46mÜÜ[40m[s');
    Print('[u[44mß[0;34mß ß['+Strr(length(q)+4)+'Cß ß[1;44mß[46mÜÜ[44mß[0;34mß[7;1H[18Cßß');
    Print('['+Strr(length(q)+12)+'Cßß'^M^M);
    Print('[0;0m');
  End
 Else
  Begin
    Assign(TXF,CNF^.MenuDir+'HEADER.ANS');
    Reset(TXF);
    Chrs:='';
    While (Not EOF(TXF)) and (NOT hungupon) do
    Begin
      Read(TXF,K);
      If K='|' Then
      Begin
        Read(TXF,K); Chrs:=UpCase(K);
        Read(TXF,K); Chrs:=Chrs+UpCase(K);
        If Chrs='RP' Then
        Begin
          Read(Txf,RP);
          For iCE:=1 to MCiLength(q) do Print(RP);
        End;
        If Chrs='HD' Then MCIWrite(q) Else
        If Chrs[1]='~' then Delay(Valu(Chrs[2])*1000) Else
        If Chrs='HA' Then Print(Urec^.Handle) Else
        If Chrs='TI' Then Print(TimeStr(Now)) Else
        If Chrs='DA' Then Print(DateStr(Now)) Else
        If Chrs='SY' Then Print(CNF^.FullSysName) Else
{       If Chrs='UN' Then Print(Unum) Else  }
        If Chrs='UH' Then Print(Urec^.Handle) Else
{       If Chrs='UT' Then Print(Timeleft);  }
        IF Chrs='DA' Then Print(DateStr(Now));
        If Chrs='TI' Then Print(TimeStr(Now));
        If Chrs='BE' Then Print(^G) Else
        If Chrs='CL' Then Cls Else
{       If Chrs='BA' Then Print(BaudStr) Else  }
{       If Chrs='NU' Then OpenUFile(CurUfile); Print(Strr(NumUsers)); CloseUFile; Else  }
        If Chrs='01' Then AColor(1) Else
        If Chrs='02' Then AColor(2) Else
        If Chrs='03' Then AColor(3) Else
        If Chrs='04' Then AColor(4) Else
        If Chrs='05' Then AColor(5) Else
        If Chrs='06' Then AColor(6) Else
        If Chrs='07' Then AColor(7) Else
        If Chrs='08' Then AColor(8) Else
        If Chrs='09' Then AColor(9) Else
        If Chrs='10' Then AColor(10) Else
        If Chrs='11' Then AColor(11) Else
        If Chrs='12' Then AColor(12) Else
        If Chrs='13' Then AColor(13) Else
        If Chrs='14' Then AColor(14) Else
        If Chrs='15' Then AColor(15) Else
        If Chrs='MB' Then Print(CurMsgAreaName) Else
        If Chrs='MA' Then Print(CurFileAreaName) Else
{       If Chrs='CC' Then Print(FakeConf) Else  }
        If Chrs='CR' Then Println('') Else
        If Chrs='RE' Then AColor(Urec^.RegularColor) Else
        If Chrs='PR' Then AColor(Urec^.PromptColor) Else
        If Chrs='IN' Then AColor(Urec^.InputColor) Else
        If Chrs='BX' Then AColor(Urec^.BoxColor) Else
        If Chrs='ST' Then AColor(urec^.StatColor) Else
        If Chrs='CM' Then AColor(urec^.CmdColor) Else
        If Chrs='MS' Then AColor(Urec^.MiscColor) Else
        If Chrs='IS' Then AColor(Urec^.InSideColor) Else
        If Chrs='SY' Then Print(CNF^.FullSysName) Else
        If Chrs='FN' Then Print(Strr(CurFileArea)) else
        If Chrs='TL' Then Print(Strr(Urec^.TimeLeft));
     End Else Print(K);
   End;
   Close(TXF);
  End;
End;

Function DotYesNo(b:boolean):Char;
Begin
 if b = true then DotYesNo:='þ' else DotYesNo:=' ';
end;

Function YesNo(b:boolean):String;
Begin
 if b = true then YesNo:='Yes' else YesNo:='No ';
end;

Function YeaNa(S:String; Def:Boolean):Boolean;
Var x,y:Byte;
    k:Char;
    zifly:Byte;

  Procedure redo;
  Var I:Integer;
  Begin
    If Def Then
    Begin
      AColor(Urec^.CmdColor);      Print(' Yes ');
      AColor(Urec^.RegularColor);  Print(' No ');
      Print(#27+'[9D');
    End
  Else
    Begin
      AColor(Urec^.RegularColor); Print(' Yes ');
      AColor(Urec^.CmdColor);     Print(' No ');
      Print(#27+'[9D');
    End;
  End;

  Procedure toggle;
  Begin
    If Def Then Def:=False Else Def:=True;
    redo;
  End;

  Procedure possibly(FC_Is_GOD:Boolean);
  Begin
    If FC_Is_God Then Println('Yes') Else Println('No');
    Def:=FC_Is_God;
  End;

  Begin
    If (Emulation>0) Then
    Begin
      MCIWrite(S+' ');
      Redo;
      Repeat
        GetChar(K);
        If K=#0 Then GetChar(K);
        K:=UpCase(K);
        If (K='Y') and (Def=False) Then toggle Else
        If (K='N') and (Def=True) Then toggle Else
        If (K='4') Or (K='6') Or (K=#27) Or (K='K') Or (K='M') Or (K=#32) Then toggle Else
      Until (K=#13) Or (K='Y') or (K='N') Or HungUpOn;
      YeaNa:=Def;
      AColor(Urec^.RegularColor);
      Println('');
    End
  Else
    Begin
      MCIWrite(S+' ');
      If Def Then Print('(Y/n): ') Else Print('(y/N): ');
      GetChar(K);
      K:=UpCase(K);
      If ((K='Y') Or (K='y')) Then possibly(True);
      If ((K='N') Or (K='n')) Then possibly(False);
      If K=#13 Then Possibly(Def);
      YeaNa:=Def;
    End;
  End;

Function TextMenu(M:MenuBarRec):Char;
Var Ch:Char;
   Cnt:Byte;

  Procedure WriteList;
  Var X:Byte;
      Z:Byte; 
  Begin
    With M Do
    Begin
      Println(MenuName);
      For X:=1 to NumChoices Do 
        For Z:=2 to Length(Choice[X]) Do 
        Begin
          If Z=(M.HighChr[X]+1) Then 
          Begin
            Print(+Choice[X][Z]+')');
            Inc(Z);
          End;
          Print(Choice[X][Z]);
        End;
    End;
  End;

Begin
  Writelist;
  Input:=UpCase(M.Choice[M.DefChoice][2]);
  Input:=Prompt(1,'['+UpCase(M.Choice[M.DefChoice][2])+']:',Urec^.MenuType=1);
  Ch:=UpCase(Input[1]);
  If Ch='' Then TextMenu:=UpCase(M.Choice[M.DefChoice][2]) 
 Else
  For Cnt:=1 to Length(M.KeyCmds) Do If Ch=M.KeyCmds[Cnt] then TextMenu:=Ch;
End;

Function BarMenu(M:MenuBarRec):Char;
Var Key,LastChoice,CurChoice:Byte;
    iCE,Ch:Char;

Procedure WriteSelect;
Var Zip:Byte;
Begin
  GoXY(M.MenuX[LastChoice],M.MenuY[LastChoice]);
  AColor(Urec^.RegularColor);
  For Zip:=1 to Length(M.Choice[LastChoice]) Do
  Begin
    If Zip=(M.HighChr[LastChoice]+1) Then 
    Begin
      AColor(Urec^.StatColor); AColor(11);
      Print(M.Choice[LastChoice][Zip]);
      AColor(Urec^.RegularColor)
    End Else Print(M.Choice[LastChoice][Zip]);
  End;
  GoXY(M.MenuX[CurChoice],M.MenuY[CurChoice]);
  Acolor(Urec^.CmdColor);
  Print(M.Choice[CurChoice]);
End;

Procedure INCCurChoice;
Begin
  LastChoice:=CurChoice;
  Inc(CurChoice);
  If CurChoice>M.NumChoices then CurChoice:=1;
End;

Procedure DecCurChoice;
Begin
  LastChoice:=CurChoice;
  Dec(CurChoice);
  If CurChoice<1 then CurChoice:=M.NumChoices;
End;

Procedure WriteList;
Var Zip,X:Byte;

Begin
  With M Do
  Begin
    BarX:=WhereX;
    BarY:=WhereY;
    AColor(Urec^.RegularColor); Print(MenuName); ClsEol; Println('');
    AColor(Urec^.MiscColor);
    Print('³');
    AColor(Urec^.RegularColor);
    For X:=1 to NumChoices Do
    Begin
      MenuX[X]:=WhereX;
      MenuY[X]:=WhereY;

      For Zip:=1 to Length(M.Choice[X]) Do
      Begin
        If Zip=(M.HighChr[X]+1) Then 
        Begin
          AColor(Urec^.StatColor); AColor(11);
          Print(M.Choice[X][Zip]);
          AColor(Urec^.RegularColor)
        End Else Print(M.Choice[X][Zip]);
      End;
    End;
    AColor(Urec^.MiscColor);
    Print('³');
    Acolor(Urec^.RegularColor);
  End;
End;

Procedure BarInput;
Var Cnt:Byte;

  Procedure EscCode;
  Var Arrow:Char;
  Begin
    Repeat
      GetChar(Arrow);
      GetChar(Arrow);
      Case Arrow Of
        'B':IncCurChoice;
        'A':DecCurChoice;
        'C':IncCurChoice;
        'D':DecCurChoice;
      End;
    Until (Ch<>'[') or Hungupon;
    If HungUpOn Then HangUp;
  End;

Begin
  Repeat If HungUpOn Then HangUP; Until(CharPressed) or (HungUpOn);
  GetChar(Ch);

  If Ch=#0 Then 
  Begin
    GetChar(Ch);
    Case Upcase(Ch) Of 
      'H','M':IncCurChoice;
      'P','K':DecCurChoice;
    End;
    Ch:='þ';
  End
 Else { else, it must be a non-extended character }
  Begin
    Case Ch Of
      #27:EscCode;
      ' ':IncCurChoice;
       ^H:DecCurChoice;
    End;
    Ch:=UpCase(Ch);
    For Cnt:=1 to Length(M.KeyCmds) Do If Ch=M.KeyCmds[Cnt] then
    Begin
      If Ch<>'?' then
      Begin
        LastChoice:=CurChoice;
        CurChoice:=Cnt;
      End;
    End;
  End;
  If Ch=#13 Then iCE:=M.KeyCmds[CurCHoice] Else iCE:=Ch;
End;

Begin
  If Emulation >=1 Then
  Begin
    Key:=0;
    iCE:=#0;
    CurChoice:=M.DefChoice;
    LastChoice:=M.DefChoice;
    WriteList;
    WriteSelect;
    Repeat
      BarInput;
      If (Ch In ['þ',' ',^H,#27]) or (Pos(ICE,M.KeyCmds)<>0) then WriteSelect;
    Until (iCE=#13) or (Pos(iCE,M.KeyCmds)>0) or (HungUpOn);
    AColor(Urec^.RegularColor);
    If HungUpOn Then HangUp;
    BarMenu:=iCE;
    GoXy(M.BarX,M.BarY);
    Println(#27+'[K');
    Print(#27+'[K');
    GoXy(M.BarX,M.BarY);
  End Else BarMenu:=TextMenu(M);
End;


Function Barz(M:MenuBarRec; Fn:Str40; GetEm:Boolean):Char;
Var Cnt,Key,LastChoice,CurChoice:Byte;
    iCE,Ch:Char;
    List,L:String;
    RB,RC,FC,BC:Byte;
    Cmd:String;
    X1,Y1,FG,BG,R1,R2:String;

Procedure SetDefaults;
Begin
  With M do
  Begin
    MenuName:='';
    KeyCmds:='';
  End;
End;

Procedure Parseln(S:String; Var X,Y,FC,BC,RC,RB,Cmd,L:String);

  Procedure Cut(Var Instr,OutStr:String);
  Var Tmp:String; 
  Begin
    Tmp:=S;
    If Pos(',',Instr)>0 THen Tmp:=Copy(Instr,1,Pos(',',Instr)-1) Else 
     Tmp:=Copy(Instr,1,Length(Tmp));
     Delete(Instr,1,Pos(',',Instr));
     OutStr:=Tmp;
  End;

Begin
  TmpStr:=S;
  Cut(TmpStr,X);
  Cut(TmpStr,Y);
  Cut(TmpStr,RC);
  Cut(TmpStr,RB);
  Cut(TmpStr,BC);
  Cut(TmpStr,FC);
  Cut(TmpStr,Cmd);
  Cut(TmpStr,L);
End;

Procedure ReadXYDat;
Var Txt:Text;
Begin
  cnt:=0;
  SetDefaults;
  Assign(Txt,CNF^.MenuDataDir+FN);
{$I+}  Reset(Txt); {$I-}
  If IOResult<>0 Then
  Begin
    Acolor(12);
    Println('.BAR or .XY File: File Not Found.');
    Acolor(7);
    Delay(2000);
    Exit;
  End;

  While Not EOF(Txt) do
  Begin
    Readln(Txt,L);
    If L[1]<>';' Then
    Begin
      INC(Cnt);
      ParseLn(L,X1,Y1,FG,BG,R1,R2,Cmd,List);
      If (Cnt=1) and (X1='*') Then X1:=Strr(WhereX) Else 
          If X1='*' Then X1:=Strr(M.MenuX[Cnt-1]+Length(M.Choice[Cnt-1]));
      M.MenuX[Cnt]:=Valu(X1);
      M.MenuY[Cnt]:=Valu(Y1);
      RB:=Valu(FG);
      RC:=Valu(BG);
      FC:=Valu(R1);
      BC:=Valu(R2);
      M.KeyCmds:=M.KeyCmds+Cmd[1];
      If GetEm Then
      Begin
        M.NumChoices:=Cnt;
        M.Choice[Cnt]:=' '+List+' ';
      End;
    End;
  End;
  Close(Txt);
End;

Procedure WriteSelect;
Begin
  GoXY(M.MenuX[LastChoice],M.MenuY[LastChoice]);
  Color(RC,RB); MCiWrite(M.Choice[LastChoice]);
  GoXY(M.MenuX[CurChoice],M.MenuY[CurChoice]);
  Color(FC,BC); MCiWrite(M.Choice[CurChoice]);
End;

Procedure INCCurChoice;
Begin
  LastChoice:=CurChoice;
  Inc(CurChoice);
  If CurChoice>M.NumChoices then CurChoice:=1;
End;

Procedure DecCurChoice;
Begin
  LastChoice:=CurChoice;
  Dec(CurChoice);
  If CurChoice<1 then CurChoice:=M.NumChoices;
End;

Procedure WriteList;
Var X:Byte;
Begin
  With M Do
  Begin
    Color(RC,RB);
    For X:=1 to NumChoices Do 
    Begin
      GoXY(MenuX[X],MenuY[X]);
      MCiWrite(Choice[X]);
    End;
  End;
End;

Procedure BarzReset;
Var X:Byte;
Begin
  For X:=1 to MaxChoices Do M.Choice[X]:='';
  M.NumChoices:=0;
  M.KeyCmds:='';
  M.DefChoice:=1;
  M.MenuName:='';
End;

Procedure BarInput;
Var Cnt:Byte;

  Procedure EscCode;
  Var Arrow:Char;
  Begin
    Repeat
      GetChar(Arrow);
      GetChar(Arrow);
      Case Arrow Of
        'B':IncCurChoice;
        'A':DecCurChoice;
        'C':IncCurChoice;
        'D':DecCurChoice;
      End;
    Until (Ch<>'[') or Hungupon;
    If HungUpOn then HangUP;
  End;

Begin
  Repeat If HungUpOn then HangUP; Until(CharPressed) or (HungUpOn);
  GetChar(Ch);

  If Ch=#0 Then 
  Begin
    GetChar(Ch);
    Case Upcase(Ch) Of 
      'P','M':IncCurChoice;
      'H','K':DecCurChoice;
    End;
    Ch:='þ';
  End
 Else { else, it must be a non-extended character }
  Begin
    Case Ch Of
      #27:EscCode;
      ' ':IncCurChoice;
       ^H:DecCurChoice;
    End;
    Ch:=UpCase(Ch);
    For Cnt:=1 to Length(M.KeyCmds) Do If Ch=M.KeyCmds[Cnt] then
    Begin
      LastChoice:=CurChoice;
      CurChoice:=Cnt;
    End;
  End;
  If Ch=#13 Then iCE:=M.KeyCmds[CurCHoice] Else iCE:=Ch;
End;

Procedure RipSelection;
Begin
End;

Begin
  If GetEm then BarzReset;
  Key:=0;
  iCE:=#0;
  ReadXYDat;
  CurChoice:=M.DefChoice;
  LastChoice:=M.DefChoice;
  WriteList;
  WriteSelect;
  Repeat
    BarInput;
    If (Ch In ['þ',' ',^H,#27]) or (Pos(ICE,M.KeyCmds)<>0) then WriteSelect;
  Until (iCE=#13) or (Pos(iCE,M.KeyCmds)>0) or (HungUpOn);
  AColor(Urec^.RegularColor);
  If HungUpOn then HangUP;
  Barz:=M.KeyCmds[CurChoice];
  BarzReset;
End;

Procedure WriteErr(S:Str80);
Begin
  AColor(12);
  Println(S);
  Delay(2000);
  AColor(7);
End;

Function Prompt(Len:Byte; Str:Str80; HotKey:Boolean): str80;
begin
  UseHotKey:=HotKey;
  StatusBar(CurStat);
  If TimeLeft<6 Then MCiPrintln(Strr(Urec^.TimeLeft)+' mins left!');
  MCiWrite('|PR'+Str);
  AColor(Urec^.InputColor);
  TmpStr := GetLn(Len);
  If HungUpOn then Hangup;
  Prompt:=TmpStr;
  AColor(Urec^.RegularColor);
  If (Not Dots) Then WriteLog(1,1,Str+' '+TmpStr);
  StatusBar(CurStat);
end;

Function EditPrompt(Len:Byte; Str:String):String;
Begin
  If TimeLeft<6 Then MCiPrintln(Strr(Urec^.TimeLeft)+' mins left!');

  If Emulation in [1,2,3,4,9] Then 
  Begin
    MCiWrite('|PR'+Str);
    Edit(Input,WhereX,WhereY,Len,False);
  End Else Input:=Prompt(Len,Str,False);

  EditPrompt:=Input;
End;

Function Edit(Var S:String; X,Y,Len:Byte; MultiFields:Boolean):Char;
Var Done,InsertMode:Boolean;
    Ch:Char;
    Holder:String;
    CurPos:Integer;
    
  Procedure StripEndSpaces;
  Var Index:Byte;
  Begin
    Index:=Length(S);
    While S[Index]=' ' Do
    Begin
      Delete(S,Index,1);
      Dec(Index);
    End;
  End;

  Procedure UpdateToEOL;
  Var I:Byte;
  Begin
    For I:=CurPos To Length(S) Do Print(S[I]);
    For I:=Length(S) To Len-1 Do Print(' ');
  End;

  Procedure Update;
  Var I:Byte;
  Begin
    For I:=CurPos To Length(S) Do Print(S[I]);
  End;

  Procedure Back_Space;
  Begin
    If (CurPos>1) Then
    Begin
      Dec(CurPos);
      Delete(S,CurPos,1);
      Print(^H+' '+^H);
      Update; Print(' ');
    End;
  End;

  Procedure DelChar;
  Begin
    Delete(S,CurPos,1);
    UpDate; Print(' ');
  End;

  Procedure UpDateCursorPos;
  Begin
    If CurPos<1 Then CurPos:=1;
    If CurPos>Len Then CurPos:=Len;
    GoXY(CurPos+(X-1),Y);
  End;

  Procedure ClearLine;
  Begin
    CurPos:=1;
    UpDateCursorPos; S:='';
    UpDateToEOL;
  End;

  Procedure Typer;
  Begin
    If Length(S)<>Len Then
    Begin
      If InsertMode Then
      Begin
        Insert(Ch,S,CurPos);
        Update;
      End
     Else
      Begin
        Print(Ch);
        S[CurPos]:=Ch;
      End;
      If CurPos>=Length(S) Then S[0]:=Chr(CurPos);
      Inc(CurPos);
    End;
  End;

  Procedure ExitCode(C:Char);
  Begin
    Done:=True;
    Edit:=C;
  End;

  Procedure EscCode;
  Var Arrow:Char;
  Begin
    Repeat
      GetChar(Arrow);
      GetChar(Arrow);
      Case Arrow Of
        'C':Inc(CurPos);
        'D':Dec(CurPos);
      End;
    Until (Ch<>'[') or Hungupon;
    If HungUpOn then HangUP;
  End;

Begin
  Done:=False; InsertMode:=True;
  Holder:=S;

  CurPos:=1;
  GoXY(X,Y); AColor(Urec^.CmdColor);
  UpdateToEol;
  CurPos:=Length(S)+1;
  UpdateCursorPos;

  Repeat
    Repeat If HungUpOn then HangUP; Until(CharPressed) or (HungUpOn);
    GetChar(Ch);

    If Ch=#0 Then
    Begin
      GetChar(Ch);
      Case UpCase(Ch) Of
        #71:CurPos:=1;     (*Home*)
        #75:Dec(CurPos);   (*Left*)
        #77:Inc(CurPos);   (*Right*)
        #79:CurPos:=Length(S)+1; (*End*)
        #83:DelChar;
      End;  
    End
   Else
    Case Ch Of
      #1:CurPos:=1;        (*Home*)
      #8:Back_Space;
      #13:ExitCode(#13);
      #26:CurPos:=Length(S)+1; (*End*)
      #27:EscCode;
       ^Q:ExitCode(^Q);
       ^S:Dec(CurPos);     (*Left*)
       ^D:Inc(CurPos);     (*Right*)
       ^V,#82:InsertMode:=Not InsertMode;
       ^Y:ClearLine;
      Else Typer;
    End;  
    UpdateCursorPos;
  Until (Done) or (HungUpOn);
  If HungUpOn then Hangup;
  AColor(Urec^.InputColor);
  StripEndSpaces;
  BackSpace(X,Y,Len);
  MCiPrint(S);

End;

Procedure PrintMenu(Cmd:CommandRec);
Begin
End;

Begin
End.
