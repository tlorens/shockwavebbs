{
   iB * 02/28/96 - Message Handling routines.
                   These routines handle ANY message type in ShockWavE:PRO
                   mType = 0/Message - 1/E-mail - 2/News Bulletin - 3/FeedBack
                   These routines also allow areas to pass between conferences
                   and if wanted, E-mail/Bulletins/Feedback to be a message base!

   iB * 03/11/96 - Added Index routines to save NewScan Pointers. Of course
                   this works with ANY message saved in ShockWavE, unless its
                   a Bulletin.  Started implementing these routines with
                   newscan. Now saves in it's own MSG <DIR>

   iB * 03/12/96 - Completed newscan routines.  

}
{$I+,D-,L-}
Unit MSub1;

Interface

Uses OpCrt,Dos,Records,Vars,IO,GenSubs,CnfgRec,Display,Misc,User,ANSiEdit;

Procedure BuildNDX(MType:Byte; MArea:String);
Procedure AddToNDX(Mtype:Byte; Marea:String; U:UserRec);
Function IsNew(MType:Byte; Header:MsgHdr; Conf:Byte; MArea:String):Boolean;
Function NumMsgs(MType,Conf:Byte; MArea:Str10; Acutal:Boolean):Integer;
Procedure SaveMsg(MType:Byte; Header:MsgHdr; Txt:MsgTxt; Conf:Byte; MArea:Str10);
Procedure LoadMsg(MType:Byte; Var Header:MsgHdr; Var Txt:MsgTxt; Conf:Byte; MArea:Str10; ID:LongInt);
Procedure DelMsg(MType:Byte; Header:MsgHdr; Txt:MsgTxt; Conf:Byte; MArea:Str10; ID:LongInt);
Procedure PrintMsgHdr(Header:MsgHdr; Txt:MsgTxt; MArea:Str40; Cur,Total:Integer);
Function EditMsg(MType:Byte):Boolean;
Function PostMsg(MType:Byte; INet:Boolean):Boolean;
Procedure ReadMsg(MType,Conf:Byte; MArea:String; Var ID,Cur:LongInt; Tot:Integer; Up:Boolean);
Procedure UpDateMsg(MType:Byte; Header:MsgHdr; Conf:Byte; MArea:Str10; ID:LongInt;Update,Reply:boolean);
Procedure PackMsg(MType,Conf:Byte; MArea:Str10);
Procedure AutoDelete(MType:Byte; Conf:Byte; MArea:Str10; AutoDel:Integer);

Implementation

Var  FMsg:File Of MsgTxt;
     FMHdr:File Of MsgHdr;
      
Procedure BuildNDX(MType:Byte; MArea:String);
Var 
    IdxFile:String;
    LastMsgF: File Of LastMsgRec;
    LastM: LastMsgRec;
    XX,Lame,Cnt:Byte;
    U:UserRec;
