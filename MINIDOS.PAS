Unit MiniDos;    (* Miniature Dos Shell *)

interface

Procedure Littledos;

implementation

Uses OpCrt,Vars,DOS,Records,IO,CnfgRec,Windows,Gensubs,Display,Misc,Archive;

Var xword:array[1..9] of str255;
    ffinfo:searchrec;
    found:boolean;
    nofile:boolean;
    DisplayDir:Boolean;
    Status : Word;

procedure Littledos;
var curdir,BBSDir,s,s1:str40;
    abort,next,done,nocmd,nospace:boolean;

function timeit (time:longint):Str25;
var h1:integer;
    ms:Str25;
    dt:datetime;
const ampmstr:array [false..true] of string[2]=('a','p');
Begin
  unpacktime (time,dt);
  h1:=dt.hour;
  If h1=0
    Then h1:=12
    Else If h1>12
      Then h1:=h1-12;
  ms:=strr(dt.min);
  If dt.min<10 Then ms:='0'+ms;
  timeit:=strr(h1)+':'+ms+ampmstr[dt.hour>11]
End;

function dateit (time:longint):Str25;

    Function addzero(gnr:integer):string;
    Begin
        If Length(Strr(GNR))=2 Then AddZero:=Strr(GNR)
        Else AddZero:='0'+Strr(GNR);
    End;

var dt:datetime;
Begin
  unpacktime (time,dt);
  dateit:=AddZero(dt.month)+'/'+AddZero(dt.day)+'/'+strr(dt.year-1900)
End;

procedure parse(s:Str40);
var i,j,k:integer;
Begin
  For i:=1 to 9 Do xword[i]:='';
  i:=1; j:=1; k:=1;
  If (length(s)=1) Then xword[1]:=s;
  While (i<length(s)) Do
  Begin
    inc(i);
    If ((s[i]=' ') or (length(s)=i)) Then
    Begin
      If (length(s)=i) Then inc(i);
      xword[k]:=copy(s,j,(i-j));
      j:=i+1;
      inc(k);
    End;
  End;
End;

function exdrv(s:string):byte;
Begin
  s:=fexpand(s);
  exdrv:=ord(s[1])-64;
End;

function allcaps(s:string):string;
var i:integer;
Begin
  For i:=1 to length(s) Do s[i]:=upcase(s[i]);
  allcaps:=s;
End;

function iswildcard(s:Str40):boolean;
Begin
  iswildcard:=((pos('*',s)<>0) or (pos('?',s)<>0));
End;

