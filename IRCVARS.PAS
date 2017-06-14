Unit ircVars;

Interface

Uses IRCRecs;

Const VerNum    ='1.2a';
      MsgFile   ='MSGii.CHT';
      ServerFile='SERVER.DAT';
      UserFile  ='IRCUSRS.DAT';

Var User    :UserRec;
   UserF    :File Of UserRec;

    Chat    :ChatRec;
   ChatF    :File Of ChatRec;

     Ch:Char;
 OutStr:String;
  ChatY,LastX:Byte;
  ChatFile:String;
   UNum:Byte;
  SavX,SavY:Byte;
  QuitIRC:Boolean;
  MsgTo:String;

Implementation

Begin
End.