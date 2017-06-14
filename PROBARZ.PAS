     (************** ]|LOCAL|[ Lite-Bar Unit by: iCE Breaker ************)
     (* icebrkr@nacs.net * telnet cyberdyne.org * www.nacs.net/~icebrkr *)

(*
  iB * 11/20/96 - Converted Bar setup into 1 Record
                  Added Capital Character HighLighting
                  Fills HotKey list based on Capital Character
                  Added Color Constants (CRT has them too)
                  Added Top,Bottom,Left,Right Constans for MenuName

*)

Unit ProBarz;

Interface

Uses OpCrt,Dos;

Const
       PullVerNum='  PullBarZ:0.05.1';
      PullVerDate='  PullBarZ:11/20/96  ';
      MaxChoices=50;            { Max number of menu choices }

      Black    =0;
      Blue     =1;
      Green    =2;
      Cyan     =3;
      Red      =4;
      Magenta  =5;
      Brown    =6;
      White    =7;
      Grey     =8;
      LtBlue   =9;
      LtGreen  =10;
      LtCyan   =11;
      LtRed    =12;
      LtMagenta=13;
      Yellow   =14;
      LtWhite  =15;

      ProBar   =0;
      PullBar  =1;
      SlideBar =2;

      None     =0;
      Top      =1;
      Left     =2;
      Right    =3;

Type
    PullBarzRec=Record          { Pull/Slide Bar Records }
      MenuName    :String[40];  { title for current menu }
      NumChoices  :Byte;        { number of choices for menu }
      DefChoice   :Byte;        { default/starting choice }
      Choice      :Array[1..MaxChoices] Of String[40]; {choice name/desc }
      MenuX,MenuY :Array[1..MaxChoices] Of Byte; { X,Y for menu choice }
      KeyCmds     :String[MaxChoices];           { HotKey Listing }
      Operation,                (* Operation Method: 1:PullDown 2:Slide 3:PRO *)
      MainX,                    (* Starting X Position *)
      MainY,                    (* Starting Y Position *)
      ForC,                     (* Normal Foreground Color *)
      BackG,                    (* Normal Background Color *)
      BForC,                    (* Bar Foreground Color *)
      BBackG,                   (* Bar Background Color *)
      HiC,                      (* Highlighted Character Color *)
      Hdr:Byte;                 (* MenuName Position: 0:None 1:Top 2:Left 3:Right *)
    End;

Function MenuBar(Var B:PullBarzRec):Byte;

Implementation

Function MenuBar(Var B:PullBarzRec):Byte;
Var
   LastChoice,CurChoice:Byte;
   iCE,Ch:Char;

Procedure INCCurChoice;
Begin
  LastChoice:=CurChoice;
  Inc(CurChoice);
  If CurChoice>B.NumChoices then CurChoice:=1;
End;

Procedure WriteVer;
Begin
  Writeln;
  Writeln(' PullVerNum=',PullVerNum);
  Writeln('PullVerDate=',PullVerDate);
  Writeln;
End;

Procedure DecCurChoice;
Begin
  LastChoice:=CurChoice;
  Dec(CurChoice);
  If CurChoice<1 then CurChoice:=B.NumChoices;
End;

Procedure Pull_WriteList;
Var Cnt,Z:Byte;
    HasHotKey:Boolean;
