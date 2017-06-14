{*****************************************************************************}
{*                                                         Modified 08/07/93 *}
{*                                                                           *}
{* Include file PLEDIT.INC                                                   *}
{* --- Logical port list manipulation routines                               *}
{*                                                                           *}
{* These routines are used to edit the "logical port list" used by most of   *}
{* the ASYNC routines.                                                       *}
{*                                                                           *}
{*                                                                           *}
{* Procedures & functions declared in this include file:                     *}
{* -----------------------------------------------------                     *}
{* - Procedure AddCom(Address:Word; Int:Byte; ForceAdd:Boolean)              *}
{* - Procedure AddPS2Ports(ForceAdd:Boolean)                                 *}
{* - Procedure AddISAPorts(ForceAdd:Boolean)                                 *}
{* - Procedure ChangeCom(ComPort:Byte; Address:Word; Int:Byte;               *}
{*             ForceAdd:Boolean)                                             *}
{* - Procedure InsertCom(ComPort:Byte; Address:Word; Int:Byte;               *}
{*             ForceAdd:Boolean)                                             *}
{* - Procedure DelCom(ComPort:Byte)                                          *}
{*                                                                           *}
{* ! = Used internally by ASYNC; not callable from user programs             *}
{* - = Delcared in INTERFACE section; may be called from user programs       *}
{*                                                                           *}
{* Copyright (C) 1989-1993, Rising Edge Data Serivces                        *}
{*                                                                           *}
{*****************************************************************************}

{*****************************************************************************}
{*                                                         Modified 12/30/90 *}
{*                                                                           *}
{* Procedure AddCom(Address:Word; Int:Byte; ForceAdd:Boolean);               *}
{* -- Add a new port definition to the internal port list.                   *}
{*                                                                           *}
{* AddCom allows the inclusion of ports that are not predefined by ASYNC to  *}
{* be defined and used.  (Address) specifies the port address of an 8250-    *}
{* compatable UART.  (Int) specifies the hardware interrupt line (0-7 for    *}
{* XT/compatables or 0-15 for AT/compatables) that is used by the UART.      *}
{* If (ForceAdd) is TRUE, the port will be added to the internal list even   *}
{* if the hardware does not exist (C_Error will still be set).               *}
{*                                                                           *}
{* Ports used by ASYNC must be compatable with the 8250/16450 UART.          *}
{* Furthermore, the port must be capable of interrupt-driven operation using *}
{* the hardware interrupt line specified by (Int).  A compatability test is  *}
{* performed on the port mapped at (Address) before it is added to the int-  *}
{* ernal port list.  If the test fails AddCom will return with a non-zero    *}
{* error code in C_Error and leave the internal port list unmodified (unless *}
{* (ForceAdd) is TRUE; see above).                                           *}
{*                                                                           *}
{* The port number assigned to a port added via this procedure can be        *}
{* identified by reading the global variable C_MaxCom.                       *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, port added to internal list.                                 *}
{* 1: Port list full, no more ports may be added.                            *}
{* 2: Port existence test failed                                             *}
{* 5: (Int) value passed is out of range for current machine type            *}
{*                                                                           *}
{*****************************************************************************}

Procedure AddCom(Address:Word; Int:Byte; ForceAdd:Boolean);

Var
  Exist : Boolean;

Begin

  {Make sure parameters are valid}

  C_Error := C_NoError;
  If C_MaxCom >= C_MaxPort Then
    Begin
      C_Error := C_InvalidPort;
      Exit;
    End;

  If (C_IsAT And (Int > 15)) Or ((Not C_IsAT) And (Int > 7)) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Make sure that port hardware exists}
  {Do not add definition unless ForceAdd is TRUE}

  Exist := ComExist(Address,C_ExistMode);
  If Not Exist Then
    Begin
      C_Error := C_PortNotFound;
      If Not ForceAdd Then Exit;
    End;

  {Assign port to a logical port number}

  Inc(C_MaxCom);
  C_PortExist[C_MaxCom] := Exist;
  C_FIFOExist[C_MaxCom] := ComFIFOExist(Address);
  C_PortAddr[C_MaxCom] := Address;
  C_PortInt[C_MaxCom] := Int;
  C_PortOpen[C_MaxCom] := False;
  C_OpenLevel[C_MaxCom] := 0;
End;

