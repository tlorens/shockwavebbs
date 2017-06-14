Unit ICEIO1;

interface

Uses opCrt,Dos,FastTTT5;

Const
      iCEIOVerNum='  iCEIO:0.03  ';
     iCEIOVerDate='  iCEIO:05/31/95  ';

Type
    Str1 = string[1];
    Str2 = string[2];
    Str15 = string[15];
    Str30 = string[30];
    Str79 = string[79];

FUNCTION GetKey : Str2;
PROCEDURE AdaptorType;
PROCEDURE CursorOff;
PROCEDURE CursorOn;
PROCEDURE BlockCursorOn;
PROCEDURE ReverseVideo;
PROCEDURE BlinkOn;
PROCEDURE Pad(VAR LineToPad : str79; PadLength : byte);
PROCEDURE Strip (VAR LineToStrip :  str79);
PROCEDURE EditLine(VAR line:string; VAR cursor:byte; col,row,fieldlength:byte; VAR exit_key:str2; Usefields:Boolean;
                   DisType:Byte);
Procedure Add_Field(ID,XX,YY,Len:Byte; Var S:String; Msg:String; ZZ,WW:Byte);
Procedure EditField(ID:Byte; Var X:String; T:Byte);
Procedure NextField;
Procedure PrevField;
Function EditFields(T:Byte):String;
Procedure Display_Fields(DisType:Byte);
Function Upstring(S:String):String;
Function Boo_To_Str(B:Boolean):String;
Function Str_To_Boo(S:String):Boolean;
Function Int_to_Str(Number:longint):string;
Function Str_To_Word(Str:String):Word;
Function Exist(Filename:string):boolean;
Procedure FadeIn(Ch:Char; X,Y:Byte);
Procedure SaveScreen;
Procedure RestoreScreen;
Implementation


Const InsertFlag:Boolean=True;
Type
  FieldRec=Record
      FieldID,
      X,Z,
      Y,W,
      FieldLen:Byte;
      Strg:^String;
      TempStr:String;
      Message:String[80];
  End;

  Screentype=Array[0..3999] of byte;

Var Field:Array[1..21] Of FieldRec;
    TotFields,
    LastField,
    CurField,
    LastUsed:Byte;
    Regs : Registers;
    ScreenBase : word;
    Monochrome : boolean;
    Abort,
    ExitFlag : boolean;
    SPtr: ^string;
    Screen:ScreenType;
    OldY,OldX:BYte;

Procedure FadeIn(Ch:Char; X,Y:Byte);
Begin
  GotoXy(X,Y); TextColor(8); Write(Ch); Delay(50);
  GotoXy(X,Y); TextColor(1); Write(Ch); Delay(50);
  GotoXy(X,Y); TextColor(9); Write(Ch); Delay(50);
  TextColor(15);
End;

Procedure ClearEol;
var X:Byte;
Begin
  CursorOff;
  For X:=1 to 78 Do FWrite(' ');
  CursorOn;
End;

Procedure WriteString(S:String);  (* Capible of running files *)
Var Pause,I:Integer;
    IncANSi:String[13];
    ExtFile:String;
    Chrs:String[2];

