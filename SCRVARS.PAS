Unit ScrVars; {variable handling for ShockScript}

Interface

Uses
  ScrMisc,
  ScrErr,

  StrnTTT5,
  Parser,
  MyLib,
  TpString,
  IO;


Const
  maxVars = 50;
  maxVarLength = 80;

Type
  {record used to keep all variables}
  {all the variables are strings, each has a name, and a value assigned to
   it}
  varType = Record
    name  : array [1..MaxVars] of string[30];
    value : array [1..maxVars] of string[maxVarLength];
  end;

function getvar (st: string): string;
function expandVars (st : string) : string;
procedure setVars (myvars : string);
procedure setVar (name, value: string);

var
  vars : ^varType;

implementation

(*** GET VARIABLE *********************************************************)
function getvar (st: string): string;
var
  i : integer;
  gottenVar : string;
begin
  gottenVar := '';

  st := trim (st);
  upcaseStr (st);

  for i := 1 to maxVars do
  begin
    if vars^.name [i] = st then
    begin
      gottenVar := vars^.value [i];
      i := maxVars;
    end;
  end;
  getvar := gottenVar;
end;

(*** EXPAND VARIABLES *****************************************************)
function expandVars (st : string) : string;
var
  i : integer;
  outputStr : string;
  origPos : integer;
  var2add : string;
  finished, validity : boolean;
  mymacro, param: string;
  myResult : real;

begin
  outputStr := '';
  If Pos('USER.',Upper(St))>0 Then
  Begin
    { record manipulation goes here }
  End
 Else
  for i := 1 to length (st) do
  begin
    if st [i] = '%' then
    begin
      origPos := i;
      i := i + 1;
      if st [i] = '%' then
      Begin
        outputStr := outputStr + '%';   {if %% then actually show %}
      End
      else if st [i] = '@' then {goodie, we've found an internal macro!}
      begin
        macro := '';
        param := '';
        myResult := 0.0;

        i := i + 1;
        while st [i] <> '[' do
        begin
          macro := macro + st [i];
          i := i + 1;
        end;

        i := i + 1;
        while st [i] <> ']' do
        begin
          param := param + st [i];
          i := i + 1;
        end;
        macro := param;

        myResult := getExpr (validity);
        if (validity = false) then
          tellError (CalcFailed)
        else
          outputStr := outputStr + Real_to_Str (myResult, decimals);
      end
      else
      begin
        finished := false;
        while (not finished) and (i <= length (st)) do
        begin
          i := i + 1;
          if st [i] = ' ' then
          begin
            var2add := getVar (copy (st, origPos+1, i - origPos - 1));
            outputStr := outputStr + var2add + ' ';
            finished := true;
          end
          else if st [i] = '%' then
          begin
            var2add := getVar (copy (st, origPos+1, i - origPos - 1));
            outputStr := outputStr + var2add;
            finished := true;
          end;

        end;
        if i > length (st) then
        begin
          var2add := getVar (copy (st, origPos, length (st)-origPos));
          outputStr := outputStr + var2add;
          i := length (st);
        end;
      end;
    end
    else
      outputStr := outputStr + st [i];
  end;

  expandVars := outputStr;
end;

procedure setVar (name, value: string);
var
  i,
  emptySlot : integer;
  foundVar : boolean;

begin
  foundVar := false;

  for i := 1 to maxVars do
    if vars^.name [i] = name then
    begin
      vars^.value [i] := value;
      foundVar := true;
    end;

  if not foundVar then
  begin
    value := expandVars (value);
    emptySlot := -1;
    for i := maxVars downto 1 do
      if vars^.name [i] = '' then
    emptySlot := i;

    if emptySlot = -1 then TellError (tooManyVars)
   else
    begin
      vars^.name [emptySlot] := name;
      vars^.value [emptySlot] := value;
    end
  end;
end;

procedure setVars (myvars : string);
var
  var2set, value : string;
  i : integer;
  charSet : CharSetType;
  emptySlot : integer;
begin
  if myvars = '' then
  begin
    println('** Defined variables:');
    for i := 1 to maxVars do
      if vars^.name [i] <> '' then
        println('  ' + vars^.name [i]+ '='+ vars^.value[i]);
  end
  else
  begin
    charSet := [' ', '='];
    SpecialSplit(myvars, var2set, value, charSet);
    if value = '' then
    begin
      {display specific value of a variable}
    end
   else SetVar (var2Set, value);
  end;
end;


var
  i : integer;

begin
  New (vars);

  for i := 1 to maxVars do
  begin
    vars^.name  [i] := '';
    vars^.value [i] := '';
  end;
end.