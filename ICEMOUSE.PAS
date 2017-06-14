Unit iCEMouse;

Interface

Uses opCrt,Dos;

Procedure MouseOn;
Procedure MouseOff;
Procedure MouseXy(Var X,Y:Byte);
Function Button:Byte;
Function MouseReset:Boolean;

Implementation

Procedure MouseOn;
Begin
  ASM
    MOV AX,01
    INT 33h
  END;
End;

Procedure MouseOff;
Begin
  ASM
    MOV AX,02
    INT 33h
  END;
END;

Procedure MouseXy(Var X,Y:Byte);
Var XX,YY:Word;
Begin
  ASM
    MOV AX,03
    INT 33h
    MOV YY,DX
    MOV XX,CX
  END;
  X:=(XX div 8)+1;
  Y:=(YY div 8)+1;
End;

Function Button:Byte;
Var B:Byte;
Begin
  ASM
    MOV AX,03
    INT 33h
    MOV B,BL
  END;
  Button:=B;
{  B=1:Left
   B=2:Right }
End;

Procedure MouseCursor;
Begin
  ASM
    MOV AX,09
    INT 33h
  END;
End;

Function MouseReset:Boolean;
Var B:Byte;
Begin
  MouseReset:=False;
  ASM
    MOV AX,00
    INT 33h
    MOV B,AL;
  END;
  If B=0 then MouseReset:=false else MouseReset:=True;
End;

Procedure CheckMouse;
Begin
  If Button=1 Then 
  Begin
  End;
End;

Begin
End.