Begin
  Println('');
  Println('Creating area index... '); XX:=WhereX;

  Case MType Of
    0: IdxFile:=StripSpace(CNF^.MsgDir+Marea+'.NDX');
    1: IdxFile:=CNF^.MsgDir+'EMAIL.NDX';
    3: IdxFile:=CNF^.MsgDir+'FEEDBACK.NDX';
  End;

  Assign(LastMsgF,IdxFile);
  ReWrite(LastmsgF);
  OpenUFiles(CurUFile);
  For Cnt:=1 to NumUsers Do
  Begin
    FillChar(LastM,SizeOf(LastM),#0);
    PrintXy(XX,WhereY,Strr(ReadUser(U)));
    LastM.Handle:=U.Handle;
    LastM.LastMsg:=-1;  
    Write(LastMsgF,LastM);
  End;
  CloseUFiles;
  Close(LastMsgF);
End;

Procedure AddToNDX(Mtype:Byte; Marea:String; U:UserRec);
Var    LastMsgF: File Of LastMsgRec;
       LastM: LastMsgRec;
       IdxFile:String;
Begin
  Case MType Of
    0: IdxFile:=CNF^.MsgDir+Marea+'.NDX';
    1: IdxFile:=CNF^.MsgDir+'EMAIL.NDX';
    3: IdxFile:=CNF^.MsgDir+'FEEDBACK.NDX';
  End;

  If Not Exist(IdxFile) then BuildNDX(Mtype,MArea);
  Println('New user added to area index...');
  Assign(LastMsgF,IdxFile);
  Reset(LastMsgF);
  Seek(LastMsgF,FileSize(LastMsgF));
  FillChar(LastM,SizeOf(LastM),#0);
  LastM.Handle:=U.Handle;
  LastM.LastMsg:=-1;
  Write(LastMsgF,LastM);
  Close(LastMsgF);
End;

Function IsNew(MType:Byte; Header:MsgHdr; Conf:Byte; MArea:String):Boolean;
Var IdxFile:String;
    Index:LastMsgRec;
    FIndex:File Of LastMsgRec;

Begin
  IsNew:=False;
  Case MType Of
    0: IdxFile:=StripSpace(CNF^.MsgDir+Marea+'.NDX');
    1: IdxFile:=CNF^.MsgDir+'EMAIL.NDX';
    3: IdxFile:=CNF^.MsgDir+'FEEDBACK.NDX';
  End;

  If Not Exist(IdxFile) then BuildNDX(Mtype,MArea);

  Assign(FIndex,IdxFile);
  ReSet(FIndex);
  While (not EOF(FIndex)) Do 
  Begin
    Read(FIndex,Index);
    If Match(Index.Handle,Urec^.Handle) Then
    begin
      If (Index.LastMsg<Header.ID) Then IsNew:=True;
      Close(FIndex);
      Exit;
    End;
  End;
  Close(FIndex);
  AddToNDX(Mtype,Marea,Urec^);
End;

Function FindDelMsg(MType,Conf:Byte; MArea:Str10):Integer; { For Recycling }
Var HdrFile:String;
    TmpHdr:MsgHdr;
Begin
  Case MType Of
    0:HdrFile:=StripSpace(CNF^.MsgDir+Marea+'.HDR');
    1:HdrFile:=CNF^.MsgDir+'EMAIL.HDR';
    2:HdrFile:=CNF^.MsgDir+'BULLET.HDR';
    3:HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR';
  End;

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);
  While Not EOF(FMHdr) Do
  Begin
    Read(FMHdr,TmpHdr);
    If TmpHdr.Deleted Then 
    Begin
      FindDelMsg:=FilePos(FMHdr)-1;
      Exit;
    End;
  End;
  Close(FMHdr);
  FindDelMsg:=FilePos(FMHdr)
End;

Function NumMsgs(MType,Conf:Byte; MArea:Str10; Acutal:Boolean):Integer;
Var SavFile:String;
    HdrFile:String;
    TmpX:MsgHdr;
    Tot:Word;
Begin
  Case MType Of
    0:Begin { Message }
{       SavFile:=CNF^.MsgDir+'MAREA'+PadRight(Strr(Conf),3,'0')+'.DAT';}
        SavFile:=CNF^.MsgDir+StripSpace(Marea)+'.'+PadRight(Strr(Conf),3,'0');
        HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR';
      End;
    1:Begin { E-Mail }
        SavFile:=CNF^.MsgDir+'EMAIL.DAT';
        HdrFile:=CNF^.MsgDir+'EMAIL.HDR';
      End;
    2:Begin { News Bulletin }
        SavFile:=CNF^.MsgDir+'BULLET.DAT';
        HdrFile:=CNF^.MsgDir+'BULLET.HDR';
      End;
    3:Begin { FeedBack }
        SavFile:=CNF^.MsgDir+'FEEDBACK.DAT';
        HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR';
      End;
  End;

  If Not Exist(SavFile) Then 
  Begin
    NumMsgs:=0;
    Exit;
  End;

  If Acutal Then
  Begin
    Assign(FMHdr,HdrFile);
    Reset(FMHdr);
    NumMsgs:=FileSize(FMHdr);
    Close(FMHdr);
  End
 Else
  Begin
    Tot:=0;
    Assign(FMHdr,HdrFile);
    Reset(FMHdr);
    While (Not EOF(FMHdr)) Do
    Begin
      Read(FMHdr,TmpX);
      If (Not (TmpX.Deleted)) Then Inc(Tot);
    End;
    NumMsgs:=Tot;
    Close(FMHdr);
  End;
End;

Procedure SaveMsg(MType:Byte; Header:MsgHdr; Txt:MsgTxt; Conf:Byte; MArea:Str10);
Var SavFile:String;
    HdrFile:String;
Begin
  Case MType Of
    0:Begin { Message }
        SavFile:=StripSpace(CNF^.MsgDir+Marea+'.'+PadRight(Strr(Conf),3,'0'));
        HdrFile:=StripSpace(CNF^.MsgDir+Marea+'.HDR');
      End;
    1:Begin { E-Mail }
        SavFile:=CNF^.MsgDir+'EMAIL.DAT';
        HdrFile:=CNF^.MsgDir+'EMAIL.HDR';
      End;
    2:Begin { News Bulletin }
        SavFile:=CNF^.MsgDir+'BULLET.DAT';
        HdrFile:=CNF^.MsgDir+'BULLET.HDR';
      End;
    3:Begin { FeedBack }
        SavFile:=CNF^.MsgDir+'FEEDBACK.DAT';
        HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR';
      End;
  End;

  If Not Exist(SavFile) Then
  Begin
    Assign(FMsg,SavFile);
    ReWrite(FMsg);
    Close(FMsg);
  End;

  If Not Exist(HdrFile) Then
  Begin
    Assign(FMHdr,HdrFile);
    ReWrite(FMHdr);
    Close(FMHdr);
  End;

  { Make this write over deleted messages }
  Assign(FMsg,SavFile);
  ReSet(FMsg);
  Seek(FMsg,FileSize(FMsg));
  Write(FMsg,Txt);
  Header.ID:=FilePos(FMsg)-1;
  Close(FMsg);

  Header.When:=Now;  { sets time of message }

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);
  Seek(FMHdr,FileSize(FMHdr));
  Write(FMHdr,Header);
  Close(FMHdr);
