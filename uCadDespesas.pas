unit uCadDespesas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.DateTimeCtrls, FMX.ListBox, FireDAC.Comp.Client, FireDAC.DApt, DateUtils,
  Data.DB, FMX.DialogService;

{$IFDEF AUTOREFCOUNT}
type
  TIntegerWrapper = class
  public
    value: Integer;
    constructor Create(AValue: Integer);
  end;
{$ENDIF}

type
  TfrmCadDespesas = class(TForm)
    rectBottom: TRectangle;
    imgLixeira: TImage;
    lytTop: TLayout;
    imgVoltar: TImage;
    imgSave: TImage;
    lblRotulo: TLabel;
    lytDescricao: TLayout;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
    lineDescricao: TLine;
    lytValor: TLayout;
    lblValor: TLabel;
    edtValor: TEdit;
    LineValor: TLine;
    lytCategoria: TLayout;
    lblCategoria: TLabel;
    lytData: TLayout;
    lblData: TLabel;
    LineData: TLine;
    dtLanc: TDateEdit;
    imgHoje: TImage;
    imgOntem: TImage;
    imgTipoLanc: TImage;
    imgReceita: TImage;
    imgDespesa: TImage;
    lblDescCategoria: TLabel;
    imgAcessoCat: TImage;
    Line1: TLine;
    procedure imgVoltarClick(Sender: TObject);
    procedure imgTipoLancClick(Sender: TObject);
    procedure imgHojeClick(Sender: TObject);
    procedure imgOntemClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSaveClick(Sender: TObject);
    procedure edtValorTyping(Sender: TObject);
    procedure imgLixeiraClick(Sender: TObject);
    procedure imgAcessoCatClick(Sender: TObject);
  private
    procedure comboCategoria;
    function trataValor(str: string): Double;
    { Private declarations }
  public
    { Public declarations }

    modo: String;
    idLanc: Integer;
  end;

var
  frmCadDespesas: TfrmCadDespesas;

implementation

{$R *.fmx}

uses uPrincipal, cCategoria, uDM, cLancamento, uFuncoes, uComboCategoria;

{$IFDEF AUTOREFCOUNT}
constructor TIntegerWrapper.Create(AValue: Integer);
begin  // Para utilizar ComboBox no Mobile
  inherited Create;
  Value := AValue;
end;
{$ENDIF}

procedure TfrmCadDespesas.comboCategoria;
var
  cat: TCategoria;
  erro: String;
  qry:TFDQuery;
  cbxCategoria: TComboBox;
begin
  try
    cbxCategoria.Items.Clear;
    cat := TCategoria.Create(DM.Connection);
    qry := cat.listarCategoria(erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    while not qry.Eof do
    begin
      cbxCategoria.Items.AddObject(qry.FieldByName('DESCRICAO').AsString,
      {$IFDEF AUTOREFCOUNT}
        TIntegerWrapper.Create(qry.FieldByName('ID').AsInteger)
      {$ELSE}
        TObject(qry.FieldByName('ID').AsInteger)
      {$ENDIF});

      qry.Next;
    end;
  finally
    cat.DisposeOf;
    qry.DisposeOf;
  end;
end;

procedure TfrmCadDespesas.edtValorTyping(Sender: TObject);
begin
  Formatar(edtValor, TFormato.Valor);
end;

procedure TfrmCadDespesas.FormShow(Sender: TObject);
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro: String;
begin
  if modo = 'I' then
  begin
    edtDescricao.Text := '';
    edtValor.Text := '0,00';
    dtLanc.Date := Date;
    imgTipoLanc.Bitmap := imgDespesa.Bitmap;
    imgTipoLanc.Tag := -1;
    rectBottom.Visible := False;
    lblDescCategoria.Text := '';
    lblDescCategoria.Tag := 1;
  end
  else
  begin
    try
      lanc := TLancamento.Create(DM.Connection);
      lanc.ID_LANCAMENTO := idLanc;
      qry := lanc.ListarLancamento(0, erro);

      if qry.RecordCount = 0 then
      begin
        ShowMessage('Lançamento não encontrado');
        Exit;
      end;

      edtDescricao.Text := qry.FieldByName('DESCRICAO').AsString;
      dtLanc.Date := qry.FieldByName('DATA').AsDateTime;

      if qry.FieldByName('VALOR').AsFloat < 0 then
      begin
        edtValor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat * -1);
        imgTipoLanc.Bitmap := imgDespesa.Bitmap;
        imgTipoLanc.Tag := -1;
      end
      else
      begin
        edtValor.Text := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat);
        imgTipoLanc.Bitmap := imgReceita.Bitmap;
        imgTipoLanc.Tag := 1;
      end;

      lblDescCategoria.Text := qry.FieldByName('DESCRICAO_CATEGORIA').AsString;
      lblDescCategoria.Tag := qry.FieldByName('ID_CATEGORIA').AsInteger;
      rectBottom.Visible := True;

    finally
      lanc.DisposeOf;
      qry.DisposeOf;
    end;
  end;
