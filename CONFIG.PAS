{ ShockWavE Pro Config Program BY ICE BREAKER }
{ Started: 10/28/93   Finished: 11/02/93 }
{ Debuging: 11/03/93...  }

Program Config;
{$M 32000,6400,35000 }

Uses opCrt,Dos,ICEio1,PullBarZ,Records,Profiles,FastTTT5,CnfgRec,Strnttt5,Event;

Const
      colorstr:array [0..15] of Str25=
  (' Black ',' Blue ',' Green ',' Cyan ',' Red ',' Magenta ',' Brown ',' Grey ',
   ' Dk Grey ',' Lt Blue ',' Lt Green ',' Lt Cyan ',' Lt Red ',' Lt Magenta ',' Yellow ',' White ');

   ConfigVerNum='  Config:0.39  ';
  ConfigVerDate='  Config:05/31/95  ';

Var Tim,
    Save,iCE  :String;
    Bars      :PullBarzRec;
    Quit      :Boolean;
    LastBar,Pick:Byte;
    Txt       :StringRec;
    TextFile  :File Of StringRec;
    CurPage   :Byte;
    Ext     : String[2];
    Ch        :Char;
    Cur,LangSet   :Byte;

procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
begin
  inline ($1E/$C5/$B6/Addr1/$C4/$BE/Addr2/$8B/$8E/BlkLen/$8B/$D7/
          $B4/$00/$AC/$3C/$10/$73/$07/$80/$E4/$F0/$0A/$E0/$EB/$44/
       $3C/$18/$74/$13/$73/$19/$2C/$10/$02/$C0/$02/$C0/$02/$C0/
       $02/$C0/$80/$E4/$0F/$0A/$E0/$EB/$2D/$81/$C2/$A0/$00/$8B/
       $FA/$EB/$25/$3C/$1A/$75/$0B/$AC/$49/$51/$32/$ED/$8A/$C8/
       $AC/$EB/$0D/$90/$3C/$19/$75/$11/$AC/$51/$32/$ED/$8A/$C8/
       $B0/$20/$0B/$C9/$74/$03/$AB/$E2/$FD/$59/$49/$AB/$0B/$C9/
       $74/$02/$E2/$AA/$1F);
end;

function strr (n:integer):Str40;
var q:Str40;
begin
  str (n,q);
  strr:=q
end;

function valu (q:Str40):integer;
var i,s,pu:integer;
    r:real;
    c:Char;
begin
  valu:=0;
  if length(q)=0 then exit;
  c:=Q[1];
  if not (C in ['0','1','2','3','4','5','6','7','8','9','-']) then begin
    Valu:=0;
    exit;
  End;
  If (c in ['A'..'~']) then Begin
    Valu:=0;
    Exit;
  End;
  if length(q)>5 then exit;
  val (q,r,s);
  if s<>0 then exit;
  if (r<=32767.0) and (r>=-32767.0)
    then valu:=round(r)
end;


Procedure Strings;
Var XQuit:Boolean;
  Procedure StrBoxIt;
  {$I STRINGS.INC}
  Begin
    UnCrunch(STRINGS,Mem[$B800:(1*2)+(1*160)-162],STRINGS_LENGTH);
  End;

  Procedure WriteStrings;
  Begin
    Assign(TextFile,CNF^.DataDir+'STRINGS.DAT');
    If (Not Exist(CNF^.DataDir+'STRINGS.DAT')) Then ReWrite(TextFile) Else ReSet(TexTFile);
    If LangSet>0 THen
    Begin
      If LangSet>=FileSize(TextFile) Then Seek(TextFile,FileSize(TextFile)) Else Seek(TextFile,LangSet);
    End;
    Write(TextFile,Txt);
    Close(TextFile);
  End;

  Procedure SetUpStrings;
  Begin
   With Txt Do
   Begin
   Sys1PWPrompt    :='|03System |15One |03Password? ';
   Sys2PWPrompt    :='|03System |15Two |03Password? ';
   Sys3PWPrompt    :='|03System |15Three |03Password? ';
   ShowSys1Pw      :='|03System |15One |03Password is: ';
   ShowSys2Pw      :='|03System |15Two |03Password is: ';
   ShowSys3Pw      :='|03System |15Three |03Password is: ';
   ConnectStr      :='|03Connected at: |14|BA';
   DetectANSi      :='|03Auto-ANSi Detection...  |15-|07=|08] |14Wait |08[|07=|08-';
   GotANSi         :='|12A|14N|10S|15i |03Enabled!';
   NoANSi          :='No ANSi Detected...';
   LockBaudPrompt  :='|12Baudrate not support! |03Please enter Password: ';
   WrongPWBaud     :='|12Sorry, your modem is too slow...';
   NUPPrompt       :='|03New User Password: ';
   NewHandle       :='|03Enter the Handle you wish to use here: ';
   NewPassword     :='|03Enter the Password you wish to use here: ';
   GetHandle       :='|03Enter your Handle/ID#: ';
   DupHandle       :='|03That handle is already in use.';
   GetPassword     :='|03Enter your password: ';
   WrongPW         :='|12Wrong Password!!!';
   GetRealName     :='|03Enter your |14REAL |03first name: ';
   GetPhone        :='|03What is your |14VOICE |03Phone Number: ';
   AskANSi         :='|03Enable |12A|14N|10S|15i |03Color';
   AskHotKeys      :='|03Enable |08(|14One-Key|08)|03 Input';
   MsgAreaPrompt   :='|03Message Base |08(|15?|01/|15List|08)|01: ';
   InvalidMsgArea  :='|12Area does not exist!';
   NScanMsgPrompt  :='|03Scan for latest messages: ';
   NewScanHdrMsg   :='|03Scanning New Messages';
   PostPrompt      :='|03Post on |MB now: ';
   MsgDelPrompt    :='|12Do you really want to delete this message: ';
   AutoDelStr      :='|14Hang-On while I delete some messages...';
   TitlePrompt     :='|03Title: ';
   PostToPrompt    :='|03Send To |08(|15CR|01/|15All|08)|01: ';
   MsgULPrompt     :='|03Upload Prepared Message: ';
   ToAllStr        :='All';
   Anonprompt      :='|03Anonymous: ';
   NetOrigin1      :='NOT USED';
   NetOrigin2      :='NOT USED';
   FileAreaPrompt  :='|03File Base |08(|15?|01/|15List|08)|01: ';
   NScanFilesPrompt:='|03Scan for latest files: ';
   NewScanHdrFiles :='|03Scanning New Uploads/Files';
   FileDelPrompt   :='|12Do you really want to delete this file: ';
   NewFileStr      :='|12That file needs validation!';
   SpecFileStr     :='|12That file is not for you!';
   OffLineStr      :='|12Sorry, that file is Off-Line';
   PWFileStr       :='|12File is Password protected!';
   NoPointsStr     :='|12Sorry, but you need some more file points!';
   NoTimeStr       :='|12Not enough time for file transfer!';
   NoDLAreaStr     :='|12Write-Only File Base.';
   NoULAreaStr     :='|12Read-Only File Base.';
   NoFiles         :='|12There are no files areas to go to!';
   NoAreas         :='|12There are no message areas to go to!';
   BadUDRstr       :='|12You have a low Upload/Download Ratio!';
   BadUDKstr       :='|12You have a low Upload-K/Download-K Ratio!';
   BadPCRstr       :='|12You have a low Post/Call Ratio!';
   PrivFile        :='|12That file is PRIVATE!';
   ProtoHdr        :='System File Protocols';
   AskHangupDL     :='|03Drop-Carrier after Download is complete: ';
   AskHangupUL     :='|03Drop-Carrier after Upload is complete: ';
   DohangupUL      :='|03Thanks for the upload! - Hanging Up!';
   DoHangupDL      :='|03Download complete - Hanging up!';
   UsrNotValidated :='|12Sorry, the SysOp has not granted you access yet.';
   LogOffPrompt    :='|03Log off this board now: ';
   MsgToNext       :='Message To Next Caller';
   MsgToSysop      :='|03Leave messge to sysop';
   CloseTimeBnk    :='|12Sorry, the SysOp has closed the TimeVault.';
   WallPrompt      :='|03Scribble on the wall: ';
   TimeBankHdr     :='The TimeVault';
   BBSlistHdr      :='The Other Guys';
   SysOpWait       :='|15-|07=|08] |14Wait |08[|07=|15-';
   BadLevel        :='|12You are unauthorized to access that command or area!';
   AskMorePrompts  :='|03Enable |08(|14More|08) |03Prompts';
   EnterChatStr    :='|03The SysOp Enters Chat!';
   ExitChatStr     :='|03The SysOp Leaves Chat!';
   SysOpIn         :='|03The Sysop is available for chat!';
   SysOpOut        :='|03The SysOp is not available for chat!';
   SysOpInDosStr   :='|03SysOp In Local DOS Shell... |15-|07=|08] |14Wait |08[|07=|15-';
   AnonymousStr    :='[Unknown]';
   MatrixHangupStr :='|03Goodbye!  |08(|07Click!|08)';
   MatInvalidStr   :='|03Use |08(|15?|08) |03for Help.';
   MatrixPrompt    :='|03Cmd> ';
   HitAKey         :='|08[|15Hit A Key|08]';
   Email_To        :='|03Enter |11UserName |03or |11ID# |03to Send mail to: ';
   NewEmail        :='|12New E-Mail!!  |03Read now?';
   AppendFile      :='|03Attach file:';
   Certified       :='|03Certified Mail:';
   CarbonCopy      :='|03Carbon Copy to:';
   EmerChatPrmpt   :='|03Is this an |12emergency?';
   EnterEmergChat  :='|12Enter priority chat password:';
   ChatReasonPrmpt :='|03Chat Reason:';
   ReEnterPWPrmpt  :='|03Re-Enter password:';
   PWDontMatchstr  :='|12They don''t Match!  |03Try again...';
   QuoteString     :='|03|08-|14=|15] |12|UH |15[|14=|08-';
   UserNotFound    :='|12Sorry, you are not found in the users list!';
   ApplyNow        :='|03Do you wish to apply now?';
   UserNumStr      :='|03You are user number: |14|UN';
   ScrLen          :='|03Screen Length |08(|15CR|01/|1524|08)|01:';
   BirthDate       :='|03Birth Date - |08(|15MM|01/|15DD|01/|15YY|08)|01:';
   EditCmd         :='|03Command |08(|15?|01/|15Help|08)|01:';
   IntrHdr         :='Available Interviews';
   IntrFill        :='|03Fill-Out Which Interview:';
   IntrReplace     :='|12Interview already filled-out! - |03Replace?';
   ChkRIP          :='|03Checking For |15R|07I|08P |03Graphics...';
   HaveRIP         :='|15R|07I|08P |07Graphics Enabled!';
   ScanEmail       :='|03Scanning for new E-mail...   |08[|14Please Wait|08]';
   GenderPrompt    :='|03Gender |08(|15M|01/|15F|08)|01:';
   AskANSi         :='Do you have ANSi Emulation?';
   MsgSys          :='|03þ Messages SysOp þ (?/Help):';
 End;
 WriteStrings;
