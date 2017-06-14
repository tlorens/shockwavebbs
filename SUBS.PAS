{
 iB * 08/01/95 - General User Options.  Any MISC funtion should go in here.
                 BBSlisting/Voting/etc.
 Nk * 08/04/95 - Created TheWall
 Nk * 08/09/95 - Created TimeBank
 iB * 08/22/95 - Ability to pass-in Wall/User/BBS File + Top/Mid/Bot File
                 Optimized TheWall a bit. P1=Parameter1/P2=Parmeter2
 iB * 10/11/95 - Completely repaired TheWall.
 iB * 05/24/97 - Added: AddBBS, DelBBS, EditBBS Routines.
 iB * 05/26/97 - Ripped out old MultiNode Chat routines.
}

Unit Subs;

Interface

Procedure TimeBank(P1:String);
Procedure Wall(P1,P2:String);
Procedure ListUsers(P1,P2:String);
Procedure AddBBS(P1,P2:String);
Procedure BBSLister(P1,P2:String);
Procedure EditBBS(P1,P2:String);
Procedure DelBBS(P1,P2:String);
Function RndLiner(P1:String):String;
Function RndBBSAd(P1:String):String;
Procedure ReadAutoMsg;
Procedure SaveAutoMsg;
Procedure LeaveFeedBack(P1:String);
Procedure GetLanguage(B:Byte);
Procedure PageMe(P1,P2:String);
Procedure WhosOnLine;
Procedure SwitchUser;

Implementation

Uses OpCRT,DOS,Vars,Gensubs,Display,CnfgRec,
     User,Records,IO,MSub1,Multi,Misc;

Var BBSFile: File of BBSRec;
    BS: BBSRec;

Procedure ListUsers(P1,P2:String);
Var UF:File Of UserRec;
    U:UserRec;
    Txt:File;
    Chk:String[2];
    Num,Cnt:Word;
    NumRead:Word;
    Buf:Array[1..4096] of Char;