End;

Procedure LoadMsg(MType:Byte; Var Header:MsgHdr; Var Txt:MsgTxt; Conf:Byte; MArea:Str10; ID:LongInt);
Var X:Byte;
    SavFile:String;
    HdrFile:String;
Begin
  Case MType Of
    0:Begin { Message }
        SavFile:=CNF^.MsgDir+StripSpace(Marea)+'.'+PadRight(Strr(Conf),3,'0');
        HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR';
      End;
    1:Begin { E-Mail }
        SavFile:=CNF^.MsgDir+'EMAIL.DAT';
        HdrFile:=CNF^.MsgDir+'EMAIL.HDR';
      End;
    2:Begin { News Bulletin }
        SavFile:=CNF^.MsgDir+'BULLET.DAT';
        HdrFile:=CNF^.MsgDir+'BULLET.HDR';
      End;
    3:Begin { FeedBack }
        SavFile:=CNF^.MsgDir+'FEEDBACK.DAT';
        HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR';
      End;
  End;

  If (Not Exist(SavFile)) OR (Not Exist(HdrFile)) Then
  Begin
    WriteErr(SavFile+' or '+HdrFile+' not found.');
    Exit;
  End;

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);
  Seek(FMHdr,ID);
  Read(FMHdr,Header);
  Close(FMHdr);

  Assign(FMsg,SavFile);
  ReSet(FMsg);
  Seek(FMsg,ID);
  Read(FMsg,Txt);
  Close(FMsg);
End;

Procedure DelMsg(MType:Byte; Header:MsgHdr; Txt:MsgTxt; Conf:Byte; MArea:Str10; ID:LongInt);
Var SavFile:String;
    HdrFile:String;
Begin
  Case MType Of
    0:Begin { Message }
        SavFile:=CNF^.MsgDir+StripSpace(Marea)+'.'+PadRight(Strr(Conf),3,'0');
        HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR';
      End;
    1:Begin { E-Mail }
        SavFile:=CNF^.MsgDir+'EMAIL.DAT';
        HdrFile:=CNF^.MsgDir+'EMAIL.HDR';
      End;
    2:Begin { News Bulletin }
        SavFile:=CNF^.MsgDir+'BULLET.DAT';
        HdrFile:=CNF^.MsgDir+'BULLET.HDR';
      End;
    3:Begin { FeedBack }
        SavFile:=CNF^.MsgDir+'FEEDBACK.DAT';
        HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR';
      End;
  End;

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);
  Seek(FMHdr,ID);
  Write(FMHdr,Header);
  Close(FMHdr);

  Assign(FMsg,SavFile);
  ReSet(FMsg);
  Seek(FMsg,ID);
  Write(FMsg,Txt);
  Close(FMsg);
