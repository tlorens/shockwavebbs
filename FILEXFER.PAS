{
  iB * 08/04/96 - ShockWavE:PRO File Section
}

{$I+,D-,L-}
Unit FileXfer;

Interface

Uses OpCrt,DOS,Records,Vars,IO,GenSubs,User,CnfgRec,Display,Misc,FSubs;

Procedure XAreaEditScr(Add:Boolean);
Procedure XAreaHdr(Area,Descp,Files,Cmd:Str80);
Procedure AddXArea;
Procedure SetXArea(N:Byte; NewScan:Boolean);
Procedure AddFile(S:String; Mass:Boolean);
Procedure ManAddFiles;
Procedure MassAddFiles;
Procedure RemoveFile;
Procedure ListXAreas;
Procedure SelectXArea;
Procedure ListFiles;
Procedure OpenXFiles;
Procedure CloseXFiles;
Procedure ListBatch;
Procedure RemoveFromBatch;
Procedure ClearBatch;
Procedure DownLoad(P1:String);
Procedure UpLoad(P1:String);
Procedure FNewScanArea;
Procedure FNewScanAll;
Procedure NextFArea;
Procedure PrevFArea;

Implementation

Var
    FArea:File Of FAreaRec;
    CurXArea:FAreaRec;

    FList:File Of FFileRec;
    List:FFilerec;
    XAreaFPos:Integer;

    BatchFile:File Of BatchRec;
    BatchItem:BatchRec;
{
    FAREA[conf].DAT
     FAREA001.DAT
}
Procedure AssignF;
Var S:Str80;
Begin
  S:=CNF^.UploadDIR+'FAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  Assign(FArea,S);
End;

Procedure CloseXFiles;
Begin
  Close(FArea);
End;

{
    FFILE[Area].Conf
    FFILE 001  .001
}
Procedure AssignList;
Var S:Str80;
Begin
  S:=CNF^.UploadDIR+'FFILE'+PadRight(Strr(CurFileArea),3,'0')+'.'+PadRight(Strr(CurConf),3,'0');
  Assign(FList,S);
  If (Not Exist(S)) Then
  Begin
    Rewrite(FList);
    Close(Flist);
    Assign(Flist,S);
  End;
End;

Procedure OpenXfiles;
Begin
  AssignF; Reset(FArea);
End;

Procedure CheckFiles;
Var S:Str80;
Begin
  S:=CNF^.UploadDIR+'FAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  If Not Exist(S) Then
  Begin
    AssignF; ReWrite(FArea);
    CloseXFiles;
    AddXArea;
  End
End;

Procedure WriteXArea;
Begin
  OpenXFiles;
  Seek(Farea,XAreaFPos);
  Write(FArea,CurXArea);
  CloseXFiles;
End;

Procedure WriteNewXArea;
Begin
  OpenXFiles;
  Seek(Farea,FileSize(FArea));
  Write(FArea,CurXArea);
  CloseXFiles;
End;

Procedure ReadXArea;
Begin
  Read(FArea,CurXArea);
  XAreaFPos:=FilePos(FArea)-1;
End;

Procedure SeekXArea(N:Byte);
Begin
  Seek(FArea,N-1);
End;

Function NumXAreas:Integer;
Begin
  CheckFiles;
  OpenXFiles;
  NumXAreas:=FileSize(FArea);
  CloseXFiles;
End;

Function NumFiles:Integer;
Begin
  CheckFiles;
  OpenXFiles;
  NumFiles:=FileSize(FList);
  CloseXFiles;
End;

Function FindFile(S:String; All:Boolean):String;

  Procedure JustOnce;
  Begin
    AssignList;
    Reset(FList);
    While (Not EOF(FList)) Do
    Begin
      Read(FList,List);
      If Match(List.FileName,S) Then
      Begin
        FindFile:=List.Path;
        Close(Flist);
        Exit;
      End Else FindFile:='';
    End;
    Close(Flist);
  End;

Begin
  If All Then
  Begin
    OpenXFiles;
    While (Not Eof(FArea)) Do
    Begin
      Read(FArea,CurXArea);
      If GetAccess(CurXArea.Flags) Then JustOnce;
    End;
    CloseXFiles;
  End
 Else
  JustOnce;
