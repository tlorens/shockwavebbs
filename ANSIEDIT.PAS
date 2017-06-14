{ 
  iB * 03/12/96 - OLD ShockWavE:PRO FSE Converted for use with new v1.00!
                  This is just a temporary thing until we get a REAL editor
                  in place.

  iB * 04/23/96 - OLD style quoting is in place. Will switch to Searchlights
                  fullscreen quoting method.
 
}
Unit ANSiEdit;    (* Ansi Full Screen Editor *)

Interface

Uses OPCrt,Dos,Records,Vars,IO,CnfgRec,windows,gensubs,Display,Misc;

Function ANSiEditor(var M:MsgTxt; Hdr:MsgHdr; ID:Longint):boolean;

implementation

Function AnsiEditor(var m:MsgTxt; Hdr:MsgHdr; ID:LongInt):boolean;

Var TopLine,CurLine,CX,CY,Cols,ScrnSize,Lines,
    RightMargin,SavedX,SavedY,TopScrn:Integer;
    SigMode,insertmode,msgdone:boolean;

  Procedure QuoteMsg;
  Var X:Integer;
      Start,Nd:Byte;
      Doit:Boolean;

    Procedure Getline;
    Var getlines:boolean;
    Begin
      Input:=Prompt(3,'|03End line |08(|11'+Strr(QMsg.NumLines-1)+'|08)|07:',False);
      If ((Valu(Input)=0) or (Valu(Input)<Start) or (Valu(Input)>QMsg.NumLines-1)) then ND:=QMsg.NumLines-1 else
      ND:=valu(input);
      if (Start>=1) and (ND>=Start) and (Start<=QMsg.numlines-1) and
      (ND<=QMsg.numlines-1) then GetLines:=true
     else
      begin
        Start:=1;
        ND:=7;
      end
    end;

    Procedure QuoteAll;
    Begin
      Start:=1;
      ND:=QMsg.NumLines;
    End;

  Procedure AskQuote;
  Var Cnt:Byte;
  Begin
    If Not Doit then Exit;
    Input:=Prompt(3,'|03Start of Quote or |08(|11A|08)|03ll|07:',False);
    If (Upcase(Input[1])='A') or (Length(Input)=0) then QuoteAll Else
    Begin
      Start:=Valu(Input);
      If Start=0 Then
      Begin
        Start:=0;
        ND:=0;
        Exit;
      End;
      GetLine;
    End;
  End;
  
  PROCEDURE WordWrap(VAR S,S1:string);
  VAR I,B:Byte;
  Begin
    S1:='';
    I:=Length(S)+1;
    Repeat Dec(I); Until (S[I]=#32) or (I=0);
    If I=0 then Exit;
    For B:=I+1 to Length(S) do S1:=S1+S[B];
    Repeat Dec(S[0]); Until (Length(S)=I);
    Dec(S[0]);
  End;


  Function StripInc(O:String):String;
  Var Tmp:String[80];
  Begin  
    If Pos('|%%',O)>0 Then 
    Begin
      tmp:='<';
      Tmp:=Tmp+O+'>';
      O:=Tmp;
      Delete(O,Pos('|%%',O),3);
    End;
    StripInc:=O;
  End;

  Var Cnt,Cnt2,Numlines,
      N,PriorLines:Byte;
      St1,QuoteString:string[80];
      LB:Str25;
      Ch1,Ch2:Char;

  Begin
    Doit:=True;
    If QMsg.NumLines=0 Then Exit;
    WriteHdr('Quoting Message');
    For X:=1 to QMsg.NumLines-1 Do MCiPrintln('|11'+Strr(X)+'|03)|07 '+StripInc(QMsg.Text[X]));
    AskQuote;
    If Start=0 then Exit;
    NumLines:=ND-Start+1;
    PriorLines:=M.NumLines;
    M.Numlines:=M.Numlines + NumLines;

    LB:=QHdr.From;

    Ch1:=LB[1];
    If Pos(' ',LB)>0 Then Ch2:=LB[Pos(' ',LB)+1];
    cnt:=0;

    QuoteString:='|08-|14=|15] |12|UH |15[|14=|08-';
    if LB='' Then LB:='[DELETED User]';
    If QHdr.Anon Then M.Text[priorlines]:='|ISÄÄ|IN=|ST]|PR Quoting '+MyStr^.AnonymousStr+' |ST[|IN=|ISÄÄ|RE' Else
    M.Text[priorlines]:='|ISÄÄ|IN=|ST]|PR Quoting '+LB+' |ST[|IN=|ISÄÄ|RE';
    If QHdr.Anon then Begin Ch1:='X'; Ch2:='X'; End;

    M.Text[priorlines+1]:='';
    Cnt2:=0;
    For CNT:=Start To Nd Do
    Begin
      Inc(cnt2);
      If Pos(' ',LB)>0 Then M.Text[PriorLines+cnt2+1]:=Ch1+Ch2+'> '+StripInc(QMsg.Text[cnt])
      Else M.Text[PriorLines+cnt2+1]:=Ch1+'> '+StripInc(QMsg.Text[cnt]);
    End;
    M.Numlines:=PriorLines+cnt2+2; m.Text[M.NumLines]:='|RE';
    M.Numlines:=PriorLines+cnt2+3; M.Text[M.Numlines]:='';
    CurLine:=M.Numlines;
  End;

  Function CurX:Integer;
  Begin
    CurX:=WhereX;
  End;

  Function CurY:Integer;
  Begin
    CurY:=WhereY-TopScrn+1;
  End;

  Procedure MoveTo(X,Y:Integer);
  Begin
    Y:=Y+TopScrn-1;
    Print(#27'[');
    If Y<>1 Then Print(Strr(Y));
    If X<>1 Then Print(';'+Strr(X));
    Print('H');
  End;

  Procedure CMove(K:Char; N:Byte); { [A,[B,[C,[D Cursor Movements }
  Begin
    If N<1 then Exit;
    Print(#27'[');
    If N<>1 Then Print(Strr(N));
    Print(K)
  End;


  Procedure Cup(N:Byte);  (* Cursor Up *)
  Begin
    If Emulation in [1,2,3] Then CMove('A',N) Else
  End;

  Procedure Cdn(N:Byte);  (* Cursor Down *)
  Begin
    CMove('B',N);
  End;

  Procedure Clf(N:Byte); (* Cursor Left *)
  Begin
    CMove('D',N)
  End;

  Procedure Crg(N:Byte); (* Cursor Right *)
  Begin
    CMove('C',N)
  End;

  Procedure CheckSpaces;
  Var q:^Str80;
  Begin
    Q:=Addr(m.Text[curline]);
    While Q^[length(q^)]=' ' do q^[0]:=pred(q^[0])
  End;

  Procedure checkcx;  (* Gets Cursor X Cord. *)
  var n:integer;
  Begin
    N:=length(m.Text[curline])+1;
    if cx>n then cx:=n
  End;

  procedure computecy;  (* Get Cursor Y Cord. *)
  begin
    cy:=curline-topline+1;
  end;

  procedure updatecpos;
  begin
    computecy;
    moveto(cx,cy);
  end;

  procedure insertabove;
  var cnt:integer;
  begin
    if m.numlines=maxmessagesize then exit;
    for cnt:=m.numlines downto curline do m.Text[cnt+1]:=m.Text[cnt];
    m.Text[curline]:='';
    m.numlines:=m.numlines+1
  end;

  procedure deletethis;
  var cnt:integer;
  begin
    if m.numlines=1 then
    begin
      m.Text[1]:='';
      exit
    end;
    for cnt:=curline+1 to m.numlines do m.Text[cnt-1]:=m.Text[cnt];
    m.Text[m.numlines]:='';
    m.numlines:=m.numlines-1;
    checkcx
  end;

  procedure fullrefresh;
  var cnt,n,foxx:integer;
      BkGrd,Tmp:byte;
  begin
    Cls;
    MoveTo(1,-1);
    if topline<1 then topline:=1;
    computecy;
{-4}AColor(Urec^.BoxColor);Print('Ü');
    AColor(Urec^.CmdColor);PrintLn('³ ShockWavE Pro ³ /? For Help ³            ³ AutoSig:    ³                   ³');
{-3}AColor(Urec^.BoxColor);PrintLn('ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß ');
    AColor(Urec^.CmdColor);
    MoveTo(34,-1); If InsertMode=True then Print('Insert') else Print('OverStrike');
    MoveTo(56,-1); If SigMode=True Then Print('On ') else Print('Off');
    MoveTo(1,1);
    AColor(Urec^.Regularcolor);
    for cnt:=1 to lines do
    begin
      n:=cnt+topline-1;
      if n<=m.numlines then
      begin
        Print(m.Text[n]);
        if cnt<>lines then PrintLn('');
      end
    end;
    updatecpos
  end;

  procedure repos (dorefresh:boolean);
  var cl,tl:integer;
  begin
    checkspaces;
    cl:=curline;
    tl:=topline;
    if curline<1 then curline:=1;
    if curline>m.numlines then curline:=m.numlines;
    if topline>curline then topline:=curline;
    if topline+lines<curline then topline:=curline-lines;
    if topline<1 then topline:=1;
    checkcx;
    computecy;
    if (cl=curline) and (tl=topline) and (not dorefresh) then updatecpos
    else fullrefresh
  end;

  procedure partrefresh;  { Refreshes from CY (Cursor Y) }
  var cnt,n:integer;
  begin
    if topline<1 then repos(true) else
    begin
      moveto (1,cy);
      for cnt:=cy to lines do
      begin
        n:=cnt+topline-1;
        if n<=m.numlines then Print (m.Text[n]);
        clseol;
        if cnt<>lines then PrintLn('');
      end;
      updatecpos
    end
  end;

  procedure pageup;
  begin
    checkspaces;
    if curline>20 then exit;  { Used to be: CurLine=1 then }
    curline:=curline-lines+4;
    topline:=topline-lines+4;
    repos (true)
  end;

  procedure pagedn;
  begin
    checkspaces;
    if curline=m.numlines then exit;
    curline:=curline+lines-4;
    topline:=topline+lines-4;
    repos (true)
  end;

  procedure toggleins;
  Var bkgrd,Tmp:Byte;
  begin
    insertmode:=not insertmode;
    MoveTo(34,-2);
    AColor(Urec^.CmdColor);
    If InsertMode=true then Print('Insert     ') else Print('Overstrike');
    AColor(Urec^.RegularColor);
    UpdateCpos;
  end;

  Procedure ToggleSig;
  Var Tmp,bkgrd:Byte;
  Begin
    SigMode:=Not SigMode;
    MoveTo(56,-2);
    AColor(Urec^.CmdColor);
    If SigMode=True then Print('On ') else Print('Off');
    AColor(Urec^.RegularColor);
    UpdateCPos;
  End;

  procedure scrolldown;
  begin
    topline:=curline-lines+2;
    repos (true)
  end;

  procedure scrollup;
  begin
    if topline<1 then
    begin
      topline:=topline+1;
      moveto (1,lines);
      computecy;
      PrintLn('');
    end
   else
    begin
      topline:=curline-1;
      repos (true)
    end
  end;

  procedure topofmsg;
  begin
    checkspaces;
    cx:=1;
    cy:=1;
    curline:=1;
    if topline=1 then updatecpos else
    begin
      topline:=1;
      fullrefresh
    end
  end;

  procedure updatetoeol;
  var cnt:integer;
  begin
    SaveXY;
    Print (copy(m.Text[curline],cx,255));
    clseol;
    RestoreXY;
  end;

  procedure letterkey (k:char);
  var l:^Str80;
      w:Str80;
   n,ox:integer;
      q:char;
    inserted,refr:boolean;

    procedure scrollwwrap;
    begin
      if topline>0 then
      begin
        scrollup;
        exit
      end;
      cy:=cy-1;
      moveto (length(m.Text[curline-1])+1,cy);
      clseol;
      PrintLn('');
      Print (m.Text[curline]);
      topline:=topline+1;
      cx:=curx
    end;

  begin
    l:=addr(m.Text[curline]);
    if length(l^)>=rightmargin then
    begin
      if curline=maxmessagesize then exit;
      if cx<=length(l^) then exit;
      l^:=l^+k;
      w:='';
      cx:=length(l^);
      repeat
        q:=l^[cx];
        if q<>' ' then insert (q,w,1);
        cx:=cx-1
      until (q=' ') or (cx<1);
      if cx<1 then
      begin
        cx:=length(l^)-1;
        w:=k
      end;
      l^[0]:=chr(cx);
      checkspaces;
      curline:=curline+1;
      if curline>m.numlines then m.numlines:=curline;
      inserted:=m.Text[curline]<>'';
      if inserted then insertabove;
      m.Text[curline]:=w;
      cy:=cy+1;
      ox:=cx;
      cx:=length(w)+1;
      refr:=cy>lines;
      if refr then scrollwwrap else
      begin
        if length(w)>0 then
        begin
          moveto (ox+1,cy-1);
          for n:=1 to length(w) do Print (' ')
        end;
        if inserted and (m.numlines>curline) then partrefresh else
        begin
          moveto (1,cy);
          Print (m.Text[curline]);
        end
      end;
      exit
    end;
    if insertmode then insert(k,l^,cx) else
    begin
      while length(l^)<cx do l^:=l^+' ';
      l^[cx]:=k
    end;
    if k=#27 then Print(k) else Print (k);
    cx:=cx+1;
    if insertmode and (cx<=length(l^)) then updatetoeol
  end;

  procedure back;
  begin
    if cx=1 then
    begin
      if curline=1 then exit;
      checkspaces;
      curline:=curline-1;
      cy:=cy-1;
      cx:=length(m.Text[curline])+1;
      if cy<1 then scrolldown else updatecpos;
    end
   else
    begin
      cx:=cx-1;
      clf(1)
    end
  end;

procedure fowrd;
begin
  if cx>length(m.Text[curline]) then begin
    if curline=maxmessagesize then exit;
    checkspaces;
    curline:=curline+1;
    if curline>m.numlines then m.numlines:=curline;
    cy:=cy+1;
    cx:=1;
    if cy>lines then scrollup else updatecpos
  end else begin
    cx:=cx+1;
    crg (1)
  end
end;

procedure del;
begin
  if length(m.Text[curline])=0 then
  begin
    deletethis;
    partrefresh;
    exit
  end;
  delete (m.Text[curline],cx,1);
  if cx>length(m.Text[curline]) then Print (' '^H) else updatetoeol;
end;

procedure bkspace;
begin
  if length(m.Text[curline])=0 then
  begin
    if curline=1 then exit;
    deletethis;
    checkspaces;
    curline:=curline-1;
    cy:=cy-1;
    cx:=length(m.Text[curline])+1;
    if cy<1 then scrolldown else partrefresh;
    exit;
  end;
  if cx=1 then exit;
  cx:=cx-1;
  Print(^H);
  del;
end;

procedure beginline;
begin
  if cx=1 then exit;
  cx:=1;
  updatecpos
end;

procedure endline;
var dx:integer;
begin
  dx:=length(m.Text[curline])+1;
  if cx=dx then exit;
  cx:=dx;
  updatecpos
end;

procedure upline;
var chx:boolean;
    l:integer;
begin
  checkspaces;
  if curline=1 then exit;
  curline:=curline-1;
  l:=length(m.Text[curline]);
  chx:=cx>l;
  if chx then cx:=l+1;
  cy:=cy-1;
  if cy>0 then if chx then updatecpos else cup (1) else scrolldown
end;

procedure downline;
var chx:boolean;
    l:integer;
begin
  checkspaces;
  if curline=maxmessagesize then exit;
  curline:=curline+1;
  if curline>m.numlines then m.numlines:=curline;
  l:=length(m.Text[curline]);
  chx:=cx>l;
  if chx then cx:=l+1;
  cy:=cy+1;
  if cy<=lines then if chx then updatecpos else cdn (1) else scrollup
end;

procedure insertline;
begin
  if m.numlines>=maxmessagesize then exit;
  insertabove;
  checkcx;
  partrefresh
end;

procedure crlf;
var k:char;
begin
  beginline;
  downline
End;

function conword:boolean;
var l:^Str80;
begin
  l:=addr(m.Text[curline]);
  conword:=false;
  if (cx>length(l^)) or (cx=0) then exit;
  conword:=true;
  if cx=1 then exit;
  if (l^[cx-1]=' ') and (l^[cx]<>' ') then exit;
  conword:=false
end;

procedure wordleft;
begin
  repeat
    cx:=cx-1;
    if cx<1 then begin
      if curline=1 then begin
        cx:=1;
        repos (false);
        exit
      end;
      checkspaces;
      curline:=curline-1;
      cy:=cy-1;
      cx:=length(m.Text[curline])
    end;
  until conword;
  if cx=0 then cx:=1;
  if cy<1
    then repos (true)
    else updatecpos
end;

procedure wordright;
begin
  repeat
    cx:=cx+1;
    if cx>length(m.Text[curline]) then begin
      if curline=m.numlines then begin
        repos (false);
        exit
      end;
      checkspaces;
      curline:=curline+1;
      cy:=cy+1;
      cx:=1
    end;
  until conword;
  if cy>lines then repos (true) else updatecpos;
end;

procedure worddel;
var l:^Str80;
    b:byte;
    s,n:integer;
begin
  l:=addr(m.Text[curline]);
  b:=length(l^);
  if cx>b then exit;
  s:=cx;
  repeat
    cx:=cx+1
  until conword or (cx>b);
  n:=cx-s;
  delete (l^,s,n);
  cx:=s;
  updatetoeol
end;

procedure deleteline;
begin
  deletethis;
  partrefresh
end;

procedure help;
var k:char;
begin
  Cls;
  printfile(CNF^.MenuDir+'EDITHELP');
  Hitkey;
  fullrefresh
end;

procedure breakline;
begin
  if (m.numlines>=maxmessagesize) or (cy=lines) or
    (cx=1) or (cx>length(m.Text[curline])) then exit;
  insertabove;
  m.Text[curline]:=copy(m.Text[curline+1],1,cx-1);
  delete (m.Text[curline+1],1,cx-1);
  partrefresh
end;

procedure joinlines;
var n:integer;
begin
  if curline=m.numlines then exit;
  if length(m.Text[curline])+length(m.Text[curline+1])>rightmargin then exit;
  m.Text[curline]:=m.Text[curline]+m.Text[curline+1];
  n:=cx;
  curline:=curline+1;
  deletethis;
  curline:=curline-1;
  cx:=n;
  partrefresh
end;

{procedure centerline;
var spaces:Str80;
begin
 fillchar (spaces[1],80,32);
 delete(input,1,1);
  while (length(input)>0) and (input[1]=' ') do delete (input,1,1);
  if length(input)=0 then exit;
  spaces[0]:=chr((cols-length(input)) div 2);
  input:=spaces+input;
  insertline;
end;}

Function AnyMsg:Boolean;
Var X:Byte;
Begin
  AnyMsg:=False;
  For X:=1 to M.NumLines Do If Length(M.Text[X])>0 Then AnyMsg:=True;
End;

Procedure AbortMsg;

 Function AreYouSure:Boolean;
 Begin
   YN:=YeaNa('Abort: ',False);
   BackSpace(1,Curline+3,16);
   Cup(1);
   AreYouSure:=YN;
 End;

 Var b:MsgTxt;
 Begin
   If AreYouSure Then
   Begin
     ANSiEditor:=False;
     M.numlines:=0;
     MsgDone:=True;
   End
 End;

 Procedure SaveMsg;
 Begin
   MsgDone:=True;
   If (M.NumLines>0) and (AnyMsg) then ANSiEditor:=True Else ANSiEditor:=False;
  End;

 Procedure FormatText;
   var ol,il,c:integer;
      oln,wd,iln:Str80;
      k:char;

    procedure putword;
    var cnt:integer;
        b:boolean;
    begin
      b:=true;
      for cnt:=1 to length(wd) do if wd[cnt]<>' ' then b:=false;
      if b then exit;
      while wd[length(wd)]=' ' do wd[0]:=pred(wd[0]);
      if length(wd)=0 then exit;
      if length(wd)+length(oln)>rightmargin then begin
        m.Text[ol]:=oln;
        ol:=ol+1;
        while (wd[1]=' ') and (length(wd)>0) do delete (wd,1,1);
        oln:=wd
      end else oln:=oln+wd;
      if wd[length(wd)] in ['.','?','!']
        then wd:='  '
        else wd:=' '
    end;

  begin
    il:=curline;
    ol:=il;
    c:=1;
    oln:='';
    wd:='';
    iln:=m.Text[il];
    repeat
      if length(iln)=0 then
      begin
        putword;
        m.Text[ol]:=oln;
        partrefresh;
        checkcx;
        updatecpos;
        exit
      end;
      if c>length(iln) then
      begin
        il:=il+1;
        if il>m.numlines then iln:='' else
        begin
          iln:=m.Text[il];
          m.Text[il]:=''
        end;
        c:=0;
        k:=' '
      end else k:=iln[c];
      c:=c+1;
      if k=' ' then putword else wd:=wd+k
    until 0=1
  end;


Procedure Userescape;
Var k:char;
Begin
  Repeat
  GetChar(K);
  Case K Of
    'A':upline;
    'B':downline;
    'C':fowrd;
    'D':back;
    'H':BeginLine;
    'K':EndLine;
    'O':Begin
          GetChar(K);
          Case K Of
            'P':Help;
          End;
        End;
    End
    Until (K<>'[') Or Hungupon;
    If HungUpOn then HangUP;
End;

Procedure DeleteEol;
Begin
  ClsEol;
  M.Text[Curline][0]:=chr(cx-1)
End;

Procedure Tab;
Var nx,n,cnt:integer;
Begin
  nx:=((cx+8) and 248)+1;
  n:=nx-cx;
  if (n+length(m.Text[curline])>=cols) or (nx>=cols) then exit;
  for cnt:=1 to n do insert (' ',m.Text[curline],cx);
  UpdatetoEol;
  cx:=cx+n;
  updatecpos
End;

Procedure ExtendedCmds;
Begin
  Input:=Prompt(1,MyStr^.EditCmd,Urec^.MenuType=1);
  If Length(Input)=0 then Input:='C';
  Case UpCase(Input[1]) of
   '?':Begin
         Help;
         ExtendedCmds;
       End;
   'S':SaveMsg;
   'A':AbortMsg;
   'Q':Begin
         QuoteMsg;
         FullReFresh;
       End;
   Else BackSpace(1,Curline+2,34);
  End;
  BackSpace(1,Curline+2,34);
End;

Procedure Processkey;
var k:char;
begin
  GetChar(K);
  If K=#0 Then 
  Begin
    GetChar(K);
    Case K Of
      'P':DownLine;
      'M':Fowrd;
      'H':Upline;
      'K':Back;
      'G':BeginLine;
      'O':EndLine;
      'S':Del;
      'R':ToggleIns;
      'I':PageUp;
      'Q':PageDn;
      ';':Help;
    End;
  End
 Else
  Case K of
     '/':If length(m.Text[curline])<1 then ExtendedCmds else LetterKey(K);
     #27:userescape;
     ^S:back;
     ^D:fowrd;
     ^H:bkspace;
     ^M:crlf;
     ^V:toggleins;
     ^E:upline;
     ^X:downline;
     ^U:help;
     ^R:pageup;
     ^C:pagedn;
     ^G:del;
     ^A:wordleft;
     ^B:FormatText;
     ^F:wordright;
     ^T:worddel;
     ^Q:beginline;
     ^W:endline;
     ^L:fullrefresh;
     ^Y:deleteline;
     ^N:insertline;
     ^I:tab;
     ^B:breakline;
     ^P:deleteeol;
     ^J:joinlines;
     ^O:ToggleSig;
     #127:Del;
     ' '..#255:letterkey (k);
     End;
end;

var cnt:integer;
    mp:boolean;
begin
  ANSiEditor:=False;
  If Not (Emulation In [1,2,3,4,9]) Then
  Begin
    Println('Full screen editing, requires ANSi Emulation!'+^M+^M);
    Exit;
  End;

  for cnt:=m.numlines+1 to maxmessagesize do m.Text[cnt]:='';
  scrnsize:=24;
  cols:=80;
  mp:=moreprompts in urec^.config;
  if mp then urec^.config:=urec^.config-[moreprompts];
  lines:=scrnsize-2;
  topscrn:=scrnsize-lines+1;
  SIgMode:=True;
  insertmode:=True;
  rightmargin:=cols-2;
  msgdone:=false;
  cx:=1;
  curline:=1;
  topline:=2-lines;
  computecy;
  updatecpos;
  if m.numlines>0 then fullrefresh
 else
  begin
    M.NumLines:=1;
    FullRefresh;
  end;
  Repeat
    ProcessKey;
  Until (MsgDone) or (HungUpOn);
  If HungUpOn then HangUP;

  If (M.NumLines>=1) and (AnyMsg) Then  
  Begin
    If (Sigmode) and (Urec^.AutoSig.Length>0) and (Not Hdr.Anon) Then
    Begin
      If Hdr.Title='(HideMySig)' then Exit;
      M.Numlines:=M.NumLines-1;
      For cnt:=1 to Urec^.AutoSig.Length do m.Text[m.numlines+cnt]:=Urec^.AutoSig.Line[cnt];
      M.NumLines:=M.NumLines+Urec^.AutoSig.Length;
    End;
  End;
  if mp then urec^.config:=urec^.config+[moreprompts];
  GoXY(1,24);
{  GoXY(1,Urec^.ScrnLength);}

end;

end.
