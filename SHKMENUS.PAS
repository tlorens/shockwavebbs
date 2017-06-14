{
  iB * 10/19/95 - If you see this, you are in the wrong file!
                  Don't fucking edit this file until I'm done!
  iB * 03/07/96 - Now processes EVERY prompt commands, and AUTO run
                  commands.
  iB * 04/03/97 - Door commands added.
  iB * 05/18/97 - AUTO Menus now execute, unlimited deep.
}
{$I+,D-,L-}
Unit ShkMenus;

Interface

Uses Records;

Procedure LoadMenu(MenuFile:String);
Procedure RunCommand(C:CommandRec);
Function MenuPW(MenuFile:String):Boolean;
Procedure RunMenu;
Function GnuMenu(Prmt:Str80; ANSiScr:Str10):String;

Implementation

Uses Dos,OpCrt,Vars,IO,CNFGrec,GenSubs,Display,ASMX,Windows,
     User,           { UserRec Routines }
     Messages,MSub1, { Message Routines }
     Filexfer,FSubs, { File Routines }
     EMail,          { Email Routines }
     Misc,           { Misc Routines (Code Based) }
     GetLogin,       { Matrix/Login routines }
     Subs,           { Misc Routines (User Based) }
     SysOp,MiniDos,  { SysOp Routines }
     ShkScrpt,       { Scripting Routines }
     Doors,          { Door Routines }
     IRC,            { MultiNode Chat, IRC style }
     UConfig;        { User Configuration Routines }
     

Var TmpCmd:CommandRec;
    RanAutos:Boolean;
    FMenuCmd:File Of CommandRec; { Removed from global VAR.PAS list }
    FCurMenu:File Of MenuRec;    { Removed from global VAR.PAS list }
    UseBarMenu:Boolean;

Function GnuMenu(Prmt:Str80; ANSiScr:Str10):String;
Begin
  GnuMenu:='';
  Input[0]:=#0;
  Input:=Prompt(80,Prmt+' ',Urec^.MenuType=1);
    If Length(Input)>0 Then GnuMenu:=UpString(Input);
End;

Procedure RunEvery(MenuFile:String);  { Run Commands Automatically }
Begin
  Reset(FMenuCmd);
  While Not EOF(FMenuCmd) Do
  Begin
    Read(FMenuCmd,TmpCmd);
    If (Match(TmpCmd.Param2,'EVERY')) OR (Match(TmpCmd.Param1,'EVERY')) Then RunCommand(TmpCmd);
  End;
End;

Procedure RunAutos(MenuFile:String);  { Run Commands Automatically }
Begin
  Reset(FMenuCmd);
  While (Not EOF(FMenuCmd)) Do
  Begin
    Read(FMenuCmd,TmpCmd);
    If (Match(TmpCmd.Param2,'AUTO')) OR (Match(TmpCmd.Param1,'AUTO')) Then 
    Begin
      RanAutos:=True;
      RunCommand(TmpCmd);
    End;
  End;
End;

Procedure LoadMenu(MenuFile:String);
Begin
  If Not Exist(CNF^.MenuDataDir+MenuFile+'.DAT') Then
  Begin
    AColor(12);
    Println('Menu .DAT File: '+MenuFile+' not found!');
    AColor(7);
    Delay(2000);
    Halt(2);
  End;

  If Not Exist(CNF^.MenuDataDir+MenuFile+'.MNU') Then
  Begin
    AColor(12);
    Println('Menu .MNU File: '+MenuFile+' not found!');
    AColor(7);
    Delay(2000);
    Halt(2);
  End;

  Assign(FMenuCmd,CNF^.MenuDataDir+MenuFile+'.DAT');
  Reset(FMenuCmd);

  Assign(FCurMenu,CNF^.MenuDataDir+MenuFile+'.MNU');
  Reset(FCurMenu);
  Read(FCurMenu,CurMenu);
  Close(FCurMenu);
End;

Function MenuPW(MenuFile:String):Boolean;
Begin
  MenuPW:=False;
  If PrevMenuFile<>CurMenuFile Then
  Begin
    MenuPW:=False;
    LoadMenu(MenuFile);
    Close(FMenuCmd);
    If GetAccess(CurMenu.ACFlag) Then
    If Carrier Then MenuPW:=GetPassword(CurMenu.Password) else MenuPW:=True;
  End Else MenuPW:=True;
End;

