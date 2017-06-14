Unit gensubs;

interface

uses Dos,Records,CnfgRec;

Function lastDrive:Word;
Function UAge(S:Str10):Byte;
function strr (n:integer):Str40;
function streal (r:real):Str40;
function strlong (l:longint):Str40;
function valu (q:Str40):integer;
function hexstr (n:integer):Str10;
function addrstr (p:pointer):Str10;
procedure parse3 (s:Str80; var a,b,c:word);
function packtime (var dt:datetime):longint;
function now:longint;
function timestr (time:longint):Str10;
function timeval (q:Str10):longint;
function timepart (time:longint):longint;
function datestr (time:longint):Str10;
function dateval (q:Str10):longint;
function datepart (time:longint):longint;
function upstring (s:Str255):Str255;
function match (s1,s2:Str255):boolean;
function devicename (name:Str80):boolean;
Function Exist(Filename:string):boolean;
Function DirExists (FileName: PathStr): boolean;
procedure appendfile (name:Str80; var q:text);
procedure addexitproc (p:pointer);
procedure doneexitproc;
function ratio(x1,x2:longint):integer;
Function Encode(Str:Str25):Str25;
Function PadRight(Str:string;Size:byte;Pad:char):string;
Function IsOpen(var ff):boolean;
Function IsClosed(var ff):boolean;
Function RandomFile:Str25;
Procedure WriteLog(Sec,Item:Byte; S:String);
Function StripSpace(S:String):String;

implementation

const maxexitprocs=20;

type packedtimerec=record
       date,time:word
     end;

var exitstack:array [1..maxexitprocs] of pointer;
    exitstackptr:integer;
    DirInfo:         searchrec;

function strr (n:integer):Str40;
var q:Str40;
begin
  str (n,q);
  strr:=q
end;

{function ageuser(bday:string):integer;
var i:integer;
begin
  i:=valu(copy(date,7,2))-valu(copy(bday,7,2));
  if (daynum(copy(bday,1,6)+copy(date,7,2))>daynum(date)) then dec(i);
  ageuser:=i;
end;}


Function UAge(S:Str10):Byte; { make this calc using month too! not just year }
Var M,Day,Y2,Y:Byte;
    D:String;
Begin
  Y:=Valu(Copy(S,Length(S)-1,2));
  If S[1]='0' Then M:=Valu(Copy(S,1,2)) Else M:=Valu(Copy(S,1,1));
  If Pos('/',S)>0 Then Day:=Valu(Copy(S,Pos('/',S)+1,2))
 Else
  If Pos('-',S)>0 Then Day:=Valu(Copy(S,Pos('-',S)+1,2));
  D:=DateStr(Now);
  Y2:=Valu(Copy(D,Length(D)-1,2));
  UAge:=Y2-Y;
End;

Function Ratio(x1,x2:longint):Integer;  { Checked by Zealot }
Var x3:Integer;
   y1,y2,y3:Real;
Begin
  if x1<1 then x1:=1;
  if x2<1 then x2:=1;
  y1:=int(x1);
  y2:=int(x2);
  y3:=y1/y2;
  y3:=y3*100;
  x3:=trunc(y3);
  Ratio:=x3;
End;

function streal (r:real):Str40;
var q:Str40;
begin
  str (r:0:0,q);
  streal:=q
end;

function strlong (l:longint):Str40;
var q:Str40;
begin
  str (l,q);
  strlong:=q
end;

function valu (q:Str40):integer;
var i,s,pu:integer;
    r:real;
    c:Char;
begin
  valu:=0;
  if length(q)=0 then exit;
  c:=Q[1];
  if not (C in ['0','1','2','3','4','5','6','7','8','9','-']) then begin
    Valu:=0;
    exit;
  End;
  If (c in ['A'..'~']) then Begin
    Valu:=0;
    Exit;
  End;
  if length(q)>5 then exit;
  val (q,r,s);
  if s<>0 then exit;
  if (r<=32767.0) and (r>=-32767.0) then valu:=round(r)
end;

function value(q:Str40):Word;
var Cnt,Holder,i,s,pu:Word;
    r:real;
    c:Char;
begin
  value:=0;
  if length(q)=0 then exit;
  c:=Q[1];
  if not (C in ['0','1','2','3','4','5','6','7','8','9','-']) then 
  begin
    Value:=0;
    exit;
  End;
  If (c in ['A'..'~']) then Begin
    Value:=0;
    Exit;
  End;
  if length(q)>5 then exit;

{  If Cnt=1 Then Holder:=Q[cnt]*10000 Else
  If Cnt=2 Then Holder:=Q[Cnt]*1000 Else
  If Cnt=3 Then Holder:=Q[Cnt]*100 Else
  If Cnt=4 Then Holder:=Q[Cnt]*10 Else
  If Cnt=5 Then Holder:=Q[Cnt]*1;
 }
  val(q,r,s);
  if s<>0 then exit;
  if (r<=32767.0) and (r>=-32767.0) then value:=round(r)