End;

Procedure UpDateMsg(MType:Byte; Header:MsgHdr; Conf:Byte; MArea:Str10; ID:LongInt;Update,Reply:boolean);
Var HdrFile:String;
    IdxFile:String;
    Index:LastMsgRec;
    FIndex:File Of LastMsgRec;

Begin
  Case MType Of
    0: Begin
         HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR'; { Message }
         IdxFile:=CNF^.MsgDir+StripSpace(Marea)+'.NDX';
       End;   
    1: Begin
         HdrFile:=CNF^.MsgDir+'EMAIL.HDR'; { E-Mail }
         IdxFile:=CNF^.MsgDir+'EMAIL.NDX';
       End;
    2: HdrFile:=CNF^.MsgDir+'BULLET.HDR'; { News Bulletin }
    3: Begin
         HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR'; { FeedBack }
         IdxFile:=CNF^.MsgDir+'FEEDBACK.NDX';
       End;
  End;

  If (Not Exist(HdrFile)) Then Exit;

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);
  Seek(FMHdr,ID);
  Read(FMHdr,Header);
  Inc(Header.NumRead);
  If Reply Then 
  Begin
    Inc(Header.NumReply);
    Header.Forwd:=ID;
  End;
  Seek(FMHdr,ID);
  Write(FMHdr,Header);
  Close(FMHdr);

  If (MType<>2) and (Update) Then 
  Begin
    Assign(FIndex,IdxFile);
    Reset(Findex);
    While (not EOF(FIndex)) Do 
    Begin
      Read(FIndex,Index);
      If Match(Index.Handle,Urec^.Handle) Then
      begin
        Index.LastMsg:=ID;
        Seek(FIndex,FilePos(Findex)-1);
        Write(FIndex,Index);
        Close(FIndex);
        Exit;
      End;
    End;
    Close(FIndex);
    AddToNDX(Mtype,Marea,Urec^);
  End;
End;

Procedure PrintMsgHdr(Header:MsgHdr; Txt:MsgTxt; MArea:Str40; Cur,Total:Integer);
Var Ch:Char;
    Chk:String[2];
    Mark:String;
    X:integer;
    T:Text;
    LnCnt:Byte;

Function Delete:String;
Begin
  If Header.Deleted Then Delete:=' |12(Deleted)|RE' else Delete:='';
End;

