{
  iB * 10/23/95 - Added (nX) flag for "If UserNumber > X"
                  not be be confused with (uX) flag for "If UserNumber=X"
  iB * 04/10/96 - Added WriteLog routines.
}

Unit Misc;

Interface

Function GetPassword(PW:String):Boolean;
Function GetAccess(St:String):Boolean;
Function IsSysOp:Boolean;
Procedure SummonSysOp;
Procedure ChangePWD;
Procedure SWDone(B:Byte);
Procedure LogOff(B:Byte);
Procedure Range(Var Min:Integer; Var Max:Integer);
Function ExecProtocol(PStr:String):Byte;

Implementation

Uses OpCrt,Dos,Records,Vars,IO,GenSubs,CnfgRec,User,Display,iCEMouse;

Function GetPassword(PW:String):Boolean;
Begin
  GetPassword:=True;
  If Length(PW)>0 Then
  Begin
    Dots:=True;
    {DotsPassword:=PW;}
    GetPassword:=False;
    Input:=Prompt(25,MyStr^.GetPassword,False);
    Dots:=False;
    {DotsPassword:='';}
    If (Match(PW,Input)) Then GetPassword:=True;
  End;
End;

Procedure SWDone(B:Byte);
Begin
  TextColor(7);
  Writeln;
  Writeln('þ ShockWavE:PRO Run:Halted(',B,') * ',TimeStr(Now),' ',DateStr(Now));
  WriteLog(1,1,'þ ShockWavE:PRO Run:Halted('+Strr(B)+') * '+TimeStr(Now)+' '+DateStr(Now));
  DeInitModem;    Writeln('þ DeInit Modem');          WriteLog(1,1,'þ DeInit Modem');
  Dispose(CNF);   Writeln('þ Dispose: Config');       WriteLog(1,1,'þ Dispose: Config');
  Dispose(Urec);  Writeln('þ Dispose: User Records'); WriteLog(1,1,'þ Dispose: User Records');
  Dispose(MyStr); Writeln('þ Dispose: Strings');      WriteLog(1,1,'þ Dispose: Strings');
  MouseOff;
  If Carrier Then Delay(2000);
  Halt(B);
End;

Procedure LogOff(B:Byte);
Begin
  Urec^.LastCall:=Now;
  Writeln('þ Resetting Node');
  {ResetNode('Not Logged In','Waiting...',False);
  Close(NodeFile);}
  AColor(7);
{  ResetSystem:=True;}
  HangUp;
  SWDone(B);
End;

Function IsSysOp:Boolean;
Begin
  If Urec^.Lvl>= CNF^.SysOpLvl Then IsSysOp:=True Else IsSysOp:=False;
End;

Procedure SummonBeep;
Var Count:Integer;
Begin
   Count:=0;
   While Count < 800 Do
     Begin
       Sound(300); NoSound;
       Sound(1500); NoSound;
       Sound(700); Nosound;
       Sound(1000); NoSound;
       Sound(1200); Nosound;
       Sound(300); Nosound;
       Sound(1600); Nosound;
       Sound(2200); NoSound;
       Sound(count); NoSound;
       Sound(Count+300); NoSound;
       Sound(Count+500); Nosound;
       Sound(Count+700); Nosound;
       SOund(Count);
       Delay(7);
       Nosound;
       inc(Count,15);
     End;
     NoSound;
     Count:=800;
     While Count > 0 Do
     Begin
       Sound(300); NoSound;
       Sound(1500); NoSound;
       Sound(700); Nosound;
       Sound(1000); NoSound;
       Sound(1200); Nosound;
       Sound(300); Nosound;
       Sound(1600); Nosound;
       Sound(2200); NoSound;
       Sound(count); NoSound;
       Sound(Count-300); NoSound;
       Sound(Count-500); Nosound;
       Sound(Count-700); Nosound;
       SOund(Count);
       Delay(7);
       Nosound;
       dec(Count,15);
     End;

End;

Procedure SummonSysOp;
Begin
  CntB:=0;
  Print('Paging '+CNF^.SysOpName);
  Repeat
    Inc(CntB);
    Delay(2000);
    SummonBeep;
    Print('.');
  Until (CharPressed) Or (HungUpOn) Or (CntB=15);
