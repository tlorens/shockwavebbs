{
   iB * 11/13/95 - Revision/working Answering routines
}
{$D+,L+}
Unit WaitCall;

Interface

Procedure WaitForCall;

Implementation

Uses OpCrt,Dos,IO,Display,AsmX,GetLogin,Options,Vars,ShkMenus,
     Cnfgrec,GenSubs,Records,Multi,Windows;

Var Instr:String[50];
    FEvent   :File Of EventRec;
    Event    :^EventRec;
    EventCnt :Byte;


Procedure WFC; External; {$L WFC.OBJ}

Procedure LastCallers;
   Var qf:File of lastrec;
   cnt,y1:Integer;
   l:lastrec;

Begin
  If (Not Exist(CNF^.DataDir+'CALLERS.DAT')) Then
  Begin
    Assign(qf,CNF^.DataDir+'CALLERS.DAT');
    ReWrite(qf);
    l.name:='ShockWavE Creator';
    l.callnum:=1;
    l.when:=Now;
    Write(qf,l);
    Close(qf);
  End;

  Assign(qf,CNF^.DataDir+'CALLERS.DAT');
  Reset(qf);
  y1:=4;

  If FileSize(qf)<=9 then
  begin
    Cnt:=0;
    While (NOT Eof(Qf)) or (Cnt>3) DO
    begin
      Read(qf,l);
      Inc(Cnt);
      gotoxy(31,y1);
      textcolor(Cnf^.SysLineColor); Write('#',l.callnum,' ');
      textcolor(CNF^.SysNormalColor); Tab(l.name,25);
      TextColor(Cnf^.SysTopColor); Write(TimeStr(L.When));
      Writeln;
      y1:=y1+1;
    end;
  end
 Else
  If FileSize(qf)>9 then
  begin
    For cnt:=0 to 3 Do
    begin
      Read(qf,l);
      gotoxy(31,y1); textcolor(Cnf^.SysLineColor);
      Write('#',l.callnum,' ');
      textcolor(CNF^.SysNormalColor); Tab(l.name,25);
      TextColor(Cnf^.SysTopColor); Write(TimeStr(L.When));
      Writeln;
      y1:=y1+1;
    End;
  End;
  Close(qf)
End;


Procedure DrawWFC;
Var X,Y: Byte;
      S: String;
Begin
  ClrScr;
  If Exist('WFC.COM') Then
  Begin
    SwapVectors;
    Exec(GetEnv('COMSPEC'),'/C WFC.COM');
    SwapVectors;
  End
 Else Move(Pointer(@WFC)^,Mem[$B800:0],4000);

  LastCallers;
  GotoXy(3,1);
  TextColor(15);
  TextBackGround(1);
  Writeln(OSTag+' '+BuildDate+' (',cplnum,')');
  TextBackground(0);
  GotoXy(14,3);  Write(timestr(now),' ');
  GotoXy(66,16); Write(datestr(now),'  ');
End;

