Unit IRcRecs;

Interface

Type UserRec=Record
       Nick    :String[10];
       When    :LongInt;
       Idle    :LongInt;
       Away    :String[40];
     End;

    ChatRec=Record
      From:String[10];
      Text:String[78];
      Flag:Char;
    End;

Implementation

Begin
End.