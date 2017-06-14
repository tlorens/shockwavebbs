Unit Zip;

Interface

Uses DOS;

Procedure ViewZip(F:String);
Procedure ViewARJ(F:String);

Implementation

Const ZSignature = $04034B50;
      ZIPComp   : Array[0..6] Of String[50] =
                  ('Stored   ','Shrunk   ','DeflatX','Reduced 2',
                   'Reduced 3','Reduced 4','Imploded ');

      ASignature = $EA60;
      ARJComp   : Array[0..4] Of String[50] =
                  ('Stored   ','Compress1','Compress2','Compress3',
                   'Compress4');

Type ZIPLocalHdr = Record
                      ZSignature        : LongInt;
                      VersionToExtract : Integer;
                      BitFlag          : Integer;
                      CompressMethod   : Integer;
                      FileDateTime     : LongInt;
                      CRC32            : LongInt;
                      CompressedSize   : LongInt;
                      UnCompressedSize : LongInt;
                      FilenameLen      : Integer;
                      ExtraFieldLen    : Integer;
                   End;
     ZIPExtraTyp = Array[1..1024] Of Char;

     ARJHdr1=Record
       HeaderID      : Word; {EA60h}
       BasicHdrSize  : Word;
       FirstHdrSize  : Byte;
       ARJVersion    : Byte;
       MinToExtract  : Byte;
       HostOS        : Byte; {0=MSDOS,1=PRIMOS,2=UNIX,3=AMIGA,
                              4=MAC-OS,5=OS/2,6=APPLE GS,
                              7=ATARI ST,8=NEXT,9=VAX VMS}
       ARJFlags      : Byte; {01h=Garbled,02h=Reserved,
                          04h=Volume,08h=ExtFile,10h=PathSym}
       Method        : Byte; {0=Stored,1..4=Compressed Most..Fast}
       FileType      : Byte; {0=Binary,1=7-Bit Text,2=Comment Hdr,
                              3=Directory,4=Volume Label}
       Reserved      : Byte;
       TimeStamp     : LongInt;
       CompressedSz  : LongInt;
       OriginalSize  : LongInt;
       OriginalCRC   : LongInt;
       FileSpecPos   : Word;
       AccessMode    : Word;
       HostData      : Word;
     End;

     ARJHdr2=Record  {After Filename And Comment}
       BasicHdrCRC   : LongInt;
       ExtHdrSize    : Word; {Not Used}
     End;

     ARJExtraTyp = Array[1..1024] Of Char;


Var ZLclHdr : ZIPLocalHdr;
    ZNameEx : ZIPExtraTyp;
    ZInfoEx : ZIPExtraTyp;
    ZInFile : File;
    ZCSize  : LongInt;
    ZDSize  : LongInt;
    ZError  : Integer;
    ZFTime  : DateTime;
    ZFName  : String;
    ZFirst  : Boolean;
    ZFiles  : Integer;
    ZFDate  : LongInt;

    ALclHdr   : ARJHdr1;
    AEndHdr   : ARJHdr2;
    ANameEx   : ARJExtraTyp;
    AInfoEx   : ARJExtraTyp;
    ACommEx   : ARJExtraTyp;
    AFileSpec : String;
    AInFile   : File;
    ACSize    : LongInt;
    ADSize    : LongInt;
    AError    : Integer;
    AFTime    : DateTime;
    AFName    : String;
    AFirst    : Boolean;
    AFiles    : Integer;
    AFDate    : LongInt;


Function FormatStr(InString : String; Len : Byte) : String;
Var Temp : String;
    I    : Byte;
Begin
  Temp := '';
  For I := 1 To Len Do Temp := Temp + ' ';
  If Length(InString) > Len Then Temp := Copy(InString,1,Len)
 Else
  For I := 1 To Length(InString) Do Temp[I] := InString[I];
  FormatStr := Temp;
End;

Function MakeDateTime(Num1,Num2,Num3 : Word; SepChar : String) : String;
Var Str1 : String;
    Str2 : String;
    Str3 : String;
    OutS : String;
    I    : Byte;
Begin
  OutS := '';
  Str(Num1:2,Str1);
  Str(Num2:2,Str2);
  Str(Num3:2,Str3);
  If Length(Str3) = 4 Then Str3 := Copy(Str3,3,2);
  OutS := Str1+SepChar+Str2+SepChar+Str3;
  For I := 1 To Length(OutS) Do If OutS[I] = ' ' Then OutS[I] := '0';
  MakeDateTime := OutS;
End;

