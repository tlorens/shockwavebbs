Unit IRC;

Interface

Procedure IRCChat;

Implementation

Uses OpCrt,Dos,GenSubs,IO,Multi,
     IRCStart,Cmds,IRCDis,IRCVars,IRCIO;

Procedure IOLoop;
Var Loop:Integer;
Begin
  Repeat
    Slice;
    If CharPressed Then
    Begin
      GoXY(LastX,24);
      GetChar(Ch);
      If Ch<>#13 Then
      Begin
        Case Ch of
          #8:Begin
               Print(^H+' '+^H);
               LastX:=WhereX;
               Delete(OutStr,Length(OutStr),1);
             End;
          #27,^I:;
        Else
         Begin
           OutStr:=OutStr+Ch;
           Print(Ch);
           LastX:=WhereX;
         End;
       End;
      End;
    End
   Else
    Begin
      For Loop:=1 To 500 Do
      Begin
        Slice;
        If (Not CharPressed) Then
        Begin
          Delay(1);
          Slice;
          If Loop=500 Then ReadChat;
        End;
      End;
    End;
    Slice;
  Until Ch=#13;

  ReadChat;

  If OutStr[1]='/' Then Cmd(OutStr) Else SaveChat('P');

  LastX:=1;
  GoXy(1,24); ClsEol;
  Ch:=#0;
  OutStr:='';
End;

Procedure Main;
Begin
  Repeat
    IOLoop;
  Until QuitIRC;
End;

Procedure IRCChat;
Begin
  Start;
  Main;
  Cls;
End;

Begin
End.