Begin
  TextColor(7);
  Pause:=-1;
  If Length(S)=0 then exit;
  I:=1;
  Repeat
    If s[i]='|' then
    Begin
	 Chrs:=Copy(s,i+1,2);
      If Chrs='UN' then Write('<User#>');
      If Chrs='UH' Then Write('<UserHandle>');
      If Chrs='UT' Then Write('<Timeleft>');
      If Chrs='BE' Then Write('<^G>') Else
      If Chrs='CL' Then Write('<Cls>') Else
      If Chrs='BA' Then Write('<BaudRate>') Else
      If Chrs='NU' Then Write('<NumUsers>') Else
      IF Chrs='DA' Then Write('<DateNow>');
      If Chrs='TI' Then Write('<TimeNow>');
	 If Chrs='01' Then TextColor(1) else
	 If Chrs='02' Then TextColor(2) else
	 If Chrs='03' Then TextColor(3) else
	 If Chrs='04' Then TextColor(4) else
	 If Chrs='05' Then TextColor(5) else
	 If Chrs='06' Then TextColor(6) else
	 If Chrs='07' Then TextColor(7) else
	 If Chrs='08' Then TextColor(8) else
	 If Chrs='09' Then TextColor(9) else
	 If Chrs='10' Then TextColor(10) else
	 If Chrs='11' Then TextColor(11) else
	 If Chrs='12' Then TextColor(12) else
	 If Chrs='13' Then TextColor(13) else
	 If Chrs='14' Then TextColor(14) else
	 If Chrs='15' Then TextColor(15) else
 	 If Chrs='RE' Then Write('<UsrRegC>') else
	 If Chrs='PR' Then Write('<UsrPromptC>') else
      If Chrs='IN' Then Write('<UsrInputC>') else
      If Chrs[1]='~' then Write('<delay'+Chrs[2]+'>') Else

      If Chrs='MB' Then Write('<MAreaName>') else
      If Chrs='MA' Then Write('<MAraCmd>') else
      If Chrs='CR' Then Write('<CR>') else

      If Chrs='RM' Then Write('<RndRumor>') else
      If Chrs='FA' Then Write('<CurFArea>') else
      If Chrs='FN' then Write('<CurFNum>)') else
      If Chrs='CC' Then Write('<CurConf>') else

      If Chrs='SY' Then Write('<SysName>') Else
      If Chrs='%%' Then
      Begin
        IncANSi:=Copy(S,i+3,12);
        Delete(S,I,Length(IncANSi));
        Write('inc: '+INCANSi);
      End
     Else
      If Chrs='@@' Then
      Begin
        ExtFile:=Copy(S,i+3,16);
        Delete(S,I,Length(ExtFile));
        Write('exec: '+ExtFile);
      End;
	 Inc(I,3);
	End
    Else
	Begin
	  Write(S[i]);
	  inc(i);
	End;
    Until I > Length(s);
  End;


Function Upstring(S:String):String;
Var Len:BYte;
   Tmp:String;
Begin
  Tmp:='';
  For Len:=1 to Length(S) do Tmp:=Tmp+Upcase(S[Len]);
  Upstring:=Tmp;
End;

Function Boo_To_Str(B:Boolean):String;
Var Temp:String[3];
Begin
  If B Then Temp:='Yes' Else Temp:='No ';
  Boo_To_Str:=Temp;
End;

Function Str_To_Boo(S:String):Boolean;
Var Temp:Boolean;
Begin
  If Upcase(S[1])='Y' Then Temp:=True Else Temp:=False;
  Str_To_Boo:=Temp;
End;

Function Exist(Filename:string):boolean;
var Inf: SearchRec;
begin
    FindFirst(Filename,AnyFile,Inf);
    Exist := (DOSError = 0);
end;

Procedure Add_Field(ID,XX,YY,Len:Byte; Var S:String; Msg:String; ZZ,WW:Byte);
Begin
  With Field[LastUsed] Do
  Begin
    FieldID:=ID;
    X:=XX;
    Y:=YY;
    Z:=ZZ;
    W:=WW;
    FieldLen:=Len;
    Strg:=ptr(seg(S),ofs(S));
    TempStr:=S;
    Message:=Msg;
  End;
 TotFields:=LastUsed;
 Inc(LastUsed);
End;

Procedure PrevField;
Begin
  If CurField<>1 Then Dec(CurField) Else CurField:=1;
  ClearLine(Field[CurField].Z,Field[CurField].W,1);
  WriteCenter(Field[CurField].Z,Field[CurField].W,1,Field[CurField].Message);
  ExitFlag := TRUE;
End;