End;

Procedure AddToBatch(P:Str80; F:Str25; C,M:Integer; S:LongInt);
Begin
  Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
  If Exist(CNF^.WorkDir+'BATCH.'+Strr(Node)) Then
  Begin
    Reset(BatchFile);
    Seek(BatchFile,FileSize(BatchFile));
  End Else ReWrite(BatchFile);
  With BatchItem Do
  Begin
    Path :=P;
    From :=F;
    Cost :=C;
    Mins :=M;
    Size :=S;
  End;
  Write(BatchFile,BatchItem);
  Close(BatchFile);
End;

Procedure ListBatch;
Begin
  If Exist(CNF^.WorkDir+'BATCH.'+Strr(Node)) Then
  Begin
    CntB:=0;
    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    ReSet(BatchFile);
    While (Not Eof(BatchFile)) Do
    Begin
      Read(BatchFile,BatchItem);
      If Length(BatchItem.Path)>0 Then
      Begin
        Inc(CntB);
        With BatchItem Do
        Begin
          Print(TabStr(Strr(CntB),3));
          Print(TabStr(RemovePath(Path),15));
          Print(TabStr(CalcFSize(Size),4));
          Println(Strr(Cost));
        End;
      End Else Println('oopsie');
    End;
    Close(BatchFile);
  End;
End;

Procedure RemoveFromBatch;
Var Del:Byte;

  Procedure Packlist;
  Var Tmp:File Of BatchRec;
  Begin
    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    Reset(BatchFile);

    Assign(Tmp,CNF^.WorkDir+'BATCH.X'+Strr(Node));
    ReWrite(Tmp);

    While (Not Eof(BatchFile)) Do
    Begin
      Read(BatchFile,BatchItem);
      If Length(BatchItem.Path)>0 Then Write(Tmp,BatchItem);
    End;
    Close(Tmp);
    Close(BatchFile);

    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    Erase(BatchFile);

    Assign(Tmp,CNF^.WorkDir+'BATCH.X'+Strr(Node));
    Rename(Tmp,'BATCH.'+Strr(Node));
  End;

