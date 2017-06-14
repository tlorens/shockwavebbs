{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Include file IOLINE.INC                                                   *}
{* --- RS-232 I/O line monitoring & control routines                         *}
{*                                                                           *}
{* These routines are used to monitor the status of the various RS-232       *}
{* input signals and control the levels of RS-232 output control signals.    *}
{*                                                                           *}
{* Important note: If any of the control signals documented in this file are *}
{* used for hardware handshaking, you should avoid using the procedures and  *}
{* functions corresponding to the signals in use, since the ASYNC ISR will   *}
{* control or read these lines automatically.                                *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Procedure SetDTR(ComPort:Byte; Action:Char)                             *}
{* - Procedure SetRTS(ComPort:Byte; Action:Char)                             *}
{* - Procedure SetOUT1(ComPort:Byte; Action:Char)                            *}
{* - Procedure SetOUT2(ComPort:Byte; Action:Char)                            *}
{* - Procedure SetAll(ComPort,Modify,Assert:Byte)                            *}
{* - Function CTSStatus(ComPort:Byte) : Boolean                              *}
{* - Function DSRStatus(ComPort:Byte) : Boolean                              *}
{* - Function RIStatus(ComPort:Byte) : Boolean                               *}
{* - Function DCDStatus(ComPort:Byte) : Boolean                              *}
{* - Function AllStatus(ComPort:Byte) : Byte                                 *}
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
{* Procedure SetDTR(ComPort:Byte; Action:Char)                               *}
{* --- Control the DTR (Data Terminal Ready) line                            *}
{*                                                                           *}
{* SetDTR controls the status of the Data Terminal Ready signal line found   *}
{* on pin 20 of most RS-232 connectors.  (ComPort) specifies the port to     *}
{* use and (Action) controls the level of the signal according to the table  *}
{* below.  DTR is used by most peripherals to indicate that the computer is  *}
{* powered up and it's serial subsystem is initialized and ready.  In ASYNC, *}
{* you would typically assert DTR after a call to OpenCom and unassert it    *}
{* immediately before calling CloseCom.                                      *}
{*                                                                           *}
{* Signal line action characters (Action):                                   *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{*   S/s/1   | Assert (set) DTR line                                         *}
{*   R/r/0   | Unassert (reset) DTR line                                     *}
{*  T/t/X/x  | Toggle DTR line to opposite position                          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetDTR(ComPort:Byte; Action:Char);

Var
  P : Word;
  X : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then Exit;
  P := C_PortAddr[ComPort];

  IntPush;
  X := Port[P+C_MCR];
  Case Action Of
    'S','1' : X := X Or $01;
    'R','0' : X := X And $FE;
    'X','T' : X := X XOr $01;
    Else C_Error := C_BadParameter;
  End;
  Port[P+C_MCR] := X;
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure SetRTS(ComPort:Byte; Action:Char)                               *}
{* --- Control the RTS (Request to Send) line                                *}
{*                                                                           *}
{* SetRTS is used to control the Request to Send signal line typically found *}
{* on pin 4 of most RS-232 connectors.  (ComPort) specifies the port to      *}
{* use and (Action) controls the level of the signal according to the table  *}
{* below.  RTS is used by most peripherals to signal when transmission from  *}
{* the peripheral to the computer is OK.  This line is commonly used in      *}
{* hardware handshaking schemes.  RTS is typically asserted when data        *}
{* reception is OK and unasserted when the computer is not ready to receive. *}
{*                                                                           *}
{* Signal line action characters (Action):                                   *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{*   S/s/1   | Assert (set) RTS line                                         *}
{*   R/r/0   | Unassert (reset) RTS line                                     *}
{*  T/t/X/x  | Toggle RTS line to opposite position                          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetRTS(ComPort:Byte; Action:Char);

Var
  P : Word;
  X : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then Exit;
  P := C_PortAddr[ComPort];

  IntPush;
  X := Port[P+C_MCR];
  Case Action Of
    'S','1' : X := X Or $02;
    'R','0' : X := X And $FD;
    'X','T' : X := X XOr $02;
    Else C_Error := C_BadParameter;
  End;
  Port[P+C_MCR] := X;
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure SetOUT1(ComPort:Byte; Action:Char)                              *}
{* -- Control the OUT1 (internal modem reset) line                           *}
{*                                                                           *}
{* SetOUT1 is used to control the OUT1 signal that is present on 8250-       *}
{* compatable UART IC's.  OUT1 is typically not bonded to the RS-232 conn-   *}
{* ector but is used on some internal modems as a "Modem microprocessor      *}
{* RESET" signal.  (ComPort) specifies the port to modify and (Assert)       *}
{* controls the level of the OUT1 signal line according to the table below:  *}
{*                                                                           *}
{* Signal line action characters (Action):                                   *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{*   S/s/1   | Assert (set) OUT1 line                                        *}
{*   R/r/0   | Unassert (reset) OUT1 line                                    *}
{*  T/t/X/x  | Toggle OUT1 line to opposite position                         *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetOUT1(ComPort:Byte; Action:Char);

Var
  P : Word;
  X : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then Exit;
  P := C_PortAddr[ComPort];

  IntPush;
  X := Port[P+C_MCR];
  Case Action Of
    'S','1' : X := X Or $04;
    'R','0' : X := X And $FB;
    'X','T' : X := X XOr $04;
    Else C_Error := C_BadParameter;
  End;
  Port[P+C_MCR] := X;
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure SetOUT2(ComPort:Byte; Action:Char)                              *}
{* --- Control the OUT2 (UART interrupt mask) line                           *}
{*                                                                           *}
{* SetOUT1 is used to control the OUT2 signal that is present on 8250-       *}
{* compatable UART IC's.  OUT2 is typically not bonded to the RS-232 conn-   *}
{* ector but is used by PC-compatable serial boards to enable or mask the    *}
{* interrupt output signal.  The OpenCom procedure asserts this line after   *}
{* initializing the UART to allow interrupts to pass through to the          *}
{* processor.  (ComPort) specifies the port to modify and (Assert) controls  *}
{* the level of the OUT1 signal line according to the table below:           *}
{*                                                                           *}
{* Signal line action characters (Action):                                   *}
{*                                                                           *}
{* Character | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{*   S/s/1   | Assert (set) OUT2 line                                        *}
{*   R/r/0   | Unassert (reset) OUT2 line                                    *}
{*  T/t/X/x  | Toggle OUT2 line to opposite position                         *}
{*                                                                           *}
{* Note: SetOUT2 is provided to allow users with experience programming      *}
{*       the PC at the hardware level full control over UART functions.  Do  *}
{*       NOT use this procedure unless you know what you are doing!          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetOUT2(ComPort:Byte; Action:Char);

Var
  P : Word;
  X : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then Exit;
  P := C_PortAddr[ComPort];

  IntPush;
  X := Port[P+C_MCR];
  Case Action Of
    'S','1' : X := X Or $08;
    'R','0' : X := X And $F7;
    'X','T' : X := X XOr $08;
    Else C_Error := C_BadParameter;
  End;
  Port[P+C_MCR] := X;
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Procedure SetAll(ComPort,Modify,Assert:Byte)                              *}
{* --- Control all output lines                                              *}
{*                                                                           *}
{* SetAll is used to control all four output signal lines at the same time.  *}
{* (ComPort) specifies the port to use.  (Modify) and (Assert) control the   *}
{* output levels of the DTR, RTS, OUT1 and OUT2 signal lines.  (Modify) is   *}
{* a bitmapped variable that determines which of the four signal lines to    *}
{* change, according to the bitmap table below.  (Assert) is another bit-    *}
{* mapped variable that specifies the output level for each line selected    *}
{* by (Modify).                                                              *}
{*                                                                           *}
{* (Modify) and (Assert) bitmap:                                             *}
{*                                                                           *}
{* Bit #   | Line affected                                                   *}
{* --------|---------------------------------------------------------------- *}
{* 0 (2^0) | Data Terminal Ready (DTR)                                       *}
{* 1 (2^1) | Request to Send (RTS)                                           *}
{* 2 (2^2) | OUT1 / Internal modem reset                                     *}
{* 3 (2^3) | OUT2 / Interrupt enable                                         *}
{*                                                                           *}
{* Bit(s) in (Modify) should be SET to affect the signal line shown.         *}
{* If the corresponding bit in (Assert) is "1", the line shown in the table  *}
{* above is ASSERTED.  If "0", the line is UNASSERTED.                       *}
{* A error will be generated if (Modify) or (Assert) are > 15 (0Fh).         *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 5: (Modify) or (Assert) out of range                                      *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetAll(ComPort,Modify,Assert:Byte);

Var
  P : Word;
  X,On,Off : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then Exit;
  If (Modify > $0F) Or (Assert > $0F) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  P := C_PortAddr[ComPort];
  On := Modify And Assert;                    {OR-mask for assert bits}
  Off := Modify And (Assert XOR $FF) XOr $FF; {AND mask for unassert bits}

  IntPush;
  X := Port[P+C_MCR];                    {Read control register}
  Port[P+C_MCR] := X And Off Or On;      {Change control lines & save}
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Function CTSStatus(ComPort:Byte) : Boolean                                *}
{* --- Read status of CTS (Clear to Send) line                               *}
{*                                                                           *}
{* CTSStatus returns the status of the Clear to Send (CTS) line on the port  *}
{* specified by (ComPort).  If the CTS input (pin 5 on most RS-232 conn-     *}
{* ectors) is asserted, CTSStatus returns with a TRUE result.  The CTS       *}
{* signal is typically used to tell the host computer that a remote periph-  *}
{* eral is ready to accept data.  CTS is often used in hardware hand-        *}
{* shaking schemes.                                                          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Function CTSStatus(ComPort:Byte) : Boolean;

Begin
  If C_ErrorCheck(ComPort,2) Then
    Begin
      CTSStatus := False;
      Exit;
    End;
  CTSStatus := (Port[C_PortAddr[ComPort]+C_MSR] And $10) <> 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Function DSRStatus(ComPort:Byte) : Boolean                                *}
{* --- Read status of DSR (Data Set Ready) line                              *}
{*                                                                           *}
{* DSRStatus returns the status of the Data set Ready (DSR) line on the port *}
{* specified by (ComPort).  If the DSR input (pin 6 on most RS-232 conn-     *}
{* ectors) is asserted, DSRStatus returns with a TRUE result.  The DSR       *}
{* signal is the compliment of the DTR output and indicates to the host that *}
{* a remote peripheral is on and initialized.  DSR is often used in hardware *}
{* handshaking schemes.                                                      *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Function DSRStatus(ComPort:Byte) : Boolean;

Begin
  If C_ErrorCheck(ComPort,2) Then
    Begin
      DSRStatus := False;
      Exit;
    End;
  DSRStatus := (Port[C_PortAddr[ComPort]+C_MSR] And $20) <> 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Function RIStatus(ComPort:Byte) : Boolean                                 *}
{* --- Read status of the RI (Ring Indicator) line                           *}
{*                                                                           *}
{* RISTatus returns the status of the Ring Indicator (RI) line on the port   *}
{* specified by (ComPort).  If the RI input (pin 22 on most RS-232 conn-     *}
{* ectors) is asserted, this usually indicates that an incoming call is      *}
{* present on a modem connected to the port.  A TRUE result from RIStatus    *}
{* indicates that the Ring Indicator input is asserted.                      *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Function RIStatus(ComPort:Byte) : Boolean;

Begin
  If C_ErrorCheck(ComPort,2) Then
    Begin
      RIStatus := False;
      Exit;
    End;
  RIStatus := (Port[C_PortAddr[ComPort]+C_MSR] And $40) <> 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Function DCDStatus(ComPort:Byte) : Boolean                                *}
{* --- Read status of DCD (Data Carrier Detect) line                         *}
{*                                                                           *}
{* DCDStatus returns the status of the Data Carrier Detect (DCD) line on the *}
{* port specified by (ComPort).  If the DCD input (pin 8 on most RS-232      *}
{* connectors) is asserted, DCDStatus returns with a TRUE result.  The DCD   *}
{* signal is found on most modems and indicates (if asserted) that a remote  *}
{* modem has successfully established a connection with a modem connected    *}
{* to the computer.                                                          *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Function DCDStatus(ComPort:Byte) : Boolean;

Begin
  If C_ErrorCheck(ComPort,2) Then
    Begin
      DCDStatus := False;
      Exit;
    End;
  DCDStatus := (Port[C_PortAddr[ComPort]+C_MSR] And $80) <> 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/09/93 *}
{*                                                                           *}
{* Function AllStatus(ComPort:Byte) : Byte                                   *}
{* --- Read the status of all input lines                                    *}
{*                                                                           *}
{* AllStatus returns the status of all four RS-232 signal lines according    *}
{* to the bitmap table below:                                                *}
{*                                                                           *}
{* Bit #   | Signal definition                                               *}
{* --------|---------------------------------------------------------------- *}
{* 0 (2^0) | CTS (Clear to Send)                                             *}
{* 1 (2^1) | DSR (Data Set Ready)                                            *}
{* 2 (2^2) | RI  (Ring Indicator)                                            *}
{* 3 (2^3) | DCD (Data Carrier Detect)                                       *}
{*                                                                           *}
{* a "1" bit in the position shown above indicates that the line is          *}
{* presently asserted.                                                       *}
{*                                                                           *}
{* Possible error returns (in C_Error) :                                     *}
{* 0: No error                                                               *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{*                                                                           *}
{*****************************************************************************}

Function AllStatus(ComPort:Byte) : Byte;

Begin
  If C_ErrorCheck(ComPort,2) Then
    Begin
      AllStatus := 0;
      Exit;
    End;
  AllStatus := Port[C_PortAddr[ComPort]+C_MSR] SHR 4;
End;

