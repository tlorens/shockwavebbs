Unit EMail;

Interface

Procedure ListEmail;
Procedure SendEMail;
Procedure ReadEmail;
Procedure DeleteEMail;
Procedure NewScanEMail;

Implementation

Uses OpCrt,DOS,Records,CnfgRec,Vars,IO,MSub1,Misc,GenSubs,Display,User;

Var  MailCat: CatalogRec;

Procedure ListEmail;
Var Cnt,FCnt:Byte;
    K:Char;
    Chrs:String[2];
    T:Text;

Begin
  If Exist(CNF^.MenuDir+'EMAILLST.TOP') Then PrintFile(CNF^.MenuDir+'EMAILLST.TOP')
 Else
  Begin
    Cls;                                     
    MCIWrite('|08Ü');Color(11,3); PrintLn('³ #  ³ From                     ³ Title                             ³');
    MCiWriteLn('|08ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß ');
  End;

  If Exist(CNF^.MenuDir+'EMAILLST.MID') Then
  Begin
    Assign(T,CNF^.MenuDir+'EMAILLST.MID');
    Reset(T);
    Chrs:='';
    While (Not EOF(T)) And (NOT HungUpOn) do
    Begin
      Read(T,K);
      If K='|' Then
      Begin
        Read(T,K); Chrs:=K;
        Read(T,K); Chrs:=Chrs+K;
        If Chrs='MN' Then Tab(Strr(Cnt),3) Else
        If Chrs='TT' Then Tab(MHdr.Title,25) else
        If Chrs='FR' Then Tab(MHdr.From,25) Else
        If Chrs[1]='~' then Delay(Valu(Chrs[2])*1000) Else
        If Chrs='TI' Then Print(TimeStr(MHdr.When)) Else
        If Chrs='DA' Then Print(DateStr(MHdr.When)) Else
      End Else Print(K);
    End;
    Close(T);
  End
 Else
  With Mhdr Do Println(TabStr(Strr(Cnt),3)+TabStr(From,25)+TabStr(Title,25));

  If Exist(CNF^.MenuDIR+'EMAILLST.BOT') Then PrintFile(CNF^.MenuDir+'EMAILLST.BOT')
  Else MCiWriteln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|07');
  PrintLn('');

End;

Procedure UpDateCatalog;
Var X:Integer;
   
