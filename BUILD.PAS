program outputdate;

uses crt,dos,gensubs;

var txt:text;
    inf,outf:text;
    Count:Byte;
    Line,l,cpl:string;

begin
  if not exist('cplnum.dat') then
  Begin                          { create build data file }
    assign(outf,'cplnum.dat');
    rewrite(outf);
    writeln(outf,'1');
    close(outf);
  End;

  assign(inf,'cplnum.dat'); { read in build number }
  reset(inf);
  readln(inf,line);
  Close(inf);

  Count:=Valu(Line);        { increment build number }
  Inc(Count);

  assign(outf,'cplnum.dat');  { write out build number }
  rewrite(outf);
  writeln(outf,Count);
  close(outf);

  assign(txt,'build.ver');   { create include for source }
  rewrite(txt);
    l:='const builddate='''+Datestr(now)+' '+timestr(now)+''';';
  cpl:='      cplnum='+line+';';
  writeln(txt,l);
  writeln(txt,cpl);
  close(Txt);
end.