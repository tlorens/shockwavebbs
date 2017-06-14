unit ScrMark;

interface

var
  heapMarker : pointer; {to mark all memory used, then to release it}

implementation

begin
  Mark (heapMarker);
end.