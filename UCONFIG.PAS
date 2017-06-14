{
  iB * 04/06/97 - Added HotKey Toggle.
  iB * 05/25/97 - Started work on Sysop configurable user config.
}
Unit UConfig;

Interface

Procedure ToggleOption(B:Byte);
Procedure EditColors(var q:byte; GG:Char);
Procedure EditAutoSig;
Procedure EditFileListing;
Procedure EditScreenLen;
Procedure NewScanSetup;
Procedure EditUserNote;
Procedure EditMenuType;
Procedure EditMsgHdrType;
Procedure EditEmulation;
Procedure Edit8BitChars;
Procedure CustomUConfig;

Implementation

Uses OpCrt,Dos,IO,Vars,CnfgRec,GenSubs,Records,User,Display,ANSiEdit,Misc;

Type OpXYRec=Record
      X,Y:Byte;
     End;

Var OpXY:Array[1..16] of OpXYRec;

Procedure ToggleOption(B:Byte);
(*
   PostPrompts   Ask to post in current base after newscanning it
   MorePrompts   Screen Pause after every 25 lines of text
   Graphics      Use Extended ASCII Characters
   FSE           Use FullScreen Editor
   Expert        Use Expert Menu Mode
   Intermediate  Use Intermediate Menu Mode
   TimeL         Display time left at menu prompt
*)
Begin
  
End;

Procedure Edit8BitChars;
Begin
  If YeaNa('Use 8Bit/Extended Graphics Characters: ',True) Then
    Urec^.Config:=Urec^.Config+[Graphics] Else Urec^.Config:=Urec^.Config-[Graphics];
  WriteUser(Urec^);
End;

