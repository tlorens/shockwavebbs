unit ScrMisc;

interface
uses Parser,
     MyLib,
     ScrErr,
     TpString,
     StrnTTT5;

type
  charSetType = set of char;

function calc (st: string): string;
procedure SpecialSplit(InputStr:string;
                   var Command,
                       Param: string;
                       charSet : CharSetType);

var
  decimals : byte;

implementation

function calc (st: string): string;
var
  myResult : real;
  validity : boolean;
begin
  macro := st;
  myResult := getExpr (validity);
  if (validity = false) then
    tellError (CalcFailed)
  else
  calc := Real_to_Str (myResult, decimals);
end;

(*** SPLIT STRINGS W/ YOU SPECIFYING A SET OF DELIMETERS ******************)
procedure SpecialSplit(InputStr:string;
                   var Command,
                       Param: string;
                       charSet : CharSetType);
var
  i : integer;
  j : integer;
  Found: boolean;

begin
  Command := '';
  Param   := '';

  Found := FALSE;
  InputStr := Trim(InputStr);
  if not (Length (InputStr) = 0) then
    for i := 1 to Length (InputStr) do
    begin
      if InputStr [i] in charSet then
      begin
        Command := Copy (InputStr, 1, i - 1);
        Param   := Copy (InputStr, i + 1, Length (InputStr));
        i := Length (InputStr);
        Found := TRUE;
      end;
    end;
    if not Found = TRUE then Command := InputStr;

  Command := Trim (Command);
  Param := Trim (Param);

  UpCaseStr (Command);

end;

begin
  decimals := 0;
end.