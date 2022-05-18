unit uLancamentos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FireDAC.Comp.Client, FireDAC.DApt, Data.DB, DateUtils, cLancamento;

type
  TfrmLancamentos = class(TForm)
    lytTop: TLayout;
    lblRotulo: TLabel;
    imgVoltar: TImage;
    lytMes: TLayout;
    imgPrior: TImage;
    imgNext: TImage;
    imgButton: TImage;
    lblMes: TLabel;
    Rectangle1: TRectangle;
    imgAdd: TImage;
    lytBottom: TLayout;
    lblSaldoReceitas: TLabel;
    lblReceitas: TLabel;
    lblSaldoDespesas: TLabel;
    lblDespesas: TLabel;
    lblSaldoTotal: TLabel;
    lblSaldo: TLabel;
    lvLancamentos: TListView;
    imgResumo: TImage;
    procedure imgVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvLancamentosUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvLancamentosItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure abrirLancamento(id_lancamento: String);
    procedure imgAddClick(Sender: TObject);
    procedure NavegarMes(numMes: Integer);
    procedure imgNextClick(Sender: TObject);
    procedure imgPriorClick(Sender: TObject);
    procedure imgResumoClick(Sender: TObject);
  private
    dtFiltro: TDate;

    procedure ListarLancamentos(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLancamentos: TfrmLancamentos;

implementation

{$R *.fmx}

uses uPrincipal, uFuncoes, uCadDespesas, uDM, uLancamentosResumo;

procedure TfrmLancamentos.NavegarMes(numMes: Integer);
begin
  dtFiltro := IncMonth(dtFiltro, numMes);
  lblMes.Text := nomeMes(dtFiltro);
  ListarLancamentos(nil);
end;

procedure TfrmLancamentos.abrirLancamento(id_lancamento: String);
begin
  if not Assigned(frmCadDespesas) then
    Application.CreateForm(TfrmCadDespesas, frmCadDespesas);

  if id_lancamento <> '' then
  begin
    frmCadDespesas.modo := 'A';
    frmCadDespesas.idLanc := id_lancamento.ToInteger;
  end
  else
  begin
    frmCadDespesas.modo := 'I';
    frmCadDespesas.idLanc := 0;
  end;

  frmCadDespesas.ShowModal(procedure(Modalresult: TModalResult)
                           begin
                            ListarLancamentos(nil);
                           end);
end;

procedure TfrmLancamentos.ListarLancamentos(Sender: TObject);
var
  foto: TStream;
  lanc: TLancamento;
  qry: TFDQuery;
  erro: String;
  vlReceitas, vlDespesas: Double;
begin
  try
    lvLancamentos.Items.Clear;
    vlReceitas := 0;
    vlDespesas := 0;

    lanc := TLancamento.Create(DM.Connection);
    lanc.DATAINI := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(dtFiltro));
    lanc.DATAFIN := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(dtFiltro));
    qry := lanc.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while not qry.Eof do
    begin
      if qry.FieldByName('ICONE').AsString <> ''then
        foto := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead)
      else
        foto := nil;

      AddLancamento(lvLancamentos
                   , qry.FieldByName('ID_LANCAMENTO').AsString
                   , qry.FieldByName('DESCRICAO').AsString
                   , qry.FieldByName('DESCRICAO_CATEGORIA').AsString
                   , qry.FieldByName('DATA').AsDateTime
                   , qry.FieldByName('VALOR').AsFloat
                   , foto);

      if qry.FieldByName('VALOR').AsFloat > 0 then
        vlReceitas := vlReceitas + qry.FieldByName('VALOR').AsFloat
      else
        vlDespesas := vlDespesas + qry.FieldByName('VALOR').AsFloat;

      qry.Next;

      foto.DisposeOf;
    end;

    lblSaldoReceitas.Text := FormatFloat('#,##0.00', vlReceitas);
    lblSaldoDespesas.Text := FormatFloat('#,##0.00', vlDespesas);
    lblSaldoTotal.Text := FormatFloat('#,##0.00', vlReceitas - (- vlDespesas));

  finally
    lanc.DisposeOf;
  end;
end;

procedure TfrmLancamentos.FormShow(Sender: TObject);
begin
  dtFiltro := Date;
  NavegarMes(0);
end;

procedure TfrmLancamentos.imgAddClick(Sender: TObject);
begin
  abrirLancamento('');
end;

procedure TfrmLancamentos.imgNextClick(Sender: TObject);
begin
  NavegarMes(1);
end;

procedure TfrmLancamentos.imgPriorClick(Sender: TObject);
begin
  NavegarMes(-1);
end;

procedure TfrmLancamentos.imgResumoClick(Sender: TObject);
begin
  if not Assigned(frmLancamentosResumo) then
    Application.CreateForm(TfrmLancamentosResumo, frmLancamentosResumo);

  frmLancamentosResumo.lblMes.Text := nomeMes(dtFiltro);
  frmLancamentosResumo.dtFiltro := frmLancamentos.dtFiltro;
  frmLancamentosResumo.Show;
end;

procedure TfrmLancamentos.imgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLancamentos.lvLancamentosItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  abrirLancamento(AItem.TagString);
end;

procedure TfrmLancamentos.lvLancamentosUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  setupLancamento(lvLancamentos, AItem, 'txtDescricao', 95);
end;

end.
