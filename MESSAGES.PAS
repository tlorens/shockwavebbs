{
  iB * 08/19/95 - Started work on Opening and Closing files when needed.
                  Started implementing area editor.
  iB * 03/09/96 - Can now post/read messages. Read range works (2-5).
                  Updates times message has been read.
  iB * 03/12/96 - Implemented Newscan + ReadMessage Menu Bars
  iB * 12/16/96 - Read messages now skips over Deleted messages, 
                  unless you're a SysOp. Obviously Delete Message works
                  now too.
}

{$D-,L-}
Unit Messages;

Interface

Procedure EditMsgArea(Add:Boolean);
Procedure SelectMArea;
Procedure AddMarea;
Procedure DeleteArea;
Procedure DeleteMessages;
Procedure SetMArea(N:Byte; NewScan:Boolean);
Procedure NxtArea;
Procedure PrvArea;
Procedure ReadMessages;
Procedure NewScanArea;
Procedure EditMessage;
Procedure PostMessage;
Procedure MsgNewScanAll;

Implementation

Uses OpCrt,Records,Vars,IO,GenSubs,Files,User,CnfgRec,Display,Misc,MSub1;

Var MArea:File Of BoardRec;
    CurArea:BoardRec;
    MIndex:File Of Str25;
    AreaFPos:Integer;

    QuitNewScan:Boolean;
    NextArea:Boolean;
{
  MAREA[conf].DAT
  MAREA001.DAT
}
{$I+}

Procedure AssignM;
Var S:Str80;
Begin
  S:=CNF^.MsgDir+'MAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  Assign(MArea,S);
 { Assign(MIndex,S+'.NDX');}
End;

Procedure CloseMFiles;
Begin
  Close(MArea);
{ Close(MIndex);}
End;

Procedure OpenMFiles;
Begin
  AssignM; ReSet(MArea);
End;

Procedure CheckAreas;
Var S:String;
Begin
  S:=CNF^.MsgDir+'MAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  If Not Exist(S) Then
  Begin
    AssignM; ReWrite(MArea);
    CloseMFiles;
    AddMArea;
  End;
End;

Procedure WriteMArea;
Begin
  OpenMFiles;
  Seek(Marea,AreaFPos);
  Write(MArea,CurArea);
  CloseMFiles;
End;

Procedure WriteNewMArea;
Begin
  OpenMFiles;
  Seek(Marea,FileSize(MArea));
  Write(MArea,CurArea);
  CloseMFiles;
End;

Procedure ReadMArea;
Begin
  Read(MArea,CurArea);
  AreaFPos:=FilePos(MArea)-1;
End;

Procedure SeekMArea(N:Integer);
Begin
  Seek(MArea,N-1);
End;

Function NumAreas:Integer;
Begin
  CheckAreas;
  OpenMFiles;
  NumAreas:=FileSize(MArea);
  CloseMFiles;
End;

Function Validbname (N:Str10):Boolean;
Var Cnt:Integer;
Begin
  Validbname:=False;
  If (length(n)=0) or (length(n)>8) then exit;
  For Cnt:=1 To Length(n) Do
    If Not (upcase(n[cnt]) in ['0'..'9','A'..'Z']) Then Exit;
  Validbname:=True
End;

Procedure WriteEditor;
Begin
  Cls;
  Println('');
  MCiPrintln('|CM Message Area Configuration ');
  MCiPrintln('|BXÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸');
  MCiPrintln('|BX³ |MS[|INC|MS] |ISAccess Command |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INN|MS] |ISName           |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|IND|MS] |ISDescription    |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INS|MS] |ISSub-Op         |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INP|MS] |ISPassword       |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INL|MS] |ISAccess Flags   |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INO|MS] |ISPost Flags     |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INM|MS] |ISMax Messages   |BX³                                                        ³');

  MCiPrintln('|BX³ |MS[|INK|MS] |IS# Msgs to Kill |BX³                                                        ³');

  MCiPrintln('|BX³ |MS[|INT|MS] |ISArea Type      |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INF|MS] |ISNet Address    |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INX|MS] |ISNet Directory  |BX³                                                        ³');
  MCiPrintln('|BX³ |MS[|INE|MS] |ISPrivate E-Mail |BX³                                                        ³');
  MCiPrintln('|BXÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾');
  MCiPrintln('                                                                       |MS(|INQ|MS)|PRuit');
  With CurArea Do
  Begin
    AColor(Urec^.StatColor);
    PrintXy(24,4,AreaCmd);
    PrintXy(24,5,AreaName);
    PrintXy(24,6,Description);
    PrintXy(24,7,SubOp);
    PrintXy(24,8,Password);
    PrintXy(24,9,Flags);
    PrintXy(24,10,PostFlags);
    PrintXy(24,11,Strr(MaxMsgs));
    PrintXy(24,12,Strr(NumToDel));
  { GetNetType(False); }
    PrintXy(24,14,Address);
    PrintXy(24,15,Directory);
    If Priv Then PrintXy(24,16,'Yes') Else PrintXy(24,16,'No');  
    MCiPrint('|08'); PrintXy(1,18,'Last Date Scanned: '+DateStr(LastScan));
  End;
