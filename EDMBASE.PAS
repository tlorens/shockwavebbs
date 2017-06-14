Unit EdMBase;

Interface

uses OPCrt,DOS,IO,Records,Vars,Cnfgrec,GenSubs,Msub1;

Implementation

Var MArea:File Of BoardRec;
    CurArea:BoardRec;
    MIndex:File Of Str25;
    AreaFPos:Integer;

Procedure AddMarea;
Begin
  FillChar(CurArea,SizeOf(CurArea),#0);
  With CurArea Do
  Begin
    AreaCmd     :='New';
    AreaName    :='New Area';
    Description :='New Message Area';
    SubOp       :=Urec^.Handle;
    Password    :='';
    Flags       :='(s1)';
    PostFlags   :='(s1)';
    MaxMsgs     :=100;
    NumToDel    :=25;
    RealNames   :=False;
    Priv        :=False;
    NetType     :=1;
    Directory   :='';
    Address     :='';
  End;
End;

Procedure AssignM;
Var S:Str80;
Begin
  S:=CNF^.MsgDir+'MAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  Assign(MArea,S);
 { Assign(MIndex,S+'.NDX');}
End;

Procedure CloseMFiles;
Begin
  Close(MArea);
{ Close(MIndex);}
End;

Procedure OpenMFiles;
Begin
  AssignM; ReSet(MArea);
End;

Procedure CheckAreas;
Var S:String;
Begin
  S:=CNF^.MsgDir+'MAREA'+PadRight(Strr(CurConf),3,'0')+'.DAT';
  If Not Exist(S) Then
  Begin
    AssignM; ReWrite(MArea);
    CloseMFiles;
    AddMArea;
  End;
End;

Procedure WriteMArea;
Begin
  OpenMFiles;
  Seek(Marea,AreaFPos);
  Write(MArea,CurArea);
  CloseMFiles;
End;

Procedure WriteNewMArea;
Begin
  OpenMFiles;
  Seek(Marea,FileSize(MArea));
  Write(MArea,CurArea);
  CloseMFiles;
End;

Procedure ReadMArea;
Begin
  Read(MArea,CurArea);
  AreaFPos:=FilePos(MArea)-1;
End;

Procedure SeekMArea(N:Integer);
Begin
  Seek(MArea,N-1);
End;

Function NumAreas:Integer;
Begin
  CheckAreas;
  OpenMFiles;
  NumAreas:=FileSize(MArea);
  CloseMFiles;
End;

Function Validbname (N:Str10):Boolean;
Var Cnt:Integer;
Begin
  Validbname:=False;
  If (length(n)=0) or (length(n)>8) then exit;
  For Cnt:=1 To Length(n) Do
    If Not (upcase(n[cnt]) in ['0'..'9','A'..'Z']) Then Exit;
  Validbname:=True
End;

Procedure ListBases;
Begin
  OpenMFiles;
  While Not EOF(MArea) Do
  Begin
    Read(MArea,CurArea);

  End;
  CloseMFiles;
End;

Procedure EditBase;
Begin
End;

Begin
End.