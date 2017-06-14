Program ScreenEdit;

Uses OpCrt,Dos,Fields;

Var CurX,CurY:Byte;
    CurField:Byte;

Procedure Beep;
Begin
  Sound(1000);
  delay(10);
  NoSound;
End;

Function Check:Boolean;
Var X:Byte;
Begin
  Check:=False;
  For X:=1 to FieldCnt Do
    If (Field^[X].XPos=WhereX) and (Field^[X].YPos=WhereY) Then 
    Begin
      Check:=True;
      CurField:=X;
      Exit;
    End 
   Else 
    Begin
      Check:=False;
      CurField:=0;
    End;
End;

Procedure AddFld;
Begin
  If (FieldCnt<MaxFields) and (Not Check) Then 
  Begin
    Inc(FieldCnt);
    Write('þ',^H);
    AddField(FieldCnt,WhereX,WhereY,15,1,FieldCnt-1,FieldCnt+1,FieldCnt-1,FieldCnt+1,FieldCnt+1,10,'','');
  End Else Beep;
End;

Procedure DelFld;

  Procedure ReNumber;
  Var X:Byte;
  Begin
    For X:=CurField To FieldCnt Do
    Begin
    End;
  End;

Begin
  If (FieldCnt>0) And (Check) Then 
  Begin
    FillChar(Field^[FieldCnt],SizeOf(Field),#0);
    Dec(FieldCnt);
    Write(' ',^H);
  End Else Beep;
End;

Procedure EdtFld;
Var HelpStr:String;
    
Begin
  HelpStr:='';
  If (FieldCnt>0) and (Check) Then
  Begin
    GotoXY(1,24); Write('Help String: ');
    AddField(1,WhereX,24,7,1,1,1,1,1,1,60,HelpStr,'');
    Field^[CurField].Hlp:=HelpStr;
    EditFields;
  End Else Beep;
End;

Procedure Save_Export;
Var X:Byte;
  Txt:Text;
Begin
  Assign(Txt,'SOURCE.OUT');
  ReWrite(TxT);
  For X:=1 To FieldCnt Do
    Writeln(Txt,'AddField(',X,',',Field^[X].XPos,',',Field^[X].YPos,
    ',15,1,',X-1,',',X+1,',',X-1,',',X+1,',',X+1,',10,'''',',Field^[X].Hlp,');');
  Close(TxT);
End;

Procedure Up;
Begin
  If CurY>1 Then Dec(CurY);
End;

Procedure Dn;
Begin
  If CurY<25 Then Inc(CurY);
End;

Procedure Lf;
Begin
  If CurX>1 Then Dec(CurX);
End;

Procedure Rt;
Begin
  If CurX<80 Then Inc(CurX);
End;

Procedure Main;
Var Done:Boolean;
    Ch:Char;
Begin
  ClrScr;
  CurX:=1;
  CurY:=1;
  FieldCnt:=0;
  Done:=False;
  New(Field);
  Repeat
    Ch:=ReadKey;
    If Ch=#0 Then 
    Begin
      Ch:=ReadKey;
      Case Ch Of
       #72:Up;
       #80:Dn;
       #75:Lf;
       #77:Rt;
       #30:AddFld; { Alt+A }
       #32:DelFld; { Alt+D }
       #18:EdtFld; { Alt+E }
      End;
    End 
   Else
    Case Ch Of
      #27:Done:=True;
    End;
    GotoXY(CurX,CurY);
  Until Done;
  Save_Export;
  Dispose(Field);
End;

Begin
  Main;
End.