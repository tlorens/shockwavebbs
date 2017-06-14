{ 
  DP * 05/10/95 - ShockScript v1.00 - script language which is as easy to 
                  use as batch files, but with expanded capabilities of a 
                  real programming language.
  iB * 04/04/96 - Create this ShkScrpt Unit. Found that MyLib & 
                  TPString are missing!  Won't Compile!
  iB * 01/04/97 - Found TPString.. MyLib still missing... Going to try to 
                  recreate.
}
Unit ShkScrpt;

Interface

Function RunScript(ScrName: String):integer;

Implementation

uses ScrMark,
     ScrErr,
     ScrVars,
     ScrMisc,

     IO,
     opcrt,
     MyLib,
     TpString,
     GenSubs,
     Parser,
     User,Records;


const
  maxSubs = 20;

  {subroutines}
  forLoop = 1;
  repeatLoop = 2;
  GosubLoop = 3;
  whileLoop = 4;

type
  {record used to keep track all loops and subroute calls... commands
   GOSUB...RETURN, FOR...NEXT, WHILE...ENDWHILE, REPEAT...UNTIL use this}
  subType = record
    location,
    subType : array [1..maxSubs] of integer;
  end;

  scrPtr = ^ScriptRec;
  ScriptRec = record
    Line : string;
    LineNum : integer;
    next : scrPtr;
  end;

var
  FinishedReading : boolean;
  script : text;
  nextline : string;
  error : integer;
  subs : ^subType;


  decimals : byte; {decimal places to use when calculating. default = 0}

  ScrHead,
  ScrTail,
  CurPtr : scrPtr;

  i : integer;

{allow for mutual recursion}
procedure ProcessLine; forward;

(*** OPEN SCRIPT AND READ IT IN *******************************************)
Function OpenScript (name: string): integer;
Var
  ln,tmp : string;
  i : integer;
Begin
  i := 0;
  assign(script, name);
  reset(script);

  While (Not EOF(Script)) do
  Begin
    i := i + 1;
    Readln (script, ln);

    Tmp:=TrimLead(LN);

    If (Tmp[1]<>'#') or (length(Tmp)>0) Then
    Begin
      if ScrHead = nil then
      begin
        New (scrHead);
        scrHead^.line := ln;
        scrHead^.lineNum := i;
        scrHead^.next := nil;
        scrTail := ScrHead;
      end
     else 
      begin
        new (scrTail^.next);
        if scrHead = scrTail then
          scrHead^.next := scrTail^.next;
        scrTail := scrTail^.next;
        ScrTail^.line := ln;
        scrTail^.linenum := i;
        scrTail^.next := NIL;
      end;
    End;
  end;

  close (script);

  curPtr := ScrHead;

  {get first line}
  nextline := curptr^.line;

end;

(*** GET NEXT LINE ********************************************************)
procedure getNextLine;
begin
  if not (curPtr^.next = NIL) then
  begin
    curptr := curptr^.next;
    nextline := curptr^.line;
  end

  else
    finishedreading := true;
end;

(*** GOTO *****************************************************************)
procedure gotoLabel (where: string);
var
  lb, lbtest : string;
  _empty : string;
  num : integer;
begin
  curPtr := ScrHead;

  Split(where, lb, _empty);

  Writeln(lb);

  lb := ':' + lb;

  while not (curPtr=NIL) do
  begin
    lbtest := curPtr^.line;
    curPtr := curPtr^.next;

    if curPtr=NIL then tellError (labelNotFound);

    lbtest := trim (lbtest);
    upCaseStr (lbtest);

    if lb = lbtest then
    begin
      {we are going back to the line before this one}
      num := curPtr^.linenum;
      curPtr := ScrHead;
      repeat
        curPtr := curPtr^.next;
      until curPtr^.linenum = num  - 1;

      Exit;
    end;
  end;
end;

procedure GetEmptySlot (loopType : byte);
var
  emptySlot : integer;
