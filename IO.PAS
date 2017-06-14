{
  iB * 06/02/96 - Now hangs-up modem correctly.
  iB * 06/03/96 - Added PRO:Vision and Mono emulation support.
  iB * 04/06/97 - Added HotKey Menus.
}

unit IO;

interface

Const Local = 0;
      Remote = 1;
      Normal = 2;

Var IOMethod:Byte;
    CurAttrib:Integer;

Procedure DebugLn(S:String; X:Byte);
Procedure ModemPrint (St: String);
Procedure ModemPrintln (St: String);
Function RingDetect : Boolean;
Function ModemResult:String;
Function Carrier : Boolean;
Function HungUpOn:Boolean;
Function CharPressed : Boolean;
Procedure Print (st: string);
Procedure PrintLn (st: string);
Function Get (Len: byte): string;
Function GetLn(MaxLen:Byte): string;
Function GetChar (var ch: char): boolean;
{will return true if the char is coming in locally, otherwise will return
 false... for chat and stuff}
Procedure GoXY (x, y: byte);
Procedure PrintXY(X,Y:Byte; S:String);
Procedure Cls;
Procedure Color (forecolor, backcolor: byte);
Procedure AColor(Attrib:Integer);
Procedure ClsEol;
Procedure ModemCommand(ComPort:Byte; Command:String; Var Response:String;
                       Timeout:Word);
Procedure ForceCmdMode(ComPort:Byte; Timeout:Word);
Procedure SendInit(S:String);
procedure HangUp;
procedure DeInitModem;
procedure InitModem(B:Word);
Procedure DoAnswer;
Procedure DontAnswer;

implementation

uses ANSiDrv,Timer,Vars,ANSIOut,Async,OpCrt,Records,Cnfgrec,GlobKey,
     Multi,iCEMouse,Windows;

  {} { signifies a feature not implemented yet }
Const
      NoAnsi = 0;             { No ANSI Processing }
{}    InternalAnsi = 1;
      Ansi_Sys = 2;

      AsyncDriver = 1;
{}    FossilDriver = 2;

var
  output : text;   { the text file we use for Standard Output }
  modemMethod:Byte;

Procedure InitModem(B:Word);
Begin
  If CNF^.ModemPort<>0 Then 
  Begin
    ComInit;
    DoAnswer;
    Writeln('þ Opening Comport: ',Cnf^.ModemPort,' At: ',B);
    ComParams(CNF^.ModemPort,B,8,'N',1);
    OpenCom(CNF^.ModemPort,1024,2084,True);
  End;
End;

Procedure DeInitModem;
Begin
  If CNF^.ModemPort<>0 Then
  Begin
    DontAnswer;
    CloseCom(CNF^.ModemPort,90); { waits 5 seconds (18*5 = 90) }
  End;
End;


