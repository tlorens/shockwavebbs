Unit ircstart;

Interface

Uses opCrt,Dos,ircVars,ircRecs,GenSubs,ircIO,ircDis,Vars,IO;

Procedure Start;

Implementation

Procedure Start;
Begin
  Color(7,0);
  Cls;
  QuitIRC:=False;
  User.Nick:=Copy(StripSpace(Urec^.Handle),1,10);

  ChatFile:=Copy(User.Nick,1,8)+'.CHT';
  LastX:=1;
  ChatY:=1;
  SignOn;
End;

Begin
End.