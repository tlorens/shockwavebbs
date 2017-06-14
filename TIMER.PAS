{$A+,B-,D-,E+,F-,G-,I-,L-,N-,O-,R-,S+,V-,X+}
{* Available timer modes:                                                    *}
{*---------------------------------------------------------------------------*}
{* Mode 0                                                                    *}
{*   Count down, recycle mode                                                *}
{*   Toggle status bit when timer = 0                                        *}
{*---------------------------------------------------------------------------*}
{* Mode 1                                                                    *}
{*   Count up, recycle mode                                                  *}
{*   Toggle status bit when timer overflows to 0                             *}
{*---------------------------------------------------------------------------*}
{* Mode 2                                                                    *}
{*   Count down, recycle mode                                                *}
{*   Toggle status bit when timer = 0 OR timer = MatchVal                    *}
{*---------------------------------------------------------------------------*}
{* Mode 3                                                                    *}
{*   Count up, recycle mode                                                  *}
{*   Toggle status bit when timer overflows to 0 OR timer = MatchVal         *}
{*---------------------------------------------------------------------------*}
{* Mode 4                                                                    *}
{*   Count down, one-shot mode                                               *}
{*   Stop when timer = 0                                                     *}
{*---------------------------------------------------------------------------*}
{* Mode 5                                                                    *}
{*   Count up, one shot mode                                                 *}
{*   Stop when timer overflows to 0                                          *}
{*---------------------------------------------------------------------------*}
{* Mode 6                                                                    *}
{*   Count down, one-shot mode                                               *}
{*   Stop when timer = 0                                                     *}
{*   Toggle status bit when timer = MatchVal                                 *}
{*---------------------------------------------------------------------------*}
{* Mode 7                                                                    *}
{*   Count up, one-shot mode                                                 *}
{*   Stop when timer overflows to 0                                          *}
{*   Toggle status bit when timer = MatchVal                                 *}
{*---------------------------------------------------------------------------*}
{* Mode 8                                                                    *}
{*   Count down, recycle mode                                                *}
{*   Reset timer to MatchVal when timer = 0                                  *}
{*---------------------------------------------------------------------------*}
{* Mode 9                                                                    *}
{*   Count up, recycle mode                                                  *}
{*   Reset timer to 0 when timer = MatchVal                                  *}
{*---------------------------------------------------------------------------*}
{* Mode 10                                                                   *}
{*   Count direction determined by status flag (1=Up, 0=Down)                *}
{*   Counter operates continuously (recycle mode)                            *}
{*   Toggle status when timer = 0 OR timer = MatchVal                        *}
{*---------------------------------------------------------------------------*}
{* Modes 11-255                                                              *}
{*   Stop timer (may be resumed by placing a valid mode # in T_Mode[])       *}
{*****************************************************************************}

Unit Timer;

INTERFACE

Const
  {T_ASize determines the size of the various arrays used.  It may be set as}
  {high as 15, allowing for 16 independent timers.}

  T_ASize = 7;                              {Upper bound for arrays}

  Cmd_8253 = $43;                           {8253 timer command register}
  T0_8253 = $40;                            {Timer 0 data register}
  T1_8253 = $41;                            {Timer 1 data register}
  T2_8253 = $42;                            {Timer 2 data register}

Type
  T_ByteArray = Array[0..T_ASize] Of Byte;
  T_WordArray = Array[0..T_ASize] Of Word;

Const
  {T_MaxTimer is similar to T_ASize in that it defines the number of timers}
  {that are used by the UNIT.  It may be dynamically changed during runtime}
  {but should NEVER be set higher than T_ASize+1.  You may wish to use a}
  {smaller number if you only need a few timers, as this will reduce the}
  {execution time of the timer ISR.}

  T_MaxTimer : Byte = T_ASize + 1;          {# of timers available}

Var
  T_Open      : Boolean;                    {Timer system init'd if TRUE}
  T_Halt      : Boolean;                    {Halts ALL timers if TRUE}
  T_Status    : Word;                       {Status (match) register}
  T_LongCount : Longint;                    {Longword count-up timer}
  T_Mode      : T_ByteArray;                {Timer mode}
  T_Count     : T_WordArray;                {Counter registers}
  T_Match     : T_WordArray;                {Match registers}

Procedure SetTimeBase(TimeBase:Word);
Procedure GetATTime(Var Hours,Minutes,Seconds:Byte);
Procedure GetATDate(Var Year:Word; Var Month,Day:Byte);
Procedure InitTimer;
Procedure ShutdownTimer;
Procedure StartTimer(TimerNbr,Mode:Byte; StartVal,MatchVal:Word; Flag:Boolean);
Function  TimerFlag(TimerNbr:Byte) : Boolean;
Procedure SetTimerFlag(TimerNbr:Byte; Flag:Boolean);

{*****************************************************************************}

IMPLEMENTATION

Uses DOS;

{$L TIMER.OBJ}

Var
  Reg : Registers;                     {Register set used by INTR procedure}
  X : Byte;                            {Temporary counter}
  OldExitProc : Pointer;               {Pointer to previous EXIT procedure}
  T_OldINT1C : Pointer;                {Pointer to previous INT 1Ch vector}

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure IntOn      (CLI)                                                *}
{* Procedure IntOff     (STI)                                                *}
{* Procedure IntPush    (PUSHF/CLI)                                          *}
{* Procedure IntPop     (POPF)                                               *}
{* --- Enable or disable system interrupts                                   *}
{*                                                                           *}
{* IntOn and IntOff enable and disable system interrupts, respectively.      *}
{* IntPush saves the processor flag register on the stack and disables       *}
{* interrupts.  IntPop restores the status word.  In this fashion, a user    *}
{* may temporarily unconditionally disable interrupts, and then restore the  *}
{* interrupt flag without fear of unmasking interrupts that may have been    *}
{* masked before the call.                                                   *}
{*                                                                           *}
{*****************************************************************************}

Procedure IntOff;  Inline($FA);        {Unconditionally mask interrupts}
Procedure IntOn;   Inline($FB);        {Unconditionally allow interrupts}
Procedure IntPush; Inline($9C/$FA);    {Save flags, mask interrupts}
Procedure IntPop;  Inline($9D);        {Restore flags, including int mask}

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure TimerISR                                                        *}
{* --- Timer interrupt service routine                                       *}
{*                                                                           *}
{* Provides machine drivers to manage the timers when the BIOS TOD timer     *}
{* interrupt occurs.  It should NOT be called from a user program.  It is    *}
{* present here so the initialization procedure may set up the interrupt     *}
{* vector to it during the initialization process.                           *}
{*                                                                           *}
{* Note: This procedure is not present in the UNIT interface section, there- *}
{* fore it may not be called by a user program.                              *}
{*                                                                           *}
{*****************************************************************************}

{$F+}
Procedure TimerISR; External;
{$F-}

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure SetTimeBase(Timebase:Word; ResetLong:Boolean)                   *}
{* --- Control the time base used by the timing system                       *}
{*                                                                           *}
{* Normally, timer 0 of the 8253 programmable timer chip present in all IBM- *}
{* compatable systems is used by the BIOS to provide a periodic interrupt,   *}
{* which is used to maintain the BIOS time and date.  It's default time base *}
{* is $10000 (hex) / 65536 (decimal), providing a 54.92549 millisecond       *}
{* interval (approximate rate of 18.2065 Hz) when the standard crystal time- *}
{* base of 1.19318 MHz is used.  Using SetTimeBase, you may reprogram timer  *}
{* 0 on the 8253 timer chip to generate a different (shorter) interval.      *}
{* Since TimerISR is called every time the 8253 timer 0 times out, changing  *}
{* this interval will cause the timer counters to be altered at a different  *}
{* (faster) rate.                                                            *}
{*                                                                           *}
{* TimeBase contains the value to be programmed into the 8253 timer IC.  The *}
{* resulting frequency of interrupts is calculated by using the formula:     *}
{*                                                                           *}
{* Frequency (Hz) = 1,193,180 / TimeBase                                     *}
{* Period (Sec)   = TimeBase / 1,193,180                                     *}
{* [1,193,180 = 8253 clock rate]                                             *}
{*                                                                           *}
{* Use a TimeBase of 0 (which is equivalent to $10000/65536) to reprogram    *}
{* the timer to it's normal 18.2 Hz rate.                                    *}
{*                                                                           *}
{* Considerable care must be used if you choose to change the time base.     *}
{* If TimeBase is too small, interrupts will be generated at a faster rate   *}
{* than the processor can acknowledge them, and/or the processor will spend  *}
{* inordinate amounts of it's time processing interrups with the likely      *}
{* end result being a system crash.  Floppy disk motor timing also relies    *}
{* on this rate to determine how long to keep the motor on after a disk I/O  *}
{* operation.  This typically becomes a problem only if a very short time    *}
{* base (<20 mS) is used.  Finally, since the BIOS time/date is computed     *}
{* assuming a 55 mSec time base, the system time & date will become          *}
{* inaccurate.  You may wish to use the value in T_LongCount to adjust the   *}
{* system time & date.                                                       *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetTimeBase(TimeBase:Word);

Begin
  IntPush;
  Port[Cmd_8253] := $36;               {Timer 0, write latch, mode 3, binary}
  Port[T0_8253] := Lo(TimeBase);       {Set low byte of timer 0 latch}
  Port[T0_8253] := Hi(TimeBase);       {Set high byte of timer 0 latch}
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure BCD2Dec(BCD:Byte) : Byte                                        *}
{* --- Convert single-byte BCD number to decimal                             *}
{*                                                                           *}
{* Note: Not declared in INTERFACE section of UNIT; therefore not available  *}
{* to programs.  Used by GetATTime and GetATDate.                            *}
{*                                                                           *}
{*****************************************************************************}

Function BCD2Dec(BCD:Byte) : Byte;

Begin
  BCD2Dec := (BCD SHR 4) * 10 + (BCD And $0F);
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure GetATTime(Var Hours,Minutes,Seconds:Byte)                       *}
{* --- Reads the time from the AT hardware real-time clock                   *}
{*     (AT-type BIOS compatable machines only)                               *}
{*                                                                           *}
{*****************************************************************************}

Procedure GetATTime(Var Hours,Minutes,Seconds:Byte);

Begin
  Reg.AH := $02;                       {Read AT real-time clock time}
  Intr($1A,Reg);

  Hours := BCD2Dec(Reg.CH);
  Minutes := BCD2Dec(Reg.CL);
  Seconds := BCD2Dec(Reg.DH);
End;

{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Procedure GetATDate(Var Year:Word; Var Month,Day:Byte)                    *}
{* --- Reads the date from the hardware real-time clock                      *}
{*     (AT-class and above machines only)                                    *}
{*                                                                           *}
{*****************************************************************************}

Procedure GetATDate(Var Year:Word; Var Month,Day:Byte);

Begin
  Reg.AH := $04;                       {Read AT real-time clock date}
  Intr($1A,Reg);

  Year := BCD2Dec(Reg.CH) * 100 + BCD2Dec(Reg.CL);
  Month := BCD2Dec(Reg.DH);
  Day := BCD2Dec(Reg.DL);
End;

{*****************************************************************************}
{*                                                         Modified 03/18/94 *}
{*                                                                           *}
{* Procedure InitTimer;                                                      *}
{* --- Initialize the timing system                                          *}
{*                                                                           *}
{* Initializes the timing system and connects the TimerISR procedure into    *}
{* the INT 1Ch (user timer interrupt) stream.  It may also be used to reset  *}
{* and re-initialize the timer system without fear of catastrophe, since     *}
{* this routine will not revector the timer int if it has been done already. *}
{*                                                                           *}
{*****************************************************************************}

Procedure InitTimer;

Var
  X : Byte;

Begin
  T_Halt := True;                      {Stop timers}
  IntPush;                             {Disable interrupts}

  For X := 0 To T_MaxTimer-1 Do
    Begin
      T_Count[X] := 0;                 {Count = 0}
      T_Match[X] := 0;                 {Match word = 0}
      T_Mode[X] := $FF;                {Timer mode = Stopped}
    End;
  T_Status := 0;                       {Clear status bits}

  If Not T_Open Then
    Begin
      GetIntVec($1C,T_OldINT1C);       {Get the current INT 1Ch vector}
      SetIntVec($1C,@TimerISR);        {Vector INT 1Ch to TimerISR}
      T_Open := True;                  {Set flag indicating INT revectored}
    End;

  T_Halt := False;                     {Allow timers to run}
  IntPop;                              {Restore previous int-enable state}
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure ShutdownTimer;                                                  *}
{* --- "Un-initialize" (close/shut down) timer system                        *}
{*                                                                           *}
{* Closes down the timing system by restoring the INT 1Ch vector back to     *}
{* it's original location.  This routine is called by TimerExit to ensure    *}
{* that the timer system is safely shut down when the user program           *}
{* terminates.                                                               *}
{*                                                                           *}
{*****************************************************************************}

Procedure ShutdownTimer;

Begin
	T_Halt := True;                      {Stop timers}
  IntPush;                             {Disable interrupts}

  SetTimeBase(0);                      {Make sure 8253 is using BIOS rate}

  If T_Open Then
    Begin
      SetIntVec($1C,T_OldINT1C);       {INT 1Ch vector to original routine}
      T_Open := False;                 {Say that this was done}
    End;

  IntPop;                              {Restore previous int-enable state}
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure StartTimer(TimerNbr,Mode:Byte; StartVal,MatchVal:Word;          *}
{* Flag:Boolean);                                                            *}
{* --- Start (initialize) a timer                                            *}
{*                                                                           *}
{* Starts system timer specified by TimerNbr.  Mode determines how the timer *}
{* will behave during it's operation (see list of valid Modes near the start *}
{* of the code).  StartVal is the value assigned to the timer before it      *}
{* is enabled.  For count-up modes, this is typically zero.  MatchVal is     *}
{* used by many timing modes for various purposes that are mode dependent,   *}
{* including status bit toggle on match, and/or a reset value for the timer  *}
{* when it underflows.  Flag allows the user to set the initial status flag  *}
{* state when the timer is started.  Typically, this is set to FALSE.        *}
{*                                                                           *}
{*****************************************************************************}

Procedure StartTimer(TimerNbr,Mode:Byte; StartVal,MatchVal:Word; Flag:Boolean);

Var
  X : Word;

Begin
  {Exit now if timer system not init'd}
  If Not T_Open Or (TimerNbr >= T_MaxTimer) Then Exit;

  IntPush;                             {Temporarily mask interrupts}
  T_Count[TimerNbr] := StartVal;       {Set initial value of count}
  T_Match[TimerNbr] := MatchVal;       {Set match word}
  T_Mode[TimerNbr] := Mode;            {Set timer mode}
  X := $01 SHL TimerNbr;               {Compute bit mask position}
  If Flag Then
    T_Status := T_Status Or X          {Set timer status flag if Flag=TRUE}
  Else
    T_Status := T_Status And (Not X);  {Reset timer status flag if Flag=FALSE}
  IntPop;                              {Restore interrupt enable status}
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Function TimerFlag(TimerNbr:Byte) : Boolean                               *}
{* --- Return status of designated timer's status/match flag                 *}
{*                                                                           *}
{* If TimerFlag(TimerNbr) returns TRUE, the timer status flag for TimerNbr   *}
{* has been set.  This typically occurs when the timer counter reaches 0     *}
{* and/or the timer count has reached the user-defined match point.          *}
{*                                                                           *}
{*****************************************************************************}

Function TimerFlag(TimerNbr:Byte) : Boolean;

Begin
  TimerFlag := False;
  If Not T_Open Or (TimerNbr >= T_MaxTimer) Then Exit;
  TimerFlag := (T_Status And ($01 SHL TimerNbr)) > 0;
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure SetTimerFlag(TimerNbr:Byte; Flag:Boolean)                       *}
{* --- Control the state of a timer status flag                              *}
{*                                                                           *}
{* SetTimerFlag allows a program to control the setting of a timer status    *}
{* flag.  Although the status flags are usually read-only, it is occasion-   *}
{* ally desirable to be able to control the flag directly (often when using  *}
{* timer mode 10).  SetTimerFlag provides control over this flag.            *}
{*                                                                           *}
{*****************************************************************************}

Procedure SetTimerFlag(TimerNbr:Byte; Flag:Boolean);

Var
  X : Word;

Begin
  If Not T_Open Or (TimerNbr >= T_MaxTimer) Then Exit;
  X := $0001 SHL TimerNbr;

  IntPush;
  If Flag Then
    T_Status := T_Status Or X
  Else
    T_Status := T_Status And (Not X);
  IntPop;
End;

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Procedure TimerExit                                                       *}
{* --- UNIT exit procedure for timer system                                  *}
{*                                                                           *}
{* TimerExit is inserted into the Turbo Pascal exit procedure stream that    *}
{* is invoked just before a program terminates.  TimerExit simply calls      *}
{* ShutdownTimer to ensure that the system INT 1Ch vector is properly        *}
{* restored.                                                                 *}
{*                                                                           *}
{* Note: This procedure is not present in the UNIT interface section, there- *}
{* fore it may not be called by a user program.                              *}
{*                                                                           *}
{*****************************************************************************}

{$F+}
Procedure TimerExit;

Begin
  ExitProc := OldExitProc;             {Restore previous exit procedure}
  If T_Open Then ShutdownTimer;        {Shut down timer system}
End;
{$F-}

{*****************************************************************************}
{*                                                         Modified 08/12/90 *}
{*                                                                           *}
{* Main program -- initialize timer variables (but not the interrupt vector) *}
{*                                                                           *}
{* This code is automatically executed during the start-up phase of a        *}
{* program that USEs this UNIT.                                              *}
{*                                                                           *}
{*****************************************************************************}

Begin
  OldExitProc := ExitProc;             {Save pointer to exit proc chain}
  ExitProc := @TimerExit;              {Place our exit procedure in chain}

  T_Status := 0;                       {All status bits reset}
  T_Open := False;                     {Timer UNIT not initialized}
  T_Halt := False;                     {Allow timers to operate}

  For X := 0 To T_ASize Do
    Begin
      T_Mode[X] := $FF;                {Timer mode $FF = stopped}
      T_Match[X] := 0;                 {Clear match & count registers}
      T_Count[X] := 0;
    End;
End.
