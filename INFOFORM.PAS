{
  iB * 06/09/97 - Created InfoForm Routines: |* Optional String
                                             |@ Manditory String
                                             |+ Yes/No
                                             |# Option Number
                                             |& Nanditory Number
                                             |^ Advanced Editable
}
Unit InfoForm;

Interface

Uses OpCrt,Dos,GenSubs,Vars,Records,CnfgRec,Display;

Procedure SaveInfoData;
Procedure ReadInfoData;
Procedure DeleteInfoData;
Procedure ListAvailForms;
Procedure FillOutForm(B:Byte);
Procedure DisplayForm(B:Byte);

Implementation

Type InfoRec=Record
       Answer:Str80;
       ID:Integer;
     End;

Procedure SaveInfoData;
Begin
End;

Procedure ReadInfoData;
Begin
End;

Procedure DeleteInfoData;
Begin
End;

Procedure ListAvailForms;
Begin
End;

Procedure FillOutForm(B:Byte);
Var T:Text;
    Ch:Char;
    Chk:String[2];
Begin
  Assign(T,'INFOFORM.'+Strr(B));
  Reset(T);
  While (Not EOF(T)) Do
  Begin
    Read(T,Ch);
    If Ch='|' Then
    Begin
      Chk:=Ch;
      Read(T,Ch);
      Chk:=Chk+Ch;
    End;
    If Chk='|*' Then Input:=Prompt(80,'',False);
  End;
  Close(T);
End;

Procedure DisplayForm(B:Byte);
Begin
End;

Begin
End.