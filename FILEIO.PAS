UNIT FileIO;
{$I-,X+,O-,F-}
INTERFACE

USES Dos;  { Exist Function }

TYPE
  FileRec  = Record
    Handle   : Word;
    LockFile : Boolean;
    Mode     : Byte;
    FilePos  : LongInt;
    Open     : Boolean;
  End;

FUNCTION Reset(S:String; VAR F:FileRec; Mode:Byte):Integer;
FUNCTION Rewrite(S:String; VAR F:FileRec; Mode:Byte):Integer;
FUNCTION Close(VAR F:FileRec):Integer;
FUNCTION LockFile(VAR F:FileRec; Start,Stop:LongInt; LockType:Byte):Integer;
FUNCTION Flush(VAR F:FileRec):Integer;
FUNCTION Truncate(VAR F:FileRec):Integer;
FUNCTION BlockRead(VAR F:FileRec; S,O:Word; Bytes:Integer; VAR Read:Integer):Integer;
FUNCTION BlockWrite(VAR F:FileRec; S,O:Word; Bytes:Integer):Integer;
FUNCTION Seek(VAR F:FileRec; Loc:LongInt):Integer;
FUNCTION SeekEof(VAR F:FileRec):Integer;
FUNCTION FileSize(VAR F:FileRec):LongInt;
FUNCTION FilePos(VAR F:FileRec):LongInt;
PROCEDURE SetLock(VAR F:FileRec; Lock:Boolean);
FUNCTION DeleteRec(VAR F:FileRec; RecNum,RecSize:Integer):Boolean;
FUNCTION Erase(F:String):Boolean;

CONST
     NoLock     = 2;
     EntireLock = 2;  { 16 or 2 }
     DenyWrite  = 2;  { 48 or 1 }
     DenyRead   = 2;  { 32 }
     RandomLock = 2;
     Lock       = 0;
     Unlock     = 1;

IMPLEMENTATION

CONST Tries:Integer=0;

TYPE
  LongIntArr=Array[1..2] of Word;

FUNCTION Cflag(VAR Regs:Registers):Boolean;
Begin
  Cflag:=(Regs.Flags AND 1>0);
End;

Function Exist(Filename:string):boolean;
{returns true if file exists}
var Inf: SearchRec;
begin
    FindFirst(Filename,AnyFile,Inf);
    Exist := (DOSError = 0);
end;  {Func Exist}


FUNCTION Reset(S:String; VAR F:FileRec; Mode:Byte):Integer;
VAR Regs:Registers;
Begin
  Reset:=$FF;
  If Not Exist(S) then Exit;  { Keeps Lans from Locking Up }
  F.Handle:=0;
  F.LockFile:=(Mode<>NoLock);
  F.Mode:=Mode;
  F.FilePos:=0;
  F.Open:=False;
  Repeat
    Regs.Ah:=$3D;
    Regs.Al:=Mode;
    S[Length(S)+1]:=#0;
    Regs.Ds:=Seg(S);
    Regs.Dx:=Ofs(S)+1;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then Reset:=Regs.Ax else
    Begin
      F.Handle:=Regs.Ax;
      F.Open:=True;
      Reset:=0;
    End;
End;

FUNCTION Rewrite(S:String; VAR F:FileRec; Mode:Byte):Integer;
VAR Regs:Registers; I:Integer;
Begin
  F.Handle:=0;
  F.LockFile:=(Mode<>NoLock);
  F.Mode:=Mode;
  F.FilePos:=0;
  F.Open:=False;
  Repeat
    Regs.Ah:=$3C;
    Regs.Cx:=$00;
    Regs.Ds:=Seg(S);
    Regs.Dx:=Ofs(S)+1;
    S[Length(S)+1]:=#0;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then Rewrite:=Regs.Ax else
    Begin
      F.Handle:=Regs.Ax;
      F.Open:=True;
      Close(F);
      Rewrite:=Reset(S,F,Mode);
    End;
End;

FUNCTION Close(VAR F:FileRec):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      Close:=127;
      Exit;
    End;
  Repeat
    Regs.Ah:=$3E;
    Regs.Bx:=F.Handle;
    Intr($21,Regs);
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  if Cflag(Regs) then Close:=Regs.Ax else
    Begin
      Close:=0;
      F.Open:=False;
    End;
End;

FUNCTION LockFile(VAR F:FileRec; Start,Stop:LongInt; LockType:Byte):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      LockFile:=127;
      Exit;
    End;
  Repeat
    Regs.Ah:=$5C;
    Regs.Al:=LockType;
    Regs.Bx:=F.Handle;
    Regs.Cx:=LongIntArr(Start)[1];
    Regs.Dx:=LongIntArr(Start)[2];
    Regs.Si:=LongIntArr(Stop)[1];
    Regs.Di:=LongIntArr(Stop)[2];
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then LockFile:=Regs.Ax else LockFile:=0;
End;

FUNCTION Flush(VAR F:FileRec):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      Flush:=127;
      Exit;
    End;
  repeat
    Regs.Ah:=$68;
    Regs.Bx:=F.Handle;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then Flush:=Regs.Ax else Flush:=0;
End;

FUNCTION Truncate(VAR F:FileRec):Integer;
Begin
End;