End;

Procedure ReadStrings;
Var T:String;
Begin
  T:='1';
  GotoXy(26,3);
  TextColor(9);
  Write('String Set: '); 
  TextColor(15); EditLine(T,Cur,WhereX,WhereY,3,Ext,False,1);
  If Length(T)=0 Then T:='1';
  LangSet:=Valu(T)-1;
  Assign(TextFile,CNF^.DataDir+'STRINGS.DAT');
  ReSet(TextFile);
  If LangSet>0 Then
  Begin
    If LangSet>FileSize(TextFile) Then SetUpStrings Else 
    Begin
      Seek(TextFile,LangSet);
      Read(TextFile,Txt);
      Close(TextFile);
    End;
  End
 Else
  Begin
    Read(TextFile,Txt);
    Close(TextFile);
  End;
End;


Procedure PageOne;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,Sys1PWPrompt,'System One Prompt',24,15);
    Add_Field(2,2,6,78,Sys2PWPrompt,'System Two Prompt',24,15);
    Add_Field(3,2,8,78,Sys3PWPrompt,'System Three Prompt',24,15);
    Add_Field(4,2,10,78,ConnectStr,'Connected At: String',24,15);
    Add_Field(5,2,12,78,WrongPW,'Wrong Password String',24,15);
    Add_Field(6,2,14,78,NewHandle,'(New User) Handle Prompt',24,15);
    Add_Field(7,2,16,78,NewPassword,'(New User) Password Prompt',24,15);
    Add_Field(8,2,18,78,WallPrompt,'TheWall Input Prompt',24,15);
{    Add_Field(9,2,20,78,GetANSiStr,'ANSi Detection String',24,15);}
    Add_Field(10,2,22,78,GotANSi,'ANSi Enabled String',24,15);
  End;
  FastWrite(2,3,9,'System One: ');
  FastWrite(2,5,9,'System Two: ');
  FastWrite(2,7,9,'System Three: ');
  FastWrite(2,9,9,'Connect: ');
  FastWrite(2,11,9,'Wrong Password: ');
  FastWrite(2,13,9,'New Handle: ');
  FastWrite(2,15,9,'New Password: ');
  FastWrite(2,17,9,'Wall Prompt: ');
  FastWrite(2,19,9,'Get ANSi String: ');
  FastWrite(2,21,9,'Got ANSi String: ');
End;

Procedure PageTwo;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,NoANSi,'ANSi Disabled String',24,15);
    Add_Field(2,2,6,78,LockBaudPrompt,'Baud Lockout Password Prompt',24,15);
    Add_Field(3,2,8,78,WrongPWBaud,'Wrong Lockout Password String',24,15);
    Add_Field(4,2,10,78,NUPPrompt,'(New-User-Password) Prompt',24,15);
    Add_Field(5,2,12,78,GetHandle,'Input Handle Prompt',24,15);
    Add_Field(6,2,14,78,DupHandle,'Duplicate Handle String',24,15);
    Add_Field(7,2,16,78,GetPassword,'Input Password Prompt',24,15);
    Add_Field(8,2,18,78,GetRealName,'Input Real Name Prompt',24,15);
    Add_Field(9,2,20,78,GetPhone,'Input VOICE Phone Number Prompt',24,15);
    Add_Field(10,2,22,78,AskANSi,'Use ANSi Prompt',24,15);
 End;
 FastWrite(2,3,9,'No ANSi String: ');
 FastWrite(2,5,9,'Slow Baud Prompt: ');
 FastWrite(2,7,9,'Wrong Lockout PW String: ');
 FastWrite(2,9,9,'New User Password Prompt:');
 FastWrite(2,11,9,'Login Handle Prompt: ');
 FastWrite(2,13,9,'Duplicate Handle String: ');
 FastWrite(2,15,9,'Login Password Prompt: ');
 FastWrite(2,17,9,'Real Name Prompt: ');
 FastWrite(2,19,9,'Phone Number Prompt: ');
 FastWrite(2,21,9,'Use ANSi Prompt: ');
End;

Procedure PageThree;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,AskHotkeys,'Use HotKey/One-Key Input Prompt',24,15);
    Add_Field(2,2,6,78,CloseTimeBnk,'Closed TimeBank String',24,15);
    Add_Field(3,2,8,78,BBSListHdr,'BBS Listing Header String',24,15);
    Add_Field(4,2,10,78,FileDelPrompt,'Delete File Prompt',24,15);
    Add_Field(5,2,12,78,MsgDelPrompt,'Delete Message Prompt',24,15);
    Add_Field(6,2,14,78,AutoDelStr,'Message Auto-Delete String',24,15);
    Add_Field(7,2,16,78,MsgAreaPrompt,'Message Area Prompt',24,15);
    Add_Field(8,2,18,78,InvalidMsgArea,'Invalid Message Area String',24,15);
    Add_Field(9,2,20,78,TitlePrompt,'Message "Title" Prompt',24,15);
    Add_Field(10,2,22,78,PostToPrompt,'Message "To" Prompt',24,15);
  End;
  FastWrite(2,3,9,'Hot Keys: ');
  FastWrite(2,5,9,'TimeBank Closed: ');
  FastWrite(2,7,9,'BBS Listing Header: ');
  FastWrite(2,9,9,'Delete File:');
  FastWrite(2,11,9,'Delete Message: ');
  FastWrite(2,13,9,'Auto-Delete Messages: ');
  FastWrite(2,15,9,'Message Area: ');
  FastWrite(2,17,9,'Invalid Message Area: ');
  FastWrite(2,19,9,'Message Title: ');
  FastWrite(2,21,9,'Send To: ');
End;

Procedure PageFour;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,MsgULPrompt,'Upload Message Prompt',24,15);
    Add_Field(2,2,6,78,ToAllStr,'Message "To All" String',24,15);
    Add_Field(3,2,8,78,AnonPrompt,'Anonymous Prompt',24,15);
    Add_Field(4,2,10,78,SysOpWait,'SysOp Working String',24,15);
    Add_Field(5,2,12,78,FileAreaPrompt,'File Area Prompt',24,15);
    Add_Field(6,2,14,78,NewFileStr,'New File String',24,15);
    Add_Field(7,2,16,78,SpecFileStr,'Special File String',24,15);
    Add_Field(8,2,18,78,OffLineStr,'File Offline String',24,15);
    Add_Field(9,2,20,78,PWFileStr,'File Password String',24,15);
    Add_Field(10,2,22,78,NoPointsStr,'No File Points String',24,15);
 End;
 FastWrite(2,3,9,'Message Upload: ');
 FastWrite(2,5,9,'Message To All: ');
 FastWrite(2,7,9,'Message Anonymous: ');
 FastWrite(2,9,9,'SysOp Working: ');
 FastWrite(2,11,9,'File Area: ');
 FastWrite(2,13,9,'File Is New: ');
 FastWrite(2,15,9,'File Is Special: ');
 FastWrite(2,17,9,'File is Off-Line: ');
 FastWrite(2,19,9,'File is Password Protected: ');
 FastWrite(2,21,9,'No Files Points: ');
End;

