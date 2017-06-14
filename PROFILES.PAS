{ ShockWavE Pro User Profile Editor Created By: iCE Breaker }
{ Started: 01/17/95 - Finished: Never }
Unit Profiles;

Interface

Uses opCrt,Dos,Records,iCEIo1,PullBarz,Cnfgrec;

Const  ProVerNum='  ProFile:0.03  ';
      ProVerDate='  ProFile:05/31/95  ';

Procedure ProfileEditor;

Implementation

Procedure ProfileEditor;

Var Bars      :PullBarzRec;
    EditBar   :PullBarzRec;
    TmpProFile:ProFileRec;
    UProfile  :ProfileRec;
    FProFile  :File Of ProFileRec;
    Select,LastBar,Pick:Byte;
    Quit      :Boolean;
    C         :Char;
    Rec       :String;
    Cur       :Byte;
    Xit       :String[2];
    AC,Xfer,Pts,XDate,UR,KR,Post:String[10];
    Time      :String;
    CurRec    :Integer;

function valu (q:Str40):integer;
var i,s,pu:integer;
    r:real;
    c:Char;
begin
  valu:=0;
  if length(q)=0 then exit;
  c:=Q[1];
  if not (C in ['0','1','2','3','4','5','6','7','8','9','-']) then begin
    Valu:=0;
    exit;
  End;
  If (c in ['A'..'~']) then Begin
    Valu:=0;
    Exit;
  End;
  if length(q)>5 then exit;
  val (q,r,s);
  if s<>0 then exit;
  if (r<=32767.0) and (r>=-32767.0)
    then valu:=round(r)
end;

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

Procedure Error(S:String);
Begin
  TextColor(12);
  Writeln(S);
  TextColor(7);
  Delay(1000);
End;

Procedure CleanUp;
Begin
  FillChar(UProFile,SizeOf(UProfile),#0);
  AC   :='';
  Xfer :='';
  Pts  :='';
  XDate:='';
  Ur   :='';
  KR   :='';
  Post :='';
  Time :='';
  Rec  :='';
  If Not Exist(CNF^.DataDir+'PROFILES.DAT') then
  Begin
    Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
    ReWrite(FProFile);
    Close(FProFile);
  End;
End;

Procedure ListProFiles(Var Start:Integer);
Var Count:Byte;
    Cnt,X:Byte;
Begin
  Count:=0;
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ User Profile Editor ³                      ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerStr); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
 {$I-} ReSet(FProFile); {$I+}
  If IOResult<>0 Then
  Begin
    Error('File Not Found');
    Exit;
  End;

  If (Start<0) then Inc(Start,6);
  If (Start>=FileSize(FProFile)) then Dec(Start,6);

  Seek(FProFile,Start);
  While (Not EOF(FProFile)) and (Count<6) Do
  Begin
    Read(FProFile,UProFile);
    EditBar.Choice[Count+1]:=UProFile.Name;
    With UProFile Do
    Begin
      TextColor(8); Write('ÄÄ'); TextColor(9);
      Write('['); TextColor(15);
      EditBar.MenuX[Count+1]:=WhereX;
      EditBar.MenuY[Count+1]:=WhereY;
      Write(Name); TextColor(9); Write(']'); TextColor(8);
      While WhereX<80 do Write('Ä'); Writeln;
      TextColor(7); Write('Note '); TextColor(11); Tab(UserNote,25);
      TextColor(8); Write('³'); TextColor(7); Write(' AcLvl '); TextColor(8);
      Write('³'); TextColor(7); Write(' XFLvl '); TextColor(8); Write('³');
      TextColor(7); Write(' XFPts '); TextColor(8); Write('³'); TextColor(7);
      Write(' UDR '); TextColor(8); Write('³'); TextColor(7); Write(' UDK ');
      TextColor(8); Write('³'); TextColor(7); write(' PCR '); TextColor(8); Write('³');
      TextColor(7); Writeln(' Time');
      Write('Flag '); TextColor(11); Tab(AcFlags,25); TextColor(8);
      Write('³ '); TextColor(11);Tab(Strr(AcLvl),8); Tab(Strr(XferLvl),8); Tab(Strr(Fpoints),8);
      Tab(Strr(UDR),6); Tab(Strr(UDKR),6); Tab(Strr(PCR),6); writeln(Strr(TimeLimit));
    End;
    Inc(Count);
  End;
  With EditBar Do
  Begin
    KeyCmds:='';
    MenuName:='';
    NumChoices:=Count;
    DefChoice:=1;
    For Cnt:=1 to NumChoices do KeyCmds:=KeyCmds+Strr(Cnt);
    KeyCmds:=KeyCmds+#27;
  End;
  Close(FProFile);
End;