end;

procedure TfrmCadDespesas.imgAcessoCatClick(Sender: TObject);
begin
  //Abre lista de Categorias
  if not Assigned(frmComboCategoria) then
    Application.CreateForm(TfrmComboCategoria, frmComboCategoria);

  frmComboCategoria.ShowModal(procedure(Modalresult: TModalResult)
                              begin
                                if frmComboCategoria.idCategoriaSelecao > 0 then
                                begin
                                  lblDescCategoria.Text := frmComboCategoria.CategoriaSelecao;
                                  lblDescCategoria.Tag := frmComboCategoria.idCategoriaSelecao;
                                end;
                              end);
end;

procedure TfrmCadDespesas.imgHojeClick(Sender: TObject);
begin
  dtLanc.Date := Date;
end;

procedure TfrmCadDespesas.imgLixeiraClick(Sender: TObject);
var
  lanc: TLancamento;
  erro: String;
begin
  TDialogService.MessageDialog('Confirma exclusão do Lançamento?',
                               TMsgDlgType.mtConfirmation,
                               [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                               TMsgDlgBtn.mbNo,
                               0,
  procedure(const AResult: TModalResult)
  var
    erro: string;
  begin
    if AResult = mrYes then
    begin
      try
        lanc := TLancamento.Create(dm.Connection);
        lanc.ID_LANCAMENTO := idLanc;

        if not lanc.Excluir(erro) then
        begin
          ShowMessage(erro);
          Exit;
        end;

        Close;

      finally
        lanc.DisposeOf;
      end;
    end;
  end);
end;

procedure TfrmCadDespesas.imgOntemClick(Sender: TObject);
begin
  dtLanc.Date := Date - 1;
end;

function TfrmCadDespesas.trataValor(str: string): Double;
begin
  str := StringReplace(str, '.','', [rfReplaceall]);
  str := StringReplace(str, ',','', [rfReplaceall]);

  try
    Result := StrToFloat(str) / 100;
  except
    Result := 0;
  end;
end;

procedure TfrmCadDespesas.imgSaveClick(Sender: TObject);
var
  lanc: TLancamento;
  erro: String;
begin
  try
    lanc := TLancamento.Create(DM.Connection);
    lanc.DESCRICAO := edtDescricao.Text;
    lanc.VALOR := trataValor(edtValor.Text) * imgTipoLanc.Tag;

    lanc.ID_CATEGORIA := lblDescCategoria.Tag;
    lanc.DATA := dtLanc.Date;

    if modo = 'I' then
      lanc.Inserir(erro)
    else
    begin
      lanc.ID_LANCAMENTO := idLanc;
      lanc.Alterar(erro);
    end;

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    Close;
  finally
    lanc.DisposeOf;
  end;
end;

procedure TfrmCadDespesas.imgTipoLancClick(Sender: TObject);
begin
  if imgTipoLanc.Tag = 1 then
  begin
    imgTipoLanc.Bitmap := imgDespesa.Bitmap;
    imgTipoLanc.Tag := -1;
  end
  else
  begin
    imgTipoLanc.Bitmap := imgReceita.Bitmap;
    imgTipoLanc.Tag := 1;
  end;
end;

procedure TfrmCadDespesas.imgVoltarClick(Sender: TObject);
var
  lanc: TLancamento;
  vValor: Double;
begin
  vValor := trataValor(edtValor.Text) * imgTipoLanc.Tag;
  try
    lanc := TLancamento.Create(DM.Connection);


    TDialogService.MessageDialog('Cadstro efetuado com sucesso!',
                                 TMsgDlgType.mtConfirmation,
                                 [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                                 TMsgDlgBtn.mbNo,
                                 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        imgSaveClick(nil);

        Close;
    end);
  finally
    lanc.DisposeOf;
  end;
  Close;
end;

end.
