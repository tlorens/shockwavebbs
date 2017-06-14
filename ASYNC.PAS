{A+,B-,E+,F-,G-,I-,N-,O-,R-,S+,V-,X+}

Unit ASYNC;

INTERFACE

Uses opcrt,DOS,Timer;

{-----------------------------------------------------------------------------}

{Note: A complete description of all variables and constants can be found in}
{the documentation accompanying ASYNC.}

Const
  C_Version = '1.00';                  {Version #}
  C_MinBaud = 2;                       {Minimum allowed baud rate}
  C_MaxBaud = 115200;                  {Highest allowed baud rate}
  C_MaxPort = 5;                      {Highest port # allowed; array size}
  C_MinBufSize = 16;                   {Minimum input/output buffer size}

  C_ExistMode  : Boolean = FALSE;      {Default mode to use in ComExist}
  C_ExistBDiv  : Word = 6;             {Baud divisor for ComExist: 19200}
  C_ExistDelay : Word = 2;             {Echoback delay for ComExist}

  {Error codes}

  C_NoError = 0;                       {No error}
  C_InvalidPort = 1;                   {Port # invalid (no definition)}
  C_PortNotFound = 2;                  {Port hardware not present}
  C_PortNotOpen = 3;                   {Port must be opened}
  C_PortNotClosed = 4;                 {Port must be closed}
  C_BadParameter = 5;                  {Invalid parameter passed}
  C_NoMemory = 6;                      {Insufficient memory for buffers}
  C_ReceiveEmpty = 10;                 {Receive buffer empty}
  C_TransmitFull = 11;                 {Transmit buffer full}
  C_TimedOut = 12;                     {Timeout expired}

  {8250/16450 register offsets}

  C_RxB = 0;                           {Receive buffer}
  C_TxB = 0;                           {Transmit buffer}
  C_DLL = 0;                           {Divisor latch, low byte}
  C_DLH = 1;                           {Divisor latch, high byte}
  C_IER = 1;                           {Interrupt enable register}
  C_IIR = 2;                           {Interrupt identification register}
  C_FCR = 2;                           {FIFO control register}
  C_LCR = 3;                           {Line control register}
  C_MCR = 4;                           {Modem control register}
  C_LSR = 5;                           {Line status register}
  C_MSR = 6;                           {Modem status register}
  C_SCR = 7;                           {Scratch register}

Type
  C_Long = Array[1..C_MaxPort] Of Pointer;
  C_Word = Array[1..C_MaxPort] Of Word;
  C_Byte = Array[1..C_MaxPort] Of Byte;
  C_Char = Array[1..C_MaxPort] Of Char;
  C_Boolean = Array[1..C_MaxPort] Of Boolean;

{-----------------------------------------------------------------------------}

Var
  C_InBufPtr  : C_Long;      {Pointer to input buffer}
  C_OutBufPtr : C_Long;      {Pointer to output buffer}
  C_PortAddr  : C_Word;      {Addresses of port hardware}
  C_InSize    : C_Word;      {Size of input buffer}
  C_OutSize   : C_Word;      {Size of output buffer}
  C_InHead    : C_Word;      {Input buffer head pointer}
  C_InTail    : C_Word;      {Input buffer tail pointer}
  C_OutHead   : C_Word;      {Output buffer head pointer}
  C_OutTail   : C_Word;      {Output buffer tail pointer}
  C_HSOn      : C_Word;      {Receive handshaking turn-on/assert point}
  C_HSOff     : C_Word;      {Receive handshaking turn-off/unassert point}
  C_PortInt   : C_Byte;      {Hardware interrupt line used by port}
  C_Status    : C_Byte;      {Port status register; see documentation}
  C_Ctrl      : C_Byte;      {Port control register; see documenation}
  C_HWCheck   : C_Byte;      {Xmit hardware handshake bit check register}
  C_HWMatch   : C_Byte;      {Xmit hardware handshake bit match register}
  C_HWModify  : C_Byte;      {Receive hardware handshake bit modify register}
  C_HWAssert  : C_Byte;      {Receive hardware handshake assert state register}
  C_RcvError  : C_Byte;      {Count of receive errors (parity,framing,etc.)}
  C_RcvBreak  : C_Byte;      {Count of BREAK signals received}
  C_XON       : C_Char;      {Software handshake XON character, usually ^Q}
  C_XOFF      : C_Char;      {Software handshake XOFF character, usually ^S}
  C_PortExist : C_Boolean;   {Set on initialization; TRUE if port found}
  C_FIFOExist : C_Boolean;   {Set on initialization; TRUE if port has FIFOs}
  C_PortOpen  : C_Boolean;   {Port open flag; TRUE if port is opened for I/O}
  C_XmitWait  : C_Boolean;   {Flag: Wait for Tx buffer space in ComWriteCh}
  C_RcvWait   : C_Boolean;   {Flag: Wait for character Rx in ComReadCH}

  C_EOLIn : String[5];       {End-of-line sequence for input}
  C_EOLOut : String[5];      {End-of-line sequence for output}
  C_AssignInSize : Word;     {Default input buffer size for AssignCom}
  C_AssignOutSize : Word;    {Default output buffer size for AssignCom}
  C_AssignTimeout : Word;    {Timeout for CloseCom for AssignCom'ed ports}
  C_MaxCom    : Byte;        {Highest port # defined}
  C_Error     : Byte;        {Global error byte; 0=No error}
  C_Timer     : Byte;        {Default Timer # for ASYNC usage}
  C_Temp      : Byte;        {ISR debug variable}
  C_IsAT      : Boolean;     {TRUE if machine is an AT or compatable}
  C_Init      : Boolean;     {Initialization flag: TRUE if initialized}

{-----------------------------------------------------------------------------}

Procedure ComInit;
Function  C_ErrorCheck(ComPort,Level:Byte) : Boolean;
Function  ComExist(P:Word; LoopMode:Boolean) : Boolean;
Function  ComFIFOExist(P:Word) : Boolean;
Procedure OpenCom(ComPort:Byte; InBufSize,OutBufSize:Word; Default:Boolean);
Procedure CloseCom(ComPort:Byte; Timeout:Word);
Procedure CloseAllComs(Timeout:Word);
Procedure ComParams(ComPort:Byte; Baud:Longint; Wordsize:Byte; Parity:Char;
                    Stopbits:Byte);
Procedure GetComParams(ComPort:Byte; Var Baud:Longint; Var Wordsize:Byte;
          Var Parity:Char; Var Stopbits:Byte);
Procedure AssignCom(Var F:Text; CPort:Byte);

Procedure AddCom(Address:Word; Int:Byte; ForceAdd:Boolean);
Procedure AddISAPorts(ForceAdd:Boolean);
Procedure AddPS2Ports(ForceAdd:Boolean);
Procedure ChangeCom(ComPort:Byte; Address:Word; Int:Byte; ForceAdd:Boolean);
Procedure InsertCom(ComPort:Byte; Address:Word; Int:Byte; ForceAdd:Boolean);
Procedure DelCom(ComPort:Byte);

Procedure ComFIFOMode(ComPort:Byte; Enable:Boolean);
Procedure ComWaitMode(ComPort:Byte; Mode:Char; Enable:Boolean);
Procedure HandshakeMode(ComPort:Byte; Mode,Dir:Char; Enable:Boolean);
Procedure HandshakeOnOff(ComPort:Byte; On,Off:Word);
Procedure SoftHSChar(ComPort:Byte; XOn,XOff:Char);
Procedure HardHSOutput(ComPort:Byte; Modify,Assert:Byte);
Procedure HardHSInput(ComPort:Byte; Check,Match:Byte);

Procedure ComWriteCh(ComPort:Byte; Ch:Char);
Procedure ComBlockWrite(ComPort:Byte; Buffer:Pointer; Var Count:Word);
Procedure ComWrite(ComPort:Byte; St:String);
Procedure ComWriteln(ComPort:Byte; St:String);
Procedure ComTimedWrite(ComPort:Byte; Ch:Char; Timeout:Word);
Procedure ComSlowWrite(ComPort:Byte; St:String; SendDelay:Word);
Procedure ComEchoSend(ComPort:Byte; St:String; Timeout:Word);
Procedure ComFlushBuffer(ComPort:Byte; Timeout:Word);
Procedure SendBreak(ComPort:Byte; BreakTime:Word);
Function  ComReadCh(ComPort:Byte) : Char;
Procedure ComBlockRead(ComPort:Byte; Buffer:Pointer; Var Count:Word);
Procedure ComRead(ComPort:Byte; Var St:String; MaxLen:Byte; EndChar:Char);
Procedure ComReadln(ComPort:Byte; Var St:String; MaxLen:Byte; Echo:Boolean);
Function  ComTimedRead(ComPort:Byte; Timeout:Word) : Char;
Procedure ComWaitFor(ComPort:Byte; St:String; Timeout:Word; TimeReset:Boolean);
Procedure ComWaitForClear(ComPort:Byte; Timeout:Word);

Procedure ClearCom(ComPort:Byte; Buffer:Char);
Function  ComBufLeft(ComPort:Byte; Buffer:Char) : Word;
Function  ComBufUsed(ComPort:Byte; Buffer:Char) : Word;
Function  ComBufEmpty(ComPort:Byte; Buffer:Char) : Boolean;
Function  ComBufFull(ComPort:Byte; Buffer:Char) : Boolean;

Procedure SetDTR(ComPort:Byte; Action:Char);
Procedure SetRTS(ComPort:Byte; Action:Char);
Procedure SetOUT1(ComPort:Byte; Action:Char);
Procedure SetOUT2(ComPort:Byte; Action:Char);
Procedure SetAll(ComPort,Modify,Assert:Byte);
Function  CTSStatus(ComPort:Byte) : Boolean;
Function  DSRStatus(ComPort:Byte) : Boolean;
Function  RIStatus(ComPort:Byte) : Boolean;
Function  DCDStatus(ComPort:Byte) : Boolean;
Function  AllStatus(ComPort:Byte) : Byte;

{-----------------------------------------------------------------------------}

IMPLEMENTATION

{$L ASYNC.OBJ}

Type
  ComIORec = Record                      {Stores parameters in effect when}
    ComPort    : Byte;                   {a port is opened via AssignCom}
    Baud       : Word;
    Wordsize   : Byte;
    Parity     : Char;
    Stopbits   : Byte;
    InBufSize  : Word;
    OutBufSize : Word;
    Unused : Array[1..6] Of Byte;
  End;

Var
  C_OldIntVec : Array[0..15] Of Pointer; {Storage for old HW interrupt address}
  C_OpenLevel : C_Byte;                  {Used by device driver for closing}
  OldExitProc : Pointer;                 {Pointer to previous exit procedure}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure IntOn                                                           *}
{* Procedure IntOff                                                          *}
{* Procedure IntPush                                                         *}
{* Procedure IntPop                                                          *}
{* -- Enable or disable system interrupts                                    *}
{*                                                                           *}
{* IntOn and IntOff enable and disable system interrupts, respectively.      *}
{* IntPush saves the processor flag register on the stack and disables       *}
{* interrupts.  IntPop restores the status word.  Using IntPush and IntPop,  *}
{* a procedure or function can unconditionally disable interrupts when       *}
{* needed, and then restore the state of the interrupt flag (thus preserving *}
{* it's prior state).  Since these are macro-type procedures and not dec-    *}
{* lared in the INTERFACE portion of the UNIT, they are not directly         *}
{* callable from user programs using ASYNC.                                  *}
{*                                                                           *}
{*****************************************************************************}

Procedure IntOff;  Inline($FA);        {Unconditionally mask interrupts}
Procedure IntOn;   Inline($FB);        {Unconditionally allow interrupts}
Procedure IntPush; Inline($9C/$FA);    {Save flags, mask interrupts}
Procedure IntPop;  Inline($9D);        {Restore flags, including int mask}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure C_ErrorCheck(ComPort,Level:Byte) : Boolean                      *}
{* -- Check for common errors                                                *}
{*                                                                           *}
{* C_ErrorCheck is a local procedure used to check for common port errors.   *}
{* The extent of the error checking is controlled by the (Level) parameter,  *}
{* which may range from 0 to 4. Conditions checked for based on (Level) are: *}
{*                                                                           *}
{* Level      Port # valid   Hardware present   Port Opened   Port Closed    *}
{*   0             No               No              No             No        *}
{*   1             Yes              No              No             No        *}
{*   2             Yes              Yes             No             No        *}
{*   3             Yes              Yes             Yes            No        *}
{*   4             Yes              Yes             No             Yes       *}
{*                                                                           *}
{* If C_ErrorCheck detects an error, it will place the appropriate error     *}
{* code in the C_Error global variable.                                      *}
{*                                                                           *}
{*****************************************************************************}

Function C_ErrorCheck(ComPort,Level:Byte) : Boolean;

Begin
  C_ErrorCheck := True;
  If (Level >= 1) And (ComPort < 1) Or (ComPort > C_MaxCom) Then
    Begin
      C_Error := C_InvalidPort;
      Exit;
    End;
  If (Level >= 2) And (Not C_PortExist[ComPort]) Then
    Begin
      C_Error := C_PortNotFound;
      Exit;
    End;
  If (Level = 3) And (Not C_PortOpen[ComPort]) Then
    Begin
      C_Error := C_PortNotOpen;
      Exit;
    End;
  If (Level = 4) And C_PortOpen[ComPort] Then
    Begin
      C_Error := C_PortNotClosed;
      Exit;
    End;
  C_Error := C_NoError;
  C_ErrorCheck := False;
End;

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComISR (external -- see ASYNC.ASM)                                *}
{* -- ASYNC UART interrupt service routine                                   *}
{*                                                                           *}
{* ComISR, written in assembly language, manages all interrupts generated    *}
{* by INS 8250-compatable Universal Asynchronous Receiver/Transmitters.      *}
{* Characters received by active UARTs are placed in a buffer, and char-     *}
{* acters to be transmitted are removed from their buffers and sent to the   *}
{* UARTs for transmission.  Line errors are logged and modem status changes  *}
{* that affect handshaking are acted upon.  ComISR is never called directly, *}
{* but it is referenced by OpenCom to program the appropriate hardware int-  *}
{* errupt vector.  ComISR is not declared in the INTERFACE section of the    *}
{* UNIT, so it may not be called or referenced by programs using ASYNC.      *}
{*                                                                           *}
{*****************************************************************************}

{$F+}
Procedure ComISR; External;
{$F-}

{*****************************************************************************}
{*                                                         Modified 12/28/90 *}
{*                                                                           *}
{* Procedure ComInit                                                         *}
{* -- Initialize ASYNC variables                                             *}
{*                                                                           *}
{* ComInit closes all ports and resets all of ASYNC's internal variables     *}
{* and controls to a known default state.  The four "standard" port address- *}
{* es are defined (undoing any changes made through the use of AddCom,       *}
{* ChangeCom, InsertCom or DelCom), handshaking is disabled and all buffers  *}
{* are cleared.  A test of machine type is made, and the result is assigned  *}
{* to the C_IsAT variable (C_IsAT is TRUE if the machine on which ASYNC is   *}
{* executing is an IBM AT or compatable, including '386 and '486 machines).  *}
{* C_Init is also set to TRUE.  There is typically no need to call this      *}
{* procedure, as it is invoked as part of the UNIT initialization code.      *}
{*                                                                           *}
{*****************************************************************************}

Procedure ComInit;

Var
  X : Byte;

Begin
  If C_Init Then CloseAllComs(0);

  {Assign default definitions for global variables}

  C_IsAT := True;                           {Determine machine type}
  C_MaxCom := 0;                            {No logical ports defined yet}
  C_AssignInSize := $100;                   {Buffer sizes used by AssignCom...}
  C_AssignOutSize := $100;                  {...for unopened ports}
  C_AssignTimeout := 18;                    {Wait up to 1 second before close}
  C_EOLIn := ^M^J;                          {End-of-line sequence; ComReadln}
  C_EOLOut := ^M^J;                         {End-of-line sequence; ComWriteln}
  C_Timer := T_MaxTimer-1;                  {Timer # for delay operations}

  For X := 1 To C_MaxPort Do
    Begin
      C_PortExist[X] := False;         {For initialization only}
      C_FIFOExist[X] := False;

      C_PortOpen[X] := False;          {Ports closed for initialization}
      C_OpenLevel[X] := 0;             {Open level used by device driver}

      C_InBufPtr[X] := Nil;            {No buffers declared}
      C_OutBufPtr[X] := Nil;
      C_InSize[X] := 0;                {Buffer sizes set by OpenCom}
      C_OutSize[X] := 0;
      C_InHead[X] := 0;                {Start at the beginning of a buffer}
      C_InTail[X] := 0;
      C_OutHead[X] := 0;
      C_OutTail[X] := 0;

      C_Status[X] := $05;              {Receive & Transmit buffers empty}
      C_Ctrl[X] := $20;                {Soft handshake pseudo-status "assert"}
      C_RcvError[X] := 0;              {No receive errors}
      C_RcvBreak[X] := 0;              {No BREAK signals received}

      C_HSOn[X] := 0;                  {Turn on/off points set by OpenCom}
      C_HSOff[X] := 0;
      C_HWCheck[X] := $08;             {Check CTS line for hardware handshake}
      C_HWMatch[X] := $08;             {CTS line must be + for assert}
      C_HWModify[X] := $02;            {Modify RTS line on handshake change}
      C_HWAssert[X] := $02;            {Make RTS + when asserting line}
      C_XON[X] := ^Q;                  {Software handshake: ^S stop, ^Q start}
      C_XOFF[X] := ^S;
      C_XmitWait[X] := True;           {Wait for buffer space before xmit}
      C_RcvWait[X] := False;           {Don't wait for character reception}
    End;
  C_Temp := 0;

  For X := 0 To 15 Do                  {Reset interrupt address pointers}
    C_OldIntVec[X] := Nil;

  {DEFINE LOGICAL PORTS:}
  {Change the global variable C_ExistMode (declared in the unit header) to}
  {FALSE if you are using ASYNC with a modem and are experiencing loss of}
  {carrier when your program starts}

  AddISAPorts(True);                   {Add all ISA ports to logical port list}

  {Initialization complete, exit}

  C_Init := True;
  C_Error := C_NoError;
End;

{*****************************************************************************}

{The files below contain the bulk of the ASYNC source code}

{$I INIT.INC}
{$I ASSIGN.INC}
{$I PLEDIT.INC}
{$I HANDSHK.INC}
{$I IO.INC}
{$I BUFFER.INC}
{$I IOLINE.INC}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* Procedure ComExit                                                         *}
{* -- Termination code for the ASYNC unit                                    *}
{*                                                                           *}
{* When a Turbo Pascal program terminates, a series of "exit procedures" are *}
{* invoked to ensure that the machine state is properly restored before the  *}
{* DOS command processor (COMMAND.COM) regains control.  A UNIT may (option- *}
{* ally) specify such a procedure, as documented on pp. 229-230 of the Turbo *}
{* Pascal 5.0 (and 5.5) manual.  ComExit is called immediately before a      *}
{* program using ASYNC terminates.  All active ports are closed, thereby     *}
{* disabling UART interrupts and resetting hardware interrupt pointers to    *}
{* their previous values.                                                    *}
{*                                                                           *}
{*****************************************************************************}

{$F+}
Procedure ComExit;

Begin
  ExitProc := OldExitProc;
  CloseAllComs(0);
End;
{$F-}

{*****************************************************************************}
{*                                                         Modified 08/14/90 *}
{*                                                                           *}
{* UNIT initialization code for ASYNC                                        *}
{*                                                                           *}
{* The following code will be executed by a Turbo Pascal program that USES   *}
{* ASYNC.  The ASYNC exit procedure (described above) is installed, the      *}
{* ASYNC procedure ComInit is invoked (setting the variables used herein to  *}
{* a known default state) and the TIMER unit is initialized.                 *}
{*                                                                           *}
{*****************************************************************************}

Begin
  OldExitProc := ExitProc;
  ExitProc := @ComExit;

  C_Init := False;
  {ComInit;}
  InitTimer;
End.
