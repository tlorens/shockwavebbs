{
  iB * 10/21/95 - Made some changes to the Const's and various user records
}

Unit Records;

Interface

Uses DOS;

{$I build.ver}

Const VerHigh=1;
      VerLow=0;
      VerStr='1.00';
      Revision=VerHigh+VerLow;
      MaxTopics=15;       { Max Voting Topics }
      MaxMessageSize=201; { Max Message Size }
      MaxEMail=50;        { Max Number of E-Mails per Box }
      MaxChoices=25;      { Max Number of PullDown/LiteBar choices }
      MaxNodes=5;         { Max Nodes for MultiNode Chat }
      Node_FileName='MCHAT.PRO';

type Str255=String[255];
     Str80=String[80];
     Str40=String[40];
     Str25=String[25];
     Str10=String[10];
     Str12=String[12];
     Availtype=(Available,Bytime,NotAvailable);

     VoteSet=array [1..MaxTopics] of byte;
     NewVote=array [1..50] of Byte;

     UConfigSet=(PostPrompts, {Ask to post in current base after newscanning it}
                 MorePrompts, {Screen Pause after every 25 lines of text}
                 Graphics,    {Use Extended ASCII Characters}
                 FSE,         {Use FullScreen Editor}
                 Expert,      {Use Expert Menu Mode}
                 Intermediate,{Use Intermediate Menu Mode}
                 TimeL);      {Display time left at menu prompt}

StringRec=Record
      Sys1PWPrompt,
      Sys2PWPrompt,
      Sys3PWPrompt,
      ConnectStr,
      WrongPW,
      NewHandle,
      NewPassword,
      WallPrompt,
      DetectANSi,
      GotANSi,
      NoANSi,
      LockBaudPrompt,
      WrongPWBaud,
      NUPPrompt,
      GetHandle,
      DupHandle,
      GetPassword,
      GetRealName,
      GetPhone,
      UseANSi,
      AskHotKeys,
      CloseTimeBnk,
      TimeBankHdr,
      BBSlistHdr,
      FileDelPrompt,
      MsgDelPrompt,
      AutoDelStr,
      MsgAreaPrompt,
      InvalidMsgArea,
      TitlePrompt,
      PostToPrompt,
      MsgULPrompt,
      ToAllStr,  { if addressed to ALL, then print this string }
      Anonprompt,
      SysOpWait,
      FileAreaPrompt,
      NewFileStr,
      SpecFileStr,
      OffLineStr,
      PWFileStr,
      NoPointsStr,
      NoTimeStr,
      NoDLAreaStr,
      NoULAreaStr,
      NoFiles,
      NoAreas,
      BadUDRstr,
      BadUDKstr,
      BadPCRstr,
      PrivFile,
      ProtoHdr,
      AskHangupDL,
      AskHangupUL,
      DohangupUL,
      DoHangupDL,
      LogOffPrompt,
      MsgToNext,
      MsgToSysop,
      BadLevel,
      AskMorePrompts,
      DefUserPrompt,
      EnterChatStr,
      ExitChatStr,
      SysOpIn,
      SysOpOut,
      NetOrigin1,
      NetOrigin2,
      PostPrompt,
      NScanFilesPrompt,
      NScanMsgPrompt,
      NewScanHdrMsg,
      NewScanHdrFiles,
      UsrNotValidated,
      ShowSys1Pw,
      ShowSys2Pw,
      ShowSys3Pw,
      SysOpInDosStr,
      AnonymousStr,
      MatrixHangupStr,
      MatInvalidStr,
      HitAKey,
      MatrixPrompt,
      Email_To,
      NewEmail,
      AppendFile,
      Certified,
      CarbonCopy,
      EmerChatPrmpt,
      EnterEmergChat,
      ChatReasonPrmpt,
      ReEnterPWPrmpt,
      PWDontMatchstr,
      QuoteString,
      UserNotFound,
      ApplyNow,
      UserNumStr,
      ScrLen,
      BirthDate,
      EditCmd,
      IntrHdr,
      IntrFill,
      IntrReplace,
      ChkRIP,
      HaveRIP,
      ScanEMail,
      GenderPrompt,
      AskANSi,
      MsgSys:Str80;
      Pad:Array[1..180] Of Str80;
  End;