Function UpperCase(InString : String) : String;
Var I : Byte;
Begin
  For I := 1 To Length(InString) Do InString[I] := UpCase(InString[I]);
  UpperCase := InString;
End;

Function FormatFileName(InString : String) : String;
Begin
  If (Pos('.',InString) > 0) And (Pos('.',InString) < 9) Then
  Begin
    While (Pos('.',InString) < 9) Do
    Insert(' ',InString,Pos('.',InString));
  End;
  FormatFileName := InString;
End;

Function MakeIntoString(InBuf : ZipExtraTyp; BufLen : Integer) : String;
Var Temp : String;
    I    : Integer;
Begin
  Temp := '';
  For I := 1 To BufLen Do Temp := Temp + InBuf[I];
  MakeIntoString := Temp;
End;

Function RemovePath(InString : String) : String;
Begin
  While Pos('/',InString) > 0 Do Delete(InString,1,Pos('/',InString));
  While Pos('\',InString) > 0 Do Delete(InString,1,Pos('\',InString));
  RemovePath := InString;
End;

Function ZReadNextRecord : Boolean;
Begin
  {$I-}
  ZError := 0;
  BlockRead(ZInFile,ZLclHdr,SizeOf(ZLclHdr),ZError);
  If ZError < SizeOf(ZLclHdr) Then ZReadNextRecord := False
 Else
  Begin
    If ZLclHdr.ZSignature = ZSignature Then
    Begin
      ZReadNextRecord := True;
      If ZLclHdr.FileNameLen > 0 Then BlockRead(ZInFile,ZNameEx,ZLclHdr.FileNameLen,ZError);
      If ZLclHdr.ExtraFieldLen > 0 Then Seek(ZInFile,FilePos(ZInFile)+ZLclHdr.ExtraFieldLen);
      If ZLclHdr.CompressedSize > 0 Then Seek(ZInFile,FilePos(ZInFile)+ZLclHdr.CompressedSize);
      ZReadNextRecord := (IOResult = 0);
    End
   Else
    ZReadNextRecord := False;
  End;
 {$I+}
End;

Procedure ViewZip(F:String);
Begin
  ZFirst := True;
  ZFiles := 0;
  ZCSize := 0;
  ZDSize := 0;
  ZFName:=F;
  If Pos('.',ZFName) = 0 Then ZFName := ZFName + '.ZIP';
  ZFName := FExpand(ZFName);
  Assign(ZInFile,ZFName);
  {$I-} Reset(ZInFile,1); {$I+}
  If IOResult = 0 Then
  Begin
    WriteLn('Searching File:   '+UpperCase(FormatFileName(RemovePath(ZFName))));
    WriteLn('');
    While ZReadNextRecord Do
    Begin
      If ZFirst Then
      Begin
        WriteLn('Filename.Ext   Original    Current  Per%  Date      Time');
        WriteLn('------------  ---------  ---------  ----  --------  --------');
      End;
      Write(FormatStr(FormatFileName(RemovePath(MakeIntoString(ZNameEx,ZLclHdr.FileNameLen))),12)+'  ');
      Write(ZLclHdr.UncompressedSize:9,'  ');
      Write(ZLclHdr.CompressedSize:9,'  ');
{     Write(ZipComp[ZLclHdr.CompressMethod]+'  ');}
      Write((100-(100*ZLclHdr.CompressedSize) Div ZLclHdr.UnCompressedSize):3);
      Write('%  ');
      UnPackTime(ZLclHdr.FileDateTime,ZFTime);
      Write(MakeDateTime(ZFTime.Month,ZFTime.Day,ZFTime.Year,'-')+'  ');
      Write(MakeDateTime(ZFTime.Hour,ZFTime.Min,ZFTime.Sec,':'));
      WriteLn('');
      ZFirst := False;
      ZCSize := ZCSize + ZLclHdr.CompressedSize;
      ZDSize := ZDSize + ZLclHdr.UnCompressedSize;
      ZFiles := ZFiles + 1;
    End;
    If ZFirst Then WriteLn('This File Does Not Seem To Be ZIPped') Else
    Begin
      WriteLn('------------  ---------  ---------  ----  --------  --------');
      Write  (ZFiles:3,' Files     ',ZDSize:9,'  ',ZCSize:9,'  ',(100-(100*ZCSize) Div ZDSize):3,'%  ');
      GetFTime(ZInFile,ZFDate);
      UnPackTime(ZFDate,ZFTime);
      Write(MakeDateTime(ZFTime.Month,ZFTime.Day,ZFTime.Year,'-')+'  ');
      Write(MakeDateTime(ZFTime.Hour,ZFTime.Min,ZFTime.Sec,':'));
      WriteLn('');
    End;
    Close(ZInFile);
  End
 Else
  WriteLn('ZIP File Not Found');
 End;

Procedure ViewARJ(F:String);
Function AReadNextRecord : Boolean;

Var FileNameSz : Word;
    CommentSz  : Word;
    Ch         : Char;

   Begin
      {$I-}
      AFileSpec := '';
      FillChar(ANameEx,1024,0);
      FillChar(ACommEx,1024,0);
      CommentSz := 0;
      FileNameSz := 0;
      Ch := Chr(255);
      AError := 0;
      BlockRead(AInFile,ALclHdr,SizeOf(ARJHdr1),AError);
      If AError < SizeOf(ARJHdr1) Then
         AReadNextRecord := False
      Else
         Begin
            If ALclHdr.HeaderID = ASignature Then
                Begin
                   AReadNextRecord := True;
                   While (Ch<>Chr(0)) Do
                      Begin
                         BlockRead(AInFile,Ch,1,AError);
                         Inc(FileNameSz);
                         ANameEx[FileNameSz] := Ch;
                         If (FileNameSz >= ALclHdr.FileSpecPos) And (Ch<>Chr(0)) Then AFileSpec := AFileSpec + Ch;
                      End;
                   Ch := Chr(255);
                   While (Ch<>Chr(0)) Do
                      Begin
                         BlockRead(AInFile,Ch,1,AError);
                         Inc(CommentSz);
                         ACommEx[CommentSz] := Ch;
                      End;
                   BlockRead(AInFile,AEndHdr,SizeOf(ARJHdr2),AError);
                   If ALclHdr.CompressedSz > 0 Then Seek(AInFile,FilePos(AInFile)+ALclHdr.CompressedSz);
                   AReadNextRecord := (IOResult = 0);
                   If ALclHdr.FileType > 1 Then AFileSpec := '';
                End
             Else
                AReadNextRecord := False;
         End;
      {$I+}
   End;

   Begin
      AFirst := True;
      AFiles := 0;
      ACSize := 0;
      ADSize := 0;
      AFName := F;
      If Pos('.',AFName) = 0 Then AFName := AFName + '.ARJ';
      AFName := FExpand(AFName);
      Assign(AInFile,AFName);
      {$I-}
      Reset(AInFile,1);
      {$I+}
      If IOResult = 0 Then
         Begin
            WriteLn('Searching File:   '+UpperCase(FormatFileName(RemovePath(AFName))));
            WriteLn('');
            While (AReadNextRecord) Do If AFileSpec<>'' Then
               Begin
                  If AFirst Then
                     Begin
                        WriteLn('Filename.Ext   Original    Current  Method     Per%  Date      Time');
                        WriteLn('------------  ---------  ---------  ---------  ----  --------  --------');
                     End;
                  Write  (FormatStr(FormatFileName(AFileSpec),12)+'  ');
                  Write  (ALclHdr.OriginalSize:9,'  ');
                  Write  (ALclHdr.CompressedSz:9,'  ');
                  Write  (ARJComp[ALclHdr.Method]+'  ');
                  Write  ((100-(100*ALclHdr.CompressedSz) Div ALclHdr.OriginalSize):3);
                  Write  ('%  ');
                  UnPackTime(ALclHdr.TimeStamp,AFTime);
                  Write  (MakeDateTime(AFTime.Month,AFTime.Day,AFTime.Year,'-')+'  ');
                  Write  (MakeDateTime(AFTime.Hour,AFTime.Min,AFTime.Sec,':'));
                  WriteLn('');
                  AFirst := False;
                  ACSize := ACSize + ALclHdr.CompressedSz;
                  ADSize := ADSize + ALclHdr.OriginalSize;
                  AFiles := AFiles + 1;
               End;
            If AFirst Then
               WriteLn('This File Does Not Seem To Be ARJed')
            Else
               Begin
                  WriteLn('------------  ---------  ---------  ---------  ----  --------  --------');
                  Write  (AFiles:3,' Files     ',ADSize:9,'  ',ACSize:9,'             ',(100-(100*ACSize) Div ADSize):3,'%  ');
                  GetFTime(AInFile,AFDate);
                  UnPackTime(AFDate,AFTime);
                  Write  (MakeDateTime(AFTime.Month,AFTime.Day,AFTime.Year,'-')+'  ');
                  Write  (MakeDateTime(AFTime.Hour,AFTime.Min,AFTime.Sec,':'));
                  WriteLn('');
               End;
            Close(AInFile);
         End
      Else
         WriteLn('ARJ File Not Found');
   End;


 Begin
 End.
