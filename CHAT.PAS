Unit Chat;

Interface

uses OPCrt,DOS,IO,Records,Vars,Cnfgrec,GenSubs,Windows;

Procedure SplitScreenChat;

Implementation

Procedure ReadINI;
Var T:Text;
    LocalX  :Array[1..80] Of Byte;
    LocalY  :Array[1..25] Of Byte;
    RemoteX :Array[1..80] Of Byte;
    RemoteY :Array[1..25] Of Byte;
    W,XX,YY:String;
    Rem,Loc:Byte;
    Line:String;

Procedure Parseln(S:String; Var C,X,Y:String);
Var Tmp:String;

  Procedure Cut(Var Instr,OutStr:String);
  Var Tmp:String; 
  Begin
    Tmp:=S;
    If Pos(',',Instr)>0 THen Tmp:=Copy(Instr,1,Pos(',',Instr)-1) Else 
     Tmp:=Copy(Instr,1,Length(Tmp));
     Delete(Instr,1,Pos(',',Instr));
     OutStr:=Tmp;
  End;

Begin
  Tmp:=S;
  Cut(Tmp,C);
  Cut(Tmp,X);
  Cut(Tmp,Y);
End;

Begin
  (* INI Format: L=Local R=Remote
    
    L,X,Y { 1st X,Y Coord }
    L,X,Y { 2nd X,Y Coord }  
     { etc }
    R,X,Y { 1st X,Y Coord }
    R,X,Y { 2nd X,Y Coord }  
  *)
  Rem:=0;
  Loc:=0;
  Assign(T,'CHAT.INI');
  ReSet(T);
  While Not EOF(T) Do
  Begin

    Readln(T,Line);
    If Line[1]<>';' Then
    Begin
      ParseLn(Line,W,XX,YY);
      Case Upcase(W[1]) Of
        'L':Begin
              Inc(Loc);
              LocalX[Loc]:=Valu(XX);
              LocalY[Loc]:=Valu(YY);
            End;
       'R':Begin
             Inc(Rem);
             RemoteX[Rem]:=Valu(XX);
             RemoteY[Rem]:=Valu(YY);
           End;
      End; {end case}
    End; {end <>';'}
  End; {end while}
  Close(T);
End;

Procedure SplitScreenChat;
type posrec = record
       LocalX : integer;
       LocalY : integer;
       RemoteX : integer;
       RemoteY : integer;
       localStr : string;
       remoteStr : string;
       LastLocal : boolean;
     end;

