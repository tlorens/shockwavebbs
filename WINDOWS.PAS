Unit Windows;

Interface

Procedure SaveScreen;
Procedure RestoreScreen;
Procedure DelWin(Num:Byte);
Procedure MakeWin(Num,XX1,YY1,XX2,YY2:Byte);
Procedure GotoWindow(Num:Byte);
Procedure StatusBar(Which:Byte); { allows for multiple statbar types }

Var Screen:Array[0..3999] of Byte;
    SSavX,SSavY:Byte;

Implementation

Uses OpCrt,Records,Vars,User,IO;

Type WinRec=Record
      X1,X2,Y1,Y2:Byte;
      OldX,OldY:Byte;
     End;

Var Win:Array[1..4] of WinRec;
    WinCnt:Byte;

Procedure SaveScreen;
Begin
  Move(Mem[$B800:0],Screen,SizeOf(Screen));
  SSavX:=WhereX;
  SSavY:=WhereY;
End;

Procedure RestoreScreen;
Begin
  Move(Screen,Mem[$B800:0],SizeOf(Screen));
  GotoXY(SSavX,SSavY);
End;

Procedure DelWin(Num:Byte);
Begin
  Dec(WinCnt);
  With Win[Num]Do
  Begin
    X1:=1;
    X2:=1;
    Y1:=80;
    Y2:=25;
  End;
End;

Procedure MakeWin(Num,XX1,YY1,XX2,YY2:Byte);
Begin
  If (Num>4) Then 
  Begin
    Writeln('Window limit exceeded: 4');
    Writeln('Window not created');
    Exit;
  End;
  With Win[Num] Do
  Begin
    X1:=XX1;
    X2:=XX2;
    Y1:=YY1;
    Y2:=YY2;
    OldX:=WhereX;
    OldY:=WhereY;
  End;
End;

Procedure GotoWindow(Num:Byte);
Begin
  With Win[Num] Do 
  Begin
    Window(X1,Y1,X2,Y2);
    GotoXY(OldX,OldY);
  End;
End;

Procedure StatusBar(Which:Byte); { allows for multiple statbar types }
Var SavX,SavY:Byte;

Function IOMsg(B:Byte):String;
Begin
  Case B Of 
    0:IOMsg:='Local';
    1:IOMsg:='Remote';
    2:IOMsg:='Both';
  End;
End;

Function YesNo(B:Boolean):String;
Begin
 If B=True Then YesNo:='Yes' Else YesNo:='No ';
End;

Function EmuType:String;
Begin
  Case Emulation Of
   0:EmuType:='None';
   1:EmuType:='Ansi';
   2:EmuType:='Mono';
   3:EmuType:='RIP';
   4:EmuType:='PVis';
 End;
End;

Begin
   SavX:=WhereX;
   SavY:=WhereY;
   GotoWindow(1);
   GotoXY(1,25);
   Textcolor(15);
   TextBackGround(1);
   With Urec^ Do
   Begin
     Case Which Of
       0:Begin TextColor(1); TextBackGround(0); End;
       1:Write('[',UNum,']',Handle,' ',Lvl,'/',Xlvl,'/',AccessFlags,'/',TimeLeft,' ',BaudRate,' ',Node,' ',EmuType); 
       2:Write('MaxAvail: ',MaxAvail,' MaxMem: ',MemAvail); 
       3:Write('Local: ',LocalLogin,' ³ IOMethod: ',IOMsg(IoMethod),' ³ RemoteInput: ',RemoteInput);
       4:Write('Paramstr:',ParamStr(1),' ',ParamStr(2),' ',ParamStr(3),' ',ParamStr(4),' ',ParamStr(5),' ',ParamStr(6)
         ,' ',ParamStr(7),' ',ParamStr(8),' ',ParamStr(9),' ',ParamStr(10),' ',ParamStr(11),' ',ParamStr(12)
         ,' ',ParamStr(13),' ',ParamStr(14));
       5:Write('Conf: ',CurConf,' ³ Msg: [',CurMsgArea,']',CurMsgAreaName,' ³ Xfer: [',CurFileArea,']',CurFileAreaName); 
       6:Write('Mouse Panel ³ [Chat] [DOS] [+Time] [-Time] [+Level] [-Level] [SysOp] [Nuke]');
       7:Write('UFile: '+CurUFile,' CurMenu: ',CurMenuFile);
       8:Write('[',Unum,'] ',Handle,' PW: ',Password[1]);
     End;
   End;
   ClrEol;
   Textcolor(7);
   TextBackGround(0);
   GotoWindow(2);
   Gotoxy(SavX,SavY);
End;

Begin
End.