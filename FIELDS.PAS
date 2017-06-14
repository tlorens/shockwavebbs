Unit Fields;

Interface

uses OpCrt;

Type FldRec=Record
      FID,
      XPos,
      YPos,
      FG,
      BG,
      Up,
      Dn,
      Lf,
      Rt,
      Enter,
      Len:Byte;
      Fld,
      Hlp:String;
     End;

Const MaxFields=50;

Type FieldArr=Array[1..MaxFields] Of FldRec;

Var Field:^FieldArr;
    FieldCnt:Byte;

Procedure AddField(I,X,Y,F,B,U,D,L,R,Ent,Ln:Byte; Fd,H:String);
Procedure EditFields;

Implementation

Procedure BackSpace(X,Y,Int:Integer);
Var I:Integer;
Begin
 GotoXY(X,Y);
 For I:=1 to Int do Write(' ');
 For I:=Int downto 1 do  Write(^H);
End;


Function Edit(Var S:String; X,Y,F,B,Len:Byte; MultiFields:Boolean):Char;
Var Done,InsertMode:Boolean;
    Ch:Char;
    Holder:String;
    CurPos:Integer;
    
  Procedure StripEndSpaces;
  Var Index:Byte;
  Begin
    Index:=Length(S);
    While S[Index]=' ' Do
    Begin
      Delete(S,Index,1);
      Dec(Index);
    End;
  End;

  Procedure UpdateToEOL;
  Var I:Byte;
  Begin
    For I:=CurPos To Length(S) Do Write(S[I]);
    For I:=Length(S) To Len-1 Do Write(' ');
  End;

  Procedure Update;
  Var I:Byte;
  Begin
    For I:=CurPos To Length(S) Do Write(S[I]);
  End;

  Procedure Back_Space;
  Begin
    If (CurPos>1) Then
    Begin
      Dec(CurPos);
      Delete(S,CurPos,1);
      Write(^H+' '+^H);
      Update; Write(' ');
    End;
  End;

  Procedure DelChar;
  Begin
    Delete(S,CurPos,1);
    UpDate; Write(' ');
  End;

  Procedure UpDateCursorPos;
  Begin
    If CurPos<1 Then CurPos:=1;
    If CurPos>Len Then CurPos:=Len;
    GotoXY(CurPos+(X-1),Y);
  End;

  Procedure ClearLine;
  Begin
    CurPos:=1;
    UpDateCursorPos; S:='';
    UpDateToEOL;
  End;

  Procedure Typer;
  Begin
    If Length(S)<>Len Then
    Begin
      If InsertMode Then
      Begin
        Insert(Ch,S,CurPos);
        Update;
      End
     Else
      Begin
        Write(Ch);
        S[CurPos]:=Ch;
      End;
      If CurPos>=Length(S) Then S[0]:=Chr(CurPos);
      Inc(CurPos);
    End;
  End;

  Procedure ExitCode(C:Char);
  Begin
    Done:=True;
    Edit:=C;
  End;

Begin
  Done:=False; InsertMode:=True;
  Holder:=S;

  CurPos:=1;
  GotoXY(X,Y); TextColor(F);
  TextBackGround(B);
  UpdateToEol;
  CurPos:=Length(S)+1;
  UpdateCursorPos;

  Repeat
    Ch:=ReadKey;

    If Ch=#0 Then
    Begin
      Ch:=ReadKey;
      Case UpCase(Ch) Of
        #80:ExitCode(#80); (*Up*)
        #72:ExitCode(#72); (*Down*)
        #71:CurPos:=1;     (*Home*)
        #75:Dec(CurPos);   (*Left*)
        #77:Inc(CurPos);   (*Right*)
        #79:CurPos:=Length(S)+1; (*End*)
        #83:DelChar;
      End;  
    End
   Else
    Case Ch Of
      #1:CurPos:=1;        (*Home*)
      #8:Back_Space;
      #13:ExitCode(#13);
      #26:CurPos:=Length(S)+1; (*End*)
       ^Q:ExitCode(^Q);
       ^S:Dec(CurPos);     (*Left*)
       ^D:Inc(CurPos);     (*Right*)
       ^V,#82:InsertMode:=Not InsertMode;
       ^Y:ClearLine;
      Else Typer;
    End;  
    UpdateCursorPos;
  Until (Done);
  StripEndSpaces;
  TextColor(7);
  TextBackGround(0);
  BackSpace(X,Y,Len);
  Write(S);
End;

Procedure AddField(I,X,Y,F,B,U,D,L,R,Ent,Ln:Byte; Fd,H:String);
Begin
  With Field^[I] Do
  Begin
    FID:=I;
    XPos:=X;
    YPos:=Y;
      FG:=F;
      BG:=B;
      Up:=U;
      Dn:=D;
      Lf:=L;
      Rt:=R;
     Enter:=Ent;
     Len:=Ln;
     Fld:=Fd;
     Hlp:=H;
  End;
End;

Procedure EditFields;
Var C:Char;
   CurField:Byte;
   Quit:Boolean;
Begin
  CurField:=1;
  Quit:=False;
  Repeat
    With Field^[CurField] Do C:=Edit(Fld,Xpos,Ypos,Fg,Bg,Len,True);
    Case C Of
      #80:CurField:=Field^[CurField].Dn;
      #72:CurField:=Field^[CurField].Up;
      #77:CurField:=Field^[CurField].Rt;
      #75:CurField:=Field^[CurField].Lf;
       ^Q:Quit:=Not Quit;
      #13:CurField:=Field^[CurField].Enter;
    End;
  Until Quit;
End;

Begin
End.