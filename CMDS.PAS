Unit Cmds;

Interface

Procedure Quit;
Procedure Msg(S:String);
Procedure Who;
Procedure Cmd(S:String);
Procedure Summon(S:String);
Procedure Away(S:String);

Implementation

Uses OpCrt,Dos,CnfgRec,IRCVars,Gensubs,IRCIO,IRCDis,IO;

Procedure Help;
Begin
  Writelist('/BYE     - Quit');
  Writelist('/W       - Whos in Chat');
  Writelist('/M       - Send Private Message');
  Writelist('/ME      - Perform an Action');
  Writelist('/CL      - Clear Screen');
  Writelist('/SETBACK - Set yourself as here');
  Writelist('/AWAY    - Set yourself as away');
End;

Procedure Msg(S:String);
Begin
  GoXy(1,1);
  Delete(S,1,3);
  MsgTo:=StripSpace(Copy(S,1,Pos(' ',S)));
  Delete(S,1,Length(MsgTo));
  OutStr:=Copy(S,1,Length(S));
  If Length(MsgTo)>0 Then SaveChat('M');
End;

Procedure Who;
Begin
  UserList;
End;

Procedure Quit;
Begin
  SignOff;
End;

Procedure Action(S:String);
Begin
  OutStr:=Copy(S,4,Length(S));
  SaveChat('A');
End;

Procedure Summon(S:String);
Begin
  WriteList('Not implemented yet!');
End;

Procedure Away(S:String);
Begin
  OutStr:=' Set away: ';
  OutStr:=OutStr+Copy(S,7,Length(S));
  User.Away:=OutStr;
  Saveuser;
  SaveChat('A');
End;

Procedure SetBack(S:String);
Var L,TS:String;
    T:Text;
Begin
  OutStr:=' Returns: '+Copy(S,10,Length(S));
  SaveChat('A');
  User.Away:='';
  SaveUser;
  TS:=ChatFile;
  Delete(TS,Length(TS)-2,3);
  TS:=TS+'SAV';
  If Exist(CNF^.WorkDir+TS) Then
  Begin
    Assign(T,CNF^.WorkDir+TS);
    ReSet(T);
    While (NOT Eof(T)) Do
    Begin
      Readln(T,L);
      WriteList(L);
    End;
    Erase(T);
  End;
End;

Procedure Cmd(S:String);
Begin
  User.Idle:=TimePart(Now);
  Saveuser;
  If Match(Copy(S,1,3),'/ME') Then Action(S) Else
  If Match(Copy(S,1,3),'/CL') Then Clear Else
  If Match(Copy(S,1,4),'/BYE') Then Quit Else
  If Match(Copy(S,1,2),'/W') Then Who Else
  If Match(Copy(S,1,5),'/HELP') Then Help Else
  If Match(Copy(S,1,5),'/AWAY') Then Away(S) Else
  If Match(Copy(S,1,8),'/SETBACK') Then SetBack(S) Else
  If Match(Copy(S,1,7),'/SUMMON') Then Summon(S) Else
  If Match(Copy(S,1,2),'/M') Then Msg(s);
End;

Begin
End.