Procedure PageFive;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,NoTimeStr,'No Time String',24,15);
    Add_Field(2,2,6,78,NoDLAreaStr,'Can''t Download From Area String',24,15);
    Add_Field(3,2,8,78,NoULAreaStr,'Can''t Upload To Area String',24,15);
    Add_Field(4,2,10,78,NoFiles,'No File Areas String',24,15);
    Add_Field(5,2,12,78,NoAreas,'No Message Areas String',24,15);
    Add_Field(6,2,14,78,BadUDRStr,'Bad Upload/Download Ratio String',24,15);
    Add_Field(7,2,16,78,BadUDKStr,'Bad Upload/Download K Ration String',24,15);
    Add_Field(8,2,18,78,BadPCRStr,'Bad Post/Call Ratio String',24,15);
    Add_Field(9,2,20,78,PrivFile,'Private File String',24,15);
    Add_Field(10,2,22,78,ProtoHdr,'Protocol Header String',24,15);
  End;
  FastWrite(2,3,9,'No Time For Download ');
  FastWrite(2,5,9,'Uploads Only: ');
  FastWrite(2,7,9,'Downloads Only: ');
  FastWrite(2,9,9,'No File Areas: ');
  FastWrite(2,11,9,'No Message Areas: ');
  FastWrite(2,13,9,'Bad U/D Ratio: ');
  FastWrite(2,15,9,'Bad U/D K Ratio: ');
  FastWrite(2,17,9,'Bad Post/Call Ratio: ');
  FastWrite(2,19,9,'Private File: ');
  FastWrite(2,21,9,'Protocol Header: ');
End;

Procedure PageSix;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,AskHangUpDL,'Hang-Up After Download String',24,15);
    Add_Field(2,2,6,78,AskHangUpUL,'Hang-Up After Upload String',24,15);
    Add_Field(3,2,8,78,DoHangUpUL,'Hang-Up Upload String',24,15);
    Add_Field(4,2,10,78,DoHangUpDL,'Hang-Up Download String',24,15);
    Add_Field(5,2,12,78,LogOffPrompt,'Log-Off Prompt',24,15);
    Add_Field(6,2,14,78,MsgToNext,'Sned Message To Next User Prompt',24,15);
    Add_Field(7,2,16,78,MsgToSysOp,'Send Message To Sysop Prompt',24,15);
    Add_Field(8,2,18,78,BadLevel,'Access Denied String',24,15);
    Add_Field(9,2,20,78,AskMorePrompts,'Use "More Prompts" Prompt',24,15);
    Add_Field(10,2,22,78,EnterChatStr,'SysOp Enter Chat String',24,15);
 End;
 FastWrite(2,3,9,'Hang-Up After Download: ');
 FastWrite(2,5,9,'Hang-Up After Upload: ');
 FastWrite(2,7,9,'Upload GoodBye String: ');
 FastWrite(2,9,9,'Download GoodBye String:');
 FastWrite(2,11,9,'Log-Off: ');
 FastWrite(2,13,9,'Message To Next User: ');
 FastWrite(2,15,9,'Message To SysOp: ');
 FastWrite(2,17,9,'Access Denied: ');
 FastWrite(2,19,9,'More Prompt: ');
 FastWrite(2,21,9,'Enter Chat: ');
End;

Procedure PageSeven;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,ExitChatStr,'SysOp Exit Chat String',24,15);
    Add_Field(2,2,6,78,SysOpIn,'SysOp Available For Chat String',24,15);
    Add_Field(3,2,8,78,SysOpOut,'SysOp Not Available For Chat String',24,15);
    Add_Field(4,2,10,78,NetOrigin1,'Net-Origin Line 1',24,15);
    Add_Field(5,2,12,78,NetOrigin2,'Net-Origin Line 2',24,15);
    Add_Field(6,2,14,78,PostPrompt,'Message Post Prompt',24,15);
    Add_Field(7,2,16,78,NScanFilesPrompt,'Newscan Files Prompt',24,15);
    Add_Field(8,2,18,78,NScanMsgPrompt,'Newscan Messages Prompt',24,15);
    Add_Field(9,2,20,78,NewScanHdrMsg,'Message Newscan Header',24,15);
    Add_Field(10,2,22,78,NewScanHdrFiles,'Files Newscan Header',24,15);
  End;
  FastWrite(2,3,9,'Exit Chat: ');
  FastWrite(2,5,9,'SysOp Available: ');
  FastWrite(2,7,9,'SysOp Unavailable: ');
  FastWrite(2,9,9,'Net Origin 1');
  FastWrite(2,11,9,'Net Origin 2: ');
  FastWrite(2,13,9,'Post Prompt: ');
  FastWrite(2,15,9,'Newscan Files: ');
  FastWrite(2,17,9,'Newscan Messages: ');
  FastWrite(2,19,9,'Newscan Message Header: ');
  FastWrite(2,21,9,'Newscan Files Header: ');
End;

Procedure PageEight;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,UsrNotValidated,'User Not Validated String',24,15);
    Add_Field(2,2,6,78,ShowSys1PW,'System One Password String',24,15);
    Add_Field(3,2,8,78,ShowSys2PW,'System Two Password String',24,15);
    Add_Field(4,2,10,78,ShowSys3PW,'System Three Password String',24,15);
    Add_Field(5,2,12,78,SysOpInDOSStr,'SysOp In DOS String',24,15);
    Add_Field(6,2,14,78,HitAKey,'Animated Hit-A-Key String',24,15);
    Add_Field(7,2,16,78,MatrixPrompt,'Matrix Command Prompt',24,15);
    Add_Field(8,2,18,78,MatrixHangupStr,'Matrix Disconnect String',24,15);
    Add_Field(9,2,20,78,MatInvalidStr,'Matrix Invalid Command String',24,15);
    Add_Field(10,2,22,78,AnonymousStr,'Message Anonymous String',24,15);
 End;
 FastWrite(2,3,9,'Not Validated: ');
 FastWrite(2,5,9,'System One Password Is: ');
 FastWrite(2,7,9,'System Two Password Is: ');
 FastWrite(2,9,9,'System Three Password Is:');
 FastWrite(2,11,9,'SysOp In DOS: ');
 FastWrite(2,13,9,'Hit A Key: ');
 FastWrite(2,15,9,'Matrix Prompt: ');
 FastWrite(2,17,9,'Matrix Hangup: ');
 FastWrite(2,19,9,'Matrix Invalid Command: ');
 FastWrite(2,21,9,'Message Anonymous: ');
End;

Procedure PageNine;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,Email_To,'Send E-Mail To Prompt',24,15);
    Add_Field(2,2,6,78,NewEMail,'New E-Mail String',24,15);
    Add_Field(3,2,8,78,AppendFile,'Append File to E-Mail Prompt',24,15);
    Add_Field(4,2,10,78,Certified,'Certified E-Mail Prompt',24,15);
    Add_Field(5,2,12,78,CarbonCopy,'Carbon Copy E-Mail To Prompt',24,15);
    Add_Field(6,2,14,78,EmerChatPrmpt,'Emergency Chat Prompt',24,15);
    Add_Field(7,2,16,78,EnterEmergChat,'Emergency Chat Password Prompt',24,15);
    Add_Field(8,2,18,78,ChatReasonPrmpt,'Chat Reason Prompt',24,15);
    Add_Field(9,2,20,78,ReEnterPWPrmpt,'Re-Enter Password Prompt',24,15);
    Add_Field(10,2,22,78,PWDontMatchstr,'Passwords Don''t Match Prompt',24,15);
 End;
 FastWrite(2,3,9,'Send To: ');
 FastWrite(2,5,9,'Read E-Mail Now: ');
 FastWrite(2,7,9,'Append File: ');
 FastWrite(2,9,9,'Certified Mail:');
 FastWrite(2,11,9,'Carbon Copy: ');
 FastWrite(2,13,9,'Emergency Chat: ');
 FastWrite(2,15,9,'Emergency Chat PW:');
 FastWrite(2,17,9,'Chat Reason: ');
 FastWrite(2,19,9,'Re-Enter Password: ');
 FastWrite(2,21,9,'Don''t Match: ');
End;

Procedure PageTen;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,QuoteString,'Message Quote String',24,15);
    Add_Field(2,2,6,78,UserNotFound,'User Not File String',24,15);
    Add_Field(3,2,8,78,ApplyNow,'Apply For Access Prompt',24,15);
    Add_Field(4,2,10,78,UserNumStr,'User Numer String',24,15);
    Add_Field(5,2,12,78,ScrLen,'Screen Length Prompt',24,15);
    Add_Field(6,2,14,78,BirthDate,'BirthDay Prompt',24,15);
    Add_Field(7,2,16,78,EditCmd,'FSE Command Prompt',24,15);
    Add_Field(8,2,18,78,IntrHdr,'Interview Header',24,15);
    Add_Field(9,2,20,78,IntrFill,'Interview Menu Prompt',24,15);
    Add_Field(10,2,22,78,IntrReplace,'Replace Interview Prompt',24,15);
 End;
 FastWrite(2,3,9,'Quote String: ');
 FastWrite(2,5,9,'User Not Found: ');
 FastWrite(2,7,9,'Apply Now: ');
 FastWrite(2,9,9,'User Number:');
 FastWrite(2,11,9,'Screen Length: ');
 FastWrite(2,13,9,'Birth Date: ');
 FastWrite(2,15,9,'Editor Command: ');
 FastWrite(2,17,9,'Interview Header: ');
 FastWrite(2,19,9,'Fill out Inteview: ');
 FastWrite(2,21,9,'Replace Interview: ');
End;

