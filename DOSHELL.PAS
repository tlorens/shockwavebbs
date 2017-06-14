unit DoShell;

interface

uses OpCrt,Dos,Windows;

procedure ExecShell (param: string);

implementation

procedure ExecShell (param: string);
begin
  SaveScreen;
  ClrScr;
  Writeln;
  Writeln('ShockWavE:PRO <-> DOS GateWay');
  Writeln('Type EXIT to return to ShockWavE:PRO');
  Swapvectors;
  DOS.EXEC(GetENV('COMSPEC'),Param);
  Swapvectors;
  RestoreScreen;
end;

end.