end;

function hexstr (n:integer):Str10;

  function hexbytestr (b:byte):Str10;
  const hexchars:array[0..15] of char='0123456789ABCDEF';
  begin
    hexbytestr:=hexchars[b shr 4]+hexchars[b and 15]
  end;

begin
  hexstr:=hexbytestr (hi(n))+hexbytestr(lo(n))
end;

function addrstr (p:pointer):Str10;

(*  function hexstr (n:integer):Str10;

    function hexbytestr (b:byte):Str10;
    const hexchars:array[0..15] of char='0123456789ABCDEF';
    begin
      hexbytestr:=hexchars[b shr 4]+hexchars[b and 15]
    end;

  begin
    hexstr:=hexbytestr (hi(n))+hexbytestr(lo(n))
  end;
 *)
begin
  addrstr:=hexstr(seg(p^))+':'+hexstr(ofs(p^))
end;

procedure parse3 (s:Str80; var a,b,c:word);
var p:integer;

  procedure parse1 (var n:word);
  var ns:Str80;
  begin
    ns[0]:=#0;
    while (p<=length(s)) and (s[p] in ['0'..'9']) do
    begin
      ns:=ns+s[p];
      p:=p+1
    end;
    if length(ns)=0 then n:=0 else n:=valu(ns);
    if p<length(s) then p:=p+1
  end;

begin
  p:=1;
  parse1 (a);
  parse1 (b);
  parse1 (c)
end;

function packtime (var dt:datetime):longint;
var l:longint;
begin
  dos.packtime (dt,l);
  packtime:=l
end;

Function Now:longint;
Var Dt:DateTime;
    T:Word;
Begin
  GetTime(Dt.Hour,Dt.Min,Dt.Sec,T);
  GetDate(Dt.Year,Dt.Month,Dt.Day,T);
  Now:=PackTime(Dt);
End;

function timestr (time:longint):Str10;
var h1:integer;
    ms:Str10;
    dt:datetime;

const ampmstr:array [false..true] of string[2]=('am','pm');
begin
  unpacktime (time,dt);
  h1:=dt.hour;
  if h1=0 then h1:=12 else if h1>12 then h1:=h1-12;
  ms:=strr(dt.min);
  if dt.min<10 then ms:='0'+ms;
  timestr:=strr(h1)+':'+ms+' '+ampmstr[dt.hour>11]
end;

function datestr (time:longint):Str10;
var dt:datetime;
begin
  unpacktime (time,dt);
  if dt.year<2000 Then datestr:=strr(dt.month)+'/'+strr(dt.day)+'/'+strr(dt.year-1900)
  Else datestr:=strr(dt.month)+'/'+strr(dt.day)+'/'+strr(dt.year-2000)
end;

function timepart (time:longint):longint;
begin
  timepart:=time and $0000ffff;
end;

function datepart (time:longint):longint;
begin
  datepart:=time and $ffff0000;
end;

procedure cleardatetime (var dt:datetime);
begin
  unpacktime (0,dt)
end;

function timeval (q:Str10):longint;
var h1,t:word;
    k:char;
    dt:datetime;
begin
  cleardatetime (dt);
  parse3(q,h1,dt.min,t);
  k:=upcase(q[length(q)-1]);
  if h1 in [1..11] then
  begin
    dt.hour:=h1;
    if k='P' then dt.hour:=dt.hour+12
  end
  else if k='P' then dt.hour:=12 else dt.hour:=0;
  timeval:=(dt.hour*60)+(dt.min);
  {timeval:=timepart(packtime(dt))}
end;

function dateval (q:Str10):longint;
var dt:datetime;
begin
  cleardatetime (dt);
  parse3(q,dt.month,dt.day,dt.year);
  If dt.year<2000 then 
  Begin
    if dt.year<100 then dt.year:=dt.year+1900;
  End Else if dt.year<100 then dt.year:=dt.year+2000;
  dateval:=datepart(packtime(dt))
end;

function upstring (s:Str255):Str255;
var cnt:integer;
begin
  for cnt:=1 to length(s) do s[cnt]:=upcase(s[cnt]);
  upstring:=s
end;

function match (s1,s2:Str255):boolean;
var cnt:integer;
begin
  match:=false;
  if length(s1)<>length(s2) then exit;
  for cnt:=1 to length(s1) do
    if upcase(s1[cnt])<>upcase(s2[cnt])
      then exit;
  match:=true
end;

Function DeviceName (name:Str80):boolean;
var f:file;
    n:integer absolute f;
    r:registers;
begin
  devicename:=false;
  assign (f,name);
  reset (f);
  if ioresult<>0 then exit;
  r.bx:=n;
  r.ax:=$4400;
  intr ($21,r);
  devicename:=(r.dx and 128)=128;
  close (f)
end;