End;

Procedure ChangePWD;
Var t:Str10;
Begin
  If GetPassword(Urec^.Password[1]) Then
  Begin
    Dots:=true;
    Input:=Prompt(25,'Enter new password: ',False);
    Dots:=False;
    If length(input)>3 Then
    Begin
      Dots:=True;
      T:=Prompt(25,MyStr^.ReEnterPWPrmpt,False);
      Dots:=False;
      If Match(T,Input) Then
      Begin
        Urec^.Password[1]:=Input;
        WriteUser(Urec^);
        Println('Password changed.');
      End Else MCiWriteln(MyStr^.PWDontMatchstr);
    End
   Else
    Println('No change.')
  End
 Else MCIWriteln(MyStr^.WrongPW);
End;

function aacs1(u:userrec; un:integer; s:string):boolean;
var s1,s2:string;
    p1,p2,i,j:integer;
    c,c1,c2:char;
    b:boolean;

  { Used for Single char access, such as:  fZ (flag Z) or c1 (conf. 1) etc}
  Procedure Getrest;
  Begin
    s1:=c;
    p1:=i;
    If ((i<>1) and (s[i-1]='!')) Then
    Begin
      s1:='!'+s1;
      dec(p1);
    End;
    If (c in ['C','F','G','R','V','W']) Then
    Begin
      s1:=s1+s[i+1];
      inc(i);
    End
   Else
    Begin
      j:=i+1;
      Repeat
        If (s[j] in ['0'..'9']) Then
        Begin
          s1:=s1+s[j];
          inc(j);
        End;
      Until ((j>length(s)) or (not (s[j] in ['0'..'9'])));
      i:=j-1;
    End;
    p2:=i;
  End;

  function argstat(s:string):boolean;
  var One:string;
      year,month,day,dayofweek,hour,minute,second,sec100:word;
      Code:integer;
      boolstate,Axes:boolean;
  Begin
    boolstate:=(s[1]<>'!');
    If (not boolstate) Then s:=copy(s,2,length(s)-1);
    One:=copy(s,2,length(s)-1);
    Code:=valu(One);
    Case s[1] of
      'A':Axes:=(Uage(u.age)>=Code);
      'B':Axes:=(BaudRate>=Valu(One)) or (LocalLogin);
      'N':Axes:=(UNum > Code);
      'X':Axes:=(U.XLvl>=Code);
      'F':Axes:=Pos(upcase(One[1]),U.AccessFlags)<>0;
      'G':Axes:=(u.gender=upcase(One[1]));
      'H':Begin
            Gettime(hour,minute,second,sec100);
            Axes:=(hour=Code);
          End;
      'P':Axes:=(u.filepts>=Code);
      'S':Axes:=(u.lvl>=Code);
      'U':Axes:=(un=Code);
      'W':Begin
            getdate(year,month,day,dayofweek);
            Axes:=(dayofweek=Code);
          End;
    End;
    If (not boolstate) Then Axes:=not Axes;
    argstat:=Axes;
  End;

Begin
  S:=UpString(S);
  i:=0;
  While (i<length(s)) Do
  Begin
    inc(i);
    c:=s[i];
    If (c in ['A'..'Z']) and (i<>length(s)) Then
    Begin
      getrest;
      b:=argstat(s1);
      Delete(s,p1,length(s1));
      If (b) Then s2:='^' Else s2:='%';
      Insert(s2,s,p1);
      dec(i,length(s1)-1);
    End;
  End;
  s:='('+s+')';
  While (pos('&',s)<>0) Do Delete(s,pos('&',s),1);
  While (pos('^^',s)<>0) Do Delete(s,pos('^^',s),1);
  While (pos('(',s)<>0) Do
  Begin
    i:=1;
    While ((s[i]<>')') and (i<=length(s))) Do
    Begin
      If (s[i]='(') Then p1:=i;
      inc(i);
    End;
    p2:=i;
    s1:=copy(s,p1+1,(p2-p1)-1);
    While (pos('|',s1)<>0) Do
    Begin
      i:=pos('|',s1);
      c1:=s1[i-1]; c2:=s1[i+1];
      s2:='%';
      If ((c1 in ['%','^']) and (c2 in ['%','^'])) Then
      Begin
        If ((c1='^') or (c2='^')) Then s2:='^';
        Delete(s1,i-1,3);
        Insert(s2,s1,i-1);
      End
     Else
      Delete(s1,i,1);
    End;
    While(pos('%%',s1)<>0) Do Delete(s1,pos('%%',s1),1);   {leave only "%"}
    While(pos('^^',s1)<>0) Do Delete(s1,pos('^^',s1),1);   {leave only "^"}
    While(pos('%^',s1)<>0) Do Delete(s1,pos('%^',s1)+1,1); {leave only "%"}
    While(pos('^%',s1)<>0) Do Delete(s1,pos('^%',s1),1);   {leave only "%"}
    Delete(s,p1,(p2-p1)+1);
    Insert(s1,s,p1);
  End;
  aacs1:=(not (pos('%',s)<>0));
