unit Archive;

Interface

Uses opCrt,Dos,Records,Vars,cnfgrec,IO,gensubs,Display,Zip;

Procedure ArcView(fname:Str80);
Procedure PakView(filename:Str80);
Procedure ZipView(fn:Str80);
Procedure LzhView(fn:Str80);
Procedure ArjView(fn:Str80);
Procedure AdDszLog(cps:Str10;fname:Str80;send:boolean;size:longint);
Procedure LeechZModem(filezp:Str25);
Procedure AddZipComment(pathname:Str80; path,name:Str25; Var ZipUD:FFileRec);
Function File_Id(var ud:FFileRec):Boolean;

Implementation

Function File_Id(var ud:FFileRec):Boolean;
Var ZX,CNT : Integer;
    Status : Word;
    S : String;
    T : Text;
    TD : Array[1..10] of String[40];
Begin
  File_ID:=False;
  If IsOpen(T) Then Close(T);
  If POS('.ZIP',Ud.Filename)=0 Then Exit;
  Println('Searching For FILE_ID.DIZ...');
  SwapVectors;
  Exec(GetEnv('COMSPEC'),'/C PKUNZIP.EXE -o '+UD.PATH+UD.FILENAME+' FILE_ID.DIZ '+CNF^.WorkDir+ '>NUL');
  SwapVectors;

  If Exist(CNF^.WorkDir+'FILE_ID.DIZ') Then
  Begin
    File_ID:=True;
    CNT := 0;
    FillChar(TD,SizeOf(TD),#0);
    Assign(T,CNF^.WorkDir+'FILE_ID.DIZ');
    Reset(T);
    Println('');
    While (Not EOF(T)) and (Cnt<11) do
    Begin
      Inc(CNT);
      Readln(T,S);
      TD[Cnt] := Copy(S,1,40);
      Println(TD[Cnt]);
    End;
    Erase(T);
    Close(T);
    Println('');
    For ZX:=1 To 10 do UD.Desc[ZX]:='';
    If YeaNa('FILE_ID.DIZ Found!  Use as file description',True) Then
    Begin
      File_ID:=True;
      Ud.Description:='';
      Println('');
      Println('Importing Description...');
      For ZX:=1 To Cnt do UD.Desc[ZX]:=Td[ZX];
    End
   Else
    Begin
      File_ID:=False;
      For ZX:=1 To 10 do UD.Desc[ZX]:='';
      UD.Description:='-*- No Description -*-';
    End;
  End;
End;
(*
PROCEDURE ZIP_DEMON(pathname:Str255; path,name:str80);
Var BAD : Boolean;
    F   : File;
    FN  : Text;
    Status : Word;
    Vrs    : String;
    Vrs1   : String;
    Scrn1  : Array[1..4000] of Byte;
    Ch1    : Char;
    I      : Byte;
    FT1,FT2: LongInt;
    DT     : String[2];
    DirInfo:SearchRec;
BEGIN
  IF POS('.ZIP',UpString(name))=0 Then Exit;
  Writeln ('[40m[2J[2;2H[0;1;30;47mÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß[40m[s');
  Writeln ('[u[47mßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ[3;2HÛ                   [40m[s');
  Writeln ('[u[0;31;47m  [1;30m            Ü[37;41m DEMON TASKER 1.0 - UPLOAD VE[40m[s');
  Writeln ('[u[41mRIFICATION [30;47m Û[4;2HÛ  Ü[0;31;47mÛ[1;30;41mÜ[0;31;47mß[40m[s');
  Writeln ('[u[47m[1;37m [30mÜ[0;31;47mÛ[1;30mÜ[0;31;47mÛ[1;37m [30mÜ[40m[s');
  Writeln ('[u[0;31;47mÛ[1;30;41mÜ[0;31;47mß[1;37m [30mÜ[41mÜ[0;31;47mÛß[40m[s');
  Writeln ('[u[47m[1;37m [30mÜ[0;31;47mÛ[1;30;41mÜ[0;31;47mÛ[1;37m [30mÜ[40m[s');
  Writeln ('[u[0;31;47mÛÝÛ[1;30m [0;31;47m [1;30mßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß[40m[s');
  Writeln ('[u[47mßßßßßßßßßß  Û[5;2HÛ  Û[0;31;47mÛß[1;37m  [30mÛ[0;31;47mÛ[40m[s');
  Writeln ('[u[47m[1;30mÛ[0;31;47mÛ[1;37m [30mÛ[41mÜÜ[0;31;47mÛ[1;37m  [40m[s');
  Writeln ('[u[30;41mÛ[0;31;47mÛ [1;37m [30;44mÛ[0;31;47mÛ[1;30mÛ[0;31;47mÛ[40m[s');
  Writeln ('[u[47m[1;37m [30mÛ[0;31;47mÛ[1;30;41mÝ[0;31;47mÛ[1;30m [40m[s');
  Writeln ('[u[0;31;47m [1;30m         [0;30;47mFUSION      DEMON TASKER       [40m[s');
  Writeln ('[u[47m[1m  Û[6;2HÛ  Û[0;31;47mß[1;37m   [30mÛ[41mÜÜ[0;31;47mß[40m[s');
  Writeln ('[u[47m[1;37m [30mÜ[41mÜÜ[0;31;47mß[1;37m [30mÜ[41mÜÜ[0;31;47mß[40m[s');
  Writeln ('[u[47m[1;37m [30;44mÛ[41mÜÜ[0;31;47mß[1;37m [30mÛ[0;31;47mß[40m[s');
  Writeln ('[u[47m[1;30mÛ[0;31;47mß[1;30m [0;31;47m [1;30m       [0;30;47mÄÄ[40m[s');
  Writeln ('[u[47mÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[1m       Û[7;2HÛ [0;31;47m ÜÜÜÜÜÜÜ[40m[s');
  Writeln ('[u[47mÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[1;30m   File Name:                     [40m[s');
  Writeln ('[u[47m         Û[8;2HÛ ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    User Name:  [40m[s');
  Writeln ('[u[47m                            Û[9;2HÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ[40m[s');
  Writeln ('[u[47mÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ[10;2H[40mÛ[75CÛ');
  Writeln ('[11;2HÛ[17C[37mNow[Ctesting[Cuploaded[Cfile,[Cplease[Cwait[20C[30mÛ');
  Writeln ('[12;2HÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[s');
  Writeln ('[uÄÄÄÄÄÄÛ[13;2HÛ[Cþ[Cþ[C[0mCheck[CCRC[Cvalues[Cof[C.ZIP[Cfile[C:[s');
  Writeln ('[u[39C[1;30mÛ[14;2HÛ[Cþ[Cþ[C[0mTest[Cfor[Cvirus[Cwith[CSCAN.EXE[s');
  Writeln ('[u[2C:[39C[1;30mÛ[15;2HÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[s');
  Writeln ('[uÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛ[16;2HÛ[Cþ[Cþ[C[0mRemove[CBBS[Cadvertis[s');
  Writeln ('[uing[Cfiles[2C:[39C[1;30mÛ[17;2HÛ[Cþ[Cþ[C[0mRemove[CZIP[Ccomment[s');
  Writeln ('[us[Cfrom[Cfile[C:[39C[1;30mÛ[18;2HÛ[Cþ[Cþ[C[0mAdding[CBBS[Cadve[s');
  Writeln ('[urtisment[7C:[39C[1;30mÛ[19;2HÛ[Cþ[Cþ[C[0mTest[Cfor[Cage[Cconstr[s');
  Writeln ('[uaint[C([2C)[2C:[39C[1;30mÛ[20;2HÛ[Cþ[Cþ[C[0mShelling[CSysOp[CE[s');
  Writeln ('[uxternal[CBatch[C:[39C[1;30mÛ[21;2HÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[s');
  Writeln ('[uÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛ[22;2HÛ[11C[37mCopyright[C(c[s');
  Writeln ('[u)[C1993,[CSummit[CSoftware[CProductions[C(tm)[12C[30mÛ[23;2Hßßßßßß[s');
  Writeln ('[ußßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß[s');
  Writeln ('[u[0m');

  AColor(112);
  PrintXY(5,52,Verstr);
  readconfig;
{  PrintXY(7,49,FALIGN(CAP(NAME)));
  PrintXY(8,49,RealCode(Unam));}
  AColor (15);
{  PrintXY (19,33,Strr(CNF.OldFile));}
  While NumChars > 0 Do Ch1 := GetChar;
  BAD := FALSE;
  Vrs := CNF.WorkDir;
  VRS1 := VRS;
  VRS1[Length(VRS)] := ' ';
 { KillDir (VRS);}
  AnsiColor (2); PrintXY (13,4,'þ');
  Move (MEM[$B800:0],SCRN1,4000);
  SwapVectors;
  Swp:=ExecWithSwap(CNF.SysDir+'PKUNZIP.EXE',PATHNAME+' '+VRS1);
  SwapVectors;
  Move (SCRN1,MEM[$B800:0],4000);
  If DOSEXITCODE <> 0 Then
  Begin
    AnsiColor (3);
    PrintXY (13,40,'File FAILED! CRC integrity check.');
    AnsiColor (12);
    BAD := TRUE;
  End Else
  Begin
    AnsiColor (3);
    PrintXY (13,40,'File PASSED! CRC integrity check.');
    AnsiColor (10);
  End;
  PrintXY (13,6,'þ');
  VRS1 := VRS;
  VRS1[Length(VRS)] := ' ';
  AnsiColor (2); PrintXY (14,4,'þ');
  Move(MEM[$B800:0],SCRN1,4000);
  SwapVectors;
  Swp:=ExecWithSwap(CNF.SysDir+'SCAN.EXE','/NOMEM /A /NOPAUSE '+VRS);
  SwapVectors;
  Move (SCRN1,MEM[$B800:0],4000);
  If DOSEXITCODE <> 0 Then
  Begin
    AnsiColor (3);
    PrintXY (14,40,'File contains a virus.');
    AnsiColor (12);
    BAD := TRUE;
  End Else
  Begin
    AnsiColor (3);
    PrintXY (14,40,'File is virus free.');
    AnsiColor (10);
  End;
  PrintXY (14,6,'þ');
  AnsiColor (2); PrintXY (16,4,'þ');
  SwapVectors;
  Swp:=ExecWithSwap(GETENV('Comspec'),'/C PKZIP '+pathname+' -D @'+CNF.sysDir+'BADFILES.LST > NUL');
  SwapVectors;
  AnsiColor (3);  PrintXY (16,40,'BBS advertisments removed.');
  AnsiColor (10); PrintXY (16,6,'þ');
  AnsiColor (2); PrintXY (17,4,'þ');
  SwapVectors;
  Swp:=ExecWithSwap(getenv('Comspec'),'/C Pkzip -z '+pathname+' <'+CNF.MenuDir+'COMMENT.TXT');
  SwapVectors;
  if CNF.IncFile<>'' then
  If Exist(Cnf.SysDir+CNF.incFile) Then
  Begin
    SwapVectors;
    swp:=ExecWithSwap(getenv('Comspec'),'/C PKZIP '+pathname+' '+CNF.IncFile);
    SwapVectors;
  End;
  AnsiColor (3);  PrintXY (17,40,'ZIP comments removed.');
  AnsiColor (10); PrintXY (17,6,'þ');
  AnsiColor (2); PrintXY (18,4,'þ');
  SwapVectors;
  Swp:=ExecWithSwap(GETENV('Comspec'),'/C Pkzip '+pathname+' '+CNF.SysDir+CNF.IncFile+' > NUL');
  SwapVectors;
  AnsiColor (3);
  If exist(CNF.SysDir+CNF.IncFile) Then
  PrintXY (18,40,'BBS advertisments added.') Else PrintXY (18,40,'No BBS add found to add.');
  AnsiColor (10); PrintXY (18,6,'þ');
  AnsiColor (2); PrintXY (19,4,'þ');
  FT1 := 2147483647; FT2 := FT1;
  FindFirst(VRS+'*.*', Archive, DirInfo);
  While DosError = 0 do
  Begin
    Assign(F,VRS+DirInfo.Name);
    Reset (F);
    GetFTime (F,FT1);
    Close(F);
    If Ft1 < FT2 then FT2 := FT1;
    FindNext(DirInfo);
  End;
{  DT := Strr(CNF.OldFile);}  { Date of oldest file in Packed form }
  IF DT > Copy (DateStr(FT2),7,2) Then
  Begin
    AnsiColor (3);  PrintXY (19,40,'Some files found inside are old.');
    BAD := TRUE;
    AnsiColor (12);
  End Else
  Begin
    AnsiColor (3);  PrintXY (19,40,'Files are all up to date.');
    AnsiColor (10);
  End;
  PrintXY (19,6,'þ');
  AnsiColor (2); PrintXY (20,4,'þ');
  If exist(CNF.SysDir+'Upload.BAT') Then
  Begin
    SwapVectors;
    Swp:=ExecWithSwap(GetEnv('COMSPEC'),'/C '+CNF.SysDir+'DEMON.BAT '+PATHNAME+' >NUL');
    SwapVectors;
  End;
  AnsiColor (3);  PrintXY (20,40,'File passed SysOp tests.');
  AnsiColor (10); PrintXY (20,6,'þ');
{  If BAD Then
  Begin
    If Not exists(CNF.BadDi+NAME) Then
    Begin
      Assign(F,PATHNAME);
      Rename(F,CNF.BADDI+NAME);
      If IORESULT <> 0 Then
      Begin
        SwapVectors;
        Swp:=ExecWithSwap(GetEnv('COMSPEC'),'/C COPY '+PATHNAME+' '+CNF.BADDI+NAME+' >NUL');
        SwapVectors;
      End;
    End;
    ASSIGN(fn,CNF.Datadi+'Notices.BBS');
    IF NOT Fexists(CNF.Datadi+'Notices.BBS') THEN REWRITE(fn) ELSE
    APPEND(fn);
    WRITELN(fn,^m^r'                      ShockWavE Pro Upload Processor');
    WRITELN(fn,^s'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    WRITELN(fn,^s+NAME+' failed the integrity check.  Please Check it out...');
    WRITELN(fn);
    Close(fn);
    ClearScr;
    Writeln ('Sorry, UL-Processor found a problem in the file ['+NAME+'] you just uploaded!');
    Writeln ('We have placed it OFF-LINE, until the System Operator has a chance to');
    Writeln ('Check it out...');
    Writeln;
    writestr(^p+'Press '+^f+'['^s'Return'^f']'+^p+':*');
  End;}
End;
*)
procedure arcview (fname:Str80);
var f:file of byte;
    b:byte;
    sg:boolean;
    size:longint;
    n:integer;

function getsize:longint;
var x:longint;
    b:array [1..4] of byte absolute x;
    cnt:integer;
begin
 for cnt:=1 to 4 do read (f,b[cnt]);
 getsize:=x
end;

begin
 Println('PKARC');
 assign (f,fname);
 reset (f);
 if ioresult<>0 then exit;
 if (filesize(f)<32) then 
 begin
  Println (^M'That file ain''t a fukkin'' archive, FOOL!');
  close (f);
  exit;
 end;
 Println ('Filename.Ext    Size');
 Println ('ÄÄÄÄÄÄÄÄÄÄÄÄ    ÄÄÄÄ');
 repeat
  read (f,b);
  if b<>26 then begin
   Println (^M'That file ain''t a fukkin'' archive, FOOL!');
   close (f);
   exit
  end;
  read (f,b);
  if b=0 then begin
   close (f);
   exit
  end;
  sg:=false;
  for n:=1 to 13 do begin
   read (f,b);
   if b=0 then sg:=true;
   if sg then b:=32;
   Print (chr(b))
  end;
  size:=getsize;
  for n:=1 to 6 do read (f,b);
  Println ('   '+Strr(getsize));
  seek (f,filepos(f)+size)
 until hungupon;
end;

procedure pakview (filename:Str80);
var f:file of byte;
begin
 Println('PKPAK');
 if not exist ('pkpak') then
 begin
   Println (^M'Error: PK-Pak not found. Notify Sysop.'^M);
   exit;
 end;
 exec(getenv('COMSPEC'),'/C pkpak v '+filename+' >PAK.LST');
 printfile ('PAK.LST')
end;

Procedure ARJView(FN:Str80);
Begin
(*  Println('ARJ');
  swapvectors;
  exec(getenv('Comspec'),'/C ARJV '+fn+' >'+CNF.SysDir+'zipfil.lst');
  swapvectors;
  printfile(CNF.SysDir+'zipfil.lst');*)
  ViewARJ(FN);
End;

Procedure zipview (fn:Str80);
Var Temp:Text;
Begin
  ViewZip(FN);
End;

procedure lzhview(fn:Str80);
begin
  if pos('.ICE',upstring(fn))>0 then Println('LH-ICE') else Println('LH-ARC');
  swapvectors;
  exec(getenv('Comspec'),'/C LHARC /v '+fn+' >'+CNF^.SysDir+'Zipfil.lst');
  swapvectors;
  printfile(CNF^.SysDir+'Zipfil.Lst');
end;

 procedure AddszLog(cps:Str10;fname:Str80;send:boolean; size:longint);
 var f:file of byte;
     t:text;
     fse:longint;
 begin
 fse:=0;
    if exist(CNF^.SysDir+'Trans.Log') then
    begin
      assign(f,CNF^.SysDir+'Trans.Log');
      reset(f);
      fse:=filesize(f);
      close(f);
    end;
    if (fse=0) or (fse>(1024+(CNF^.logsize*1024))) then
    begin
      assign(t,CNF^.SysDir+'Trans.Log');
      rewrite(t);
      writeln(t,'ShockWavE PRO File Transfer Log');
      writeln(t,'File Name                                        CPS  Upload or Download');
      writeln(t,'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
      close(t);
    end;
    assign(t,CNF^.SysDir+'Trans.Log');
    append(t);
    write(t,copy(fname,0,50));
    for fse:=1 to 50-length(fname) do write(t,' ');
    write(t,cps);
    write(t,' '+copy(strr(size div 1024)+'k ',0,5));
    if send then writeln(t,'Download') else writeln(t,'Upload');
    close(t);
 end;

 procedure leechzmodem(filezp:Str25);
 var fn:text;
     i:integer;
 begin
 cls;
 writehdr('Leech Z-Modem Detected!');
 writeln(^M^S'Leech Z-Modem has been detected with this file transfer! The');
 writeln(^S'File points will be subtracted and the sysop WILL be notified!');
 write(^M^R'Notifying Sysop...');
 assign(fn,CNF^.SysDir+'Notices.BBS');
 if not exist(CNF^.SysDir+'Notices.BBS') then rewrite(fn) else reset(fn);
 append(fn);
 writeln(fn,^M^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln(fn,^R'                         Leech Z-Modem Detected');
 writeln(fn,^S'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
 writeln(fn,^M^S+urec^.handle+' was downloading on '+timestr(now)+'/'+datestr(now)+' when he');
 writeln(fn,^S'attempted to use Leech Z-Modem on '+filezp+'. The Points were');
 writeln(fn,^S'charged for this file.');
 close(fn);
 end;

Procedure Addzipcomment(pathname:Str80; path,name:Str25; Var ZipUD:FFileRec);
Begin
  if not CNF^.UseComment then exit;
  If exist(CNF^.MenuDir+'BADFILES.LST') then
  Begin
    If pos('.ZIP',upstring(name))>0 then
    Begin
      SwapVectors;
      Exec(getenv('Comspec'),'/C Pkzip -d '+pathname+' @'+CNF^.MenuDir+'BADFILES.LST >NUL');
      Swapvectors;
      Println('');
    End;
  End;
  If pos('.ZIP',upstring(name))>0 then
  Begin
    Swapvectors;
    Exec(getenv('Comspec'),'/C Pkzip -z '+pathname+' <'+CNF^.MenuDir+'COMMENT.TXT >NUL');
    SwapVectors;
    if CNF^.IncFile<>'' then
    If Exist(Cnf^.SysDir+CNF^.incFile) Then
    begin
      Swapvectors;
      exec(getenv('Comspec'),'/C PKZIP '+pathname+' '+CNF^.IncFile+' >NUL');
      swapvectors;
    End;
  End;

  if pos('.ARJ', upstring(name))>0 then
  begin
    swapvectors;
    exec(getenv('Comspec'),'/C ARJ c -z'+CNF^.MenuDir+'COMMENT.TXT'+pathname);
    swapvectors;
    if CNF^.IncFile<>'' then
    Begin
      swapvectors;
      exec(getenv('Comspec'),'/C ARJ a -m4 '+pathname+' '+CNF^.IncFile);
      swapvectors;
    end;
end;
End;

begin
end.