Procedure RunCommand(C:CommandRec);
Var Key:String[5];
    UCh:Char;
    P1,P2:Str80;
    CmdNum:Byte;

Begin
  If (Not GetAccess(C.FlagStr)) Then Exit;

  P1 :=C.Param1;
  P2 :=C.Param2;
  Key:=C.Comm;

  WriteLog(6,1,'Cmd '+C.Comm+' '+C.Param1+' '+C.Param2);
(************************* Matrix Login Commands **********************)
  If Key='LOGIN' Then Begin
                        If Length(P1)=0 Then 
                        If Length(CurUFile)>0 Then P1:=CurUFile else P1:='USERS';
                        If Not Exist(CNF^.DataDir+P1+'.LST') Then CheckUsers(P1);
                        CurUFile:=P1;
                        MatrixLogin(P1);
                      End;
  If Key='APPLY' Then Begin
                        If Length(P1)=0 Then 
                         If Length(CurUFile)>0 Then P1:=CurUFile else P1:='USERS';
                         If Not Exist(CNF^.DataDir+P1+'.LST') Then CheckUsers(P1);
                         MatrixApply(P1);
                       End;

   If Key='CHECK' Then Begin
                        If Length(P1)=0 Then 
                         If Length(CurUFile)>0 Then P1:=CurUFile else P1:='USERS';
                         If Not Exist(CNF^.DataDir+P1+'.LST') Then CheckUsers(P1);
                         MatrixCheck(P1);
                       End;

(**********************************************************************)

(********************** General BBS Commands **************************)

  If Key='SCRPT' Then RunScript(P1); { called from script unit }   

  If Key='@PREV' Then CurMenuFile:=PrevMenuFile;

  If Key='@BARS' Then Begin
                        PrevMenuFile:=CurMenuFile;
                        RanAutos:=False;
                        If (Match(P1,'AUTO')) Or (Match(P1,'EVERY')) Then
                        CurMenuFile:=P2 else CurMenuFile:=P1;
                        UseBarMenu:=True;
                      End;

  If Key='@MENU' Then Begin
                        PrevMenuFile:=CurMenuFile;
                        RanAutos:=False;
                        If (Match(P1,'AUTO')) Or (Match(P1,'EVERY')) Then
                        CurMenuFile:=P2 else CurMenuFile:=P1;
                        UseBarMenu:=False;
                      End;

   If Key='@EXEC' Then
   Begin
     SwapVectors;
     Exec(getenv('COMSPEC'), '/C '+P1);
     SwapVectors;
   End;

   If Key='@DOOR' Then 
   Begin
     If (P1='AUTO') Then Door(Valu(P2)) Else Door(Valu(P1));
   End;

   If Key='RDOOR' Then SWDone(31);

   If Key='ADOOR' Then AddDoor;
   If Key='EDOOR' Then EdtDoor(P2);
   If Key='LDOOR' Then LstDoor(P2);
   If Key='DDOOR' Then DelDoor(P2);

   If Key='TBANK' Then TimeBank(P1);

   If Key='GDBYE' Then Begin
                         If (Match(P1,'ASK')) or (Match(P2,'ASK')) Then
                         Begin
                           If YeaNa(MyStr^.LogOffPrompt,False) Then
                           Begin
                             Close(FMenuCmd);
                             WriteUser(Urec^);
                             LogOff(0);
                           End;
                         End Else
                         Begin
                           Close(FMenuCmd);
                           WriteUser(Urec^);
                           LogOff(0);
                         End;
                       End;
   If Key='ULIST' Then ListUsers(P1,P2);
   If Key='TWALL' Then Wall(P1,P2);
   If Key='EXPRT' Then Urec^.Expert:=Not Urec^.Expert;
   If Key='PASWD' Then ChangePWD;
   If Key='RLINE' Then MCiWriteln(RndLiner(P1));
   If Key='RNBBS' Then MCiWriteln(RndBBSAd(P1));
   If Key='AMESG' Then If Match(P1,'WRITE') Then SaveAutoMsg Else ReadAutoMsg;
   If Key='@HELP' Then If Exist(CurMenu.ANSiF) Then PrintFile(CurMenu.ANSiF) Else PrintMenu(C);


   If Key='REGST' Then
   Begin
     Cls;
     Println('Version       : '+Strr(Revision)+' þ '+BuildDate);
     Println('Registered to : '+CNF^.SysOpName);
     Println('System Name   : '+CNF^.FullSysName);
     Println('Serial Number : '+CNF^.RegNumber);
   End;

   If Key='FDBAK' Then LeaveFeedback(P1);
   If Key='IRC' Then IRCChat;
   If Key='SCHAT' Then SummonSysOp;
   If Key='WHOIS' Then WhosOnLine;
   If Key='UPAGE' Then ;
{   If Key='CTOGG' Then If CNF^.MultiNode Then ToggleAvailable(YeaNa('Wish to be available for chat',True));}
   If Key='CONF1' Then CurConf:=1;
   If Key='CONF2' Then CurConf:=2;
   If Key='CONF3' Then CurConf:=3;
   If Key='CONF4' Then CurConf:=4;
   If Key='CONF5' Then CurConf:=5;
   If Key='CONFX' Then Begin
                         If Match(P1,'AUTO') Then CurConf:=Valu(P2)
                           Else 
                         If Match(P2,'AUTO') Then CurConf:=Valu(P1)
                           Else CurConf:=Valu(P1);
                       End;
                       