Procedure EditColors(var q:byte; GG:Char);
 Var K:char;
      CNT,FG,BK:Integer;
      Hi,Bl:Boolean;
      Colur:String;
      TEMPX:Integer;

  procedure getcolorvar (attr:byte; var fg,bk:integer; var hi,bl:boolean);
  begin
    fg:=attr and 7;
    hi:=(attr and 8)=8;
    bk:=(attr shr 4) and 7;
   bl:=(attr and 128)=128
  end;

 function getattrib (fg,bk:integer; hi,bl:boolean):byte;
 begin
   getattrib:=fg+(byte(hi) shl 3)+(bk shl 4)+(byte(bl) shl 7)
 end;

 Procedure Writecolor(a:byte);
 Var fg,bk:integer;
      hi,bl:boolean;
 Begin
   GetColorVar(a,fg,bk,hi,bl);
   Color(Fg,Bk);
   Print(' Color ');
 End;

 procedure getacolor (var q:Byte);
 Var CordY,FX,BX,n:integer;

   Procedure Move(Dir:Char);
   Begin
     If Dir='L' Then
     Begin
          FX:=FX-1;
          If FX=53 then
          Begin
            GoXY(54,6);
            Color(15,0);
            Print(' ');
            FX:=68;
          End;
        Case FX Of
          54:fg:=1;
          55:fg:=2;
          56:fg:=3;
          57:fg:=4;
          58:fg:=5;
          59:fg:=6;
          60:fg:=7;
          61:fg:=8;
          62:fg:=9;
          63:fg:=10;
          64:fg:=11;
          65:fg:=12;
          66:fg:=13;
          67:fg:=14;
          68:fg:=15;
        end;
        Color(15,0);
        GoXY(Fx+1,6); Print(' ');
        GoXY(Fx,6); Print(chr(31));
      End;

      If Dir='R' then
      Begin
        FX:=FX+1;
        If FX=69 then
        Begin
          GoXY(68,6);
          Color(15,0);
          Print(' ');
          FX:=54;
        End;
      Case FX of
        54:fg:=1;
        55:fg:=2;
        56:fg:=3;
        57:fg:=4;
        58:fg:=5;
        59:fg:=6;
        60:fg:=7;
        61:fg:=8;
        62:fg:=9;
        63:fg:=10;
        64:fg:=11;
        65:fg:=12;
        66:fg:=13;
        67:fg:=14;
        68:fg:=15;
      ENd;
      Color(15,0);
      GoXY(Fx-1,6); Print(' ');
      GoXY(Fx,6); Print(chr(31));
    End;

      If Dir='D' then
      Begin
        BX:=BX-1;
        If BX=52 then
        Begin
          GoXY(53,8);
          Color(15,0);
          Print(' ');
          BX:=60;
        ENd;
      Case BX of
        53:bk:=0;
        54:bk:=1;
        55:bk:=2;
        56:bk:=3;
        57:bk:=4;
        58:bk:=5;
        59:bk:=6;
        60:bk:=7;
      End;
        Color(15,0);
        GoXY(BX+1,8); Print(' ');
        GoXY(BX,8); Print(chr(30));
      End;

      If Dir='U' then
      Begin
        BX:=BX+1;
        If BX=61 then
        Begin
          GoXY(60,8);
          AColor(15);
          Print(' ');
          BX:=53;
        End;
      Case BX of
        53:bk:=0;
        54:bk:=1;
        55:bk:=2;
        56:bk:=3;
        57:bk:=4;
        58:bk:=5;
        59:bk:=6;
        60:bk:=7;
      End;
      Color(15,0);
      GoXY(Bx-1,8); Print(' ');
      GoXY(BX,8); Print(chr(30));
    End;
  End;

  Procedure EscCode;
  Var Arrow:Char;
  Begin
    Repeat
      GetChar(Arrow);
      GetChar(Arrow);
      Case Arrow Of
        'A':Move('U');
        'B':Move('D');
        'C':move('R');
        'D':Move('L');
      End;
    Until (K<>'[') or Hungupon;
  End;

  Begin
    GetColorVar(Q,FG,BK,hi,bl);
    If Hi Then FG:=FG+8;
    Color(15,0);
    GoXY(54,6); Print('                ');
    GoXY(54,8); Print('                ');

    Case FG of
      0:fx:=54;
      1:fx:=54;
      2:fx:=55;
      3:fx:=56;
      4:fx:=57;
      5:fx:=58;
      6:fx:=59;
      7:fx:=60;
      8:fx:=61;
      9:fx:=62;
     10:fx:=63;
     11:fx:=64;
     12:fx:=65;
     13:fx:=66;
     14:fx:=67;
     15:fx:=68;
    End;

      GoXY(FX,6); Print(chr(31)); {dn}

      Case BK of
        0 :bx:=53;
        1 :bx:=54;
        2 :bx:=55;
        3 :bx:=56;
        4 :bx:=57;
        5 :bx:=58;
        6 :bx:=59;
        7 :bx:=60;
      End;
      GoXY(BX,8); Print(chr(30)); {up}
     { fg:=1; bk:=0;}
      bl:=false;  hi:=false;
      Repeat
        GetChar(K);
        If K=#0 Then 
        Begin
          GetChar(K);
          Case K Of
            'P':Move('D');
            'M':Move('R');
            'H':Move('U');
            'K':Move('L');
          End;
        End
      Else     
        Case K Of
           #27:EscCode;
          ^S:Move('L');
          ^X:Move('D');
          ^D:Move('R');
          ^E:Move('U');
         End;

       Case GG of
         '1':CordY:=11;
         '2':CordY:=12;
         '3':CordY:=13;
         '4':CordY:=14;
         '5':CordY:=15;
         '6':CordY:=16;
         '7':CordY:=17;
         '8':CordY:=18;
         '9':CordY:=19;
       End;
       GoXY(28,CordY);
       Color(fg,bk); Print(' Color ');
      if hungupon then exit;
    until k=#13;
      Color(15,0);
      GoXY(52,4); Print('                    ');
      GoXY(52,5); Print('                    ');
      GoXY(52,6); Print('                    ');
      GoXY(52,7); Print('                    ');
      GoXY(52,8); Print('                    ');
      GoXY(52,9); Print('                    ');
      GoXY(52,10);Print('                    ');
  end;

begin
  Color(15,0);
  GoXY(52,4); Print(' Left/Right Arrows  ');
  GoXY(52,5); Print('     Foreground     ');
  GoXY(52,6); Print('                    ');
  GoXY(52,7); AColor(1); Print('  Û');
  For Cnt:=2 to 15 do
  Begin
    AColor(Cnt);
    Print('Û');
  End;
  GoXy(69,7); Print('   ');
  Color(15,0);
  { Line 7, Row 53 = Color Bar }
  GoXY(52,8); Print('                    ');
  GoXY(52,9); Print('     Background     ');
  GoXY(52,10);Print('   Up/Down Arrows   ');
  Colur:=strr(Q);
  Getacolor(q);
  Q:=getattrib (fg,bk,hi,bl)