End;

Function GetAccess(St:String):Boolean;
Begin
  GetAccess:=False;
  GetAccess:=AACS1(Urec^,UNum,St);
End;

Procedure Range(Var Min:Integer; Var Max:Integer);
Var Holder:Integer;
Begin
  Holder:=Max;
  Input:=Prompt(11,'|09Range |01[|11'+Strr(Min)+'|13..|11'+Strr(Max)+'|01]|03 |08(|07CR/All|08)|07: ',False);

  If Valu(Input)>Max Then Input:=Strr(max);

  If (Length(Input)=0) Then Exit;

  If Input[1]='-' Then Input:=Copy(Input,2,Length(Input));

  If Input[Length(Input)]='-' Then
  Begin
    Min:=Valu(Copy(Input,1,Pos('-',Input)-1));
    If Min=0 Then Min:=1;
    Max:=Holder;
  End
 Else
  If Pos('-',Input)<>0 Then
  Begin
    If Pos('-',Input)>0 Then Min:=Valu(Copy(Input,1,Pos('-',Input)-1));
    If Min=0 Then Min:=1;
    If Pos('-',Input)>0 Then Max:=Valu(Copy(Input,Pos('-',Input)+1,Length(Input)));
    If Max=0 Then Max:=Holder;
  End
 Else
  If Valu(Input)=0 Then
  Begin
    Min:=1;
    Max:=1;
  End
 Else
  Begin
    Min:=Valu(Input);
    Max:=Min;
  End;
End;

Procedure DOSErrCode(B:Byte);
Begin
  Case B Of
    2 :WriteLog(1,1,'(2) File not found');
    3 :WriteLog(1,1,'(3) Path not found');
    5 :WriteLog(1,1,'(5) Access denied');
    6 :WriteLog(1,1,'(6) Invalid handle');
    8 :WriteLog(1,1,'(8) Not enough memory');
   10 :WriteLog(1,1,'(10) Invalid environment');
   11 :WriteLog(1,1,'(11) Invalid format');
   18 :WriteLog(1,1,'(18) No more files');
  End;
End;

Procedure DOSExtCode(B:Byte);
Begin
  Case B Of
    1:WriteLog(1,1,'(1) Ctrl-C');
    2:WriteLog(1,1,'(2) Device error');
    3:WriteLog(1,1,'(3) Keep procedure');
  End;
End;

Function ExecProtocol(PStr:String):Byte;
Var S:String;
   CurDir:String;
Begin
  GetDir(0,CurDir);
  If CurDir[Length(CurDir)]<>'\' Then CurDir:=CurDir+'\';
  S:='';
  For CntB:=1 to Length(PStr) Do
  Begin
    If PStr[CntB]='%' Then
    Begin
      Case Valu(PStr[CntB+1]) Of
        1:S:=S+Strr(CNF^.ModemPort);
        2:S:=S+Strr(BaudRate);
        3:S:=S+'@'+CNF^.WorkDir+'DOWNLOAD.'+Strr(Node);
      End;
      Inc(CntB);
    End Else S:=S+PStr[CntB];
  End;
  Debugln(S,3);
  SwapVectors;
    Exec(GetEnv('COMSPEC'),'/C '+S);
  SwapVectors;
  DOSErrCode(DOSError);
  Println('');
  DOSExtCode(DOSExitCode);
End;

Begin
End.