Procedure PageEleven;
Begin
  With Txt Do
  Begin
    Add_Field(1,2,4,78,ChkRip,'Checking for RIP string',24,15);
    Add_Field(2,2,6,78,HaveRip,'RIP Graphics Enabled',24,15);
    Add_Field(3,2,8,78,ScanEMail,'Scanning E-Mail String',24,15);
    Add_Field(4,2,10,78,GenderPrompt,'New User Gender Prompt',24,15);
{    Add_Field(5,2,12,78,ANSiStr,'Do you have ANSi Prompt',24,15);}
    Add_Field(6,2,14,78,MsgSys,'Message SysOp Prompt',24,15);
 End;
 FastWrite(2,3,9,'Get RIP String:');
 FastWrite(2,5,9,'RIP Enabled:');
 FastWrite(2,7,9,'EMail Scan String:');
 FastWrite(2,9,9,'Gender Prompt:');
 FastWrite(2,11,9,'Get ANSi Prompt: '); { ""  "" }
 FastWrite(2,13,9,'Msg Sys. Prompt: ');  { ""  "" }
End;

Procedure PageUp;
Begin
  WriteStrings;
  Pick:=Pick-1;
  If Pick=0 Then Pick:=1;
End;

Procedure PageDown;
Begin
  WriteStrings;
  Pick:=Pick+1;
  If Pick=12 Then Pick:=11;
End;

Procedure GetInput;
Begin
  Display_Fields(1);
  Save:=EditFields(1);
  If Save=#27 Then Begin WriteStrings; Pick:=99; End;
  If Save=#68 Then Pick:=99;
  If Save=#73 Then PageUp;
  If Save=#81 Then PageDown;
  If Save=#59 Then; {F1}
End;

Begin
  Pick:=1;
  XQuit:=False;
  If (Not Exist(CNF^.DataDir+'STRINGS.DAT')) Then SetUpStrings Else ReadStrings;
  Repeat
    StrBoxit;
    FastWrite(1,25,9,'[Page: '+Int_To_Str(Pick)+'] [Language Set: '+Strr(LangSet+1)+'] ');
    Case Pick Of
      1:Begin PageOne;    Getinput End;
      2:Begin PageTwo;    Getinput End;
      3:Begin PageThree;  Getinput End;
      4:Begin PageFour;   Getinput End;
      5:Begin PageFive;   Getinput End;
      6:Begin PageSix;    Getinput End;
      7:Begin PageSeven;  Getinput End;
      8:Begin PageEight;  Getinput End;
      9:Begin PageNine;   GetInput End;
     10:Begin PageTen;    GetInput End;
     11:Begin PageEleven; GetInput End;
     99:XQuit:=True;
    End;
  Until XQuit=True;
ClrScr;
CursorON;
End;

Procedure Intro;
{$I INTRODAT.PAS}
Var Ch:Char;
Begin
  ClrScr;
  CursorOFF;
  UnCrunch(INTRODATA,Mem[$B800:(1*2)+(1*160)-162],INTRODATA_LENGTH);
  CH:=ReadKey;
  If Ch=#0 then Ch:=ReadKey;
End;

Procedure BoxIt;
{$I CONFIG.INC}
Begin
  UnCrunch(CNFDATA,Mem[$B800:(1*2)+(1*160)-162],CNFDATA_LENGTH);
End;

Procedure FixPath(Var S:String);
Begin
  If S[Length(S)]<>'\' then S:=S+'\';
End;

Function  DirExists (FileName: PathStr): boolean;
Var
  f   : file;
  attr: word;
  len : byte;
