Unit mylib;

Interface

Procedure UpCaseStr(Var s:String);
Procedure Split(Str:String; Var Cmd,Param:String);

Implementation

Uses OpCrt,TpString;

Procedure UpCaseStr(Var S:String);
var cnt:integer;
begin
  for cnt:=1 to length(s) do s[cnt]:=upcase(s[cnt]);
end;

Procedure Split(Str:String; Var Cmd,Param:String);
Begin
  Str:=Trim(Str);
  If Str[1]=':' Then Cmd:=Str Else
  Begin  
    Cmd:=Copy(Str,1,Pos(' ',Str));
    Cmd:=Trim(Cmd);
    Delete(Str,1,Pos(' ',Str));
    Param:=Str;
  End;
End;

Begin
End.