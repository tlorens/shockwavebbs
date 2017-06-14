unit ScrErr;

interface

uses IO;

const
  {errors}
  calcFailed = 1;
  labelNotFound = 2;
  tooManyVars = 3;
  fileNotFound = 4;
  Overflow = 5;
  ifError = 6;
  genError = 7;

var
  errorsOff : boolean;
  trappedError : integer;

procedure tellError (prob: integer);

implementation

(*** TELL AN ERROR ********************************************************)
procedure tellError (prob: integer);

procedure err (msg: string);
begin
  println('');
  println('*** ERROR: ' + msg + '!');
end;

begin
  if errorsOff then trappedError := prob
 else
  begin
    case prob of
      calcFailed    : err('Expression could not be evaluated');
      labelNotFound : err('Label not found');
      tooManyVars   : err('All memory slots filled up. Remove some variables and try again');
      Overflow      : err('Nesting level overflow. Possibly an infinite recursion');
      ifError       : err('Error evaluating IF .. THEN statement');
      genError      : err('<UNKNOWN TYPE> Please correct it');
    end;
  end;
end;

begin
  errorsOff := false;
  trappedError := 0;
end.