Begin
  LnCnt:=0;
  If Exist(CNF^.MenuDir+'HEADER.'+Strr(Urec^.MsgHeader)) Then
  Begin
    Assign(T,CNF^.MenuDir+'HEADER.'+Strr(Urec^.MsgHeader));
    Reset(T);
    While (Not Eof(T)) and (Not HungUpOn) Do
    Begin
      Read(T,Ch);
      If Ch='|' Then
      Begin
        Read(T,Ch); Chk:=Ch;
        Read(T,Ch); Chk:=Chk+Ch;
        If Chk='MC' then Print(Strr(Cur)) else
        If Chk='MN' Then Print(Strr(Total)) else
        If Chk='MT' Then Print(TimeStr(Header.When)) else
        If Chk='MD' Then Print(DateStr(Header.When)) else
        If Chk='TO' Then Print(Header.SendTo) else
        If Chk='FR' Then Begin
                           If (IsSysop) and (Header.Anon) Then Header.From:=+'*'+Header.From+'*';
                           If Header.Anon Then MCIPrint(MyStr^.AnonymousStr) Else Print(Header.From)
                         End Else
        If Chk='TI' Then MCiPrint(Header.Title+Delete) else
        If Chk='CB' Then Print(MArea);
      End Else Print(Ch);
    End;
    Close(T);
  End
 Else
  If Urec^.MsgHeader=0 Then
  Begin
    Cls;
    Acolor(Urec^.MiscColor);
    If Emulation>0 Then PrintXY(79-Length(MArea),1,MArea) Else Println('['+Marea+']');
    Println('');
    With Header Do
    Begin
      If (IsSysop) and (Header.Anon) Then From:=+'*'+From+'*';
      Mark:=TabStr('    |PRMsg: |ST'+Strr(Cur)+' |PRof |ST'+Strr(Total),46);
      Mark:=Mark+'|PRDate: |ST'+TimeStr(When)+' |PRon |ST'+DateStr(When);
      MCIWriteln(Mark);
      If (Header.Anon) and (Not IsSysop) Then
      MCIWriteln('   |PRFrom: |ST'+TabStr(MyStr^.AnonymousStr,25)+'|PRRead: |ST'+Strr(NumRead)+
                 '  |PRReplies: |ST'+Strr(NumReply))
      Else
       MCIWriteln('   |PRFrom: |ST'+TabStr(From,25)+'|PRRead: |ST'+Strr(NumRead)+'  |PRReplies: |ST'+Strr(NumReply));
      MCIWriteln('     |PRTo: |ST'+SendTo);
      If IsSysOp Then MCIWriteln('  |PRTitle: |ST'+Title+Delete+' |BX[|ISMsg ID: |ST'+Strr(ID)+'|BX]')
        Else MCIWriteln('  |PRTitle: |ST'+Title+Delete)
    End;
    MCIWriteln('|BX[|IS컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴|BX]|RE');
    If Emulation >=1 then GotoXy(1,7) Else Print(^M);
  End;

  For X:=1 to Txt.Numlines Do
  Begin
    If WhereY=23 Then If (Not YeaNa('More ',True)) Then 
    Begin
      GoXY(1,23); 
      ClsEol;
      Exit 
    End
   Else 
    Begin
      GoXY(1,23); 
      ClsEol;
    End;
    MCiPrintLn(Txt.Text[X]);
  End;
End;

Procedure InterNetMail(Too,CC,Sub:String; Txt:MsgTxt);
Var T:Text;
    
Begin
  Assign(T,'MAIL.TXT');
  ReWrite(T);
  Writeln(T,'To: ',Too);
  Writeln(T,'Subject: ',Sub);
  For CntI:=1 To Txt.NumLines Do Writeln(T,Txt.Text[CntI]);
  Writeln(T,^M^M^M+'---[ShockWavE Internet-Mail]---');
  Close(T);
End;


Function EditMsg(MType:Byte):Boolean;
Begin
  If ANSiEditor(Msg,MHdr,-1) Then EditMsg:=True Else EditMsg:=False;
End;

Function PostMsg(MType:Byte; Inet:Boolean):Boolean;
Begin
  FillChar(Msg,Sizeof(Msg),#0);
  If ANSiEditor(Msg,MHdr,-1) Then
  Begin
    PostMsg:=True;
    If iNet Then InterNetMail(MHdr.SendTo,'',MHdr.Title,Msg) Else
    SaveMsg(MType,MHdr,Msg,CurConf,CurMsgAreaName);
  End
 Else PostMsg:=False;
End;

Procedure ReadMsg(MType,Conf:Byte; MArea:String; Var ID,Cur:LongInt; Tot:Integer; Up:Boolean);
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  LoadMsg(MType,MHdr,Msg,Conf,MArea,ID);
  PrintMsgHdr(MHdr,Msg,MArea,Cur,Tot);
  UpDateMsg(MType,MHdr,Conf,MArea,ID,Up,False);
End;

Procedure PackMsg(MType:Byte; Conf:Byte; MArea:Str10);
Var HdrFile:String;
    IdxFile:String;
    SavFile:String;
    TmpFile:String;
    Index:LastMsgRec;
    FIndex:File Of LastMsgRec;
    Hdr:MsgHdr;
    Txt:MsgTxt;

Begin
  TmpFile:=RandomFile;
  Case MType Of
    0: Begin
         SavFile:=CNF^.MsgDir+StripSpace(Marea)+'.'+PadRight(Strr(Conf),3,'0');
         HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR'; { Message }
         IdxFile:=CNF^.MsgDir+Marea+'.NDX';
       End;
    1: Begin
         HdrFile:=CNF^.MsgDir+'EMAIL.HDR'; { E-Mail }
         IdxFile:=CNF^.MsgDir+'EMAIL.NDX';
       End;
    2: HdrFile:=CNF^.MsgDir+'BULLET.HDR'; { News Bulletin }
    3: Begin
         SavFile:=CNF^.MsgDir+'FEEDBACK.DAT';
         HdrFile:=CNF^.MsgDir+'FEEDBACK.HDR'; { FeedBack }
         IdxFile:=CNF^.MsgDir+'FEEDBACK.NDX';
       End;
  End;

  Assign(FIndex,IdxFile);
  ReSet(FIndex);

  Assign(FMsg,SavFile);
  ReSet(FMsg);

  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);

  While Not EOF(FMHdr) Do
  Begin
    Read(FMHdr,Hdr);
    Read(FIndex,Index);
    Read(FMsg,Txt);
    If (Not Hdr.Deleted) then
    Begin

    End;
  End;
  Close(FMHdr);
  Close(FMsg);
  Close(FIndex);
