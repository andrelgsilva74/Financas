unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, System.IOUtils;

type
  TDM = class(TDataModule)
    Connection: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  with Connection do
  begin
    {$IFDEF MSWINDOWS}

    try
      Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\DB\SistemaFinanceiro.db';
      Connected := True;
    except on E: Exception do
      raise Exception.Create('Erro de Conexão com o Banco de Dados: ' + E.Message);
    end;

    {$ELSE}

    Params.Values['DriverID'] := 'SQLite';
    try
      Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'SistemaFinanceiro.db');
      Connected := True;
    except on E: Exception do
      raise Exception.Create('Erro de Conexão com o Banco de Dados: ' + E.Message);
    end;

    {$ENDIF}
  end;
end;

end.
