{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file INIT.INC                                                     *}
{* --- Port open/close, initialization & testing routines                    *}
{*                                                                           *}
{* These routines are used to OPEN and CLOSE logical ports and test port     *}
{* hardware.                                                                 *}
{*                                                                           *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Function  ComExist(P:Word; LoopMode:Boolean) : Boolean                  *}
{* - Procedure ComFIFOExist(P:Word) : Boolean                                *}
{* - Procedure OpenCom(ComPort:Byte; InBufSize,OutBufSize:Word;              *}
{*             Default:Boolean)                                              *}
{* - Procedure CloseCom(ComPort:Byte; Timeout:Word)                          *}
{* - Procedure CloseAllComs(Timeout:Word)                                    *}
{* - Procedure ComParams(ComPort:Byte; Baud:Longint; Wordsize:Byte;          *}
{*             Parity:Char; Stopbits:Byte)                                   *}
{* - Procedure GetComParams(ComPort:Byte; Var Baud:Longint;                  *}
{*             Var Wordsize:Byte; Var Parity:Char; Var Stopbits:Byte)        *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Function ComExist(P:Word; LoopMode:Boolean) : Boolean                     *}
{* -- Test port hardware / determine if an 8250-compatable port exists       *}
{*                                                                           *}
{* ComExist tests the hardware mapped at port address (P) and returns a TRUE *}
{* result if an 8250-compatable UART was detected.  The specific test per-   *}
{* formed is controlled by the (LoopMode) parameter.  If (LoopBack) is TRUE, *}
{* the port is tested using the 8250 loopback mode.  If FALSE, a simpler     *}
{* test is perfomed using the 8250 scratch register.  Since the loopback     *}
{* test is the most reliable and exahustive of the two, it is the one rec-   *}
{* commended for normal use.  However, since the 8250's loopback mode causes *}
{* the modem control lines (DTR,RTS) to go into an unasserted state during   *}
{* the test (about 3 mS in length), it is not recommended for modem use.  If *}
{* you are using ASYNC for modem/telecommunication use, the scratch register *}
{* test (LoopBack = FALSE) is recommended.                                   *}
{*                                                                           *}
{* Although effort is made to restore the 8250 state to what it was before   *}
{* the test, it is recommended that this routine only be used BEFORE a port  *}
{* is opened.  ComExist is called for each defined port during execution of  *}
{* the ComInit procedure.  The result of this test is placed in the          *}
{* C_PortExist array which may be examined at any time during execution.     *}
{*                                                                           *}
{* ComExist presently does NOT check to ensure that the UART mapped at       *}
{* (P) will operate in an interrupt-driven mode.  Ports that are not prop-   *}
{* erly configured for interrupt-driven operation will NOT work with ASYNC.  *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 2: Existence test failed (port hardware not found)                        *}
{*                                                                           *}
{*****************************************************************************}

Function ComExist(P:Word; LoopMode:Boolean) : Boolean;

Var
  OldIER,OldLCR,OldMCR,Temp : Byte;
  BaudLow,BaudHigh : Byte;
  Exist : Boolean;

Begin
  ComExist := False;
  Exist := False;

  {Save registers, disable interrupts for test}

  IntPush;
  OldIER := Port[P+C_IER];                  {Save interrupt enable register}
  Port[P+C_IER] := $00;                     {Disable interrupts}
  OldMCR := Port[P+C_MCR];                  {Save modem control register}
  OldLCR := Port[P+C_LCR];                  {Save line control register}
  IntPop;

  If LoopMode Then
    Begin
      {Loopback existence test: Initialze & configure port for loopback mode}
      {NOTE: This may cause a on-line modem to reset & drop carrier.}
      {      If this is a problem, call this routine with LoopMode = FALSE}
      {      and set the global variable C_ExistMode to FALSE.}

      While (Port[P+C_LSR] And $40) = 0 Do; {Wait for last char. transmit}
      Port[P+C_LCR] := $80;                 {Access divisor latch}
      BaudLow := Port[P+C_DLL];             {Read old baud rate}
      BaudHigh := Port[P+C_DLH];
      Port[P+C_DLL] := Lo(C_ExistBDiv);     {Set test baud rate}
      Port[P+C_DLH] := Hi(C_ExistBDiv);
      Port[P+C_LCR] := $03;                 {Line = 8N1}
      Port[P+C_MCR] := $10;                 {Enable loopback mode}
      While (Port[P+C_LSR] And $01) <> 0 Do {Clear any chars from Rx buffer}
        Temp := Port[P+C_RxB];

      {Test for character loopback}

      Port[P+C_TxB] := $55;                 {Send first test byte}
      Delay(C_ExistDelay);                  {Wait a bit}
      Temp := Port[P+C_RxB];                {Read back echoed character}
      Exist := (Temp = $55);                {Set exist flag if char. echoed}
      Port[P+C_TxB] := $AA;                 {Send second test byte}
      Delay(C_ExistDelay);                  {Wait a bit}
      Temp := Port[P+C_RxB];                {Read back echoed character}
      Exist := Exist And (Temp = $AA);      {Set exist flag if char. echoed}

      {Test for modem control / status loopback}

      Port[P+C_MCR] := $1F;                 {Set I/O lines to test pattern 1}
      Temp := Port[P+C_MSR] And $F0;        {Read inputs}
      Exist := Exist And (Temp = $F0);      {Inputs = Outputs?}
      Port[P+C_MCR] := $10;                 {Set I/O lines to test pattern 2}
      Temp := Port[P+C_MSR] And $F0;        {Read inputs}
      Exist := Exist And (Temp = $00);      {Inputs = Outputs?}

      {Restore port status}

      Port[P+C_LCR] := $80;                 {Restore baud rate}
      Port[P+C_DLL] := BaudLow;
      Port[P+C_DLH] := BaudHigh;
      Port[P+C_LCR] := OldLCR;              {Restore line controls}
    End
  Else
    Begin
      {If loopback-mode check is disabled, use scratch-register check instead}
      {Use this mode if ASYNC is being used in BBS "Door" type programs or}
      {any other application that could be STARTED while a modem connection}
      {is active.  It is not as rigorous as the loopback test but is less}
      {invasive.}

      Port[P+C_SCR] := $55;                 {Assign 1st value to scratch reg.}
      Temp := Port[P+C_SCR];                {Read back scratch register}
      Exist := (Temp = $55);                {Set exist flag if verified}
      Port[P+C_SCR] := $AA;                 {Assign 2nd value to scratch reg.}
      Temp := Port[P+C_SCR];                {Read back scratch register}
      Exist := Exist And (Temp = $AA);      {Set exist flag if verified}
    End;

  {Clear any pending interrupts}

  While Exist And ((Port[P+C_IIR] And $01) = 0) Do
    Temp := Port[P+C_RxB] + Port[P+C_LSR] + Port[P+C_MSR];
  Port[P+C_MCR] := OldMCR;
  Port[P+C_IER] := OldIER;

  ComExist := Exist;
  If Exist Then C_Error := C_NoError Else C_Error := C_PortNotFound;
End;

{*****************************************************************************}
{*                                                         Modified 12/28/90 *}
{*                                                                           *}
{* Procedure ComFIFOExist(P:Word) : Boolean                                  *}
{* -- Determine if a COM port supports FIFO operations                       *}
{*                                                                           *}
{* Some newer serial ports contain UARTs that support hardware first-in-     *}
{* first-out buffers.  These buffers can be utilized by ASYNC to ensure that *}
{* no characters are missed during high-speed multiport data reception and   *}
{* improve ISR execution efficiency for character transmission.  This        *}
{* function will test a UART located at port address (P) and return a TRUE   *}
{* result if the hardware supports FIFO operation.                           *}
{*                                                                           *}
{* Note: This routine tests the hardware directly and should not be called   *}
{*       after the port at (P) has been OPENed, since this routine cannot    *}
{*       reliably restore the UART state after it is done executing.         *}
{*       It is also possible that characters received may be lost if this    *}
{*       routine is called on a open port.                                   *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 2: Port hardware not present                                              *}
{*                                                                           *}
{*****************************************************************************}

Function ComFIFOExist(P:Word) : Boolean;

Var
  Temp : Byte;

Begin
  IntPush;                                  {Disable interrupts during test}
  Port[P+C_FCR] := $01;                     {Enable FIFO mode on UART}
  Temp := Port[P+C_IIR];                    {Get interrupt/FIFO status}
  Port[P+C_FCR] := $00;                     {Disable FIFO mode}
  IntPop;                                   {Test complete, enable interrupts}

  If (Temp And $80) > 0 Then
    ComFIFOExist := True                    {Bit 7 set, FIFOs exist}
  Else
    ComFIFOExist := False;                  {Bit 7 not set, no FIFOS present}
End;

{*****************************************************************************}
{*                                                         Modified 12/28/90 *}
{*                                                                           *}
{* Procedure OpenCom(ComPort:Byte; InBufSize,OutBufSize:Word;                *}
{*           Default:Boolean)                                                *}
{* -- Prepare a port for I/O operations                                      *}
{*                                                                           *}
{* Before a port can be used for I/O operations, a call to OpenCom must be   *}
{* made.  OpenCom prepares port (ComPort) for I/O by configuring the assoc-  *}
{* iated port hardware for interrupt driven operation, points the port's     *}
{* hardware interrupt vector to the ComISR routine, and allocates buffers    *}
{* for input and output.  The size of the buffers is determined by the       *}
{* (InBufSize) and (OutBufSize) variables.  (InBufSize) sets the size of the *}
{* receive (input) buffer, and (OutBufSize) determines the size of the       *}
{* transmit (output) buffer.  Memory space for the buffers is allocated on   *}
{* the Turbo Pascal heap to preserve data segment space.  (Default), if      *}
{* TRUE, will instruct OpenCom to reset all the port's control values to     *}
{* their start-up defaults (all handshaking disabled, receive wait disabled, *}
{* and transmit wait enabled).  If FALSE, these values will not be altered   *}
{* allowing for repeated OpenCom/CloseCom sequences without need to to re-   *}
{* specify port settings.                                                    *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port #                                                         *}
{* 2: Port hardware not present                                              *}
{* 4: Port already open                                                      *}
{* 5: Input or output buffer sizes too small (16 bytes minimum)              *}
{* 6: Insufficient memory for buffers                                        *}
{*                                                                           *}
{*****************************************************************************}

Procedure OpenCom(ComPort:Byte; InBufSize,OutBufSize:Word; Default:Boolean);

Var
  P : Word;
  IntLine,Temp,Mask,IMR,Offset : Byte;

Begin
  {Make sure port is valid and not already open}

  If C_ErrorCheck(ComPort,4) Then Exit;

  {Disable port interrupts}

  P := C_PortAddr[ComPort];
  Port[P+C_MCR] := Port[P+C_MCR] And $07;   {Mask OUT2 (interrupt enable line)}
  Port[P+C_IER] := $0F;                     {Enable UART ints to clear them}
  While (Port[P+C_IIR] And $01) = 0 Do      {Clear pending interrupts}
    Temp := Port[P+C_RxB] Or Port[P+C_LSR] Or Port[P+C_MSR];
  Port[P+C_IER] := $00;                     {Disable UART interrupts}

  {Make sure buffer sizes are correct}
  {If buffer sizes passed are 0, use default sizes}

  If InBufSize = 0 Then InBufSize := C_AssignInSize;
  If OutBufSize = 0 Then OutBufSize := C_AssignOutSize;
  IF (InBufSize < C_MinBufSize) Or (OutBufSize < C_MinBufSize) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Point hardware interrupt vector to ComISR}
  {Enable interrupts for selected port}

  IntLine := C_PortInt[ComPort];
  If IntLine > 7 Then
    Begin
      IMR := $A1;                           {Assign XT interrupt}
      Mask := ($01 SHL (IntLine-8)) XOr $FF;
      Offset := $68;
    End
  Else
    Begin
      IMR := $21;                           {Assign AT interrupt}
      Mask := ($01 SHL IntLine) XOr $FF;
      Offset := $08;
    End;

  If C_OldIntVec[IntLine] = Nil Then
    Begin
      GetIntVec(Offset+IntLine,C_OldIntVec[IntLine]);
      SetIntVec(Offset+IntLine,@ComISR);
      Temp := Port[IMR];
      Port[IMR] := Temp And Mask;
    End;

  {Check for free memory & allocate receive buffer}

  If MaxAvail < InBufSize Then
    Begin
      C_Error := C_NoMemory;
      Exit;
    End;
  C_InSize[ComPort] := InBufSize;
  GetMem(C_InBufPtr[ComPort],InBufSize);

  {Check for free memory & allocate transmit buffer}

  If MaxAvail < InBufSize Then
    Begin
      FreeMem(C_InBufPtr[ComPort],InBufSize);
      C_Error := C_NoMemory;
      Exit;
    End;
  C_OutSize[ComPort] := OutBufSize;
  GetMem(C_OutBufPtr[ComPort],OutBufSize);

  {Reset buffer pointers}

  C_InHead[ComPort] := 0;
  C_InTail[ComPort] := 0;
  C_OutHead[ComPort] := 0;
  C_OutTail[ComPort] := 0;
  C_Status[ComPort] := $05;
  C_RcvError[ComPort] := 0;
  C_RcvBreak[ComPort] := 0;

  {Set default port parameters if enabled}

  If Default Then
    Begin
      C_HSOn[ComPort] := 8;            {Assert when 8 chars left in buffer}
      C_HSOff[ComPort] := 4;           {Unassert when 4 chars left in buffer}
      C_XON[ComPort] := ^Q;            {Soft handshake assert char = ^Q}
      C_XOFF[ComPort] := ^S;           {Soft handshake unassert char = ^S}
      C_HWCheck[ComPort] := $01;       {Use CTS line for transmit handshake}
      C_HWMatch[ComPort] := $01;       {CTS line must be high for assert state}
      C_HWModify[ComPort] := $02;      {Use RTS line for receive handshake}
      C_HWAssert[ComPort] := $02;      {Make RTS line high when asserted}
      C_RcvWait[ComPort] := False;     {Do not wait for received character}
      C_XmitWait[ComPort] := True;     {Wait for buffer space before transmit}
      C_Ctrl[ComPort] := $20;          {All handshaking disabled}
    End
  Else
    Begin
      C_Ctrl[ComPort] := (C_Ctrl[ComPort] And $0F) Or $20;
      If (C_Ctrl[ComPort] And $01) = 1 Then
        Begin
          Temp := Port[P+C_MCR] And C_HWCheck[ComPort] And $0F;
          If Temp = (C_HWMatch[ComPort] And C_HWCheck[ComPort]) Then
            C_Status[ComPort] := C_Status[ComPort] Or $80;
        End;
    End;

  {Enable port interrupts & exit}

  Port[P+C_MCR] := Port[P+C_MCR] Or $08;    {Enable UART interrupt gate}
  Port[P+C_IER] := $0D;                     {Enable interrupts (except xmit)}

  C_OpenLevel[ComPort] := 1;                {Flag port as OPEN}
  C_PortOpen[ComPort] := True;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure CloseCom(ComPort:Byte; Timeout:Word);                           *}
{* -- Close a port, disable port interrupts                                  *}
{*                                                                           *}
{* CloseCom shuts down I/O on the designated (ComPort).  UART interrupts     *}
{* are disabled and the I/O buffers associated with the port are dealloc-    *}
{* ated.  If (Timeout) >0, the port is not closed until it's transmit buffer *}
{* is emptied OR the (Timeout) specified (18 = 1 second) expires.            *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0:  No error                                                              *}
{* 1:  Invalid port #                                                        *}
{* 2:  Port hardware not present                                             *}
{* 3:  Port already closed                                                   *}
{* 12: Timeout expired, buffer not emptied before close                      *}
{*                                                                           *}
{*****************************************************************************}

Procedure CloseCom(ComPort:Byte; Timeout:Word);

Var
  P : Word;
  IntLine,IMR,Mask,Offset,X : Byte;
  Revector : Boolean;

Begin
  {Make sure port exists & is opened}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Wait for port to empty if Timeout > 0}

  If Timeout > 0 Then
    ComFlushBuffer(ComPort,Timeout);

  {Mark port as closed}

  P := C_PortAddr[ComPort];
  C_PortOpen[ComPort] := False;
  C_OpenLevel[ComPort] := 0;

  {Disable all UART interrupts}

  IntPush;
  Port[P+C_IER] := $00;                      {Disable UART interrupts}
  Port[P+C_MCR] := Port[P+C_MCR] And $07;    {Turn off UART interrupt gate}
  IntPop;

  {Restore interrupt vector to original value if no other open port using it}

  IntLine := C_PortInt[ComPort];
  Revector := True;
  For X := 1 To C_MaxCom Do
    If C_PortOpen[X] And (C_PortInt[X] = IntLine) Then Revector := False;
  If Revector Then
    Begin
      If IntLine > 7 Then
        Begin
          IMR := $A1;
          Mask := $01 SHL (IntLine - 8);
          Offset := $08;
        End
      Else
        Begin
          IMR := $21;
          Mask := $01 SHL IntLine;
          Offset := $68;
        End;
      Port[IMR] := Port[IMR] Or Mask;
      SetIntVec(Offset+IntLine,C_OldIntVec[IntLine]);
      C_OldIntVec[IntLine] := Nil;
    End;

  {Deallocate communications buffers}

  FreeMem(C_InBufPtr[ComPort],C_InSize[ComPort]);
  FreeMem(C_OutBufPtr[ComPort],C_OutSize[ComPort]);
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure CloseAllComs(Timeout:Word)                                      *}
{* -- Close all opened ports                                                 *}
{*                                                                           *}
{* CloseAllComs performs a CloseCom call on all open ports.  Typically used  *}
{* at the end of a program to "clean up" before termination.  CloseAllComs   *}
{* is called by the unit exit procedure before program termination.          *}
{* If (Timeout) > 0, CloseAllComs will wait up to (Timeout) 'ticks' (18 = 1  *}
{* second) before closing each open port.                                    *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{*                                                                           *}
{* Note: C_Error is forced to 0 on exit since there is no way of telling     *}
{* which port(s) closed with errors.  If error handling is important, close  *}
{* each port individually using CloseCom.                                    *}
{*                                                                           *}
{*****************************************************************************}

Procedure CloseAllComs(Timeout:Word);

Var
  X : Byte;

Begin
  For X := 1 To C_MaxCom Do
    If C_PortOpen[X] Then CloseCom(X,Timeout);
  C_Error := 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComParams(ComPort:Byte; Baud:Longint; Wordsize:Byte;            *}
{*           Parity:Char; Stopbits:Byte)                                     *}
{* -- Set communications parameters                                          *}
{*                                                                           *}
{* ComParams configures the UART line controls and baud rate divisor of the  *}
{* parameters passed.  (Baud) may range from 50 to 112500, although the      *}
{* resolution of the 8250 baud rate divisor at high baud rates provides only *}
{* a limited number of "true" rates at high (Baud) values.  (Wordsize) must  *}
{* be between 5 and 8, and determines the number of bits (not including      *}
{* parity and stop bits) that are serially transmitted for each character    *}
{* sent.  (Parity) determines how the character's parity bit (if any), is    *}
{* computed and sent/checked.  Valid (Parity) values are 'N' (none),         *}
{* 'E' (even), 'O' (odd), 'M' (mark/always high) or 'S' (space/always low).  *}
{* (StopBits) may be 1 or 2, and determines how many stop (space) bits are   *}
{* sent at the end of each character.  ComParams may be called before or     *}
{* after a port is opened.                                                   *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComParams(ComPort:Byte; Baud:Longint; Wordsize:Byte; Parity:Char;
                    Stopbits:Byte);

Const
  ParityChk : Set of Char = ['N','O','E','M','S'];

Var
  X,P : Word;
  Temp,OldIER : Byte;

Begin
  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  Parity := Upcase(Parity);
  If (Baud < C_MinBaud) Or (Baud > C_MaxBaud) Or (Wordsize > 8) Or
     (Wordsize < 5) Or (Not (Parity In ParityChk)) Or (Stopbits > 2) Or
     (Stopbits < 1) Then Begin C_Error := C_BadParameter; Exit; End;

  {Disable UART interrupts}
  {Wait for transmission of current character, if any}

  P := C_PortAddr[ComPort];
  IntPush;
  OldIER := Port[P+C_IER];
  Port[P+C_IER] := $00;
  IntPop;
  While (Port[P+C_LSR] And $40) = 0 Do ;

  {Compute & set baud rate}

  X := 115200 Div Baud;
  Port[P+C_LCR] := $80;                {Enable divisor access}
  Port[P+C_DLL] := Lo(X);              {Set baud rate}
  Port[P+C_DLH] := Hi(X);

  {Compute line control register value}

  Temp := Wordsize - 5;                {Wordsize - 5 in bits 0-1}
  Dec(Stopbits);
  Temp := Temp Or (Stopbits SHL 2);    {# Stopbits - 1 in bit 2}

  Case Parity Of
    'N' : ;                            {No parity}
    'O' : Temp := Temp Or $08;         {Odd parity}
    'E' : Temp := Temp Or $18;         {Even parity}
    'M' : Temp := Temp Or $28;         {Mark parity}
    'S' : Temp := Temp Or $38;         {Space parity}
  End;

  Port[P+C_LCR] := Temp;                 {Set line controls}
  Port[P+C_IER] := OldIER;               {Enable UART interrupts}
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure GetComParams(ComPort:Byte; Var Baud:Longint; Var Wordsize:Byte; *}
{*           Var Parity:Char; Var Stopbits:Byte)                             *}
{* -- Get communications parameters from port hardware                       *}
{*                                                                           *}
{* GetComParams reads the current line settings from the port selected by    *}
{* (ComPort) and returns these settings in (Baud), (Wordsize), (Parity) and  *}
{* (StopBits).                                                               *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port #                                                         *}
{* 2: Port hardware not present                                              *}
{*                                                                           *}
{*****************************************************************************}

Procedure GetComParams(ComPort:Byte; Var Baud:Longint; Var Wordsize:Byte;
          Var Parity:Char; Var Stopbits:Byte);

Const
  ParityVal : Array[0..7] Of Char = ('N','O','N','E','N','M','N','S');

Var
  P : Word;
  LCRVal,BaudLow,BaudHigh : Byte;

Begin
  {Make sure port hardware exists}

  If C_ErrorCheck(ComPort,2) Then Exit;

  {Read line control register & baud rate divisor}

  P := C_PortAddr[ComPort];                 {Get port address}
  LCRVal := Port[P+C_LCR];                  {Read line control register}
  IntPush;
  Port[P+C_LCR] := $80;                     {Access divisor latch}
  BaudLow := Port[P+C_DLL];                 {Read divisor latch}
  BaudHigh := Port[P+C_DLH];
  Port[P+C_LCR] := LCRVal;                  {Restore original LCR value}
  IntPop;

  {Compute baud rate}

  Baud := 115200 Div (Longint(BaudHigh) * 256 + Longint(BaudLow));

  {Compute wordsize, parity & stopbits}

  Wordsize := (LCRVal And $03) + 5;
  StopBits := ((LCRVal SHR 2) And $01) + 1;
  Parity := ParityVal[((LCRVal SHR 3) And $07)];
End;