End;


Procedure AutoDelete(MType:Byte; Conf:Byte; MArea:Str10; AutoDel:Integer);
Var HdrFile:String;
    SavFile:String;
    TmpFile1,TmpFile2:String;
    Hdr:MsgHdr;
    Txt:MsgTxt;
    TmpFMsg:File Of MsgTxt;
    TmpFMHdr:File Of MsgHdr;

Begin
  Case MType Of
    0: Begin
         SavFile:=CNF^.MsgDir+StripSpace(Marea)+'.'+PadRight(Strr(Conf),3,'0');
         HdrFile:=CNF^.MsgDir+StripSpace(Marea)+'.HDR'; { Message }
         TmpFile1:=CNF^.MsgDir+StripSpace(Marea)+'.%%%';
         TmpFile2:=CNF^.MsgDir+StripSpace(Marea)+'.!!!';
       End;
    1: Begin
         HdrFile :=CNF^.MsgDir+'EMAIL.HDR'; { E-Mail }
         TmpFile1:=CNF^.MsgDir+'EMAIL.%%%';
         TmpFile2:=CNF^.MsgDir+'EMAIL.!!!';
       End;
    2: Begin
         HdrFile :=CNF^.MsgDir+'BULLET.HDR'; { News Bulletin }
         TmpFile1:=CNF^.MsgDir+'BULLET.%%%';
         TmpFile2:=CNF^.MsgDir+'BULLET.!!!';
       End;
    3: Begin
         SavFile :=CNF^.MsgDir+'FEEDBACK.DAT';
         HdrFile :=CNF^.MsgDir+'FEEDBACK.HDR'; { FeedBack }
         TmpFile1:=CNF^.MsgDir+'FEEDBACK.%%%';
         TmpFile2:=CNF^.MsgDir+'FEEDBACK.!!!';
       End;
  End;

  { Open Master and Temp Message Records }
  Assign(FMsg,SavFile);
  ReSet(FMsg);
  Assign(TmpFMsg,TmpFile1);
  ReWrite(TmpFMsg);

  { Open Master and Temp Header Records }
  Assign(FMHdr,HdrFile);
  ReSet(FMHdr);

  Assign(TmpFMHdr,TmpFile2);
  ReWrite(TmpFMHdr);

  Seek(FMHdr,AutoDel);
  Seek(FMsg,AutoDel);

  While (Not EOF(FMHdr)) Do
  Begin
    Read(FMHdr,Hdr); Write(TmpFMhdr,Hdr);
    Read(FMsg,Txt);  Write(TmpFMsg,Txt);
  End;

  Close(TmpFMHdr);
  Close(TmpFMsg);

  Close(FMHdr);
  Assign(FMHdr,HdrFile);
  Erase(FMHdr);

  Close(FMsg);
  Assign(FMsg,SavFile);
  Erase(FMsg);

  Assign(TmpFMsg,TmpFile1);
  Rename(TmpFMsg,SavFile);

  Assign(TmpFMHdr,TmpFile2);
  Rename(TmpFMHdr,HdrFile);
End;

Begin
End.