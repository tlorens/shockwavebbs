unit event;

Interface

Uses OpCrt,Dos,Records,iCEIo1,PullBarz,CnfgRec;

Const  EventVerNum='  Event:0.03  ';
      EventVerDate='  Event:05/31/95  ';

Procedure EventEditor;

implementation

Procedure EventEditor;
Var
    Bars   :PullBarzRec;
    EditBar:PullBarzRec;
    CurEvent:EventRec;
    TmpRec:EventRec;
    FEvent:File Of EventRec;
    Cnt:Byte;
    Input:String[80];
    Code:Integer;
    Count,Cur:Byte;
    Xit:String[2];
    Select:Byte;
    CurRec:Integer;
    Quit:Boolean;
    LastBar,Pick:Integer;
    Ch:Char;

procedure tab(n:Str255; np:integer);
var cnt:integer;
begin
  write (n);
  for cnt:=length(n) to np-1 do write(' ')
end;

function strr (n:integer):Str40;
var q:Str40;
begin
  str (n,q);
  strr:=q
end;

  function digit (k:char):boolean;
  begin
    digit:=ord(k) in [48..57]
  end;


  function validdate(inp:Str10):boolean;
  var k,l:char;

    function gchar:char;
    begin
      if length(inp)=0 then
      begin
        gchar:='?';
        exit
      end;
      gchar:=inp[1];
      delete (inp,1,1)
    end;

  begin
    validdate:=false;
    k:=gchar;
    l:=gchar;
    if not digit(k) then exit;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'1' then exit;
        if not digit(l) then exit;
        if (l>'2') and (k='1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    k:=gchar;
    l:=gchar;
    if l='/'
      then if k='0'
        then exit
        else
      else begin
        if k>'3' then exit;
        if not digit(l) then exit;
        if (k='3') and (l>'1') then exit;
        l:=gchar;
        if l<>'/' then exit
      end;
    if digit(gchar) and digit(gchar) then validdate:=true
  end;

  function validtime(Inp:Str10):boolean;
  var c,s,l:integer;
      d1,d2,d3,d4:char;
      ap,m:char;
  begin
    validtime:=false;
    L:=Length(inp);
    if (L<7) or (L>8) then Exit;
    c:=pos(':',inp);
    if c<>l-5 then exit;
    s:=pos(' ',inp);
    if s<>l-2 then exit;
    d2:=inp[c-1];
    if l=7 then d1:='0' else d1:=inp[1];
    d3:=inp[c+1];
    d4:=inp[c+2];
    ap:=upcase(inp[s+1]);
    m:=upcase(inp[s+2]);
    if d1='1' then if d2>'2' then d2:='!';
    if (d1>='0') and (d1<='1') and digit(d2) and (d3>='0') and (d3<='5')
       and digit(d4) and ((ap='A') or (ap='P')) and (m='M')
         then validtime:=true
  end;

Procedure AddEvent;
Var Err,Tyme,Dat,D:String;
Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ Event-Editor ³                             ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerStr); ClrEol;
  Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Reset(FEvent);
  FillChar(CurEvent,SizeOf(CurEvent),#0);
  Err:='';    Tyme:='';   Dat:='';   D:='';
  While Not EOF(FEvent) Do Read(FEvent,TmpRec);
  With CurEvent Do
  Begin
    Textcolor(7);
    Write('Event Name:  '); EditLine(Description,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('Error Code:  '); EditLine(Err,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Batch Name:  '); EditLine(ExecCmd,Cur,WhereX,WhereY,40,Xit,False,0); Writeln;
    Write('Time:        '); EditLine(Time,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('Date:        '); EditLine(Date,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('Day:         '); EditLine(D,Cur,WhereX,WhereY,1,Xit,False,0); Writeln;
    Val(Err,ErrCode,Code);
    Val(D,Day,Code);
    If Length(Date)=0 Then Date:='01/01/80';
    If Length(Time)=0 Then Time:='00:00 am';
  End;
  Write(Fevent,CurEvent);
 End;

Procedure Openfile;
Begin
 If Exist(CNF^.DataDir+'EVENTS.DAT') then
 Begin
   Assign(FEvent,CNF^.DataDir+'EVENTS.DAT');
   Reset(Fevent);
 End
Else
 Begin
   Assign(FEvent,CNF^.DataDir+'EVENTS.DAT');
   ReWrite(Fevent);
 End;
End;

Procedure PackEvents;
Var TempFile:File Of EventRec;
    BackFile:File;
Begin
  Close(FEvent);
  Assign(FEvent,CNF^.DataDir+'EVENTS.DAT'); ReSet(FEvent);
  Assign(TempFile,CNF^.DataDir+'EVENT$.DAT');  ReWrite(TempFile);
  While Not EOF(FEvent) Do
  Begin
    Read(FEvent,CurEvent);
    If Length(CurEvent.Description)>0 Then
    Begin
    With TmpRec Do
    Begin
      Description:=CurEvent.Description;
      ErrCode:=CurEvent.ErrCode;
      ExecCmd:=CurEvent.ExecCmd;
      Time:=CurEvent.Time;
      Date:=CurEvent.Date;
      Day:=CurEvent.Day;
    End;
    Write(TempFile,TmpRec);
   End;
  End;
  Erase(FEvent);
  Close(TempFile);
  Assign(TempFile,CNF^.DataDir+'EVENT$.DAT');
  ReName(TempFile,CNF^.DataDir+'EVENTS.DAT');
  OpenFile;
End;

Procedure DeleteEvent;
Var S:String;
Begin
  Select:=MenuBar(1,1,2,15,0,15,1,15,0,1,EditBar);
  With EditBar Do If Select=Length(KeyCmds) then Exit;
  Seek(FEvent,Select-1);
  FillChar(CurEvent,SizeOf(CurEvent),#0);
  Write(FEvent,CurEvent);
  PackEvents;
End;

Procedure EditEvent;
var Err,Tyme,Dat,D:String;
Begin
  Select:=MenuBar(1,1,2,15,0,15,1,15,0,1,EditBar);
  With EditBar Do If Select=Length(KeyCmds) then Exit;
  Seek(FEvent,Select-1);
  Read(FEvent,CurEvent);
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ User Profile Editor ³                      ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerStr); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  With CurEvent Do
  Begin
    Err:=Strr(ErrCode);
    D:=Strr(Day);
    Textcolor(7);
    Write('Event Name:  '); EditLine(Description,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('Error Code:  '); EditLine(Err,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Batch Name:  '); EditLine(ExecCmd,Cur,WhereX,WhereY,40,Xit,False,0); Writeln;
    Write('Time:        '); EditLine(Time,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('Date:        '); EditLine(Date,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('Day:         '); EditLine(D,Cur,WhereX,WhereY,1,Xit,False,0); Writeln;
    Val(Err,ErrCode,Code);
    Val(D,Day,Code);
    If Length(Date)=0 Then Date:='01/01/80';
    If Length(Time)=0 Then Time:='00:00 am';
  End;
  Seek(Fevent,Select-1);
  Write(Fevent,CurEvent);
End;

Procedure ListEvents(Var Start:Integer);
Var Count,X,Cnt:Byte;
Begin
  Count:=0;
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ Event-Editor ³                             ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerStr); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

  If (Start<0) then Inc(Start,6);
  If (Start>=FileSize(FEVent)) then Dec(Start,6);

  Seek(FEvent,Start);
  While (Not EOF(FEvent)) and (Count<6) Do
  Begin
    Read(FEvent,CurEvent);
    EditBar.Choice[Count+1]:=CurEvent.Description;
    With CurEvent Do
    Begin
      TextColor(8); Write('ÄÄ'); TextColor(9); Write('['); TextColor(15);
      EditBar.MenuX[Count+1]:=WhereX;
      EditBar.MenuY[Count+1]:=WhereY;
      Write(Description); TextColor(9); Write(']'); TextColor(8);
      While WhereX<80 do Write('Ä'); Writeln;
      TextColor(8); Write('³');
      TextColor(7); Write(' Exit ');        TextColor(8); Write('³');
      TextColor(7); Write(' Time     ');    TextColor(8); Write('³');
      TextColor(7); Write(' Date        '); TextColor(8); Write('³');
      TextColor(7); Write(' Day         '); TextColor(8); Writeln('³');
      TextColor(11);
      Tab('  '+Strr(ErrCode),9); Tab(Time,11);

      If Date<>'0' then Tab(Date,14) Else
      If (Date='0') and (Day>0) Then Tab('0 By-Day',14) else
      If (Date='0') and (Day=0) Then Tab('0 Ever Day',14);

      If (Day=0) and (Date='0') then Writeln('0 Every Day') else
      Case Day of
        1:Writeln('1 Sunday');
        2:Writeln('2 Monday');
        3:Writeln('3 Tuesday');
        4:Writeln('4 Wednesday');
        5:Writeln('5 Thursday');
        6:Writeln('6 Friday');
        7:Writeln('7 Saturday');
        8:Writeln('8 Inactive');
       Else Writeln(Day,' By-Date');
      End;
      TextColor(7); Write('Exec Cmd: ');
      If (Date<>'0') and ((Day>0) and (Day<8)) Then
      Begin
        TextColor(12+Blink); Write('ERROR ');
        TextColor(12); Writeln(' Can''t have a Date AND Day set!');
      End
     Else
      If (ErrCode=0) and (Length(ExecCmd)<=1) Then
      Begin
        TextColor(12+Blink); Write('ERROR ');
        TextColor(12); Writeln(' You have to have a Error Level OR Exec Cmd set!');
      End
     Else
      If (ErrCode>0) and (Length(ExecCmd)>0) Then
      Begin
        TextColor(12+Blink); Write('ERROR ');
        TextColor(12); Writeln(' Can''t have a ErrorCode AND ExecCmd set!');
      End
     Else
      If Length(ExecCmd)>0 Then
      Begin
        TextColor(11);
        Writeln(ExecCmd);
      End
     Else
      If ErrCode>0 then
      Begin
        TextColor(15);
        Writeln('NOTICE: Event is called via RUN.BAT!');
      End;
    End;
    Inc(Count);
  End;
  With EditBar Do
  Begin
    KeyCmds:='';
    MenuName:='Not Used';
    NumChoices:=Count;
    DefChoice:=1;
    For Cnt:=1 to NumChoices do KeyCmds:=KeyCmds+Strr(Cnt);
    KeyCmds:=KeyCmds+#27;
  End;

End;

Procedure SetupMainMenu;
Begin
  With Bars Do
  Begin
    MenuName:='Event Menu';
    Choice[1]:=' Edit ';
    Choice[2]:=' Next ';
    Choice[3]:=' Prev ';
    Choice[4]:=' Add ';
    Choice[5]:=' Delete ';
    Choice[6]:=' Quit ';
    NumChoices:=6;
    Defchoice:=LastBar;
    KeyCmds:='ENPAD'+Chr(27);
  End;
End;

Begin
  Quit:=False;
  ReadConfig;
  OpenFile;
  LastBar:=1;
  CurRec:=0;
  Repeat
    ClrScr;
    TextColor(14);
    TextBackGround(1);
    Write('³ Event-Editor ³                             ');
    TextColor(7); Write('ShockWavE Pro BBS Software v',VerStr); ClrEol; Writeln;
    TextBackGround(0);
    Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    SetupMainMenu;
    CursorOff;
    ListEvents(CurRec);
    Pick:=MenuBar(0,1,24,3,0,15,1,11,2,0,Bars);
    LastBar:=Pick;
    Case Pick Of
      1:EditEvent;
      2:Inc(CurRec,6);
      3:Dec(CurRec,6);
      4:AddEvent;
      5:DeleteEvent;
      6:Quit:=True;
    End;
  Until Quit;
  CursorOn;
  Close(FEvent);
End;

begin
End.