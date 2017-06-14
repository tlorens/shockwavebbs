{
  iB * 03/14/96 Misc File Section Routines.
}

Unit Fsubs;

Interface

Uses Records,CnfgRec,Vars;

Function RemovePath(S:String):String;
Function CalcFSize(L:LongInt):String;

Implementation

Uses OpCrt,DOS,IO,GenSubs;

Function RemovePath(S:String):String;
Var Tmp,T:String;
    X:Byte;
Begin
  If Pos('\',S)=0 Then
  Begin
    RemovePath:=S;
    Exit;
  End;
  Tmp:=''; T:='';
  For X:=Length(S) downto 1 Do
  Begin
    If S[X]='\' Then
    Begin
      RemovePath:=Copy(S,X+1,Length(S));
      X:=1;
    End;
  End;
End;

Function CalcFSize(L:LongInt):String;
Begin
  If (L<1024) Then CalcFSize:=Strr(L)+'k' 
    Else CalcFSize:=Strr(L div 1024)+'.'+Copy(Strr(L mod 1024),1,1)+'m';
End;

Begin
End.