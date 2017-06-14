(* ShockWavE Pro PullDown Menu FULLSCREEN Coordinate Editor-
                                                         By: iCE Breaker *)

{
   Started: 09/01/93
   Updated: 09/10/94    wow, 1 full year without work?!?!
   Finised: NEVER!!!
}

Program X_Y_Editor;

Uses opCrt,Dos,ANSiDrv,PullBarz,Cnfgrec,ICEMouse,ICETxt,iCEio1,records;

Type Max=Array[1..8] of Byte;

     ConfRec=Record
       Name,
       FlagStr,
       Password:String[25];
       Description:String[40];
     End;


Const Conf=5;
      Matrix=8;
    { Chat=11; }

Hdr1=';ShockWavE PRO SlideBar Menu Data File';
Hdr2=';Copyright 1995,96 Cyber Realities INC.';
Hdr3=';Compiled by: iCE Breaker';
Hdr4=';';
Hdr5='; Format: X,Y,HiFore,HiBack,RegFore,Regback,ReturnValue,Text';
Hdr6=';';

Var
   SavX,SavY:Max;
   Pick,X,Y:Integer;
   CurX,CurY,Total,Cnt,Cur:Byte;
   Txt:Text;
   Ch:Char;
   Done,Quit:Boolean;
   Bars:PullBarzRec;
   Xit:String;
   RegColor,RegBack,BarForeGround,BarBackGround:String;
   FCRec:File Of ConfRec;
   Confr:ConfRec;
   ConfName:Array[1..5] of String[25];

Procedure Intro;
Begin
End;

Procedure Endit;
Begin
End;

Procedure GetConferences(Which:String);
Begin
  Cnt:=0;
  Assign(FCRec,CNF^.DataDir+Which);
  {$I-} ReSet(FCRec); {$I+}
   While Not EOF(FCRec) do
   Begin
     Inc(Cnt);
     Read(FCRec,Confr);
     ConfName[cnt]:=Confr.Name;
   End;
   Total:=Cnt;
   Close(FCRec);
End;

Function GetANSiFile(FN:String):Boolean;
var S:String;
Begin
  GetANSiFile:=True;
  Assign(Txt,FN);
  If IOResult<>0 then
  Begin
    GetANSiFile:=False;
    Exit;
  End;
  ReSet(Txt);
  While Not Eof(Txt) do
  begin
    Readln(Txt,S);
    WriteStringAnsi(s);
  End;
Close(Txt);
End;

Procedure WriteDATFile(T:Byte; X,Y:Max);
Var FN:String;
Begin
  Case T Of
    1:FN:='MSGCONF.XY';
    2:FN:='XFRCONF.XY';
    3:FN:='MATRIX4.XY';
  End;
  Assign(TxT,CNF^.DataDir+FN);
  ReWrite(Txt);
  Writeln(Txt,Hdr1);
  Writeln(Txt,Hdr2);
  Writeln(Txt,Hdr3);
  Writeln(Txt,Hdr4);
  Writeln(Txt,Hdr5);
  Writeln(Txt,Hdr6);

  If (T=1) or (T=2) Then
  Begin
    For Cnt:=1 to Total do
    Begin
      Writeln(Txt,';Conference ',Cnt,' Location');
      Writeln(Txt,X[Cnt],',',Y[Cnt],',',BarForeground,',',BarBackGround,',',RegColor,',',RegBack,',',cnt,
      ',',ConfName[Cnt]);
    End;
  End
 Else
  If T=3 Then
  Begin
    For Cnt:=1 to Total do
    Begin
      Writeln(Txt,';Matrix Choice ',Cnt,' Location');
      Writeln(Txt,X[Cnt],',',Y[Cnt],',',BarForeground,',',BarBackGround,',',RegColor,',',RegBack,',',cnt,
                  ',',CNF^.MatrixDesc[cnt]);
    End;
  End;
  Close(Txt);
End;

Procedure DisplayANSi(FN:String);
begin
  If NOT GetANSiFile(CNF^.MenuDir+FN) then
  Begin
    HALT;  (* Make FILENOT FOUND Procedure *)
  End;
End;

Procedure CONFXY(T:Byte);
Var X:Byte;
    S:String;
