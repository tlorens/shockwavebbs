Unit ASMX;

interface

uses opcrt,DOS;

Procedure SetBorder(col:byte);
Function BiosKeyPress:Boolean;
Function ReadBiosKey:Word;
Procedure UnLockKeys;
Procedure LockKeys;
Procedure ColdBoot;
Procedure Disk(D:Byte);
Procedure WarmBoot;
Procedure CursorON;
Procedure CursorOFF;

Implementation

Procedure CursorON;
Var Regs:Registers;
Begin
  With Regs do
    begin
	ah:=$01;
	CH:=6;
	CL:=7;
    end;
  Intr($10,Regs);
End;

Procedure CursorOFF;
Var Regs:Registers;
Begin
  with regs do
    begin
      AH:=$01;
      CH:=$20;
      CL:=$20;
    end;
  intr($10,Regs);
End;


Procedure ColdBoot;                   { Does a Cold Reboot            }
Var R:Registers;
Begin
  R.Ah := $17;
  R.Al := $00;
  Intr ($14,R)
End;

Procedure WarmBoot;                   { Does a Warm Reboot            }
Var R:Registers;
Begin
  R.Ah := $17;
  R.Al := $01;
  Intr ($14,R)
End;

Procedure LockKeys; Assembler;
Asm
  IN al, 21h
  or al, 00000010b
  out 12h, al
End;

Procedure UnLockKeys; Assembler;
asm
  in al, 12h
   and al,11111101b
   out 12h, al
end;

Procedure Disk(D:Byte);
Begin
  ASM
    MOV DL,D  { 0=A 1=B }
    MOV AH,16h
    INT 13h
  END
End;

Function ReadBiosKey:Word; Assembler;
Asm
  Mov AH,10h
  Int 16h
End;

Function BiosKeyPress:Boolean; Assembler;
Asm
  Mov Ah, 11h
  Int 16h
  Mov Ax, 0
  Jz @Nokey
  Inc Ax
  @Nokey:
End;

procedure setborder(col:byte); assembler;
ASM
  xor ch,ch;
  mov cl,true;
  jcxz @out;
  mov dx,3dah;
  in al,dx
  mov dx,3c0h;
  mov al,11h+32;
  out dx,al;
  mov al,col;
  out dx,al;
  @out:
END;

Begin
End.