(*
   If Key='10MSG' Then TopUsers(1);
   If Key='10XFR' Then TopUsers(2);
   If Key='MCHAT' Then SummonSysOp;
   If Key='INFOF' Then Get_InfoForm;
   If Key='BULLS' Then PrintNews; {SysBulletins}
   If Key='NWUSV' Then CheckVot;
   If Key='MVOTE' Then VotingBooth(False);
   If Key='CALLS' Then ShowLastCallers;
   If Key='SETCL' Then SetLastCall;
*)


(**************************************************************************)

(*************************** SysOp Menu Commands **************************)
   If Key='EUSER' Then If (Length(P1)<>0) Then EditUsers(P1) Else
                       If (Length(P2)<>0) Then EditUsers(P2) Else EditUsers(CurUFile);
   If Key='MSDOS' Then LittleDos;
   If Key='FEEDB' Then ReadFeedBack;
   If Key='SYSLG' Then ReadSysLog;
   If Key='DELSY' Then DeleteSysLog;
   If Key='BLIST' Then ViewBlackList;
   If Key='MAKEU' Then MakeUser;
   If Key='!@!@!' then FixRec(Valu(P1));
   If Key='ADDBL' Then AddToBlackList('');
   If Key='DELBL' Then RemoveFromBlackList;
   If Key='LSTBL' Then ViewBlackList;

(* If Key='SPECS' Then EditOldSpecs;
   If Key='DELER' Then DelErrLog;
   If Key='FINFO' Then InfoFormHunt;
   If Key='AINFO' Then ShowAllForms;
   If Key='SHWSY' Then ShowAllSysOps;
   If Key='RINFO' Then RemoveAllForms;
   If Key='ZUSRS' Then ZapSpecifiedUsers;
*)
(***************************************************************************)

(**************************** Message Area Commands ************************)
   If Key='!ADEL' Then AutoDelete(0,CurConf,CurMsgAreaName,10);
   If Key='MAREA' Then SelectMArea;
   If Key='MPOST' Then PostMessage;
   If Key='MREAD' Then ReadMessages;
   If Key='MKILL' Then DeleteMessages;
   If Key='MAREX' Then Begin
                         If (Match(P1,'AUTO')) or (Match(P1,'EVERY')) Then SetMArea(Valu(P2),False) 
                           Else 
                         If (Match(P2,'AUTO')) or (Match(P2,'EVERY')) Then SetMArea(Valu(P1),False) 
                           Else 
                           SetMArea(Valu(P1),False);
                       End;
   If Key='MNEWS' Then If (Match(P1,'ALL') or Match(P2,'ALL'))
                         Then MsgNewScanAll Else NewScanArea;
   If Key='MEDIT' Then EditMessage;
   If Key='MPREV' Then PrvArea;
   If Key='MNEXT' Then NxtArea;
(*
   If Key='LSTIT' Then ListBuls;
*)
(***************************************************************************)

(***************************** Message SysOp Commands **********************)
   If Key='BEDIT' Then EditMsgArea(False);
   If Key='KILLM' Then DeleteArea;
   If Key='MAKEA' THen AddMarea;
(*
   If Key='SBRDS' Then sortboards;
   If Key='MBULL' Then movebulletin;
   If Key='OBRDS' Then orderboards;
   If Key='MACCS' Then listaccess;
   If Key='MADEL' Then MassDelete;
*)
(**************************************************************************)