End;

Procedure EditMsgArea(Add:Boolean);
Var GG:Char;

  Procedure AreaName;
  Begin
    Edit(CurArea.AreaName,24,5,25,False);
    BackSpace(24,5,Length(CurArea.AreaName));
    Print(CurArea.AreaName);
  End;

  Procedure Password;
  Begin
    Edit(CurArea.Password,24,8,25,False);
    BackSpace(24,8,Length(CurArea.Password));
    Print(CurArea.Password);
  End;

  Procedure Description;
  Begin
    Edit(CurArea.Description,24,6,40,False);
    BackSpace(24,6,Length(CurArea.Description));
    Print(CurArea.Description);
  End;

  Procedure PrivateArea;
  Begin
    With CurArea Do
    Begin
      Priv:=Not Priv;
      If Priv then PrintXY(24,16,'Yes') else PrintXy(24,16,'No ');
    End;
  End;

  Procedure PostFlags;  { Use Flags Here }
  Begin
    Edit(CurArea.PostFlags,24,10,40,False);
    BackSpace(24,10,Length(CurArea.PostFlags));
    Print(CurArea.PostFlags);
  End;

  Procedure GetAddress;
  Begin
    Edit(CurArea.Address,24,14,40,False);
    BackSpace(24,14,Length(CurArea.Address));
    Print(CurArea.Address);
  End;

  Procedure GetDirectory;
  Begin
    Edit(CurArea.Directory,24,15,40,False);
    BackSpace(24,15,Length(CurArea.Directory));
    If Length(CurArea.Directory)>1 then If CurArea.Directory[Length(CurArea.Directory)]<>'\' Then
    CurArea.Directory:=CurArea.Directory+'\';
    Print(CurArea.Directory);
  End;

  Procedure AccessFlag;
  Begin
    Edit(CurArea.Flags,24,9,40,False);
    BackSpace(24,9,Length(CurArea.Flags));
    Print(CurArea.Flags);
  End;

  Procedure AccessName;
  Begin
    Edit(CurArea.AreaCmd,24,4,8,False);
    BackSpace(24,4,Length(CurArea.AreaCmd));
    Print(CurArea.AreaCmd);
    If Length(Input)=0 Then Exit;
    If not validbname(Input) then
    Begin
      PrintXy(4,24,'Invalid board name!');
      Delay(2000);
      BackSpace(24,4,19);
      PrintXy(4,24,CurArea.AreaCmd);
    End
   Else
    If {boardexist(Input)} FALSE then
    Begin
       PrintXy(4,24,'Board already exists!');
         Delay(2000);
       BackSpace(24,4,21);
       PrintXy(4,24,CurArea.AreaCmd);
    End
   {Else
    CurArea.AreaCmd:=Input;
    BackSpace(24,4,Length(CurArea.AreaCmd));
    Print(CurArea.AreaCmd);}
  End;

  Procedure SubOp;
  var un:integer;
  Begin
    Un:=-1;
    Repeat
      Edit(CurArea.SubOp,24,7,25,False);
      OpenUFiles(CurUFile);
      FindUser(CurArea.SubOp,un);
      CloseUFiles;
      If Un=-1 Then
      Begin
        PrintXY(24,7,'No such user.           ');
        Delay(2000);
        BackSpace(24,7,13);
      End;
    Until Un>-1;
    BackSpace(24,7,Length(CurArea.SubOp));
    Print(CurArea.SubOp);
  End;

  Procedure SetAutoDel;
  Var Tot,Cnt:Byte;
  Begin
    With CurArea Do
    Begin
      Input:=Strr(MaxMsgs);
      Edit(Input,24,11,5,False);
      MaxMsgs:=Valu(Input);
      If MaxMsgs<10 then
      Begin
        PrintXy(24,11,'Can''t be less than 10!');
        Delay(2000);
        BackSpace(24,11,22);
        If MaxMsgs<10 then MaxMsgs:=10;
        Print(strr(MaxMsgs));
      End
    End;
    BackSpace(24,11,Length(Strr(CurArea.MaxMsgs)));
    Print(Strr(CurArea.MaxMsgs));
  End;

  Procedure SetNumToDel;
  Begin
    Input:=Strr(CurArea.NumToDel);
    Edit(Input,24,12,5,False);
    CurArea.NumToDel:=Valu(Input);

    If CurArea.NumToDel<0 Then CurArea.NumToDel:=1;

    If (CurArea.NumToDel>CurArea.MaxMsgs) then
    Begin
      PrintXy(24,12,'Can''t be greater than '+Strr(CurArea.MaxMsgs)+'!');
      Delay(2000);
      BackSpace(24,12,30);
      CurArea.NumToDel:=(CurArea.MaxMsgs div 10);
      If CurArea.NumToDel<0 Then CurArea.NumToDel:=1;
      Print(Strr(CurArea.NumToDel));
    End;
    BackSpace(24,12,Length(Strr(CurArea.NumToDel)));
    Print(Strr(CurArea.NumToDel));
  End;