Function Exist(Filename:string):boolean;
{returns true if file exists}
var Inf: SearchRec;
begin
  FindFirst(Filename,AnyFile,Inf);
  Exist := (DOSError = 0);
end;  {Func Exist}

procedure appendfile (name:Str80; var q:text);
var n:integer;
    b:boolean;
    f:file of char;
begin
  close (q);
  n:=ioresult;
  assign (q,name);
  assign (f,name);
  reset (f);
  b:=(ioresult<>0) or (filesize(f)=0);
  close (f);
  n:=ioresult;
  if b
    then rewrite (q)
    else append (q)
end;

procedure addexitproc (p:pointer);
begin
  inc (exitstackptr);
  if exitstackptr>maxexitprocs then begin
    writeln ('Too many exit procedures');
    halt (255)
  end else begin
    exitstack[exitstackptr]:=exitproc;
    exitproc:=p
  end
end;

procedure doneexitproc;
begin
  exitproc:=exitstack[exitstackptr];
  dec (exitstackptr)
end;

Function Lastdrive:word;
var LDOfs:word;
Begin
  LDOfs:=$21;
  case Hi(DosVersion) of
    2:LDOfs:=$10;
    3:If Lo(DosVersion)=0 then LDoFs:=$1B;
  End;

ASM
  Mov Ah,52h
  Int 21h
  mov di,LDofs
  Xor ah,ah
  mov al, es:[bx+di]
  mov @result,ax
  end;
end;

Function  DirExists (FileName: PathStr): boolean;
Var
  f   : file;
  attr: word;
  len : byte;
Begin
  Len:=Length(FileName);
  If (FileName[len] = '\') then Dec(FileName[0]);
  FileName:=Filename+ '\.';
  Assign(f,FileName);
  GetFattr(f,attr);
  DirExistS := ((attr and directory)=directory);
  End;

Function Encode(Str:Str25):Str25;
var
  I : integer;
  T : Integer;
  Ts: String;
begin
  Ts:='';
  For I:=1 To Length(Str) do Ts:=Ts+UpCase(Str[i]);
  Str:=ts;
  For I:=1 to Length(Str) do
  Begin
    CASE I OF
      1,23,5,17,9   :Str[I]:=Chr(Ord(Str[I])+15);
      22,4,16,8,20  :Str[I]:=Chr(Ord(Str[I])-3);
      11,13,15,7,19 :Str[I]:=Chr(Ord(Str[I])+8);
      2,14,6,18,10  :Str[I]:=Chr(Ord(Str[I])-19);
      21,3,25       :Str[I]:=Chr(Ord(Str[I])+1);
      12,24         :Str[I]:=Chr(Ord(Str[I])-10);
    End;
  End;
 
  Ts:=''; 
  For I:= 1 to Length(Str) Do 
  Begin
    T:=Ord(Str[i]) XOR $ef;
    Ts:=Ts+Chr(T);
  End;
  Encode := Ts;
End;

Function PadRight(Str:string;Size:byte;Pad:char):string;
var
  temp : string;
  L : integer;
Begin
  Fillchar(Temp[1],Size,Pad);
  Temp[0] := chr(Size);
  L := length(Str);
  If L <= Size then Move(Str[1],Temp[succ(Size - L)],L) else
  Move(Str[1],Temp[1],size);
  PadRight := Temp;
End;

Function IsOpen(var ff):boolean;
{var fi:fib absolute ff;}
begin
{  isopen:=fi.handle<>0}
end;

Function IsClosed(var ff):boolean;
{Var fi:fib absolute ff;}
Begin
{  isClosed:=Fi.Mode=fmclosed;}
End;

Function RandomFile:Str25;
Var XT,T:String;
    X:Byte;
Begin
  Randomize;
  RandSeed:=Now;
  T:=''; XT:='';
  For X:=1 to 8 do T:=T+Strr(Random(9)+1);
  RandSeed:=Now;
  For X:=1 to 3 do XT:=XT+Strr(Random(9)+1);
  RandomFile:=T+'.'+XT;
End;

Procedure WriteLog(Sec,Item:Byte; S:String);
Var T:Text;
  Line:String;
  Today:Str10;
  YY,DD,MM,DOW:Word;
Begin
  GetDate(YY,MM,DD,DOW);
  Today:=Strr(YY)+PadRight(Strr(MM),2,'0')+Strr(DD);
  Assign(T,CNF^.SysLogDir+Today+'.LOG');
  If Exist(CNF^.SysLogDir+Today+'.LOG') Then Append(T) Else ReWrite(T);
  Writeln(T,'|08[|09',DateStr(Now),'|11-|09',TimeStr(Now),'|08] |03',S,'|07');
  Close(T);
End;

Function StripSpace(S:String):String;
Var X:Byte;
  Tmp:String;
Begin
  Tmp:='';
  For X:=1 to Length(S) Do If S[X]<>' ' Then Tmp:=Tmp+S[X];
  StripSpace:=Tmp;
End;

Begin
End.