(**************************** File Area Commands **************************)
   If Key='FAREA' Then SelectXArea;
   If Key='FAREX' Then Begin
                         If Match(P1,'AUTO') Then SetXArea(Valu(P2),False)
                           Else
                         If Match(P2,'AUTO') Then SetXArea(Valu(P1),False)
                           Else SetXArea(Valu(P1),False);
                       End;
   If Key='FNEXT' Then NextFArea;
   If Key='FPREV' Then PrevFArea;
   If Key='FLIST' Then ListFiles;
   If Key='DNLOD' Then Begin
                         If Match(P1,'AUTO') Then Download(P2) Else
                         If Match(P2,'AUTO') Then Download(P1) Else
                         Download(P1);
                       End;
   If Key='UPLOD' Then Begin
                         If Match(P1,'AUTO') Then Upload(P2) Else
                         If Match(P2,'AUTO') Then Upload(P1) Else
                         Upload(P1);
                       End;

   If Key='LSBAT' Then Listbatch;
   If Key='RMBAT' Then RemoveFromBatch;
   If Key='CLBAT' Then ClearBatch;
   If Key='FNEWS' Then If (Match(P1,'ALL') or Match(P2,'ALL'))
                         Then FNewScanAll Else FNewScanArea;
(*
   If Key='FSTAT' Then YourUDStatus;
   If Key='FSRCH' Then SearchFile;

   If Key='FVIEW' Then ListArchive;
   If Key='FWIDE' Then ListFiles(True);
   If Key='FTYPE' Then TypeFile;
*)
(**************************************************************************)

(***************************** File SysOp Commands ************************)
   If Key='ADDFL' Then AddFile('',False);
   If Key='ADD**' Then ManAddFiles;
   If Key='MAS**' Then MassAddFiles;
   If Key='DELFL' Then RemoveFile;
   If Key='KFARA' Then DeleteArea;
   If Key='FEDIT' Then XAreaEditScr(False);
   If Key='FAADD' Then XAreaEditScr(True);
(*
   If Key='CHNFL' Then changef;
   If Key='FLDIR' Then directory;
   If Key='FEDIT' Then modarea;
   If Key='NEWSC' Then NewFiles;
   If Key='SORTF' Then sortarea(True);
   If Key='MOVEF' Then movefile;
   If Key='XACCS' Then listxmodem;
   If Key='OAREA' Then reorderareas;
   If Key='RNAMF' Then renamefile;
   If Key='CNARE' Then getarea;
   If Key='INDIZ' Then ImportID;
   If Key='CDROM' Then CD_AddFiles;
   IF Key='REMOV' Then RemoveOffLine(False,True);
   If Key='MOV**' Then MultMoveFile;
   If Key='REM**' Then MassRemoveOffline;
   If Key='SRT**' Then SortArea(False);
*)
(**********************************************************************)

(**************************** E-Mail Menu Commands *************************)
  If Key='ESEND' Then SendEmail;
  If Key='EREAD' Then ReadEMail;
  If Key='ENEWS' Then NewScanEMail;
  If Key='EKILL' Then DeleteEMail;
  (*
   If Key='ELIST' Then
   Begin
     Readcatalogs;
     ListAllMail;
   End;
   If Key='EDOUT' Then KillOutGoing;
   If Key='ECOPY' Then CopyMail;
   If Key='EFORE' Then ForwardMail;
*)
(***************************************************************************)

(**************************** BBS List Commands ****************************)

  If Key='BBADD' Then AddBBS(P1,P2) Else
  If Key='BBLST' Then BBSLister(P1,P2) Else
  If Key='BBDEL' Then DelBBS(P1,P2) Else
  If Key='BBEDT' Then EditBBS(P1,P2) Else
(*
  If Key='BCHNG' Then
*)
(**************************************************************************)

(************************* User Self Configuration ************************)
  If Key='UC8BT' Then Edit8BitChars Else
  If Key='UCNOT' Then EditUserNote Else
  If Key='UCSCR' Then EditScreenLen Else
  If Key='UCMHD' Then EditMsgHdrType Else
  If Key='UCEMU' Then EditEmulation Else
  If Key='UCFIL' Then EditFileListing Else
{  Colors }
  If Key='UCREG' Then EditColors(Urec^.RegularColor,'1') Else
  If Key='UCSTS' Then EditColors(Urec^.StatColor,'2') Else
  If Key='UCPMT' Then EditColors(Urec^.PromptColor,'3') Else
  If Key='UCINP' Then EditColors(Urec^.InputColor,'4') Else
  If Key='UCINS' Then EditColors(Urec^.InsideColor,'5') Else
  If Key='UCBOX' Then EditColors(Urec^.BoxColor,'6') Else
  If Key='UCMSC' Then EditColors(Urec^.MiscColor,'7') Else
  If Key='UCCMD' Then EditColors(Urec^.CmdColor,'8') Else
  If Key='UCSIG' Then EditAutoSig Else
  If Key='UCHOT' Then EditMenuType Else
  If Key='UTEST' Then CustomUConfig Else