Type UserRec=Record
       UserVersion :Word;     (* Last Revision Number *)
       Handle,                (* Users Handle *)
       Realname    :Str25;    (* Users Real Name *)
       Age         :Str10;    (* Date XX/XX/XX format *)
       Gender      :Char;     (* Gender/Sex of user [M/F] *)
       Password    :Array[1..5] of Str10;    (* [1] Users Password *)
       Phone       :Array[1..5] of Str10;    (* [1] Users Phone Number *)
       CallRate    :Str40;    (* BPS rate, including ARQ, etc...*)
       LastCall    :Longint;  (* Last Call date in DATEPACK form *)
       NumCalls,              (* Total Calls *)
       TimeLeft,              (* Time left today *)
       Posts,                 (* Messages posted *)
       Uploads,               (* Uploads *)
       Downloads   :Integer;  (* Downloads *)
       TotalTime   :Real;     (* Total Time spent on system by user *)
       Voted       :VoteSet;  (* What the user voted on *)
       Xlvl,                  (* File Level *)
       Lvl:Integer;           (* Main Level *)
       AccessFlags :Str25;    (* A..Y flag *)
       FilePts,               (* File Points *)
       { InfoForms and such go here }
       RegularColor,          (* The following are the users colors. *)
       PromptColor,
       StatColor,
       InputColor,
       BoxColor,
       InSideColor,
       CmdColor,
       MiscColor   :Byte;
       Wanted      :Boolean;             (* SysOp Flag for Autochat *)
       Scrnlength  :Byte;                (* Screen Length *)
       UseCnet     :Boolean;             (* User defined message threading flag *)
       Config      :Set of UConfigSet;   (* Various config stuff, i.e. Ansi, etc *)

       NewScanConfig,              (* Various stuff dealing with message *)
       access1,                    (* Not used *)
       access2     :set of byte;   (* Not used *)

       UserNote    :Str25;    (* Account Note [Public] *)
       UpK,                   (* Upload K *)
       DownK       :longint;  (* Download K *)
       LastPosts,             (* Last total messages in system *)
       LastFiles   :Word;     (* Last total files in system *)

       Pad         :Array [1..511] of Char;

       DefProtocol :Byte;
       ExpDate     :LongInt;  (* Expiration date in DATEPACK form *)
       TimeBank    :Integer;  (* Time stored in Time Bank *)
       LastCallNum :Word;     (* Last Caller Number *)
       Up_Down_Ratio,         (* Individual Upload/Download Ratio *)
       Up_Down_K_Ratio,       (* Individual U/D K Ratio *)
       PCR         :Integer;  (* Individual Post/Call Ratio *)
       MenuType    :Byte;     (* 0=Normal - 1=Hot *)
       TimeLimit   :Integer;  (* Daily time limit (0 means normal) *)
       LastMConf,             (* Last Message Conference user was in *)
       LastXConf   :Byte;     (* Last File COnference user was in *)
       SysopNote   :Str25;    (* Special Sysop Note *)
       NewVoteYes,NewVoteNo   :Byte; {Number of Votes}
       NewVoteIt   :NewVote;  (* New user voting Stuff *)
       MenuSet     :Byte;     (* User defined menuset *)
       Expert      :Boolean;  (**** Un-used ****)
       LastNUV:Array[1..10] of Str25;  (* Last 10 users voted  on *)
       Filelist:Array[1..8] of Boolean; (* user defined file listing 
                                          [1] FileName
                                          [2] Size
                                          [3] FilePts
                                          [4] #Downloads
                                          [5] Uploader
                                          [6] Date
                                          [7] Description
                                          [8] Diz?
                                        *)
                                         
       MsgHeader   :Byte;      (* Message Header Type *)
       AutoSig     :Record     (* users autosig *)
                      Line:Array[1..5] of Str80;
                      Length:Byte;
                    End;
  end;

     UserSpecsRec=Record    (* Sysop Defined user lists *)
       Name         :String[25];
       Expired      :Boolean;
       Minlevel,
       Maxlevel,
       Minlaston,
       Maxlaston    :Integer;
       Minpcr,Maxpcr:Real;
     End;


