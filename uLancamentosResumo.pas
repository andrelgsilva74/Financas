unit uLancamentosResumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, DateUtils,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FireDAC.Comp.Client, FireDAC.DApt, Data.DB, cLancamento;

type
  TfrmLancamentosResumo = class(TForm)
    lytTop: TLayout;
    lblRotulo: TLabel;
    imgVoltar: TImage;
    lytMes: TLayout;
    imgButton: TImage;
    lblMes: TLabel;
    lvResumo: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgVoltarClick(Sender: TObject);
  private

    procedure MontarResumo;
    { Private declarations }
  public
    dtFiltro: TDate;
    { Public declarations }
  end;

var
  frmLancamentosResumo: TfrmLancamentosResumo;

implementation

{$R *.fmx}

uses uDM, uPrincipal, uFuncoes;

procedure TfrmLancamentosResumo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmLancamentosResumo := nil;
end;

procedure TfrmLancamentosResumo.FormShow(Sender: TObject);
begin
  MontarResumo;
end;

procedure TfrmLancamentosResumo.imgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLancamentosResumo.MontarResumo;
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro, vCategoria: String;
  icone: TStream;
begin
  try
    lvResumo.Items.Clear;
    lanc := TLancamento.Create(DM.Connection);
    lanc.DATAINI := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(dtFiltro));
    lanc.DATAFIN := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(dtFiltro));
    qry := lanc.listarResumo(erro);

    while not qry.Eof do
    begin
      //Icone
      if qry.FieldByName('ICONE').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead)
      else
        icone := nil;

      AddCategoriaResumo(lvResumo,
                        qry.FieldByName('DESCRICAO').AsString,
                        qry.FieldByName('VALOR').AsCurrency,
                        icone);

      if icone <> nil then
        icone.DisposeOf;

      qry.Next;
    end;

  finally
    qry.DisposeOf;
    lanc.DisposeOf;
  end;
end;

end.