Begin
  FillChar(MailCat,SizeOf(MailCat),#0);
  For X:=0 to NumMsgs(1,CurConf,CurMsgAreaName,False)-1 Do
  Begin
    LoadMsg(1,MHdr,Msg,CurConf,CurMsgAreaName,X);
    If Match(MHdr.SendTo,Urec^.Handle) Then
    With MailCat Do
    Begin
      MailPos[NumMail]:=X;
      Inc(NumMail);
    End;
  End;
End;

Procedure SendEMail;
Var Inet:Boolean;
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  WriteHdr('Send E-Mail');
  With MHdr Do
  Begin
    FillChar(SendTo,SizeOf(SendTo),#0);
    CntI:=-1;
    SendTo:=Prompt(25,MyStr^.Email_To,False);
   
    Inet:=Pos('@',SendTo)<>0;
    CntI:=Pos('@',SendTo);

    If (ValidUserName(SendTo)) and (Length(sendTo)>0) and (Not iNet) Then 
    Begin
      OpenUserNDX(CurUFile);
      FindUser(SendTo,CntI);
      CloseUserNDX;
    End;

    If (CntI<>-1) Then 
    Begin
      Title:=Prompt(40,MyStr^.TitlePrompt,False);
      If Length(Title)=0 Then Title:='[ Untitled ]';
      If (Not iNet) Then Anon:=YeaNa(MyStr^.Anonprompt,False);
      If (Not iNet) Then Certified:=YeaNa(MyStr^.Certified,False);
      MsgType:=1;
      From:=Urec^.Handle;
      RealName:=Urec^.RealName;
      Deleted:=False;
      PostMsg(1,iNet);
    End Else Println('User Not found!');
  End;

End;

Procedure SearchMail;
Begin
  { searches for mail from/to user and displays it }
End;

Procedure ReplyMail(ID:LongInt);
Begin
  WriteHdr('Reply To E-Mail');
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
    From:=Urec^.Handle;
    If IsSysOp Then
    Begin
      MCIWrite('Reply As |08(|03CR|01/|11'+From+'|08)|RE: ');
      Edit(From,WhereX,WhereY,25,False);
      Println('');
    End;
    RealName:=Urec^.RealName;
    NumRead:=0;
    NumReply:=0;
    Deleted:=False;
    Back:=ID;
  End;
  If PostMsg(1,False) Then UpDateMsg(3,MHdr,CurConf,CurMsgAreaName,ID,False,True);
End;

Function EmailMenuBar(Title:String):Char;
Var UCh:Char;
Begin
 New(MenuBarz);
 With MenuBarz^ Do
 Begin
   MenuName:=Title+' - (?/Help)';
   Choice[1]:=' Next ';  HighChr[1]:=1;
   Choice[2]:=' Reply '; HighChr[2]:=1;
   Choice[3]:=' Again '; HighChr[3]:=1;
   Choice[4]:=' Back ';  HighChr[4]:=1;
   Choice[5]:=' Send ';  HighChr[5]:=1;
   Choice[6]:=' Quit ';  HighChr[6]:=1;
   NumChoices:=6;
   KeyCmds:='NRABSQ?';
   DefChoice:=1;
 End;

 EmailMenuBar:=BarMenu(MenuBarz^);
 Dispose(Menubarz);
End;


Procedure DeleteEMail;
Var X,St,Tot,Tot2:Integer;
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  WriteHdr('Delete E-Mail');
  Tot:=NumMsgs(1,CurConf,CurmsgAreaName,False);
  If Tot=0 Then
  Begin
    Println('No Messages!');
    Exit;
  End;
  Tot2:=Tot;
  St:=1;
  Range(St,Tot2);
  Dec(St);
  Dec(Tot2);
  If Tot2>Tot Then exit;
  For X:=St To Tot2 Do
  Begin
    LoadMsg(1,MHdr,Msg,CurConf,CurMsgAreaName,X);
    PrintMsgHdr(MHdr,Msg,CurMsgAreaName,(X+1),Tot);
    If YeaNa('Delete this Message:',False) Then
    Begin
      MHdr.Deleted:=True;
      DelMsg(1,MHdr,Msg,CurConf,CurMsgAreaName,X);
      PrintLn('Message Deleted');
    End;
  End;
End;

Procedure ReadEMail;
Var St,Tot,Tot2:Integer;
    UCnt,X:Longint;
    Next:Boolean;
Begin
  UpdateCatalog;
  WriteHdr('Read E-Mail');
  If MailCat.NumMail=0 then
  Begin
    Println('No Messages!');
    Exit;
  End;
  Tot2:=MailCat.NumMail;
  St:=1;
  Range(St,Tot2); Dec(St); Dec(Tot2);
  If Tot2>Tot Then exit;
  UCnt:=St;
  For X:=St To Tot2 Do 
  Begin
    Inc(UCnt);
    Next:=False;
    Repeat
      ReadMsg(1,CurConf,CurMsgAreaName,MailCat.MailPos[X],UCnt,MailCat.NumMail,False);
      Case EmailMenuBar('Read Messages') Of
        'Q':Exit;
        'R':ReplyMail(X);
        'N':Next:=True;
        'S':SendEMail;
        'A':;
        'B':If X>0 Then 
            Begin 
              Dec(X); 
              Dec(UCnt);
            End;
      End;
    Until Next;
  End;
End;

Procedure NewScanEMail;
Var Tot:Integer;
    UCnt,Cnt:LongInt;
    Next:Boolean;
Begin
  Tot:=NumMsgs(1,CurConf,CurMsgAreaName,False);
  For Cnt:=1 to Tot do
  Begin
    LoadMsg(1,MHdr,Msg,CurConf,CurMsgAreaName,Cnt);
    { Make this check the lastread index file }
    If Mhdr.When>=Urec^.LastCall Then
    Begin
      Next:=False;
      Repeat
        ReadMsg(1,CurConf,CurMsgAreaName,Cnt,UCnt,Tot,true);
        Case EmailMenuBar('Newscan Messages') Of
          'Q':Exit;
          'R':ReplyMail(Cnt);
          'N':Next:=True;
          'S':SendEMail;
          'A':ReadMsg(1,CurConf,CurMsgAreaName,Cnt,UCnt,Tot,False);
          'B':If Cnt>0 Then Begin Dec(Cnt); ReadMsg(1,CurConf,CurMsgAreaName,Cnt,UCnt,Tot,False); End;
        End;
      Until Next;
    End;
  End;
End;


Begin
End.