{* Procedure ModemCommand(ComPort:Byte; Command:String; Var Response:String; *}
{*           Timeout:Word)                                                   *}
{* -- Transmit a command to a Hayes-compatable modem                         *}
{*                                                                           *}
{* This routine will transmit the string in <Command> to the modem connect-  *}
{* ed to <ComPort>, followed by a carriage return (CR, ASCII 0Dh).  It will  *}
{* then wait up to <Timeout> clock ticks (18.2 per second) for a response    *}
{* from the modem.  The modem's response is returned in the <Response>       *}
{* variable, sans all control characters.  If the modem fails to respond     *}
{* after <Timeout> clock ticks have elapsed, a error is returned in C_Error. *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, response received                                            *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: (Timeout) expired before a response from the modem was received       *}

Procedure ModemCommand(ComPort:Byte; Command:String; Var Response:String;
                       Timeout:Word);

Var
  Index : Byte;                        {Response string character count}
  Ch : Char;                           {Character received from modem}
  Done : Boolean;                      {TRUE if response completely rcv'd}
  TimeUp : Boolean;                    {TRUE if <Timeout> expired}

Begin
  {Check for errors, transmit command string}

  If C_ErrorCheck(ComPort,3) Then Exit;  {If port error, exit}
  ComWrite(ComPort,Command+#13);         {Transmit command to modem w/CR}
  ComWaitFor(ComPort,#13,36,True);       {Wait for echoback from modem}

  {Set up for modem response}

  StartTimer(C_Timer,4,Timeout,0,False); {Specify maximum response wait time}
  Index := 0;                            {Reset response string len counter}
  Done := False;                         {Response string not received yet}

  {Wait for modem response}

  Repeat
    If Not ComBufEmpty(ComPort,'I') Then {If character received:}
      Begin
        Ch := ComReadCh(ComPort);        {Get character received}
        If Ch >= ' ' Then                {If not a control code:}
          Begin
            Inc(Index);                  {Increment string length/index}
            Response[Index] := Ch;       {Place character in response string}
          End
        Else
          Done := (Ch = #13);            {Response received when CR found}
      End;
    TimeUp := TimerFlag(C_Timer);        {Check status of response timer}
  Until (Done) Or (TimeUp) or (HungUpOn);
  If HungUpOn then HangUp;

  {Check for errors, exit}

  Response[0] := Chr(Index);             {Set response string length}
  If TimeUp Then C_Error := C_TimedOut;  {Return error if response not rcv'd}
End;

{* Procedure ForceCmdMode(ComPort:Byte; Timeout:Word)                        *}
{* -- Force modem into the command state                                     *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, modem is in the command mode                                 *}
{* 1: (ComPort) not defined                                                  *}
{* 2: Port hardware not found                                                *}
{* 3: Port not OPENed                                                        *}
{* 12: Time out; modem is not responding to the escape sequence              *}

Procedure ForceCmdMode(ComPort:Byte; Timeout:Word);

Const
  GuardTime = 10;                      {Escape sequence guard time}
  EscapeSeq = '+++';                   {Modem command-mode escape sequence}
  AckSeq = 'OK'#13#10;                 {Modem command-mode acknowledgement}
  RetrySeq = 'AT'#13;                  {Command-mode verification sequence}

Begin
  If C_ErrorCheck(ComPort,3) Then Exit;{If port error, exit}
  ComWriteCh(ComPort,' ');             {Abort any command in progress}
  ComWaitForClear(ComPort,Timeout);    {Wait for transmit buffer to clear}
  If C_Error <> C_NoError Then Exit;   {If buffer not clear, exit w/error}

  {Transmit escape sequence to modem:}
  {Sequence:  1). Delay 600 mS}
  {           2). Transmit "+++" escape sequence}
  {           3). Wait up to <Timeout> ticks for response}

  StartTimer(C_Timer,4,GuardTime,0,False);  {Wait for guard time}
  Repeat Until TimerFlag(C_Timer);
  ComWrite(ComPort,EscapeSeq);              {Send command-mode escape seq.}
  ComWaitFor(ComPort,AckSeq,Timeout,False); {Wait for modem response}

  {If modem does not respond with the acknowledgement sequence within the}
  {timeout specified, it MAY already be in the command mode.  To determine}
  {if this is the case, we will transmit the modem 'AT' command and wait}
  {for it to respond.}

  If C_Error = C_TimedOut Then
    Begin
      ComWrite(ComPort,RetrySeq);      {Transmit attention sequence}
      ComWaitFor(ComPort,AckSeq,Timeout,False); {Wait for modem response}
    End;
End;

Procedure SendInit(S:String);
var cnt,ptr:integer;
    k:char;
begin
  ptr:=0;
  While ptr<length(s) do
  begin
    if keypressed or (carrier) then exit;
    ptr:=ptr+1;
    k:=s[ptr];
    case k of
         '|':ComWrite(CNF^.ModemPort,^M);
         '~':delay(500);
         '^':begin
               ptr:=ptr+1;
               if ptr>length(s) then k:='^' else k:=upcase(s[ptr]);
               if k in ['A'..'Z'] then ComWrite(CNF^.ModemPort,(chr(ord(k)-64)))
                                  else ComWrite(CNF^.ModemPort,k)
              end;
            else ComWrite(CNF^.ModemPort,k)
      end;
      delay(70);
      while (not comBufEmpty (CNF^.ModemPort, 'I')) do Write(ComReadCh(CNF^.ModemPort));
    end;
  Delay(500);
  cnt:=0;
  repeat
    while (not comBufEmpty (CNF^.ModemPort, 'I')) do
    begin
      cnt:=0;
      Write(ComReadCh(CNF^.ModemPort));
    end;
    cnt:=cnt+1
  until (cnt=1000) or keypressed or (carrier);
End;

procedure ModemPrint(St: string);
begin
  {if IOmethod<>Local then} ComWrite(CNF^.ModemPort, st);
end;

procedure modemprintln (st: string);
begin
  {if IOmethod<>Local then} ComWriteLn(CNF^.ModemPort, st);
end;

Function ModemResult:String;
Begin
 TmpStr:='';
 While (Not ComBufEmpty(CNF^.ModemPort,'I')) Do TmpStr:=TmpStr+ComReadCh(CNF^.ModemPort);
 ModemResult:=TmpStr;
End;

function Carrier : boolean;
Begin
  Carrier:=DCDStatus(CNF^.ModemPort);
End;

procedure HangUp;
var
  Return : string;
begin
  If Carrier Then 
  Begin
    DontAnswer;
    Delay(1000);
    DoAnswer;
    Delay(1000);
    ModemCommand(CNF^.ModemPort, '+++', Return, 60 * 18);
    ModemCommand(CNF^.ModemPort, 'ATH0', Return, 60 * 18);
  End Else Halt(0);
End;

Function HungUpOn:Boolean;
Begin
  If ((Carrier) Or (LocalLogin)) Then HungUpOn:=False else HungUpOn:=True;
End;

function RingDetect : boolean;
begin
  RingDetect := FALSE;
  if RIStatus (CNF^.ModemPort) then RingDetect := TRUE;
end;

function charPressed: boolean;
begin
  charPressed := false;
  if (keypressed) or (not comBufEmpty (CNF^.ModemPort, 'I')) then charPressed := true;
end;

Function LowBitChar(Ch:Char):Char;
Var C:Char;
Begin
  If Ch In [#127..#175] Then Ch:=Chr ( Ord(Ch)-128 );
  Case Ch Of
    'Ý','Þ','º','¹','³','´','µ','¶':C:='|';
    'Ä':C:='-';
    'Í':C:='=';
    '±','²','°','Û':C:=':';
    'Ü':C:='.';
    'ß':C:='''';
    'Õ','Ù','Ú','¾','À','¿','½','¼','»','·','¸','Ô','Ê':C:='*';
    'Å','Á','Â':C:='+';
    Else C:=Ch;
  End;

  LowBitChar:=C;
End;

Function LowBitStr(S:String):String;
Var X:Byte;
Begin
  TmpStr:='';
  For X:=1 To Length(S) Do
  Begin
    TmpStr:=TmpStr+LowBitChar(S[X]);
  End;
  LowBitStr:=TmpStr;
End;

Procedure Print(St: String);
Begin

  If Not (Graphics In Urec^.Config) Then St:=LowBitStr(St);

  Case IOMethod Of
    Local:Begin
        Case ANSiMethod Of
          NOANSI       :Write(st);
          Ansi_Sys     :Write(output, st);
          InternalAnsi :WriteStringAnsi(st);
        End;
      End;

    Remote:ComWrite(CNF^.ModemPort, st);

    Normal:Begin
        ComWrite(CNF^.ModemPort, st);
        Case ANSiMethod Of
          NOANSI       :Write(st);
          Ansi_Sys     :Write(output, st);
          InternalAnsi :WriteStringANSi(st);
        End;
      End;
  End;
End;

Procedure Println(St:String);
Begin

  If Not (Graphics In Urec^.Config) Then St:=LowBitStr(St);

  Case IOMethod Of
    Local:Begin
        Case ANSiMethod Of
          NOANSI       :WriteLn(st);
          Ansi_Sys     :WriteLn(output, st);
          InternalAnsi :WriteStringANSi(st);
        End;
        Writeln;
      End;

    Remote:ComWriteLn(CNF^.ModemPort, st);

    Normal:Begin
        ComWriteLn(CNF^.ModemPort, st);
        Case ANSiMethod Of
          NOANSI       :WriteLn(st);
          Ansi_Sys     :WriteLn(output, st);
          InternalAnsi :WriteStringANSI(st);
        End;
        Writeln;
      End;
  End;
End;

function getChar (var ch: char): boolean;
{ 
  Return Value:
  Local KeyPressed  = True 
  Remote KeyPressed = False
}

Var
  exitloop : boolean;
  TmOut : boolean;
  TimeOut : word;
begin
    
    TimeOut :=  5 * 60 * 18;     {# of ticks = 5 mins *
                                              60 secs / min *
                                              18 ticks / sec
                                          }
    exitloop := false;
    
    StartTimer(C_Timer,4,Timeout,0,False);         {Start timeout counter}

    Repeat
      If HungUpOn then HangUP;

      TmOut := TimerFlag(C_Timer);                 {Get timer status}
      if ((IOmethod = local) or (IOmethod = normal)) then
      Begin
        if KeyPressed then
          begin
            ch := readkey;
            exitloop := true;
            getChar := true;
          end;
      End;

      If (Not RemoteInput) Then
      Begin
        if (not ComBufEmpty (CNF^.ModemPort, 'I'))  then ComReadCh(CNF^.ModemPort);
      End
     Else
      if ((IOmethod = remote) or (IOmethod = normal)) and (RemoteInput) then
      begin
        if (not ComBufEmpty (CNF^.ModemPort, 'I'))  then
        begin
          Ch := ComReadCh(CNF^.ModemPort);
          exitloop := true;
          getChar := false;
        end;
      End;

{      If Length(Urec^.Handle)>0 Then TimeLeft:=SysTimeLeft;
      Writeln(Timeleft);}

      If (Urec^.TimeLeft=0) and (Not LocalLogin) Then
      Begin
        Print('Time Limit Expired!');
        Hangup;
        Delay(2000);
        ExitLoop:=True;
      End;

      If TmOut then
      begin
        print('Input Timed out!');
        HangUp;
        Delay(2000);
        ExitLoop:=True;
      end;
      Slice;
    Until (exitloop) or (HungUpOn);
    If HungUpOn then HangUp;
end;

function get (len: byte): string;
var
  st : string;
begin
  St:='';
  read(st);
  get := st;
end;

function GetLn(MaxLen:Byte): string;
Var
  St  : str80;
  Len : Byte;
  Ch  : Char;
  Hot,Done : Boolean;
  DotCnt   : Byte;
  exitloop : boolean;

Begin
  DotCnt:=0;
  Hot:=False;
  {If C_ErrorCheck(CNF^.ModemPort,3) Then Exit;}
  St :='';
  Ch:=#0;
  If MaxLen = 0 Then Exit;
  { Initialize control variables }

  Len := 0;
  Done := False;

  If Dots then StatusBar(8) else StatusBar(CurStat);

  Repeat
    If HungUpOn Then HangUp;

    GetChar(ch);
    if (Ch = #0) then CheckGlobalKeys Else
    Begin
      If (Not Hot) Then If Ch='/' then Hot:=True;
      If ((Urec^.MenuType=1) and (Not Hot)) and (Not Dots) and (UseHotKey)
        Then Done:=True;
    End;

    { Check for end-of-line sequence }

    If Ch = #13 Then
      Begin
        Done := TRUE;
        Println('');
      End;

    { Check for editing commands }
    Case Ch Of
      ^H : If Len > 0 Then                       {Backspace: Delete char}
             Begin
               Print(^H' '^H);
               Dec(Len);
               Dec(DotCnt);
               If DotCnt<1 Then DotCnt:=Length(CNF^.PWString);
             End;

      #32..#255 : Begin                          {Normal char: Place in string}
                    If not (Len >= MaxLen) Then
                    begin
                      Inc(Len);
                      Inc(DotCnt);
                      If DotCnt>Length(CNF^.PWString) Then DotCnt:=1;
                      St[Len] := Ch;
                      If (Dots) Then 
                      Begin
                        ComWriteCh(CNF^.ModemPort,CNF^.PWString[DotCnt]);
                        Write(Ch);
                      End
                      Else Print(Ch);
                    End;
                  end;
    End;
  Until (Done) or (HungUpOn);

  If (Urec^.MenuType=1) and (Ch<>#13) Then Println('');

  If HungUpOn Then HangUp;
  St[0] := Chr(Len);
  GetLn := st;
End;

Procedure AsciiXY(X,Y:Byte);
Var Cnt:Byte;
Begin
  For Cnt:=1 to X Do Print(' ');
  For Cnt:=1 to Y Do Print(^J);
End;

procedure GoXY (x, y: byte);
begin
  If (IOmethod=Local) or (IOmethod=Normal) then GotoXY(x,y);
  If (IOmethod=Remote) or (IOmethod=Normal) then 
  Case Emulation Of
    0:AsciiXY(X,Y);
    1,2,3,4:ComWrite (CNF^.ModemPort, ANSIGotoXY(x,y));
    9:Print('m'+Chr(X)+Chr(Y));
  End;
end;

Procedure PrintXY(X,Y:Byte; S:String);
Begin
  GoXY(X,Y); Print(S);
End;

procedure Color(forecolor, backcolor: byte);
begin
  If (Emulation=0) or (CurAttrib=(ForeColor or BackColor)) Then Exit;

  CurAttrib:=(ForeColor or BackColor);

  if (IOmethod = Local) or (IOmethod = normal) then
  begin
    if ansiMethod = ANSI_SYS then write(output,ANSIColor(forecolor, backcolor))
    else if ansiMethod = InternalANSI then
    begin
      TextColor (forecolor);
      TextBackground (backcolor);
    end
    else if ansiMethod = noANSI then;
  end;

  if (IOmethod = Remote) or (IOmethod = normal) then
  begin
    if ANSIMethod <> 0 then ComWrite(CNF^.ModemPort,ANSIColor(forecolor, backcolor));
  end;
end;

Procedure AColor (Attrib:integer);
var tc:integer;
    m:Str40;
    C1:String;
    High:Boolean;

const  colorid:array [0..7] of Byte=(30,34,32,36,31,35,33,37);

function strr (n:integer):Str40;
var q:Str40;
begin
  str (n,q);
  strr:=q
end;

begin
  if attrib=0 then
  begin
    textcolor (7);
    textbackground (0)
  end;

  If (Emulation=0) or (attrib=0) or (CurAttrib=Attrib) Then Exit;

  If (Emulation=1) or (Emulation=3) Then {ANSi + RiP}
  Begin
    TextAttr:=attrib;
    curattrib:=attrib;
    m:=#27+'[0';
    tc:=attrib and 7;
    if tc<>7 then m:=m+';'+Strr(Colorid[tc]);
    tc:=(attrib shr 4) and 7;
    if tc<>0 then m:=m+';'+Strr(colorid[tc]+10);
    if (attrib and 8)=8 then m:=m+';1';
    if (attrib and 128)=128 then m:=m+';5';
    m:=m+'m';
    Print(m);
  End
 Else
  If Emulation in [2,4] Then { Mono/VT100  <7 = 7;  > 7=15 }
  Begin
    TextAttr:=attrib;
    curattrib:=attrib;
    If ((Attrib and 7) < 7) Then attrib:=7;
    If ((Attrib and 7) > 7) Then attrib:=15;
    m:=#27+'[0';
    tc:=attrib and 7;
    if tc<>7 then m:=m+';'+Strr(Colorid[tc]);
    tc:=(attrib shr 4) and 7;
    if tc<>0 then m:=m+';'+Strr(colorid[tc]+10);
    if (attrib and 8)=8 then m:=m+';1';
    if (attrib and 128)=128 then m:=m+';5';
    m:=m+'m';
    Print(m);
  End
 Else
  If Emulation=9 Then
  Begin
    TextAttr:=Attrib;
    CurAttrib:=Attrib;
    TextColor(Attrib);
    If ((Attrib shr 4) and 7)>0 Then ComWrite(CNF^.ModemPort,'a'+Chr((Attrib shr 4) and 7)); {BG} 
    If (attrib and 8)=8 Then C1:=Chr((Attrib and 7)+8) Else C1:=Chr(Attrib);
    If (Attrib and 7)>0 Then ComWrite(CNF^.ModemPort,'A'+C1); {FG}
  End;
End;

procedure Cls;
begin
  if (IOmethod = Local) or (IOmethod = normal) then ClrScr;
  if (IOmethod = Remote) or (IOmethod = normal) then
  if (ANSIMethod <> 0) Then
  Begin
    Case Emulation Of
      0:ComWrite(CNF^.ModemPort,#12);
      1,2,3:ComWrite (CNF^.ModemPort, ANSIClrScr);
      4:ComWrite(CNF^.ModemPort,#27+'2J');
      9:ComWrite(CNF^.ModemPort,'C');
    End;
  End;
End;

procedure ClsEol;
Var X:Byte;
begin
  if (IOmethod = Local) or (IOmethod = normal) then ClrEol;
  if (IOmethod = Remote) or (IOmethod = normal) then
  if (ANSIMethod <> 0) Then
  Begin
    Case Emulation Of
      0:For X:=WhereX to 78 Do ComWrite(CNF^.ModemPort,' ');
      1,2,3:ComWrite(CNF^.ModemPort,ANSIClrEol);
      4:ComWrite(CNF^.ModemPort,#27+'K');
      9:ComWrite(CNF^.ModemPort,'e');
    End;
  End;
End;

Procedure DebugLn(S:String; X:Byte);
Var Holder:Word;
Begin
  Holder:=TextAttr;
  TextColor(14); Writeln(S); Delay(X*1000);
  TextColor(Holder);
End;

Procedure DoAnswer;
Begin
  SetDTR(CNF^.ModemPort,'1');
End;

Procedure DontAnswer;
Begin
  SetDTR(CNF^.ModemPort,'0');
End;

Begin
  AnsiMethod := InternalANSI;
  ModemMethod := AsyncDriver;
End.