end;

Procedure EditAutoSig;
Var Done:Boolean;
     k:char;
     Cnt:Integer;

  procedure delAutoSig;
  Var Cnt:Byte;
  begin
    For Cnt:=1 to Urec^.AutoSig.Length do Urec^.AutoSig.Line[cnt]:='';
    Urec^.AutoSig.Length:=0;
  end;

  Procedure CreateAutoSig;
  Var Cnt:Byte;
  Begin
    If Urec^.AutoSig.Length>0 then
    Begin
      MHdr.Title:='(HideMySig)';
      For Cnt:=1 to Urec^.AutoSig.Length Do Msg.Text[Cnt]:=Urec^.AutoSig.Line[cnt];
      Msg.NumLines:=Cnt;
      If ANSiEditor(Msg,MHdr,-1) Then
      Begin
        If Msg.NumLines>5 then Msg.NumLines:=5;
        For Cnt:=1 To Msg.NumLines do Urec^.AutoSig.Line[Cnt]:=Msg.Text[Cnt];
        Urec^.AutoSig.Length:=Cnt;
      End;
    End
   Else
    Begin
      DelAutoSig;
      If ANSiEditor(Msg,Mhdr,-1) Then
      Begin
        If Msg.NumLines>5 then Msg.NumLines:=5;
        For Cnt:=1 To Msg.NumLines do Urec^.AutoSig.Line[Cnt]:=Msg.Text[Cnt];
        Urec^.AutoSig.Line[Cnt]:=Urec^.AutoSig.Line[Cnt]+'|RE';
        Urec^.AutoSig.Length:=Cnt;
      End
     Else DelAutoSig;
    End;
  End;