Procedure NextField;
Begin
  If CurField<>TotFields Then Inc(CurField) Else CurField:=TotFields;
  ClearLine(Field[CurField].Z,Field[CurField].W,1);
  WriteCenter(Field[CurField].Z,Field[CurField].W,1,Field[CurField].Message);
  ExitFlag := TRUE;
End;

FUNCTION GetKey:Str2;
    VAR ch : char;
        t  : Str2;
  BEGIN
    ch:=ReadKey;
    t:=ch;
    IF (ch=#0) THEN
    BEGIN
      ch := ReadKey;
      t  := t + ch;
    END;
    GetKey := T
  END;

  PROCEDURE AdaptorType;
    BEGIN
      INTR (17,Regs);
      IF (Regs.AX AND $0030) = $30 THEN
        BEGIN
          ScreenBase := $b000;
          Monochrome := TRUE
        END
      ELSE
        BEGIN
          ScreenBase := $b800;
          Monochrome := FALSE
        END
    END; {of AdaptorType procedure}

  Procedure CursorSize(Size:Byte);
  Begin
    Regs.AH:=$01;
    Case Size Of
     0:Begin
         Regs.CH:=$20;
         Regs.CL:=$20;
       End;
     1:Begin
         Regs.CH:=$6;
         Regs.CL:=$7;
       End;
     2:Begin
         Regs.CH:=$3;
         Regs.CL:=$7;
       End;
    End;
    Intr($10,Regs);
  End;

  PROCEDURE CursorOff;
    BEGIN
      CursorSize(0);
    END; {of CursorOff procedure}

  PROCEDURE CursorOn;
    BEGIN
      CursorSize(1);
    END; {of NormCursorOn procedure}

  PROCEDURE BlockCursorOn;
    BEGIN
      CursorSize(2);
    END; {of BlockCursorOn procedure}

  PROCEDURE ReverseVideo;
    BEGIN
      TextColor(0);
      TextBackground (7);
    END; {of ReverseVideo procedure}

  PROCEDURE BlinkOn;
    BEGIN
      TextAttr := TextAttr + Blink;
    END;

   Procedure Pad(VAR LineToPad : str79; PadLength : byte);
   BEGIN
     WHILE Length (LineToPad) < PadLength DO LineToPad := LineToPad + ' ';
    END;

    PROCEDURE Strip (VAR LineToStrip :  str79);
    VAR index : byte;
    BEGIN
      index:=Length(LineToStrip);
      WHILE LineToStrip[index]=' ' DO
        BEGIN
          Delete(LineToStrip,index,1);
          Dec(index)
        END
    END;

{***************************************************************}
PROCEDURE EditLine(VAR line:string; VAR cursor:byte; col,row,fieldlength:byte; VAR exit_key:str2; Usefields:Boolean;
                   DisType:Byte);

  VAR
    key : str2;
    TempStr:String;

  PROCEDURE CursorRight;
    BEGIN
      Inc(cursor)
    END;

  PROCEDURE CursorLeft;         
    BEGIN
      Dec (cursor)
    END; {of CursorLeft procedure}

  PROCEDURE CursorFront;        
    BEGIN
      cursor := col;
    END; {of CursorFront procedure}

  PROCEDURE CursorEnd;          
    VAR
      position : byte;
    BEGIN
      If Length(Line)=0 then Exit;
      position:=Length(line);
      WHILE line[position] = ' ' DO
        Dec (position);
      cursor := col + position
    END; {of CursorEnd procedure}

  PROCEDURE WordRight;          
    VAR position : byte;
    BEGIN
      position := cursor - col + 1;
      WHILE line[position] <> ' ' DO
        BEGIN
          Inc(position);
          IF position = fieldlength THEN Exit;
        END;
      Inc (position);
      cursor := col + position - 1
    END; {of WordRight procedure}

  PROCEDURE WordLeft;           
    VAR position : byte;
    BEGIN
      position := cursor - col + 1;
      WHILE (line[position] <> ' ') AND (position >= 1) DO
        Dec (position);
      WHILE (line[position] = ' ') AND (position >= 1) DO
        Dec (position);
      WHILE (line[position] <> ' ') AND (position >= 1) DO
          Dec (position);
      cursor := col + position - 1;
      IF cursor > col THEN Inc (cursor)
    END; {of WordLeft procedure}

  PROCEDURE BackSpace;          
    VAR
      position : byte;
    BEGIN
      IF cursor < col THEN cursor := col;
      If Cursor=Col then Exit;
      position := cursor - col + 1;
      Delete (line, position - 1, 1);
      CursorLeft;
      line := line + ' '
    END; {of BackSpace procedure}

  PROCEDURE DeleteChar;         
    VAR
      position : byte;
    BEGIN
      position := cursor - col + 1;
      Delete (line, position, 1);
      line := line + ' '
    END; {of DeleteChar procedure}

  PROCEDURE DeleteWord;         
    VAR
      position : byte;
    BEGIN
      position := cursor - col + 1;
      REPEAT
        DeleteChar
      UNTIL (COPY(line, position, 1) = ' ');
      DeleteChar
    END; {of DeleteWord procedure}

  PROCEDURE DeleteEOL;          
    VAR
      count, position : byte;
    BEGIN
      position := cursor - col + 1;
      count := FieldLength - position + 1;
      Delete (line, position, count);
      Pad (line, FieldLength)
    END; {of DeleteEOL procedure}

  PROCEDURE ToggleInsert;       
    BEGIN
      IF InsertFlag=TRUE THEN
      Begin
        InsertFlag := FALSE;
        CursorOn;
      End
     ELSE
      IF InsertFlag=FALSE THEN
      Begin
        InsertFlag := TRUE;
        BlockCursorOn;
      End;
    END; {of ToggleInsert procedure}

  PROCEDURE InsertChar;         
    VAR
      character : str1;
      position : byte;
    BEGIN
      position := cursor - col + 1;
      Delete (line, fieldlength,1);
      character := key[1];
      Insert (character, line, position);
      CursorRight
    END; {of InsertChar procedure}

  PROCEDURE ReplaceChar;        
    VAR
      position : byte;
    BEGIN
      position := cursor - col + 1;
      line[position] := key[1];
      CursorRight;
    END; {of ReplaceChar procedure}

  PROCEDURE PositionCursor;     
    BEGIN
      IF cursor < col THEN cursor := col;
      IF cursor > col + fieldlength - 1 THEN cursor:=FieldLength+Col-1;
      Gotoxy (cursor, row);
      IF InsertFlag = TRUE THEN
        BlockCursorOn
      ELSE
        CursorOn;
    END; {of PositionCursor procedure}

  PROCEDURE ExtendedCodes;      
    BEGIN
      CASE key[2] OF
        #68:  Begin Abort:=True; ExitFlag:=True; Key:=#68; End;
        #71:  CursorFront; {Home}
        #72:  IF UseFields Then PrevField;
        #73:  Begin Abort:=True; ExitFlag:=True; Key:=#73; End;
        #75:  CursorLeft; {left arrow}
        #77:  CursorRight; {right arrow}
        #79:  CursorEnd; {End}
        #80:  IF UseFields Then NextField;
        #82:  ToggleInsert; {Ins}
        #83:  DeleteChar; {Del}
        #81:  Begin Abort:=True; ExitFlag:=True; Key:=#81; End;
        #115: WordLeft; {Ctrl-left arrow}
        #116: WordRight; {Ctrl-right arrow}
      ELSE
        ExitFlag := TRUE
      END; {of CASE statement}
    END; {of ExtendedCodes procedure}

  PROCEDURE ControlCodes;       
  Var Z:Byte;
    BEGIN
      CASE key[1] OF
        #8:   BackSpace; {Backspace}
        #5:   DeleteEOL;  {Ctrl-E}
        #23:  DeleteWord; {Ctrl-W}
        #27:  Begin
                Abort:=True;
                ExitFlag:=True;
              End;
        #68:  Begin
                Abort:=True;
                ExitFlag:=True;
                Line:=TempStr;
              End;
      ELSE
        Begin
          ExitFlag := TRUE;
          IF UseFields Then NextField;
        End;
      END; {of CASE statement}
    END; {of ControlCodes procedure}

  PROCEDURE ActOnKeypress;            
    BEGIN
      IF Length(key)=2 THEN Extendedcodes ELSE
      BEGIN
        IF key[1] IN [#0..#31] THEN ControlCodes;
        IF key[1] IN [#32..#254] THEN
        BEGIN
          IF InsertFlag = TRUE THEN InsertChar ELSE ReplaceChar
        END
      END;
    END; {of ActOnKeypress procedure}

  PROCEDURE GetKeypress;        
    BEGIN
      key := GetKey
    END; {of GetKeypress procedure}

  PROCEDURE DisplayLine;        
    BEGIN
      CursorOff;
      If Col>78 Then Col:=78;
      FastWrite(Col,Row,7,Line);
    END;

  BEGIN
    Cursor:=0;
    ExitFlag := FALSE;
    TempStr:=Line;
    SPtr:=@Line;
    Pad(Line,FieldLength);
    CursorEnd;
    WHILE ExitFlag = FALSE DO
      BEGIN
        DisplayLine;
        PositionCursor;
        GetKeypress;
        ActOnKeypress;
      END;
    Strip(line);
    IF DisType=1 Then
    Begin
      GotoXy(Col,Row);
      ClearEol;
      GotoXy(Col,Row);
      WriteString(Line);
    End;
    exit_key := key;
    cursoron;
  END;

Procedure EditField(ID:Byte; Var X:String; T:Byte);
Var Cur:Byte;
    Xit:String;
Begin
  Cur:=1;
  With Field[ID] Do EditLine(Strg^,Cur,X,Y,FieldLen,Xit,True,T);
  X:=Xit;
End;

Procedure Display_Fields(DisType:Byte);
Var Z:Byte;
Begin
  CurField:=1;
  LastField:=1;
  LastUsed:=1;
  Abort:=False;
  ClearLine(Field[CurField].Z,Field[CurField].W,1);
  WriteCenter(Field[CurField].Z,Field[CurField].W,1,Field[CurField].Message);
  TextColor(7);
  If DisType=0 Then
  Begin
    For Z:=1 To TotFields Do With Field[Z] Do FastWrite(X,Y,7,Strg^);
  End
 Else
  Begin
    For Z:=1 to TotFields Do With Field[Z] Do
    Begin
      GotoXy(X,Y);
      WriteString(Strg^);
    End
  End;
End;

Function Str_To_Word(Str:String):Word;
Var Code:Integer;
    Temp:Word;
Begin
  If Length(Str)=0 Then Str_To_Word:=0 Else
  Begin
    Val(Str,Temp,Code);
    If Code=0 Then Str_To_Word:=Temp Else Str_To_Word:=0;
  End;
End;

Function Int_to_Str(Number:longint):string;
var Temp : string;
begin
    Str(Number,temp);
    Int_to_Str := temp;
end;

Function EditFields(T:Byte):String;
Var Z:String[2];
Begin
  Repeat
    EditField(CurField,Z,T);
    EditFields:=Z;
  Until Abort=True;
End;

Procedure SaveScreen;
Begin
  Move(Mem[$B800:0000],Screen,3999);
  OldY:=WhereY;
  OldX:=WhereX;
End;

Procedure RestoreScreen;
Begin
  Move(Screen,Mem[$B800:0000],3999);
  GotoXy(OldX,Oldy);
End;


Begin
  Abort:=False;
  AdaptorType;
  CurField:=1;
  LastField:=1;
  LastUsed:=1;
End.