Begin
  WriteEditor;
  Repeat
    Repeat
      GetChar(GG);
      If Length(GG)=0 then GG:=' '; GG:=Upcase(GG);
    Until (Pos(GG,'CNDSPLOMKITAE%FXQ') >0) or HungUpOn;
    Case GG of
      'C':AccessName;
      'N':AreaName;
      'D':Description;
      'S':SubOp;
      'P':Password;
      'L':AccessFlag;
      'O':PostFlags;
      'M':SetAutoDel;
      'K':SetNumToDel;
{     'T':GetNetType(True);}
      'E':PrivateArea;
      'F':GetAddress;
      'X':GetDirectory;
      'Q':;
    End;
  Until (GG='Q') or hungupon;

  GoXy(1,23);
  If YeaNa('Save Changes:',True) Then
  Case Add of
     False:WriteMArea;
      True:Begin
             WriteNewMArea;
             BuildNDX(0,StripSpace(CurArea.AreaName));
           End;
  End;
End;


Procedure AddMarea;
Begin
  FillChar(CurArea,SizeOf(CurArea),#0);
  With CurArea Do
  Begin
    AreaCmd     :='New';
    AreaName    :='New Area';
    Description :='New Message Area';
    SubOp       :=Urec^.Handle;
    Password    :='';
    Flags       :='(s1)';
    PostFlags   :='(s1)';
    MaxMsgs     :=100;
    NumToDel    :=25;
    RealNames   :=False;
    Priv        :=False;
    NetType     :=1;
    Directory   :='';
    Address     :='';
    EditMsgArea(True);
  End;
End;
                  { Just Pass in the RECORD here }
Procedure AreaHdr(Area,Descp,Msgs,Cmd:Str80; Net:Byte; NewScan:Boolean);
Var Txt:Text;
    Z,Ch:Char;
    Chk:String[2];

Begin
  If NewScan Then 
  Begin
    Println('New Scanning Area: '+Area+' ('+Descp+')');
    exit;
  End;
  If Not Exist(CNF^.MenuDir+'AREAHDR.ANS') then
  Begin
    Println('[40m[2J[2;1H[3;1H[4;1H[12C[0;1;36mÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[s');
    Println('[uÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[0;36mÜ[5;1H[12C[1mÛ[0;36mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ[s');
    Println('[uÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ[1;30mÛ[6;1H[12C[36mÛ[0;36mÛÛ[s');
    Println('[u[1;30mÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß[36;46mÜ[40m[s');
    Println('[u[0;36mÛÛ[1;30mÛ[7;1H[12C[36mÛ[0;36mÛÛ[1;30mÛ[48C[36mÛ[0;36mÛÛ[s');
    Println('[u[1;30mÛ[8;1H[12C[36mÛ[0;36mÛÛ[1;30mÛ[48C[36mÛ[0;36mÛÛ[1;30mÛ');
    Println('[9;1H[12C[36mÛ[0;36mÛÛ[1;30mÛ[48C[36mÛ[0;36mÛÛ[1;30mÛ[10;1H[12C[s');
    Println('[u[36mÛ[0;36mÛÛ[1;30;46mß[36;40mÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[s');
    Println('[uÜÜÜÜÜÜÜÜÜÜÛ[0;36mÛÛ[1;30mÛ[11;1H[12C[36mÛ[0;36mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ[s');
    Println('[uÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ[1;30mÛ[12;1H[12C[0;36mß[1;30mßß[s');
    Println('[ußßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß[0m');
   { AColor(Urec^.StatColor);}
    AColor(15);
    PrintXY(24,7,'Area Name: '+Area);
    PrintXY(24,8,'Description: '+Descp);
    If Net>1 then printxy(24,9,'Status: Net - Messages: '+Msgs)
           else PrintXy(24,9,'Status: Local - Messages: '+Msgs);
    Println(^M^M^M);
  End
Else
 Begin
    If Not Exist(CNF^.MenuDir+Cmd+'.HDR') Then
    Begin
      Assign(Txt,CNF^.MenuDir+'AREAHDR.ANS');
      Reset(Txt);
      While (Not EOF(Txt)) and (Not HungUpOn) Do
      Begin
        Read(Txt,Ch);
        If Ch='|' Then
        Begin
          Read(Txt,Ch); Chk:=Ch;
          Read(Txt,Ch); Chk:=Chk+Ch;
          { Add Sub-Op Name here }
          If Chk='AN' then Print(Area) else
          If Chk='DE' Then Print(Descp) else
          If Chk='MS' Then Print(Msgs) else
          If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
          If Chk='HA' Then Print(Urec^.Handle) Else
          If Chk='TI' Then Print(TimeStr(Now)) Else
          If Chk='DA' Then Print(DateStr(Now)) Else
          If Chk='SY' Then Print(CNF^.FullSysName) Else
          If Chk='TL' Then Print(Strr(Urec^.TimeLeft)) Else
          If Chk='ST' Then if Net>1 then Print('Net') else Print('Local');
        End Else Print(Ch);
      End;
      Close(Txt);
    End
   Else
    Begin
      Assign(Txt,CNF^.MenuDir+Cmd+'.HDR');
      Reset(Txt);
      While (Not EOF(Txt)) and (Not HungUpOn) Do
      Begin
        Read(Txt,Ch);
        If Ch='|' Then
        Begin
          Read(Txt,Ch); Chk:=Ch;
          Read(Txt,Ch); Chk:=Chk+Ch;
          { Add Sub-Op Name here }
          If Chk='AN' then Print(Area) else
          If Chk='DE' Then Print(Descp) else
          If Chk='MS' Then Print(Msgs) else
          If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
          If Chk='HA' Then Print(Urec^.Handle) Else
          If Chk='TI' Then Print(TimeStr(Now)) Else
          If Chk='DA' Then Print(DateStr(Now)) Else
          If Chk='SY' Then Print(CNF^.FullSysName) Else
          If Chk='TL' Then Print(Strr(Urec^.TimeLeft)) Else
          If Chk='ST' Then if Net>1 then Print('Net') else Print('Local');
        End Else Print(Ch);
      End;
      Close(Txt);
    End;
 End;
End;

Procedure AreaList;
Var Cnt,FCnt:Byte;
    K:Char;
    Chrs:String[2];
    T:Text;
Begin
  Cnt:=0;
  FCnt:=0;
  If Exist(CNF^.MenuDir+'MSGAREA.TOP') Then PrintFile(CNF^.MenuDir+'MSGAREA.TOP')
 Else
  Begin
    Cls;                                                
    MCIWrite('|08Ü');Color(11,3); PrintLn('³ Area Cmd ³ Name             ³ Description                     ³ # Msgs ³');
    MCiWriteLn('|08ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß ');
  End;

  AColor(Urec^.RegularColor);
  OpenMFiles;
  While Not EOF(MArea) Do
  Begin
    Inc(FCnt); Inc(Cnt);
    Read(MArea,CurArea);

    If GetAccess(CurArea.Flags) Then
    With CurArea Do
    Begin
      If Exist(CNF^.MenuDir+'MSGAREA.MID') Then
      Begin
        Assign(T,CNF^.MenuDir+'MSGAREA.MID');
        Reset(T);
        Chrs:='';
        While (Not EOF(T)) And (NOT HungUpOn) do
        Begin
          Read(T,K);
          If K='|' Then
          Begin
            Read(T,K); Chrs:=K;
            Read(T,K); Chrs:=Chrs+K;
            If Chrs='MA' Then Tab(AreaCmd,8) Else
            {If Chrs='MA' Then Tab(Strr(FilePos(Marea)),8) Else}
            If Chrs='DE' Then Tab(Description,25) else
            If Chrs='PO' Then Tab(Strr(NumMsgs(0,CurConf,AreaName,False)),5) Else
{            If Chrs='PO' Then Tab(Strr(CurArea.NumPosts),5) Else}
            If Chrs='SO' Then Tab(SubOP,25) Else
            If Chrs='AR' Then Tab(Areaname,25) Else
            If Chrs='NX' Then Read(MArea,CurArea) Else
            If Chrs[1]='~' then Delay(Valu(Chrs[2])*1000) Else
            If Chrs='HA' Then Print(Urec^.Handle) Else
            If Chrs='TI' Then Print(TimeStr(Now)) Else
            If Chrs='DA' Then Print(DateStr(Now)) Else
            If Chrs='SY' Then Print(CNF^.FullSysName) Else
            If Chrs='TL' Then Print(Strr(Urec^.TimeLeft)) Else Print(Chrs);
          End Else Print(K);
        End;
        Close(T);
      End
     Else
      With CurArea Do Println('  '+TabStr(AreaCmd,11)+TabStr(AreaName,20)+TabStr(Description,40)+
                              Strr(NumMsgs(0,CurConf,AreaName,False)));
    End;
  End;
  If Exist(CNF^.MenuDIR+'MSGAREA.BOT') Then PrintFile(CNF^.MenuDir+'MSGAREA.BOT')
  Else MCiWriteln('|BX[|ISÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|BX]|RE');
  PrintLn('');
  CloseMFiles;
End;

Procedure SetMArea(N:Byte; NewScan:Boolean);
Var OldArea:BoardRec;
    OldAreaNum:Integer;
    OldMsgAreaName:String;
Begin
  If (N > NumAreas) or (N <= 0) Then
  Begin
    MCiWriteln(MyStr^.InvalidMsgArea);
    If IsSysOp Then MCiWriteln(MyStr^.NoAreas);
    Exit;
  End
 Else
  Begin
    OldArea:=CurArea;
    OpenMFiles;
    SeekMArea(N);
    ReadMArea;
    CloseMFiles;
    If (Not GetAccess(CurArea.Flags)) Then
    Begin
      CurArea:=OldArea;
      CurMsgArea:=OldAreaNum;
      CurMsgAreaName:=CurArea.AreaName;
      With CurArea Do AreaHdr(AreaName,Description,Strr(NumMsgs(0,CurConf,AreaName,False)),
                              AreaCmd,NetType,NewScan);
      Exit;
    End;
     CurMsgArea:=N;
     CurMsgAreaName:=CurArea.AreaName;
  End;
  With CurArea Do AreaHdr(AreaName,Description,Strr(NumMsgs(0,CurConf,AreaName,False)),
                          AreaCmd,NetType,NewScan);
End;

Function FindArea(S:String; Var Ndx:Byte):Boolean;
Var N:Byte;
Begin
  N:=NumAreas;
  OpenMFiles;
  For CntB:=1 to N Do
  Begin
    ReadMArea;
    If (GetAccess(CurArea.Flags)) Then
    Begin
      If (Match(S,CurArea.AreaCmd)) Then 
      Begin
        FindArea:=True;
        Ndx:=CntB;
        CloseMFiles;
        Exit;
      End 
     Else
      Begin
        FindArea:=False;
        Ndx:=CurMsgArea;
      End;
    End;
  End;
  CloseMFiles;
End;

Procedure SelectMArea;
Begin
  Println(^M);
  If NumAreas>0 Then
  Begin
    Repeat
      Input:='';
      Input:=Prompt(25,MyStr^.MsgAreaPrompt,False);
      If (Length(Input)=0) then exit;
      If Input[1]='?' Then AreaList;
    Until Input[1]<>'?';
    If FindArea(Input,CurMsgArea) Then SetMArea(CurMsgArea,False);
  End
 Else
  Begin
    MCIWriteLn(MyStr^.InvalidMsgArea);
    If IsSysOp Then MCiWriteln(MyStr^.NoAreas);
  End;
End;

Procedure NxtArea;
Begin
  Inc(CurMsgArea); 
  If CurMsgArea<=NumAreas Then SetMArea(CurMsgArea,False) Else Dec(CurMsgArea);
End;

Procedure PrvArea;
Begin
  Dec(CurMsgArea);
  If CurMsgArea>0 Then SetMArea(CurMsgArea,False) Else Inc(CurMsgArea);
End;

Procedure DeleteArea;
Var T:File;

  Procedure PackAreas;
  Var Tmp:File Of BoardRec;
        S:String;
  Begin
    S:=CNF^.MsgDir+'MAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
    Assign(Tmp,CNF^.MsgDir+'TMP$$$.$$$');
    ReWrite(Tmp);

    SeekMArea(1);
    While Not EOF(MArea) do
    Begin
      ReadMArea;
      If Length(CurArea.AreaName)>0 then Write(Tmp,CurArea);
    End;
    CloseMfiles; Close(Tmp);
    OpenMfiles;  Assign(Tmp,CNF^.MsgDir+'TMP$$$.$$$');
    Erase(MArea);
    Rename(Tmp,S);
    CloseMFiles;
  End;

Begin
  MCIPrintln('Current Area:'+CurArea.AreaName+' ('+Strr(CurMsgArea)+')');
  Input:=Prompt(3,'Delete Message Area #: ',False);
  If Valu(Input)>0 Then
  Begin

    OpenMFiles;
    SeekMArea(Valu(Input));
    Read(MArea,CurArea);

    If Exist(CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.NDX') Then
    Begin
      Assign(T,CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.NDX');
      Erase(T);
    End;

    If Exist(CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.HDR') Then
    Begin
      Assign(T,CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.HDR');
      Erase(T);
    End;

    If Exist(CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.'+PadRight(Strr(CurConf),3,'0')) then
    Begin
      Assign(T,CNF^.MsgDir+StripSpace(CurArea.AreaName)+'.'+PadRight(Strr(CurConf),3,'0'));
      Erase(T);
    End;

    FillChar(CurArea,SizeOf(CurArea),#0);
    SeekMArea(Valu(Input));
    Write(MArea,CurArea);
    PackAreas;
  End;
End;

Procedure DeleteMessages;
Var X,St,Tot,Tot2:Integer;
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  WriteHdr('Delete Message');
  Tot:=NumMsgs(0,CurConf,CurmsgAreaName,True);
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
    LoadMsg(0,MHdr,Msg,CurConf,CurMsgAreaName,X);
    If Match(MHdr.From,Urec^.Handle) or (IsSysOp) Then
    Begin
      PrintMsgHdr(MHdr,Msg,CurMsgAreaName,(X+1),Tot);
      If YeaNa(MyStr^.MsgDelPrompt,False) Then
      Begin
        MHdr.Deleted:=True;
        DelMsg(0,MHdr,Msg,CurConf,CurMsgAreaName,X);
        PrintLn('Message Deleted');
      End;
    End else MCiPrintln('|12Message doesn''t belong to you...');
  End;
End;

Procedure PurgeOldMsgs;
Var X:Byte;
   TmpF:File Of MsgTxt;
   TmpX:File Of MsgHdr;
   TF:MsgTxt;
   TX:MsgHdr;
Begin
  Print('Purging old messages.');
  While (Not EOF(TmpX)) Do
  Begin
    Read(TmpX,TX);
    If (Not TX.Deleted) Then Write('.');
  End;
  Close(TmpX);
  Close(TmpF);
End;

Procedure PostMessage;
Var Chk:Integer;
Begin
  FillChar(MHdr,Sizeof(Mhdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  FillChar(QHdr,Sizeof(Qhdr),#0);
  FillChar(QMsg,Sizeof(QMsg),#0);
  If GetAccess(CurArea.PostFlags) Then
  Begin
    WriteHdr('Post Message');
    With MHdr Do
    Begin
      SendTo:=Prompt(25,MyStr^.PostToPrompt,False);
      If Length(SendTo)=0 Then SendTo:=MyStr^.ToAllStr;
      If CurArea.Priv Then 
      Begin
        OpenUFiles(CurUFile);
        FindUser(SendTo,Chk);
        CloseUFiles;
        If Chk=-1 Then Exit;
      End;
      Title:=Prompt(40,MyStr^.TitlePrompt,False);
      If Length(Title)=0 Then Exit;
      Anon:=YeaNa(MyStr^.Anonprompt,False);
      MsgType:=0;
      From:=Urec^.Handle;
      If IsSysOp Then 
      Begin
        From:=EditPrompt(25,'Post As |08(|03CR|01/|11'+From+'|08)|RE: ');
        Println('');
        If Length(Input)>0 Then From:=Input Else From:=Urec^.Handle;
      End;
      RealName:=Urec^.RealName;
      Deleted:=False;
    End;
    If PostMsg(0,False) Then 
    Begin
      Inc(Urec^.Posts);
      Println('Message Saved!');
      WriteMArea;
      If NumMsgs(0,CurConf,CurMsgAreaName,False)>=CurArea.MaxMsgs Then
      Begin
        Println('Auto Deleting First '+Strr(CurArea.NumToDel)+' Messages');
        AutoDelete(0,CurConf,CurMsgAreaName,CurArea.NumToDel);
      End;
    End Else Println('Message Aborted!');
  End 
   Else MCiPrintln('|12You don''t have access to post here!|RE');
End;

Procedure ReplyMessage(ID:LongInt);
Begin
  If GetAccess(CurArea.PostFlags) Then
  Begin
    WriteHdr('Reply To Message');
    QMsg:=Msg;
    QHdr:=MHdr;
    With MHdr Do
    Begin
      If MHdr.Anon Then SendTo:=MyStr^.AnonymousStr else SendTo:=From;
      MCIWrite(MyStr^.PostToPrompt);
      Edit(SendTo,WhereX,WhereY,25,False); Println('');
      If Pos('Re:',Title)<>1 Then Title:='Re: '+Title;
      MCIWrite(MyStr^.TitlePrompt);
      Edit(Title,WhereX,WhereY,40,False); Println('');

      Anon:=YeaNa(MyStr^.Anonprompt,False);
      MsgType:=0;
      From:=Urec^.Handle;
      If IsSysOp Then 
      Begin
        MCIWrite('Reply As |08(|03CR|01/|11'+From+'|08)|RE: ');
        Edit(From,WhereX,WhereY,25,False);
        Println('');
        {If Length(Input)>0 Then From:=Input Else From:=Urec^.Handle;}
      End;
      RealName:=Urec^.RealName;
      NumRead:=0;
      NumReply:=0;
      Deleted:=False;
      Back:=ID;
    End;
    If PostMsg(0,False) Then UpDateMsg(0,MHdr,CurConf,CurMsgAreaName,ID,False,True);
  End Else MCiPrintln('|12You don''t have access to post here!|RE');
End;

Procedure EditMessage;
Var ID:LongInt;
Begin
  WriteHdr('Edit Message');
  ID:=Valu(Prompt(5,'Edit which message: ',False));
  If ID=0 Then Exit;
  LoadMsg(0,MHdr,Msg,CurConf,CurMsgAreaName,ID-1);
  With MHdr Do
  Begin
    MCiPrint(MyStr^.PostToPrompt);
    Edit(SendTo,WhereX,WhereY,25,False);
    Println('');

    MCiPrint(MyStr^.TitlePrompt);
    Edit(Title,WhereX,WhereY,40,False);
    Println('');

    Anon:=YeaNa(MyStr^.Anonprompt,False);
    MsgType:=0;
    From:=Urec^.Handle;
    If IsSysOp Then 
    Begin
      MCiPrint('Post As |08(|03CR|01/|11'+From+'|08)|RE: ');
      Edit(From,WhereX,WhereY,25,False);
      Println('');
    End;
    RealName:=Urec^.RealName;
    NumRead:=0;
    NumReply:=0;
    Deleted:=False;
    Back:=ID;
  End;
  If EditMsg(0) Then UpDateMsg(0,MHdr,CurConf,CurMsgAreaName,ID-1,False,True);
End;

Function GotoMessage:LongInt;
Var X,St,Tot,Tot2:Integer;
Begin
  Tot:=NumMsgs(0,CurConf,CurmsgAreaName,False);
{  Tot:=CurArea.NumPosts;}
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
   Choice[1]:=' Next ';  HighChr[1]:=1;
   Choice[2]:=' Reply '; HighChr[2]:=1;
   Choice[3]:=' Again '; HighChr[3]:=1;
   Choice[4]:=' Back ';  HighChr[4]:=1;
   Choice[5]:=' Skip ';  HighChr[5]:=1;
   Choice[6]:=' Goto ';  HighChr[6]:=1;
   Choice[7]:=' Post ';  HighChr[7]:=1;
   Choice[8]:=' E-Mail ';HighChr[8]:=1;
   Choice[9]:=' Thread ';HighChr[9]:=1;
   If IsSysOp Then 
   Begin 
     Choice[10]:=' Other '; HighChr[10]:=1;
     Choice[11]:=' Quit ';  HighChr[11]:=1;
     NumChoices:=11;
     KeyCmds:='NRABSGPETOQ?';
   End
  Else
   Begin
     Choice[10]:=' Quit '; HighChr[10]:=1;
     NumChoices:=10;
     KeyCmds:='NRABSGPETQ?';
   End;
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
   Choice[1]:=' Edit ';       HighChr[1]:=1;
   Choice[2]:=' Remove ';     HighChr[2]:=1;
   Choice[3]:=' Forward ';    HighChr[3]:=1;
   Choice[4]:=' Download ';   HighChr[4]:=1;
   Choice[5]:=' Grab ';       HighChr[5]:=1;
   Choice[6]:=' Quit ';       HighChr[6]:=1;
   If IsSysOp Then
   Begin
     Choice[6]:=' Move ';     HighChr[6]:=1;
     Choice[7]:=' Quit ';     HighChr[7]:=1;
     NumChoices:=7;
     KeyCmds:='ERFDGMQ?';
     DefChoice:=1;
   End
  Else
   Begin
     NumChoices:=6;
     KeyCmds:='ERFDGQ?';
     DefChoice:=1;
   End;
 End;

 OtherMenuBar:=BarMenu(MenuBarz^);
 Dispose(Menubarz);
End;

Function CanRead(Too:Str25):Boolean;
Begin
  If CurArea.Priv Then
  Begin
    If Match(Urec^.Handle,Too) Then CanRead:=True Else CanRead:=False;
  End Else CanRead:=True;
End;

Procedure ReadMessages;
Var St,Tot,Tot2:Integer;
    UCnt,X:LongInt;
    Quit,Next:Boolean;
Begin
  WriteHdr('Read Message');
  Tot:=NumMsgs(0,CurConf,CurmsgAreaName,True);
  Tot2:=NumMsgs(0,CurConf,CurmsgAreaName,IsSysOp);
  If (Tot2=0) and (Tot=0) Then Println('No Messages!')
 Else
  Begin
    St:=1;
    Range(St,Tot2); Dec(St); Dec(Tot);
    UCnt:=St;
    For X:=St To Tot Do 
    Begin
      If UCnt=Tot2 Then Exit;
      LoadMsg(0,MHdr,Msg,CurConf,CurMsgAreaName,X); 
      Next:=False;
      If (CanRead(MHdr.SendTo) and (Not (MHdr.Deleted))) or (IsSysOp) Then 
      Begin
        Inc(UCnt);
        Repeat
          ReadMsg(0,CurConf,CurMsgAreaName,X,UCnt,Tot2,False);
          Case MsgMenuBar('Read Messages') Of
            'Q':Exit;
            'R':ReplyMessage(x);
            'N':Next:=True;
            'G':X:=GotoMessage;
            'P':PostMessage;
            'A':;
            'S':Exit;
            'O':Begin  
                  Repeat
                    Case OtherMenuBar('+Read Messages') Of
                      'Q':Quit:=True;
                    End;
                  Until Quit;
                End;
            'B':If UCnt>0 Then Dec(UCnt); 
          End;
        Until Next;
      End;
    End;
  End;
End;

Procedure NewScanArea;
Var Tot:Integer;
    UCnt,Cnt:LongInt;
    Quit,Next:Boolean;
    Scanned:Boolean;
Begin
  Scanned:=False;
  Tot:=NumMsgs(0,CurConf,CurMsgAreaName,True);
  If Tot=0 Then Println('No Messages!')
 Else
  Begin
    UCnt:=0;
    For Cnt:=0 to Tot-1 do
    Begin
       UCnt:=Cnt;
        LoadMsg(0,MHdr,Msg,CurConf,CurMsgAreaName,Cnt); 
        If IsNew(0,MHdr,CurConf,CurMsgAreaName) Then 
        Begin

          Next:=False;
          If (CanRead(MHdr.SendTo) and (Not (MHdr.Deleted))) or (IsSysOp) Then 
          Begin
            Inc(UCnt);
            Repeat
              Scanned:=true;
              ReadMsg(0,CurConf,CurMsgAreaName,Cnt,UCnt,Tot,True);
              Case MsgMenuBar('Newscan Messages') Of
              'Q':Begin QuitNewScan:=True; Exit; End;
              'R':ReplyMessage(Cnt);
              'N':Next:=True;
              'G':Cnt:=GotoMessage;
              'P':PostMessage;
              'A':; 
              'S':Exit;
              'O':Begin
                    Quit:=False;
                    Repeat
                      Case OtherMenuBar('+Read Messages') Of
                       'Q':Quit:=True;
                      End;
                    Until Quit;
                  End;
              'B':If Cnt>0 Then Dec(Cnt);
            End;
          Until Next;
        End;
      End;
    End;
  End;
  If Scanned then If YeaNa(MyStr^.PostPrompt,False) Then PostMessage;
End;

Procedure MsgNewScanAll;
Var X:Integer;
Begin
  Cls;
  MCiWriteln(MyStr^.NewScanHdrMsg);
  QuitNewScan:=False;
  For X:=1 to NumAreas Do
  Begin
    If (Not QuitNewScan) Then
    Begin
      SetMArea(X,True);
      NewScanArea;
    End;
  End;
  SetMArea(1,True);
End;

Begin
End.