Begin
  With B Do
  Begin
    Case Hdr Of
      0: GotoXY(MainX,MainY);
      1: Begin GotoXy(MainX,MainY); TextColor(15); Writeln(MenuName); End;
      2: Begin GotoXy(MainX,MainY); TextColor(15); Write(MenuName+' '); End;
    End;

    TextColor(ForC); TextBackground(BackG);

    For Z:=1 to NumChoices Do
    Begin
      HasHotKey:=False;
      GotoXy(MainX,MainY+Z);
      If Operation>0 then
      Begin
        MenuX[Z]:=WhereX;
        MenuY[Z]:=WhereY;

        TextColor(ForC); TextBackground(BackG);

        For Cnt:=1 to Length(B.Choice[LastChoice]) Do
        Begin
          If (B.Choice[Z][Cnt] In [#64..#91,#48..#57]) and (Not HasHotKey) Then
          Begin
            HasHotKey:=True;
            B.KeyCmds:=B.KeyCmds+B.Choice[Z][Cnt];
            TextColor(B.HiC);
            Write(B.Choice[Z][Cnt]);
            TextColor(B.ForC); TextBackground(B.BackG);
          End
         Else Write(B.Choice[Z][Cnt]);
        End;
      End;
    End;
    If Hdr=3 Then Begin TextColor(15); Write(' '+MenuName); End;
  End;
End;

Procedure Slide_WriteList;
Var Cnt,Z:Byte;
    HasHotKey:Boolean;

Begin
  With B Do
  Begin
    GotoXy(MainX,MainY);
    Case Hdr Of
      0: ;
      1: Begin TextColor(15); Writeln(MenuName); End;
      2: Begin TextColor(15); Write(MenuName+' '); End;
    End;
    TextColor(8); Write('³');

    For Z:=1 to NumChoices Do
    Begin
      HasHotKey:=False;
      MenuX[Z]:=WhereX; MenuY[Z]:=WhereY;
      TextColor(ForC); TextBackground(BackG);
      For Cnt:=1 to Length(B.Choice[Z]) Do
      Begin
        If (B.Choice[Z][Cnt] In [#64..#91,#48..#57]) and (Not HasHotKey) Then
        Begin
          HasHotKey:=True;
          B.KeyCmds:=B.KeyCmds+B.Choice[Z][Cnt];
          TextColor(B.HiC);
          Write(B.Choice[Z][Cnt]);
          TextColor(B.ForC); TextBackground(B.BackG);
        End
       Else Write(B.Choice[Z][Cnt]);
      End;
    End;
    TextColor(8); Write('³');
    If Hdr=3 Then Begin TextColor(15); Write(' '+MenuName); End;
  End;
End;

Procedure WriteSelect;
Var Cnt:Byte;
    HasHotKey:Boolean;
Begin
  GotoXY(B.MenuX[LastChoice],B.MenuY[LastChoice]);
  TextColor(B.ForC); TextBackground(B.BackG);
  HasHotKey:=False;

  For Cnt:=1 to Length(B.Choice[LastChoice]) Do
  Begin
    If (B.Choice[LastChoice][Cnt] In [#64..#91,#48..#57]) and (Not HasHotKey) Then
    Begin
      HasHotKey:=True;
      TextColor(B.HiC);
      Write(B.Choice[LastChoice][Cnt]);
      TextColor(B.ForC); TextBackground(B.BackG);
    End
   Else Write(B.Choice[LastChoice][Cnt]);
  End;

  GotoXY(B.MenuX[CurChoice],B.MenuY[CurChoice]);
  TextColor(B.BForC); TextBackGround(B.BBackG); Write(B.Choice[CurChoice]);
  TextBackGround(0);
End;

Procedure BarInput;
Var Cnt:Byte;
Begin
    Ch:=Upcase(ReadKey);

    For Cnt:=1 to Length(B.KeyCmds) Do 
      If Ch=B.KeyCmds[Cnt] then
      Begin
        LastChoice:=CurChoice;
        CurChoice:=Cnt;
        iCE:=Ch;
      End;

    If Ch=#27 Then iCE:='þ';

    If Ch=#0 then
    Begin
      Ch:=ReadKey;
      Case Ch Of
        #72,#75:DecCurChoice;
        #77,#80:IncCurChoice;
        #73    :iCE:='ü';  { PgUp }
        #81    :iCE:='ý';  { PgDn }
        #68    :iCE:='þ';  { F10  }
        #119   :WriteVer;
      End;
    End;
    If Ch=#13 Then iCE:=B.KeyCmds[CurCHoice];
End;

Begin
  iCE:=#0;
  CurChoice:=B.DefChoice;
  LastChoice:=B.DefChoice;
  Case B.Operation Of
    0:Pull_WriteList;
    1:Pull_WriteList;
    2:Slide_WriteList;
  End;

  GotoXy(B.MenuX[B.DefChoice],B.MenuY[B.DefChoice]);
  WriteSelect;

  Repeat
    BarInput;
    WriteSelect;
  Until (Pos(iCE,B.KeyCmds)>0) or (iCE in ['þ','ü','ý',#13]);

  Case iCE Of
{ü} #252:MenuBar:=252; { PgUp }
{ý} #253:MenuBar:=253; { PgDn }
    #254:MenuBar:=255; { Exit/F10/ESC }
     else MenuBar:=CurChoice;
  End;
End;

Begin
End.