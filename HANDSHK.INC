{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file HANDSHK.INC                                                  *}
{* --- Handshake/mode controlling routines                                   *}
{*                                                                           *}
{* These routines provide an interface to the software and hardware hand-    *}
{* shaking capabilities of the ASYNC ISR port driver.  Using the routines    *}
{* in this section a program can control the characters used for software    *}
{* handshaking and the I/O lines and levels used for hardware handshaking.   *}
{* Procedures are provided to enable or disable the various handshaking      *}
{* modes.  The ASYNC documentation covers handshaking in detail; consult it  *}
{* for a more in-depth treatment of these routines.                          *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Procedure ComFIFOMode(ComPort:Byte; Enable:Boolean)                     *}
{* - Procedure ComWaitMode(ComPort:Byte; Mode:Char; Enable:Boolean)          *}
{* - Procedure HandshakeMode(ComPort:Byte; Mode,Dir:Char; Enable:Boolean)    *}
{* - Procedure HandshakeOnOff(ComPort:Byte; On,Off:Word)                     *}
{* - Procedure SoftHSChar(ComPort:Byte; XOn,XOff:Char)                       *}
{* - Procedure HardHSOutput(ComPort:Byte; Modify,Assert:Byte)                *}
{* - Procedure HardHSInput(ComPort:Byte; Check,Match:Byte)                   *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{*****************************************************************************}
{*                                                         Modified 12/28/90 *}
{*                                                                           *}
{* Procedure ComFIFOMode(ComPort:Byte; Enable:Boolean)                       *}
{* --- Enable/disable usage of hardware FIFOs on compatable UARTs            *}
{*                                                                           *}
{* Some UARTs, such as the NS16550 have the capability to buffer (at the     *}
{* hardware level) up to 16 characters received or to be transmitted.        *}
{* ComFIFOMode may be used to enable or disable this feature for COM ports   *}
{* that support this IC.  If (Enable) is TRUE, hardware buffering for the    *}
{* port specified by (ComPort) is enabled.  If (Enable) is FALSE, this       *}
{* feature is inhibited.  For applications requiring the simultaneous use of *}
{* several COM ports receiving and/or transmitting data at high speed it is  *}
{* recommended that this feature be ENABLED if the hardware supports it.     *}
{* This procedure may only be used on ports that have NS16550-compatable     *}
{* UART IC's; if called for an incompatable port an error is returned.  The  *}
{* global boolean array C_FIFOExist[ComPort] may be interrogated to det-     *}
{* ermine if a particular COM port supports this capability.  The function   *}
{* ComFIFOExist may also be used.                                            *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present, or the port does not support hardware FIFOs *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComFIFOMode(ComPort:Byte; Enable:Boolean);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;

	{UART must be FIFO-compatable; exit w/error if not}

  If Not C_FIFOExist[ComPort] Then
    Begin
      C_Error := C_PortNotFound;
      Exit;
    End;

  {Set/reset UART FIFO mode}

  If Enable Then
    Port[C_PortAddr[ComPort]+C_FCR] := $07  {Enable FIFO mode, reset buffers}
  Else
    Port[C_PortAddr[ComPort]+C_FCR] := $00; {Disable FIFO mode}
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComWaitMode(ComPort:Byte; Mode:Char; Enable:Boolean)            *}
{* --- Enable/disable "wait" mode for a transmission or reception for a port *}
{*                                                                           *}
{* The low-level I/O routines (ComReadCh, ComWriteCh, ComBlockRead and       *}
{* ComBlockWrite) have two distinct operating modes: "Wait" mode and "No-    *}
{* wait" mode.  For READ routines, "Wait" mode implies that the routine      *}
{* will not terminate until at least one character (or several, for ComBlock *}
{* Read) are received.  For WRITE routines, "Wait" mode forces the routine   *}
{* to wait for enough transmit buffer space to send it's character(s) before *}
{* it exits.  "No-wait" mode for READs allows these routines to potentially  *}
{* return a "null" result if the receive buffer is empty, and allows WRITE   *}
{* routines to terminate without transmitting anything if inadequate trans-  *}
{* mit buffer space exists.  ComWaitMode allows a program to control which   *}
{* mode is used for transmit and receive for the port specified by (ComPort).*}
{* (Mode) is a character from the table below that specifies whether the     *}
{* receiver, transmitter or both are effected by the value of (Enable).      *}
{* (Enable) in turn specifies the wait mode: TRUE to enable wait mode, FALSE *}
{* to disable it.                                                            *}
{*                                                                           *}
{* (Mode)    | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I or i    | Change mode for READ routines (ComReadCh,ComBlockRead)        *}
{* O or o    | Change mode for WRITE routines (ComWriteCh,ComBlockWrite)     *}
{* B or b    | Change mode for both READ and WRITE routines                  *}
{*                                                                           *}
{* Note:  Since all of the higher-level I/O routines in ASYNC make use of    *}
{*        the four aforementioned low-level routines, the wait mode selected *}
{*        by this procedure will affect the operation of most of the other   *}
{*        I/O routines found in ASYNC.                                       *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: (Mode) value not recognized                                            *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComWaitMode(ComPort:Byte; Mode:Char; Enable:Boolean);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  Mode := Upcase(Mode);
  If Pos(Mode,'IOB') = 0 Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Set (or reset) transmit/receive wait flags}

  If (Mode = 'I') Or (Mode = 'B') Then C_RcvWait[ComPort] := Enable;
  If (Mode = 'O') Or (Mode = 'B') Then C_XmitWait[ComPort] := Enable;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure HandshakeMode(ComPort:Byte; Mode,Dir:Char; Enable:Boolean)      *}
{* --- Selects and enables/disables handshaking options for a port           *}
{*                                                                           *}
{* ASYNC supports full software (character-mode) and hardware (I/O line)     *}
{* handshaking for all ports.  If a handshaking mode is enabled a remote     *}
{* system or periperhal may send transmit pacing requests to ASYNC, and/or   *}
{* allow ASYNC to send such requests to a remote system or peripheral.       *}
{* HandshakeMode controls which handshaking mode(s), if any, are to be used. *}
{* (ComPort) specifies the port to be configured.  (Mode) determines the     *}
{* "type" of handshaking (hardware, software or both) that is to be changed. *}
{* (Dir) determines the "direction" (input/receive, output/transmit, or      *}
{* both) to which handshaking is to be applied (or inhibited).  (Enable)     *}
{* specifies whether the handshake mode(s) for the given direction(s) are to *}
{* be enabled or disabled.  Both (Mode) and (Dir) are character parameters   *}
{* that should be choosen from the tables below:                             *}
{*                                                                           *}
{* (Mode)    | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* H or h    | Enable/disable HARDWARE handshaking                           *}
{* S or s    | Enable/disable SOFTWARE handshaking                           *}
{* B or b    | Enable/disable both HARDWARE and SOFTWARE handshaking         *}
{*                                                                           *}
{* (Dir)     | Action                                                        *}
{* ----------|-------------------------------------------------------------- *}
{* I,i,R,r   | Change handshaking mode(s) for INPUT (receive)                *}
{* O,o,T,t   | Change handshaking mode(s) for OUTPUT (transmit)              *}
{* B or b    | Change handshaking mode(s) for both INPUT and OUTPUT          *}
{*                                                                           *}
{* Note:  INPUT handshaking allows a remote system or peripheral to pace     *}
{*        ASYNC's transmission by monitoring the port's input control lines  *}
{*        or checking all of the port's received data for pacing characters. *}
{*        OUTPUT handshaking allows ASYNC to pace a remote system or periph- *}
{*        eral's transmissions by controlling port output lines or through   *}
{*        the transmission of pacing characters to a remote system.          *}
{*        ** If you are unfamiliar with the concept of "handshaking" or      *}
{*        puzzled by this routine's calling convention you should consult    *}
{*        the tutorial and reference section(s) of your manual.              *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: (Mode) or (Dir) value not recognized                                   *}
{*                                                                           *}
{*****************************************************************************}

Procedure HandshakeMode(ComPort:Byte; Mode,Dir:Char; Enable:Boolean);

Const
  HSMask : Array[1..9] Of Byte = ($01,$02,$03,$04,$08,$0C,$05,$0A,$0F);

Var
  X,Y : Byte;

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  Mode := Upcase(Mode);
  Dir := Upcase(Dir);
  X := Pos(Mode,'HSB');
  Y := Pos(Dir,'OIBTR');
  If Y > 3 Then Dec(Y,3);
  If (X = 0) Or (Y = 0) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;
  X := X + Y * 3 - 3;

  {Enable (or disable) handshaking modes as selected by parameters passed}

  If Enable Then
    C_Ctrl[ComPort] := C_Ctrl[ComPort] Or HSMask[X]
  Else
    C_Ctrl[ComPort] := C_Ctrl[ComPort] And (HSMask[X] XOr $FF);
End;

{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Procedure HandshakeOnOff(ComPort:Byte; On,Off:Word)                       *}
{* --- Set output handshaking assertion/negation points                      *}
{*                                                                           *}
{* Output handshaking (both software and hardware forms) is controlled by    *}
{* the amount of space left in a port's receive buffer.  If the receive buf- *}
{* fer for a port is nearly full, ASYNC can send a "XOFF" character and/or   *}
{* unassert various RS-232 control signals, telling a remote system or hard- *}
{* wired peripheral to temporarily stop sending data.  When enough data is   *}
{* removed (via ComReadCh or other "input" routines) from the receive buffer *}
{* ASYNC will then send a "XON" character and/or assert the previously neg-  *}
{* ated control signals, signalling the remote system/peripheral that it is  *}
{* O.K. to resume transmission.  HandshakeOnOff is used to specify the point *}
{* at which XOFF/negation and XON/assertion takes place. (ComPort) specifies *}
{* the port # to change.  When the number of unused bytes left in the        *}
{* receive buffer shrinks below the (Off) setpoint, XOFF/negation takes      *}
{* place.  Once this takes place, a minimum of (On) free bytes must be       *}
{* present in the receive buffer before XON/assertion takes place.  These    *}
{* seperate (On) and (Off) values allow the programmer to specify a degree   *}
{* of hysterisis in handshaking, avoiding repeated and frequent              *}
{* assert/unassert cycling.  Since it makes no sense to have an (Off) point  *}
{* greater than the (On) point this routine will return an error if          *}
{* (On) <= (Off)                                                             *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: Invalid parameters; (On) <= (Off)                                      *}
{*                                                                           *}
{*****************************************************************************}

Procedure HandshakeOnOff(ComPort:Byte; On,Off:Word);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  If On <= Off Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign control values for output handshaking arbitration}
  {These values are compared against the current # bytes free in the receive}
  {buffer whenever a new character is received and determine when handshaking}
  {is asserted or negated.}

  C_HSOn[ComPort] := On;
  C_HSOff[ComPort] := Off;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure SoftHSChar(ComPort:Byte; XOn,XOff:Char)                         *}
{* --- Specify the control characters to be used in software handshaking     *}
{*                                                                           *}
{* When software handshaking is employed special control characters are used *}
{* between the host (ASYNC) and the remote system to tell each other when    *}
{* to suspend or resume data transmission.  SoftHSChar allows the programmer *}
{* to specify the character codes sent/received to suspend or resume         *}
{* transmission.  (ComPort) specifies the port to modify.  (XOn) determines  *}
{* the character which signals "OK to transmit" and (XOff) specifies the     *}
{* "Suspend transmit" code.  These values are used by both input and output  *}
{* software handshaking, if enabled.  Both (XOn) and (XOff) must be in the   *}
{* control character range (ASCII codes 00-31 decimal) or an error will      *}
{* result.                                                                   *}
{*                                                                           *}
{* The most common value for (XOn) is ^S, ASCII code 19.  (XOff) is          *}
{* typically defined as ^Q, ASCII code 17 on most systems.                   *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: Invalid parameters; (XOn) and/or (XOff) are not control characters     *}
{*                                                                           *}
{*****************************************************************************}

Procedure SoftHSChar(ComPort:Byte; XOn,XOff:Char);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  If (XOn > #31) Or (XOff > #31) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign characters to use for software handshake}

  C_XON[ComPort] := XOn;
  C_XOFF[ComPort] := XOff;
End;

{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Procedure HardHSOutput(ComPort:Byte; Modify,Assert:Byte)                  *}
{* --- Specify output lines & levels used for input hardware handshaking     *}
{*                                                                           *}
{* HardHSOutput is used to control which of the available RS-232 output      *}
{* lines are used to perform handshaking between the computer and a external *}
{* device.  (ComPort) specifies the port to modify.  (Modify) is a bit-      *}
{* mapped byte variable that determines which output lines to modify when    *}
{* handshaking takes place (see table below).  (Assert) is another bitmapped *}
{* variable (with the same definition as (Modify)) that determines the       *}
{* "Handshake asserted" level of the control lines selected by (Modify).     *}
{*                                                                           *}
{* (Modify) |   OUT1   |   RTS    |   DTR    |                               *}
{* ---------|----------|----------|----------|                               *}
{*     0    | Not used | Not used | Not used |  Not used: Control signal is  *}
{*     1    | Not used | Not used |   Used   |    not modified under any     *}
{*     2    | Not used |   Used   | Not used |    conditions.                *}
{*     3    | Not used |   Used   |   Used   |  Used: Control signal is      *}
{*     4    |   Used   | Not used | Not used |    modified based on whether  *}
{*     5    |   Used   | Not used |   Used   |    or not handshaking is      *}
{*     6    |   Used   |   Used   | Not used |    asserted or negated.       *}
{*     7    |   Used   |   Used   |   Used   |                               *}
{*                                                                           *}
{* (Assert) uses the same bitmap -- if the corresponding bit in (Assert) is  *}
{* set, the signal is ASSERTED when remote transmission is desired.          *}
{* If the bit is reset, the signal is NEGATED when remote transmission is    *}
{* desired.  The usual value of bits in (Assert) is "1" and in most appli-   *}
{* cations (Assert) is set equal to (Modify).  Consult the ASYNC manual for  *}
{* further details regarding hardware handshaking modes.                     *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: Invalid parameters; (Modify) or (Assert) > 07h                         *}
{*                                                                           *}
{*****************************************************************************}

Procedure HardHSOutput(ComPort:Byte; Modify,Assert:Byte);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  If (Modify > $07) Or (Assert > $07) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign control values for receive hardware handshaking}
  {(determines output signal lines to use & level when asserted)}

  C_HWModify[ComPort] := Modify;
  C_HWAssert[ComPort] := Assert And Modify;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure HardHSInput(ComPort:Byte; Check,Match:Byte)                     *}
{* --- Specify input lines & levels used for output hardware handshaking     *}
{*                                                                           *}
{* HardHSInput is used to control which of the available RS-232 input lines  *}
{* are used to perform handshaking between the computer and a external       *}
{* device.  (ComPort) specifies the port to modify.  (Check) is a bitmapped  *}
{* byte variable that determines which input lines to monitor during char-   *}
{* acter transmission (see table below).  (Match) uses the same bit def-     *}
{* initions and determines the "enable" level of the lines selected by       *}
{* (Check).  In most applications, (Match) is set equal to (Check).          *}
{*                                                                           *}
{*  (Check) |   DCD   |    RI   |   DSR   |   CTS   |                        *}
{* ---------|---------|---------|---------|---------|                        *}
{*     0    | Ignored | Ignored | Ignored | Ignored |  Ignored: Signal line  *}
{*     1    | Ignored | Ignored | Ignored | Checked |    does not control    *}
{*     2    | Ignored | Ignored | Checked | Ignored |    data transmission   *}
{*     3    | Ignored | Ignored | Checked | Checked |  Checked: Signal line  *}
{*     4    | Ignored | Checked | Ignored | Ignored |    is interrogated     *}
{*     5    | Ignored | Checked | Ignored | Checked |    during data trans-  *}
{*     6    | Ignored | Checked | Checked | Ignored |    mission and will    *}
{*     7    | Ignored | Checked | Checked | Checked |    be used to control  *}
{*     8    | Checked | Ignored | Ignored | Ignored |    transmission (per   *}
{*     9    | Checked | Ignored | Ignored | Checked |    setting in the      *}
{*    10    | Checked | Ignored | Checked | Ignored |    MATCH variable).    *}
{*    11    | Checked | Ignored | Checked | Checked |                        *}
{*    12    | Checked | Checked | Ignored | Ignored |                        *}
{*    13    | Checked | Checked | Ignored | Checked |                        *}
{*    14    | Checked | Checked | Checked | Ignored |                        *}
{*    15    | Checked | Checked | Checked | Checked |                        *}
{*                                                                           *}
{* (Match) uses the same bitmap as (Check).  A "1" bit specifies that the    *}
{* corresponding signal line must be ASSERTED to allow data transmission.    *}
{* A "0" bit in (Match) means the line must be NEGATED to allow transmission.*}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error                                                               *}
{* 1: Invalid port number                                                    *}
{* 2: Port hardware not present                                              *}
{* 5: Invalid parameters; (Modify) or (Assert) > 15                          *}
{*                                                                           *}
{*****************************************************************************}

Procedure HardHSInput(ComPort:Byte; Check,Match:Byte);

Begin

  {Make sure port hardware exists & parameters are valid}

  If C_ErrorCheck(ComPort,2) Then Exit;
  If (Check > $0F) Or (Match > $0F) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Assign control values to use for transmit hardware handshaking}
  {(determines input lines to use & level they must be at to signal assertion)}

  C_HWCheck[ComPort] := Check;
  C_HWMatch[ComPort] := Match And Check;
End;

