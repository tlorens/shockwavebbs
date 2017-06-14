{$I+}
Program UserConvert;

Uses Dos,Crt,Records,OldRec,GenSubs;

Var
    Urec:Userrec;
    Old :File of OldUserrec;
    OldURec:OldUserRec;
    Update:UserRec;
    New:File of Userrec;
    Index:File of Str25;
    ICE,X,Cnt:Integer;
    C:Char;
    Source,target:String;
    FFile:File;

Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ User List Convertion ³ ');
  TextColor(7); Write('ShockWavE Pro BBS Software v',VersionNum); ClrEol;
  Writeln;
  TextBackGround(0);
  Window(1,2,80,24);
  Writeln;
  Writeln('Hit [ESC] to quit or any key to continue');
  If C=#27 then halt; Writeln;
  Writeln('Creating BackUp: Renaming users list file: USERS.LST -to-> USERS.CVT');
  If Exist('USERS.CVT') Then
  Begin
    Assign(FFile,'USERS.CVT');
    Erase(Ffile);
  End;
  Assign(FFILE,'USERS.LST');
  Rename(FFILE,'USERS.CVT');

  Writeln('Creating new users list file: USERS.NEW');
  Assign(NEW,'USERS.NEW');
  ReWrite(NEW);

  Writeln('Reading users list file: USERS.CVT');
  Assign(OLD,'USERS.CVT');
  Reset(OLD);
  Seek(Old,1);
  Seek(New,1);

While Not Eof(OLD) Do
Begin
  Read(OLD,OldUrec);
{  If OldUrec.UserVersion}
  With OldUrec do
  Begin
   { Inc(UserVersion);}
    Update.UserVersion :=UserVersion;       (* Last Revision Number *)
    Update.handle   :=handle;               (* Users Handle *)
    Update.Gender   :=Gender;                     (* Users Gender *)
    Update.Age:=Age;                        (* Users Age *)
    Update.realname :=Realname;             (* Users Real Name *)
    Update.password[1]:=Password[1];        (* Users Password *)
    For iCE:=2 to 5 do Update.Password[ICE]:='';
    Update.phone[1] :=phone[1];             (* Users Phone Number *)
    For iCE:=2 to 5 do Update.Phone[ICE]:='';
    Update.LastCall :=LastCall;             (* Last Call date in DATEPACK form *)
    Update.NumCalls :=NumCalls;             (* Total Calls *)
    Update.timeLeft:=TimeLeft;              (* Time left today *)
    Update.Posts    :=Posts;                (* Messages posted *)
    Update.UseCNet :=False;                (* Cnet type file threading *)
    Update.Expert   :=False;                (* Expert Users? *)
    Update.uploads  :=Uploads;              (* Uploads *)
    Update.downloads:=Downloads;            (* Downloads *)
    Update.totaltime:=TotalTime;            (* Total Time spent on system by user *)
    Update.XLvl     :=Xlvl;                 (* File Level *)
    Update.LvL      :=LvL;                  (* Main Access Level *)
    Update.AccessFlags:=AccessFlags;
    Update.FilePts  :=FilePts;              (* File Points *)
    Update.Regularcolor:=7;
    Update.Promptcolor:=9;
    Update.Statcolor:=11;
    Update.Inputcolor:=3;
    Update.CmdColor:=15;
    Update.MiscColor:=8;
    Update.InsideColor:=9;
    Update.BoxColor:=8;

    {Update.regularcolor:=regularcolor;      (* The following are the users colors. *)
    Update.promptcolor:=promptColor;
    Update.statcolor:=statcolor;
    Update.inputcolor:=inputcolor;
    Update.BoxColor:=BoxColor;
    Update.InSideColor:=InSideColor;
    Update.CmdColor:=CmdColor;
    Update.MiscColor:=MiscColor;}
    Update.Scrnlength:=ScrnLength;
    Update.newscanconfig:=newscanconfig;   (* Various stuff dealing with message
                                                    bases. Do not mess with these. *)
    Update.access1  :=access1;
    Update.access2  :=access2;
    Update.usernote :=Usernote;            (* Account Note [Public] *)
    Update.upk      :=upk;                 (* Upload K *)
    Update.DownK    :=DownK;               (* Download K *)
    Update.lastposts:=lastposts;           (* Last total messages in system *)
    Update.lastfiles:=lastfiles;           (* Last total files in system *)
    For Cnt:=1 to 255 do Update.lastread[cnt]:=lastread[cnt]; (* Message Stuff *)
    Update.expdate  :=expdate;             (* Expiration date in DATEPACK form *)
    Update.timebank :=Timebank;            (* Time stored in Time Bank *)
    Update.lastcallnum:=lastcallnum;       (* Last Caller Number *)
    Update.Up_Down_Ratio:=Up_Down_Ratio;   (* Individual Upload/Download Ratio *)
    Update.Up_Down_K_Ratio:=Up_Down_K_Ratio; (* Individual U/D K Ratio *)
    Update.pcr  :=pcr;                     (* Individual Post/Call Ratio *)
    Update.MenuType :=MenuType;            (* 0=Normal ansi, 1=Pull Down Windows *)
    Update.timelimit:=Timelimit;           (* Daily time limit (0 means normal) *)
    Update.LastMConf :=lastMconf;            (* Last Conference user was in *)
    Update.LastXconf :=LastMconf;
    Update.SysopNote:=sysopnote;           (* Special Sysop Note *)
    Update.NewVoteYes:=NewVoteYes;
    Update.NewVoteNo:=NewVoteNo;
    Update.MsgHeader:=MsgHeader;
    for Cnt:=1 to 5 do Update.AutoSig.Line[cnt]:=Autosig.Line[cnt];
    Update.AutoSig.Length:=Autosig.Length;
  End;
  Writeln('Updating User #:',FilePos(NEW),' - ',Update.Handle);
  Seek(NEW,FilePos(NEW));
  Write(NEW,Update);
End;

  WriteLn(^M,filepos(OLD)-1,' users were upgraded.');
  Close(OLD);
  Close(New);

  Writeln('Renameing new user list file: USERS.NEW -to-> USERS.LST');
  Assign(FFILE,'USERS.NEW');
  Rename(FFILE,'USERS.LST');

  Writeln('Reading users list file: USERS.LST');
  Assign(NEW,'USERS.LST');
  REset(New);
  assign(Index,'USERS.NDX');
  rewrite(Index);
  seek(Index,0);
  Writeln('Updating user index file: USERS.NDX');
{  While Not EOF(New) do
  Begin
    Read(New,Urec);
    Write(Index,Urec.handle);
  End;
  Writeln('Closing all files: USERS.NDX, USERS.LST');}
  Close(new);
  Close(Index);
  Close(FFile);
End.