const
  memopad = 'memo.pad';
  barpos = 12;
  SpinChar : Array [1..4] of Char = ('Ä','\','³','/');

var
  FKey,FromKbd,localtest : boolean;
  st: string;
  st2 : string;
  k,ch : char;
  TimeStarted,i: integer;


procedure midline;
 begin
   GoXY(1,12);
   Print('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ '+timestr(now)+' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
   GoXY(trunc((20-length(CNF^.sysopname))/2),12);  Print ('Ä '+CNF^.sysopname+' Ä');
   GoXY(trunc((24-length(urec^.handle))/2)+55,12); Print ('Ä '+urec^.handle+' Ä');
 end;


Function ReadKeySpin(Wait : Byte) : Char;
Var
  X,Y  : Byte;
  Num  : Byte;
  Ch   : Char;
begin
  Num := 1;                               (* initialize SpinChars  *)
  X   := WhereX;                          (* Where am I ??         *)
  Y   := WhereY;
  Repeat
    Write(SpinChar[Num]);           (* Spin the Cursor       *)
    GotoXY(X, Y);                   (* Go back               *)
    Delay(Wait);                    (* Wait, it's to fast!   *)
    Write(#32);                     (* Clean Screen          *)
    GotoXY(X, Y);                   (* Go back               *)
    Inc(Num);                       (* Next SpinChar, please *)
    if Num = 5 then Num := 1;       (* I have only 5 Chars   *)
  Until KeyPressed;
  Ch := ReadKey;                    (* Get the pressed Key   *)
  if (ch <> #9) and (ch <> #27) and (ch <> #13) then Write(Ch);                      (* and Write it to screen*)
  ReadKeySpin := Ch;                (* give a result         *)
end;

Function ReadStringSpin (var out:boolean):  Str80;
Var
  Help : String;
  Ch   : Char;
  i    : Byte;
begin
  Out:=false;
  Help := '';
  Repeat
    if WhereX = 79 then GotoXY (78, WhereY);
    Ch := ReadKeySpin(50);
    if ch = #60 then out := true
    else if (Ch <> #13) and (WhereX < 78) and (Ch<>#9) and (Ch<>#27)
    then Help := Help + Ch;
  Until (Ch = #13) or (ch = #9) or (ch = #27);
  ReadStringSpin := Help;
  if  (ch = #9) or (Ch=#27) then out := true;
end;

PROCEDURE WordWrap(VAR S,S1:string);
VAR I,B:Byte;
Begin
  S1:='';
  I:=Length(S)+1;
  Repeat Dec(I); Until (S[I]=#32) or (I=0);
  If I=0 then Exit;
  For B:=I+1 to Length(S) do S1:=S1+S[B];
  Repeat Dec(S[0]); Until (Length(S)=I);
  Dec(S[0]);
End;

procedure Init (var pos: posrec);
begin
  with pos do
  begin
    localX := 1;
    localY := 1;
    remoteX := 1;
    remoteY := 13;
    localStr := '';
    remoteStr := '';
    LastLocal := true;
  end;
end;

procedure DrawScreen;
var
  i : integer;
begin
  GotoWindow(1);
  Cls;
  MidLine;
  gotoXY (1, 24);
  TextColor(CNF^.SysLineColor);
  for i := 1 to 5 do Write('Ä');
  TextColor(CNF^.SysNormalColor);
  Write(' [ Split-Screen Chat (F1/Exit) (F2/Menu) (F3/Memo) ] ');
  TextColor(CNF^.SysLineColor);
  repeat Write ('Ä'); until WhereX = 80;
  GoXY(1,1);
  TextColor(Urec^.RegularColor);
  TextColor(15);
end;

function ReadCharacter(var ch : char): boolean;
begin
  Repeat Until CharPressed;
  FromKbd:=KeyPressed;
  Case FromKBd Of
     True:Begin
            K:=ReadKey;
            If K=#0 then
            Begin
              K:=Readkey;
              FKey:=True;
            End else FKey:=False;
            ReadCharacter:=True;
          End;
     False:Begin
             GetChar(K);
             ReadCharacter:=False;
           End;
  End;
  Ch:=K;
End;

Procedure DoCr;
Begin
  Print(#27+'[B'); ClsEol; Print(#27+'[A');
End;

procedure PressEnter (var x, y: integer; ending: integer; var str: string);
Var SavX,SavY:Byte;
begin

  SavX:=WhereX; SavY:=WhereY;
  Gotoxy(SavX,SavY);

  Println('');
  x := 0;
  if Y = ending then
  begin
    GoXY (1,ending - 10);
    Y:=ending - 10;
    ClsEol;
    DoCr;
  end else
  Inc(Y);
  if Y <> ending then DoCr else ClsEol;
  str := '';
end;

procedure DoMemo;
var
  I,savecol : byte;
  memo: text;
  exit : boolean;
  s: str80;

begin
  Savecol := TextAttr;
  Print(#27+'[s');
  gotoXY (1, 24);
  TextColor(CNF^.SysLineColor);
  for i := 1 to 5 do Print('Ä');
  TextColor(CNF^.SysNormalColor);
  Write(' [ Memo Editor (ESC/Exit) ] ');
  TextColor(CNF^.SysLineColor);
  repeat Write('Ä'); until WhereX = 80;
  Assign (memo, memopad);
  if Exist(memopad) then Append (memo) else Rewrite (memo);

  repeat
    GotoXY (1, 24);
    TextColor(CNF^.SysTopColor);
    ClrEol;
    s:=ReadStringSpin (exit);
    writeln(memo, s);
  until exit;
  close(memo);
  gotoXY (1, 24);
  TextColor(CNF^.SysLineColor);
  for i := 1 to 5 do Write('Ä');
  TextColor(CNF^.SysNormalColor);
  Write(' [ Split-Screen Chat (F1/Exit) (F2/Menu) (F3/Memo) ] ');
  TextColor(CNF^.SysLineColor);
  repeat Write('Ä'); until WhereX = 80;
  TextColor(SaveCol);
  Print(#27+'[u');
end;

function Output (local : boolean;ch: char; var pos: posrec): boolean;
Var SavX,SavY,I:Byte;
   Keys:Byte;
begin
  Output := false;
  If Local Then
  Begin
    Keys:=Ord(Ch);
    If FKey Then
    Begin
      Case Keys Of
        59: OutPut:=True;
        60: OutPut:=True;
        61: DoMemo;
      End;
      Ch:=#0;
    End;
  End;

  SavX:=WhereX; SavY:=WhereY;
  GotoXy(SavX,SavY);

begin
    {Local Typer}
    if local then
    begin

      if pos.lastlocal=false then 
      Begin
        GoXY (pos.localX, pos.localY);
        AColor(Urec^.RegularColor);
      End;

      if ch = #8 then if not (pos.LocalX = 1) then
      begin
        Print(#8+' ');
        pos.LocalX := Pos.LocalX - 2;
      end;

      {Enter was pressed}
      if ch = #13 then
      begin
        PressEnter (Pos.LocalX, Pos.LocalY, 11, Pos.LocalStr);
      end
      else

      {local word wrap}
      if pos.LocalX = 79 then
      begin
        st := '';
        wordwrap (pos.localstr, st);
        for i := 1 to length (st) do Print (#8+' '+#8);
        PressEnter (pos.localX, Pos.localY, 11, Pos.LocalStr);
        Print (st);
        pos.LocalX := length (st) + 1;
      end;
      pos.localstr := pos.localstr + ch;
      If (Ch<>#13) and (Ch<>#0) then Print(ch);
      pos.LocalX := pos.LocalX + 1;
      pos.lastlocal := true;

    {Remote Typer}
    end
   else
    begin

      if pos.lastlocal=true then 
      Begin
        GoXY(pos.remoteX, pos.remoteY);
        AColor(Urec^.InputColor);
      End;

      if ch = #8 then if not (pos.remoteX = 1) then
      begin
        Print (#8+' ');
        pos.remoteX := Pos.remoteX - 2;
      end;

      {Enter was pressed}
      if ch = #13 then
      begin
        PressEnter (Pos.remoteX, Pos.remoteY, 23, Pos.remoteStr);
      end else

      {remote word wrap}
      if pos.remoteX = 79 then
      begin
        st := '';
        wordwrap (pos.remotestr, st);
        for i := 1 to length (st) do
          Print (#8+' '+#8);
        PressEnter (pos.remoteX, Pos.remoteY, 23, Pos.remoteStr);
        Print (st);
        pos.remoteX := length (st) + 1;
      end;
      pos.remotestr := pos.remotestr + ch;
      if (ch<>#13) then Print(ch);
      pos.remoteX := pos.remoteX + 1;
      pos.lastlocal := false;
    end;
  end;
end;

{--------------------------------------}
var
  done : boolean;
  Local : boolean;
  pos : posrec;

begin
  DrawScreen;
  Init(pos);
  repeat
    Local:=ReadCharacter(ch);
    Done:=Output(Local,ch,pos);
  until done;
  Cls;
  GotoWindow(2);
End;

Begin
End.