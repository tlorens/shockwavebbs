Program MenuEditor;

Uses opCrt,Dos,Records,GenSubs,iCEIO1,ProBarz,CnfgRec,FSelect;

Const VerNum='0.10';
      VerDate='05/13/97';

      Hdr1=';ShockWavE:PRO LiteBar Menu Data File -v'+VerNum;
      Hdr2=';Copyright 1997,98 Cyberdyne Systems:VSI';
      Hdr4=';';
      Hdr5='; Format: X,Y,HiFore,HiBack,RegFore,Regback,ReturnValue,Text';
      Hdr6=';';

Var
    Bars    : PullBarzRec;
    Pick,X  : Byte;
    Quit    : Boolean;
    FTmpMenu: File Of CommandRec;
  TmpMenuCmd: CommandRec;
    InputStr: String;
    Ext     : String[2];
    CmdList : String[78];
    Slide,LastSlide,
    LastPull,
    Count,Cur: Byte;
    F:File;
    FMenuCmd:File Of CommandRec;           { Remove from global var list }
    MenuCmd:Array[1..68] of ^CommandRec;   { 68 MAX }
    MenuArray:Array[1..50] of String[13];
    CurMenu:MenuRec;
    FCurMenu:File Of MenuRec;              { Remove from global var list }


Procedure Tab(S:String; Len:Byte);
Var I:Byte;
Begin
  Write(S);
  For I:=1 to Len-Length(S) do Write(' ');
End;

Procedure Header;
Begin
  ClrScr;
  TextColor(14);
  TextBackGround(1);
  Write('³ Menu-Editor ³                              ');
  TextColor(7); Write('ShockWavE:PRO BBS Software v',VerNum); ClrEol;
  Writeln;
  TextBackGround(0);
  Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  TextColor(7);
End;

Procedure GetMenus;
Begin
  GatherFiles(CNF^.MenuDataDir+'*.MNU');
  Header;
  DisplayList;
  Writeln;
End;

Function NumCmds(F:String):Byte;
Var Tmp:Byte;
Begin
  Assign(FTmpMenu,CNF^.MenuDataDir+F+'.DAT');
  Reset(FTmpMenu);
  Tmp:=Round(FileSize(FTmpMenu)/SizeOf(CommandRec));
  If Tmp=0 then NumCmds:=1 Else NumCmds:=Tmp;
  Close(FTmpMenu);
End;