(**************************************************************************)


(*******************  Misc Commands for st00pid shit **********************)
   If Key='CANSI' Then DetectANSi Else
   If Key='CKRIP' Then DetectRiP Else
   If Key='CHSHK' Then DetectShckTerm Else
   If Key='!ANSI' Then Emulation:=1 Else
   If Key='!RIP'  Then Emulation:=3 Else
   If Key='!MONO' Then Emulation:=2 Else
   If Key='!NONE' Then Emulation:=0 Else
   If Key='GLANG' Then GetLanguage(0) Else
   If Key='!LANG' Then GetLanguage(1) Else
   If Key='LANGX' Then GetLanguage(Valu(P1)) Else
   If Key='BRDR1' Then SetBorder(36) Else { Red }
   If Key='BRDR0' Then SetBorder(0) Else { Black }
   If Key='BRDRX' Then SetBorder(Valu(P1)) Else
   If Key='BEEP1' Then Begin Sound(2000); Delay(500); NoSound; End Else
   If Key='BEEP2' Then Begin Sound(1500); Delay(500); NoSound; End Else
   If Key='BEEP3' Then Begin Sound(1000); Delay(500); NoSound; End Else
   If Key='BEEPX' Then Begin Sound(Valu(P1)); Delay(Valu(P2)); NoSound; End Else
   If Key='CLEOL' Then ClsEol Else
   If Key='CLEAR' Then Cls Else
   If Key='PRINT' Then If Exist(CNF^.MenuDir+P1) Then PrintFile(CNF^.MenuDir+P1) Else
   If Key='WRITE' Then Println(P1) Else
   If Key='PAUSE' Then Begin MCIWrite(P1); GetChar(Input[1]); End Else
   If Key='MOVXY' Then GotoXY(Valu(P1),Valu(P2)) Else
   If Key='RANDM' Then Begin
                        Randomize;
                        PrintFile(CNF^.MenuDir+P1+Strr(Random(Valu(P2))));
                      End Else
(*************************************************************************)

(*************** SYSTEM CONTROL COMMANDS - Use with CAUTION **************)
   If Key='!HALT' Then Halt(255);
   If Key='!HLTX' Then Halt(Valu(P1));
   If Key='!LOCK' Then LockKeys;
   If Key='!UNLK' Then UnLockKeys;
   If Key='!LKSY' Then Begin SetCBreak(False); LockKeys; Repeat Until False=True; End;
   If Key='!CLIK' Then HangUp;
   If Key='WBOOT' Then WarmBoot;
   If Key='CBOOT' Then ColdBoot;
   If Key='CURS0' Then CursorOff;
   If Key='CURS1' Then CursorOn;
   If Key='GUEST' Then Begin
                         FindUser(P1,UNum);
                         SeekUFile(UNum);
                         ReadUser(Urec^);
                       End;
   If Key='!NAME' Then Urec^.Handle:=P1;       { Neato account fuck stuff  }
   If Key='!MLVL' Then Urec^.Lvl:=Valu(P1);    {   ""                ""    }
   If Key='!XLVL' Then Urec^.XLvL:=Valu(P1);   {   ""                ""    }
   If Key='!TIME' Then Urec^.TimeLeft:=Valu(P1);{  ""                ""    }
   If Key='!BAUD' Then BaudRate:=Valu(P1);
   If Key='!USER' Then SwitchUser;
   If Key='PAGME' Then PageMe(P1,P2);