function bslash(b:boolean; s:Str40):Str40;
Begin
  If (b) Then
  Begin
    While (copy(s,length(s)-1,2)='\\') Do s:=copy(s,1,length(s)-2);
    If (copy(s,length(s),1)<>'\') Then s:=s+'\';
  End Else
    While (copy(s,length(s),1)='\') Do s:=copy(s,1,length(s)-1);
  bslash:=s;
End;

procedure ffile(fn:Str40);
Begin
    findfirst(fn,anyfile,ffinfo);
    found:=(doserror=0);
End;

procedure nfile;
Begin
    findnext(ffinfo);
    found:=(doserror=0);
End;

procedure dir(cd,x:Str40; pause:boolean);
var abort,next,nofiles:boolean;
    t,name,ext:Str40;
    onlin:integer;
    dfs:longint;
    z,y,numfiles:integer;
    ch:Char;
    A,B,C:Byte;
Begin
  If (copy(cd,length(cd),1)<>'\') Then cd:=cd+'\';
  abort:=FALSE;
  If x<>'' Then Cd:=Cd+x Else cd:=cd+'*.*';
  If DisplayDir Then Println(' Sub-Directories of '+copy(cd,1,length(cd)))
    Else Println(' Directory of  '+copy(cd,1,length(cd)));
  Println('');
  t:=''; onlin:=0; numfiles:=0; nofiles:=TRUE; Name:=''; Ext:='';
  ffile(cd);
  While (found) And (not abort) Do
  Begin
    If DisplayDir Then If ffinfo.attr = 16 Then
    Begin
      nofiles:=FALSE;
      Inc(OnLin);
      Inc(NumFiles);
      Print(ffinfo.name);
      For Y:= 1 to 12-Length(ffinfo.name) Do Print(' ');
      Print(' <DIR>');
    End;
    If Not DisplayDir And (ffinfo.attr <> 16) Then
    Begin
      nofiles:=FALSE;
      Inc(OnLin);
      Inc(NumFiles);
      If Length(ffinfo.name) > 4 Then
      Begin
        Z:=Length(ffinfo.name)-3;
        If ffinfo.name[Z]='.' Then
        Begin
          For Y:=1 to Z-1 Do Print(ffinfo.name[Y]);
          For Y:=Z to 9 Do Print(' ');
          For Y:=Z+1 to Length(ffinfo.name) Do Print(ffinfo.name[Y]);
        End
         Else
        Begin
          Print(ffinfo.name);
          For Y:= 1 to 12-Length(ffinfo.name) Do Print(' ');
        End;
      End
     Else
      Begin
        Print(ffinfo.name);
        For Y:= 1 to 12-Length(ffinfo.name) Do Print(' ');
      End;
    End;
    If Not DisplayDir And (ffinfo.attr <> 16) Then
    Begin
      Str(ffinfo.size,T);
      Case Length(T) of
        1 : Print('        '+StrLong(ffinfo.size));
        2 : Print('       '+StrLong(ffinfo.size));
        3 : Print('      '+StrLong(ffinfo.size));
        4 : Print('     '+StrLong(ffinfo.size));
        5 : Print('    '+StrLong(ffinfo.size));
        6 : Print('   '+StrLong(ffinfo.size));
        7 : Print('  '+StrLong(ffinfo.size));
      End;
    End;
    If ((DisplayDir) And (ffinfo.attr=16)) or ((Not DisplayDir) And (ffinfo.attr <> 16)) Then
    Begin
      Tab(' '+DateIt(ffinfo.time),11);
      If Length(TimeIt(FFinfo.Time))<6 Then Print(' ');
      Println(TimeIt(FFinfo.time));
    End;
    nfile;
    If (OnLin=24) And Pause Then
    Begin
      HitKey;
      OnLin:=0;
    End;
  End;
  If (nofiles) Then t:='      Files not found' Else t:='      '+strr(numfiles)+' File(s)';
  If Not NoFiles Then Println(T+'   '+Strr(DiskFree(0))+' bytes free') Else Println(T);
End;

procedure versioninfo;
Begin
  PrintLn('ShockWavE(R) Mini-DOS(R) Version '+Strr(Revision));
  PrintLn('        (C)Copyright Cyber Realities 1994, 1995');
  PrintLn('');
End;

  Procedure Help;
  Begin;
    PrintLn('        ShockWavE Mini Dos Help');
    PrintLn('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�');
    PrintLn('DIR..........Displays a list of files in that Directory');
    PrintLn('DIR DIR......Displays a list of directories');
    PrintLn('EXIT.........Quits from Mini-Dos');
    PrintLn('DEL..........Deletes a file');
    PrintLn('TYPE.........Prints a file to the Screen');
    Println('REN..........Renames a File');
    Println('CD...........Changes Directory');
    Println('MD...........Makes a Directory');
    Println('RD...........Removes a Directory');
    Println('COPY.........Copies a File');
    Println('MOVE.........Moves a File');
    Println('CLS..........Clears the Screen');
    Println('SEND.........Sends a file');
    Println('RECEIVE......Recieves a file');
    Println('PKZIP........PKZIP [Zipfile] [Files]');
    Println('PKUNZIP......PKUNZIP [Zipfile]');
    Println('VIEW.........Views an Archived File');
    Println('VER..........Displays Version Information');
    Println('DIRSIZE......Shows Size of a Directory');
    Println('?............Displays this help file');
  End;

procedure docmd(cmd:Str40);

var
  fi       : file of byte;
  f        : file;
  fname    : Str80;
  ps,
  ns,
  es,
  op,
  np,
  s1,
  s2,
  s3       : Str40;
  tsiz,
  numfiles : longint;
  i,
  j,
  retlevel : integer;
  b,
  ok       : boolean;

  Begin
    abort:=FALSE;
    next:=FALSE;
    nocmd:=FALSE;
    For i:=1 to 9 Do xword[i]:=allcaps(xword[i]);
    s:=xword[1];
    If (s='?') or (s='HELP') Then Help
     Else If (s='EXIT') or (s='QUIT') Then done:=TRUE
      Else If ((s='DEL') or (s='DELETE')) Then
      Begin
        If iswildcard(xword[2]) Then
        Begin
            If Not Yeana('All selected files will be deleted!'+^M+'Are you sure: ',False) Then exit;
        End;
        If ((not exist(xword[2])) And (not iswildcard(xword[2]))) or
         (xword[2]='') Then Println('File not found.') Else
        Begin
          xword[2]:=fexpand(xword[2]);
          ffile(xword[2]);
          repeat
            If not ((ffinfo.attr And VolumeID=VolumeID) or
              (ffinfo.attr And Directory=Directory)) Then
            Begin
              assign(f,ffinfo.name);
              {$I-} erase(f); {$I+}
              If (ioresult<>0) Then
              Println('"'+ffinfo.name+'": Could not delete!');
            End;
            nfile;
          until (not found) or (hungupon);
        End;
      End
    Else
    If (s='TYPE') Then Begin
      If ((not exist(xword[2])) And (xword[2]<>'')) Then
      Println('File not found.')
      Else Begin
        xword[2]:=fexpand(xword[2]);
        printfile(xword[2]);
        If (ioresult<>0) Then Println('File not found.');
      End;
    End
    Else
    If ((s='REN') or (s='RENAME')) Then Begin
      If ((not exist(xword[2])) And (xword[2]<>'')) Then
        Println('File not found.')
      Else Begin
        xword[2]:=fexpand(xword[2]);
        assign(f,xword[2]);
        {$I-} rename(f,xword[3]); {$I+}
        If (ioresult<>0) Then Println('File not found.');
      End
    End
    Else
    If (s='DIR') or (s='DIR/P') or (s='DIR /P') or (s='DIR /W') or (S='DIR/W')
    Then Begin
      If (s='DIR/P') or (s='DIR /P') Then B:=True Else B:=False;
      If (xword[2]='') Then xword[2]:='*.*';
      If (xword[2]='DIR') Then
      Begin
        DisplayDir:=True;
        xword[2]:='*.*';
      End Else DisplayDir:=False;
      s1:=curdir;
      xword[2]:=fexpand(xword[2]);
      fsplit(xword[2],ps,ns,es);
      s1:=ps; s2:=ns+es;
      If (s2='') Then s2:='*.*';
      If (not iswildcard(xword[2])) Then Begin
        ffile(xword[2]);
        If ((found) And (ffinfo.attr=directory)) or
           ((length(s1)=3) And (s1[3]='\')) Then Begin   {* root directory *}
          s1:=bslash(TRUE,xword[2]);
          s2:='*.*';
        End;
      End;
      Println('');
      DIR(s1,s2,b);
      Println('');
    End
    Else
    If ((s='CD') or (s='CHDIR')) And (xword[2]<>'') Then
    Begin
      xword[2]:=fexpand(xword[2]);
      {$I-} chdir(xword[2]); {$I+}
      If (ioresult<>0) Then Println('Invalid pathname.');
    End
    Else
    If ((s='MD') or (s='MKDIR')) And (xword[2]<>'') Then Begin
      {$I-} mkdir(xword[2]); {$I+}
      If (ioresult<>0) Then Println('Unable to create directory.');
    End
    Else
    If ((s='RD') or (s='RMDIR')) And (xword[2]<>'') Then Begin
      {$I-} rmdir(xword[2]); {$I+}
      If (ioresult<>0) Then Println('Unable to remove directory.');
    End
    Else
    If (s='COPY') Then
    Begin
      If (xword[2]<>'') Then
      Begin
        If (iswildcard(xword[3])) Then
          Println('Wildcards not allowed in destination parameter!')
        Else
        Begin
          If (xword[3]='') Then xword[3]:=curdir;
          xword[2]:=bslash(FALSE,fexpand(xword[2]));
          xword[3]:=fexpand(xword[3]);
          ffile(xword[3]);
          b:=((found) And (ffinfo.attr And directory=directory));
          If ((not b) And (copy(xword[3],2,2)=':\') And
              (length(xword[3])=3)) Then b:=TRUE;

          fsplit(xword[2],op,ns,es);
          op:=bslash(TRUE,op);

          If (b) Then
            np:=bslash(TRUE,xword[3])
          Else Begin
            fsplit(xword[3],np,ns,es);
            np:=bslash(TRUE,np);
          End;

          j:=0;
          abort:=FALSE; next:=FALSE;
          ffile(xword[2]);
          While (found) And (not abort) And (not hungupon) Do Begin
            If (not ((ffinfo.attr=directory) or (ffinfo.attr=volumeid))) Then
            Begin
              s1:=op+ffinfo.name;
              If (b) Then s2:=np+ffinfo.name Else s2:=np+ns+es;
              Println(s1+' -> '+s2);
              Swapvectors;
              Exec(GETENV('COMSPEC'),'/C Copy '+s1+' '+s2);
              Swapvectors;
              If DosExitCode=0 Then
              Begin
                inc(j);
                Println('');
              End 
             Else If (nospace) Then Println(' - *Insufficient space*') Else Println(' - *Copy failed*');
            End;
            HitKey;
            nfile;
          End;
          If (j<>0) Then 
          Begin
            Print('  '+strr(j)+' file');
            If (j<>1) Then Print('s');
            Println(' copied.');
          End;
        End;
      End;
    End
    Else
    If (s='MOVE') Then 
    Begin
      If (xword[2]<>'') Then 
      Begin
        If (iswildcard(xword[3])) Then Println('Wildcards Not Allowed in Destination Parameter!')
       Else 
        Begin
          If (xword[3]='') Then xword[3]:=curdir;
          xword[2]:=bslash(FALSE,fexpand(xword[2]));
          xword[3]:=fexpand(xword[3]);
          ffile(xword[3]);
          b:=((found) And (ffinfo.attr And directory=directory));
          If ((not b) And (copy(xword[3],2,2)=':\') And (length(xword[3])=3)) Then b:=TRUE;
          fsplit(xword[2],op,ns,es);
          op:=bslash(TRUE,op);

          If (b) Then np:=bslash(TRUE,xword[3]) Else 
          Begin
            fsplit(xword[3],np,ns,es);
            np:=bslash(TRUE,np);
          End;

          j:=0;
          abort:=FALSE; next:=FALSE;
          ffile(xword[2]);
          While (found) And (not abort) And (not hungupon) Do 
          Begin
            If (not ((ffinfo.attr=directory) or (ffinfo.attr=volumeid))) Then
            Begin
              s1:=op+ffinfo.name;
              If (b) Then s2:=np+ffinfo.name Else s2:=np+ns+es;
              Print(s1+' -> '+s2+' :');
              Swapvectors;
              Exec(GETENV('COMSPEC'),'/C Copy '+S1+' '+s2);
              Swapvectors;
              If DosExitCode=0 Then 
              Begin
                Swapvectors;
                Exec(Getenv('COMSPEC'),'/C Del '+S1);
                Swapvectors;
              End;
              If DosExitCode=0 Then 
              Begin
                inc(j);
                Println('');
              End Else
                If (nospace) Then Println(' - *Insufficient Space*')
                Else Println(' - *Move Failed*');
            End;
            HitKey;
            nfile;
          End;
          If (j<>0) Then Begin
            Print('  '+strr(j)+' file');
            If (j<>1) Then Print('s');
            Println(' moved.');
          End;
        End;
      End;
    End
    Else
    If (s='CLS') Then Cls
    Else
    If (length(s)=2) And (s[1]>='A') And (s[1]<='Z') And
       (s[2]=':') Then Begin
      {$I-} getdir(ord(s[1])-64,s1); {$I+}
      If (ioresult<>0) Then Println('Invalid drive.')
      Else Begin
        {$I-} chdir(s1); {$I+}
        If (ioresult<>0) Then Begin
          Println('Invalid drive.');
          chdir(curdir);
        End;
      End;
    End
    Else
    If (s='VIEW') Then
    Begin
      Fname:=Upstring(xword[2]);
      cls;
      Print('Archive Type: ');
      If pos ('.ZIP', fname)>0 Then Zipview(fname) Else
      If pos ('.PAK',fname)>0 Then PakView(fname) Else
      If pos ('.ARC',fname)>0 Then Arcview(fname) Else
    { If pos ('.GIF',fname)>0 Then Gifview(fname) Else  }
      If pos ('.ARJ',fname)>0 Then Arjview(fname) Else {01/04/91}
      If (pos ('.LZH',fname)>0) or (pos('.ICE',fname)>0) Then Lzhview(fname) Else
      Println('Not an ARCHIVE!'^M^M);
    End
    Else
    If (s='RECEIVE') Then
    Begin
      If XWord[ 2 ] <> '' Then
      Begin
        If Not Exist( XWord[ 2 ] ) Then
        Begin
          SwapVectors;
          Exec( GetEnv('COMSPEC'), '/C DSZ.COM port '+Strr(CNF^.ModemPort)+
            +' speed '+StrLong( BaudRate )+' ha slow rz -mrr '+XWord[2] );                 
          SwapVectors;
        End
        Else Println('File Already Exists.');
      End
      Else Println('Filename not specified.');
    End
    Else
    If (s='SEND') Then
    Begin
      If XWord[2] <> '' Then
      Begin
        If Exist(XWord[2]) Then
        Begin
          SwapVectors;
          Exec(GetEnv('COMSPEC'),'/C DSZ.COM port '+Strr(CNF^.ModemPort)+
            ' speed '+StrLong(BaudRate)+' ha slow sz -mrr '+XWord[2]);
          SwapVectors;
        End
        Else Println('File not found.');
      End
      Else Println('Filename not specified.');
    End
    Else
    If (s='PKZIP') Then
    Begin
      If XWord[2]<>'' Then
      Begin      
        If XWord[3]<>'' Then
        Begin
          SwapVectors;
          Exec(GetEnv('COMSPEC'),'/C PKZIP '+XWord[2]+' '+XWord[3]);
          SwapVectors;
        End
        Else Println('No files specified');
      End
      Else Println('Zip file not specified');
    End
   Else
    If (s='PKUNZIP') Then
    Begin
      If XWord[2]<>'' Then
      Begin
        If Xword[3]<>'' Then Begin
          SwapVectors;
          Exec(GetEnv('Comspec'),'/C PKUNZIP '+XWord[2]+' '+XWord[3]);
          SwapVectors;
        End Else Begin
          SwapVectors;
          Exec(GetEnv('Comspec'),'/C PKUNZIP '+XWord[2]);
          SwapVectors;
        End;
      End Else Println('No File Specified');
    End
    Else
    If (s='VER') Then versioninfo
    Else
    If (s='FORMAT') Then
    Begin
      Println('');
      Println('Yea, like thats gonna work!');
      Println('');
    End
   Else
    If (s='DIRSIZE') Then
    Begin
      Println('');
      If (xword[2]='') Then If Length(CurDir)=3 Then xword[2]:=CurDir+'*.*'
        Else xword[2]:=CurDir+'\*.*';
      numfiles:=0; tsiz:=0;
      ffile(xword[2]);
      While (found) Do
      Begin
        inc(tsiz,ffinfo.size);
        inc(numfiles);
        nfile;
      End;
      If (numfiles=0) Then Println('No files found!')
        Else Println('"'+allcaps(xword[2])+'": '+strr(numfiles)+' file(s), '+Strr(tsiz)+' bytes.');
      Println('');
    End Else
    Begin
      nocmd:=TRUE;
      If (s<>'') Then
        Println('Bad command or file name')
    End;
  End;

Begin
  {PrintLog(2,14,'');}
  done:=FALSE;
  nofile:=true;
  clrscr;
  Println('Type "EXIT" to return to ShockWavE.');
  versioninfo;
  getdir(0,curdir);
  BBSDir:=Curdir;
  Repeat
    getdir(0,curdir);
    Input:=Prompt(80,Curdir+'>',False);
    s1:=input;
   { Printlog(2,15,s1);}
    parse(s1);
    docmd(s1);
  until (done) or (hungupon);
  {$I-} chdir(BBSDir); {$I+}
 { Printlog(2,16,'');}
End;

Begin
End.
