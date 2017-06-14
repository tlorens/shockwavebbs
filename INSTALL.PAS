{$A+,B+,D-,E+,F-,G+,I-,L-,N+,O+,R-,S-,V-,X-}
{$M 5520,20000,55360}

Program ProInstall;

Uses Crt,Dos,GenSubs,iCEio1,PullBarz;

Const VerNum='0.01';
      VerDate='02/17/95';

Var Cur:Byte;
    Ext:String[2];
    DoDoX,
    Upgrade,
    NewInstall:Boolean;
    SourcePath,
    TargetPath,
    ANSiPath,
    MenuPath,
    DocsPath,
    FileData,
    Messages,
    Areas,
    WorkPath,
    Includes,
    FileMail,
    DoorPath,
    SwapPath,
    DataPath:String;

Procedure WriteTitle(S:String);
Begin
  TextColor(8); Write('Ä');
  TextColor(9); Write('[');
  TextColor(14); Write('ş');
  TextColor(9); Write(']');
  TextColor(8); Write('ÄÄÄ');
  TextColor(9); Write('[');
  TextColor(15); Write(S);
  TextColor(9); Write(']');
  TextColor(8); Write('ÄÄÄ');
  TextColor(9); Write('[');
  TextColor(14); Write('ş');
  TextColor(9); Writeln(']');
End;

Procedure Install(Source,Target:String);
Begin
  TextColor(7); Writeln('       From ',Source,' ÄtoÄ ',Target);
  SwapVectors;
  Exec(GetEnv('ComSpec'),'/C PKUNZIP.EXE -o '+Source+' '+Target+' >NUL');
  SwapVectors;
  Writeln;
End;

Procedure CheckPath(Title,S:String);
Begin
  WriteTitle(Title);
  Delete(S,Length(S),1);
  TextColor(7); Write('Checking Path: ',S);
  If Not DirExists(S) Then Begin Writeln(' -- Creating...'); MkDir(S); End else writeln;
End;

Procedure CompleteInstall;
Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ Complete Install ³                         ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerNum); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Window(1,3,80,24);
  CheckPath('Main Files',TargetPath);           Install(SourcePath+'SHKWAVE0.ZIP',TargetPath);
  CheckPath('Misc Data',TargetPath+DataPath);   Install(SourcePath+'SHKWAVE1.ZIP',TargetPath+DataPath);
  CheckPath('Documents',TargetPath+DocsPath);   Install(SourcePath+'SHKWAVE2.ZIP',TargetPath+DocsPath);
  CheckPath('ANSi Menus',TargetPath+ANSiPath);  Install(SourcePath+'SHKWAVE3.ZIP',TargetPath+ANSiPath);
  CheckPath('Menu Data',TargetPath+MenuPath);   Install(SourcePath+'SHKWAVE4.ZIP',TargetPath+MenuPath);
  CheckPath('Message Path',TargetPath+Messages);
  CheckPath('Areas Path',TargetPath+Areas);
  CheckPath('Work Path',TargetPath+WorkPath);
  CheckPath('Door Path',TargetPath+DoorPath);
  CheckPath('FileMail Path',TargetPath+FileMail);
  CheckPath('Include Path',TargetPath+Includes);
  CheckPath('Swap Path',TargetPath+SwapPath);
  CheckPath('File Data Path',TargetPath+FileData);
End;

Procedure MainSetup;
Begin
  GetDir(3,SourcePath);
  SourcePath:=SourcePath+'\';
  TargetPath:='C:\SHCK\';
  ANSiPath:='ANSi\';
  MenuPath:='MENUDATA\';
  DataPath:='DATA\';
  DocsPath:='DOCS\';
  FileData:='FILEDATA\';
  Messages:='MESSAGE\';
  Areas:='AREAS\';
  WorkPath:='WORK\';
  Includes:='INCLUDES\';
  FileMail:='FILEMAIL\';
  DoorPath:='DOORS\';
  SwapPath:='SWAP\';
End;

Begin
  MainSetup;
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ Install ³                                  ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VerNum); ClrEol; Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  Write('Target Path: '); EditLine(TargetPath,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;
  CursorOff;
  If TargetPath[length(TargetPath)]<>'\' then TargetPath:=targetpath+'\';
  CompleteInstall;
  Delete(TargetPath,Length(TargetPath),1);
  Chdir(TargetPath);
  CursorOn;
  SwapVectors;
  Exec(GetEnv('ComSpec'),'/C CONFIG.EXE');
  SwapVectors;
End.