Begin
  Len:=Length(FileName);
  If (FileName[len] = '\') then Dec(FileName[0]);
  FileName:=Filename+ '\.';
  Assign(f,FileName);
  GetFattr(f,attr);
  DirExistS := ((attr and directory)=directory);
  End;

Procedure MakeDir(Path:String); { have this make multi depth dirs }
Begin                           { ie. C:\BBS\SWPRO\MENUDATA }
  {$I+}
  Delete(Path,Length(Path),1);
  If Not DirExists(Path) Then MkDir(Path);
  {$I-}
End;

Procedure SysInfo;
Var Private,Log,WFC,Video,Snow,
    SSave,Menu,Bell,Bull,Wall,Famous,EMS,MaxDos,Print,Stat:String[3];
Begin
  With Cnf^ Do
  Begin
    Log     :=Boo_To_Str(UseAutoLogin);
    WFC     :=Boo_To_Str(WFC50);
    Private :=Boo_To_Str(PrivateBBS);
    Video   :=Boo_To_Str(UseDirectVideo);
    Snow    :=Boo_To_Str(UseSnowCheck);
    Menu    :=Boo_To_Str(UseExtMnu);
    Bell    :=Boo_To_Str(UseLoginBell);
    Bull    :=Boo_To_Str(UseBulletins);
    Wall    :=Boo_To_Str(UseTheWall);
    Famous  :=Boo_To_Str(UseFamousDay);
    EMS     :=Boo_To_Str(UseEMS);
    MaxDos  :=Boo_To_Str(MaximumDosShell);
    Print   :=Boo_To_Str(UsePrinterLog);
    Stat    :=Boo_To_Str(UseStatLine);
    SSave   :=Int_To_Str(ScreenSaveMin);
    {ID,XX,YY,Len:Byte; Var S:String; Msg:String; ZZ,WW,Fore,Back:Byte);}
    Add_Field(1,45,3,34,FullSysName,'Full System Name',23,15);
    Add_Field(2,45,4,6,RegNumber,'Registration Code',23,15);
    Add_Field(3,45,5,25,SysOpName,'SysOp''s User Name',23,15);
    Add_Field(4,45,6,3,Log,'Yes to use AutoLogin',23,15);
    Add_Field(5,45,7,3,WFC,'Yes to use High-Res WFC Screen',23,15);
    Add_Field(6,45,8,3,Private,'Yes for Private System',23,15);
    Add_Field(7,45,9,3,Video,'Yes to use Direct Video Writes',23,15);
    Add_Field(8,45,10,3,Snow,'Yes to check for snow',23,15);
    Add_Field(9,45,11,3,Menu,'Yes to use Auto-RiP Detection',23,15);
    Add_Field(10,45,12,3,Bell,'Yes to use Login Bell',23,15);
    Add_Field(11,45,13,3,Bull,'Yes to use Login Bulletins',23,15);
    Add_Field(12,45,14,3,Wall,'Yes to use TheWall',23,15);
    Add_Field(13,45,15,3,Famous,'Yes to use Famous Day Logoff',23,15);
    Add_Field(14,45,16,3,EMS,'Yes to use EMS',23,15);
    Add_Field(15,45,17,3,MaxDOS,'Yes to use Max. Memory for DOS Shell',23,15);
    Add_Field(16,45,18,3,Print,'Yes to Print Call Logs',23,15);
    Add_Field(17,45,19,3,Stat,'Yes to use Local Status Line',23,15);
    Add_Field(18,45,20,1,SSave,'Min. to activate Screen Saver (0=Not Used)',23,15);
  End;
  FastWrite(26,3,9,'System Name: ');
  FastWrite(26,4,9,'Registration Code: ');
  FastWrite(26,5,9,'SysOp Handle: ');
  FastWrite(26,6,9,'Auto-Login: ');
  FastWrite(26,7,9,'High-Res WFC: ');
  FastWrite(26,8,9,'Private BBS: ');
  FastWrite(26,9,9,'Direct Video: ');
  FastWrite(26,10,9,'Check For Snow: ');
  FastWrite(26,11,9,'RiP Detection: ');
  FastWrite(26,12,9,'Login Bell: ');
  FastWrite(26,13,9,'Login Bulletins: ');
  FastWrite(26,14,9,'Use The Wall: ');
  FastWrite(26,15,9,'Use Famous Day: ');
  FastWrite(26,16,9,'Use EMS: ');
  FastWrite(26,17,9,'Max. DOS Shell: ');
  FastWrite(26,18,9,'Printer Log: ');
  FastWrite(26,19,9,'Status Line: ');
  FastWrite(26,20,9,'Screen Saver: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    UseAutoLogin:=Str_To_Boo(Log);
    WFC50:=Str_To_Boo(WFC);
    PrivateBBS:=Str_To_Boo(Private);
    UseDirectVideo:=Str_To_Boo(Video);
    UseSnowCheck:=Str_To_Boo(Snow);
    UseExtMnu:=Str_To_Boo(Menu);
    UseLoginBell:=Str_To_Boo(Bell);
    UseBulletins:=Str_To_Boo(Bull);
    UseTheWall:=Str_To_Boo(Wall);
    UseFamousDay:=Str_To_Boo(Famous);
    UseEms:=Str_To_Boo(EMS);
    MaximumDosShell:=Str_To_Boo(MaxDOS);
    UsePrinterLog:=Str_To_Boo(Print);
    UseStatLine  :=Str_To_Boo(Stat);
    ScreenSaveMin:=Valu(SSave);
    WriteConfig;
  End;
End;

Procedure SysDirectories;
Begin
  With Cnf^ Do
  Begin
    Add_Field(1,45,3,33,SysDir,'Path where ShockWavE runs',23,15);
    Add_Field(2,45,4,33,MsgDir,'Path to message data',23,15);
    Add_Field(3,45,5,33,MsgBoardDir,'<unused>',23,15);
    Add_Field(4,45,6,33,UpLoadDir,'Path to file area data',23,15);
    Add_Field(5,45,7,33,SwapDir,'ShockWavE Swap File directory',23,15);
    Add_Field(6,45,8,33,MenuDir,'Path to ANSi/Non-ANSi Menus',23,15);
    Add_Field(7,45,9,33,DoorDir,'Direcotory for doors',23,15);
    Add_Field(8,45,10,33,WorkDir,'Path for work directory',23,15);
    Add_Field(9,45,11,33,NetDir,'Path to include files',23,15);
    Add_Field(10,45,12,33,DSZLog,'DSZLog Environment Path',23,15);
    Add_Field(11,45,13,33,DataDir,'Path to Data files',23,15);
    Add_Field(12,45,14,33,FileMailDir,'Path to File-Mail',23,15);
    Add_Field(14,45,15,33,MenuDataDir,'Path to menu data',23,15);

  End;
  FastWrite(26,3,9,'Path To ShockWavE:');
  FastWrite(26,4,9,'Path to Messages:');
  FastWrite(26,5,9,'Path to Boards:');
  FastWrite(26,6,9,'Path to Files:');
  FastWrite(26,7,9,'Swap Directory:');
  FastWrite(26,8,9,'Path to ANSis:');
  FastWrite(26,9,9,'Path To Doors:');
  FastWrite(26,10,9,'Work Directory:');
  FastWrite(26,11,9,'Path To Includes:');
  FastWrite(26,12,9,'DSZ Log Path:');
  FastWrite(26,13,9,'Path to Data:');
  FastWrite(26,14,9,'Path to File Mail:');
  FastWrite(26,15,9,'Path To Menu Data:');

  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  Begin
    With Cnf^ Do
    Begin
      FixPath(SysDir);
      FixPath(MsgDir);      MakeDir(MsgDir);
      FixPath(MsgBoardDir); MakeDir(MsgBoardDir);
      FixPath(UploadDir);   MakeDir(UploadDir);
      FixPath(SwapDir);     MakeDir(SwapDir);
      FixPath(MenuDir);     MakeDir(MenuDir);
      FixPath(DoorDir);     MakeDir(DoorDir);
      FixPath(WorkDir);     MakeDir(WorkDir);
      FixPath(NetDir);      MakeDir(NetDir);
      FixPath(DataDir);      MakeDir(DataDir);
      FixPath(FileMailDir); MakeDir(FileMailDir);
      FixPath(MenuDataDir); MakeDir(MenuDataDir);
    End;
    WriteConfig;
  End;
End;

Procedure SysPasswords;
Begin
  With Cnf^ Do
  Begin
    Add_Field(1,43,3,20,PWString,'Hidden Password String',23,15);
    Add_Field(2,43,4,20,SysOpPW,'SysOp Password',23,15);
    Add_Field(3,43,5,20,System1PW,'System One Password',23,15);
    Add_Field(4,43,6,20,System2PW,'System Two Password',23,15);
    Add_Field(5,43,7,20,System3PW,'System Three Password',23,15);
    Add_Field(6,43,8,20,NewUserPW,'New User Password',23,15);
    Add_Field(7,43,9,20,LockOutBaudPass,'Lock-Out Baud Password',23,15);
    Add_Field(8,43,10,20,ChatPW,'Emergency Chat Password',23,15);
  End;
  FastWrite(26,3,9,'Password String: ');
  FastWrite(26,4,9,'SysOp Password: ');
  FastWrite(26,5,9,'System One: ');
  FastWrite(26,6,9,'System Two: ');
  FastWrite(26,7,9,'System Three: ');
  FastWrite(26,8,9,'New User: ');
  FastWrite(26,9,9,'Lock-Out: ');
  FastWrite(26,10,9,'Emergency Chat: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then WriteConfig;
End;

Procedure SysModemSetup;
Var Def,Min,Port:String;

Begin
  With Cnf^ Do
  Begin
    Port:=Int_To_Str(ModemPort);
    Def:=Int_To_Str(DefBaudRate);
    Min:=Int_To_Str(MinBaudRate);
    Add_Field(1,39,3,1,Port,'Modem Com-Port to use',23,15);
    Add_Field(2,39,4,39,ModemINITStr,'Modem Initialization String',23,15);
    Add_Field(3,39,5,39,ModemHangUpStr,'Modem Hang-Up String',23,15);
    Add_Field(4,39,6,39,ModemDialStr,'Modem Dial String',23,15);
    Add_Field(5,39,7,39,ModemDialSuff,'Modem Dial Suffix',23,15);
    Add_Field(6,39,8,5,Def,'Maximum Baud Rate',23,15);
    Add_Field(7,39,9,5,Min,'Minimum Baud Rate',23,15);
  End;
  FastWrite(26,3,9,'Com-Port: ');
  FastWrite(26,4,9,'Modem Init: ');
  FastWrite(26,5,9,'Hang-Up: ');
  FastWrite(26,6,9,'Dial Prefix: ');
  FastWrite(26,7,9,'Dial Suffix: ');
  FastWrite(26,8,9,'Max. Baud: ');
  FastWrite(26,9,9,'Min. Baud: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    ModemPort  :=Valu(Port);
    DefBaudRate:=Str_To_Word(Def);
    MinBaudRate:=Valu(Min);
    WriteConfig;
  End;
End;

Procedure SysMisc1;
Var Leech,UTime,RDoors,Doors,Multi:String[3];
    LeeK,LeeUD,PLvl,Max,BankLvl,Time,Node:String[40];

Begin
  With Cnf^ Do
  Begin
    Leech:=Boo_To_Str(UseLeechWeek);
    UTime:=Boo_To_Str(UseTimeBank);
    RDoors:=Boo_To_Str(RemoteDoors);
    Multi:=Boo_To_Str(MultiNode);
    LeeK:=Int_To_Str(LeechListK);
    LeeUD:=Int_To_Str(LeechListUD);
    PLvl:=Int_To_Str(PrivLvl);
    Max:=Int_To_Str(MaxTimeBank);
    BankLvl:=Int_To_Str(TimeBankLvl);
    Time:=Int_To_Str(TimeOutTime);
    Node:=Int_To_Str(NodeNumber);
    Add_Field(1,43,3,3,Leech,'Yes to use Leech-Week',23,15);
    Add_Field(2,43,4,5,LeeUD,'U/D Ratio to put user in Leech-List',23,15);
    Add_Field(3,43,5,5,LeeK,'K to put user in Leech-List',23,15);
    Add_Field(4,43,6,3,UTime,'Yes to use Time-Bank',23,15);
    Add_Field(5,43,7,5,Max,'Maximum Time Storage for Time-Bank',23,15);
    Add_Field(6,43,8,5,BankLvl,'Level needed to use Time-Bank',23,15);
    Add_Field(7,43,9,5,PLvl,'Private Hours Access Level',23,15);
    Add_Field(8,43,10,10,PrivBegin,'Private Hours Start Time',23,15);
    Add_Field(9,43,11,10,PrivEnd,'Private Hours End Time',23,15);
    Add_Field(10,43,12,3,RDoors,'Yes to allow Remote Door maintainance',23,15);
    Add_Field(11,43,13,10,EventTime,'Time to activate Event',23,15);
    Add_Field(12,43,14,12,EventBatchFile,'Batch file to run for Event',23,15);
    Add_Field(13,43,15,10,SysOpIn,'SysOp Available Time',23,15);
    Add_Field(14,43,16,10,SysOpOut,'SysOp Unavailable Time',23,15);
    Add_Field(15,43,17,3,Time,'Hang-Up Time Out (in Min.)',23,15);
    Add_Field(16,43,18,3,Multi,'Yes if Multi-Node System',23,15);
    Add_Field(17,43,19,2,Node,'System Node Number',23,15);
  End;
  FastWrite(26,3,9,'Leech Week: ');
  FastWrite(26,4,9,'Leech UD Ratio: ');
  FastWrite(26,5,9,'Leech K Ratio: ');
  FastWrite(26,6,9,'Time Bank: ');
  FastWrite(26,7,9,'Max. Time: ');
  FastWrite(26,8,9,'Bank Level: ');
  FastWrite(26,9,9,'Private Level: ');
  FastWrite(26,10,9,'Priv. Hrs Begin: ');
  FastWrite(26,11,9,'Priv. Hrs End: ');
  FastWrite(26,12,9,'Door Maint.: ');
  FastWrite(26,13,9,'Event Time: ');
  FastWrite(26,14,9,'Event Batch: ');
  FastWrite(26,15,9,'SysOp In: ');
  FastWrite(26,16,9,'SysOp Out: ');
  FastWrite(26,17,9,'Time Out: ');
  FastWrite(26,18,9,'Multi-Node: ');
  FastWrite(26,19,9,'Node Number: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    UseLeechWeek:=Str_To_Boo(Leech);
    UseTimeBank:=Str_To_Boo(Utime);
    RemoteDoors:=Str_To_Boo(RDoors);
    MultiNode:=Str_To_Boo(Multi);
    LeechListK:=Valu(LeeK);
    LeechListUD:=Valu(LeeUD);
    PrivLvl:=Valu(PLvl);
    MaxTimeBank:=Valu(Max);
    TimeBankLvl:=Valu(BankLvl);
    TimeOutTime:=Valu(Time);
    NodeNumber:=Valu(Node);
    WriteConfig;
  End;
End;

Procedure DoAttrib;

  var CLastBar,cnt,v:Byte;
      k:char;
      Zuit:Boolean;
      CPtr:^Byte;

Procedure Demo(Var Tmp:Byte);
 var cnt:integer;
          K:char;
    begin
      CPtr:=@Tmp;
      GrowFBox(55,9,74,15,8,0,1);
      gotoxy(56,10);
      Textcolor(15);
      write(' Color Selection');
      gotoxy(56,12);
      for cnt:=0 to 15 do
      begin
        TextColor(cnt); write('Û');
      end;
      cnt:=Tmp;

      repeat
        gotoxy(56+cnt,11);
        Textcolor(15);
        write('');
        gotoxy(60,14);
        Textcolor(cnt);
        if cnt=0 then
        begin
          Textcolor(15+Blink); write('   Black    ');
          Textcolor(cnt);
        end
      else
        Write(colorstr[cnt]);
        k:=ReadKey;
        IF K=#0 then K:=ReadKey;
        if (k=#77) or (K=#28) then
        begin
          gotoxy(cnt+56,11); write(' ');
          cnt:=cnt+1;
          if cnt>15 then cnt:=0;
        end
      else
       if (k=#75) or (k=#29) then
       begin
         gotoxy(cnt+56,11);write(' ');
         cnt:=cnt-1;
         if cnt<0 then cnt:=15;
       end;
       until (k=#13) or (k=#27);
       If (K=#13) or (K=#27) then
       Begin
         Cptr^:=Cnt;
         WriteConfig;
         FastWrite(54,9,0,'                     ');
         FastWrite(54,10,0,'                     ');
         FastWrite(54,11,0,'                     ');
         FastWrite(54,12,0,'                     ');
         FastWrite(54,13,0,'                     ');
         FastWrite(54,14,0,'                     ');
         FastWrite(54,15,0,'                     ');
       End;
    End;

Procedure SetupColorMenu;
Begin
  With Bars Do
  Begin
    MenuName:='Color Selection';
    Choice[1]:=' Normal Color  ';
    Choice[2]:=' Top Color     ';
    Choice[3]:=' OutLock Color ';
    Choice[4]:=' Line Color    ';
    Choice[5]:=' Status Color  ';
    Choice[6]:=' User Status   ';
    Choice[7]:=' User Input    ';
    Choice[8]:=' User Prompt   ';
    Choice[9]:=' User Regular  ';
    Choice[10]:=' User Box     ';
    Choice[11]:=' User Inside  ';
    Choice[12]:=' User Command ';
    Choice[13]:=' User Misc    ';
    Choice[14]:=' Quit         ';
    NumChoices:=14;
    Defchoice:=CLastBar;
    KeyCmds:='ABCDEFGHIJKLM'+Chr(27);
  End;
  With Cnf^ Do
  Begin
  FastWrite(43,4,9,ColorStr[SysNormalColor]);
  FastWrite(43,5,9,ColorStr[SysTopColor]);
  FastWrite(43,6,9,ColorStr[SysOutLockColor]);
  FastWrite(43,7,9,ColorStr[SysLineColor]);
  FastWrite(43,8,9,ColorStr[SysStatBarColor]);
  FastWrite(43,9,9,ColorStr[DefStat]);
  FastWrite(43,10,9,ColorStr[DefInput]);
  FastWrite(43,11,9,ColorStr[DefPrompt]);
  FastWrite(43,12,9,ColorStr[DefReg]);
  FastWrite(43,13,9,ColorStr[DefBox]);
  FastWrite(43,14,9,ColorStr[DefInSide]);
  FastWrite(43,15,9,ColorStr[DefCmd]);
  FastWrite(43,16,9,ColorStr[DefMisc]);

  End;
End;
  Begin
    Zuit:=False;
    CLastBar:=1;
    Repeat
     { BoxIt;}
      SetUpColorMenu;
      Pick:=MenuBar(1,26,3,3,0,15,1,3,0,0,Bars);
      CLastBar:=Pick;
      With Cnf^ Do
      Case Pick Of
        1:Demo(SysNormalColor);
        2:Demo(SysTopColor);
        3:Demo(SysOutLockColor);
        4:Demo(SysLineColor);
        5:Demo(SysStatBarColor);
        6:Demo(DefStat);
        7:Demo(DefInput);
        8:Demo(DefPrompt);
        9:Demo(DefReg);
        10:Demo(DefBox);
        11:Demo(DefInside);
        12:Demo(DefCmd);
        13:Demo(DefMisc);
        14:Zuit:=True;
    End;
    Until Zuit=True;
  End;

Procedure SysMatrix;
Var Matrix:String[3];
Begin
  With Cnf^ Do
  Begin
    Matrix:=Int_To_Str(MatrixType);
    Add_Field(1,45,3,1,Matrix,'Matrix Type: 0:None 1:Normal 2:Config 3:DOS 4:Pulldown 5:SunOS',23,15);
    Add_Field(2,45,4,10,MatrixCmd[1],'Command For System One',23,15);
    Add_Field(3,45,5,25,MatrixDesc[1],'System One',23,15);
    Add_Field(4,45,6,10,MatrixCmd[2],'Command For System Two',23,15);
    Add_Field(5,45,7,25,MatrixDesc[2],'System Two',23,15);
    Add_Field(6,45,8,10,MatrixCmd[3],'Command For System Three',23,15);
    Add_Field(7,45,9,25,MatrixDesc[3],'System Three',23,15);

    Add_Field(8,45,10,10,MatrixCmd[4],'Check For Access',23,15);
    Add_Field(9,45,11,25,MatrixDesc[4],'Check For Access',23,15);

    Add_Field(10,45,12,10,MatrixCmd[5],'Command for New User',23,15);
    Add_Field(11,45,13,25,MatrixDesc[5],'Apply For Access',23,15);

    Add_Field(12,45,14,10,MatrixCmd[6],'Command to Leave FeedBack',23,15);
    Add_Field(13,45,15,25,MatrixDesc[6],'Send SysOp FeedBack',23,15);

    Add_Field(14,45,16,10,MatrixCmd[7],'Command to Chat',23,15);
    Add_Field(15,45,17,25,MatrixDesc[7],'Chat Request',23,15);

    Add_Field(16,45,18,10,MatrixCmd[8],'Command to Log Off',23,15);
    Add_Field(17,45,19,25,MatrixDesc[8],'Log Off System',23,15);
  End;
  FastWrite(26,3,9,'Matrix: ');
  FastWrite(26,4,9,'Command 1: ');
  FastWrite(26,5,9,'Description: ');
  FastWrite(26,6,9,'Command 2: ');
  FastWrite(26,7,9,'Description:');
  FastWrite(26,8,9,'Command 3: ');
  FastWrite(26,9,9,'Description: ');
  FastWrite(26,10,9,'Command 4: ');
  FastWrite(26,11,9,'Description: ');
  FastWrite(26,12,9,'Command 5: ');
  FastWrite(26,13,9,'Description: ');
  FastWrite(26,14,9,'Command 6: ');
  FastWrite(26,15,9,'Description: ');
  FastWrite(26,16,9,'Command 7: ');
  FastWrite(26,17,9,'Description: ');
  FastWrite(26,18,9,'Command 8: ');
  FastWrite(26,19,9,'Description: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  Begin
    CNF^.MatrixType:=valu(Matrix);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysLogin;
Var Pre,Bye,Welcome,HangUp,ANSI,FeedBack,Chat:String[3];
Begin
  With Cnf^ Do
  Begin
    Hangup:=Boo_To_Str(HangUpOnNew);
    ANSi:=Boo_To_Str(UseANSiDetect);
    Chat:=Boo_To_Str(AllowChat);
    FeedBack:=Boo_To_Str(AllowFeedBack);
    Welcome:=Int_To_Str(NumWelcomes);
    Pre:=Int_To_Str(NumPreLogins);
    Bye:=Int_To_Str(NUmGoodByes);
    Add_Field(1,43,3,3,HangUp,'Yes to Hang-Up on new users',23,15);
    Add_Field(2,43,4,3,ANSi,'Use Auto-ANSi Detection',23,15);
    Add_Field(3,43,5,3,Welcome,'Number Welcome ANSi''s',23,15);
    Add_Field(3,43,6,3,Pre,'Number of Prelogon Screens',23,15);
    Add_Field(3,43,7,3,Bye,'Number of Goodbye Screens',23,15);
    Add_Field(4,43,8,3,Chat,'Allow Matrix Chat',23,15);
    Add_Field(5,43,9,3,FeedBack,'Allow Matrix FeedBack',23,15);
    Add_Field(6,43,10,8,StartUpMenu,'File Name for StartUp Menu',23,15);
  End;
  FastWrite(26,3,9,'Hang-Up On New: ');
  FastWrite(26,4,9,'ANSi Detect: ');
  FastWrite(26,5,9,'Welcomes: ');
  FastWrite(26,6,9,'Prelogons: ');
  FastWrite(26,7,9,'GoodByes: ');
  FastWrite(26,8,9,'Matrix Chat: ');
  FastWrite(26,9,9,'Matrix FeedBack: ');
  FastWrite(26,10,9,'STARTUP Menu:');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    NumWelcomes:=Valu(Welcome);
    NumPrelogins:=Valu(Pre);
    NUmGoodByes:=Valu(Bye);
    HangUpOnNew:=Str_To_Boo(Hangup);
    UseANSiDetect:=Str_To_Boo(ANSi);
    AllowChat:=Str_To_Boo(Chat);
    AllowFeedBack:=Str_To_Boo(FeedBack);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysNUV;
Var Use,Kill:String[3];
    NLvl,Yes,No,DLvl,DXlvl,DFpts:String;
Begin
  With Cnf^ Do
  Begin
    Use:=Boo_To_Str(UseNUV);
    Kill:=Boo_To_Str(AutoKillNUV);
    NLvl:=Int_To_Str(NUVLvl);
    YEs:=int_To_Str(NUVYes);
    No:=Int_To_Str(NUVNo);
    DLvl:=Int_To_Str(DefNUVLvl);
    DXLvl:=Int_To_Str(DefNUVXLvl);
    DFpts:=Int_To_Str(DefNUVFpts);
    Add_Field(1,43,3,3,Use,'Yes to use New-User-Voting (NUV)',23,15);
    Add_Field(2,43,4,3,Kill,'Yes to Delete ''NO Voted'' users',23,15);
    Add_Field(3,43,5,5,NLvl,'Level to use NUV',23,15);
    Add_Field(4,43,6,3,Yes,'Number of ''YES Votes'' needed for validation',23,15);
    Add_Field(5,43,7,3,No,'Number of ''NO Votes'' needed to get deleted',23,15);
    Add_Field(6,43,8,5,DLvl,'Level users are validated with',23,15);
    Add_Field(7,43,9,5,DXLvl,'File level users are validated with',23,15);
    Add_Field(8,43,10,5,DFpts,'File Points users are validated with',23,15);
    Add_Field(8,43,11,5,DefNUVACSFlags,'ACS Flag users are validated with',23,15);
  End;
  FastWrite(26,3,9,'New User Voting: ');
  FastWrite(26,4,9,'Auto Delete: ');
  FastWrite(26,5,9,'NUV Level: ');
  FastWrite(26,6,9,'Num. Yes: ');
  FastWrite(26,7,9,'Num. No: ');
  FastWrite(26,8,9,'Def. Level: ');
  FastWrite(26,9,9,'Def. File Level: ');
  FastWrite(26,10,9,'Def. Points: ');
  FastWrite(26,11,9,'Def. ACS Flag: ');

  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    UseNUV:=Str_To_Boo(Use);
    AutoKillNUV:=Str_To_Boo(Kill);
    NUVLvl:=Valu(NLvl);
    NUVYes:=Valu(Yes);
    NUVNo:=Valu(No);
    DefNUVLvl:=Valu(DLvl);
    DefNUVXLvl:=Valu(DXLvl);
    DefNUVFpts:=Valu(DFpts);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysDef;
Var DLvl,DXLvl,DFpts,Exempt,PCR,UDR,UD:String;
Begin
  With Cnf^ Do
  Begin
    DLvl:=Int_To_Str(DefLvl);
    DXLvl:=Int_To_Str(DefXLvl);
    DFpts:=Int_To_Str(DefFpts);
    Exempt:=int_To_Str(ExemptPCR);
    PCR:=Int_To_Str(MinPCR);
    UDR:=Int_To_Str(MinUDR);
    UD:=Int_To_Str(MinUDK);
    Add_Field(1,40,3,38,DefNote,'Auto-Validation User Note',23,15);
    Add_Field(2,40,4,5,DLvl,'Auto-Validation Level',23,15);
    Add_Field(3,40,5,5,DefACSFlags,'Auto-Validation Access Flags',23,15);
    Add_Field(4,40,6,5,DXLvl,'Auto-Validation File Level',23,15);
    Add_Field(5,40,7,5,DFpts,'Auto-Validation File Points',23,15);
    Add_Field(6,40,8,5,Exempt,'PCR Check Exemption Level',23,15);
    Add_Field(7,40,9,3,PCR,'Minimum Post/Call ratio',23,15);
    Add_Field(8,40,10,3,UDR,'Minimum Upload/Download Ratio',23,15);
    Add_Field(9,40,11,3,UD,'Minimum Upload K/Download K Ratio',23,15);
  End;
  FastWrite(26,3,9,'User Note: ');
  FastWrite(26,4,9,'Level: ');
  FastWrite(26,5,9,'Flags: ');
  FastWrite(26,6,9,'File Level: ');
  FastWrite(26,7,9,'File Points: ');
  FastWrite(26,8,9,'Exempt Level: ');
  FastWrite(26,9,9,'Min. PCR: ');
  FastWrite(26,10,9,'Min. Ratio: ');
  FastWrite(26,11,9,'Min. K Ratio: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    DefLvl:=Valu(DLvl);
    DefXLvl:=Valu(DXLvl);
    DefFpts:=Valu(DFpts);
    ExemptPCR:=Valu(Exempt);
    MinPCR:=Valu(PCR);
    MinUDR:=Valu(UDR);
    MinUDK:=Valu(UD);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysInfoForms;
Var Force:Array[1..5] of String[3];
    Num:String;
    Zip:Byte;
Begin
  With Cnf^ Do
  Begin
    Num:=Int_To_Str(NumInfoForms);
    For Zip:=1 to 5 Do Force[Zip]:=Boo_To_Str(ForceInfo[Zip]);
    Add_Field(1,39,3,3,Num,'Number of Available Info-Forms',23,15);
    Add_Field(2,39,4,40,Info[1],'Info-Form One Description',23,15);
    Add_Field(3,39,5,3,Force[1],'Yes if Info-Form is Mandatory',23,15);
    Add_Field(4,39,6,40,Info[2],'Info-Form Two Description',23,15);
    Add_Field(5,39,7,3,Force[2],'Yes if Info-Form is Mandatory',23,15);
    Add_Field(6,39,8,40,Info[3],'Info-Form Three Description',23,15);
    Add_Field(7,39,9,3,Force[3],'Yes if Info-Form is Mandatory',23,15);
    Add_Field(8,39,10,40,Info[4],'Info-Form Four Description',23,15);
    Add_Field(9,39,11,3,Force[4],'Yes if Info-Form is Mandatory',23,15);
    Add_Field(10,39,12,40,Info[5],'Info-Form Five Description',23,15);
    Add_Field(11,39,13,3,Force[5],'Yes if Info-Form is Mandatory',23,15);
  End;
  FastWrite(26,3,9,'Info-Forms: ');
  FastWrite(26,4,9,'Info-Form 1: ');
  FastWrite(26,5,9,'Mandatory: ');
  FastWrite(26,6,9,'Info-Form 2: ');
  FastWrite(26,7,9,'Mandatory: ');
  FastWrite(26,8,9,'Info-Form 3: ');
  FastWrite(26,9,9,'Mandatory: ');
  FastWrite(26,10,9,'Info-Form 4: ');
  FastWrite(26,11,9,'Mandatory: ');
  FastWrite(26,12,9,'Info-Form 5: ');
  FastWrite(26,13,9,'Mandatory: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    NumInfoForms:=Valu(Num);
    For Zip:=1 to 5 Do ForceInfo[Zip]:=Str_To_Boo(Force[Zip]);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysLevels;
Var SysOp,Call2,File2,Pts2,Next,Users,Last:String;

Begin
  With Cnf^ Do
  Begin
    SysOp:=Int_To_Str(SysOpLvl);
    Call2:=Int_To_Str(SecCallLvl);
    File2:=Int_To_Str(SecCallFileLvl);
    Pts2:=int_To_Str(SecCallPts);
    Users:=Int_To_Str(ListUsersLvl);
    Last:=Int_To_Str(LIstLastUsrsLvl);
    Add_Field(1,40,3,38,SysOp,'SysOp Level',23,15);
    Add_Field(2,40,4,5,Call2,'Second Call Level',23,15);
    Add_Field(3,40,5,5,File2,'Second Call File Level',23,15);
    Add_Field(4,40,6,5,Pts2,'Second Call File Points',23,15);
    Add_Field(6,40,7,3,Users,'Level to list users',23,15);
    Add_Field(7,40,8,3,Last,'Level to view last callers list',23,15);
  End;
  FastWrite(26,3,9,'SysOp Level: ');
  FastWrite(26,4,9,'Level: ');
  FastWrite(26,5,9,'File Level: ');
  FastWrite(26,6,9,'File Points: ');
  FastWrite(26,7,9,'List Users: ');
  FastWrite(26,8,9,'Last Callers: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    SysOpLvl:=Valu(SysOp);
    SecCallLvl:=Valu(Call2);
    SecCallFileLvl:=Valu(File2);
    SecCallPts:=Valu(Pts2);
    ListUsersLvl:=Valu(Users);
    ListLastUsrsLvl:=Valu(Last);
    WriteConfig;
  End;
  CursorOff;
End;

  procedure dousertime;
  var input:Str80;
      n:integer;

    procedure refresh;
    var cnt:integer;
    begin
      ClrScr;
      gotoxy (1,1);
      Textcolor(7);
      writeln('Level Time ³ Level Time ³ Level Time ³ Level Time ³ Level Time');
      writeln('þÄÄÄÄÄÄÄÄÄÄþÄÄÄÄÄÄÄÄÄÄÄÄþÄÄÄÄÄÄÄÄÄÄÄÄþÄÄÄÄÄÄÄÄÄÄÄÄþÄÄÄÄÄÄÄÄÄÄþ');
      gotoxy (1,3);
      for cnt:=1 to 100 do
      begin
        TextColor(15); write(cnt:4,': ');
        TextColor(11); Write(CNF^.usertime[cnt]:4);
        TextColor(8);
        if (cnt mod 5)=0 then writeln else write (' ³ ')
      end
    end;

    procedure setone (n,v:integer);
    var x,y:integer;
    begin
      TextColor(14);
      x:=((n-1) mod 5)*13+7;
      y:=((n-1) div 5)+3;
      gotoxy (x,y);
      write(v:4);
      CNF^.usertime[n]:=v
    end;

    procedure getone (n:integer);
    var x,y,v:integer;
        ZCur:Byte;
        Xit:String;
    begin
      x:=((n-1) mod 5)*13+7;
      y:=((n-1) div 5)+3;
      gotoxy (x,y);
      write ('    ');
      Input:='';
      gotoxy(x,y);
      EditLine(Input,ZCur,x,y,4,Xit,False,0);
      v:=valu(input);
      if (v<1) or (v>1000) then v:=CNF^.usertime[n];
      SetOne(n,v)
    end;

    Function Getn(txt:Str80):integer;
    var Xit,input:Str80;
        ZCur:Byte;
    begin
      gotoxy (1,23);
      write (txt,': ');
      clreol;
      Input:='';
      EditLine(Input,ZCur,WhereX,WhereY,4,Xit,False,0);
      getn:=valu(input)
    end;

    function getlvl (txt:Str80):integer;
    var n:integer;
    begin
      n:=getn(txt);
      if (n<1) or (n>100) then n:=0;
      getlvl:=n
    end;

    procedure pattern;
    var st,en,ba,se,cn:integer;
    begin
      st:=getlvl('Starting level of pattern'); if st=0 then exit;
      en:=getlvl ('Ending level of pattern');  if en<st then exit;
      ba:=getn ('Time for level '+strr(st));   if (ba<1) or (ba>1000) then exit;
      se:=getn ('Additional time per level');  if (se<0) or (se>1000) then exit;
      cn:=st;
      repeat
        setone (cn,ba);
        if ba+se<1000 then ba:=ba+se else ba:=1000;
        cn:=cn+1
      until cn>en
    end;

  var k:char;
     Cur:Byte;
     Xit:String[2];
  begin
    refresh;
    repeat
      repeat
        Input:='';
        GotoXy(1,24);
        TextColor(7);
        write('[#] Change / [P]attern / [Q]uit: ');
        EditLine(Input,Cur,WhereX,WhereY,3,Xit,False,0);
      until length(input)>0;
      k:=upcase(input[1]);
      n:=valu(input);
      if (n>=1) and (n<=100) then getone(n) else
        case k of
          'P':Pattern;
        end
    until k='Q';
    WriteConfig;
  end;

Procedure SysFiles;
Var Min,Log,Mult,Percent,Pts:String;
    Cmnt,Zip,UsePts:string[3];
Begin
  With Cnf^ Do
  Begin
    Min:=Int_To_Str(MinKBFree);
    Log:=Int_To_Str(LogSize);
    Mult:=Int_To_Str(UploadMultiple);
    Percent:=int_To_Str(PercentBack);
    Pts:=Int_To_Str(AutoPts);
    Cmnt:=Boo_To_Str(UseComment);
    Zip:=Boo_To_Str(AddCmtToZip);
    Usepts:=Boo_To_Str(UsePtsComp);
    Add_Field(1,43,3,10,FilesOpen,'When Files are Open',23,15);
    Add_Field(2,43,4,10,FilesClosed,'When Files are Closed',23,15);
    Add_Field(3,43,5,3,Cmnt,'Use .ZIP Comment <COMMENT.TXT>',23,15);
    Add_Field(4,43,6,3,Zip,'Add File Comment to Uploads',23,15);
    Add_Field(5,43,7,12,IncFile,'File to add to uploaded files',23,15);
    Add_Field(6,43,8,5,Min,'Minimum K free for uploads',23,15);
    Add_Field(7,43,9,5,Log,'Transfer Log Size',23,15);
    Add_Field(8,43,10,2,Mult,'Upload Point Multiple',23,15);
    Add_Field(9,43,11,3,Pts,'Number of points per 10k upload',23,15);
    Add_Field(10,43,12,3,Percent,'Percent of time back for uploads',23,15);
    Add_Field(11,43,13,3,UsePts,'Yes to use AutoPoint Compensation',23,15);
  End;
  FastWrite(26,3,9,'Files Open: ');
  FastWrite(26,4,9,'Files Closed: ');
  FastWrite(26,5,9,'ZIP Comments: ');
  FastWrite(26,6,9,'Include Comment: ');
  FastWrite(26,7,9,'Comment File: ');
  FastWrite(26,8,9,'Min. KB Free: ');
  FastWrite(26,9,9,'Log Size: ');
  FastWrite(26,10,9,'Point Multiple: ');
  FastWrite(26,11,9,'Points Per 10k: ');
  FastWrite(26,12,9,'Percent Back: ');
  FastWrite(26,13,9,'Compensation: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    MinKBFree:=Valu(Min);
    LogSize:=Valu(Log);
    UploadMultiple:=Valu(Mult);
    PercentBack:=Valu(Percent);
    AutoPts:=Valu(Pts);
    UseComment:=Str_To_Boo(Cmnt);
    AddCmtToZip:=Str_To_Boo(Zip);
    UsePtsComp:=Str_To_Boo(UsePts);
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SysMessages;
Var Use:string[3];
    MsgPt,Confs,Anon,Post:String;
Begin
  With Cnf^ Do
  Begin
    Anon:=Int_To_Str(AnonymousLvl);
    Post:=Int_To_Str(PostLvl);
    Use:=Boo_To_Str(UseNewScanPrompt);
    MsgPt:=Real_To_Str(MsgPts,1);
    Add_Field(7,44,3,5,Post,'Default Post Level',23,15);
    Add_Field(8,44,4,5,Anon,'Anonymouse Level',23,15);
    Add_Field(9,44,5,3,Use,'Yes to use NewScan Prompts',23,15);
    Add_Field(10,44,6,5,MsgPt,'File Points granted for a post',23,15);
  End;
  FastWrite(26,3,9,'Post Level: ');
  FastWrite(26,4,9,'Anon. Level:');
  FastWrite(26,5,9,'NewScan Prompts: ');
  FastWrite(26,6,9,'Message Value: ');
  Display_Fields(0);
  Save:=EditFields(0);
  If Save=#27 Then
  With Cnf^ Do
  Begin
    AnonymousLvl:=Valu(Anon);
    PostLvl:=Valu(Post);
    UseNewScanPrompt:=Str_To_Boo(Use);
{    MsgPts:=Str_to_Real(MsgPt);}
    WriteConfig;
  End;
  CursorOff;
End;

Procedure SetupMainMenu;
Begin
  With Bars Do
  Begin
    MenuName:='';
    Choice[1]:=' System Info          ';
    Choice[2]:=' System Directories   ';
    Choice[3]:=' Passwords            ';
    Choice[4]:=' Modem SetUp          ';
    Choice[5]:=' Misc. Options        ';
    Choice[6]:=' Matrix Set-Up        ';
    Choice[7]:=' Define Colors        ';
    Choice[8]:=' Logon SetUp          ';
    Choice[9]:=' New User Voting      ';
    Choice[10]:=' User Defaults        ';
    Choice[11]:=' Info-Forms           ';
    Choice[12]:=' Access Levels        ';
    Choice[13]:=' Time Limits          ';
    Choice[14]:=' File Section         ';
    Choice[15]:=' Message Section      ';
    Choice[16]:=' String Editor        ';
    Choice[17]:=' Event Editor         ';
    Choice[18]:=' Profile Editor       ';
    Choice[19]:=' Exit To DOS          ';
    NumChoices:=19;
    Defchoice:=LastBar;
    KeyCmds:='ABCDEFGHIJKLMNOPQR'+Chr(27);
  End;
End;

Procedure RunProtEdit;
Begin
  Exec('PROTEDIT.EXE','');
End;

Procedure VersionScreen;
Begin
  ClrScr;
  Writeln('|',VerStr,'|',MaxNodes);
  Writeln(PullVerNum);
  Writeln(PullVerDate);
  Writeln(ConfigVerNum);
  Writeln(ConfigVerDate);
  Writeln(iCEIOVerNum);
  Writeln(ICEIOVerDate);
  Writeln(ProVerNum);
  Writeln(ProVerDate);
  Writeln(EventVerNum);
  Writeln(EventVerDate);
  Writeln('Max Avail: ',MaxAvail);
  Writeln('Mem Avail: ',MemAvail);
  Repeat Until KeyPressed;
  Readkey;
  WriteConfig;
End;

Begin
  SaveScreen;
  Intro;
  LangSet:=0;
  LastBar:=1;
  Quit:=False;
  If (Not Exist('CONFIG.DAT')) Then SetUpConfig Else ReadConfig;
  Repeat
    BoxIt;
    SetupMainMenu;
    CursorOff;
    Pick:=MenuBar(1,2,2,3,0,15,1,3,1,0,Bars);
    If Pick<>255 then LastBar:=Pick else LastBar:=1;
    ReadConfig;
    Case Pick Of
      1:SysInfo;
      2:SysDirectories;
      3:SysPasswords;
      4:SysModemSetup;
      5:SysMisc1;
      6:SysMatrix;
      7:DoAttrib;
      8:SysLogin;
      9:SysNUV;
     10:SysDef;
     11:SysInfoForms;
     12:SysLevels;
     13:DoUserTime;
     14:SysFiles;
     15:SysMessages;
     16:Strings;
     17:EventEditor;
     18:ProfileEditor;
     19,20:Quit:=True;
    255:VersionScreen;
    End;
  Until Quit=True;
  CursorON;
  ReStoreScreen;
End.