Begin
  Input:=Prompt(1,'Remove which file: ',False);
  If (Length(Input)=0) Or (Valu(Input)=0) Then Exit;
  Del:=Valu(Input);
  If Exist(CNF^.WorkDir+'BATCH.'+Strr(Node)) Then
  Begin
    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    Reset(BatchFile);
    FillChar(BatchItem,SizeOf(BatchItem),#0);
    Seek(BatchFile,Del-1);
    Write(BatchFile,BatchItem);
    Close(BatchFile);
  End;
  PackList;
End;

Procedure ClearBatch;
Begin
  If Exist(CNF^.WorkDir+'BATCH.'+Strr(Node)) Then
  Begin
    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    Erase(BatchFile);
  End;
End;

Procedure MoveBatch;
Begin
End;

Procedure ExportBatch;
var T:Text;
Begin
  If Exist(CNF^.WorkDir+'BATCH.'+Strr(Node)) Then
  Begin
    Assign(BatchFile,CNF^.WorkDir+'BATCH.'+Strr(Node));
    Reset(BatchFile);

    Assign(T,CNF^.WorkDir+'DOWNLOAD.'+Strr(Node));
    ReWrite(T);

    While (Not EOF(BatchFile)) Do
    Begin
      Read(BatchFile,BatchItem);
      If Length(BatchItem.Path)>0 Then Writeln(T,BatchItem.Path);
    End;
    Close(T);
    Close(BatchFile);
  End;
End;

Function ValidFName (N:Str10):Boolean;
Begin
  ValidFname:=False;
  If (length(n)=0) or (length(n)>8) then exit;
  For CntI:=1 To Length(n) Do If Not (upcase(n[cntI]) in ['0'..'9','A'..'Z']) Then Exit;
  ValidFname:=True
End;

Procedure WriteXEditor;
Begin
  Cls;
  Println('');
  MCiPrintln('|CM  File Area Configuration ');
  MCiPrintln('|BXÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸');
  MCiPrintln('|BX³ |MS[|INN|MS]|ISame            |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|IND|MS]|ISescription     |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INP|MS]|ISath            |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INS|MS]|ISub-Op          |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INW|MS]|IS Password      |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INA|MS]|ISccess Flags    |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|IN+|MS]|IS Upload        |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|IN-|MS]|IS Download      |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INX|MS]|IS Download Flag |BX³                                                         ³');
  MCiPrintln('|BX³ |MS[|INU|MS]|ISpload Flags    |BX³                                                         ³');
  MCiPrintln('|BXÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾');
  MCiPrintln('                                                                       |MS(|INQ|MS)|PRuit  ');
  AColor(Urec^.StatColor);
  With CurXArea do
  Begin
    Printxy(23,4,Area);
    PrintXy(23,5,Description);
    PrintXy(23,6,Path);
    PrintXy(23,7,SubOp);
    PrintXy(23,8,Password);
    PrintXy(23,9,Flags);
    If Upload=true then PrintXy(23,10,'Yes') else PrintXy(23,10,'No');
    If Download=True then printxy(23,11,'Yes') else PrintXy(23,11,'No');
    PrintXy(23,12,DownFlag);
    PrintXy(23,13,UpFlag);
  End;
End;

Procedure XAreaEditScr(Add:Boolean);
Var GG:Char;

  Procedure BoardName;
  Begin
    Edit(CurxArea.Area,23,4,25,False);
    BackSpace(23,4,Length(CurXArea.Area));
    PrintXy(23,4,CurXArea.Area);
   End;

  Procedure GetSponsor;
  Begin
    Edit(CurxArea.SubOp,23,7,25,False);
    BackSpace(23,7,Length(CurXArea.SubOp));
    PrintXy(23,7,CurXArea.SubOp);
  End;

   Procedure Uploads;
   Begin
     If CurXArea.Upload=True then BackSpace(23,10,3) Else BackSpace(23,10,2);
     CurXArea.Upload:=not CurXArea.Upload;
     If CurXArea.Upload=true then PrintXy(23,10,'Yes') else PrintXy(23,10,'No');
   End;

   Procedure Downloads;
   Begin
     If CurXArea.DownLoad=True then BackSpace(23,11,3) Else BackSpace(23,11,2);
     CurXArea.DownLoad:=not CurXArea.DownLoad;
     If CurXArea.DownLoad=True then printxy(23,11,'Yes') else PrintXy(23,11,'No');
   End;

   Procedure AreaPassword;
   Begin
     Edit(CurxArea.Password,23,8,25,False);
     BackSpace(23,8,Length(CurXArea.Password));
     PrintXy(23,8,CurXArea.Password);
   End;

  Procedure AccessLevel;
  begin
    Edit(CurxArea.Flags,23,9,25,False);
    BackSpace(23,9,Length(CurXArea.Flags));
    PrintXy(23,9,CurXArea.flags);
  End;

  Procedure AreaDesc;
  Begin
    Edit(CurxArea.Description,23,5,25,False);
    BackSpace(23,5,Length(CurXArea.Description));
    PrintXy(23,5,CurXArea.Description);
  End;

  Procedure DownloadFlags;
  Begin
    Edit(CurxArea.DownFlag,23,12,25,False);
    BackSpace(23,12,Length(CurXArea.DownFlag));
    PrintXy(23,12,CurXArea.DownFlag);
  End;

  Procedure UploadFlags;
  Begin
    Edit(CurxArea.UpFlag,23,13,25,False);
    BackSpace(23,13,Length(CurXArea.UpFlag));
    PrintXy(23,13,CurXArea.UpFlag);
  End;

  Procedure AreaPath;
  begin
    Edit(CurxArea.Path,23,6,40,False);
    If Length(CurXArea.Path)>1 then If CurXArea.Path[Length(CurXArea.Path)]<>'\' Then
    CurXArea.Path:=CurXArea.Path+'\';
    BackSpace(23,6,Length(CurXArea.Path));
    PrintXy(23,6,CurXArea.Path);
  end;

Begin
  WriteXEditor;
  Repeat
    Repeat
      GetChar(GG);
      If Length(GG)=0 then GG:=' '; GG:=Upcase(GG);
    Until (Pos(GG,'NPWSAUXD-+Q') >0) OR HungUpOn;
    Case GG of
      'N':BoardName;
      'D':AreaDesc;
      'P':AreaPath;
      'W':AreaPassword;
      'S':GetSponsor;
      'A':AccessLevel;
      '+':Uploads;
      '-':Downloads;
      'X':DownLoadFlags;
      'U':UploadFlags;
      'Q':;
     End;
  Until (GG='Q') or HungupOn;

  GoXy(1,23);
  If YeaNa('Save Changes: ',True) Then
  Begin
    Case Add of
       False:WriteXArea;
        True:WriteNewXArea;
    End;
  End;
End;

Procedure AddXArea;
Begin
  FillChar(CurXArea,SizeOf(CurXArea),#0);
  FillChar(List,SizeOf(List),#0);

  With CurXArea Do
  Begin
    Area:='New';
    SubOp:=URec^.Handle;
    Description:='New File Area';
    Path:='';
    Password:='';
    Upload:=False;
    Download:=True;
    Flags:='(x1)';
    DownFlag:='(x1)';
    UpFlag:='(x100)';
    NumFiles:=0;
  End;
  XAreaEditScr(True);
End;

Procedure DeleteArea;

  Procedure PackAreas;
  Var Tmp:File Of FAreaRec;
        S:String;
  Begin
    S:=CNF^.UploadDIR+'FAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
    Assign(Tmp,CNF^.UploadDIR+'TMP$$$.$$$');
    ReWrite(Tmp);

    SeekXArea(1);
    While Not EOF(FArea) do
    Begin
      ReadXArea;
      If Length(CurXArea.Area)>0 then Write(Tmp,CurXArea);
    End;
    CloseXfiles; Close(Tmp);
    OpenXfiles;  Assign(Tmp,CNF^.UploadDIR+'TMP$$$.$$$');
    Erase(FArea);
    Rename(Tmp,S);
  End;

Begin
  If NumXAreas>0 then
  Begin
    FillChar(CurXArea,SizeOf(CurXArea),0);
    SeekXArea(CurFileArea);
    WriteXArea;
    PackAreas;
    {SetXArea(1);}
  End;
End;

Procedure XAreaHdr(Area,Descp,Files,Cmd:Str80);
Var Txt:Text;
    Ch:Char;
    Chk:String[2];
    Cnt:Word;

Begin
  If Not Exist(CNF^.MenuDir+'XAREAHDR.ANS') then
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
    AColor(Urec^.StatColor);
    AColor(15);
    PrintXY(24,7,'Area Name: '+Area);
    PrintXY(24,8,'Description: '+Descp);
    Println(^M^M^M);
  End
Else
 Begin
    If Not Exist(CNF^.MenuDir+Cmd+'.HDR') Then
    Begin
      Assign(Txt,CNF^.MenuDir+'XAREAHDR.ANS');
      Reset(Txt);
      While (Not EOF(Txt)) and (Not HungUpOn) Do
      Begin
        Read(Txt,Ch);
        If Ch='|' Then
        Begin
          Read(Txt,Ch); Chk:=Ch;
          Read(Txt,Ch); Chk:=Chk+Ch;
          If Chk='AN' then Print(Area) else
          If Chk='DE' Then Print(Descp) else
          If Chk='NF' Then Print(Files) else
          If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
          If Chk='HA' Then Print(Urec^.Handle) Else
          If Chk='TI' Then Print(TimeStr(Now)) Else
          If Chk='DA' Then Print(DateStr(Now)) Else
          If Chk='SY' Then Print(CNF^.FullSysName) Else
          If Chk='TL' Then Print(Strr(Urec^.TimeLeft)) Else
          { Add Sub-Op Name here }
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
          If Chk='NF' Then Print(Files) else
          If Chk[1]='~' then Delay(Valu(Chk[2])*1000) Else
          If Chk='HA' Then Print(Urec^.Handle) Else
          If Chk='TI' Then Print(TimeStr(Now)) Else
          If Chk='DA' Then Print(DateStr(Now)) Else
          If Chk='SY' Then Print(CNF^.FullSysName) Else
          If Chk='TL' Then Print(Strr(Urec^.TimeLeft)) Else
        End Else Print(Ch);
      End;
      Close(Txt);
    End;
 End;
End;

Procedure SetXArea(N:Byte; NewScan:Boolean);
Begin
  If (N > NumXAreas) Or (N <= 0)Then
  Begin
    MCiWriteln(MyStr^.InvalidMsgArea);
    If IsSysOp then MCiWriteln(MyStr^.NoFiles);
    Exit;
  End
 Else
  Begin
    OpenXFiles;
    SeekXArea(N);
    ReadXArea;
    CloseXFiles;
    If (Not GetAccess(CurXArea.Flags)) Then Exit;
    CurFileArea:=N;
    CurFileAreaName:=CurXArea.Area;
  End;
  With CurXArea Do XAreaHdr(Area,Description,Strr(NumFiles),SubOp);
End;

Procedure NextFArea;
Begin
  Inc(CurFileArea);
  If CurFileArea<=NumXAreas Then SetXArea(CurFileArea,False) Else Dec(CurFileArea);
End;

Procedure PrevFArea;
Begin
  Dec(CurFileArea);
  If CurFileArea>0 Then SetXArea(CurFileArea,False) Else Inc(CurFileArea);
End;

Procedure AddFile(S:String; Mass:Boolean);
Var FS:File Of Byte;
Begin
  If (Not Mass) Then
  Begin
    Input:='';
    AColor(15);
    If Length(S)=0 Then Input:=Prompt(25,'Path\FileName: ',False) Else Input:=S;
    If (Length(Input)=0) then Exit;
    If Exist(Input) Then
    Begin
      With List Do
      Begin
        From      :=Urec^.Handle;
        When      :=Now;
        WhenRated :=Now;
        Filename  :=UpString(RemovePath(Input));
        Path      :=UpString(Input);

        Assign(FS,Path);
        Reset(FS);
        FSize:=(FileSize(FS) div 1024);
        Close(FS);

        Input     :=Prompt(5,'File Value: ',False);
        Points    :=Valu(Input);
        Description:=Prompt(40,'Single Line Description: ',False);
       {Desc           :Array[1..10] of Str40;} {Search for .DIZ}
        Downloaded     :=0;
        SendTo         :=Prompt(25,'Send To: ',False);
        PassWord       :=Prompt(25,'File Password: ',False);
        NewFile        :=False;
        SpecialFile    :=YeaNa('Mark as Special: ',False);
        Aborted        :=False;
        Crashed        :=False;
      End;
      AssignList;
      Reset(FList);
      Seek(FList,FileSize(FList));
      Write(FList,List);
      Close(FList);
      If IOResult=0 Then
      Begin
        Println('File added.');
        Inc(CurXArea.NumFiles);
        WriteXArea;
      End;
    End
   Else Println('File not found.');
  End
 Else
  Begin
    With List Do
    Begin
      From      :=Urec^.Handle;
      When      :=Now;
      WhenRated :=Now;
      Filename  :=Input;
      Path      :=CurXArea.Path;
      Points    :=0;
      Assign(FS,Input);
      FSize     :=FileSize(FS);
      Close(FS);
      Description:=''; {use 1st line in DIZ}
      {Desc           :Array[1..10] of Str40;} {Search for .DIZ}
      Downloaded     :=0;
      SendTo         :='';
      PassWord       :='';
      NewFile        :=True;
      SpecialFile    :=False;
      Aborted        :=False;
      Crashed        :=False;
    End;
    Write(FList,List);
    Close(Flist);
    If IOResult=0 Then Println('File added.');
 End;
End;


Procedure ManAddFiles;
Var DirInfo:SearchRec;
    Cmd:Char;
    MBar:MenuBarRec;

Procedure Setupbar;
Begin
  With MBar Do
  Begin
    MenuName    :='Add File';
    NumChoices  :=5;
    Choice[1]   :=' Yes ';
    Choice[2]   :=' No ';
    Choice[3]   :=' View ';
    Choice[4]   :=' Delete ';
    Choice[5]   :=' Quit ';
    DefChoice   :=1;
    BarX        :=WhereX;
    BarY        :=WhereY;
    KeyCmds     :='YNVDQ';
  End;
End;

Begin
  Input:=UpString(CurXArea.Path);
  Println('--- Manual File Adding ---');
  Edit(Input,WhereX,WhereY,40,False); Println('');
  If Length(Input)=0 Then Exit;
  Input:=Input+'\';
  FindFirst(Input+'*.*',AnyFile,DirInfo);
  Setupbar;
  While DOSError=0 Do
  Begin
    Case BarMenu(MBar) Of
     'Y':AddFile(Input+DirInfo.Name,False);
     'N':;
     'V':;{view archive}
     'D':;{delete file}
     'Q':Exit;
    End;
    FindNext(DirInfo);
  End;
End;

Procedure MassAddFiles;
Var DirInfo:SearchRec;
Begin
  Input:=UpString(CurXArea.Path);
  Println('--- Mass File Adding ---');
  Edit(Input,WhereX,WhereY,40,False); Println('');
  If Length(Input)=0 Then Exit;
  If Input[Length(Input)]<>'\' Then Input:=Input+'\';
  FindFirst(Input+'*.*',AnyFile,DirInfo);
  While DOSError=0 Do
  Begin
    AddFile(Input+DirInfo.Name,True);
    FindNext(DirInfo);
  End;
End;

Procedure RemoveFile;
Begin
End;

Procedure ListXAreas;
Var FCnt:Integer;
    Chrs:String[2];
    TXF:Text;
    K:Char;

Begin
  CntI:=0;
  FCnt:=0;

  If Exist(CNF^.MenuDir+'FILEAREA.TOP') Then PrintFile(CNF^.MenuDir+'FILEAREA.TOP') Else
  Begin
    Cls;
 {  Println('      #     File Area                    Level        # Of Files         ');}
    Println('      #     File Area                    Level                           ');
    Println(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Println('ÛÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    Println('ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  ');
  End;

  OpenXFiles;
  While (Not Eof(FArea)) Do
  Begin
    Read(FArea,CurXArea);
    If GetAccess(CurXArea.Flags) Then
    Begin
      Inc(CntI);
      If Exist(CNF^.MenuDir+'FILEAREA.MID') Then
      Begin
        Assign(TXF,CNF^.MenuDir+'FILEAREA.MID');
        Reset(TXF);
        Chrs:='';
        While (Not eof(TXF)) and (NOT hungupon) do
        Begin
          Read(TXF,K);
          If K='|' Then
          Begin
            Read(TXF,K); Chrs:=K;
            Read(TXF,K); Chrs:=Chrs+K;
            If Chrs='FA' Then Tab(Strr(CntI),3) Else
            If Chrs='AR' Then Tab(CurXArea.Area,25) Else
{           If Chrs='LV' Then Tab(CurXArea.Level),5) Else }
            If Chrs='DE' Then Tab(CurXArea.Description,25) Else
            If Chrs='SO' Then Tab(CurXArea.SubOp,25);
          End Else Print(K);
        End;
        Close(TXF);
      End
     Else
      Begin
        Print('      '); Tab(strr(cntI),4);
        Print('  ');     Tab(CurXArea.Area,28);
      { Print(' ');      Tab(strr(CurXArea.level),12); }
      { Println(Strr(A.NumFiles)); }
        Println('');
      End;
    End;
  End;
  CloseXFiles;

   If Exist(CNF^.MenuDir+'FILEAREA.BOT') Then PrintFile(CNF^.MenuDIR+'FILEAREA.BOT') Else
   Begin
    Println(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Println('ÛÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    Println('ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  ');
  End;
End;

Procedure SelectXArea;
Begin
  Println(^M);
  If NumXAreas>0 Then
  Begin
    Repeat
      Input:='';
      Input:=Prompt(10,MyStr^.FileAreaPrompt,False);
      If (Length(Input)=0) Then Exit;
      If Input[1]='?' Then ListXAreas;
    Until Input[1]<>'?';
    SetXArea(Valu(Input),False);
   End
  Else
   Begin
     MCIWriteLn(MyStr^.InvalidMsgArea);
     If IsSysOp Then MCiWriteln(MyStr^.NoFiles);
   End;
End;

Function XferMenuBar(Title:String):Char;
Var UCh:Char;
Begin
 New(MenuBarz);
 With MenuBarz^ Do
 Begin
   MenuName:=Title+' - (?/Help)';
   Choice[1]:=' Next ';       HighChr[1]:=1;
   Choice[2]:=' Tag ';        HighChr[2]:=1;
   Choice[3]:=' Download ';   HighChr[3]:=1;
   Choice[4]:=' View ';       HighChr[4]:=1;
   Choice[5]:=' Archive ';    HighChr[5]:=1;
   Choice[6]:=' Info ';       HighChr[6]:=1;
   Choice[7]:=' Quit ';       HighChr[7]:=1;
   NumChoices:=7;
   KeyCmds:='NTDVAIQ?';
   DefChoice:=1;
 End;

 XferMenuBar:=BarMenu(MenuBarz^);
 Dispose(Menubarz);
End;


Procedure ListFiles;

Var LCnt:Byte;
    TempList:Array[1..24] Of BatchRec;
    TagLtr:String[25];
    Next,Done:Boolean;

  Procedure TagFile;
  Var P:Byte;
  Begin
    Input[0]:=#0;
    Input:=Prompt(1,'Tag which file: ',False);
    If Length(Input)>0 Then
    Begin
      P:=Pos(UpCase(Input[1]),TagLtr);
      AddToBatch(TempList[P].Path,
                 TempList[P].From,
                 TempList[P].Cost,
                 0,
                 TempList[P].Size);
    End;
  End;
              
Begin
  Done:=False;
  TagLtr:='ABCDEFGHIKLMNOPQRSTUVWXYZ';
  If CurXArea.NumFiles>0 Then
  Begin
  If Exist(CNF^.MenuDir+'FILELIST.TOP') Then PrintFile(CNF^.MenuDir+'FILELIST.TOP') Else
  Begin
    Cls;
    MCiPrintln('|03 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    MCiPrintln('|08Û|03ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    MCiPrintln('|08ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß|07');
  End;

  AssignList;
  ReSet(FList);
  LCnt:=1;
  FillChar(TempList,SizeOf(TempList),#0);

  While (Not EOF(FList)) and (Not Done) Do
  Begin
    Next:=False;
    Read(FList,List);
    With List Do 
    Begin
      TempList[LCnt].Path:=List.Path;
      TempList[LCnt].From:=List.From;
      TempList[LCnt].Cost:=List.Points;
      TempList[LCnt].Size:=List.FSize;

      Print(TagLtr[LCnt]+' ');
      If Urec^.FileList[1] Then Print(TabStr(FileName,13));
      If Urec^.FileList[2] Then Print(TabStr(CalcFSize(FSize),5));
      If Urec^.FileList[3] Then Print(TabStr(Strr(Points),5));
      If Urec^.FileList[4] Then Print(TabStr(Strr(Downloaded),4));
      If Urec^.FileList[5] Then Print(TabStr(From,25));
      If Urec^.FileList[6] Then Print(TabStr(DateStr(When),10));
      If Urec^.FileList[7] Then Print(Copy(Description,1,35));
      If Urec^.FileList[8] Then Print('FILE_ID.DIZ');
    End;

    Println('');
    Inc(LCnt);
    If (LCnt=23) Or (Eof(FList)) Then 
    Begin
      Println('');
      Repeat
        SaveXY;
        Case XferMenuBar('File') Of
          'N':Begin
                Next:=True;
                LCnt:=0;
                FillChar(TempList,SizeOf(TempList),#0);
              End;
          'Q':Done:=Not Done;
          'T':TagFile;
          'D':;
          'A':;
          'I':;
          'V':;
        End;
        RestoreXY;
      Until Next or Done;
    End;
  End;
  Close(Flist);

  If Exist(CNF^.MenuDir+'FILELIST.BOT') Then PrintFile(CNF^.MenuDir+'FILELIST.BOT') Else
    MCiPrintln('|08ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  End Else MCiPrintln('No files in this area...');
End;

Function SelectFile:String;
Begin
  Input:='';
  Print('File name to download: '); Edit(Input,WhereX,WhereY,12,False); Println('');
  SelectFile:=FindFile(Input,YeaNa('Search All areas: ',False));
End;

Procedure Upload(P1:String);
Var FS:File;
Begin
  Input:='';
  Print('File name to upload: '); Edit(Input,WhereX,WhereY,12,False); Println('');
  If (Length(FindFile(Input,True))=0) Then
  Begin
    If ExecProtocol(P1)=0 Then
    Begin
      With List Do
      Begin
        From      :=Urec^.Handle;
        When      :=Now;
        WhenRated :=Now;
        Filename  :=Input;
        Path      :=CurXArea.Path;
        Points    :=0;
        Assign(FS,Input);
        FSize     :=FileSize(FS);
        Close(FS);
        Description:=''; {use 1st line in DIZ}
        Println('Description: '); Edit(Description,WhereX,WhereY,40,False); Println('');
       {Desc           :Array[1..10] of Str40;} {Search for .DIZ}
        Downloaded     :=0;
        SendTo         :='';
        PassWord       :='';
        NewFile        :=True;
        SpecialFile    :=False;
        Aborted        :=False;
        Crashed        :=False;
      End;

      If List.FSize>1 Then
      Begin
        Write(FList,list);
        AssignList;
        Reset(FList);
        Seek(FList,FileSize(FList));
        Close(FList);
      End Else Println('File upload aborted!');
    End Else Println('File upload error!');
  End Else Println('File already exists!');
End;

Procedure DownLoad(P1:String);
Var UCh:Char;
    Aborted:Boolean;
Begin
   Aborted:=False;
   If (Not Exist(CNF^.WorkDir+'BATCH.'+Strr(Node))) Then
   Begin
     Input:=SelectFile;
     If Length(Input)<>0 Then
     Begin
        AddToBatch(Input,'',0,0,0);
        New(MenuBarz);
        With MenuBarz^ Do
        Begin
          MenuName:='Download Option';
          Choice[1]:=' Now ';     HighChr[1]:=1;
          Choice[2]:=' Batch ';   HighChr[2]:=1;
          Choice[3]:=' Abort ';   HighChr[3]:=1;
          NumChoices:=3;
          KeyCmds:='NBA';
          DefChoice:=1;
        End;
        Uch:=BarMenu(MenuBarz^);
        Dispose(Menubarz);
        Case Uch Of
          'N':Begin ExportBatch; ExecProtocol(P1); End;
          'B':Aborted:=True;
          'A':Begin Aborted:=True; Println('Download process aborted!'); End;
        End;
      End;
   End
  Else
   Begin
     New(MenuBarz);
     With MenuBarz^ Do
     Begin
       MenuName:='Download Option';
       Choice[1]:=' Now ';   HighChr[1]:=1;
       Choice[2]:=' Add ';   HighChr[2]:=1;
       Choice[3]:=' Quit ';  HighChr[3]:=1;
       NumChoices:=3;
       KeyCmds:='NAQ';
       DefChoice:=1;
     End;
     Uch:=BarMenu(MenuBarz^);
     Dispose(Menubarz);
     Case Uch Of
      'N':Begin ExportBatch; ExecProtocol(P1); End;
      'A':Begin Aborted:=True; Input:=SelectFile; If length(Input)<>0 Then AddToBatch(Input,'',0,0,0); End;
      'Q':Aborted:=True;
     End;
   End;
   If (Not Aborted) Then ClearBatch;
End;

Procedure FNewScanArea;
Begin
End;

Procedure FNewScanAll;
Begin
End;

Begin
  CurFileArea:=1;
End.