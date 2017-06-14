{
  This is a unit to obtain and process keys which are global throughout
  the program, such as Shell-To-Dos, and GetUserStats, etc.
}

unit GlobKey;

interface

procedure CheckGlobalKeys;

implementation

Uses OpCrt,Options,Misc,User,Vars,Windows;

procedure CheckGlobalKeys;
Var  ch : char;
begin
  Ch := Readkey;
  Case CH Of
    #17:SaveUserStats;       {Alt+W}
    #20:ToggleTempSysop;     {Alt+T}
    #31:FullUserStats;       {Alt+S}
    #32:Debugger;            {Alt+D}
    #35:LocalHelp;           {Alt+H}
    #36:DOSShell;            {Alt+J}
    #44:; {blackList-ZZZAP}  {Alt+Z}
    #45:SWDone(255);         {Alt+X}
    #48:FlipStatBar;         {Alt+B} 
    #47:SetUserProfile(URec^,0); {Alt+V}
    #49:NukeUser;            {Alt+N}
    #59:SysOpChat;           {F1}
    #60:LocalMenus;          {F2}
    #66:RunConfig;           {F8}
    #67:ToggleOutPut;        {F9}
    #68:ToggleInput;         {F10}
    #72:MoreTime;            {UpArrow}
    #80:LessTime;            {DnArrow}
  End;
  StatusBar(CurStat);
End;

End.