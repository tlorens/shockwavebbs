{
  iB * 08/08/95 - Added EditUsers procedure, implemented User Editor
  iB * 08/14/95 - Added/Implemented Conference Editor.
  IB * 04/11/96 - Added-Blacklist, MakeUser, FeedBack, and SysLog routines.
}
Unit Sysop;

Interface

Procedure AddToBlackList(S:String);
Procedure RemoveFromBlacklist;
Procedure ViewBlacklist;
Procedure EditUser(EUnum:Integer);
Procedure EditUsers(U:String);
Procedure MakeUser;
Procedure ReadSysLog;
Procedure DeleteSysLog;
Procedure ReadFeedBack;

Implementation

Uses OpCrt,DOS,IO,Vars,Gensubs,Display,CNFgRec,User,Records,Misc,MSub1;

Var UProfile :^ProfileRec;
    FProFile :File Of ProFileRec;

Procedure AddToBlackList(S:String);
Var BL:BlackListRec;
   BLF:File Of BlacklistRec;

  Function FindFreeRec:Integer;
  Var Tmp:BlackListRec;
  Begin
    ReSet(BLF);
    While (Not EOF(BLF)) Do
    Begin
      Read(BLF,Tmp);
      If ((Length(Tmp.Handle)=0) and (FilePos(BLF)-1<>0)) Then
      Begin
        FindFreerec:=FilePos(BLF)-1;
        Exit;
      End;
    End;
    FindFreerec:=FilePos(BLF);
  End;

Begin
  Assign(BLF,'BLACKLST.DAT');
  If Exist('BLACKLST.DAT') Then
  Begin
    ReSet(BLF);
    Seek(BLF,FindFreeRec);
  End Else ReWrite(BLF);
  With BL Do
  Begin
    ByWho:=Urec^.Handle;
    If Length(S)=0 Then Handle:=Prompt(25,'Handle: ',False) Else Handle:=S;
    When:=Now;
    HowLong:=Valu(Prompt(3,'How Long (Days): ',False));
  End;
  If Length(BL.Handle)>0 Then Write(BLF,BL);
  Close(BLF);
End;

Procedure RemoveFromBlackList;
Var BL:BlackListRec;
   BLF:File Of BlacklistRec;
   Place:Integer;