(*
     { Conference record }  {*** NOT USED ***}
     ConfRec=Record
       Name,              { Name Of Conference }
       Flags,             { Access Flags }
       Password:Str25;    { Conference Password }
       Description:Str40; { Description of Conference }
     End;
*)
     (* Message Area Record *)
     BoardRec=Record
       AreaCmd     :Str10;   (* Area Short Name *)
       AreaName    :Str25;   (* Area Name *)
       Description :Str40;   (* Area Description *)
       SubOp       :Str25;   (* Sub-Op Of Area *)
       Password    :Str25;   (* Entry Password *)
       Flags       :Str40;   (* Area Access Flags *)
       PostFlags   :Str40;   (* Post Flags *)
       MaxMsgs,              (* Maximum # Of Messages *)
       NumToDel    :Integer; (* Number Of Posts to Delete *)
       RealNames,            (* Force RealNames *)
       Priv        :Boolean; (* Private NetMail *)
       NetType     :Byte;    (* Net Type 0=Local/1=FiDO/2=iNET *)
       Directory   :Str40;   (* FidoNet Directory *)
       Address     :Str40;   (* FidoNet/iNET Address *)
       LastScan    :LongInt; (* FidoNet/iNET LastScan *)
     End;

     (* Message Header Record *)
     MsgHdr=Record
        MsgType   :Byte;    { 0=Message/1=Email/2=Bulletin/3=Feedback }
        From,               { Posters Handle }
        RealName,           { Posters Real Name }
        SendTo,             { Message To }
        Title,              { Title Of Message }
        Flags     :Str25;   { Special Access Flags }
        Forwd,Back:LongInt; { Thread Pointers }
        Deleted   :Boolean; { Is message Deleted? }
        When      :LongInt; { When Posted - Date/Time }
        Anon      :Boolean; { Is Message Anonymous? }
        NumRead   :Integer; { Number of times read }
        NumReply  :Integer; { Number of times replied to }
        ID        :LongInt; { Unique Message ID Number }
        Certified :Boolean; { Used in E-Mail/Feedback }
        FileIndex :Integer; { Message Location in INDEX }
        AfileName :Str12;   { Filename.ext of Appended file }
     End;

     MsgTxt=Record { we'll learn pointers, one of these days!! }
       Text     : Array[1..MaxMessageSize] of Str80; { This HAS to go! This code sucks! }
       Numlines : Integer;
     End;

     (* User Message Newscan .NDX *)
     LastMsgRec=Record 
       Handle:Str25;
       LastMsg:Integer; { Should be LongInt }
     End;

     CatalogRec=Record   (* Dynamic Email Catalog *)
       NumMail :Integer;
       MailPos :Array [0..MaxEMail] of Longint;
     End;

     VoteTopicRec=Record
       TopicName      :Str80;   { Voting Topic Name }
       NumVoted,                { Number of People Voted }
       Addlevel       :Integer;
       Mandatory      :Boolean; { Voting topic mandatory? }
     End;

     ChoiceRec=Record           (* Voting topic records *)
       Choice         :Str80;
       NumVoted       :Integer;
     End;

     LastRec=Record             (* Last Caller Info *)
       Name           :Str25;
       Callnum,
       When           :Longint;
       Lastbps        :Word;
     End;

     FFileRec=Record
       From           :Str25;       (* Who Send the File *)
       When,                        (* When Uploaded *)
       WhenRated      :Longint;     (* Date When Validated *)
       Filename       :String[12];  (* File Name *)
       Path           :Str80;       (* Path to file [Check on this] *)
       Points         :Integer;     (* File Value *)
       FSize          :Longint;     (* Size of File *)
       Description    :Str40;       (* Short Description *)
       Desc           :Array[1..10] of Str40;
       Downloaded     :Integer;     (* Number of Times downloaded *)
       SendTo         :Str25;       (* If PRIV: Send to Who *)
       PassWord       :Str10;       (* Special Password *)
       Flags          :Str80;       (* 'Files' access flags *)
       NewFile,                     (* Is new File? For SysOp Validation *)
       SpecialFile,                 (* Is Special File? For Flags! *)
       Aborted,                     (* Was Upload Aborted? *)
       Crashed        :Boolean;     (* Should I Crash Recieve? *)
     End;

     FAreaRec=record                (* File Area *)
       Area,SubOp        :Str25;
       Description       :Str40;
       Path              :Str80;
       Password          :Str10;
       Upload,Download   :Boolean;
       Flags             :Str40;
       DownFlag,
       UpFlag            :Str40;
       NumFiles          :Integer;
     End;

     BatchRec=Record
       Path          :Str80;
       From          :Str25;
       Cost,Mins     :Integer;
       Size          :Longint;
     End;

     BBSRec=Record
        BoardName    :Str80;
        LeftBy       :Str25;
        Baud         :String[4];
        Phone        :String[12];
        Software     :Str10;
        Description  :Str80;
        ANSiFile     :String[12];
     End;

     DoorRec=Record
       Name          :Str25;
       Flags         :Str40;
       NumUsed       :Integer;
       Description   :Str40;
       DoorPath      :Str40;
       BatchName     :Str25;
       DoorType      :Byte;  (* 1=CHAIN.TXT 2=DORINFOx.DEF 3=PCBOARD.SYS *)
     End;

     MinuteRec=Record
       Started       :Boolean;
       StarteDat     :Integer;
       Total         :Real
     End;

     StatusRec=Record
       Chat:AvailType;
       LastChatReason:Str80;
       MinsIdle,MinsInUse,MinsInXfers:MinuteRec;
       NewFeedBack,NewUploads,NewCalls,NewPosts,NewMail:Integer;
       LastDayUp:LongInt;
       NumDaysUp,CallsToday:Integer;
     End;

     MenuBarRec=Record { Pull/Slide Bar Records }
      MenuName    :Str40;
      NumChoices  :Byte;
      Choice      :Array[1..MaxChoices] Of Str25;
      HighChr     :Array[1..MaxChoices] Of Byte; { Character to HighLite }
      DefChoice   :Byte;
      MenuX,MenuY :Array[1..MaxChoices] Of Byte;
      BarX,BarY   :Byte;
      KeyCmds     :String[MaxChoices];
    End;


    MenuRec=Record       { Currrent Menu Options }
      ANSiF    :Str25;
      Prompt   :Str80;
      ACFlag   :Str80;
      Password :Str25;
    { Expert   :Byte; } { 0=Normal/1=Forced/2=Disabled }
    { HotKey   :Byte; } { 0=Normal/1=Forced/2=Disabled }
    End;

    CommandRec=record  { Menu Options Record Array; Max: 65 }
       Key    :Str25;  { ^[ = Esc }
       Desc   :Str40;
       Comm   :String[5];
       FlagStr:Str80;
       Param1 :Str80;
       Param2 :Str80;
     End;

    EventRec=Record
      Description:Str40;
      ErrCode    :Byte;
      ExecCmd    :Str40;
      Time       :Str10;
      Date       :Str10;
      Day        :Byte;
      Completed  :Boolean;
     End;

    ProfileRec=Record
       Name        :Str25;
       AcLvl       :Integer;
       XferLvl     :Integer;
       Fpoints     :Integer;
       AcFlags     :Str25;
       UserNote    :Str25;
       ExpDate     :LongInt;
       UDR,UDKR,PCR:Integer;
       TimeLimit   :Integer;
    End;

    BlackListRec=Record
      ByWho:Str25;        { Who did the BlackListing }
      Handle:Str25;       { Who to BlackList }
      When:LongInt;       { When BlackListing occured }
      HowLong:Integer;    { How many days is user Blacklisted }
    End;

 {   Fib=TextRec;}

    AutoMsgRec=Record
     Line:Array[1..3] Of Str80;
     From:Str25;
    End;

    MCiRec=Record
      F,B   :Byte;
      X,Y   :Byte;
      Code  :String[3];
      Prompt:String[80];
      Data  :String[80];
    End;

implementation

begin
end.
