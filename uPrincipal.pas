unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.TabControl, FMX.ListBox, FMX.Layouts, DateUtils,
  FMX.VirtualKeyboard,

  {$IFDEF ANDROID}
  AndroidAPI.Jni.Net, AndroidAPI.Jni.JavaTypes, AndroidAPI.Jni, AndroidAPI.JNIBridge,
  AndroidAPI.Helpers, FMX.Helpers.Android, AndroidAPI.Jni.GraphicsContentViewText,
  {$ENDIF ANDROID}

  {$IFDEF IOS}
  Macapi.Helpers, iOSAPI.Foundation, FMX.Helpers.iOS,
  {$ENDIF IOS}
  FMX.Platform, FMX.Objects, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Ani,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB, FMX.MediaLibrary.Actions, u99Permissions;

type
  TfrmPrincipal = class(TForm)
    lytPrincipal: TLayout;
    lytTop: TLayout;
    lytSaldo: TLayout;
    lytIndicadores: TLayout;
    lytLancamentos: TLayout;
    imgMenu: TImage;
    cAvatar: TCircle;
    imgNotification: TImage;
    lblRotulo: TLabel;
    lblSaldoAtual: TLabel;
    lblTitulo: TLabel;
    lytImgIndicadores: TLayout;
    lytIndicadorReceita: TLayout;
    lytIndicadorDespesa: TLayout;
    Image1: TImage;
    Image2: TImage;
    lblSaldoReceita: TLabel;
    lblReceita: TLabel;
    lblDespesa: TLabel;
    lblSaldoDespesa: TLabel;
    imgNotificatioRed: TImage;
    rectBottom: TRectangle;
    imgAdd: TImage;
    rectBody: TRectangle;
    lblLancamentos: TLabel;
    lblVerTodos: TLabel;
    lvLancamento: TListView;
    StyleBook1: TStyleBook;
    rectMenu: TRectangle;
    layoutPrincipal: TLayout;
    animationMenu: TFloatAnimation;
    Image3: TImage;
    layMenuCategoria: TLayout;
    lblCategorias: TLabel;
    layLogout: TLayout;
    lblLogout: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvLancamentoUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lvLancamentoPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure lblVerTodosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure animationMenuFinish(Sender: TObject);
    procedure animationMenuProcess(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure layMenuCategoriaClick(Sender: TObject);
    procedure imgAddClick(Sender: TObject);
    procedure lvLancamentoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure layLogoutClick(Sender: TObject);
    procedure MontaPainel;
  private
    permissao: T99Permissions;

    { Private declarations }

    procedure TrataErroPermissao(Sender: TObject);
    procedure CarregaIcone;
  public
    { Public declarations }
    procedure listarLancamentos(Sender: TObject);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses uLancamentos, uFuncoes, uCategorias, cLancamento, uDM,
  uCadDespesas, cUsuario, uLogin;

procedure TfrmPrincipal.TrataErroPermissao(Sender: TObject);
begin
  ShowMessage('Você não tem permissão de acesso para esse recurso');
end;

procedure TfrmPrincipal.animationMenuFinish(Sender: TObject);
begin
  layoutPrincipal.Enabled := animationMenu.Inverse;
  animationMenu.Inverse := not(animationMenu.Inverse);
end;

procedure TfrmPrincipal.animationMenuProcess(Sender: TObject);
begin
  layoutPrincipal.Margins.Right := -260 - rectMenu.Margins.Left;
end;

procedure TfrmPrincipal.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(frmLancamentos) then
  begin
    frmLancamentos.DisposeOf;
    frmLancamentos := nil;
  end;

  Action := TCloseAction.caFree;
  frmPrincipal := nil;
  permissao.DisposeOf;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  rectMenu.Margins.Left := -260;
  rectMenu.Align := TAlignLayout.Left;
  rectMenu.Visible := True;
  permissao := T99Permissions.Create;
end;

procedure TfrmPrincipal.listarLancamentos(Sender: TObject);
var
  foto: TStream;
  lanc: TLancamento;
  qry: TFDQuery;
  erro: String;
  vlReceitas, vlDespesas: Double;
begin
  try
    lvLancamento.Items.Clear;
    vlReceitas := 0;
    vlDespesas := 0;

    lanc := TLancamento.Create(DM.Connection);
    qry := lanc.ListarLancamento(10, erro);

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

      AddLancamento(lvLancamento
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

  finally
    lanc.DisposeOf;
  end;

  MontaPainel;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  listarLancamentos(nil);
  CarregaIcone;
end;

procedure TfrmPrincipal.Image3Click(Sender: TObject);
begin
  animationMenu.Start;
end;

procedure TfrmPrincipal.imgAddClick(Sender: TObject);
begin
  if not Assigned(frmCadDespesas) then
    Application.CreateForm(TfrmCadDespesas, frmCadDespesas);

  frmCadDespesas.modo := 'I';
  frmCadDespesas.idLanc := 0;

  frmCadDespesas.ShowModal(procedure(Modalresult: TModalResult)
                           begin
                            listarLancamentos(nil);
                           end);
end;

procedure TfrmPrincipal.imgMenuClick(Sender: TObject);
begin
  animationMenu.Start;
end;

procedure TfrmPrincipal.layLogoutClick(Sender: TObject);
var
  usu: TUsuario;
  erro: String;
begin
  try
    usu := TUsuario.Create(DM.Connection);

    if not usu.Logout(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

  finally
    usu.DisposeOf;
  end;

  if not Assigned(frmLogin) then
    Application.CreateForm(TfrmLogin, frmLogin);

  Application.MainForm := frmLogin;
  frmLogin.Show;
  frmPrincipal.Close;
end;

procedure TfrmPrincipal.layMenuCategoriaClick(Sender: TObject);
begin
  animationMenu.Start;

  if  not Assigned(frmCategorias) then
    Application.CreateForm(TfrmCategorias, frmCategorias);

  frmCategorias.Show;
end;

procedure TfrmPrincipal.lblVerTodosClick(Sender: TObject);
begin
  if not Assigned(frmLancamentos) then
    Application.CreateForm(TfrmLancamentos, frmLancamentos);

  frmLancamentos.Show;
end;

procedure TfrmPrincipal.lvLancamentoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  if not Assigned(frmCadDespesas) then
    Application.CreateForm(TfrmCadDespesas, frmCadDespesas);


  frmCadDespesas.modo := 'A';
  frmCadDespesas.idLanc := AItem.TagString.ToInteger;

  frmCadDespesas.ShowModal(procedure(Modalresult: TModalResult)
                           begin
                            ListarLancamentos(nil);
                           end);
end;

procedure TfrmPrincipal.lvLancamentoPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
//Scroll Infinito
{  if lvLancamento.Items.Count > 0 then
    if lvLancamento.GetItemRect(lvLancamento.Items.Count - 4).Bottom <= lvLancamento.Height then
    begin
      AddLancamento('00002', 'Supermecado', 'Alimentação', Date, -550, nil);
      AddLancamento('00002', 'Supermecado', 'Alimentação', Date, -550, nil);
      AddLancamento('00002', 'Supermecado', 'Alimentação', Date, -550, nil);
      AddLancamento('00002', 'Supermecado', 'Alimentação', Date, -550, nil);
      AddLancamento('00002', 'Supermecado', 'Alimentação', Date, -550, nil);
    end;    }
end;

procedure TfrmPrincipal.lvLancamentoUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  setupLancamento(lvLancamento, AItem, 'txtDescricao', 95);
end;

procedure TfrmPrincipal.MontaPainel;
var
  lanc: TLancamento;
  qry: TFDQuery;
  erro: String;
  vlReceitas, vlDespesas: Double;
begin
  try
    lanc := TLancamento.Create(dm.Connection);
    lanc.DATAINI := FormatDateTime('yyyy-mm-dd', StartOfTheMonth(Date));
    lanc.DATAFIN := FormatDateTime('yyyy-mm-dd', EndOfTheMonth(Date));

    qry := lanc.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    vlReceitas := 0;
    vlDespesas := 0;
    while not qry.Eof do
    begin
      if qry.FieldByName('VALOR').AsFloat > 0 then
        vlReceitas := vlReceitas + qry.FieldByName('VALOR').AsFloat
      else
        vlDespesas := vlDespesas + qry.FieldByName('VALOR').AsFloat;

      qry.Next;
    end;

    lblSaldoReceita.Text := FormatFloat('#,##0.00', vlReceitas);
    lblSaldoDespesa.Text := FormatFloat('#,##0.00', vlDespesas);
    lblSaldoAtual.Text := FormatFloat('#,##0.00', vlReceitas + vlDespesas);
  finally
    qry.DisposeOf;
    lanc.DisposeOf;
  end;
end;

procedure TfrmPrincipal.CarregaIcone;
var
  usu: TUsuario;
  qry: TFDQuery;
  erro: String;
  foto: TStream;
begin
  try
    usu := TUsuario.Create(DM.Connection);
    qry := usu.ListarUsuario(erro);

    if qry.FieldByName('FOTO').AsString <> '' then
      foto := qry.CreateBlobStream(qry.FieldByName('FOTO'), TBlobStreamMode.bmRead)
    else
      foto := nil;

    if foto <> nil then
    begin
      cAvatar.Fill.Bitmap.Bitmap.LoadFromStream(foto);
      foto.DisposeOf;
    end;
  finally
    qry.DisposeOf;
    usu.DisposeOf;
  end;

end;

end.
