(******************************************************************************
*                                   parser                                    *
* Ron Loewy, 1992. A mathematical recursive decent parser +-/*^ and functions *
******************************************************************************)
unit parser;

interface

type  TokenType   = (Delimiter,Non,variable,Digit,endExpr,Error,Func);
      TokenPtr    = ^TokenRec;
      TokenRec    = Record
                      Next       :TokenPtr;
                      Start,Close:Byte;
                    end;

var Macro : string;
    V     : array ['0'..'9'] of Real; {macro program variables}
    ErrAt : Byte;

function GetExpr(var Valid:Boolean) : Real;

implementation 

var
   c  : char;
   i  : byte;

(******************************************************************************
*                                    DoErr                                    *
******************************************************************************)
procedure DoErr(var n : TokenType);

begin
     n := Error;
     ErrAt := i; {globl err pos}
end; {doErr}

(******************************************************************************
*                                  ReadWord                                   *
******************************************************************************)
function ReadWord : string;
var 
   WordIn : string;
begin
     WordIn := '';
     While (not(Macro [i] in
                      [' ','\',';','*','/','^','+','=','-','%','(',')']))
            and (i <= Length(Macro)) do
     begin
          WordIn := WordIn + UpCase(Macro[i]);
          Inc(i);
     end;
     ReadWord := WordIn;
end; {readWord}

(******************************************************************************
*                                 ReadNumber                                  *
******************************************************************************)
function ReadNumber : Real;
var 
   Number : Real;
   Code   : Integer;
   StrNum : string;
begin
     StrNum := ReadWord;
     if StrNum[1] = '.' then StrNum := '0' + StrNum;
     Val(StrNum,Number,Code);
     if Code <> 0 then Number := 0;
     ReadNumber := Number;
end; {readNumber}

procedure Level1(var Result : Real; var n : TokenType) ; forward;

(******************************************************************************
*                                 SkipBlanks                                  *
******************************************************************************)
procedure SkipBlanks;
begin
  While Macro [i] = ' ' do Inc(i);
end; {skipBlanks}

(******************************************************************************
*                                  GetToken                                   *
******************************************************************************)
function GetToken : TokenType;
var 
   Temp : string;
   n    : TokenType;
begin
  SkipBlanks;
  if Macro [i] in ['+','-','/','*','=','^','%','(',')'] then
                         n := Delimiter
                    else if Macro [i] in ['v','V'] then begin
                         n := variable;
                    end else if Macro [i] in ['0'..'9','.'] then
                        n := Digit
                    else if Macro [i] = ';' then
                         n := endExpr
                    else if Macro[i] in ['a'..'z','A'..'Z']
                         then n := Func
                    else n := Non;
     GetToken := n;
end; {getToken}

(******************************************************************************
*                                  MatchFunc                                  *
******************************************************************************)
function MatchFunc(Match : string; var Result : Real; var n : TokenType) :
                                                               Boolean;
var 
   j : Byte;
begin
     j := i; {restore i if no match}
     if (ReadWord = Match) then 
     begin
        MatchFunc := True;
        skipblanks;
        if (Macro [i] <> '(') then DoErr(n) else 
        begin
          Inc(i);
          n := GetToken;
          Level1(Result,n);
          SkipBlanks; {Reach closing parenthasis}
          if Macro[i] <> ')' then DoErr(n);
          Inc(i);
          SkipBlanks;
        end;
     end 
    else 
     begin
       MatchFunc := False;
       i := j; {no Func Match, restore}
     end;
end; {matchFunc}

(******************************************************************************
*                                 MatchToken                                  *
******************************************************************************)
function MatchToken(Match : string) : boolean;
var 
   j : byte;
begin
     j := i;
     if (readWord = match) then MatchToken := True
          else begin
               MatchToken := False;
               i := j;
          end; {else}
end; {matchToken}

(******************************************************************************
*                                    doPI                                     *
******************************************************************************)
function doPI(var r:real) : boolean;
begin
     doPI := matchToken('PI');
     r := pi;
end; {doPI}

(******************************************************************************
*                                     doE                                     *
******************************************************************************)
function doE(var r:real) : boolean;
begin
     doE := matchToken('E');
     r := exp(1.0);
end; {doE}

(******************************************************************************
*                                    DoSin                                    *
******************************************************************************)
function DoSin(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('SIN',Result,n);
     Result := sin(Result);
     DoSin := r;
end; {doSin}

(******************************************************************************
*                                    DoExp                                    *
******************************************************************************)
function DoExp(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('EXP',Result,n);
     Result := exp(Result);
     DoExp := r;
end; {doSin}

(******************************************************************************
*                                    DoCos                                    *
******************************************************************************)
function DoCos(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('COS',Result,n);
     Result := cos(Result);
     DoCos := r;
end; {doCos}

(******************************************************************************
*                                    DoLn                                     *
******************************************************************************)
function DoLn(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('LN',Result,n);
     if (Result > 0.0) then Result := ln(Result)
        else DoErr(n);
     DoLn := r;                      
end; {doLn}

(******************************************************************************
*                                   DoLog10                                   *
******************************************************************************)
function DoLog10(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('LOG10',Result,n);
     if (Result > 0.0) then Result := ln(Result)/ln(10.0)
        else DoErr(n);
     DoLog10 := r;                   
end; {doLog10}

(******************************************************************************
*                                   DoLog2                                    *
******************************************************************************)
function DoLog2(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('LOG2',Result,n);
     if (Result > 0.0) then Result := ln(Result)/ln(2.0)
        else DoErr(n);
     DoLog2 := r;                    
end; {doLog2}

(******************************************************************************
*                                    DoAbs                                    *
******************************************************************************)
function DoAbs(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('ABS',Result,n);
     Result := Abs(Result);
     DoAbs := r;
end; {doAbs}

(******************************************************************************
*                                  DoArcTan                                   *
******************************************************************************)
function DoArcTan(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('ARCTAN',Result,n);
     Result := ArcTan(Result);
     DoArcTan := r;
end; {doArcTan}

(******************************************************************************
*                                    DoSqr                                    *
******************************************************************************)
function DoSqr(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('SQR',Result,n);
     Result := Sqr(Result);
     DoSqr := r;
end; {doSqr}

(******************************************************************************
*                                   DoSqrt                                    *
******************************************************************************)
function DoSqrt(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('SQRT',Result,n);
     Result := Sqrt(Result);
     DoSqrt := r;
end; {doSqrt}

(******************************************************************************
*                                    DoTan                                    *
******************************************************************************)
function DoTan(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('TAN',Result,n);
     if ( cos(result) <> 0 ) then 
     Result := Sin(Result) / cos(Result)
     else doErr(n);
     DoTan := r;
end; {doTan}

(******************************************************************************
*                                   DoCoTan                                   *
******************************************************************************)
function DoCoTan(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('COTAN',Result,n);
     if ( sin(result) <> 0 ) then 
     Result := cos(Result) / sin(Result)
     else doErr(n);
     DoCoTan := r;
end; {doCoTan}

(******************************************************************************
*                                  DoArcSin                                   *
******************************************************************************)
function DoArcSin(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
     r := MatchFunc('ARCSIN',Result,n);
      if (abs(Result) < 1.0) then
     Result := arcTan(Result/sqrt(1-result*result))
     else doErr(n);
     DoArcSin := r;
end; {doArcSin}

(******************************************************************************
*                                  DoArcCos                                   *
******************************************************************************)
function DoArcCos(var Result : Real; var n : TokenType) : Boolean;
var 
   r : Boolean;
begin
      r := MatchFunc('ARCCOS',Result,n);
      if ((Result <> 0.0) and (result < 1.0)) then
        Result := arcTan(sqrt(1-result*result)/result)
    else doErr(n);
    DoArcCos := r;
end; {doArcCos}

(******************************************************************************
*                                   DoFunc                                    *
******************************************************************************)
procedure DoFunc(var Result : Real; var n : TokenType);
begin
     case Macro [i] of
          's','S' : begin
                         if not(DoSin(Result,n)) then
                            if not(DoSqr(Result,n)) then
                               if not(DoSqrt(Result,n)) then
                            DoErr(n);
                    end;
          'c','C' : begin
                         if not(DoCos(Result,n)) then
                  if not(DoCoTan(result,n)) then
                            DoErr(n);
                    end;
          'l','L' : begin
                         if not(DoLn(Result,n)) then
                    if not(doLog10(result,n)) then
                         if not(doLog2(result,n)) then
                            DoErr(n);
                    end;
          'a','A' : begin
                         if not(DoAbs(Result,n)) then
                            if not(DoArcTan(Result,n)) then
                    if not(doArcSin(Result,n)) then
                         if not(doArcCos(result,n))
                               then DoErr(n);
                    end;
          'e','E' : begin
                         if not(DoExp(Result,n)) then
                    if not(doE(result)) then
                                   DoErr(n);
                    end;
       't','T' : begin
               if not(doTan(result,n)) then
                    doErr(n);
              end;
       'p','P' : begin
               if not(doPI(result)) then 
                    doErr(n);
              end;   
          else DoErr(n);
     end; {case}
end;

procedure Primitive(var Result : Real; var n : TokenType);

begin
     if n = variable then begin
        Inc(i);
        SkipBlanks;
        if Macro [i] in ['0'..'9'] then begin
           Result := V [Macro [i]];
           Inc(i);
        end else DoErr(n);
     end else if n = Digit then Result := ReadNumber
     else if (n = Func) then DoFunc(Result,n);
     SkipBlanks;
end;

procedure Level6(var Result : Real; var n : TokenType);

{deal with parenthsis}

begin
     if (n = Delimiter) and (Macro [i] = '(') then begin
        Inc(i);
        n := GetToken;
        Level1(Result,n);
        SkipBlanks; {Reach closing parenthasis}
        if Macro[i] <> ')' then DoErr(n);
        Inc(i);
        SkipBlanks;
     end else Primitive (Result,n);
end;

procedure Level5(var Result : Real; var n : TokenType);

{Unary +,-}

var op : Char;

begin
     op := Macro [i];
     if op in ['-','+'] then Inc(i);
     n := GetToken;
     Level6(Result,n);
     if op = '-' then Result := - (Result);
end;

function Sign(Number : Real) : Real;

{-1 if Number < 0 , 1 otherwise}

begin
     if (Number < 0.0) then Sign := -1.0
        else Sign := 1.0;
end;

procedure Level4(var Result : Real; var n : TokenType);

var Hold : Real;

begin
     Level5(Result,n);
     if (n <> Error) then
        if macro [i] = '^' then begin
           Inc(i);
           n := GetToken;
           Level4(Hold,n);
           if (Result = 0.0) then
              if (hold = 0.0) then result := 1.0
                   else Result := 0.0
           else Result := Sign(Result) * Exp(Hold * Ln(Abs(Result)));
                                          {mimic power}
           SkipBlanks;
           end;
end;

procedure Level3(var Result : Real; var n : TokenType);

{Multipy / divide 2 factors}

var Hold : Real;
    op   : Char;

begin
     Level4(Result,n);
     if (n <> Error) then begin
        SkipBlanks;
        While Macro [i] in ['*','/','%'] do begin
           op := Macro[i];
           Inc(i);
           n := GetToken;
           Level4(Hold,n);
           if op = '*' then Result := Result * Hold
              else begin
             if (hold = 0.0) then doErr(n)
               else 
               if op = '/' then Result := Result / Hold
                         else Result := Trunc(Result) mod Trunc(Hold);
           end;
           SkipBlanks;
        end;
     end; {not error}
end;

procedure Level2(var Result : Real; var n : TokenType);

{add/sub 2 terms}

var Hold : Real;
    op   : Char;

begin
     Level3(Result,n);
     if (n <> Error) then begin
        SkipBlanks;
        While (Macro [i] in ['+','-']) do begin
           op := Macro [i];
           inc(i);
           n := GetToken;
           Level3(Hold,n);
           if op = '+' then Result := Result + Hold
              else Result := Result - Hold;
           SkipBlanks;
        end; {while}
     end; {not error}
end;

procedure Level1(var Result : Real; var n : TokenType);

var Slot : Char;
    m    : TokenType;
    j    : Byte;

begin
     if n = variable then begin
        j := i; {save  i}
        Inc(i);
        SkipBlanks;
        if Macro [i] in ['0'..'9'] then Slot := Macro [i]
           else DoErr(n);
        if (n <> Error) then begin
           Inc(i);
           m := GetToken;
           if ((m = Delimiter) and (Macro [i] = '=') and (i <=length(Macro)))
           then begin
                Inc(i);
                n := GetToken;
                Level2(Result,n);
                V [Slot] := Result;
           end else begin
               i := j; {restore ..}
               level2(Result,n);
           end; {not a vx = ...}
        end {n <> error}
     end {variable case} else
         Level2(Result,n);
end;

{Deal with assinment here}

function GetExpr(var Valid:Boolean) : Real;

var Result : Real;
    n      : TokenType;

begin
     i := 1;
     Result := 0; {if no result returned}
     n := GetToken;
     if Not (n in [endExpr,Non]) then Level1(Result,n);
     if (n <> endExpr) and (i < Length(Macro)) then Dec(i);
     GetExpr := Result;
     if (n = Error) then Valid := False
        else Valid := True;
end;

(******************************************************************************
*                                    MAIN                                     *
******************************************************************************)
begin
   for c := '0' to '9' do
      v[c] := 0.0;
end.