Procedure AddProFile;
Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ User Profile Editor ³                      ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',ProVerNum); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
 {$I-} ReSet(FProFile); {$I+}
  If IOResult<>0 Then ReWrite(FProFile);
  While Not EOF(FProFile) Do Read(FProFile,TmpProFile);
  With UProFile Do
  Begin
    Write('Profile Name:    '); EditLine(Name,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('Access Level:    '); EditLine(AC,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('Access Flags:    '); EditLine(ACFlags,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('File Level:      '); EditLine(Xfer,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('File Points:     '); EditLine(Pts,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('User Note:       '); EditLine(UserNote,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('ExpDate:         '); EditLine(XDate,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('U/D Ratio:       '); EditLine(UR,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('U/D K Ratio:     '); EditLine(KR,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Post/Call Ratio: '); EditLine(Post,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Time Per Day:    '); EditLine(Time,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    AcLvl:=Valu(AC);
    Xferlvl:=Valu(Xfer); FPoints:=Valu(Pts);
    UDR:=Valu(UR); If Udr=0 then Inc(Udr);
    UDKR:=Valu(KR); If Udkr=0 then Inc(Udkr);
    PCR:=Valu(Post); if pcr=0 then Inc(pcr);
    TimeLimit:=Valu(Time);
  End;
  Write(FproFile,UProFile);
  Close(FproFile);
End;

Procedure EditProFile;
Begin
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
 {$I-} ReSet(FProFile); {$I+}
  If IOResult<>0 Then
  Begin
    Error('File Not Found');
    Exit;
  End;
  Select:=MenuBar(1,1,2,15,0,15,1,15,0,1,EditBar);
  With EditBar Do If Select=Length(KeyCmds) then
  Begin
    Close(FProFile);
    Exit;
  End;
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ User Profile Editor ³                      ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',ProVerNum); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Seek(FProFile,Select-1);
  Read(FProFile,UProFile);
  With UProFile Do
  Begin
    AC:=Strr(AcLvl);
    Xfer:=Strr(XferLvl); Pts:=Strr(FPoints);
    UR:=Strr(UDR); KR:=Strr(UDKR);
    Post:=Strr(PCR);
    Time:=Strr(TimeLimit);
    Write('Profile Name:    '); EditLine(Name,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('Access Level:    '); EditLine(AC,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('Access Flags:    '); EditLine(ACFlags,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('File Level:      '); EditLine(Xfer,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('File Points:     '); EditLine(Pts,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    Write('User Note:       '); EditLine(UserNote,Cur,WhereX,WhereY,25,Xit,False,0); Writeln;
    Write('ExpDate:         '); EditLine(XDate,Cur,WhereX,WhereY,8,Xit,False,0); Writeln;
    Write('U/D Ratio:       '); EditLine(UR,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('U/D K Ratio:     '); EditLine(KR,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Post/Call Ratio: '); EditLine(Post,Cur,WhereX,WhereY,3,Xit,False,0); Writeln;
    Write('Time Per Day:    '); EditLine(Time,Cur,WhereX,WhereY,5,Xit,False,0); Writeln;
    AcLvl:=Valu(AC);
    Xferlvl:=Valu(Xfer); FPoints:=Valu(Pts);
    UDR:=Valu(UR); If Udr=0 then Inc(Udr);
    UDKR:=Valu(KR); If Udkr=0 then Inc(Udkr);
    PCR:=Valu(Post); if pcr=0 then Inc(pcr);
    TimeLimit:=Valu(Time);
  End;
  Seek(FProFile,Select-1);
  Write(FproFile,UProFile);
  Close(FproFile);
End;

Procedure PackProFiles;
Var TempFile:File Of ProFileRec;
    BackFile:File;
Begin
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT'); ReSet(FProFile);
  Assign(TempFile,CNF^.DataDir+'PROFILE$.DAT');  ReWrite(TempFile);
  While Not EOF(FProFile) Do
  Begin
    Read(FProFile,UProFile);
    If Length(UProfile.Name)>0 Then
    Begin
    With TmpProFile Do
    Begin
      Name:=UProFile.Name;
      AcLvl:=UProFile.AcLvl;
      XferLvl:=UProFile.XferLvl;
      Fpoints:=UProFile.Fpoints;
      AcFlags:=UProFile.AcFlags;
      UserNote:=UProFile.UserNote;
      ExpDate:=UProFile.ExpDate;
      UDR:=UProFile.UDR;
      UDKR:=UProFile.UDKR;
      PCR:=UProFile.PCR;
      TimeLimit:=UProFile.TimeLimit;
    End;
    Write(TempFile,TmpProFile);
   End;
  End;
  Erase(FProFile);
  Close(TempFile);
  Assign(TempFile,CNF^.DataDir+'PROFILE$.DAT');
  ReName(TempFile,CNF^.DataDir+'PROFILES.DAT');
End;

Procedure RemoveProFile;
Begin
  Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
 {$I-} ReSet(FProFile); {$I+}
  If IOResult<>0 Then
  Begin
    Error('File Not Found');
    Exit;
  End;
  Select:=MenuBar(1,1,2,15,0,15,1,15,0,1,EditBar);
  With EditBar Do If Select=Length(KeyCmds) then
  Begin
    Close(FProFile);
    Exit;
  End;
  Seek(FProFile,Select-1);
  FillChar(UProFile,SizeOf(UProfile),#0);
  Write(FProFile,UProFile);
  Close(FProFile);
  PackProfiles;
End;

Procedure SetupMainMenu;
Begin
  With Bars Do
  Begin
    MenuName:='User Profile Menu';
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
  LastBar:=1;
  CurRec:=0;
  Repeat
    ClrScr;
    TextColor(14);
    TextBackGround(1);
    Write('³ User Profile Editor ³                      ');
    TextColor(7); Write('ShockWavE Pro BBS Software v',ProVerNum); ClrEol;
    Writeln;
    TextBackGround(0);
    Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    SetupMainMenu;
    CursorOff;
    CleanUp;
    ListProFiles(CurRec);
    Pick:=MenuBar(0,1,24,3,0,15,1,11,2,0,Bars);
    LastBar:=Pick;
    Case Pick Of
      1:EditProFile;
      2:Inc(CurRec,6);
      3:Dec(CurRec,6);
      4:AddProFile;
      5:RemoveProFile;
      6,7:Quit:=True;
    End;
  Until Quit;
  CursorOn;
End;

Begin
End.