Begin
  Done:=False;
  FillChar(QMsg,Sizeof(QMsg),#0);
  FillChar(QHdr,Sizeof(QHdr),#0);
  FillChar(Msg,Sizeof(Msg),#0);
  FillChar(MHdr,Sizeof(MHdr),#0);
  Repeat
    WriteHdr('Auto-Signature');
    If Urec^.AutoSig.Length>0 then for Cnt:=1 to Urec^.AutoSig.Length do MCIPrintln(Urec^.AutoSig.Line[cnt])
    else Println('You don''t have an AutoSig right now.');
    New(Menubarz);
    With MenuBarz^ Do
    Begin
      MenuName:='Auto-Signature - (?/Help)';
      Choice[1]:=' Quit ';
      Choice[2]:=' Edit ';
      Choice[3]:=' Delete ';
      NumChoices:=3;
      KeyCmds:='QED?';
      DefChoice:=1;
    End;
    K:=BarMenu(MenuBarz^);
    Dispose(Menubarz);
    Case K of
      'Q':Done:=True;
      'D':delAutoSig;
      'E':createAutosig;
      '?':Begin
            Println(' -Auto-Signature Help- ');
            Println('Edit   - Edit or Creator AutoSig');
            Println('Delete - Removes/Deletes AutoSig');
          End;
    End
  Until (HungUpOn) or (Done)
End;

Procedure EditFileListing;

Const MaxOut=78;

Var GG:Char;
    Total:Byte;
    Leave:Boolean;

  Procedure TooBad;
  Begin
    GoXY(17,16);
    Println('You do not have enough Free Space for that option!');
    Delay(1000);
    GoXy(17,16);
    ClrEOL;
  End;

  Procedure ShowIt;
  Begin
    Cls;
    MCiWriteln('|CM  File Listing Configuration ');
    MCiWriteln('|BXีอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ');
    MCiWriteln('|BXณ |MS[|IN1|MS] |ISFile Name   |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN2|MS] |ISFile Size   |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN3|MS] |ISFile Cost   |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN4|MS] |IS# Downloads |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN5|MS] |ISUploader    |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN6|MS] |ISUpload Date |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN7|MS] |ISDescription |BXณ                                                           ณ');
    MCiWriteln('|BXณ |MS[|IN8|MS] |ISFile_ID.DIZ |BXณ                                                           ณ');
    MCiWriteln('|BXิอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ');
    MCiWriteln('    |RETotal:                                                             |MS(|INQ|MS)|PRuit  ');
  End;

  Procedure SmartWrite(X,Y,Len:Byte; B,Sub:Boolean);
  Begin
    AColor(Urec^.StatColor);
    GoXY(X,Y);
    If B Then
    Begin
      Total:=Total+Len;
      Print('Yes')
    End
   Else
    Begin
      If Sub Then Total:=Total-Len;
      Print('No ');
    End;
    GoXY(12,12);
    Print(Strr(Total)+'   ');
  End;

  Procedure Example;
  Begin
    GoXY(1,14);
    With Urec^ Do
    Begin
      Print('A ');
      If FileList[1] Then Print(TabStr('SHCKWAVE.EXE',13));
      If FileList[2] Then Print(TabStr('500k',5));
      If FileList[3] Then Print(TabStr('Free',5)); 
      If FileList[4] Then Print(TabStr('100',4));
      If FileList[5] Then Print(TabStr('iCE Breaker',25));
      If FileList[6] Then Print(TabStr(DateStr(Now),10));
      If FileList[7] Then Print('ShockWavE:PRO BBS Software v.'+VerStr);
      If FileList[8] Then Print('FILE_ID.DIZ');
    End;
    ClsEOL;
  End;

  Procedure ShowCurStats;
  Begin
    ShowIt;
    Total:=0;
    SmartWrite(21,3,13,Urec^.FileList[1],False);
    SmartWrite(21,4,5,Urec^.FileList[2],False);
    SmartWrite(21,5,5,Urec^.FileList[3],False);
    SmartWrite(21,6,3,Urec^.FileList[4],False);
    SmartWrite(21,7,25,Urec^.FileList[5],False);
    SmartWrite(21,8,10,Urec^.FileList[6],False);
    SmartWrite(21,9,40,Urec^.FileList[7],False);
    SmartWrite(21,10,25,Urec^.FileList[8],False);
    Example;
  End;

  Procedure GetuserInput;
  Begin
    Repeat
      Repeat
        GetChar(GG);
        If Length(GG)=0 then GG:=' '; GG:=Upcase(GG);
      Until (Pos(GG,'12345678Q') >0) or HungUpOn;

    Urec^.FileList[Valu(GG)]:=Not Urec^.FileList[Valu(GG)];

    Case GG Of
      '1':Begin
            If Urec^.FileList[1] Then SmartWrite(21,3,13,Urec^.Filelist[1],False)
            Else SmartWrite(21,3,13,Urec^.Filelist[1],True);
            If Total>MaxOUt then
            Begin
              Urec^.FileList[1]:=False;
              TooBad;
              SmartWrite(21,3,13,Urec^.FileList[1],True);
            End;
          End;

      '2':Begin
            If Urec^.FileList[2] Then SmartWrite(21,4,5,Urec^.FileList[2],False)
            Else SmartWrite(21,4,5,Urec^.Filelist[2],True);
            If Total>MaxOUt then
            Begin
              Urec^.FileList[2]:=False;
              TooBad;
              SmartWrite(21,4,5,Urec^.FileList[2],True);
            End;
          End;

      '3':Begin
            If Urec^.FileList[3] Then SmartWrite(21,5,5,Urec^.FileList[3],False)
            Else SmartWrite(21,5,5,Urec^.Filelist[3],True);
            If Total>MaxOUt then
            Begin
              Urec^.FileList[3]:=False;
              TooBad;
              SmartWrite(21,5,5,Urec^.FileList[3],True);
            End;
          End;

    {10}
     '4':Begin
           If Urec^.FileList[4] Then SmartWrite(21,6,3,Urec^.FileList[4],False)
           Else SmartWrite(21,6,3,Urec^.Filelist[4],True);
           If Total>MaxOUt then
           Begin
             Urec^.FileList[4]:=False;
             TooBad;
             SmartWrite(21,6,3,Urec^.FileList[4],True);
           End;
         End;
 
   {40}
     '5':Begin
           If Urec^.FileList[5] Then SmartWrite(21,7,25,Urec^.FileList[5],False)
           Else SmartWrite(21,7,25,Urec^.Filelist[5],True);
           If Total>MaxOUt then
           Begin
             Urec^.FileList[5]:=False;
             TooBad;
             SmartWrite(21,7,25,Urec^.FileList[5],True);
           End;
         End;

    {11}
     '6':Begin
           If Urec^.FileList[6] Then SmartWrite(21,8,10,Urec^.FileList[6],False)
           Else SmartWrite(21,8,10,Urec^.Filelist[6],True);
           If Total>MaxOUt then
           Begin             
             Urec^.FileList[6]:=False;
             TooBad;
             SmartWrite(21,8,10,Urec^.FileList[6],True);
           End;
         End;
  
     {6}
     '7':Begin
           If Urec^.FileList[7] Then SmartWrite(21,9,40,Urec^.FileList[7],False)
           Else SmartWrite(21,9,40,Urec^.Filelist[7],True);
           If Total>MaxOUt then
           Begin
             Urec^.FileList[7]:=False;
             TooBad;
             SmartWrite(21,9,40,Urec^.FileList[7],True);
           End;
        End;
  
    {25}
     '8':Begin
           If Urec^.FileList[8] Then SmartWrite(21,10,25,Urec^.FileList[8],False)
           Else SmartWrite(21,10,25,Urec^.Filelist[8],True);
           If Total>MaxOUt then
           Begin
             Urec^.FileList[8]:=False;
             TooBad;
             SmartWrite(21,10,25,Urec^.FileList[8],True);
           End;
         End;
  
     'Q':Leave:=True;
  End;
  Example;
  Until Leave Or HungUpOn;
  WriteUser(Urec^);
End;

Begin
  Leave:=False;
  ShowCurStats;
  GetUserInput;
  Cls;
End;

Procedure EditScreenLen;
Begin
  Input:=Prompt(2,MyStr^.ScrLen,False);
  If (Valu(Input)<15) or (Valu(Input)>50) Then Exit;
  Urec^.Scrnlength:=Valu(Input);
  WriteUser(Urec^);
End;

Procedure NewScanSetup;
Begin
End;

Procedure EditUserNote;
Begin
  Urec^.UserNote:=Prompt(25,'User Note: ',False);
  WriteUser(Urec^);
End;

Procedure EditMenuType;
Begin
  If YeaNa(MyStr^.AskHotKeys,True) Then Urec^.MenuType:=1 Else Urec^.MenuType:=0;
  WriteUser(Urec^);
End;

Procedure EditMsgHdrType;
Var HdrTemp:Byte;
    Hold:Char;

  Procedure ViewHeader;
  Var Txtx:Text;
      Ch1,Ch2:Char;
      Chk:String[2];
  Begin
    Input:=Prompt(2,'View which header:',False);
    Cls;
    If Exist(Cnf^.MenuDir+'HEADER.'+Input) Then
    Begin
      Assign(Txtx,CNF^.MenuDir+'HEADER.'+Input);
      Reset(Txtx);
      While (Not EOF(Txtx)) Do
      Begin
        Read(Txtx,Ch1);
        If Ch1='|' Then
        Begin
          Read(Txtx,Ch2); Chk:=+Ch2;
          Read(Txtx,Ch2); Chk:=Chk+Ch2;
          Chk:=Upcase(Chk[1])+Upcase(Chk[2]);
          If Chk='MC' then Print('1') else
          If Chk='MN' Then Print('32767') else
          If Chk='MT' Then Print(TimeStr(Now)) else
          If Chk='MD' Then Print(DateStr(Now)) else
          If Chk='TO' Then Print(MyStr^.ToAllStr) else
          If Chk='FR' Then Println(Urec^.Handle) else
          If Chk='TI' Then Print('Testing Message Headers!') else
          If Chk='CB' Then Print('General Messages');
          If Chk='O1' Then Print('Origin1') else
          If Chk='O2' Then Print('Origin2');
        End Else Print(Ch1);
      End;
      Close(Txtx);
    End;
    Input:=Prompt(1,'Hit A Key',True);
  End;

Begin
  HdrTemp:=Urec^.MsgHeader;
  Repeat
    If Exist(Cnf^.MenuDir+'MSGHDRCF.ANS') Then PrintFile(Cnf^.MenuDir+'MSGHDRCF.ANS');
    Input:=Prompt(1,'Message Header Type (V/View - Q/Quit):',False);
    Hold:=Input[1];
    If Upcase(Hold)='V' then ViewHeader;
  Until Exist(Cnf^.MenuDir+'HEADER.'+Hold) and (Upcase(Hold)<>'V') or (Upcase(Hold)='Q') or (Valu(Hold)=0) or (HungUpOn);
  If Exist(Cnf^.MenuDir+'HEADER.'+Hold) or (Valu(Hold)=0) Then Urec^.MsgHeader:=Valu(Hold)
  else Urec^.MsgHeader:=HdrTemp;
  WriteUser(Urec^);
End;

Procedure EditEmulation;
Begin
  Input:=Prompt(1,MyStr^.AskANSi,Urec^.MenuType=1);
    Case Upcase(Input[1]) Of
    'N':Emulation:=0;
    'A':Emulation:=1;
    'M':Emulation:=2;
    'R':Emulation:=3;
    'V':Emulation:=4;
    'S':Emulation:=9;
   Else Emulation:=1;
  End;
End;


Procedure CustomUConfig; { for custom fullscreen user config menu }
Var T:File;
    Z,Ch1,Ch2:Char;
    Chk:String[2];
    OpCnt,Cnt:Word;
    NumRead:Word;
    Buf:Array[1..4096] of Char;
    Tim:Byte;

  Procedure GetOpXy(X:Byte);
  Begin
    OpXY[X].X:=WhereX;
    OpXY[X].Y:=WhereY;
  End;

Begin
  OpCnt:=0;
  If Exist(CNF^.MenuDir+'USERCNF.ANS') Then
  Begin
    Assign(T,CNF^.MenuDir+'USERCNF.ANS');
    Reset(T,1);
      Repeat
        Cnt:=1;
        FillChar(Buf,SizeOf(Buf),#0);
        BlockRead(T,Buf,Sizeof(buf),NumRead);
        Repeat
          If Buf[Cnt]='%' Then
          Begin
            Inc(Cnt);
            Chk:=Upcase(Buf[Cnt])+Upcase(Buf[Cnt+1]);
            Inc(Cnt);
            If Chk='C1' Then Begin AColor(Urec^.RegularColor); Print(' Color '); GetOpXY(1) End Else { Color  }
            If Chk='C2' Then Begin AColor(Urec^.StatColor); Print(' Color ');GetOpXY(2) End Else { Color  }
            If Chk='C3' Then Begin AColor(Urec^.PromptColor); Print(' Color ');GetOpXY(3) End Else { Color  }           
            If Chk='C4' Then Begin AColor(Urec^.InputColor); Print(' Color ');GetOpXY(4) End Else { Color  }
            If Chk='C5' Then Begin AColor(Urec^.InsideColor); Print(' Color ');GetOpXY(5) End Else { Color  }
            If Chk='C6' Then Begin AColor(Urec^.BoxColor); Print(' Color ');GetOpXY(6) End Else { Color  }
            If Chk='C7' Then Begin AColor(Urec^.MiscColor); Print(' Color ');GetOpXY(7) End Else { Color  }           
            If Chk='C8' Then Begin AColor(Urec^.CmdColor); Print(' Color ');GetOpXY(8) End Else { Color  }
            If Chk='AS' Then GetOpXY(9) Else { AutoSig  }
            If Chk='FL' Then GetOpXY(10) Else { FileList  }
            If Chk='SL' Then Begin Print(Strr(Urec^.Scrnlength)); GetOpXY(11) End Else { Screen Length  }
            If Chk='8B' Then Begin If (Graphics in Urec^.Config) Then Print('Yes') Else Print('No');GetOpXY(12) End Else
            If Chk='HT' Then Begin Print(Strr(Urec^.MsgHeader)); GetOpXY(13) End Else { MsgHdr Type  }
            If Chk='EM' Then Begin Print(Strr(Emulation)); GetOpXY(14) End Else { Emulation  }
            If Chk='MT' Then Begin If Urec^.MenuType=1 Then Print('One Key') Else Print('Normal'); GetOpXY(15) End Else
            If Chk='UN' Then Begin Print(Urec^.UserNote); GetOpXY(16); End;    { User Note }
          End Else Print(Buf[Cnt]);
          Inc(Cnt);
        Until (Buf[Cnt]=#0) or (HungUpOn);
      Until (Numread=0) or (HungUpOn);
      Close(T);
    End

    

End;

Begin
End.