begin
  emptySlot := -1;

  for i := maxSubs downto 1 do
  begin
    if subs^.location [i] = 0 then
      emptySlot := i;
  end;
  if emptySlot = -1 then
    TellError (Overflow);

  subs^.location [emptySlot] := curPtr^.lineNum;
  subs^.subType [emptySlot] := loopType;
end;

procedure GotoLine (where: integer);
var
  lineTest : integer;
begin
  curPtr := ScrHead;

  while not (curPtr=NIL) do
  begin
    lineTest := curPtr^.linenum;
    curPtr := curPtr^.next;

    if curPtr=NIL then TellError (genError);

    if where = lineTest then Exit;
  end;
  if curPtr = NIL then FinishedReading := TRUE;
end;

(*** FOR ******************************************************************)
procedure DoFor (where: string);
var
  test: integer;
  mySet : charSetType;
  variable,
  morestuff,
  val1, val2: string;
  step,
  intval1, intval2 : integer;
  position : integer;
  tempVal, tempVal2: string;
begin
  GetEmptySlot (forLoop);

  UpCaseStr (where);
  step := 1;
  val1 := '';
  val2 := '';

  mySet := ['='];
  SpecialSplit (where, variable, morestuff, mySet);

  for i := 1 to length (morestuff) do
  begin
    {we're looking for a ' TO ' ... in FOR x = y TO z}
    if (morestuff [i] = ' ') and (morestuff [i+1] = 'T') and
       (morestuff [i+2] = 'O') and (morestuff [i+3] = ' ') then
    begin
      val1 := Copy (morestuff, 1, i - 1);
      val2 := Copy (morestuff, i + 3, length (morestuff) {- (i + 4)});
      i := length (morestuff);
    end;
  end;

  if (val1 = '') or (val2 = '') then
    TellError (genError);

  Position := Pos (' STEP ', val2);
  if Position <> 0 then
  begin
    tempVal := Copy (val2, 1, Position);
    tempVal2 := Copy (val2, Position + 6, Length (val2) - (Position + 6));
    val2 := tempVal;
    if not str2int (tempVal2, step) then {attempt to convert to an int}
      TellError (genError);
  end;

  val1 := calc (expandvars (val1));
  val2 := calc (expandvars (val2));

  if (not str2int (val1, intval1)) or (not str2int (val2, intval2)) then
    TellError (genError);

  val1 := long2str (intval1);
  setVar (variable, val1);
end;

(*** PROCESS FOR **********************************************************)
function ProcessFor: boolean; {returns if we're finished or not}
var
  test: integer;
  mySet : charSetType;
  variable,
  morestuff,
  val1, val2: string;
  step,
  intval1, intval2 : integer;
  position : integer;
  tempVal, tempVal2: string;
  a, b: string;
  curVal : integer;
begin
  processFor := false;

  UpCaseStr (curPtr^.line);

  Split (curPtr^.line, a, b);

  step := 1;
  val1 := '';
  val2 := '';

  mySet := ['='];
  SpecialSplit (b, variable, morestuff, mySet);

  for i := 1 to length (morestuff) do
  begin
    {we're looking for a ' TO ' ... in FOR x = y TO z}
    if (morestuff [i] = ' ') and (morestuff [i+1] = 'T') and
       (morestuff [i+2] = 'O') and (morestuff [i+3] = ' ') then
    begin
      val1 := Copy (morestuff, 1, i - 1);
      val2 := Copy (morestuff, i + 3, length (morestuff) {- (i + 4)});
      i := length (morestuff);
    end;
  end;

  if (val1 = '') or (val2 = '') then
    TellError (genError);

  Position := Pos (' STEP ', val2);
  if Position <> 0 then
  begin
    tempVal := Copy (val2, 1, Position);
    tempVal2 := Copy (val2, Position + 6, Length (val2) - (Position + 6));
    val2 := tempVal;
    if not str2int (tempVal2, step) then {attempt to convert to an int}
      TellError (genError);
  end;

  val1 := calc (expandvars (val1));
  val2 := calc (expandvars (val2));

  if (not str2int (val1, intval1)) or (not str2int (val2, intval2)) then
    TellError (genError);

  tempVal := getVar (variable);
  if not str2int (tempVal, curVal) then
    TellError (genError);

  curVal := curVal + step;

  if curVal > intval2 then
    processFor := true;

  val1 := long2str (curVal);
  setVar (variable, val1);
end;

(*** NEXT *****************************************************************)
procedure DoNext;
var
  LineTest, ReturnPlace : integer;
  OrigLine : integer;
  finished : boolean;
begin
  origLine :=  curPtr^.lineNum;
  returnPlace := 0;

    for i := 1 to maxSubs do
    begin
      if (subs^.location[i] <> 0) and (subs^.subType[i] = forLoop) then
      begin
        returnPlace := subs^.location [i];
      end;
    end;



  GotoLine (returnPlace - 1);


  finished := processFor;

  if finished then
  begin
    GotoLine (origLine - 1);
    for i := 1 to maxSubs do
    begin
      if (subs^.location[i] <> 0) and (subs^.subType[i] = forLoop) then
      begin
        returnPlace := subs^.location [i];
        subs^.location [i] := 0;
        subs^.SubType  [i] := 0;
      end;
    end;
  end;
end;

(*** GOSUB ****************************************************************)
procedure GoSub (where: string);
begin
  GetEmptySlot (GoSubLoop);
  GotoLabel (where);
end;

(*** RETURN FROM GOSUB ****************************************************)
procedure Return;
var
  LineTest, ReturnPlace : integer;
begin
  returnPlace := 0;
  for i := 1 to maxSubs do
  begin
    if (subs^.location[i] <> 0) and (subs^.subType[i] = goSubLoop) then
    begin
      returnPlace := subs^.location [i];
      subs^.location [i] := 0;
      subs^.SubType [i]  := 0;
    end;
  end;

  GotoLine (returnPlace - 1)
end;

function evaluate (expr : string): boolean;
type
  compareType = set of char;
const
  compareSet = ['<', '>', '='];
var
  truth, negate : boolean;
  check, side1, side2: string;
  test1, test2: string;

begin
  truth := false;
  negate := false;
  side1 := '';
  side2 := '';

  expr := Trim (expr);
  UpCaseStr (expr);

  {check for a NOT}
  if (expr[1]='N')and(expr[2]='O')and(expr[3]='T')and(expr[4]=' ') then
  begin
    negate := true;
    Delete (expr, 1, 4);
  end;

  for i := 1 to length (expr) do
    if (expr [i] in compareSet) and (expr [i + 1] in compareSet) then
    begin
      side1 := copy (expr, 1, i - 1);
      side2 := copy (expr, i + 2, length (expr) - i + 2);
      check := expr [i] + expr [i + 1];
      side1 := trim (side1);
      side2 := trim (side2);
      i := length (expr);
    end;

  if check = '==' then
    if side1 = side2 then
      truth := true;

  if (check = '<>') or (check = '><') then
    if side1 <> side2 then
      truth := true;

  if check = '<<' then
  begin
    test1 := calc (side1);
    test2 := calc (side2);
    if test1 < test2 then
      truth := true;
  end;

  if check = '>>' then
  begin
    test1 := calc (side1);
    test2 := calc (side2);
    if test1 > test2 then
      truth := true;
  end;

  if negate then
    if truth = true then
      truth := false
    else
      truth := true;

  evaluate := truth;
end;

procedure evalIf (params: string);
var
  Position : byte;
  checkIf : string;
  finished, truth : boolean;
  testCase : string;
begin
  testCase := StUpCase (params);

  UpCaseStr (testCase);

  Position := Pos (' THEN', testCase);

  if (Position = 0)
{  or (not (Position + 4 = length(params)))
  or (not (params [Position + 5] = ' ')) } then
  begin
    TellError (ifError);
    Exit;
  end;

  checkIf := Copy (testCase, 1, Position);
  delete (params, 1, Position + 5);
  delete (testCase, 1, Position + 5);
  checkIf := Trim (checkIf);

  truth := evaluate (checkIf);

  if params = '' then
  {we've found an if .. then DoLotsCrap endif form
   now we take over the command processing and check for ELSE and ENDIF}
  begin
    finished := false;

    if truth then
    begin
      while (not finishedReading) and (error=0) and (not finished) do
      begin
        if  (not finishedReading) and (error = 0) then getNextLine;
        testCase := StUpCase (nextLine);

        if testCase = 'ENDIF' then
          Finished := true
        else if testCase = 'ELSE' then
        begin
          repeat
            if (not finishedReading) and (error = 0) then getNextLine;
            testCase := StUpCase (nextLine);
            if testCase = 'ENDIF' then
              Exit;
          until (finishedReading) or (error <> 0);
        end;
        if  (not finishedReading) and (error = 0) then processLine;
      end;

    end
    else begin {if truth = false}
      repeat
        if (not finishedReading) and (error = 0) then getNextLine;
        testCase := StUpCase (nextLine);
        if testCase = 'ELSE' then
          Exit;
      until (finishedReading) or (error <> 0);
    end;
  end
  else {we've found a simple if .. then DoCrap}
    if truth then
    begin
      nextLine := params;
      processLine;
    end;
end;

Procedure doInput(params:String);
Var inpval:String;
Begin
  Readln(inpval);
  setVars(params+'='+inpval);
End;

(* Should be able to parse |Codes *)
Procedure doPrint(Params:String);
Var X:Byte;
Begin
  For X:=1 to Length(Params) Do
  Begin
    If Params[X]='\' Then 
    Begin
      If Params[X+1]='n' Then 
      Begin
        Inc(X);
        Println('')
      End;
    End else Print(Params[X]);
  End;
End;

Procedure doColor(Params:String);
Var FG,BG:String;
Begin
  Split(Params,FG,BG);
  Trim(FG);
  Trim(BG);
  Color(Valu(FG),Valu(BG));
End;

procedure processLine;
var
  command, params: string;
begin
  Split(nextline, command, params);
  Command :=StUpCase(command);

  if command='PRINT'  then doPrint(ExpandVars(Params)) else 
  if command='VAR'    then Setvars(Params) else 
  if command='FOR'    then DoFor(Params) else 
  if command='NEXT'   then doNext else 
  if command='GOSUB'  then GoSub(Params) else 
  if command='RETURN' then Return else 
  if command='GOTO'   then GotoLabel(Params) else 
  if command='ENDIF'  then {do NOTHING when this is encountered} else 
  if command='IF'     then EvalIf(Params);
  If Command='INPUT'  then doInput(Params);
  If Command='COLOR'  then doColor(Params);
{
  GOTOXY    GotoXY Coordinates
  SAVE      Save user Record
  READ      Read User Record
  WRITELN   Writeln to text File
  READLN    Readln from text file
  YESNO     Yes/No Prompt
  BAR .BAR file 
  ANSI      Toggle ANSi
  8Bit      Toggle 8bit Graphics
}
end;

function runScript (scrName: string): integer;
var
  i : integer;
begin

  ScrHead := NIL;
  ScrTail := NIL;

  error := 0;
  finishedReading := FALSE;
  runScript := 0;

  new (subs);

  for i := 1 to maxSubs do
  begin
    subs^.subType [i] := 0;
    subs^.location [i] := 0;
  end;

  OpenScript (scrName);

  while (not finishedReading) and (error=0) do
  begin
    if  (not finishedReading) and (error = 0) then processLine;
    if  (not finishedReading) and (error = 0) then getNextLine;
  end;
  runScript  := error;

  Release (heapMarker);
end;

begin
end.