Begin
  Num:=0;
  If Exist(CNF^.MenuDir+P2+'.TOP') Then PrintFile(CNF^.MenuDir+P2+'.TOP')
 Else
  Begin
    Cls;
    MCiWriteln('|11User Handle ');
    MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  End;
  Assign(Uf,CNF^.DataDir+P1);
  ReSet(Uf);
  Seek(UF,1);
  While Not EOF(UF) do
  Begin
    Read(UF,U);
    If Exist(CNF^.MenuDir+P2+'.MID') Then
    Begin
      Assign(Txt,CNF^.MenuDir+P2+'.MID');
      Reset(Txt,1);
      Repeat
        Cnt:=1;
        FillChar(Buf,SizeOf(Buf),#0);
        BlockRead(Txt,Buf,Sizeof(buf),NumRead);
        Repeat
          If Buf[Cnt]='|' Then
          Begin
            Inc(Cnt);
            Chk:=Upcase(Buf[Cnt])+Upcase(Buf[Cnt+1]);
            Inc(Cnt);
            If (Chk='HA') and (U.Handle<>'') then 
            Begin 
              Print(U.Handle);
              Inc(Num);
              If Num>22 then 
              Begin
                Num:=0;
                If Not YeaNa('More',True) Then
                Begin
                  Close(UF);
                  Exit;
                End;
              End;
            End else
            If Chk='CR' Then Println('') Else
            If Chk='NX' then if Not EOF(UF) then Read(UF,U);
          End Else Print(Buf[Cnt]);
          Inc(Cnt);
        Until (Buf[Cnt]=#0) or (HungUpOn);
      Until (Numread=0) or (HungUpOn);
      Close(Txt);
    End
   Else 
    Begin
      If U.Handle<>'' Then MCiWriteln('|03'+U.Handle);
      Inc(Num);
      If Num>22 then 
      Begin
        Num:=0;
        If Not YeaNa('More',True) Then
        Begin
          Close(UF);
          Exit;
        End;
      End;
    End;
  End;
  Close(UF);
  If Exist(CNF^.MenuDir+P2+'.BOT') Then PrintFile(CNF^.MenuDir+P2+'.BOT')
End;

Procedure AddBBS(P1,P2:String);

  Procedure CheckFile;
  Begin
    If NOT Exist(CNF^.DataDir+P1) then
    Begin
      Assign(BBSFile,CNF^.DataDir+P1);
      ReWrite(BBSFile);
      With BS Do
      Begin
        BoardName:=Prompt(25,'System Name: ',False);
        LeftBy:=Urec^.Handle;
        Baud:=Prompt(25,'Max Baud: ',False);
        Phone:=Prompt(25,'Phone Number: ',False);
        Software:=Prompt(25,'Software: ',False);
        Description:=Prompt(25,'Description: ',False);
      End;
      Write(BBSfile,BS);
      Close(BBSFile);
    End
   Else
    Begin
      Assign(BBSFile,CNF^.DataDir+P1);
      ReSet(BBSFile);
     End;
  End;

Begin
  If Exist(CNF^.MenuDir+P2+'.TOP') Then PrintFile(CNF^.MenuDir+P2+'.TOP');
  CheckFile;
  Seek(BBSFile,FileSize(BBSFile));
  With BS Do
  Begin
    BoardName  :=Prompt(25,'System Name: ',False);
    LeftBy     :=Urec^.Handle;
    Baud       :=Prompt(4,'Max Baud: ',False);
    Phone      :=Prompt(10,'Phone Number: ',False);
    Software   :=Prompt(10,'Software: ',False);
    Description:=Prompt(79,'Description: ',False);
  End;
  Write(BBSfile,BS);
  Close(BBSFile);
End;

Procedure BBSLister(P1,P2:String);
Var
    Txt:File;
    Chk:String[2];
    Cnt:Word;
    NumRead:Word;
    Buf:Array[1..4096] of Char;

  Procedure CheckFile;
  Begin
    If NOT Exist(CNF^.DataDir+P1) then
    Begin
      Assign(BBSFile,CNF^.DataDir+P1);
      ReWrite(BBSFile);
      With BS Do
      Begin
        BoardName:=Prompt(25,'System Name: ',False);
        LeftBy:=Urec^.Handle;
        Baud:=Prompt(25,'Max Baud: ',False);
        Phone:=Prompt(25,'Phone Number: ',False);
        Software:=Prompt(25,'Software: ',False);
        Description:=Prompt(25,'Description: ',False);
      End;
      Write(BBSfile,BS);
      Close(BBSFile);
    End
   Else
    Begin
      Assign(BBSFile,CNF^.DataDir+P1);
      ReSet(BBSFile);
     End;
  End;

  Procedure List;
  Begin
    If Exist(CNF^.MenuDir+P2+'.TOP') Then PrintFile(CNF^.MenuDir+P2+'.TOP')
   Else
    Begin
      Cls;
      MCiWriteln('|11BBS Name                 |03Baud Phone #      |11Software ');
      MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    End;
    While Not Eof(BBSFile) Do
    Begin
      Read(BBSFile, BS);
      If Exist(CNF^.MenuDir+P2+'.MID') Then
      Begin
        Assign(Txt,CNF^.MenuDir+P2+'.MID');
        Reset(Txt,1);
        Repeat
          Cnt:=1;
          FillChar(Buf,SizeOf(Buf),#0);
          BlockRead(Txt,Buf,Sizeof(buf),NumRead);
          Repeat
            If Buf[Cnt]='|' Then
            Begin
              Inc(Cnt);
              Chk:=Upcase(Buf[Cnt])+Upcase(Buf[Cnt+1]);
              Inc(Cnt);
              If Chk='NA' then Print('|11'+BS.BoardName) else
              If Chk='BA' Then Print(BS.Baud) Else
              If Chk='PH' Then Print('|03'+BS.Phone) Else
              If Chk='SF' Then Print('|11'+BS.Software) Else
              If Chk='DE' Then Print(BS.Description) Else
              If Chk='CR' Then Println('') Else
              If Chk='NX' then if Not EOF(BBSFile) then Read(BBSFile,BS);
            End Else Print(Buf[Cnt]);
            Inc(Cnt);
          Until (Buf[Cnt]=#0) or (HungUpOn);
        Until (Numread=0) or (HungUpOn);
        Close(Txt);
      End Else
      With BS Do PrintLn(TabStr(BoardName,25)+TabStr(Baud,5)+TabStr(Phone,13)+TabStr(Software,25));
    End;
    If Exist(CNF^.MenuDir+P2+'.BOT') Then PrintFile(CNF^.MenuDir+P2+'.BOT')
    Else MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    Close(BBSFile);
  End;

Begin
  CheckFile;
  WriteHdr(MyStr^.BBSlistHdr);
  List;
End;

Procedure EditBBS(P1,P2:String);
Begin
  
End;

Procedure DelBBS(P1,P2:String);
Begin
  
End;

Function RndBBSAd(P1:String):String;
Begin
  If Exist(CNF^.DataDir+P1) Then
  Begin
    Assign(BBSFile,CNF^.DataDir+P1);
    Reset(BBSFile);
    Randomize;
    Seek(BBSFile,Random(FileSize(BBSFile)));
    Read(BBSFile,BS);
    Close(BBSFile);
    With BS Do RndBBSAd:=BoardName+' '+Baud+' '+Phone+' '+Software+#13+Description;
  End;
End;

Procedure Wall(P1,P2:String);
Type WallRec=Record
        Who, Words:String;
     End;

Var WallF, TempF: File of WallRec;
    WInfo: WallRec;
    TmpWInfo: WallRec;
    i:integer;
    Txt:Text;
    Chk:String[2];
    Cnt:Word;
    Ch:Char;

Begin
  I:=0;
  If (Not Exist(CNF^.DataDir+P1)) Then
  Begin
    Assign(WallF,CNF^.DataDir+P1);
    ReWrite(WallF);
    WInfo.Who:='ShockWavE';
    WInfo.Words:='ShockWavE:PRO BBS Wall...';
    Write(WallF,WInfo);
    Close(WallF);
  End;

  If Exist(CNF^.MenuDir+P2+'.TOP') Then PrintFile(CNF^.MenuDir+P2+'.TOP')
 Else
  Begin
    Cls;
    WriteHdr(CNF^.FullSysName+' Wall');
    MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  End;

  Assign(WallF,CNF^.DataDir+P1);
  ReSet(WallF);
  While (Not EOF(WallF)) Do
  Begin
    Read(WallF,WInfo);

    If Exist(CNF^.MenuDir+P2+'.MID') Then
    Begin
      Assign(Txt,CNF^.MenuDir+P2+'.MID');
      ReSet(Txt);
      While (Not EOF(Txt)) and (Not HungUpOn) Do
      Begin
        Read(Txt,Ch);
        If Ch='|' Then
        Begin
          Read(Txt,Ch); Chk:=Ch;
          Read(Txt,Ch); Chk:=Chk+Ch;
          If Chk='HA' then MCIWriteLn('|03'+WInfo.Words) else
          If Chk='CR' Then Println('') Else
          If Chk='NX' then if Not EOF(WallF) then Read(WallF,WInfo);
        End Else Print(Ch);
        Inc(Cnt);
      End;
      Close(Txt);
    End Else MCiPrintln('|RE'+WInfo.Words);
  End;
  If Exist(CNF^.MenuDir+P2+'.BOT') Then PrintFile(CNF^.MenuDir+P2+'.BOT')
 Else MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

  Println('');
  If (Not YeaNa(MyStr^.WallPrompt,False)) Then
  Begin
    Close(WallF);
    Exit;
  End;

  Println('Use |01-|15 For Colors');
  MCiWriteln('|REPlese enter your graffiti |08(|07CR|15/|07Abort|08)|RE');
  Input:='';
  Edit(Input,WhereX,WhereY,75,False);
  Println('');

{  Input:=Prompt(75,'|PR>|IN');}

  If Length(input)>3 then
  Begin
    WInfo.Who:=Urec^.Handle;
    WInfo.Words:=Input;
    Write(WallF,WInfo);

    If (FileSize(WallF)<20) Then 
    Begin
      Assign(TempF, CNF^.DataDir+Copy(P1,1,Length(P1)-4)+'$$$'); 
      ReWrite(TempF);
      Seek(WallF,1); 
      While Not Eof(WallF) Do
      Begin
        Read(WallF,WInfo);
        Write(TempF,WInfo);
      End;
      Close(WallF); Erase(WallF);
      Close(TempF);
  
      Assign(TempF,CNF^.DataDir+Copy(P1,1,Length(P1)-4)+'$$$');
      Rename(TempF,CNF^.DataDir+P1);
    End;
    Println('');
    Println('þ Graffiti Posted þ');
  End;
End;

Function RndLiner(P1:String):String;
Type WallRec=Record
        Who, Words:String;
     End;

Var WallF, TempF: File of WallRec;
    WInfo: WallRec;
    R:Byte; 
Begin
  If (Exist(CNF^.DataDir+P1)) Then
  Begin
    Assign(WallF,CNF^.DataDir+P1);
    Reset(WallF);
    Randomize;
    R:=Random(FileSize(WallF));
    Seek(WallF,R);
    Read(WallF,WInfo);
    RndLiner:=WInfo.Words;
    Close(WallF);
  End;
End;

Procedure TimeBank(P1:String);
Var TChange: Integer;
    TempStr: String;

  Procedure CheckTime;
  Begin
     If (URec^.TimeBank < 0) Then
     Begin
        URec^.TimeBank := 0;
        WriteUser(URec^);
     End;
  End;

  Procedure DisplayBank;
  Begin
     If Exist(CNF^.MenuDir+'TBANK.TOP') Then PrintFile(CNF^.MenuDir+'TBANK.TOP')
     Else
     Begin
       Cls;
       WriteHdr(MyStr^.TimeBankHdr);
       MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
     End;
     MCiWriteln('|03Time Left Online   Time Deposited');
     With URec^ Do MCiWriteln('|11'+TabStr(Strr(TimeLeft),19)+Strr(TimeBank));
     If Exist(CNF^.MenuDir+'TBANK.BOT') Then PrintFile(CNF^.MenuDir+'TBANK.BOT')
     Else MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  End;

  Procedure WithDrawal;
  Begin
     TempStr := Prompt(5, '|03Enter time to withdrawal|09:|07 ',false);
     TChange := Valu(TempStr);
     If (TChange <= 0) Or (TChange > URec^.TimeBank) Then MCiWriteln('|12Invalid Time')
    Else
     Begin
        URec^.TimeLeft := URec^.TimeLeft + TChange;
        URec^.TimeBank := URec^.TimeBank - TChange;
        WriteUser(Urec^);
        MCiWriteln('|09You now have |11'+ Strr(URec^.TimeLeft)+' |09minutes left');
     End;
  End;

  Procedure Deposit;
  Begin
     TempStr := Prompt(5, '|03Enter time to deposit|09:|07 ',False);
     TChange := Valu(TempStr);
     If (TChange <= 0) Or (TChange > (URec^.TimeLeft - 5)) Then MCiWriteln('|12Invalid Time')
     Else
     Begin
        URec^.TimeLeft := URec^.TimeLeft - TChange;
        URec^.TimeBank := URec^.TimeBank + TChange;
        WriteUser(Urec^);
        MCiWriteln('|09You now have |11'+ Strr(URec^.TimeBank)+' |09minutes deposited');
     End;
  End;

Begin
   CheckTime;
   If P1='DEPOSIT' Then Deposit;
   If P1='WITHDRAW' Then Withdrawal;
   If P1='DISPLAY' Then DisplayBank;
End;

Procedure ReadAutoMsg;
Var  AMsg:AutoMsgRec;
    AMsgF:File of AutoMsgRec;
    X:Byte;
Begin
  If Exist(CNF^.MsgDir+'AUTO.MSG') Then
  Begin
    Assign(AMsgF,CNF^.MsgDir+'AUTO.MSG');
    Reset(AmsgF);
    Read(AMsgF,AMsg);
    Close(AMsgF);
    MCIPrintln('|11Auto-Message Left By: |15'+Amsg.From);
    MCIPrintln('');
    For X:=1 to 3 Do 
      If Length(Amsg.Line[X])>0 Then 
        MCIPrintln(AMsg.Line[X]);
        MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|07');
  End;
End;

Procedure SaveAutoMsg;
Var  AMsg:AutoMsgRec;
    AMsgF:File of AutoMsgRec;
    X:Byte;
Begin
  FillChar(AMsg,SizeOf(AMsg),#0);
  MCIPrintln('Enter up to 3 lines of text (75 Chars/Line)');
  MCIPrintln('Blank lines will be ignored. ');
  MCIPrintln('');
  MCIPrintln('|09[----+----:----+----:----+----:----+----:----+----:----+----:----+----:----+]');
  AMsg.From:=Urec^.Handle;
  Print(' ');Edit(AMsg.Line[1],WhereX,WhereY,75,False);
  Println('');
  Print(' ');Edit(AMsg.Line[2],WhereX,WhereY,75,False);
  Println('');
  Print(' ');Edit(AMsg.Line[3],WhereX,WhereY,75,False);
  Println('');                              

{  AMsg.Line[1]:=Prompt(75,'|111|03:|08>');
  AMsg.Line[2]:=Prompt(75,'|112|03:|08>');
  AMsg.Line[3]:=Prompt(75,'|113|03:|08>');}
  MCIPrintln('|07');

  Assign(AMsgF,CNF^.MsgDir+'AUTO.MSG');
  Rewrite(AmsgF);
  Write(AMsgF,AMsg);
  Close(AMsgF);
End;

Procedure LeaveFeedBack(P1:String);
Var X,Cnt:Byte;
   List:Array[1..10] of Str25;
    T:Text;
    Line:String;
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);

  WriteHdr('Post FeedBack');
  Cnt:=1;
  List[Cnt]:=CNF^.SysOpName;

  If Length(P1)>0 Then List[Cnt]:=P1;

  If Exist('SYSOP.LST') and (Length(P1)=0) Then
  Begin
    Assign(T,'SYSOP.LST');
    ReSet(T);
    While (Not EOF(T)) Do
    Begin
      Readln(T,Line);
      Inc(Cnt);
      List[Cnt]:=Line;
      MCIWriteln('|08[|11'+Strr(Cnt)+'|08] |09'+Line);
    End;
    Close(T);
    Line:=Prompt(2,'FeedBack to who: ',False);
    X:=Valu(Line);
    If (X<1) or (X>Cnt) Then Cnt:=1;
  End;

  With MHdr Do
  Begin
    SendTo:=List[Cnt];
    Title:=Prompt(40,MyStr^.TitlePrompt,False);
    If Length(Title)>0 Then
    Begin
      Anon:=False;
      MsgType:=3;
      If Urec^.Handle='' Then From:=Prompt(40,MyStr^.GetHandle,False) else From:=Urec^.Handle;
      RealName:=Urec^.RealName;
      Deleted:=False;
      If PostMsg(3,False) Then Println('Message Saved!') Else Println('Message Aborted!');
    End;
  End;
End;

Procedure GetLanguage(B:Byte);
Var TmpStr :StringRec;   { System Strings  }
    StrFile:File Of StringRec;
    Chk:Byte;
Begin
  Assign(StrFile,CNF^.DataDir+'STRINGS.DAT');
  Reset(StrFile);

  If B=0 Then
  Begin
    If Exist(CNF^.MenuDir+'LANG.ANS') Then PrintFile(CNF^.MenuDir+'LANG.ANS');
    Input:=Prompt(1,'Select Language: ',Urec^.MenuType=1);
    If Length(Input)>0 Then Chk:=Valu(Input);
    If (Chk>0) and (Chk<=FileSize(StrFile)) Then
    Begin
      Seek(StrFile,Chk-1);
      Read(StrFile,MyStr^);
    End;
  End 
 Else
  Begin
    Seek(StrFile,B-1);
    Read(StrFile,MyStr^);
  End;
  Close(StrFile);
End;

Procedure Pageme(P1,P2:String);
{P1=Filename P2=Max Chars}
Var From:String[25];
    Msg:String[225];
    Line:Array[1..3] Of String[75];
    Cnt:Byte;
    T:Text;
Begin
  ClrScr;
  Msg:='';
  MCIPrintln('|07Send Message to |15'+CNF^.SysOpName+'s |07Pager');
  MCIPrintln('|14');
  From:=Urec^.Handle;
  MCIPrintln('Enter up to 3 lines of text (75 Chars/Line)');
  MCIPrintln('Blank lines and MCiCodes will be ignored. ');
  MCIPrintln('');
  MCIPrintln('|09  [----+----:----+----:----+----:----+----:----+----:----+----:----+----:----+]');
  Line[1]:=Prompt(75,'|111|03:|08>',False);
  Line[2]:=Prompt(75,'|112|03:|08>',False);
  Line[3]:=Prompt(75,'|113|03:|08>',False);
  MCIPrintln('|07');
  Msg:='From: '+From+'> ';
  For Cnt:=1 to 3 Do If Length(Line[Cnt])>0 Then Msg:=Msg+Line[Cnt];

  For Cnt:=1 to Length(Msg) Do If Msg[Cnt]='|' then Delete(Msg,Cnt,3);

  Println(Msg);

  MCiPrintln('|03');

  If YeaNa('Is this correct:',True) Then
  Begin
    Assign(T,P1);
    ReWrite(T);
    Write(T,Msg);
    Close(T);
    Println('Message will be sent after you hangup!');
  End;
End;

Procedure WhosOnLine;
Var I:Byte;
    H,A:Str25;
    Av:Boolean;
Begin
  WriteHdr('Who''s On-Line');
  { Add Top/Mid/Bot here }
  Tab('Node',6); Tab('Handle',27); Tab('Activity',25); Println('Chat Status');
  Println('');
  Tab('0',6); Tab(CNF^.SysOpName,27); Tab('Idle...',25);
  If {SysOpIsAvail} True Then Println('Available') else Println('Unavailable');
  If CNF^.MultiNode Then
  begin
    For i:=1 to MaxNodes do
    Begin
      {GetNodeStats(I,H,A,Av);}
      If I=CNF^.NodeNumber Then Tab(Strr(i),6) Else Tab(Strr(i),6);
      Tab(H,27); Tab(A,25);
      If AV Then Println('Available') else Println('Unavailable');
    End;
  End;
End;

Procedure SwitchUser;
Var TmpUNum:Word;
Begin
  TmpUNum:=UNum;
  Input:=Prompt(25,'User to switch to: ',False);
  If (Valu(Input)<>0) Then
  Begin
    UNum:=Valu(Input);
    OpenUFiles(CurUFile);
    If (UNum>=0) And (UNum<=NumUsers) Then
    Begin
      SeekUFile(UNum);
      UNum:=ReadUser(URec^);
      If (Not GetPassword(URec^.Password[1])) Then
      Begin
        SeekUFile(TmpUNum);
        UNum:=ReadUser(URec^);
      End;
    End else UNum:=TmpUNum;
    CloseUFiles;
  End
 Else
  If (Length(Input)>0) Then
  Begin
    OpenUFiles(CurUFile);
    FindUser(Input,UNum);
    If (UNum>0) Then
    Begin
      SeekUFile(UNum-1);
      UNum:=ReadUser(URec^);
      If (Not GetPassword(URec^.Password[1])) Then
      Begin
        SeekUFile(TmpUNum);
        UNum:=ReadUser(URec^);
      End;
    End Else UNum:=TmpUNum;
    CloseUFiles;
  End;

End;

Begin
End.
