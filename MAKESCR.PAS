Program ScriptCompiler;

Uses opCrt,Dos,GenSubs;

Const Header='ShockWavE:PRO - Simple Scripting Language file'+#13+#10+
             'Copyright (C) 1997-98 Cyberdyne Systems:VSI'+#26;

Function Extension(S:String):String;
Var Tmp:String;
Begin
  Tmp:=Copy(S,Length(S)-2,3);
  Extension:=Tmp;
End;

Function EncodeLine(S:String):String;
Var X:Byte;
   Tmp:String;
   T:Byte;
Begin
  Tmp:='';
  For X:=1 To Length(S) Do Tmp:=Tmp+Chr(Ord(S[X])-5 XOR $AF);
  EncodeLine:=Tmp;
End;

Function DecodeLine(S:String):String;
Var X:Byte;
   Tmp:String;
   T:Byte;
Begin
  Tmp:='';
  For X:=1 To Length(S) Do Tmp:=Tmp+(Chr(ORd(S[X])+5 XOR $AF));
  DecodeLine:=Tmp;
End;

Procedure Compile(F1:String);
Var Txt1,Txt2:Text;
    OutFile,L:String;
Begin
  OutFile:=Copy(F1,1,Length(F1)-3)+'SHK';
  Assign(Txt1,F1); Reset(Txt1);
  Assign(Txt2,OutFile); Rewrite(Txt2);
  Writeln(Txt2,Header);
  While (Not EOF(Txt1)) Do
  Begin
    Readln(Txt1,L);
    Writeln(Txt2,EncodeLine(L));
  End;
  Close(Txt1);
  Close(Txt2);
End;

Procedure DeCompile(F1:String);
Var Txt1,Txt2:Text;
    OutFile,L:String;
    X:Byte;
    Ch:Char;
Begin
  OutFile:=Copy(F1,1,Length(F1)-3)+'SCR';
  Assign(Txt1,F1); Reset(Txt1);
  Assign(Txt2,OutFile); Rewrite(Txt2);
  For X:=1 to Length(Header) Do Read(Txt1,Ch);
  While (Not EOF(Txt1)) Do
  Begin
    Readln(Txt1,L);
    Writeln(Txt2,DecodeLine(L));
  End;
  Close(Txt1);
  Close(Txt2);
End;

Procedure Help;
Begin
  Writeln;
  Writeln('MAKESCR v0.01 by iCE Breaker * 04/13/97');
  Writeln('For use with ShockWavE:PRO BBS');
  Writeln;
  Writeln('Usage: MAKESCR <scriptfile>');
End;

Begin
  If (ParamCount=1) AND (Extension(Paramstr(1))='SCR') Then Compile(Paramstr(1)) Else 
{  If (ParamCount=1) AND (Extension(Paramstr(1))='SHK') Then DeCompile(Paramstr(1)) Else} Help;
End.