Function CheckEvents:Boolean;
Var DD,MM,YY,DOW:Word;
Begin
  CheckEvents:=False;
  If Exist(CNF^.DataDir+'EVENTS.DAT') Then
  Begin
    Assign(FEvent,CNF^.DataDir+'EVENTS.DAT');
{$I+} ReSet(FEvent); {$I-}
    If IOResult<>0 Then
    Begin
      AColor(12);
      Println('EVENTS.DAT File: not found!');
      AColor(7);
      Delay(2000);
      Close(FEvent);
      Exit;
    End;
    GetDate(YY,MM,DD,DOW);
    Inc(Dow);
    EventCnt:=0;
    New(Event);
    While Not EOF(FEvent) Do
    Begin
      Read(FEvent,Event^);
      If (Event^.Day=8) Then Exit;
      If (Event^.Day=Dow) or (Event^.Day=0) or Match(Event^.Date,DateStr(Now)) Then
      Begin
        Inc(EventCnt);
        CheckEvents:=True;
        Close(FEvent);
        Dispose(Event); { Don't think I want to do this! }
        Exit;
      End;
    End;
    Close(FEvent);
    Dispose(Event);
  End
 Else
  CheckEvents:=False;
End;

Function LocalKey:Byte;
Var Ch:Char;
Begin
  LocalKey:=255;
  If BiosKeyPress then
  Begin
    Ch:=ReadKey;
    If Ch=#0 Then LocalKey:=0;
  End;
End;

Procedure DoMatrix(L:Boolean);
var X:Byte;
   Tmp:String;
Begin
  GotoWindow(2);
  CursorOn;
  AColor(7);
  Cls;
  If Not L Then
  Begin
    If Pos('RING',InStr)   <>0 Then Delete(InStr,Pos('RING',InStr),Length('RING')); { removes RING from connect string }
    If Pos('ARQ',InStr)    <>0 Then Delete(InStr,Pos('ARQ',InStr),Length('ARQ'));
    If Pos('ALT',InStr)    <>0 Then Delete(InStr,Pos('ALT',InStr),Length('ALT'));
    If Pos('V.42BIS',InStr)<>0 Then Delete(InStr,Pos('V.42BIS',InStr),Length('V.42BIS'));
    If Pos('V.32',InStr)   <>0 Then Delete(InStr,Pos('V.32',InStr),Length('V.32'));
    If Pos('MNP',InStr)    <>0 Then Delete(InStr,Pos('MNP',InStr),Length('MNP'));
    If Pos('MNP5',InStr)   <>0 Then Delete(InStr,Pos('MNP5',InStr),Length('MNP5'));
    If Pos('LAPM',InStr)   <>0 Then Delete(InStr,Pos('LAPM',InStr),Length('LAPM'));
    If Pos('NONE',InStr)   <>0 Then Delete(InStr,Pos('NONE',InStr),Length('NONE'));
    If Pos('TELFROM',InStr)<>0 Then Delete(InStr,Pos('TELFROM',InStr),Length('TELFROM'));
    If Pos('ATA',InStr)    <>0 Then Delete(InStr,Pos('ATA',InStr),Length('ATA'));
    If Pos('CONNECT',InStr)<>0 Then Delete(InStr,Pos('CONNECT',InStr),7);

    Tmp:='';
    For X:=1 to Length(InStr) Do 
      If (Not(InStr[X] In [#0..#47,#58..#64,#91..#255])) Then Tmp:=Tmp+InStr[X];
    InStr:=Tmp;

    WriteLog(1,1,'|15Connect: ['+InStr+']');
    BaudRate:=Valu(InStr);
    Emulation:=0;
    IOMethod:=Normal;
    LocalLogin:=False;
    MCiPrintln(MyStr^.ConnectStr);
  End;

  If L Then
  Begin
    Emulation:=0;
    IOMethod:=Local;
    LocalLogin:=True;
    DontAnswer;
  End;

  FillChar(Urec^,SizeOf(UserRec),#0);
  With Urec^ do
  Begin
    Lvl:=0;
    XLvl:=0;
    Password[1]:='';
    TimeLeft:=10;
    Handle:='';
    Lvl:=0;
    XLvl:=0;
    Regularcolor:=7;
    Promptcolor:=9;
    Statcolor:=11;
    Inputcolor:=3;
    CmdColor:=15;
    MiscColor:=8;
    InsideColor:=9;
    BoxColor:=8;
  End;
  RunMenu;
End;

Procedure UpdateWFC;
Begin
  GotoXY(14,3);  Write(TimeStr(Now),' ');
  GotoXY(66,16); Write(DateStr(Now),'  ');
{  If CheckEvents Then DoEvent;}
End;

Procedure WaitForCall;
Var Ch:Char;
    I:Integer;
    B:Byte;
    TimeHolder:LongInt;
    WFCDone:Boolean;
Begin

  WFCDone:=False;
  TextColor(7);
  TextBackGround(0);
  GotoWindow(1);
  Cls;

  TimeHolder:=TimePart(Now);
  CursorOff;
  TextColor(11);
  DrawWFC;
  Repeat
    {Delay(50);}
    Slice;

    If TimeHolder<>TimePart(Now) Then UpdateWFC;
    TimeHolder:=TimePart(Now);

    If CharPressed Then Instr:=ModemResult;

    If Pos('RING',Instr)<>0 Then
    Begin
      ModemPrint('ATA'+^M);
      Instr:='';
    End
   Else
    If Pos('CONNECT',Instr)<>0 Then DoMatrix(False) Else

    If Keypressed then
    Begin
      Ch:=ReadKey;
      If Ch=#0 Then
      Begin
        Clrscr;
        Ch:=ReadKey;
        If Ch In [#104..#113] Then Halt(Valu(Ch)) Else
        Case Ch Of
          #59:DoMatrix(True);        {F1}
          #60:Begin
                CurMenuFile:='WFC';
                RunMenu;
              End;
          #62:ModemPrintln('ATA');   {F4}
          #68:WFCDone:=True;         {F10}
        End;
        DrawWFC;
      End;
    End;
    Slice;
 Until WFCDone;
 Clrscr;
 CursorOn;
End;

Begin
End.