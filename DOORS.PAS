{
    iB * 04/03/97 - Door Support Added.
}
Unit Doors;

Interface

Procedure AddDoor;
Procedure EdtDoor(P2:String);
Procedure LstDoor(P2:String);
Procedure DelDoor(P2:String);
Procedure Door(B:Byte);

Implementation

Uses Dos,Vars,Records,Cnfgrec,GenSubs,IO,Display,Misc;

Var Info:Text;
    DoorInfo:DoorRec;
    DoorF:File Of DoorRec;

Procedure PcBoard_12_X;
Type
  PCBoardRec=Record
   Display    : Array[1..2] of Char; (* Display On/Off ("-1" = On, " 0" = Off) *)
   Printer    : Array[1..2] of Char; (* Printer On/Off ("-1" = On, " 0" = Off) *)
   PagerBell  : Array[1..2] of Char; (* Page Bell On/Off ("-1" = On, " 0" = Off) *)
   CallAlarm  : Array[1..2] of Char; (* Caller Alarm On/Off ("-1" = On, " 0" = Off) *)
   SysOpFlag  : Array[1..2] of Char; (* Sysop Flag ("  ", "N "=sysop next, "X "=exit dos) *)
   BaudRate   : Array[1..4] of Char; (* Caller's Baud rate (or "LOCL"?) *)
   FullName   : Array[1..25] of Char; (* Caller's Full Name (padded to 25 characters) *)
   ExpertFlag : Char;                (* Expert flag *)
   Nulls      : Char;                (* Nulls Flag *)
   FirstName  : Array[1..15] of Char; (* User's First Name (padded to 15 characters) *)
   Graphics   : Array[1..2] of Char;  (* Graphics Mode ('-1'=ANSI,' 0'=8-bit ASCII,'7E'=7E1) *)
   Password   : Array[1..12] of Char; (* User's Password (padded to 12 characters) *)
   UserIndex  : Integer;             (* User's Record Number in the USERS file *) 
   UserTime   : LongInt;             (* Time User Logged On (in seconds since midnight)  *)
   TimeLeft   : LongInt;             (* User's time remaining in seconds  *) 
   Opened     : LongInt;             (* Time user opened door?  *)
   LoggedOn   : Array[1..5] of Char; (* Time User Logged On (in "HH:MM" format) *)
   CurConf    : Integer;
   ConfJoined : Array[1..9] of Integer; (* Conference #1 Joined? (-1=Yes, 0=No)  *)
   ConfTime   : Integer;              (* Conference added time in mins  *)
   DLLimit    : Array[1..8] of Char;  (* Download limit (in bytes?) *)
   TimeCredit : Integer;              (* Time credit for uploading *)
   Language   : Array[1..4] of Char;  (* Language Extension (see note below) *)
   ErrCorrect : Array[1..2] of Char;  (* Error Corrected ("-1" = On, " 0" = Off) *)
   ChatReq    : Char;                 (* Chat request flag  *)
End;
Begin
End;

Procedure PcBoard_14_X;
Begin
End;

Procedure PcBoard_14_5;
Begin
End;

Procedure Chain(S:Str80);
Begin
  Assign(Info,S+'CHAIN.TXT');
  ReWrite(Info);
  Writeln(Info,UNum);
  Writeln(Info,Urec^.Handle);
  Writeln(Info,Urec^.Realname);
  Writeln(Info,'XYZZY');
  Writeln(Info,Uage(Urec^.Age));
  Writeln(Info,Urec^.Gender);
  Writeln(Info,Urec^.Filepts);
  Writeln(Info,Urec^.LastCall);
  Writeln(Info,'80');
  Writeln(Info,Urec^.Scrnlength);
  Writeln(Info,Urec^.Lvl);
  Writeln(Info,'0');            (* 1 = CO-SYSOP, 0 = NOT CO-SYSOP *)
  Writeln(Info,'0');            (* 1 = SYSOP, 0 = NOT SYSOP *)
  Writeln(Info,'1');            (* 1 = ANSI, 0 = NO ANSI *) 
  Writeln(Info,'0');            (* 1 = REMOTE (MODEM) USER, 0 = LOCAL USER *) 
  Writeln(Info,Urec^.TimeLeft);    
  Writeln(Info,CNF^.MenuDir);
  Writeln(Info,CNF^.DataDir);
  Writeln(Info,CNF^.WorkDir);
  Writeln(Info,CNF^.WorkDir);
  Writeln(Info,BaudRate);       (* "KB" IF LOCAL LOGON, OR BAUDRATE IF REMOTE LOGON *)
  Writeln(Info,CNF^.ModemPort);
  Writeln(Info,CNF^.FullSysName);
  Writeln(Info,CNF^.SysOpName);
  Writeln(Info,Now);
  Writeln(Info,Now-Urec^.TimeLimit); (* # OF SECONDS ONLINE THIS CALL *)
  Writeln(Info,Urec^.UpK);
  Writeln(Info,Urec^.Uploads);
  Writeln(Info,Urec^.DownK);
  Writeln(Info,Urec^.Downloads);
  Writeln(Info,'8N1');
  Close(Info);
End;

Procedure DorInfo(S:Str80);
Begin
  Assign(info,S+'DORINFO1.DEF');
  ReWrite(Info);
  Writeln(Info,CNF^.FullSysName);   (* bbsname *)
  Writeln(Info,CNF^.SysOpName); (* sysop first name *)
  Writeln(Info,' ');           (* sysop last name *)
  Writeln(Info,CNF^.ModemPort); (* comport number (0 if local) *)
  Writeln(Info,CNF^.DefBaudRate,' BAUD N,8,1');  (* comport logon string *)
  Writeln(Info,'0');           (* reserved (Networked=1?) *)
  Writeln(Info,Urec^.Handle);   (* caller first name *)
  Writeln(Info,' ');           (* caller last name *)
  Writeln(Info,'MyTown, USA'); (* caller hometown *)
  Writeln(Info,'1');           (* caller graphics (0=TTY, 1=ANSI) *)
  Writeln(Info,Urec^.Lvl);      (* caller access level *)
  Writeln(Info,Urec^.TimeLeft); (* caller time remaining in minutes *)
  Writeln(Info,'0');           (* -1 = Fossil driver present, 0 = No fossil (??) *)
  Close(Info);
End;

Procedure CallInfo(S:Str80);
Begin
  Assign(Info,S+'CALLINFO.BBS');
  ReWrite(Info);
  Writeln(Info,Urec^.Handle);
  Writeln(Info,'5');       (*  0/2400, 1/300, 2/1200, 3/9600 4/19200. 5/Local+Higher*)
  Writeln(Info,' ');
  Writeln(Info,Urec^.Lvl);
  Writeln(Info,Urec^.TimeLeft);
  Writeln(Info,'COLOR');   (* "COLOR" or "MONO" *)
  Writeln(Info,Urec^.Password[1]);
  Writeln(Info,UNum);
  Writeln(Info,Now);       (* Time On-line *)
  Writeln(Info,Copy(TimeStr(Now),1,7)); (* Time user logged on *)
  Writeln(Info,Copy(TimeStr(Now),1,7),DateStr(Now)); (* Time and date that user logged on *)
  Writeln(Info,'ABCDEF');  (* ConfJoiend: 123456*)
  Writeln(Info,'0');       (* # DL's today *)
  Writeln(Info,'0');       (* Daily Download Max. *)
  Writeln(Info,'0');       (* Kb of Downloads Today *)
  Writeln(Info,'0');       (* Daily Kb Download Max. *)
  Writeln(Info,Urec^.Phone[1]);
  Writeln(Info,DateStr(Now),Copy(TimeStr(Now),1,7));
  Writeln(Info,'EXPERT');  (* "EXPERT"  or "NOVICE" *)
  Writeln(Info,'ALL');     (* All, Ymodem, Ymodem/G, Xmodem, Xmodem/CRC, Xmodem-1K, Xmodem-1K/G, Ascii *)
  Writeln(Info,DateStr(now));  (* Last New Date *)
  Writeln(Info,Urec^.NumCalls);
  Writeln(Info,Urec^.Scrnlength); (* 0=No Pause *)
  Writeln(Info,'1');  (* Last message Read *)
  Writeln(Info,Urec^.Uploads);
  Writeln(Info,Urec^.Downloads);  
  Writeln(Info,'8'); (* Data Bits *)
  Writeln(Info,'REMOTE'); (* "LOCAL"  or "REMOTE" *)
  Writeln(Info,'COM'+Strr(CNF^.ModemPort));
  Writeln(Info,Urec^.Age);
  Writeln(Info,CNF^.DefBaudRate);
  Writeln(Info,'TRUE');   (* Already Connected TRUE or FALSE *)
  Writeln(Info,'Normal Connection');
  Writeln(info,'');   (*  Time of next system event?  MM/DD/YY HH:MM *)
  Writeln(Info,'1');  (* node number *)
  Writeln(Info,'0');  (* Door number *)
  Close(info);
End;

Procedure DropFile(B:Byte; Path:Str80);
Begin
  Case B of  
    1:DorInfo(Path);
    2:PCBoard_12_X;
    3:Chain(Path);
    4:PCBoard_14_X;
    5:PCBoard_14_5;
    6:CallInfo(Path);
  End;
End;

Procedure AddDoor;
Var Tmp:DoorRec;
Begin
  With DoorInfo Do
  Begin
    Input          :='New Door'; 
    Name          :=EditPrompt(25,'Door Name:'); Println('');

    Input         :='New Door Description';
    Description   :=EditPrompt(40,'Description: '); Println('');

    Input         :='(s0)';
    Flags         :=EditPrompt(40,'Access Flags: '); Println('');
    NumUsed       :=0;
  
    Input         :=CNF^.DoorDir;
    DoorPath      :=EditPrompt(40,'Door Dir: '); Println('');
    If DoorPath[Length(DoorPath)]<>'\' Then DoorPath:=DoorPath+'\';

    Input         :='NEWDOOR.BAT';
    BatchName     :=EditPrompt(40,'Batch File: '); Println('');

    Input         :='1';
    Println('1=DORINFOx.DEF 3=CHAIN.TXT 6=CALLINFO.BBS');
    DoorType      :=Valu(EditPrompt(1,'Door Type: ')); Println('');
  End;

  Assign(DoorF,CNF^.DataDir+'DOORS.DAT');
  If (NOT Exist(CNF^.DataDir+'DOORS.DAT')) Then ReWrite(DoorF) Else
  Begin
    ReSet(DoorF);
    Repeat Read(DoorF,Tmp) Until EOF(DoorF);
  End;
  Write(DoorF,DoorInfo);
  Close(DoorF);
End;


Procedure LstDoor(P2:String);
Begin

  If (Exist(CNF^.MenuDir+P2+'.TOP') and ((P2<>'AUTO') or (P2<>'EVERY'))) Then PrintFile(CNF^.MenuDir+P2+'.TOP')
 Else
  Begin
    Cls;
    If Exist(CNF^.DataDir+'DOORS.DAT') Then
    Begin
      Assign(DoorF,CNF^.DataDir+'DOORS.DAT');
      ReSet(DoorF);
      While (Not EOF(DoorF)) Do
      Begin
        Read(DoorF,DoorInfo);
        Println(Strr(FilePos(DoorF))+' '+DoorInfo.Name);
      End;
      Close(DoorF);
    End Else MCIPrintln('|12No doors exist!|RE');
  End;
  If Exist(CNF^.MenuDir+P2+'.BOT') and ((P2<>'AUTO') or (P2<>'EVERY')) Then PrintFile(CNF^.MenuDir+P2+'.BOT')
  Else MCiPrintln('|08컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�|RE');
End;

Procedure DelDoor(P2:String);
Begin
  LstDoor(P2);
  Input:='1';
  Input:=EditPrompt(1,'Delete: '); Println('');
  Assign(DoorF,CNF^.DataDir+'DOORS.DAT');
  ReSet(DoorF);
  Seek(DoorF,Valu(Input)-1);
  FillChar(DoorInfo,SizeOf(DoorInfo),#0);
  Write(DoorF,DoorInfo);
  Close(DoorF);
End;

Procedure EdtDoor(P2:String);
Var Hold:Byte;
Begin
  LstDoor(P2);
  Input:='1';
  Input:=EditPrompt(1,'Edit: '); Println('');
  Hold:=Valu(Input);
  Assign(DoorF,CNF^.DataDir+'DOORS.DAT');
  ReSet(DoorF);
  Seek(DoorF,Hold-1);
  Read(DoorF,DoorInfo);

  Input:=DoorInfo.Name;
  Input:=EditPrompt(25,'Door Name: '); Println('');
  DoorInfo.Name:=Input;

  Input:=DoorInfo.Description;
  Input:=EditPrompt(40,'Description: '); Println('');
  DoorInfo.Description:=Input;

  Input:=DoorInfo.Flags;
  Input:=EditPrompt(40,'Flags: '); Println('');
  DoorInfo.Flags:=Input;

  Input:=DoorInfo.DoorPath;
  Input:=EditPrompt(40,'Door Path: '); Println('');
  DoorInfo.DoorPath:=Input;

  Input:=DoorInfo.BatchName;
  Input:=EditPrompt(40,'Batch File: '); Println('');
  DoorInfo.BatchName:=Input;

  Input:=Strr(DoorInfo.DoorType);
  Println('1=DORINFOx.DEF 3=CHAIN.TXT 6=CALLINFO.BBS');
  Input:=EditPrompt(1,'Door Type: '); Println('');
  DoorInfo.DoorType:=Valu(Input);
  Seek(DoorF,Hold-1);
  Write(DoorF,DoorInfo);
  Close(DoorF);
End;

Procedure Door(B:Byte);
Var Txt:Text;
Begin
  If Exist(CNF^.DataDir+'DOORS.DAT') Then
  Begin
    Assign(DoorF,CNF^.DataDir+'DOORS.DAT');
    ReSet(DoorF);
    Seek(DoorF,B-1);
    Read(DoorF,DoorInfo);
    Close(DoorF);
    DropFile(DoorInfo.DoorType,DoorInfo.DoorPath);
    Assign(Txt,'DOOR.BAT');
    ReWrite(Txt);
    Writeln(Txt,'CD '+DoorInfo.DoorPath);
    Writeln(Txt,'CALL '+DoorInfo.BatchName);
{   Writeln(Txt,'DEL '+CNF^.DoorDir+DoorType()); Removes DORINFO1.DEF }
    Writeln(Txt,'CD '+CNF^.SysDir);
    If LocalLogin Then Writeln(Txt,'SWPRO.BAT /U '+Strr(UNum)+' /LOCAL /ANSI /M DOOR') 
    Else Writeln(Txt,'SWPRO.BAT /U '+Strr(UNum)+' /REMOTE /ANSI /M DOOR');
    Close(Txt);
    SWDone(31);
  End;
End;

Begin
End.
