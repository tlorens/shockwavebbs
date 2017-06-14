{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file IO.INC                                                       *}
{* --- Port input/output routines                                            *}
{*                                                                           *}
{* These routines are used to send and receive data from active serial       *}
{* port(s).  Routines are provided for sending and receiving character,      *}
{* string and block data.                                                    *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Procedure ComWriteCh(ComPort:Byte; Ch:Char)                             *}
{* - Procedure ComBlockWrite(ComPort:Byte; Buffer:Pointer; Var Count:Word)   *}
{* - Procedure ComWrite(ComPort:Byte; St:String);                            *}
{* - Procedure ComWriteln(ComPort:Byte; St:String)                           *}
{* - Procedure ComTimedWrite(ComPort:Byte; Ch:Char; Timeout:Word)            *}
{* - Procedure ComSlowWrite(ComPort:Byte; St:String; SendDelay:Word)         *}
{* - Procedure ComEchoSend(ComPort:Byte; St:String; Timeout:Word)            *}
{* - Procedure SendBreak(ComPort:Byte; BreakTime:Word)                       *}
{* - Procedure ComFlushBuffer(ComPort:Byte; Timeout:Word)                    *}
{* - Function  ComReadCh(ComPort:Byte):Char;                                 *}
{* - Procedure ComBlockRead(ComPort:Byte; Buffer:Pointer; Var Count:Word)    *}
{* - Procedure ComRead(ComPort:Byte; Var St:String;MaxLen:Byte;EndChar:Char) *}
{* - Procedure ComReadln(ComPort:Byte; Var St:String; MaxLen:Byte;           *}
{*             Echo:Boolean)                                                 *}
{* - Function  ComTimedRead(ComPort:Byte; Timeout:Word):Char                 *}
{* - Procedure ComWaitFor(ComPort:Byte; St:String; Timeout:Word;             *}
{*             TimeReset:Boolean)                                            *}
{* - Procedure ComWaitForClear(ComPort:Byte; Timeout:Word)                   *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWriteCh(ComPort:Byte; Ch:Char)                               *}
{* --- Send a single character to a port                                     *}
{*                                                                           *}
{* ComWriteCh places a single character (Ch) into the transmit buffer of     *}
{* the port selected by (ComPort).  It is written in assembly language to    *}
{* maximize speed since this routine is used by many of the higher-level     *}
{* output routines in ASYNC.                                                 *}
{*                                                                           *}
{* If the transmit buffer for (ComPort) is full and the variable             *}
{* C_XmitWait[ComPort] is TRUE, ComWriteCh will wait for one byte of buffer  *}
{* space to be freed before placing (Ch) in the transmit buffer.  This mode  *}
{* ensures that each character transmit request is granted.  If C_XmitWait[] *}
{* is FALSE, ComWriteCh will terminate with an error if there is no free     *}
{* transmit buffer space.  Use this mode when delays cannot be tolerated.    *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character placed in transmit buffer                          *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 11: Transmit buffer for (ComPort) full (only if C_XmitWait[] is FALSE)    *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWriteCh(ComPort:Byte; Ch:Char); External;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComBlockWrite(ComPort:Byte; Buffer:Pointer; Var Count:Word)     *}
{* --- Transmit a block of data to a port                                    *}
{*                                                                           *}
{* It is often desirable to send a large block of data (such as strings) to  *}
{* a port.  ComBlockWrite accomplishes this task by transferring a block of  *}
{* data pointed to by (Buffer) to the transmit buffer of the port specified  *}
{* by (ComPort).  (Count) regulates the number of bytes transmitted and      *}
{* returns with the actual number of characters sent (see below).  This      *}
{* routine has been coded in assembly language to maximize transfer speed    *}
{* and is used throught ASYNC to transmit large data blocks (such as         *}
{* strings).                                                                 *}
{*                                                                           *}
{* If the transmit buffer is filled during the execution of ComBlockWrite    *}
{* and the variable C_XmitWait[ComPort] is TRUE, ComBlockWrite will delay    *}
{* transfers from (Buffer) to the port transmit buffer until space in the    *}
{* transmit buffer becomes available.  Use this mode to ensure that exactly  *}
{* (Count) characters get transmitted.  If C_XmitWait[] is FALSE,  the block *}
{* transfer will terminate when the transmit buffer is filled.  In this      *}
{* event, (Count) will contain on return the actual number of characters     *}
{* placed in the transmit buffer.  Use this mode if long ComBlockWrite       *}
{* delays cannot be tolerated.                                               *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, all data in (Buffer) transmitted                             *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 11: Transmit buffer for (ComPort) full (only if C_XmitWait[] is FALSE)    *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComBlockWrite(ComPort:Byte; Buffer:Pointer; Var Count:Word); External;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWrite(ComPort:Byte; St:String)                               *}
{* --- Transmit a string to a port without the line terminating sequence     *}
{*                                                                           *}
{* ComWrite is similar to the standard Pascal procedure WRITE -- the string  *}
{* (St) is placed in the transmit buffer of (ComPort).  Unlike Pascal's      *}
{* WRITE statement, ComWrite cannot transmit mixed types; only strings.      *}
{*                                                                           *}
{* ComWrite will delay execution if transmit buffer space is unavailable if  *}
{* the variable C_XmitWait[ComPort] is TRUE.  If set to FALSE, ComWrite will *}
{* terminate with an error the moment the transmit buffer is filled.         *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, entire string placed in transmit buffer                      *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 11: Transmit buffer for (ComPort) full (only if C_XmitWait[] is FALSE)    *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWrite(ComPort:Byte; St:String);

Var
  X : Word;

Begin
  X := Length(St);
  ComBlockWrite(ComPort,@St[1],X);
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWriteln(ComPort:Byte; St:String)                             *}
{* --- Transmit a string to a port followed by the line termination sequence *}
{*                                                                           *}
{* ComWriteln is the ASYNC counterpart to Pascal's WRITELN procedure; it     *}
{* transfers the string (St) to the transmit buffer of port (ComPort),       *}
{* followed by the line-termination sequence in the global variable          *}
{* C_EOLOut.  Unlike WRITELN, ComWriteln can only transmit string variables. *}
{*                                                                           *}
{* ComWriteln will delay execution of the caller if transmit buffer space    *}
{* is unavailable if the variable C_XmitWait[ComPort] is TRUE.  If set to    *}
{* FALSE, ComWriteln will terminate with an error as soon as the transmit    *}
{* buffer is filled.                                                         *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, entire string placed in transmit buffer                      *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 11: Transmit buffer for (ComPort) full (only if C_XmitWait[] is FALSE)    *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWriteln(ComPort:Byte; St:String);

Begin
  ComWrite(ComPort,St+C_EOLOut);
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComTimedWrite(ComPort:Byte; Ch:Char; Timeout:Word)              *}
{* --- Place character in transmit buffer with timeout                       *}
{*                                                                           *}
{* One of the problems associated with transmitting data using ComWriteCh    *}
{* is that if the transmit buffer for the target port is filled, ComWriteCh  *}
{* will either delay execution indefinitely (waiting for buffer space) or    *}
{* terminate immediately with an error, without transmitting it's character. *}
{* ComTimedWrite works around this problem by providing a mechanisim to      *}
{* transmit a character with a "transmission timeout".  If the transmit      *}
{* buffer for (ComPort) has space for (Ch), the character is placed in the   *}
{* transmit buffer immediately.  However, if space does not exist ComTimed   *}
{* Write will delay up to (Timeout) clock "ticks" waiting for transmit       *}
{* buffer space before giving up and returning with an error.  This routine  *}
{* works the same way irregardless of the C_XmitWait[ComPort] variable.      *}
{*                                                                           *}
{* Note: 1 clock "tick" = approx. 1/18 second.                               *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character placed in transmit buffer                          *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expired, character not transmitted                          *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComTimedWrite(ComPort:Byte; Ch:Char; Timeout:Word);

Var
  TmOut : Boolean;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Start delay timer}

  StartTimer(C_Timer,4,Timeout,0,False);

  {Wait for buffer space or timeout}

  Repeat
    TmOut := TimerFlag(C_Timer);
  Until ((C_Status[ComPort] And $08) = 0) Or TmOut;

  {Send character or return error}

  If Not TmOut Then
    ComWriteCh(ComPort,Ch)
  Else
    C_Error := C_TimedOut;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComSlowWrite(ComPort:Byte; St:String; SendDelay:Word)           *}
{* --- Transmit a string slowly                                              *}
{*                                                                           *}
{* Some devices, such as cheaper modems, cannot accept commands transmitted  *}
{* to them at their full character rate.  If a remote device seems to be     *}
{* "dropping" or "missing" characters that a program is trying to send to it *}
{* this problem is indicated.  ComSlowWrite provides a means to reliably     *}
{* communicate with these devices.  The data in (St) is transmitted to       *}
{* (ComPort) at a 1 character per (SendDelay) rate [Note: (SendDelay) is     *}
{* expressed in millisecond units].  ComSlowWrite waits for the character to *}
{* actually be sent before commencing it's intercharacter delay so the       *}
{* actual data rate is (character transmit time) + (SendDelay).              *}
{*                                                                           *}
{* To ensure accurate transmission timing, ComSlowWrite waits for the        *}
{* transmit buffer to clear before initiating transmission.                  *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character placed in transmit buffer                          *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComSlowWrite(ComPort:Byte; St:String; SendDelay:Word);

Var
  Index : Byte;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  Index := 0;
  While Index < Length(St) Do
    Begin
      {Wait for transmitter to clear}

      While (Port[C_PortAddr[ComPort]+C_LSR] And $40) = 0 Do;

      {Send character & wait}

      Inc(Index);
      ComWriteCh(ComPort,St[Index]);
      Delay(SendDelay);
    End;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComEchoSend(ComPort:Byte; St:String; Timeout:Word)              *}
{* --- Transmit data waiting for echoback confirmation, with timeout         *}
{*                                                                           *}
{* ComEchoSend can be used to ensure that data is being received correctly   *}
{* by a remote device, and furthermore ensure that data is transmitted to    *}
{* the device at a rate at which it can accurately process it.  ComEchoSend  *}
{* will transmit the data in (St) to (ComPort) one character at a time,      *}
{* waiting for it to be echoed back by the device before the next character  *}
{* is sent.  The data echoed back is used to "pace" the transmission, but    *}
{* is not checked for validity (i.e. it does not have to match what was      *}
{* sent to be considered valid).  (Timeout) specifies the maximum length of  *}
{* time that should be spent transmitting the string and is measured in      *}
{* clock "tick" units (approx. 1/18 second).  If (Timeout) expires the       *}
{* remainder of the string is NOT sent and a error is returned.              *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, entire string transmitted                                    *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expried, entire string not transmitted                      *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComEchoSend(ComPort:Byte; St:String; Timeout:Word);

Var
  Index : Byte;
  Ch : Char;
  TmOut : Boolean;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Initialize control variables}

  Index := 1;
  TmOut := False;

  While (Index <= Length(St)) And (Not TmOut) Do
    Begin
      {Send character}

      ComWriteCh(ComPort,St[Index]);
      StartTimer(C_Timer,4,Timeout,0,False);

      {Wait for echoback -- exit if timeout expires}

      Repeat
        If (C_Status[ComPort] And $01) = 0 Then
          Ch := ComReadCh(ComPort)
        Else
          Ch := Succ(St[Index]);
        TmOut := TimerFlag(C_Timer);
      Until (Ch = St[Index]) Or TmOut;
      Inc(Index);
    End;

  {Return error if timed out}

  If TmOut Then C_Error := C_TimedOut;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure SendBreak(ComPort:Byte; BreakTime:Word)                         *}
{* --- Transmit a BREAK signal                                               *}
{*                                                                           *}
{* The PC serial hardware is capable of transmitting a special signal        *}
{* commonly referred to as a "BREAK request".  A "break" is sent by sending  *}
{* a continuous "space" signal to a device.  The way a device reacts to      *}
{* a "break" signal is dependent on the manufacturer's implementation.       *}
{*                                                                           *}
{* SendBreak will transmit a BREAK signal to port (ComPort) for (BreakTime)  *}
{* milliseconds.  BREAK transmission does not occur until the current        *}
{* character being transmitted (if any) is completely sent.  Once the BREAK  *}
{* period expires, normal character transmission is resumed.                 *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, entire string transmitted                                    *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{*                                                                           *}
{*****************************************************************************}

Procedure SendBreak(ComPort:Byte; BreakTime:Word);

Var
  P : Word;
  OldIER,OldLCR,X : Byte;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Disable transmit interrupt}

  P := C_PortAddr[ComPort];
  IntPush;
  OldIER := Port[P+C_IER];
  Port[P+C_IER] := OldIER And $0D;
  C_Status[ComPort] := C_Status[ComPort] Or $20;
  IntPop;

  {Wait for final character transmission & send pad character (null)}

  While (Port[P+C_LSR] And $20) = 0 Do;
  Port[P+C_TxB] := $00;
  While (Port[P+C_LSR] And $20) = 0 Do;

  {Send BREAK}

  OldLCR := Port[P+C_LCR];
  Port[P+C_LCR] := OldLCR Or $40;
  Delay(BreakTime);

  {Wait for transmitter to clear}

  While (Port[P+C_LSR] And $40) = 0 Do;
  Port[P+C_LCR] := OldLCR;

  {Restore interrupt enable register}

  OldIER := (OldIER And $FC) Or $01;
  IntPush;
  X := C_Status[ComPort] And $DF;
  If (X And $E4) = 0 Then OldIER := OldIER Or $02;
  C_Status[ComPort] := X;
  Port[P+C_IER] := OldIER;
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComFlushBuffer(ComPort:Byte; Timeout:Word)                      *}
{* --- Wait for transmit buffer to clear                                     *}
{*                                                                           *}
{* ComFlushBuffer will suspend program execution until the transmit buffer   *}
{* for (ComPort) is completely cleared or (Timeout) clock "ticks" have       *}
{* passed.  If (Timeout) expires before the transmit buffer is fully cleared *}
{* an error will be returned.                                                *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, transmit buffer now clear                                    *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expried, buffer is not completely clear yet                 *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComFlushBuffer(ComPort:Byte; Timeout:Word);

Var
  X,Y : Byte;
  TmOut : Boolean;

Begin
  If C_ErrorCheck(ComPort,3) Then Exit;          {Check for error}
  StartTimer(C_Timer,4,Timeout,0,False);         {Start timeout counter}

  {Wait for transmit buffer to clear or time to expire}

  Repeat
    X := C_Status[ComPort] And $04;              {Isolate buffer-empty flag}
    Y := Port[C_PortAddr[ComPort] + C_LSR] And $40;  {Isolate data-ready flag}
    TmOut := TimerFlag(C_Timer);                 {Set flag if timeout expired}
  Until (X > 0) And (Y > 0) Or TmOut;

  If TmOut Then C_Error := C_TimedOut;           {Return error if timeout}
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Function ComReadCh(ComPort:Byte) : Char                                   *}
{* --- Read one character from receive buffer                                *}
{*                                                                           *}
{* ComReadCh will remove a single character from the receive buffer of       *}
{* (ComPort) and return it as a result.  If C_RcvWait[ComPort] is TRUE,      *}
{* ComReadCh will wait indefinitely until at least one character is          *}
{* received.  If C_RcvWait[ComPort] is FALSE, a null character (ASCII code   *}
{* 00h) will be returned if the receive buffer is empty, along with a non-   *}
{* zero error code in C_Error.                                               *}
{*                                                                           *}
{* Since this routine is used throught ASYNC for character reception, it     *}
{* has been coded in assembly language to maximize throughput.               *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character received                                           *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 10: Receive buffer empty (only if C_RcvWait is FALSE)                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComReadCh(ComPort:Byte) : Char; External;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComBlockRead(ComPort:Byte; Buffer:Pointer; Var Count:Word)      *}
{*                                                                           *}
{* It is often desirable to be able to grab a block of characters from a     *}
{* port rather than reading them one at a time.  ComBlockRead will remove    *}
{* up to (Count) characters from (ComPort)'s receive buffer and place them   *}
{* in a memory block pointed to by (Buffer).  (Count) returns with the       *}
{* actual number of bytes transferred.                                       *}
{*                                                                           *}
{* If C_RcvWait[ComPort] is TRUE, ComBlockRead will wait indefinitely for    *}
{* exactly (Count) characters to be received; if (ComPort)'s receive buffer  *}
{* has fewer than (Count) characters ComBlockRead will wait until (Count)    *}
{* characters are received.  If C_RcvWait[ComPort] is FALSE, ComBlockRead    *}
{* will return with (Count) set to the actual number of characters           *}
{* transferred to (Buffer) and a non-zero error code in C_Error if this      *}
{* number is less than the value initially passed in (Count).                *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character received                                           *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 10: Receive buffer empty, entire block not filled. (C_RcvWait = FALSE)    *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComBlockRead(ComPort:Byte; Buffer:Pointer; Var Count:Word); External;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComRead(ComPort:Byte; Var St:String; MaxLen:Byte; EndChar:Char) *}
{* --- Read a string from a port                                             *}
{*                                                                           *}
{* ComRead is rougly equivalent to Pascal's READ procedure; it will read     *}
{* up to (MaxLen) characters from (ComPort)'s receive buffer and place them  *}
{* in the string (St).  The read operation will terminate if (MaxLen) char-  *}
{* acters are received or the character (EndChar) is encountered in the      *}
{* received data.  (EndChar) is NOT returned as part of the string.          *}
{*                                                                           *}
{* If C_RcvWait[ComPort] is TRUE, ComRead will not terminate until it's      *}
{* normal termination requirements are met, delaying indefinitely until the  *}
{* appropriate number of characters are received.  If C_RcvWait[ComPort] is  *}
{* FALSE, reception is terminated if the receive buffer is emptied, even if  *}
{* this occurs before normal termination conditions are met.  If this hap-   *}
{* pens, a non-zero error code will be returned in C_Error.                  *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character received                                           *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 10: Receive buffer empty (only if C_RcvWait is FALSE)                     *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComRead(ComPort:Byte; Var St:String; MaxLen:Byte; EndChar:Char);

Var
  Len : Byte;
  Ch : Char;

Begin
  { Check for error }

  If C_ErrorCheck(ComPort,3) Then Exit;
  St := '';
  If MaxLen = 0 Then Exit;

  Len := 0;

  Repeat
    Repeat                                       {Wait for character}
      Ch := ComReadCh(ComPort);
    Until C_Error = 0;
    Inc(Len);                                    {Put character in string}
    St[Len] := Ch;
  Until (Len >= MaxLen) Or (Ch = EndChar);

  If Ch = EndChar Then Dec(Len);                 {Set string length}
  St[0] := Chr(Len);
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComReadln(ComPort:Byte; Var St:String; MaxLen:Byte;             *}
{*           Echo:Boolean)                                                   *}
{*                                                                           *}
{* ComReadln is a "high level" input procedure that provides a simple TTY    *}
{* line editing routine similar in capabilities to Pascal's READLN pro-      *}
{* cedure.  ComReadln will read up to (MaxLen) characters from (ComPort)'s   *}
{* receive buffer and place them in the string (St).  If (Echo) is set to    *}
{* TRUE, all printable (non-control) characters received will be echoed back *}
{* to the remote device that sent them (this is sometimes referred to as     *}
{* "Full duplex" mode).  ComReadln terminates when the "end of line" seq-    *}
{* uence defined in the global string C_EOLIn is received.  Control char-    *}
{* acters (ASCII codes 00-31) are ignored, with the following exceptions:    *}
{*                                                                           *}
{* Ctrl-H (08) : Delete one character from the end of the received string    *}
{* Ctrl-X (24) : Delete the entire string received to this point             *}
{* C_EOLIn (typically Ctrl-M, code 13) : Terminate input & return to caller  *}
{*                                                                           *}
{* All other control characters are ignored and NOT returned.                *}
{* This routine works the same way irregardless of the C_RcvWait setting.    *}
{* C_XmitWait -may- affect operation if (Echo) is TRUE, but typically does   *}
{* not come into play unless the transmit buffer size is very small.         *}
{* If (MaxLen) characters are received (not counting control characters or   *}
{* deleted characters), ComReadln will terminate without waiting for the     *}
{* C_EOLIn sequence.                                                         *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character received                                           *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComReadln(ComPort:Byte; Var St:String; MaxLen:Byte; Echo:Boolean);

Var
  Len,EOLIndex : Byte;
  Ch : Char;
  Done : Boolean;

Begin
  { Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;
  St := '';
  If MaxLen = 0 Then Exit;

  { Initialize control variables }

  Len := 0;
  EOLIndex := 1;
  Done := False;

  Repeat
    { Wait for character from port }

    Repeat
      Ch := ComReadCh(ComPort);
    Until C_Error = 0;

    { Check for end-of-line sequence }

    If Ch = C_EOLIn[EOLIndex] Then
      Begin
        Inc(EOLIndex);
        Done := (EOLIndex > Length(C_EOLIn));
        If Done And Echo Then ComWrite(ComPort,C_EOLOut);
      End
    Else
      EOLIndex := 1;

    { Check for editing commands }

    Case Ch Of
      ^H : If Len > 0 Then                       {Backspace: Delete char}
             Begin
               If Echo Then ComWrite(ComPort,^H' '^H);
               Dec(Len);
             End;
      ^X : If Len > 0 Then                       {Ctrl-X: Delete line}
             Begin
               If Echo Then
                 For Len := Len Downto 1 Do
                   ComWrite(ComPort,^H' '^H);
               Len := 0;
             End;
      #32..#255 : Begin                          {Normal char: Place in string}
                    Inc(Len);
                    St[Len] := Ch;
                    If Echo Then ComWriteCh(ComPort,Ch);
                  End;
    End;

    { Terminate input if maximum length reached }

    If Len >= MaxLen Then
      Begin
        If Echo Then ComWrite(ComPort,C_EOLOut);
        Done := True;
      End;
  Until Done;

  St[0] := Chr(Len);
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Function ComTimedRead(ComPort:Byte; Timeout:Word) : Char                  *}
{* --- Read a single character with receive timeout                          *}
{*                                                                           *}
{* ComTimedRead differs from the standard ComReadCh procedure in one aspect: *}
{* instead of delaying indefinitely or returning a null when there are no    *}
{* characters in the receive buffer, ComTimedRead will instead wait for      *}
{* up to (Timeout) clock "ticks" (1 "tick" = 1/18 second) for a character    *}
{* to be received before returning a null/error result.  If there is a       *}
{* character in (ComPort)'s receive buffer, it is returned immediately.      *}
{* The setting of C_RcvWait[ComPort] has no effect on this routine.          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character received                                           *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expired before a character was received                     *}
{*                                                                           *}
{*****************************************************************************}

Function ComTimedRead(ComPort:Byte; Timeout:Word) : Char;

Var
  TmOut,CharReady : Boolean;

Begin
  If C_ErrorCheck(ComPort,3) Then Exit;          {Check for error}
  StartTimer(C_Timer,4,Timeout,0,False);         {Start timeout counter}

  Repeat
    TmOut := TimerFlag(C_Timer);                 {Get timer status}
    CharReady := (C_Status[ComPort] And $01) = 0;{Determine if rcv buf empty}
  Until TmOut Or CharReady;

  ComTimedRead := ComReadCh(ComPort);            {Get character from port}
  If TmOut Then C_Error := C_TimedOut;           {Return error if timeout}
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWaitFor(ComPort:Byte; St:String; Timeout:Word;               *}
{*           TimeReset:Boolean)                                              *}
{* --- Wait for a character sequence to be received, with timeout            *}
{*                                                                           *}
{* ComWaitFor will delay the caller's execution until the character seq-     *}
{* uence in (St) is received from (ComPort).  (Timeout) determines the       *}
{* maximum amount of time to wait for the (St) character sequence to be      *}
{* received and is measured in clock "ticks" (1 "tick" = 1/18 second).       *}
{* (TimeReset) determines the mechanisim used to determine timeouts.  If     *}
{* FALSE, the entire (St) character sequence must be received before         *}
{* a single (Timeout) period expires.  If TRUE, the internal timeout counter *}
{* is reset to (Timeout) every time a new character is received.  This       *}
{* mode ensures that termination with an error does not occur until the      *}
{* receiver is idle.                                                         *}
{*                                                                           *}
{* All characters processed during the WaitFor time are discarded.           *}
{* This routine is especially useful for those applications that need to     *}
{* wait for character or string prompts from a remote system before sending  *}
{* data to the remote.  It can also be used to create "logon scripts" for    *}
{* BBS's and remote computing stations.                                      *}
{*                                                                           *}
{* The setting of C_RcvWait[ComPort] has no effect on this routine.          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, character sequence in (St) received                          *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expired before (St) sequence received                       *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWaitFor(ComPort:Byte; St:String; Timeout:Word; TimeReset:Boolean);

Var
  Index,X : Byte;
  Ch : Char;
  TmOut : Boolean;

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Initialize control variables, start timeout countdown}

  Index := 1;
  TmOut := False;
  StartTimer(C_Timer,4,Timeout,0,False);

  {Wait for string to be received (main loop)}

  While (Index <= Length(St)) And (Not TmOut) Do
    Begin
      If TimeReset Then StartTimer(C_Timer,4,Timeout,0,False);

      {Wait for incoming character or timeout}

      Repeat
        X := C_Status[ComPort] And $01;
        TmOut := TimerFlag(C_Timer);
      Until (X = 0) Or TmOut;
      Ch := ComReadCh(ComPort);

      {Increment string index if character matches current search char}

      If (Ch = St[Index]) And (Not TmOut) Then
        Inc(Index)
      Else
        Begin
          Index := 1;
          If Ch = St[Index] Then Inc(Index);
        End;
    End;

  {Return error if timed out}

  If TmOut Then C_Error := C_TimedOut;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWaitForClear(ComPort:Byte; Timeout:Word)                     *}
{* --- Wait for receiver to become idle                                      *}
{*                                                                           *}
{* ComWaitForClear simply removes and discards characters in (ComPort)'s     *}
{* receive buffer and waits for (Timeout) clock "ticks" (1 "tick" = 1/18     *}
{* second) of inactivity (i.e. no character reception) before returning.     *}
{* Every time a new character is received it is discarded and the internal   *}
{* timeout counter is reset to (Timeout).  When (Timeout) expires, the       *}
{* routine terminates.                                                       *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error, receiver was idle for (Timeout) ticks                        *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWaitForClear(ComPort:Byte; Timeout:Word);

Begin
  {Check for error}

  If C_ErrorCheck(ComPort,3) Then Exit;

  {Clear receive buffer & wait to make sure nothing else is received}

  StartTimer(C_Timer,4,Timeout,0,False);
  Repeat
    If (C_Status[ComPort] And $01) = 0 Then
      Begin
        ClearCom(ComPort,'I');
        StartTimer(C_Timer,4,Timeout,0,False);
      End;
  Until TimerFlag(C_Timer);
End;