Procedure CreateNewMenu;
Var fn:String;
Begin
  FN:='';
  Write('Menu Name: '); EditLine(FN,Cur,WhereX,WhereY,8,Ext,False,0); Writeln;
  If (Length(FN)=0) or (Exist(CNF^.MenuDataDir+FN+'.DAT')) then exit;
  Assign(FTmpMenu,CNF^.MenuDataDir+FN+'.DAT');
  ReWrite(FTmpMenu);

  MenuCmd[1]^.Key    :='Q';
  MenuCmd[1]^.Desc   :='Quit';
  MenuCmd[1]^.Comm   :='@MENU';
  MenuCmd[1]^.FlagStr:='(s0)';
  MenuCmd[1]^.Param1 :='MAIN';
  MenuCmd[1]^.Param2 :='';

  Write(FTmpMenu,MenuCmd[1]^);
  MenuCmd[1]^.Key    :='?';
  MenuCmd[1]^.Desc   :='Help';
  MenuCmd[1]^.Comm   :='PRINT';
  MenuCmd[1]^.FlagStr:='(s0)';
  MenuCmd[1]^.Param1 :=FN+'.ANS';
  MenuCmd[1]^.Param2 :='';

  Write(FTmpMenu,MenuCmd[1]^);
  Close(FTmpMenu);

  Assign(FCurMenu,CNF^.MenuDataDir+FN+'.MNU');
  Rewrite(FCurMenu);
  FillChar(CurMenu,SizeOf(CurMenu),#0);
  With CurMenu Do
  Begin
    {
      Force HotKeys?
    }
    ANSiF:=FN;
    Write('Help File: ');       EditLine(ANSiF,Cur,WhereX,WhereY,12,Ext,False,0); Writeln;
    ACFlag:='(s'+Strr(CNF^.DefLvl)+')';
    Write('Access Flag: ');     EditLine(ACFlag,Cur,WhereX,WhereY,40,Ext,False,0); Writeln;
    Write('Menu Password: ');        EditLine(Password,Cur,WhereX,WhereY,25,Ext,False,0); Writeln;
    Prompt:='|07ú|09'+FN+' Menu|09ú';
    Writeln('Prompt String: '); EditLine(Prompt,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;
  End;
  Write(FCurMenu,CurMenu);
  Close(FCurMenu);
End;

Procedure CreateMenu(Fn:String);  { Fix CurSecion problem }
Begin
  TextColor(12);
  Writeln('Error: ',fn,' File not found!  Creating!');
  Assign(FTmpMenu,CNF^.MenuDataDir+FN+'.DAT');
  ReWrite(FTmpMenu);
  MenuCmd[1]^.Key    :='Q';
  MenuCmd[1]^.Desc   :='Quit';
  MenuCmd[1]^.Comm   :='@MENU';
  MenuCmd[1]^.FlagStr:='(s0)';
  MenuCmd[1]^.Param1 :='MAIN';
  MenuCmd[1]^.Param2 :='';

  Write(FTmpMenu,MenuCmd[1]^);

  MenuCmd[1]^.Key    :='?';
  MenuCmd[1]^.Desc   :='Help';
  MenuCmd[1]^.Comm   :='PRINT';
  MenuCmd[1]^.FlagStr:='(s0)';
  MenuCmd[1]^.Param1 :=FN+'.ANS';
  MenuCmd[1]^.Param2 :='';

  Close(FTmpMenu);

  Assign(FCurMenu,CNF^.MenuDataDir+FN+'.MNU');
  Rewrite(FCurMenu);
  Write(FCurMenu,CurMenu);
  Close(FCurMenu);
End;


Procedure EditMenu(FileName:String);
Var Done:Boolean;

  Procedure ListCmds;
  Var Sub,Tim,Cnt:Byte;
  Begin
    ClrScr;
    Cnt:=0;
    CmdList:='';

    ReSet(FMenuCmd);
    While Not Eof(FMenuCmd) do
    Begin
      Read(FMenuCmd,MenuCmd[FilePos(FMenuCmd)+1]^);
      CmdList:=CmdList+MenuCmd[FilePos(FMenuCmd)+1]^.Key;
      Inc(Cnt);
    End;

    Tim:=0;
    TextColor(7); Writeln('# :K:Desc        :Cmd     # :K:Desc        :Cmd     # :K:Desc        :Cmd');
    Textcolor(8); Writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    While Tim<Cnt Do
    Begin
      Sub:=0;
      Repeat
        Inc(Tim);
        Inc(Sub);
        With MenuCmd[Tim]^ do
        Begin
          TextColor(7);  Tab(Strr(Tim),3);
          If Length(Key)>1 Then TextColor(13) Else TextColor(15);
          Tab(Key[1],2);
          TextColor(11); Tab(Copy(Desc,1,12),13);
          TextColor(8);  Tab(Copy(Comm,1,5),8);
        End;
      Until (Sub=3) or (Tim=Cnt);
      Writeln;
    End;
End;

  Procedure ExportBar(F:String);
  Var Sub,Tim,Cnt:Byte;
      XPortFile:Text;

  Begin
    Tim:=1;
    Assign(FTmpMenu,CNF^.MenuDataDir+F+'.DAT');
    ReSet(FTmpMenu);

    Assign(XportFIle,CNF^.MenuDataDir+F+'.BAR');
    ReWrite(XportFIle);
    Writeln(XportFIle,';ShockWavE:PRO SlideBar Menu Data File -v'+VerNum);
    Writeln(XportFIle,';Copyright(C) 1997 Cyberdyne Systems:VSI');
    Writeln(XportFIle,';Compiled by: iCE Breaker');
    Writeln(XportFIle,';');
    Writeln(XportFIle,';Format: X,Y,HiFore,HiBack,RegFore,Regback,ReturnValue,Text');
    Writeln(XportFIle,';');

    While Not EOF(FTmpMenu) Do
    Begin
      Read(FTmpMenu,TmpMenuCmd);
      Writeln(XportFIle,'1,',Tim,',15,1,7,0,',TmpMenuCmd.Key,',',TmpMenuCmd.Desc);
      Inc(Tim);
    End;

    Close(FTmpMenu);
    Close(XportFIle);
    ListCmds;
  End;


  Procedure MenuOptions(FN:String);
  Begin
    Assign(FCurMenu,CNF^.MenuDataDir+FN+'.MNU');
   {$I-} ReSet(FCurMenu); {$I+}
    If Ioresult<>0 then
    Begin
      {CreateMenu(FN);}
      Assign(FCurMenu,CNF^.MenuDataDir+FN+'.MNU');
      ReSet(FCurMenu);
    End;
    Read(FCurMenu,CurMenu);
    With CurMenu Do
    Begin
      Write('ANSi File: ');       EditLine(ANSiF,Cur,WhereX,WhereY,12,Ext,False,0); Writeln;
      Write('Access Flag: ');     EditLine(ACFlag,Cur,WhereX,WhereY,40,Ext,False,0); Writeln;
      Write('Password: ');        EditLine(Password,Cur,WhereX,WhereY,25,Ext,False,0); Writeln;
      Writeln('Prompt String: '); EditLine(Prompt,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;
    End;
    Seek(FCurMenu,0);
    Write(FCurMenu,CurMenu);
    Close(FCurMenu);
    ListCmds;
  End;

  Procedure ReOrder;
  Begin
  End;

  Procedure InsertCmd;
  Begin

  End;

  Procedure SortCmds(F:String);
  Begin

  End;

  Procedure AddCmd(F:String);
  Var Cnt:Byte;
      TmpKey:String;
  Begin
    Writeln;
    FillChar(TmpMenuCmd,SizeOf(CommandRec),#0);
    With TmpMenuCmd Do
    Begin
      InputStr:='';
      Write('Key Command: ');
      EditLine(InputStr,Cur,WhereX,WhereY,25,Ext,False,0);
      Key:=UpString(InputStr);
      Writeln;
      If (Length(InputStr)=0) or (Length(Key)=0) then
      Begin
        ListCmds;
        Exit;
      End;

      Write('Command Desc: ');
      EditLine(Desc,Cur,WhereX,WhereY,40,Ext,False,0);
      Writeln;

      Writeln('Execute Command: ');
      EditLine(Comm,Cur,WhereX,WhereY,5,Ext,False,0);
      Writeln;
      Comm:=UpString(Comm);

      FlagStr:='(s'+Strr(CNF^.DefLvl)+')';
      Writeln('Access Flag: ');
      EditLine(FlagStr,Cur,WhereX,WhereY,78,Ext,False,0);
      Writeln;

      Writeln('Parameter 1: ');
      EditLine(Param1,Cur,WhereX,WhereY,78,Ext,False,0);
      Writeln;

      Writeln('Parameter 2: ');
      EditLine(Param2,Cur,WhereX,WhereY,78,Ext,False,0);
      Writeln;
    End;

    Cnt:=1;
    While Cnt<=NumCmds(F) Do Inc(Cnt); { whaaat? Just use NumCmds for this! }
    Move(TmpMenuCmd,MenuCmd[Cnt]^,Sizeof(CommandRec));
    Write(FMenuCmd,MenuCmd[Cnt]^);
    ListCmds;
  End;

  Procedure EditCmd;
  Var Cnt:Byte;
      TmpKey:String;
  Begin
    Writeln;
    TmpKey:='';
    Write('Command # to Edit (Q/Quit): '); EditLine(TmpKey,Cur,WhereX,WhereY,5,Ext,False,0); Writeln;
    If (TmpKey='Q') or (Valu(TmpKey)=0) Then
    Begin
      ListCmds;
      Exit;
    End;
    Move(MenuCmd[Valu(TmpKey)]^,TmpMenuCmd,Sizeof(CommandRec));
    With TmpMenuCmd Do
    Begin

      InputStr:=UpString(Key);
      Write('Key Command: ');     EditLine(InputStr,Cur,WhereX,WhereY,25,Ext,False,0);  Writeln;
      Key:=UpString(InputStr);

      Write('Command Desc: ');    EditLine(Desc,Cur,WhereX,WhereY,40,Ext,False,0); Writeln;

      Writeln('Execute Command: '); EditLine(Comm,Cur,WhereX,WhereY,5,Ext,False,0); Writeln;
      Comm:=Upstring(Comm);

      Writeln('Access Flag: ');     EditLine(FlagStr,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;

      Writeln('Parameter 1: ');     EditLine(Param1,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;
      Writeln('Parameter 2: ');     EditLine(Param2,Cur,WhereX,WhereY,78,Ext,False,0); Writeln;

    End;

    Move(TmpMenuCmd,MenuCmd[Valu(TmpKey)]^,Sizeof(CommandRec));
    Seek(FMenuCmd,Valu(TmpKey)-1);
    Write(FMenuCmd,MenuCmd[Valu(TmpKey)]^);
    ListCmds;
  End;

  Procedure RemoveCmd;

  Procedure PackCmds;
  Begin
    Assign(FTmpMenu,CNF^.MenuDataDir+'TMPMNU.DAT');
    ReWrite(FTmpMenu);
    Seek(FMenuCmd,0);
    While Not EOF(FMenuCmd) Do
    Begin
      Read(FMenuCmd,MenuCmd[1]^);
      If (Length(MenuCmd[1]^.Key)<>0) And (Length(MenuCmd[1]^.Comm)<>0)
      Then Write(FTmpMenu,MenuCmd[1]^);
    End;
    Close(FMenuCmd); Erase(FMenuCmd);

    Close(FTmpMenu);

    Assign(FTmpMenu,CNF^.MenuDataDir+'TMPMNU.DAT');
    Rename(FTmpMenu,CNF^.MenuDataDir+FileName+'.DAT');

    Assign(FMenuCmd,CNF^.MenuDataDir+Filename+'.DAT');
    ReSet(FMenuCmd);
    ListCmds;
  End;

  Begin
    Writeln;
    InputStr:='';
    Write('Command # to Remove (Q/Quit): '); EditLine(InputStr,Cur,WhereX,WhereY,2,Ext,False,0);
    If (Upcase(InputStr[1])='Q') or (Length(InputStr)=0) then
    Begin
      ListCmds;
      Exit
    End
   Else
    Begin
      Seek(FMenuCmd,Valu(InputStr)-1);
      Read(FMenuCmd,TmpMenuCmd);
      FillChar(TmpMenuCmd,SizeOf(CommandRec),#0);
      Seek(FMenuCmd,Valu(InputStr)-1);
      Write(FMenuCmd,TmpMenuCmd);
      PackCmds;
    End;
  End;

Begin
  Done:=False;
  Assign(FMenuCmd,CNF^.MenuDataDir+FileName+'.DAT');
  {$I-} ReSet(FMenuCmd); {$I+}
  If IOResult<>0 then
  Begin
{    CreateMenu(FileName);}
    Close(FMenuCmd);
    Assign(FMenuCmd,CNF^.MenuDataDir+Filename+'.DAT');
    ReSet(FMenuCmd);
  End;
  ListCmds;
  LastSlide:=1;
  Repeat
    CursorOff;
    With Bars Do
    Begin
      MenuName  :='Menu Command Editor';
      NumChoices:=6;
      DefChoice :=LastSlide;
      KeyCmds   :='';
      Operation :=2;
      MainX     :=WhereX;
      MainY     :=WhereY+1;
      ForC      :=7;
      BackG     :=0;
      BForC     :=15;
      BBackG    :=1;
      HiC       :=15;
      Hdr       :=2;
      Choice[1] :=' Add ';
      Choice[2] :=' Edit ';
      Choice[3] :=' Remove ';
      Choice[4] :=' Options ';
      CHoice[5] :=' Make .BAR ';
      Choice[6] :=' Quit ';
     End;
     Writeln;
     Pick:=MenuBar(Bars);
     LastSlide:=Pick;
     Writeln;
     Case Pick Of
       1:AddCmd(FileName);
       2:EditCmd;
       3:RemoveCmd;
       4:MenuOptions(FileName);
       5:ExportBar(Filename);
       6,7:Done:=True;
     End;
  Until Done;
End;

Procedure SetMainMenu;
Begin
  With Bars Do
  Begin
    KeyCmds   :='';
    MenuName  :='Menu Editor';
    Operation :=2;
    MainX     :=WhereX;
    MainY     :=WhereY+1;
    ForC      :=7;
    BackG     :=0;
    BForC     :=15;
    BBackG    :=1;
    HiC       :=15;
    Hdr       :=2;
    Choice[1] :=' Edit ';
    Choice[2] :=' Add ';
    Choice[3] :=' Delete ';
    Choice[4] :=' Quit ';
    NumChoices:=4;
    DefChoice :=Slide;
  End;
End;

Begin
  ReadConfig;
  Quit:=False;
  For X:=1 To 68 Do New(MenuCmd[X]);

  Slide:=1;
  Repeat
    CursorOFf;
    CmdList:='';
    InputStr:='';
    ClrScr;
    GetMenus;

    SetMainMenu;
    Pick:=MenuBar(Bars);
    Slide:=Pick;
    Writeln;
    Case Pick Of
      1:Begin
          GetMenus;
          InputStr:=SelectFile(CNF^.MenuDataDir+'*.MNU');
          Delete(InputStr,Length(InputStr)-3,4);
          If (Length(InputStr)>0) then
          If Exist(CNF^.MenuDataDir+InputStr+'.DAT') Then EditMenu(InputStr);
        End;
      2:CreateNewMenu;
      3:Begin
          GetMenus;
          InputStr:=SelectFile(CNF^.MenuDataDir+'*.MNU');
          Delete(InputStr,Length(InputStr)-3,4);
          If (Length(InputStr)>0) then
           If (Exist(CNF^.MenuDataDir+InputStr+'.DAT')) and (Exist(CNF^.MenuDataDir+Inputstr+'.MNU')) Then
            Begin
              Assign(F,CNF^.MenuDataDir+InputStr+'.DAT'); Erase(F);
              Assign(F,CNF^.MenuDataDir+InputStr+'.MNU'); Erase(F);
            End;
        End;
      4,5:Quit:=True;
    End;
  Until Quit;
  For X:=1 To 68 Do Dispose(MenuCmd[X]);
  CursorOn;
  ClrScr;
End.