FUNCTION BlockRead(VAR F:FileRec; S,O:Word; Bytes:Integer; VAR Read:Integer):Integer;
CONST Error:Boolean=False;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      BlockRead:=127;
      Exit;
    End;
  If F.LockFile then LockFile(F,F.FilePos,F.FilePos+Bytes,Lock);
  Repeat
    Regs.Ah:=$3F;
    Regs.Bx:=F.Handle;
    Regs.Cx:=Bytes;
    Regs.Ds:=S;
    Regs.Dx:=O;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If F.LockFile then LockFile(F,F.FilePos,F.FilePos+Bytes,UnLock);
  If Error then Exit;
  Read:=0;
  If Cflag(Regs) then BlockRead:=Regs.Ax else
    Begin
      Read:=Regs.Ax;
      F.FilePos:=F.FilePos+Regs.Ax;
      BlockRead:=0;
    End;
End;

FUNCTION BlockWrite(VAR F:FileRec; S,O:Word; Bytes:Integer):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      BlockWrite:=127;
      Exit;
    End;
  If F.LockFile then LockFile(F,F.FilePos,F.FilePos+Bytes,Lock);
  Repeat
    Regs.Ah:=$40;
    Regs.Bx:=F.Handle;
    Regs.Cx:=Bytes;
    Regs.Ds:=S;
    Regs.Dx:=O;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If F.LockFile then LockFile(F,F.FilePos,F.FilePos+Bytes,UnLock);
  If Cflag(Regs) then BlockWrite:=Regs.Ax else
    Begin
      BlockWrite:=0;
      F.FilePos:=F.FilePos+Regs.Ax;
    End;
End;

FUNCTION Seek(VAR F:FileRec; Loc:LongInt):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      Seek:=127;
      Exit;
    End;
  Repeat
    Regs.Ah:=$42;
    Regs.Al:=$00;
    Regs.Bx:=F.Handle;
    Regs.Cx:=Word(Loc shl 16);
    Regs.Dx:=Word(Loc);
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then Seek:=Regs.Ax else
    Begin
      Seek:=0;
      F.FilePos:=(Regs.Dx shl 16) or Regs.Ax;
    End;
End;

FUNCTION SeekEof(VAR F:FileRec):Integer;
VAR Regs:Registers;
Begin
  If Not F.Open then
    Begin
      SeekEof:=127;
      Exit;
    End;
  Repeat
    Regs.Ah:=$42;
    Regs.Al:=$02;
    Regs.Bx:=F.Handle;
    Regs.Cx:=0;
    Regs.Dx:=0;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then SeekEof:=Regs.Ax else
    Begin
      F.FilePos:=LongInt((Regs.Dx shl 16) or Regs.Ax);
      SeekEof:=0;
    End;
End;

FUNCTION FileSize(VAR F:FileRec):LongInt;
VAR Loc:LongInt;
    Regs:Registers;
Begin
  If Not F.Open then
    Begin
      FileSize:=$FFFFFFFF;
      Exit;
    End;
  Loc:=F.FilePos;
  Repeat
    Regs.Ah:=$42;
    Regs.Al:=$02;
    Regs.Bx:=F.Handle;
    Regs.Cx:=0;
    Regs.Dx:=0;
    MsDos(Regs);
  Until Not ((Cflag(Regs)) and (Regs.Ax=$05));
  If Cflag(Regs) then
    Begin
      FileSize:=$FFFFFFFF;
      Seek(F,Loc);
    End else
    Begin
      FileSize:=LongInt((Regs.Dx shl 16) or Regs.Ax);
      Seek(F,Loc);
    End;
End;

FUNCTION FilePos(VAR F:FileRec):LongInt;
Begin
  FilePos:=F.FilePos;
End;

PROCEDURE SetLock(VAR F:FileRec; Lock:Boolean);
Begin
  F.LockFile:=Lock;
End;

FUNCTION DeleteRec(VAR F:FileRec; RecNum,RecSize:Integer):Boolean;
VAR Position:LongInt;
    P:Pointer;
    L,I:Integer;
    Err:Boolean;
Begin
  DeleteRec:=False;
  If not F.Open then Exit;
  Position:=F.FilePos;
  GetMem(P,RecSize);
  Err:=False;
  If Not (RecNum-1=FileSize(F) div RecSize) then
    For I:=RecNum to (FileSize(F) div RecSize) do
      Begin
        If Seek(F,I*RecSize)<>0 then Err:=True;
        If BlockRead(F,Seg(P^),Ofs(P^),RecSize,L)<>0 then Err:=True;
        If L<>RecSize then Err:=True;
        If Seek(F,(I-1)*RecSize)<>0 then Err:=True;
        If BlockWrite(F,Seg(P^),Ofs(P^),RecSize)<>0 then Err:=True;
        If Err then Exit;
      End;
  FreeMem(P,RecSize);
  If Err then Exit;
  If Seek(F,FileSize(F)-RecSize)<>0 then Exit;
  If Truncate(F)<>0 then Exit;
  If Seek(F,Position)<>0 then Exit;
  DeleteRec:=True;
End;

FUNCTION Erase(F:String):Boolean;
VAR Regs:Registers;
Begin
  Regs.Ah:=$41;
  Regs.Ds:=Seg(F);
  Regs.Dx:=Ofs(F)+1;
  F[Length(F)+1]:=#0;
  Intr($21,Regs);
  Erase:=Cflag(Regs);
End;

End.
