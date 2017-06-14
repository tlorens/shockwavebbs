{$I+}
Unit IRCIO;

Interface

Uses Dos,OpCrt,CnfgRec,IO,
     Gensubs,IRCRecs,IRCVars,IRCDis;

Procedure ReadChat;
Procedure SaveChat(Flag:Char);
Procedure SignOn;
Procedure SaveUser;
Procedure SignOff;
Procedure UserList;

Implementation

Procedure SaveMsgs(S:String);
Var T:Text;
    TS:String;
Begin
  TS:=ChatFile;
  Delete(TS,Length(TS)-2,3);
  TS:=TS+'SAV';
  Assign(T,CNF^.WorkDir+TS);
  If Exist(CNF^.WorkDir+TS) Then Append(T) else ReWrite(T);
  Writeln(T,S);
  Close(T);
End;

Procedure ReadChat;
Begin
  If Exist(CNF^.WorkDir+ChatFile) Then
  Begin
    Assign(ChatF,CNF^.WorkDir+ChatFile);
    Repeat
    {$I-} ReSet(ChatF);
         Delay(500);
    Until IOResult<>5;
    {$I+}

    While (Not EOF(ChatF)) Do
    Begin
      Read(ChatF,Chat);
      If Length(Chat.Text)>0 Then
      Begin
        WriteChat(Chat.From,Chat.Text,Chat.Flag);
        If Length(User.Away)>0 Then SaveMsgs('['+Chat.From+']'+Chat.Text);
      End;
    End;
    Erase(ChatF);
  End;
End;


Procedure SaveChat(Flag:Char);
var TmpFile:String;
    TmpU:UserRec;
    Found:Boolean;
Begin
  Chat.Flag:=Flag;
  Chat.From:=User.Nick;
  Chat.Text:=OutStr;

  TmpU.Idle:=TimePart(Now);
  SaveUser;
  Found:=False;

  Assign(UserF,CNF^.WorkDir+UserFile);
  Repeat
    {$I-} ReSet(UserF);
    Delay(500);
  Until IOResult<>5;
  {$I+}
  While NOT Eof(UserF) Do
  Begin
    Read(UserF,TmpU);
    If Length(TmpU.Nick)>0 Then
    Begin
      TmpFile:=Copy(TmpU.Nick,1,8)+'.CHT';
      Assign(ChatF,CNF^.WorkDir+TmpFile);
      If Exist(CNF^.WorkDir+TmpFile) Then
      Begin
        ReSet(ChatF);
        Seek(ChatF,FileSize(ChatF));
      End
     Else ReWrite(ChatF);

      If (Chat.Flag='M') and (Match(MsgTo,TmpU.Nick)) Then
      Begin
        Found:=True;
        Write(ChatF,Chat);
        WriteChat(MsgTo,' ®-'+Chat.Text,'M');
        If Length(TmpU.Away)>0 Then
          Writelist('   -¯ '+TmpU.Away);
      End;
      If (Chat.Flag<>'M') Then Write(ChatF,Chat);
      Close(ChatF);
    End;
  End;
  If (Not Found) and (Chat.Flag='M') Then WriteChat(MsgTo,'not found!','S');
  Close(UserF);
End;

Procedure SignOn;
Begin
  User.When:=Now;
  Assign(UserF,CNF^.WorkDir+UserFile);
  If Exist(CNF^.WorkDir+UserFile) Then
  Begin
    ReSet(UserF);
    Seek(UserF,FileSize(UserF));
  End
 Else
  ReWrite(UserF);
  Write(UserF,User);
  UNum:=FilePos(UserF)-1;
  Close(UserF);
  println('Welcome to ShockWavE:PRO-Chat v'+VerNum);
  println('');;
  println('Hello, '+User.Nick+', you are user number: '+Strr(Unum+1));
  ChatY:=WhereY+1;
  OutStr:='Has Joined Chat';
  SaveChat('S');
  OutStr:='';
End;

Function FindUNum(S:String):Integer;
Var Comp:UserRec;
Begin
  Assign(UserF,CNF^.WorkDir+UserFile);
  Repeat
  {$I-} ReSet(UserF);
     Delay(500);
  Until IOResult<>5;
  {$I+}
  FindUNum:=-1;
  While (Not EOF(UserF)) Do
  Begin
    Read(UserF,Comp);
    If Match(Comp.Nick,S) Then
    Begin
      FindUNum:=FilePos(UserF)-1;
      UNum:=FilePos(UserF);
      Close(UserF);
      Exit;
    End Else FindUNum:=-1;
  End;
  Close(UserF);
End;

Procedure SaveUser;
Var N:Integer;
Begin
  N:=FindUNum(User.Nick);
  If N>-1 Then
  Begin
    Assign(UserF,CNF^.WorkDir+UserFile);
    If Exist(CNF^.WorkDir+UserFile) Then
    Begin
      Repeat
        {$I-}
        ReSet(UserF);
        Delay(500);
      Until IOResult<>5;
      {$I+}
      Seek(UserF,N);
    End;
    Write(UserF,User);
    Close(UserF);
  End;
End;

Procedure SignOff;

  Procedure ReSort;
  Var U:UserRec;
      T:File Of UserRec;
  Begin
    Assign(UserF,CNF^.WorkDir+UserFile);
    ReSet(UserF);
    Assign(T,CNF^.WorkDir+'NEWUSR.DAT');
    ReWrite(T);
    While (Not EOF(UserF)) Do
    Begin
      Read(UserF,U);
      If Length(U.Nick)>0 Then Write(T,U);
    End;
    Erase(UserF);
    Close(T);
    Assign(T,CNF^.WorkDir+'NEWUSR.DAT');
    Rename(T,CNF^.WorkDir+UserFile);
  End;

Begin
  QuitIRC:=True;
  OutStr:='Has Left Chat';
  SaveChat('S');
  OutStr:='';
  ReadChat;
  Assign(UserF,CNF^.WorkDir+UserFile);
  ReSet(UserF);
  Seek(UserF,UNum-1);
  FillChar(User,SizeOf(User),#0);
  Write(UserF,User);
  Close(UserF);
  Resort;
End;

Procedure UserList;
Var TmpU:UserRec;
Begin
  Assign(UserF,CNF^.WorkDir+UserFile);
  ReSet(UserF);
  While NOT Eof(UserF) Do
  Begin
    Read(UserF,TmpU);
    WriteList(Strr(FilePos(UserF))+': '+TmpU.Nick+' -¯ '+DateStr(TmpU.When)+' at '+TimeStr(TmpU.When)+
              ' Idle: '+Strr(TimePart(Now)-TmpU.Idle));
    If Length(TmpU.Away)>0 Then Writelist('   -¯ '+TmpU.Away);
  End;
  Close(UserF);
End;

Begin
End.