{*****************************************************************************}
{*                                                         Modified 12/30/90 *}
{*                                                                           *}
{* Procedure AddISAPorts(ForceAdd:Boolean)                                   *}
{* -- Add the ISA standard port definitions to the logical port list         *}
{*                                                                           *}
{* This routine adds to the logical port list the four standard ports that   *}
{* are found on ISA machines (corresponding to COM1: - COM4).  These ports   *}
{* are added to the end of the port list.  If any of these port definitions  *}
{* already exist in the LPL they will not be added.  If (ForceAdd) is TRUE,  *}
{* all four port definitions will be created irregadless of the results of   *}
{* the port hardware existence test.                                         *}
{*                                                                           *}
{* The four ports added have characteristics as outlined below:              *}
{*                                                                           *}
{* Port # | Address | Interrupt                                              *}
{* -------|---------|----------                                              *}
{*   1    |   3F8h  |     4                                                  *}
{*   2    |   2F8h  |     3                                                  *}
{*   3    |   3E8h  |     4                                                  *}
{*   4    |   2E8h  |     3                                                  *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, all ports added to internal list                             *}
{* 1: Port list full, no more ports may be added.                            *}
{* 2: Port existence test failed                                             *}
{*                                                                           *}
{*****************************************************************************}

Procedure AddISAPorts(ForceAdd:Boolean);

Const
  ISANbr = 4;
  ISAAddr : Array[1..ISANbr] Of Word = ($3F8,$2F8,$3E8,$2E8);
  ISAInt  : Array[1..ISANbr] Of Byte = (   4,   3,   4,   3);

Var
  Count,Error : Byte;

Begin
  Error := C_NoError;
  For Count := 1 To ISANbr Do
    Begin
      AddCom(ISAAddr[Count],ISAInt[Count],ForceAdd);
      If C_Error <> C_NoError Then Error := C_Error;
    End;
  C_Error := Error;
End;

{*****************************************************************************}
{*                                                         Modified 12/30/90 *}
{*                                                                           *}
{* Procedure AddPS2Ports(ForceAdd:Boolean)                                   *}
{* -- Add the PS/2 standard port definitions to the logical port list        *}
{*                                                                           *}
{* This routine adds to the logical port list the six additional ports that  *}
{* may be found on IBM PS/2 series machines (for COM3: - COM8).  These ports *}
{* are added to the end of the port list.  If any of these port definitions  *}
{* already exist in the LPL they will not be added.  If (ForceAdd) is TRUE,  *}
{* all six port definitions will be created irregadless of the results of    *}
{* the port hardware existence test.                                         *}
{*                                                                           *}
{* The six ports added have characteristics as outlined below:               *}
{*                                                                           *}
{* Port # | Address | Interrupt                                              *}
{* -------|---------|----------                                              *}
{*   1    |  3220h  |     3                                                  *}
{*   2    |  3228h  |     3                                                  *}
{*   3    |  4220h  |     3                                                  *}
{*   4    |  4228h  |     3                                                  *}
{*   5    |  5220h  |     3                                                  *}
{*   6    |  5228h  |     3                                                  *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, all ports added to internal list                             *}
{* 1: Port list full, no more ports may be added.                            *}
{* 2: Port existence test failed                                             *}
{*                                                                           *}
{*****************************************************************************}

Procedure AddPS2Ports(ForceAdd:Boolean);

Const
  PS2Nbr = 6;
  PS2Addr : Array[1..PS2Nbr] Of Word = ($3220,$3228,$4220,$4228,$5220,$5228);
  PS2Int  : Array[1..PS2Nbr] Of Byte = (    3,    3,    3,    3,    3,    3);

Var
  Count,Error : Byte;

Begin
  Error := C_NoError;
  For Count := 1 To PS2Nbr Do
    Begin
      AddCom(PS2Addr[Count],PS2Int[Count],ForceAdd);
      If C_Error <> C_NoError Then Error := C_Error;
    End;
  C_Error := Error;
End;

{*****************************************************************************}
{*                                                         Modified 12/30/90 *}
{*                                                                           *}
{* Procedure ChangeCom(ComPort:Byte; Address:Word;Int:Byte;ForceAdd:Boolean) *}
{* -- Change an existing port definition.                                    *}
{*                                                                           *}
{* ChangeCom allows a program to modify an existing port definition in the   *}
{* internal port list.  (ComPort) specifies the port number to modify.       *}
{* (Address) specifies the port address of an existing 8250-compatable UART. *}
{* (Int) specifies the hardware interrupt line (0-7 for XT/compatables or    *}
{* 0-15 for AT/compatables) that is used by the UART.  If (ForceAdd) is      *}
{* TRUE, the port definition will be changed even if the port hardware       *}
{* existence test fails.                                                     *}
{*                                                                           *}
{* Ports used by ASYNC must be compatable with the 8250/16450 UART.          *}
{* Furthermore, the port must be capable of interrupt-driven operation using *}
{* the hardware interrupt line specified by (Int).  A compatability test is  *}
{* performed on the port mapped at (Address) before any changes are made to  *}
{* the internal port list.  If the test fails ChangeCom will return with a   *}
{* non-zero error code in C_Error and leave the internal port list           *}
{* unmodified (unless (ForceAdd) is TRUE; see above).                        *}
{*                                                                           *}
{* The port specified by (ComPort) must be CLOSED before changes are         *}
{* allowed.  If the port is presently OPEN, ChangeCom will return with a     *}
{* non-zero error code in C_Error and leave the port list unmodified.        *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, port definition changed.                                     *}
{* 2: Port existence test failed                                             *}
{* 4: Port is presently OPEN, changes not allowed.                           *}
{* 5: (ComPort) or (Int) value passed is out of range.                       *}
{*                                                                           *}
{*****************************************************************************}

Procedure ChangeCom(ComPort:Byte; Address:Word; Int:Byte; ForceAdd:Boolean);

Var
  Exist : Boolean;

Begin

  {Make sure parameters are valid}

  C_Error := C_NoError;
  If (ComPort < 1) Or (ComPort > (C_MaxCom+1)) Or (ComPort > C_MaxPort) Then
    Begin
      C_Error := C_InvalidPort;
      Exit;
    End;

  If (C_IsAT And (Int > 15)) Or ((Not C_IsAT) And (Int > 7)) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Make sure port being reassigned is not OPENed}

  If C_PortOpen[ComPort] Then
    Begin
      C_Error := C_PortNotClosed;
      Exit;
    End;

  {Make sure that port hardware exists}
  {Do not change definition unless ForceAdd is TRUE}

  Exist := ComExist(Address,C_ExistMode);
  If Not Exist Then
    Begin
      C_Error := C_PortNotFound;
      If Not ForceAdd Then Exit;
    End;

  {Assign new hardware address to the logical port #}

  C_PortExist[ComPort] := Exist;
  C_FIFOExist[C_MaxCom] := ComFIFOExist(Address);
  C_PortAddr[ComPort] := Address;
  C_PortInt[ComPort] := Int;
  C_PortOpen[ComPort] := False;
  C_OpenLevel[ComPort] := 0;
  If ComPort > C_MaxCom Then Inc(C_MaxCom);
End;

{*****************************************************************************}
{*                                                         Modified 12/30/90 *}
{*                                                                           *}
{* Procedure InsertCom(ComPort:Byte; Address:Word;Int:Byte;ForceAdd:Boolean) *}
{* -- Insert a new port definition into the internal port list.              *}
{*                                                                           *}
{* InsertCom allows a program to insert a new definition into the internal   *}
{* port list, scrolling all port definitions above (ComPort) down.           *}
{* (ComPort) specifies the insertion point in the list.  (Address) specifies *}
{* the address of a 8250-compatable UART.  (Int) specifies the hardware      *}
{* interrupt line (0-7 for XT/compatables or 0-15 for AT/compatables) that   *}
{* is used by the UART.  If (ForceAdd) is TRUE, the port definition will     *}
{* be inserted even if the port hardware existence test fails.               *}
{*                                                                           *}
{* InsertCom may only be used if ALL ports equal to or greater than ComPort  *}
{* are CLOSED.  A non-zero error code will be returned in C_Error and the    *}
{* internal port list will remain unmodified if any port numbers equal to or *}
{* greater than (ComPort) are OPEN.                                          *}
{*                                                                           *}
{* Ports used by ASYNC must be compatable with the 8250/16450 UART.          *}
{* Furthermore, the port must be capable of interrupt-driven operation using *}
{* the hardware interrupt line specified by (Int).  A compatability test is  *}
{* performed on the port mapped at (Address) before any changes are made to  *}
{* the internal port list.  If the test fails InsertCom will return with a   *}
{* non-zero error code in C_Error and leave the internal port list           *}
{* unmodified (unless (ForceAdd) is TRUE; see above).                        *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, port definition inserted into the internal list.             *}
{* 1: Port list full, cannot INSERT any more definitions.                    *}
{* 2: Port existence test failed                                             *}
{* 4: One or more ports are OPEN, changes not allowed.                       *}
{* 5: (ComPort) or (Int) value passed is out of range.                       *}
{*                                                                           *}
{*****************************************************************************}

Procedure InsertCom(ComPort:Byte; Address:Word; Int:Byte; ForceAdd:Boolean);

Var
  X : Byte;
  POpen,Exist : Boolean;

Begin

  {Make sure parameters are valid}

  If (ComPort < 1) Or (ComPort > (C_MaxCom+1)) Or (ComPort > C_MaxPort) Or
  (C_MaxCom >= C_MaxPort) Then
    Begin
      C_Error := C_InvalidPort;
      Exit;
    End;

  If (C_IsAT And (Int > 15)) Or ((Not C_IsAT) And (Int > 7)) Then
    Begin
      C_Error := C_BadParameter;
      Exit;
    End;

  {Make sure that port hardware exists}
  {Do not insert definition unless ForceAdd is TRUE}

  Exist := ComExist(Address,C_ExistMode);
  If Not Exist Then
    Begin
      C_Error := C_PortNotFound;
      If Not ForceAdd Then Exit;
    End;

  {Do not allow insertion if any port above (greater than) the insertion point}
  {is presently OPEN}

  POpen := False;
  For X := ComPort To C_MaxCom Do
    POpen := POpen Or C_PortOpen[X];
  If POpen Then
    Begin
      C_Error := C_PortNotClosed;
      Exit;
    End;

  {Open up space for the new port definition}

  For X := C_MaxPort Downto ComPort+1 Do
    Begin
      C_PortAddr[X] := C_PortAddr[X-1];
      C_PortInt[X] := C_PortInt[X-1];
      C_FIFOExist[X] := C_FIFOExist[X-1];
    End;

  {Assign new hardware address to the logical port #}

  C_PortExist[ComPort] := Exist;
  C_FIFOExist[C_MaxCom] := ComFIFOExist(Address);
  C_PortAddr[ComPort] := Address;
  C_PortInt[ComPort] := Int;
  C_PortOpen[ComPort] := False;
  C_OpenLevel[ComPort] := 0;
  If ComPort > C_MaxCom Then Inc(C_MaxCom);
  C_Error := C_NoError;
End;

{*****************************************************************************}
{*                                                         Modified 12/28/90 *}
{*                                                                           *}
{* Procedure DelCom(ComPort:Byte)                                            *}
{* -- Delete a port from the internal port list.                             *}
{*                                                                           *}
{* DelCom will delete the port specified by (ComPort) and scroll all ports   *}
{* below it up one in the internal port list.                                *}
{*                                                                           *}
{* DelCom may only be used if ALL ports equal to or greater than (ComPort)   *}
{* are CLOSED.  A non-zero error code will be returned in C_Error and the    *}
{* internal port list will remain unmodified if any port numbers equal to or *}
{* greater than (ComPort) are OPEN.                                          *}
{*                                                                           *}
{* Possible error returns (in C_Error):                                      *}
{* 0: No error, port definition deleted from the internal list.              *}
{* 4: One or more ports are OPEN, changes not allowed.                       *}
{* 5: (ComPort) specified does not exist.                                    *}
{*                                                                           *}
{*****************************************************************************}

Procedure DelCom(ComPort:Byte);

Var
  X : Byte;
  POpen : Boolean;

Begin

  {Make sure parameters are valid}

  If (ComPort < 1) Or (ComPort > C_MaxCom) Or (C_MaxCom < 1) Then
    Begin
      C_Error := C_InvalidPort;
      Exit;
    End;

  {Do not allow deletion if any port above (greater than) the deletion point
  {is presently OPEN}

  POpen := False;
  For X := ComPort To C_MaxCom Do
    POpen := POpen Or C_PortOpen[X];
  If POpen Then
    Begin
      C_Error := C_PortNotClosed;
      Exit;
    End;

  {Delete the port definition from the logical port list}

  For X := ComPort To C_MaxCom Do
    Begin
      C_PortAddr[X] := C_PortAddr[X+1];
      C_PortInt[X] := C_PortInt[X+1];
      C_FIFOExist[X] := C_FIFOExist[X+1];
    End;
  Dec(C_MaxCom);
End;