Begin
  Input:=Prompt(25,'User to remove: ',False);
  If Exist('BLACKLST.DAT') Then
  Begin
    Assign(BLF,'BLACKLST.DAT');
    ReSet(BLF);
    While (Not EOF(BLF)) Do
    Begin
      Read(BLF,BL);
      Place:=FilePos(BLF)-1;
      If Match(BL.Handle,Input) Then
      Begin
        FillChar(BL,SizeOf(BL),#0);
        Seek(BLF,Place);
        Write(BLF,BL);
      End;
    End;
  End;
End;

Procedure ViewBlackList;
Var BL:BlackListRec;
   BLF:File Of BlacklistRec; 
Begin
  If Not Exist('BLACKLST.DAT') Then Exit;
  Assign(BLF,'BLACKLST.DAT');
  ReSet(BLF);
  While (Not EOF(BLF)) Do
  Begin
    Read(BLF,BL);
    If Length(BL.Handle)>0 Then
    With BL Do PrintLn(Handle+' Blacklisted by '+ByWho+' on '+DateStr(When)+' For '+Strr(HowLong)+' Days');
  End;
  Close(BLF);
End;

Procedure EditUsers(U:String);
Var Eunum:Integer;

  Procedure EListUsers;
  Var Num,cnt,f,l:Integer;
      u:userrec;

    Procedure listuser;
    Begin
      MCiWrite('|01'); Tab(Strr(cnt),4);
      MCiWrite('|09'); Tab(u.handle,25);
      MCiWrite('|03'); Tab(Strr(u.lvl),7);
      MCiWrite('|13'); Tab(datestr(u.lastCall),9);
      MCiWrite('|15'); Tab(Strr(u.Posts),6);
      MCiWrite('|11'); Tab(Strr(u.NumCalls),6);
      MCiWrite('|03');
      If Datestr(u.expdate)='0/0/80' Then Println('N/A') Else Println(datestr(u.expdate));
    End;

    Begin
      f:=1;
      l:=numusers;
      Range(f,l);
      SeekUFile(f);
      MCiWriteln('|01Num |09Name                     |03Level  |13Last on  |15Posts |11Calls |03Exp Date');
      Num:=0;
      for Cnt:=F to L do
      Begin
        ReadUser(u);
        Inc(Num);
        If Num>21 Then
        Begin
          Num:=0;
          If Not YeaNa('More',True) Then Exit;
          MCiWriteln('|01Num |09Name                     |03Level  |13Last on  |15Posts |11Calls |03Exp Date');
        End;
        ListUser;
      End;
  End;

  Procedure GlobalNew;
  Var Cnt,F:Integer;
      U:userrec;

  Begin
    SeekUFile(1);
    Cnt:=0;
    For F:=1 To NumUsers Do
    Begin
      ReadUser(U);
      If (U.Lvl < CNF^.SecCallLvl) And (u.handle<>'') Then
      Begin
        cnt:=cnt+1;
        If YeaNa('|03Edit |11'+u.handle+'|07:',False) Then 
        Begin
          EditUser(F+1);
          SeekUFile(F+1);
          Println('Continuing with the scan...');
        End;
      End;
   End;
   MCiPrintln('|03End of user list! |11'+Strr(cnt)+' |03Match(s) found!');
  End;

  Procedure FindWildCard(Wild:String);
  Var Cnt,F:Integer;
      U:userrec;
      Tmp:String;
  Begin
    Wild:=Copy(Wild,1,Length(Wild)-1);
    SeekUFile(1);
    Cnt:=0;
    For F:=1 To NumUsers Do
    Begin
      ReadUser(U);
      If (Length(Wild) < Length(U.Handle)) Then Tmp:=Copy(U.Handle,1,Length(Wild)) Else
      Tmp:=U.Handle;

      If Match(Wild,Tmp) Then
      If YeaNa('|03Edit |11'+u.handle+'|07:',False) Then 
      Begin
        EditUser(F+1);
        SeekUFile(F+1);
        Println('Continuing with the scan...');
      End;
    End;
  End;

Begin
  Cls;
  OpenUFiles(U);
  Repeat
    Input:=Prompt(25,'|03Edit User |08(|11N|09/|11New Users |08- |11?|09/|11List|08)|07:  ',False);
    If match(input,'N') Then Globalnew
   Else
    If match(input,'?') Then EListUsers
   Else
    If Valu(Input)>0 Then EditUser(Valu(Input)+1) 
   Else
    If Length(Input)>1 Then
    Begin
      If Pos('*',Input[Length(Input)])>0 Then FindWildCard(Input);
      FindUser(Input,EuNum);
      If EuNum=-1 Then MCIWriteln('|12User not found!|07') Else EditUser(EuNum);
    End;
  Until (Upcase(Input[1])='Q') or (Length(Input)=0);
  CloseUFiles;
End;


Procedure EditUser(EUnum:Integer);
Var Eurec:userrec;
    Updated:Boolean;

(*  Procedure SeekNextUser;
  Begin
    WriteUFile(Eurec,Eunum);
    If (FilePos(Ufile)) < FileSize(Ufile) then
    Begin
      ClearFields;
      Repeat
        Read(ufile,eurec);
      Until (Length(Eurec.Handle)>0) or Eof(Ufile);
      If (Length(Eurec.Handle)=0) Or (EOF(Ufile)) Then Exit;
      writelog (2,3,eurec.handle);
      EuNum:=FilePos(UFile)-1;
    End;
    WriteStats;
  End;

  Procedure SeekPrevUser;
  Begin
    WriteUFile(Eurec,Eunum);
    If FilePos(Ufile)-2 > 0 Then
    Begin
      ClearFields;
      Repeat
        Seek(Ufile,FilePos(Ufile)-2);
        Read(ufile,eurec);
      Until (Length(Eurec.Handle)>0) or (Filepos(Ufile)=1);
      If Length(Eurec.Handle)=0 Then Exit;
      writelog (2,3,eurec.handle);
      EuNum:=FilePos(UFile)-1;
      WriteStats;
    End;
  End;
  *)

(*  Procedure EuWanted;
  Begin
    Println('Wanted status: '^S+YesNo(wanted in Eurec.Sysop));
    If YeaNa('Is User "WANTED"',False) Then Eurec.SysOp:=Eurec.SysOp+[wanted]
      Else Eurec.SysOp:=Eurec.SysOp-[wanted];
    {Writelog(18,1,yesno(wanted in Eurec.SysOp))}
  End;*)

  Procedure EuDel;
  Begin
    GoXy(51,12);
    If YeaNa('Delete user:',False) Then
    Begin
      GoXy(51,13);
      If YeaNa('Add to Blacklist',False) Then AddToBlackList(Eurec.Handle);        
      Deleteuser(EUnum);
      Cls;
    End
  End;

  Procedure EUname;
  Var m:Str25;
  Begin
    m:=Eurec.handle;
    m:=Prompt(25,'name',False);
    If not match (m,Eurec.handle) Then FindUser(m,EUnum);
    If Eunum<>0 Then If Not YeaNa('Already exists!  Are you sure',False) Then Exit;
    Eurec.handle:=m;
  End;

  Procedure EuPassword;
  Begin
    If not IsSysOp Then Exit Else Eurec.password[1]:=Prompt(25,'password',False);
  End;

  Procedure EuLevel;
  Var n:Integer;
  Begin
    n:=Eurec.lvl;
    N:=Valu(Prompt(5,'level',False));
    If (n>=CNF^.SysOpLvl) and (not IsSysop) Then Exit
   Else
    Begin
      Eurec.lvl:=n;
     {writelog (18,15,strr(n))}
    End
  End;

  Procedure EuPhone;
  Var m:Str25;
      p:Integer;
  Begin
    m:=Eurec.phone[1];
    M:=Prompt(12,'phone number',False);
    p:=1;
    While p<=length(m) do If (m[p] in ['0'..'9']) Then p:=p+1 Else delete(m,p,1);
    If length(m)>7 Then Eurec.phone[1]:=m;
  End;

  Procedure ClearFields;
  Begin
    Backspace(22,2,Length(Eurec.Handle));
    Backspace(22,3,Length(Eurec.Realname));
    Backspace(22,4,Length(Eurec.Password[1]));
    Backspace(22,5,Length(Eurec.Phone[1]));
    Backspace(22,6,Length(Eurec.UserNote));
    Backspace(22,7,Length(Eurec.SysOpNote));
    Backspace(22,8,Length(Strr(Eurec.Lvl)));
    Backspace(22,9,Length(Strr(Eurec.TimeLeft)));
    Backspace(22,10,Length(Strr(Eurec.TimeLimit)));
    Backspace(22,11,Length(Strr(Eurec.TimeBank)));
    Backspace(22,12,Length(Strr(Eurec.Posts)));
    Backspace(22,13,Length(Strr(Eurec.NumCalls)));
    Backspace(22,14,Length(Strr(Eurec.PCR))+1);
    Backspace(22,15,Length(DateStr(Eurec.ExpDate)));
    Backspace(22,16,Length(Eurec.Age)+Length(' ('+Strr(UAge(Eurec.Age))+')'));
    Backspace(72,2,Length(Strr(Eurec.XLvl)));
    Backspace(72,3,Length(Strr(Eurec.FilePts)));
    Backspace(72,4,Length(Strr(Eurec.Uploads)));
    Backspace(72,5,Length(Strr(Eurec.UpK)));
    Backspace(72,6,Length(Strr(Eurec.Downloads)));
    Backspace(72,7,Length(Strr(Eurec.DownK)));
    Backspace(72,8,Length(Strr(Eurec.Up_Down_Ratio))+1);
    Backspace(72,9,Length(Strr(Eurec.Up_Down_K_Ratio))+1);
  End;

  Procedure WriteStats;
  Begin
    AColor(Urec^.StatColor);
    AColor(9);
    PrintXy(22,2,Eurec.Handle);
    PrintXY(22,3,Eurec.RealName);
    PrintXY(22,4,Eurec.Password[1]);
    PrintXy(22,5,Eurec.Phone[1]);
    PrintXy(22,6,Eurec.UserNote);
    PrintXy(22,7,Eurec.SysOpNote);
    PrintXY(22,8,Strr(Eurec.Lvl));
    PrintXy(22,9,Strr(Eurec.TimeLeft));
    PrintXy(22,10,Strr(Eurec.Timelimit));
    Printxy(22,11,Strr(Eurec.TimeBank));
    PrintXy(22,12,Strr(Eurec.Posts));
    PrintXy(22,13,Strr(Eurec.NumCalls));
    PrintXy(22,14,Strr(Eurec.PCR)+'% ');
    PrintXy(22,15,DateStr(Eurec.ExpDate));
    PrintXy(22,16,Eurec.Age+' ('+Strr(UAge(Eurec.Age))+')');
    PrintXy(22,17,Eurec.Gender);
    PrintXy(72,2,Strr(Eurec.XLvl));
    PrintXy(72,3,Strr(Eurec.FilePts));
    PrintXy(72,4,Strr(Eurec.Uploads));
    PrintXy(72,5,Strr(Eurec.UpK));
    PrintXy(72,6,Strr(Eurec.Downloads));
    PrintXy(72,7,Strr(Eurec.DownK));
    PrintXy(72,8,Strr(Eurec.Up_Down_Ratio)+'% ');
    PrintXy(72,9,Strr(Eurec.Up_Down_K_Ratio)+'% ');
  End;

Procedure EditScreen;
Begin
  Cls;
  MCiPrintln('|BXีออออออออออออออออออัอออออออออออออออออออออออออออธีออออออออออออออออออออัออออออออธ');
MCiPrintln('|BXณ |MS[|INH|MS] |ISHandle       |BXณ                           ณณ |MS[|INF|MS] |ISFile Level     |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INR|MS] |ISReal Name    |BXณ                           ณณ |MS[|INX|MS] |ISFile Points    |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INW|MS] |ISPassword     |BXณ                           ณณ |MS[|IN+|MS] |ISUploads        |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INP|MS] |ISPhone #      |BXณ                           ณณ |MS[|IN>|MS] |ISUp K           |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INN|MS] |ISUser Note    |BXณ                           ณณ |MS[|IN-|MS] |ISDownloads      |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INS|MS] |ISSysOp Note   |BXณ                           ณณ |MS[|IN<|MS] |ISDown K         |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INM|MS] |ISMain Level   |BXณ                           ณณ |MS[|IN$|MS] |ISUp/Down Ratio  |BXณ        ณ');
MCiPrintln('|BXณ |MS[|INT|MS] |ISTime Left    |BXณ                           ณณ |MS[|IN^|MS] |ISKiloByte Ratio |BXณ        ณ');
  MCiPrintln('|BXณ |MS[|INZ|MS] |ISTime Limit   |BXณ                           ณิออออออออออออออออออออฯออออออออพ');
  MCiPrintln('|BXณ |MS[|INB|MS] |ISTime Bank    |BXณ                           ณีอออออออออออออออออออออออออออออธ');
  MCiPrintln('|BXณ |MS[|IN#|MS] |ISPosts        |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXณ |MS[|INL|MS] |IS# Logins     |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXณ |MS[|IN%|MS] |ISPCR          |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXณ |MS[|INE|MS] |ISExp Date     |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXณ |MS[|IN/|MS] |ISBirth Date   |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXณ |MS[|IN\|MS] |ISGender       |BXณ                           ณณ                             ณ');
  MCiPrintln('|BXิออออออออออออออออออฯอออออออออออออออออออออออออออพณ                             ณ');
  MCiPrintln('|BXีออออออออออออออออออออออออออออออออออออออออออออออธณ                             ณ');
  MCiPrintln('|BXณ |MS[|IN=|MS]|IS Set Profile  |MS[|INA|MS]|ISccess      |MS[|INI|MS]|ISnterviews  |BXณณ'
  +'                             ณ');
  MCiPrintln('|BXณ |MS[|IN?|MS]|IS Find User    |MS[|IN*|MS]|ISMsg Access |MS[|IND|MS]|ISelete      |BXณณ'
  +'                             ณ');
  MCiPrintln('|BXณ |MS[|IN!|MS]|IS Flags        |MS[|IN.|MS]|IS Global    |MS[|INQ|MS]|ISuit        |BXณณ'
  +'                             ณ');
  MCiPrintln('|BXิออออออออออออออออออออออออออออออออออออออออออออออพิอออออออออออออออออออออออออออออพ');
  WriteStats;
End;

Procedure Choose;
Var gg:Char;
    tmp,cpu:Integer;
    imdone:boolean;

  Procedure AutoValidate;
  Begin
    AColor(Urec^.StatColor);
    Printxy(3,72,Strr(Eurec.FilePts));
    PrintXy(6,22,EUrec.Usernote);
    PrintXy(8,22,Strr(EUrec.Lvl));
    PrintXy(2,72,Strr(EUrec.Xlvl));
    PrintXy(10,22,Strr(CNF^.UserTime[Eurec.Lvl]));
  End;

  Procedure Voting;
  Var Tim:Integer;
  Begin
{   Clearscr;
    For Tim:=1 To Maxtopics Do
    Begin
      If Tim<>1 Then Print(',');
      Print(Eurec.voted[Tim]);
    End;}
  End;

  Procedure ClearWindow;
  Var Mk:Byte;
  Begin
    For Mk:=12 to 22 Do BackSpace(51,Mk,28);
  End;

  Procedure ListProfiles;
  Var Line:Byte;
  Begin
    ClearWindow;
    Assign(FProFile,CNF^.DataDir+'PROFILES.DAT');
    ReSet(FProFile);
    New(UProFile);
    Line:=12;
    While (Not EOF(FProFile)) Do
    Begin
      Read(FProFile,UProFile^);
      PrintXY(51,Line,Strr(FilePos(FProFile)-1)+': '+UProFile^.Name);
      Inc(Line);
      If (Line=20) or EOF(FProFile) Then
      Begin
        PrintXY(51,Line+2,'');
        HitKey;
        ClearWindow;
        Line:=12;
      End;
    End;
    Close(FProFile);
    Dispose(UProFile);
  End;

  Procedure GetProfiles;
  Var Setit:Boolean;
  Begin
    Setit:=False;
    Repeat
      GoXy(51,12);
      Input:=Prompt(1,'Profile #: (?/List):',Urec^.MenuType=1);
      If Input=''  Then
      Begin
        ClearWindow;
        Exit;
      End;
      If Length(Input)>0 Then
      If Input='?' Then
      Begin
        SetIt:=False;
        ListProfiles;
      End
     Else
      Begin
        Setit:=True;
        SetUserProfile(EuRec,Valu(Input));
        ClearFields;
        ClearWindow;
        WriteStats;
      End;
   Until Setit;
  End;


  Procedure SetFlags;

    Procedure ParseFlag(Ch:Char; Var St:Str25);
    Var K,I,J,Gap:Byte;

      Procedure Switch(Var A,b:Char);
      Var C:Char;
      Begin
        C:=A;
        A:=B;
        B:=C;
      End;

    Begin
      If Pos(Ch,St)<>0 Then Delete(St,Pos(Ch,St),1) Else St:=St+Ch;
      Gap:=Length(St) Div 2;
      While(Gap>0) do
      Begin
        For I:=(Gap+1) To Length(St) Do
        Begin
          J:=i-Gap;
          While(J>0) Do
          Begin
            K:=J+Gap;
            If (ST[J]<=ST[k]) Then J:=0 Else
            Begin
              Switch(ST[J],ST[K]);
              J:=J-Gap;
            End;
          End;
        End;
        Gap:=Gap Div 2;
      End;
    End;

  Var Z:Char;
  Begin
    PrintXy(51,12,'      - Access Flags - ');
    PrintXY(51,14,+Eurec.AccessFlags);
    PrintXy(51,22,'[Z] Exit [+] All [-] None');
    Repeat
      Z:=' ';
      Repeat
        Repeat
          If HungUpOn Then Exit;
        Until CharPressed Or hungupon;
        Getchar(Z);
        If Length(Z)=0 Then Z:=' ';
        Z:=UpCase(Z);
      Until (Pos(Z,'ABCDEFGHIJKLMNOPQRSTUVWXYZ+-')>0) or hungupon;
    Case Z Of
      'A':ParseFlag('A',Eurec.AccessFlags);
      'B':ParseFlag('B',Eurec.AccessFlags);
      'C':ParseFlag('C',Eurec.AccessFlags);
      'D':ParseFlag('D',Eurec.AccessFlags);
      'E':ParseFlag('E',Eurec.AccessFlags);
      'F':ParseFlag('F',Eurec.AccessFlags);
      'G':ParseFlag('G',Eurec.AccessFlags);
      'H':ParseFlag('H',Eurec.AccessFlags);
      'I':ParseFlag('I',Eurec.AccessFlags);
      'J':ParseFlag('J',Eurec.AccessFlags);
      'K':ParseFlag('K',Eurec.AccessFlags);
      'L':ParseFlag('L',Eurec.AccessFlags);
      'M':ParseFlag('M',Eurec.AccessFlags);
      'N':ParseFlag('N',Eurec.AccessFlags);
      'O':ParseFlag('O',Eurec.AccessFlags);
      'P':ParseFlag('P',Eurec.AccessFlags);
      'Q':ParseFlag('Q',Eurec.AccessFlags);
      'R':ParseFlag('R',Eurec.AccessFlags);
      'S':ParseFlag('S',Eurec.AccessFlags);
      'T':ParseFlag('T',Eurec.AccessFlags);
      'U':ParseFlag('U',Eurec.AccessFlags);
      'V':ParseFlag('V',Eurec.AccessFlags);
      'W':ParseFlag('W',Eurec.AccessFlags);
      'X':ParseFlag('X',Eurec.AccessFlags);
      'Y':ParseFlag('Y',Eurec.AccessFlags);
      '+':Eurec.AccessFlags:='ABCDEFGHIJKLMNOPQRSTUVWXY';
      '-':Begin
            Eurec.AccessFlags:='';
            BackSpace(51,14,25);
          End;
    End;
    BackSpace(51,14,Length(Eurec.AccessFlags)+1);
    PrintXY(51,14,+Eurec.AccessFlags);
    Until (Z='Z') or HungupOn;
    ClearWindow;
  End;

(*  Procedure ViewInterView;
  Var Z:Char;
  Begin
    Repeat
    PrintXy(12,51,'      - View Interview - ');
    PrintXY(14,51,'     Interview [1]:  ['+DotYesNo(Eurec.InfoForm1>-1)+']');
    PrintXY(15,51,'     Interview [2]:  ['+DotYesNo(Eurec.InfoForm2>-1)+']');
    PrintXY(16,51,'     Interview [3]:  ['+DotYesNo(Eurec.InfoForm3>-1)+']');
    PrintXY(17,51,'     Interview [4]:  ['+DotYesNo(Eurec.InfoForm4>-1)+']');
    PrintXY(18,51,'     Interview [5]:  ['+DotYesNo(Eurec.InfoForm5>-1)+']');
    PrintXy(22,51,'[E]xit');
    Z:=' ';
     Repeat
      Repeat
        If hungupon Then exit;
      Until CharPressed Or hungupon;
      Getchar(Z);
      If Length(Z)=0 Then Z:=' ';
      Z:=UpCase(Z);
    Until (Pos(Z,'12345E')>0) or hungupon;
    Case Z of
        '1':Tmp:=1;
        '2':Tmp:=2;
        '3':Tmp:=3;
        '4':Tmp:=4;
        '5':Tmp:=5;
        'E':Begin tmp:=0; ClearWindow; Exit; End;
      End;
      {Showinfoforms(strr(EUnum),tmp);}
      {HitKey(MyStr.HitAKey);}
      EditScreen;
    Until (Z='E') or HungupOn;
    ClearWindow;
  End;
  *)

  Procedure GetString(X,Y:Byte; Var S:Str25);
  Begin
    Input:=S;
    Edit(Input,X,Y,25,False);
  End;

  Procedure GetNum(X,Y:Byte; Var S:Integer);
  Begin
    Input:=Strr(S);
    Edit(Input,X,Y,5,False);
    S:=Valu(Input);
  End;

  Procedure GetLongInt(X,Y:Byte; Var S:LongInt);
  Begin
    Input:=Strr(S);
    Edit(Input,X,Y,5,False);
    S:=Valu(Input);
  End;

  Procedure GetAge;
  Begin
    Edit(EUrec.Age,22,16,8,False);
    Print(' ('+Strr(UAge(Eurec.Age))+')   ');
  End;

  Procedure GetExpDate;
  Begin
    Backspace(22,15,Length(DateStr(Eurec.ExpDate)));
    Input:=Prompt(25,'',False);
    If Length(Input)>0 Then Eurec.ExpDate:=DateVal(Input);
    Backspace(22,15,Length(DateStr(Eurec.ExpDate)));
    Print(DateStr(Eurec.Expdate));
  End;

  Procedure GetGender;
  Begin
    Input:=Eurec.Gender;
    Edit(Input,22,17,1,False);
    If (Upcase(Input[1])='M') or (Upcase(Input[1])='F') Then Eurec.Gender:=Upcase(Input[1]);
  End;

  Procedure GlobalSet;
  Var Item:Char;
      Value:String;
      Cnt:Integer;
      TotalUsers:Word;
      U:userrec;
  Begin
    Item:=#0;
    Value:=#0;
    PrintXy(51,12,'      - Global Commands - ');
    PrintXY(51,14,'Valid Items:');
    PrintXY(51,15,'  N,M,Z,B,%,E,F,X,$,^,!,=');
    PrintXY(51,16,'Item to change: '); Input:=Prompt(1,'',Urec^.MenuType=1);
    If Length(Input)<1 Then
    Begin
      ClearWindow;
      Exit;
    End;
    Item:=Upcase(Input[1]);
    If Item<>'=' Then
    Begin
      PrintXY(51,17,'Value Of Item: ');
      GoXY(51,18); 
      Input:='';
      EditPrompt(25,Input);

      If Length(input)<1 Then
      Begin
        ClearWindow;
        Exit;
      End;
      Value:=Input;
    End;
    ClearWindow;
    TotalUsers:=NumUsers;
    OpenUFiles(CurUFile);
    If (Length(Value)=0) or (Length(Item)=0) Then Exit;
    Case Item Of
      'N':Begin
            For Cnt:=2 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.Usernote:=Value;
              SeekUfile(cnt);
              WriteUser(U);
            End
          End;
      '!':Begin
            For Cnt:=1 To Length(Value) Do Value[Cnt]:=Upcase(Value[Cnt]);
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.AccessFlags:=Value;
              SeekUFile(cnt);
              WriteUser(U);
            End
          End;
      'M':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.Lvl:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      'Z':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.TimeLimit:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      'B':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.TimeBank:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      '%':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.PCR:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      'E':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.ExpDate:=DateVal(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      'F':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.XLvl:=valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      'X':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.FilePts:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      '$':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.Up_Down_Ratio:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      '^':Begin
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              U.Up_Down_K_Ratio:=Valu(Value);
              SeekUFile(cnt);
              WriteUser(u)
            End
          End;
      '=':Begin
            GoXY(51,12);
            Input:=Prompt(2,'Profile #: ',Urec^.MenuType=1);
            If Input='' Then
            Begin
              ClearWindow;
              Exit;
            End;
            If (Length(Input)>0) and (Valu(Input)<=FileSize(FProFile)) Then
            For Cnt:=1 to TotalUsers Do
            Begin
              SeekUFile(cnt);
              ReadUser(U);
              SetUserProfile(U,Valu(Input));
              {SeekUFile(cnt);
              WriteUser(u)}
            End
           Else
            Begin
              ClearWindow;
              Exit;
            End;
          End;
    End;
    PrintXy(22,62,'Done!');
    CloseUfiles;  
    Delay(1000);
    ClearWindow;
  End;

Begin
  ImDone:=False;
  Updated:=False;
  EditScreen;
  Repeat
    GG:=' ';
    Repeat
      Repeat Until (CharPressed) Or (HungUpOn);
      GetChar(GG);
      If Length(GG)=0 Then GG:=' ';
      GG:=UpCase(GG);
      If GG<>'Q' Then Updated:=True;
    Until (Pos(GG,'HRWPNSMTZB#L%EFX+>-<$^QD=AI!/\.[]')>0) Or (HungUpOn);
    Case GG of
      'H': GetString(22,2,Eurec.Handle);
      'R': GetString(22,3,Eurec.RealName);
      'W': GetString(22,4,Eurec.Password[1]);
      'P': GetString(22,5,Eurec.Phone[1]);
      'N': GetString(22,6,Eurec.UserNote);
      'S': GetString(22,7,Eurec.SysOpNote);
      'M': If (Urec^.Lvl>Eurec.Lvl) or (IsSysOp) Then GetNum(22,8,Eurec.Lvl);
      'T': GetNum(22,9,Eurec.TimeLeft);
      'Z': GetNum(22,10,Eurec.TimeLimit);
      'B': GetNum(22,11,Eurec.TimeBank);
      '#': GetNum(22,12,Eurec.Posts);
      'L': GetNum(22,13,Eurec.NumCalls);
      '%': GetNum(22,14,Eurec.PCR);
      'E': GetExpDate;
      'F': If (Urec^.Lvl>Eurec.Lvl) or (IsSysOp) Then GetNum(72,2,Eurec.XLvl);
{      'X': GetNum(72,3,Eurec.FilePts);}
      '+': GetNum(72,4,Eurec.Uploads);
      '>': GetLongInt(72,5,Eurec.UpK);
      '-': GetNum(72,6,Eurec.Downloads);
      '<': GetLongInt(72,7,Eurec.DownK);
      '$': GetNum(72,8,Eurec.Up_Down_Ratio);
      '^': GetNum(72,9,Eurec.Up_Down_K_Ratio);
      'D': Begin EuDel; Exit; End;
{      'A': If (IsSysOp) Then SetAccess;}
{      'I': ViewInterview;}
      '!': SetFlags;
      '/': GetAge;
      '\': GetGender;
      '.': GlobalSet; 
{      ']': SeekNextUser;
       '[': SeekPrevUser;}
      '=': GetProFiles;
      Else
      If GG='Q' Then ImDone:=True Else ImDone:=False;
    End;
  Until Imdone;
  If Updated Then 
  Begin
    PrintXy(55,12,' - User Editor - ');
    PrintXY(51,14,'');
    If YeaNa('Save Changes: ',False) Then
    Begin
      If Match(Eurec.Handle,Urec^.Handle) Then Move(Eurec,Urec^,SizeOf(Eurec));
      WriteUfile(Eurec,EUnum);
    End;
  End;
  Cls;
End;

Begin
  SeekUFile(EuNum-1);
  EUNum:=ReadUser(Eurec);
  Choose;
End;

Procedure MakeUser;
Var Eurec:userrec;
Begin
  OpenUFiles(CurUFile);
  WriteHdr('Create New User');
  Input:=Prompt(25,'Users Handle: ',False);
  If ValidUserName(Input) then
  Begin
    If DupHandle(Input) then
    Begin
      MCiWriteLn(MyStr^.DupHandle);
      Delay(2000);
    End
   Else
    Begin
      { Create Users: Defaults }
      With EUrec Do
      Begin
        If YeaNa(Input+', is this correct: ',True) then
        Handle:=Input else Handle:=Prompt(25,MyStr^.NewHandle,False);
        Password[1]:=Prompt(25,MyStr^.NewPassword,False);
        RealName:=Prompt(25,MyStr^.GetRealName,False);
        Age:=Prompt(8,MyStr^.BirthDate,False);
        Input:=(Copy(Prompt(1,'Gender (M/F): ',Urec^.MenuType=1),1,1));
        Gender:=Input[1];
        Phone[1]:=Prompt(13,MyStr^.GetPhone,False);
        ScrnLength:=Valu(Prompt(2,MyStr^.ScrLen,False));
        UserNote:=Prompt(25,'User Note: ',False);
        MsgHeader:=1;
        TimeLeft:=10;
        {MenuType}
        {Expert}
        Lvl:=0;
        XLvl:=0;
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
     WriteLog(6,1,EUrec.Handle+' Created');
     Println('Don''t forget to validate '+Eurec.Handle);
     Delay(2000);
     AddUser(EUrec);
    End;
  End;
  CloseUFiles;
 { EditUser(EUnum:Integer);}
End;

Procedure ReadSysLog;
Var  T:Text;
  Line:String;
   Cnt:Byte;
    Go:Boolean;
  Today:Str10;
  YY,DD,MM,DOW:Word;
Begin
  GetDate(YY,MM,DD,DOW);
  Today:=Strr(YY)+PadRight(Strr(MM),2,'0')+Strr(DD);

  If (Exist(CNF^.SysLogDir+Today+'.LOG')) Then
  Begin
    Assign(T,CNF^.SysLogDir+Today+'.LOG');
    ReSet(T);
    Cnt:=0;
    Go:=True;
    AColor(7);
    While (Not EOF(T)) And (Go) Do
    Begin
      Inc(Cnt);
      Readln(T,Line);
      MCIWriteln(Line);
      If Cnt=21 Then
      Begin
        AColor(7);
        Go:=YeaNa('More: ',True);
        Cnt:=0;
      End;
    End;
    Close(T);
  End;
End;

Procedure DeleteSysLog;
Var T:Text;
  Today:Str10;
  YY,DD,MM,DOW:Word;
Begin
  GetDate(YY,MM,DD,DOW);
  Today:=Strr(YY)+PadRight(Strr(MM),2,'0')+Strr(DD);

  If Exist(CNF^.SysLogDIr+Today+'.LOG') Then
  Begin
    If YeaNa('Delete Syslog: ',False) Then
    Begin
      Assign(T,CNF^.SysLogDIr+Today+'.LOG');
      Erase(T);
    End;
  End;
End;

Procedure ReadErrorLog;
Begin
End;

Procedure DeleteErrorLog;
Begin
End;

Procedure ReadFeedBack;

  Procedure DeleteFeedBack(X:LongInt);
  Begin
    If YeaNa(MyStr^.MsgDelPrompt,False) Then
    Begin
      MHdr.Deleted:=True;
      DelMsg(3,MHdr,Msg,CurConf,CurMsgAreaName,X);
      PrintLn('Message Deleted');
    End;
  End;

  Procedure ReplyFeedBack(ID:LongInt);
  Begin
    WriteHdr('Reply To Feedback');
    QMsg:=Msg;
    QHdr:=MHdr;

    With MHdr Do
    Begin
      SendTo:=From;
      MCIWriteln(MyStr^.PostToPrompt+SendTo);
      If Pos('Re:',Title)<>1 Then Title:='Re: '+Title;
      MCIWriteln(MyStr^.TitlePrompt+Title);
      Anon:=False;
      MsgType:=1;
      MCIWrite('Reply As |08(|03CR|01/|11'+From+'|08)|RE: ');
      Edit(From,WhereX,WhereY,25,False);
      Println('');
      RealName:=Urec^.RealName;
      NumRead:=0;
      NumReply:=0;
      Deleted:=False;
      Back:=ID;
    End;
    If PostMsg(1,False) Then UpDateMsg(3,MHdr,CurConf,CurMsgAreaName,ID,False,True);
  End;

  Function GotoMessage:LongInt;
  Var X,St,Tot,Tot2:Integer;
  Begin
    Tot:=NumMsgs(0,CurConf,CurmsgAreaName,False);
    If Tot=0 then 
    Begin
      Println('No Messages!');
      Exit;
    End;
    Tot2:=Tot;
    St:=1;
    Range(St,Tot2); Dec(St); Dec(Tot2);
    If Tot2>Tot Then exit;
    GotoMessage:=St;
  End;

  Function MsgMenuBar(Title:String):Char;
  Var UCh:Char;
  Begin
    New(MenuBarz);
    With MenuBarz^ Do
    Begin
      MenuName:=Title+' - (?/Help)';
      Choice[1]:=' Next ';   HighChr[1]:=1;
      Choice[2]:=' Reply ';  HighChr[2]:=1;
      Choice[3]:=' Again ';  HighChr[3]:=1;
      Choice[4]:=' Back ';   HighChr[4]:=1;
      Choice[5]:=' Delete '; HighChr[5]:=1;
      Choice[6]:=' Goto ';   HighChr[6]:=1;
      Choice[7]:=' Other ';  HighChr[7]:=1;
      Choice[8]:=' Quit ';   HighChr[8]:=1;
      NumChoices:=8;
      KeyCmds:='NRABGOQ?';
      DefChoice:=1;
     End;
     MsgMenuBar:=BarMenu(MenuBarz^);
     Dispose(Menubarz);
  End;

  Function OtherMenuBar(Title:String):Char;
  Var UCh:Char;
  Begin
    New(MenuBarz);
    With MenuBarz^ Do
    Begin
      MenuName:=Title+' - (?/Help)';
      Choice[1]:=' Edit User';   HighChr[1]:=1;
      Choice[2]:=' Forward ';    HighChr[2]:=1;
      Choice[3]:=' Download ';   HighChr[3]:=1;
      Choice[4]:=' Quit ';       HighChr[4]:=1;
      NumChoices:=4;
      KeyCmds:='EFDQ?';
      DefChoice:=1;
    End;
    OtherMenuBar:=BarMenu(MenuBarz^);
    Dispose(Menubarz);
  End;

Var St,Tot,Tot2:Integer;
    UCnt,X:LongInt;
    Quit,Next:Boolean;
Begin
  WriteHdr('Read Feedback');
  Tot:=NumMsgs(3,CurConf,'Feedback',False);
  Tot2:=NumMsgs(3,CurConf,'Feedback',True);
  If Tot=0 then Println('No Messages!') Else
  Begin
    St:=1;
    Range(St,Tot); Dec(St); Dec(Tot);
    UCnt:=St;
    For X:=St To Tot Do 
    Begin
      Inc(UCnt);
      Next:=False;
      Repeat
        ReadMsg(3,CurConf,'Feedback',X,UCnt,Tot2,False);
        Case MsgMenuBar('Read Feedback') Of
          'Q':Exit;
          'N':Next:=True;
          'G':X:=GotoMessage;
          'R':ReplyFeedBack(X);
          'D':DeleteFeedBack(X);
          'A':;
          'O':Begin  
                Repeat
                  Case OtherMenuBar('+Read Feedback') Of
                    'Q':Quit:=True;
                  End;
                Until Quit;
              End;
          'B':If X>0 Then 
              Begin
                Dec(X); 
                Dec(UCnt);
              End;
        End;
      Until Next;
    End;
  End;
End;

Begin
End.