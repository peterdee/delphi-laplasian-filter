program LinearLaplasianFilter;

uses
  Forms,
  App in 'App.pas' {AppForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TAppForm, AppForm);
  Application.Run;
end.

