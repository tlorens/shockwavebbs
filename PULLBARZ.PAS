      (********************* ShockWavE:PRO BBS ***********************)
      (*********** ]|LOCAL|[ Pulldown bar Unit by: iCE Breaker *******)
      (********************* ShockWavE:PRO BBS ***********************)
                     { 100% Optimized code 05/31/95. }

Unit PullBarz;

Interface

Uses OpCrt,Dos;

Const
       PullVerNum='  PullBarZ:0.03  ';
      PullVerDate='  PullBarZ:05/31/95  ';
      MaxChoices=25;   { Max number of menu choices }
Type
    PullBarzRec=Record { Pull/Slide Bar Records }
      MenuName    :String[40];  { title for current menu }
      NumChoices  :Byte;        { number of choices for menu }
      Choice      :Array[1..MaxChoices] Of String[25]; {choice name/desc }
      DefChoice   :Byte;   { default/starting choice }
      MenuX,MenuY :Array[1..MaxChoices] Of Byte; { X,Y for menu choice }
      KeyCmds     :String[MaxChoices]; { HotKey Listing }
    End;

{Op    1:PullBar
       2:SlideBar
 X     Starting X Position
 Y     Starting Y Position
 Fore  Normal Foreground Color
 Back  Normal Background Color
 BarF  Bar Forground Color
 BarB  Bar BackGround Color
 HChar Highlight Character Color
 Hdr   0:No Header
       1:Top of MenuBar
       2:Left of MenuBar
       3:Right of MenuBar
 Pro   0:Normal
       1:PRO:Bar
 B     Predefined MenuRecord
}

Function MenuBar(Op,X,Y,Fore,Back,BarF,BarB,HChar,Hdr:Byte; Pro:Byte; Var B:PullBarzRec):Byte;

Implementation

Function MenuBar (Op,X,Y,Fore,Back,BarF,BarB,HChar,Hdr:Byte; Pro:Byte; Var B:PullBarzRec):Byte;
Var
   LastChoice,CurChoice:Byte;
   iCE,Ch:Char;

Procedure INCCurChoice;
Begin
  LastChoice:=CurChoice;
  Inc(CurChoice);
  If CurChoice>B.NumChoices then CurChoice:=1;
End;

Procedure DecCurChoice;
Begin
  LastChoice:=CurChoice;
  Dec(CurChoice);
  If CurChoice<1 then CurChoice:=B.NumChoices;
End;

Procedure Pull_WriteList;
Var Z:Byte;
Begin
  With B Do
  Begin
    Case Hdr Of
      0: ;
      1: Begin TextColor(15); Writeln(MenuName); End;
      2: Begin GotoXy(X,Y); TextColor(15); Write(MenuName+' '); End;
    End;

    TextColor(Fore); TextBackground(Back);
    For Z:=1 to NumChoices Do
    Begin
      GotoXy(X,Y+Z);
      If Pro=0 then
      Begin
        MenuX[Z]:=WhereX;
        MenuY[Z]:=WhereY;
        Writeln(Choice[Z]);
      End;
    End;
    If Hdr=3 Then Begin TextColor(15); Write(' '+MenuName); End;
  End;
End;

Procedure Slide_WriteList;
Var Cnt,Z:Byte;

Begin
  With B Do
  Begin
    GotoXy(X,Y);
    Case Hdr Of
      0: ;
      1: Begin TextColor(15); Writeln(MenuName); End;
      2: Begin TextColor(15); Write(MenuName+' '); End;
    End;
    TextColor(8); Write('³');
    For Z:=1 to NumChoices Do
    Begin
      MenuX[Z]:=WhereX; MenuY[Z]:=WhereY;
      Write(Choice[Z][1]);
      TextColor(HChar);  Write(Choice[Z][2]);
      TextColor(Fore); TextBackground(Back);
      For Cnt:=3 to Length(Choice[Z]) Do Write(Choice[Z][Cnt]);
    End;
    TextColor(8); Write('³');
    If Hdr=3 Then Begin TextColor(15); Write(' '+MenuName); End;
  End;
End;

Procedure WriteSelect;
Var Cnt:Byte;
Begin
  GotoXY(B.MenuX[LastChoice],B.MenuY[LastChoice]);
  Write(B.Choice[LastChoice][1]);
  TextColor(HChar);  Write(B.Choice[LastChoice][2]);
  TextColor(Fore); TextBackground(Back);
  For Cnt:=3 to Length(B.Choice[LastChoice]) Do Write(B.Choice[LastChoice][Cnt]);
  GotoXY(B.MenuX[CurChoice],B.MenuY[CurChoice]);
  TextColor(BarF); TextBackGround(BarB); Write(B.Choice[CurChoice]);
  TextBackGround(0);
End;

Procedure BarInput;
Var Cnt:Byte;
Begin
    Ch:=Upcase(ReadKey);
    For Cnt:=1 to Length(B.KeyCmds) Do If Ch=B.KeyCmds[Cnt] then
    Begin
      LastChoice:=CurChoice;
      CurChoice:=Cnt;
      iCE:=Ch;
    End;
    If Ch=#0 then Ch:=ReadKey;
    If Ch=#72 Then DecCurChoice else
    If Ch=#129 then IncCurChoice else
    If Ch=#80 then IncCurChoice else
    If Ch=#75 Then DecCurChoice else
    If Ch=#129 then IncCurChoice else
    If Ch=#77 then IncCurChoice else
    If Ch=#128 Then DecCurChoice Else
    If Ch=#133 Then iCE:=B.KeyCmds[CurChoice] else
    If Ch=#13 Then iCE:=B.KeyCmds[CurCHoice];
    If Ch=#68 Then iCE:='þ';

End;

Begin
  iCE:=#0;
  CurChoice:=B.DefChoice;
  LastChoice:=B.DefChoice;
  IF Op=1 then Pull_WriteList else Slide_WriteList;
  GotoXy(B.MenuX[B.DefChoice],B.MenuY[B.DefChoice]);
  WriteSelect;
  Repeat
    BarInput;
    WriteSelect;
  Until (iCE=#13) or (Pos(iCE,B.KeyCmds)>0) or (iCE='þ');
  If iCE='þ' then MenuBar:=255 else MenuBar:=CurChoice;
End;

Begin
  DirectVideo:=True;
End.