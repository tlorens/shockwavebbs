Unit IRCDis;

Interface
Procedure SaveXY;
Procedure RestoreXY;
Procedure Clear;
Procedure StatusLine;
Procedure WriteList(S:String);
Procedure WriteChat(Fr,S:String; Flag:Char);

Implementation

Uses OpCrt,Dos,GenSubs,IRCVars,IO;

Procedure SaveXY;
Begin
  SavX:=WhereX;
  SavY:=WhereY;
End;

Procedure RestoreXY;
Begin
  GoXy(SavX,SavY);
End;

Procedure StatusLine;
Begin
End;

Procedure Clear;
Begin
  Cls;
  ChatY:=1;
End;

Procedure WriteList(S:String);
Begin
  GoXY(1,ChatY);
  AColor(5);
  Println(S);
  ChatY:=WhereY;
  AColor(7);
  GoXY(1,24);
End;

Procedure ClearEoLn;
Var  T:Byte;
  CntB:Byte;
Begin
  T:=Wherex;
  For CntB:=WhereX to 78 Do Print(' ');
  GoXy(T,WhereY);
End;

Procedure WriteChat(Fr,S:String; Flag:Char);
Begin
  GoXy(1,ChatY);
  Case Flag Of
   'P':Begin
         AColor(3); Print('<');
         AColor(11);Print(Fr);
         AColor(3); Print('> ');
         AColor(7); Println(S);
       End;
   'S':Begin
         AColor(3);  Print('*** User: ');
         AColor(15); Print(Fr+' ');
         AColor(3);  PrintLn(S);
         AColor(7);
       End;
   'A':Begin
         AColor(3);  Print('* ');
         AColor(15); Print(Fr);
         AColor(3);  Println(S);
         AColor(7);
       End;
   'M':Begin
         AColor(7);  Print('[');
         AColor(15); Print(Fr);
         AColor(7);  Print(']');
         AColor(3);  Println(S);
       End;
    End;
  ChatY:=WhereY;
  GoXY(1,24);
  AColor(7);
End;

Begin
End.