(**********************************************************************)
   If Key='|SYSN' Then Edit(CNF^.FullSysName,WhereX,WhereY,40,False);
   If Key='|SYSO' Then Edit(CNF^.FullSysName,WhereX,WhereY,40,False);
   If Key='|AUTL' Then Edit(CNF^.FullSysName,WhereX,WhereY,40,False);
   If Key='|PRIV' Then ;
   If Key='|VIDO' Then ;
   If Key='|SNOW' Then ;
   If Key='|BELL' Then ;
   If Key='|UMES' Then ;
   If Key='|STAT' Then ;

   If Key='|SDIR' Then Edit(CNF^.SysDir,WhereX,WhereY,40,False);
   If Key='|MDIR' Then Edit(CNF^.MsgDir,WhereX,WhereY,40,False);
   If Key='|UDIR' Then Edit(CNF^.UploadDIR,WhereX,WhereY,40,False);
   If Key='|BDIR' Then Edit(CNF^.SysLogDir,WhereX,WhereY,40,False);
   If Key='|SWAP' Then Edit(CNF^.SwapDir,WhereX,WhereY,40,False);
   If Key='|MENU' Then Edit(CNF^.MenuDir,WhereX,WhereY,40,False);
   If Key='|DOOR' Then Edit(CNF^.DoorDir,WhereX,WhereY,40,False);
   If Key='|WORK' Then Edit(CNF^.WorkDir,WhereX,WhereY,40,False);
   If Key='|NDIR' Then Edit(CNF^.NetDir,WhereX,WhereY,40,False);
   If Key='|DSZL' Then Edit(CNF^.DszLog,WhereX,WhereY,40,False);
   If Key='|DATA' Then Edit(CNF^.DataDir,WhereX,WhereY,40,False);
   If Key='|FMAL' Then Edit(CNF^.FileMailDir,WhereX,WhereY,40,False);
   If Key='|MDAT' Then Edit(CNF^.MenuDataDir,WhereX,WhereY,40,False);

   If Key='|PWST' Then Edit(CNF^.PWString,WhereX,WhereY,40,False);
   If Key='|CTPW' Then Edit(CNF^.ChatPW,WhereX,WhereY,40,False);
   If Key='|PORT' Then ;
   If Key='|INIT' Then Edit(CNF^.ModemINITStr,WhereX,WhereY,40,False);
   If Key='|HNUP' Then Edit(CNF^.ModemHangUpStr,WhereX,WhereY,40,False);
   If Key='|BAUD' Then ;
   If Key='|MINI' Then ;
   If Key='|MAXT' Then ;
   If Key='|CHTH' Then ;
   If Key='|CHTG' Then ;
   If Key='|TMOT' Then ;
   If Key='|MULT' Then ;
   If Key='|NODE' Then ;
   If Key='|NORM' Then ;
   If Key='|TOPC' Then ;
   If Key='|LOCL' Then ;
   If Key='|LINE' Then ;
   If Key='|SBAR' Then ;
   If Key='|DEFS' Then ;
   If Key='|' Then ;
End;

Procedure RunMenu;
Var Q:String;
   
Begin
  UseBarMenu:=False;
  If Length(Urec^.Handle)>0 Then WriteUser(Urec^);  { to save timeleft and misc var's }
  Repeat
    If HungUpOn Then HangUp;
    Q:='';
    If MenuPW(CurMenuFile) Then
    Begin
      Repeat (* For Auto MENU's Unlimited execution *)
        TmpStr:=CurMenuFile;
        LoadMenu(CurMenuFile);
        WriteLog(6,1,'RunMenu: '+CurMenuFile);
        {ResetNode(Urec^.Handle,'Menu: '+CurMenuFile,Available4Chat);}
        If (Not RanAutos) Then RunAutos(CurMenuFile);
      Until Match(CurMenuFile,TmpStr); (* For Auto MENU's Unlimited execution *)

      RunEvery(CurMenuFile);

      If UseBarMenu Then
      Begin
        Close(FMenuCmd);
        LoadMenu(CurMenuFile);
        New(Menubarz);
        If Exist(CNF^.MenuDir+CurMenu.ANSiF) Then PrintFile(CNF^.MenuDir+CurMenu.ANSiF);
        Q:=Barz(MenuBarz^,CurMenuFile+'.BAR',True);
        Dispose(Menubarz);
        Cls;
      End
     Else
      Q:=GnuMenu(CurMenu.Prompt,CurMenu.ANSiF);

      Reset(FMenuCmd);
      While (Not EOF(FMenuCmd)) Do
      Begin
        Read(FMenuCmd,TmpCmd);
        If (Match(TmpCmd.Key,Q)) Then RunCommand(TmpCmd);
      End;
      Close(FMenuCmd);
    End else CurmenuFile:=PrevMenuFile;
  Until (False=True) Or (HungUpon);
End;


End.
