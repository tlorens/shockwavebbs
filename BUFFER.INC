{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file BUFFER.INC                                                   *}
{* --- I/O buffer management routines                                        *}
{*                                                                           *}
{* These routines provide mechanisims for examining and changing the state   *}
{* of the internal circular buffers used by ASYNC.  Buffers can be size-     *}
{* checked, tested for empty/full status and cleared.                        *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Procedure ClearCom(ComPort:Byte; Buffer:Char)                           *}
{* - Function ComBufLeft(ComPort:Byte; Buffer:Char) : Word                   *}
{* - Function ComBufUsed(ComPort:Byte; Buffer:Char) : Word                   *}
{* - Function ComBufEmpty(ComPort:Byte; Buffer:Char) : Boolean               *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{*****************************************************************************}
{*                                                                           *}
{* Procedure ClearCom(ComPort:Byte; Buffer:Char)                             *}
{* -- Clear (reset) an I/O buffer                                            *}
{*                                                                           *}
{* ClearCom resets the buffer specified by (Buffer) for the port denoted by  *}
{* (ComPort).  (Buffer) is a single character that specifies the buffer to   *}
{* be cleared and may be one of the following:                               *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Clear input (receive) buffer                                  *}
{* O or o    | Clear output (transmit) buffer                                *}
{* B or b    | Clear both input and output buffers                           *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 3: Port not open                                                          *}
{* 5: Unrecognized character in (Buffer)                                     *}
{*                                                                           *}
{*****************************************************************************}

Procedure ClearCom(ComPort:Byte; Buffer:Char);

Var
  P : Word;
  X : Byte;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  Buffer := UpCase(Buffer);
  If Pos(Buffer,'IOB') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  P := C_PortAddr[ComPort];

  {Clear receive buffer, if requested}

  If (Buffer = 'I') Or (Buffer = 'B') Then
    Begin
      IntPush;                                   {Disable interrupts}
      C_InHead[ComPort] := 0;                    {Clear receive buffer}
      C_InTail[ComPort] := 0;
      X := C_Status[ComPort] And $FD;            {Flag buffer as empty}
      C_Status[ComPort] := X Or $01;
      IntPop;                                    {Enable interrupts}
    End;

  {Clear transmit buffer, if requested}

  If (Buffer = 'O') Or (Buffer = 'B') Then
    Begin
      IntPush;                                   {Disable interrupts}
      C_OutHead[ComPort] := 0;                   {Clear transmit buffer}
      C_OutTail[ComPort] := 0;
      X := C_Status[ComPort] And $F7;            {Flag buffer as empty}
      C_Status[ComPort] := X Or $04;
      IntPop;                                    {Enable interrupts}
    End;
End;

{*****************************************************************************}
{*                                                                           *}
{* Function ComBufLeft(ComPort:Byte; Buffer:Char) : Word                     *}
{* -- Return number of unused bytes in a I/O buffer                          *}
{*                                                                           *}
{* ComBufLeft checks the buffer pointers for the buffer specified by         *}
{* (ComPort) and (Buffer) and returns a value indicating the number of bytes *}
{* that are currently free.  (ComPort) specifies which port's buffer should  *}
{* be checked.  (Buffer) controls which buffer for the specified port is     *}
{* checked, according to the table below:                                    *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Return free space in input (receive) buffer                   *}
{* O or o    | Return free space in output (transmit) buffer                 *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 3: Port not open                                                          *}
{* 5: Unrecognized character in (Buffer)                                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComBufLeft(ComPort:Byte; Buffer:Char) : Word;

Var
  Left : Longint;
  Head,Tail,Size : Word;
  Flag : Byte;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  Buffer := Upcase(Buffer);
  If Pos(Buffer,'IO') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign computation variables according to requested buffer}

  If Buffer = 'I' Then
    Begin
      IntPush;
      Head := C_InHead[ComPort];
      Tail := C_InTail[ComPort];
      Flag := C_Status[ComPort] And $02;
      IntPop;
      Size := C_InSize[ComPort];
    End;

  If Buffer = 'O' Then
    Begin
      IntPush;
      Head := C_OutHead[ComPort];
      Tail := C_OutTail[ComPort];
      Flag := C_Status[ComPort] And $08;
      IntPop;
      Size := C_OutSize[ComPort];
    End;

  {Compute # bytes remaining}

  If Flag > 0 Then
    Left := 0
  Else
    Left := Tail - Longint(Head);
  If Left < 0 Then Inc(Left,Size);
  ComBufLeft := Left;
End;

{*****************************************************************************}
{*                                                                           *}
{* Function ComBufUsed(ComPort:Byte; Buffer:Char) : Word                     *}
{* -- Returns spaced used in a I/O buffer                                    *}
{*                                                                           *}
{* ComBufUsed will return a value indicating the number of bytes that are    *}
{* presently in use for the buffer specified by (ComPort) and (Buffer).      *}
{* (ComPort) specifies which port's buffer should be checked.  (Buffer)      *}
{* selects which of the port's used buffer space is returned, according to   *}
{* the table below:                                                          *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Return used space in input (receive) buffer                   *}
{* O or o    | Return used space in output (transmit) buffer                 *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 3: Port not open                                                          *}
{* 5: Unrecognized character in (Buffer)                                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComBufUsed(ComPort:Byte; Buffer:Char) : Word;

Var
  Used : Longint;
  Head,Tail,Size : Word;
  Flag : Byte;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  Buffer := Upcase(Buffer);
  If Pos(Buffer,'IO') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign computation variables according to requested buffer}

  If Buffer = 'I' Then
    Begin
      IntPush;
      Head := C_InHead[ComPort];
      Tail := C_InTail[ComPort];
      Flag := C_Status[ComPort] And $02;
      IntPop;
      Size := C_InSize[ComPort];
    End;

  If Buffer = 'O' Then
    Begin
      IntPush;
      Head := C_OutHead[ComPort];
      Tail := C_OutTail[ComPort];
      Flag := C_Status[ComPort] And $08;
      IntPop;
      Size := C_OutSize[ComPort];
    End;

  {Compute # bytes used}

  If Flag > 0 Then
    Used := Size
  Else
    Used := Head - Longint(Tail);
  If Used < 0 Then Inc(Used,Size);
  ComBufUsed := Used;
End;

{*****************************************************************************}
{*                                                                           *}
{* Function ComBufEmpty(ComPort:Byte; Buffer:Char) : Boolean                 *}
{* -- Determine if a I/O buffer is empty                                     *}
{*                                                                           *}
{* ComBufEmpty provides a quick and efficient way of determining if a I/O    *}
{* buffer is empty.  Unlike ComBufLeft or ComBufUsed, ComBufEmpty checks     *}
{* the "buffer empty" status bit in the port's status register, resulting in *}
{* quicker execution.  ComBufEmpty returns a TRUE result if the buffer       *}
{* specified by (ComPort) and (Buffer) is empty.  (Buffer) denotes which     *}
{* one of the port's I/O buffers is checked according to the table below:    *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Return TRUE if the input (receive) buffer is empty            *}
{* O or o    | Return TRUE if the output (transmit) buffer is empty          *}
{* B or b    | Return TRUE if either the input OR output buffer is empty     *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 3: Port not open                                                          *}
{* 5: Unrecognized character in (Buffer)                                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComBufEmpty(ComPort:Byte; Buffer:Char) : Boolean;

Var
  Empty : Boolean;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  Buffer := Upcase(Buffer);
  If Pos(Buffer,'IOB') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Determine if chosen buffer is empty}

  Empty := False;
  If (Buffer = 'I') Or (Buffer = 'B') Then
    Empty := Empty Or ((C_Status[ComPort] And $01) <> 0);
  If (Buffer = 'O') Or (Buffer = 'B') Then
    Empty := Empty Or ((C_Status[ComPort] And $04) <> 0);
  ComBufEmpty := Empty;
End;

{*****************************************************************************}
{*                                                                           *}
{* Function ComBufFull(ComPort:Byte; Buffer:Char) : Boolean                  *}
{* -- Determine if a I/O buffer is full                                      *}
{*                                                                           *}
{* ComBufFull is the compliment of ComBufEmpty; it returns a TRUE result     *}
{* if the buffer specified by (ComPort) and (Buffer) is completely full.     *}
{* (ComPort) specifies the port to check and (Buffer) determines which one   *}
{* of the port's I/O buffers is interrogated according to the table below:   *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Return TRUE if the input (receive) buffer is full             *}
{* O or o    | Return TRUE if the output (transmit) buffer is full           *}
{* B or b    | Return TRUE if either the input OR output buffer is full      *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 3: Port not open                                                          *}
{* 5: Unrecognized character in (Buffer)                                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComBufFull(ComPort:Byte; Buffer:Char) : Boolean;

Var
  Full : Boolean;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  Buffer := Upcase(Buffer);
  If Pos(Buffer,'IOB') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Determine if chosen buffer is empty}

  Full := False;
  If (Buffer = 'I') Or (Buffer = 'B') Then
    Full := Full Or ((C_Status[ComPort] And $02) <> 0);
  If (Buffer = 'O') Or (Buffer = 'B') Then
    Full := Full Or ((C_Status[ComPort] And $08) <> 0);
  ComBufFull := Full;
End;