Begin
  S:='';
  Case T Of
   1:DisplayANSI('MSGCONF.ANS');
   2:DisplayANSI('XFRCONF.ANS');
  End;

  For Cnt:=1 to Conf Do
  Begin
    Repeat MouseOn; MouseXY(CurX,CurY); Until Button=1;
    TextColor(15);
    GotoXy(CurX,CurY);
    Write(Cnt);
    SavX[Cnt]:=CurX;
    SavY[Cnt]:=CurY;
    Delay(350);
  End;
  ClrScr;
  MouseOff;
  RegColor:='';
  RegBack:='';
  BarForeGRound:='';
  BarBackGround:='';
  Writeln;
  Writeln('          þ Color List þ         ');
  Writeln('1=Dark Blue       9=Light Blue   ');
  Writeln('2=Dark Green     10=Light Green  ');
  Writeln('3=Dark Cyan      11=Light Cyan   ');
  Writeln('4=Dark Red       12=Light Red    ');
  Writeln('5=Dark Magenta   13=Light Magenta');
  Writeln('6=Brown          14=Yellow       ');
  Writeln('7=Grey           15=Bright White ');
  Writeln('8=Dark Grey                      ');
  Writeln;
  Write('Choice Foreground: '); EditLine(RegColor,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
  Write('Choice Background: '); EditLine(RegBack,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
  Write('Bar Foreground Color: '); EditLine(BarForeGround,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
  Write('Bar Background Color: '); EditLine(BarBackGround,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
  Case T Of
    1:WriteDATFile(1,SavX,SavY);
    2:WriteDATFile(2,SavX,SavY);
  End;
End;

Procedure MATRIXY;
Var X:Byte;
    S:String;
Begin
  S:='';
  MouseOn;
  DisplayANSI('MATRIX4.ANS');
  For Cnt:=1 to Matrix Do
  Begin
    Repeat MouseXY(CurX,CurY); Until Button=1;
    GotoXy(CurX,CurY);
    TextColor(15);
    Write(Cnt);
    SavX[Cnt]:=CurX;
    SavY[Cnt]:=CurY;
    Delay(350);
  End;
 ClrScr;
 MouseOff;
 RegColor:='';
 RegBack:='';
 BarForeGRound:='';
 BarBackGround:='';
 Writeln;
 Writeln('          þ Color List þ         ');
 Writeln('1=Dark Blue       9=Light Blue   ');
 Writeln('2=Dark Green     10=Light Green  ');
 Writeln('3=Dark Cyan      11=Light Cyan   ');
 Writeln('4=Dark Red       12=Light Red    ');
 Writeln('5=Dark Magenta   13=Light Magenta');
 Writeln('6=Brown          14=Yellow       ');
 Writeln('7=Grey           15=Bright White ');
 Writeln('8=Dark Grey                      ');
 Writeln;
 Write('Choice Foreground: '); EditLine(RegColor,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
 Write('Choice Background: '); EditLine(RegBack,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
 Write('Bar Foreground Color: '); EditLine(BarForeGround,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
 Write('Bar Background Color: '); EditLine(BarBackGround,Cur,whereX,WhereY,2,Xit,False,0); Writeln;
 WriteDATFile(3,SavX,SavY);
End;

Procedure EditBar;
Var X:Byte;
    S:String;

Begin
  ClrScr;
  Writeln('Not Yet implemented!');
  Writeln;
  Writeln('-Press a key-');
  Ch:=ReadKey;
  Exit;
  S:='';
  Write('Edit which .BAR file: '); EditLine(S,Cur,WhereX,WhereY,8,Xit,False,0);
  MouseOn;
  DisplayANSI(S+'.ANS');
End;

Function MainPullDown:Byte;
Begin
  ClrScr;
  With Bars Do
  Begin
    MenuName:='ShockWave Pro X-Y Editor';
    Choice[1]:='  Message Conferences  ';
    Choice[2]:='   File Conferences    ';
    Choice[3]:='    Login Matrix       ';
    Choice[4]:='   Edit .BAR File      ';
    Choice[5]:='    Quit To DOS        ';
   NumChoices:=5;
   Defchoice:=1;
   KeyCmds:='ABCDE'+#27;
  End;
  CursorOff;
  MainPullDown:=MenuBar(1,24,6,3,0,15,1,11,0,0,Bars);
End;

Begin
  ClrScr;
  ReadConfig;
  Pick:=0;
  Total:=8;
  Done:=False;
  If Not MouseReset then
  Begin
    writeln('Mouse not found!');
    Writeln('Implementation of arrow keys will be added shortly');
    Halt;
  End
 Else
  Begin
    Repeat
      Pick:=MainPullDown;
      ClrScr;
      Case Pick Of
        1:Begin GetConferences('CONFMSG.LST'); CONFXY(1); End;
        2:Begin GetConferences('CONFXFR.LST'); CONFXY(2); End;
        3:MATRIXY;
        4:EditBar;
        6,5:Done:=True;
      End;
    Until Done=True;
    CursorOn;
 End;
End.