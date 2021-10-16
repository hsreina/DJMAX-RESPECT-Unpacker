unit uGeneric;

interface

type
  TGeneric = class
    public
      class function IfElse<T>(const condition: Boolean; ifTrue, ifFalse: T): T; inline;
  end;

implementation

class function TGeneric.IfElse<T>(const condition: Boolean; ifTrue: T; ifFalse: T): T;
begin
  if condition then
  begin
    Exit(ifTrue);
  end else
  begin
    Exit(ifFalse);
  end;
end;

end.
