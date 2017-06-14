{
  iB * 08/01/05 - Complete Login/Matrix routines.
  iB * 08/08/95 - Made it possible for multiple user files to be used
                  and fixed up MatrixLogin routine.
  iB * 08/11/95 - Removed MatrixChat/FeedBack/Logoff -- Not needed!
}
{$D+,L+}
Unit GetLogin;

Interface

Procedure MatrixLogin(U:String); {U:String = the user file to open}
Procedure MatrixApply(U:String); {U:String = the user file to open}
Procedure MatrixCheck(U:String); {U:String = the user file to open}
Procedure DetectANSi;
Procedure DetectRIP;
Procedure DetectShckTerm;

Implementation

Uses opcrt,CnfgRec,Records,Display,User,GenSubs,Vars,IO,Misc,
     Windows,Timer;

Procedure DetectANSi;
Var Cpl:String;
    TimeOut:Integer;
    C:Char;
Begin
  If Carrier then
  Begin
    MCiWriteln(MyStr^.DetectANSi);
    ModemPrint(#27+'[6n'+^H^H^H^H);
    TimeOut:=0;
    Cpl:='';
    Delay(3500);

    While (CharPressed) {Or (TimeOut<2000)} do
    Begin
      Inc(TimeOut);
      GetChar(C);
      Cpl:=Cpl+C;
    End;

    If Pos(#27+'[',Cpl)<>0 then
    Begin
      Emulation:=1;
      MCiWriteln(MyStr^.GotANSi);
    End
   Else
    Begin
      Emulation:=0;
      MCiWriteln(MyStr^.NoANSi);
      Println('');
      WriteHdr('Terminal Emulation');
      Input:=Prompt(1,MyStr^.AskANSi,Urec^.MenuType=1);
      Case Upcase(Input[1]) Of
        'N':Emulation:=0;
        'A':Emulation:=1;
        'M':Emulation:=2;
        'R':Emulation:=3;
        Else Emulation:=1;
      End;
    End;
  End
 Else Emulation:=1; { Local Emulation setting }
End;

Procedure DetectRIP;
Var Cpl:String;
    C:Char;
Begin
  If Carrier Then
  Begin
    MCiWriteln(MyStr^.ChkRIP);
    ModemPrint(#27+'[!'+^H^H^H);
    Delay(3500);
    Cpl:='';
    While CharPressed Do
    Begin
      GetChar(C);
      Cpl:=Cpl+C;
    End;
    If Pos('RIPSCRIP',Cpl)>0 Then
    Begin
      MCiWriteln(MyStr^.HaveRIP);
      Emulation:=3;
    End;
  End Else If YeaNa('Use RiP:',False) Then Emulation:=3;
End;

Procedure DetectShckTerm;
Var Cpl:String;
    C:Char;
Begin
  If Carrier Then
  Begin
    ModemPrint(#27+^U);
    Delay(2000);
    MCiWriteln('|11PRO:Vision |09Emulation Check...');
    ModemPrint('v'+^H^H);
    Delay(3000);
    Cpl:='';
    While CharPressed Do
    Begin
      GetChar(C);
      Cpl:=Cpl+C;
    End;
    If Pos('PVIS',Cpl)>0 Then
    Begin
      MCiWriteln('Ok!');
      Emulation:=4;
    End;
  End;
End;


Procedure AddLastCaller (n:Str25);
var qf:file of lastrec;
    last,cnt:integer;
    l:lastrec;
Begin
  If Match(n,CNF^.SysopName) Then Exit;
  Assign(qf,CNF^.DataDir+'CALLERS.DAT');
  Reset(qf);
  Last:=filesize(qf);
  if last>20 then last:=20;
  for cnt:=last-1 downto 0 do
  begin
    seek (qf,cnt);
    read (qf,l);
    seek (qf,cnt+1);
    write (qf,l)
  end;
  with l do
  begin
    name:=n;
    when:=now;
    lastbps:=BaudRate;
    {callnum:=round(numcallers)}
  end;
  seek (qf,0);
  write (qf,l);
  close (qf)
end;

Procedure MatrixCheck(U:String); {U:String = the user file to open}
Begin
  OpenUFiles(U);
  CleanURec;
  StatusBar(CurStat);
  Input:=Prompt(25,MyStr^.GetHandle,False);
  If ValidUserName(Input) then
  Begin
    WriteLog(6,1,Input+' Checked for access');
    FindUser(Input,UNum);
    If UNum>-1 Then
    Begin
      SeekUFile(UNum);
      ReadUser(Urec^);
      If Urec^.Lvl>=CNF^.SecCallLvl Then PrintLn('You are a validated user!') Else MCiWriteln(MyStr^.UsrNotValidated);
      CleanURec;
      UNum:=-1;
    End
  End;
  CloseUFiles;
End;

Procedure MatrixApply(U:String); {U:String = the user file to open}
Var Gend:String;
    NiceTry:Byte;
Begin

  OpenUFiles(U);
  CleanURec;
  StatusBar(CurStat);

  Input:=#0;
  NiceTry:=0;

  Repeat
    Inc(NiceTry);
    Input:=Prompt(25,MyStr^.NewHandle,False);
  Until (YeaNa(Input+' is your current login ID, is this correct:',True)) or
        (NiceTry>5) or (HungUpOn);

  If NiceTry>5 Then HangUp;

  If ValidUserName(Input) then
  Begin
    If DupHandle(Input) then
    Begin
      MCiWriteLn(MyStr^.DupHandle);
      Delay(2000);
    End
   Else
    Begin
      CleanURec;
      { Create Users: Defaults }
      With Urec^ Do
      Begin
        Handle:=Input;
        Dots:=True;
        NiceTry:=0;
        Repeat 
          If HungUpOn Then hangUp;
          Inc(NiceTry);
          Input:=Prompt(25,MyStr^.NewPassword,False);
          Password[1]:=Prompt(25,MyStr^.ReEnterPWPrmpt,False);
        Until (Match(Input,Password[1])) Or (NiceTry>5) or (HungUpOn);
        If NiceTry>5 Then HangUp;
        Password[1]:=Input;
        Dots:=False;
        RealName:=Prompt(25,MyStr^.GetRealName,False);
        Age:=Prompt(8,MyStr^.BirthDate,False);
        Gend:=Prompt(1,MyStr^.GenderPrompt,False);
        Gender:=Upcase(Gend[1]);
        Phone[1]:=Prompt(13,MyStr^.GetPhone,False);
        ScrnLength:=Valu(Prompt(2,MyStr^.ScrLen,False));
        UserNote:=Prompt(25,'User Note: ',False);
        MsgHeader:=1;
        DefProtocol:=1;
        {MenuType}
        {Expert}
        Lvl:=0;
        XLvl:=0;
        LastCall:=Now;
        UserVersion:=Revision;
        Regularcolor:=7;
        Promptcolor:=9;
        Statcolor:=11;
        Inputcolor:=3;
        CmdColor:=15;
        MiscColor:=8;
        InsideColor:=9;
        BoxColor:=8;
     End;
     WriteLog(6,1,'**** '+Urec^.Handle+' Applied For Access ****');
     { do fullscreen newuser configuration screen and then ask toa save changes }
     AddUser(Urec^);
     FindUser(Urec^.Handle,UNum);
    End; { end if duplicate }
  End; { end validuser name }
  CloseUFiles;
End;

Procedure MatrixLogin(U:String); {U:String = the user file to open}
Begin
  OpenUFiles(U);
  CleanURec;
  StatusBar(CurStat);

  { Dunno how I'm gonna get AutoLogin to work }
(*  If (CNF^.UseAutoLogin) Then
  Begin
    FindUser(CNF^.SysOpName,UNum);
    SeekUfile(UNum-1);
    UNum:=ReadUser(Urec^);
    If DatePart(Urec^.LastCall)<>DatePart(Now) Then Urec^.TimeLeft:=Urec^.TimeLimit;
    TimeLeft:=Urec^.TimeLeft;
    WriteLog(6,1,'*** '+Urec^.Handle+' Logged in. ***');
    StatusBar(CurStat);
    CloseUFiles;
    Exit; { Sloppy  code sucks.. But it works! }
  End;*)

  Input:='';
  Input:=Prompt(25,MyStr^.GetHandle,False);
  If ValidUserName(Input) Then
  Begin
    If (Valu(Input) <= NumUsers) and (Valu(Input) > 0) Then UNum:=Valu(Input)+1 Else FindUser(Input,UNum);
    If UNum>-1 Then
    Begin
      SeekUfile(UNum-1);
      UNum:=ReadUser(Urec^);
      If Length(Urec^.Handle) = 0 Then 
      Begin
        CleanURec;
        UNum:=-1;
        CloseUFiles;
        Exit;
      End;
      {ResetNode(Urec^.Handle,'Logging In',False);}
      If GetPassword(Urec^.Password[1]) Then
      Begin
        SeekUfile(UNum);
        UNum:=ReadUser(Urec^);
        If DatePart(Urec^.LastCall)<>DatePart(Now) Then Urec^.TimeLeft:=Urec^.TimeLimit;

        Inc(Urec^.NumCalls);
        WriteLog(6,1,'|15*** '+Urec^.Handle+' Logged in. ***');

        UserUpgrades; (* For when I add new stuff to user records *)

        AddLastCaller(Urec^.Handle);
        StatusBar(CurStat);

        {If CNF^.MultiNode Then
        Begin
          For CntB:=1 to MaxNodes Do
          Begin
            ReadNode(CntB);
            If (Not Match(ChatNode.Activity,'Waiting...')) then
            Begin
              If SendSysMsg(CntB,Urec^.Handle,'Just Logged in...') <> 0 Then
              Begin
                Delay(1000);
                If SendSysMsg(CntB,Urec^.Handle,'Just Logged in...') <> 0 Then;
              End;
            End;
          End;
        End;} { if multinode }

      End { if getpassword() }
     Else
      Begin
        CleanURec;
        UNum:=-1;
      End; { else Invalid Password }
    End { UserName Found }
   Else
   Begin
     CleanUrec;
     UNum:=-1;
   End;
  End; { if ValidUserName }
  CloseUFiles;
End;

Begin
End.