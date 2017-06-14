{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file ASSIGN.INC                                                   *}
{* -- ASYNC text file interface & drivers                                    *}
{*                                                                           *}
{* ASSIGN.INC contains the necessary interface procedures & functions to     *}
{* impliment text file compatability between Turbo Pascal and the ASYNC      *}
{* serial routines.                                                          *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* ! Function C_InFunc(Var F:TextRec) : Integer                              *}
{* ! Function C_OutFunc(Var F:TextRec) : Integer                             *}
{* ! Function C_FlushFunc(Var F:TextRec) : Integer                           *}
{* ! Function C_CloseFunc(Var F:TextRec) : Integer                           *}
{* ! Function C_OpenFunc(Var F:TextRec) : Integer                            *}
{* - Procedure AssignCom(Var F:Text; CPort:Byte)                             *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{$F+}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Function C_InFunc(Var F:TextRec) : Integer                                *}
{* -- INPUT function for the ASYNC text file device driver                   *}
{* Function C_OutFunc(Var F:TextRec) : Integer                               *}
{* -- OUTPUT function for the ASYNC text file device driver                  *}
{* Function C_FlushFunc(Var F:TextRec) : Integer                             *}
{* -- FLUSH function for the ASYNC text file device driver                   *}
{* Function C_CloseFunc(Var F:TextRec) : Integer                             *}
{* -- CLOSE function for the ASYNC text file device driver                   *}
{* Function C_OpenFunc(Var F:TextRec) : Integer                              *}
{* -- OPEN function for the ASYNC text file device driver                    *}
{*                                                                           *}
{* These procedures are used internally by ASYNC and Turbo Pascal to pro-    *}
{* vide a text file device driver that may be used by standard Pascal I/O    *}
{* calls (such as Reset/Rewrite, Read/Readln, Write/Writeln, etc.).  When    *}
{* a port is ASSIGNed to a text file variable using AssignCom, the file's    *}
{* I/O links are pointed to these routines.  The text file interface is      *}
{* documented on pp. 109-116 and pp. 223-228 of the Turbo Pascal (V5 & 5.5)  *}
{* reference manual.                                                         *}
{*                                                                           *}
{* Each procedure accepts a text file record as defined in the Turbo Pascal  *}
{* DOS unit.  The return value is an error code which is reported by the     *}
{* standard function IOResult.  Error codes are the same as those normally   *}
{* returned in the C_Error global variable.                                  *}
{*                                                                           *}
{* These functions are intended for use only as part of the Turbo Pascal     *}
{* I/O subsystem and should not be called directly.  They may not be called  *}
{* by user programs since they are not declared in the INTERFACE section     *}
{* of the ASYNC unit.                                                        *}
{*                                                                           *}
{*****************************************************************************}

Function C_InFunc(Var F:TextRec) : Integer;

Var
  Index : Word;
  EOLIndex : Byte;
  Ch : Char;

Begin
  With F,ComIORec(UserData) Do
    Begin
      Index := 0;
      C_Error := 0;
      EOLIndex := 0;

      {Place all available received characters in text file input buffer}
      {Input is terminated if end-of-line sequence received}

      While (Index < BufSize) And (C_Error = 0) And (EOLIndex <= Length(C_EOLIn)) Do
        Begin
          {Get character from buffer & place in text file's buffer}

          Ch := ComReadCh(ComPort);
          BufPtr^[Index] := Ch;
          Inc(Index);

          {Determine if end-of-line sequence received}

          If Ch = C_EOLIn[EOLIndex] Then
            Inc(EOLIndex)
          Else
            Begin
              EOLIndex := 1;
              If Ch = C_EOLIn[EOLIndex] Then Inc(EOLIndex);
            End;
        End;

      BufPos := 0;
      BufEnd := Index;
    End;

  C_InFunc := C_Error;
End;

{*****************************************************************************}

Function C_OutFunc(Var F:TextRec) : Integer;

Var
  Index : Word;

Begin
  With F,ComIORec(UserData) Do
    Begin
      Index := 0;
      C_Error := 0;
      While (Index < BufPos) And (C_Error = 0) Do
        Begin
          While (C_Status[ComPort] And $08) <> 0 Do ;
          ComWriteCh(ComPort,BufPtr^[Index]);
          Inc(Index);
        End;
      BufPos := 0;
    End;
  C_OutFunc := C_Error;
End;

{*****************************************************************************}

Function C_FlushFunc(Var F:TextRec) : Integer;

Begin
  If F.Mode = FmOutput Then
    C_FlushFunc := C_OutFunc(F)
  Else
    C_FlushFunc := 0;
End;

{*****************************************************************************}

Function C_CloseFunc(Var F:TextRec) : Integer;

Var
  P : Word;

Begin
  With F,ComIORec(UserData) Do
    Begin
      If C_OpenLevel[ComPort] <= 1 Then
        Begin
          P := C_PortAddr[ComPort] + C_LSR;
          While ((C_Status[ComPort] And $04) = 0) Or ((Port[P] And $40) = 0) Do ;
          CloseCom(ComPort,C_AssignTimeout);
          C_CloseFunc := C_Error;
          Mode := FmClosed;
        End
      Else
        C_CloseFunc := 0;
      Dec(C_OpenLevel[ComPort]);
    End;
End;

{*****************************************************************************}

Function C_OpenFunc(Var F:TextRec) : Integer;

Begin
  C_OpenFunc := 0;

  With F,ComIORec(UserData) Do
    Begin

      {OPEN the port if it is not already opened}
      {Parameters used are those in effect when the port was ASSIGNed}
      {by AssignCom.  C_OpenLevel[] is >0 if the port was previously OPENed}

      If Not C_PortOpen[ComPort] Then
        Begin
          ComParams(ComPort,Baud,Wordsize,Parity,Stopbits);
          If C_Error = C_NoError Then
            OpenCom(ComPort,InBufSize,OutBufSize,False);
          C_OpenFunc := C_Error;
          If C_Error <> C_NoError Then Exit;
        End
      Else
        Inc(C_OpenLevel[ComPort]);

      {If file is opened by the 'Reset' or 'Append' procedures, configure it}
      {for output.  Otherwise configure it for input.}

      If Mode = FmInput Then
        InOutFunc := @C_InFunc
      Else
        Begin
          Mode := FmOutput;
          InOutFunc := @C_OutFunc;
        End;
    End;
End;

{$F-}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure AssignCom(Var F:Text; CPort:Byte)                               *}
{* -- ASSIGNs an ASYNC port to a text file variable                          *}
{*                                                                           *}
{* AssignCom provides a means by which a communications port (as specified   *}
{* by (CPort)) can be assigned to a Turbo Pascal text file variable.  After  *}
{* a text file variable (F) is assigned by this procedure all of the         *}
{* standard Pascal procedures and functions available for text files (such   *}
{* as Reset, Rewrite, Writeln and Readln) may be used on (F) as if it were   *}
{* a disk file.  Subsequent I/O operations will send/receive data to/from    *}
{* the port specified by (CPort).                                            *}
{*                                                                           *}
{* The (CPort) specified may be open or closed when the ASSIGNment is made.  *}
{* If (CPort) was previously opened by OpenCom the buffer sizes used will    *}
{* be those used in OpenCom.  If the port is not opened when ASSIGNment is   *}
{* made, the global variables C_AssignInSize and C_AssignOutSize will det-   *}
{* ermine the I/O buffer sizes.                                              *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{*                                                                           *}
{*****************************************************************************}

Procedure AssignCom(Var F:Text; CPort:Byte);

Var
  BR : Longint;
  WS,SB : Byte;
  Pty : Char;

Begin
  If C_ErrorCheck(CPort,2) Then Exit;

  With TextRec(F) Do
    Begin
      Handle := $FFFF;                           {No DOS file handle needed}
      Mode := FmClosed;                          {Flag port as closed}
      BufSize := Sizeof(Buffer);                 {Text file buffer size}
      BufPtr := @Buffer;                         {Point to default file buffer}
      OpenFunc := @C_OpenFunc;                   {Point to file func drivers}
      CloseFunc := @C_CloseFunc;
      FlushFunc := @C_FlushFunc;
      InOutFunc := @C_OutFunc;
      Name[0] := #0;                             {No file name}

      GetComParams(CPort,BR,WS,Pty,SB);          {Get port parameters}
      With ComIORec(UserData) Do
        Begin
          ComPort := CPort;                      {Pass parameters to OPEN func}
          Baud := Word(BR);
          Wordsize := WS;
          Parity := Pty;
          Stopbits := SB;
          If C_PortOpen[CPort] Then
            Begin
              InBufSize := C_InSize[CPort];      {Use current buffer sizes if}
              OutBufSize := C_OutSize[CPort];    {port already opened}
            End
          Else
            Begin
              InBufSize := C_AssignInSize;       {Use default assign sizes if}
              OutBufSize := C_AssignOutSize;     {port is closed}
            End;
        End;
    End;
End;
