unit uLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, FMX.TabControl,
  System.Actions, FMX.ActnList, u99Permissions, FMX.MediaLibrary.Actions,

  {$IFDEF ANDROID}
  FMX.VirtualKeyboard, FMX.Platform,
  {$ENDIF}

  FMX.StdActns, FireDAC.Comp.Client, FireDAC.DApt, Data.DB, FMX.DialogService;

type
  TfrmLogin = class(TForm)
    lytMain: TLayout;
    imgLoginLogo: TImage;
    lytEmail: TLayout;
    lytSenha: TLayout;
    lytEntrar: TLayout;
    rrEmail: TRoundRect;
    rrSenha: TRoundRect;
    rrEntrar: TRoundRect;
    edtEmail: TEdit;
    edtSenha: TEdit;
    StyleBook1: TStyleBook;
    lblAcesso: TLabel;
    TabControl: TTabControl;
    tabLogin: TTabItem;
    tabConta: TTabItem;
    lytCadMain: TLayout;
    imgCadLogin: TImage;
    lytCadNome: TLayout;
    rrCadNome: TRoundRect;
    edtCadNome: TEdit;
    lytCadEmail: TLayout;
    rrCadEmail: TRoundRect;
    edtCadEmail: TEdit;
    lytNext: TLayout;
    rrNext: TRoundRect;
    lblNext: TLabel;
    lytCadSenha: TLayout;
    rrCadSenha: TRoundRect;
    edtCadSenha: TEdit;
    tabFoto: TTabItem;
    lytFoto: TLayout;
    cFotoEditar: TCircle;
    lytCriar: TLayout;
    rrCriar: TRoundRect;
    lblCriar: TLabel;
    tabLibrary: TTabItem;
    lytLibrary: TLayout;
    lblTirarFoto: TLabel;
    imgCamera: TImage;
    imgLibrary: TImage;
    lblCamera: TLabel;
    lblLibrary: TLabel;
    lytVoltar: TLayout;
    imgVoltar: TImage;
    Layout1: TLayout;
    Image1: TImage;
    lytBotoes: TLayout;
    lytNavigationLogin: TLayout;
    lblLoginTab: TLabel;
    lblLoginConta: TLabel;
    recUnderline: TRectangle;
    ActionList: TActionList;
    actConta: TChangeTabAction;
    actFoto: TChangeTabAction;
    actLibrary: TChangeTabAction;
    actLogin: TChangeTabAction;
    lytBotoesConta: TLayout;
    lytNavigationConta: TLayout;
    lblContaLogin: TLabel;
    lblContaCriar: TLabel;
    recUnderlineConta: TRectangle;
    actPhotoLibrary: TTakePhotoFromLibraryAction;
    actCamera: TTakePhotoFromCameraAction;
    tabMain: TTabItem;
    lytPrincipal: TLayout;
    imgPrincipalLogo: TImage;
    lblBoasVindas: TLabel;
    imgEntrar: TImage;
    Timer1: TTimer;
    procedure lblLoginContaClick(Sender: TObject);
    procedure lblNextClick(Sender: TObject);
    procedure lblContaCriarClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure cFotoEditarClick(Sender: TObject);
    procedure imgVoltarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgCameraClick(Sender: TObject);
    procedure imgLibraryClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgEntrarClick(Sender: TObject);
    procedure actPhotoLibraryDidFinishTaking(Image: TBitmap);
    procedure actCameraDidFinishTaking(Image: TBitmap);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure lblAcessoClick(Sender: TObject);
    procedure rrEntrarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rrCriarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormVirtualKeyboardShown(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardHidden(Sender: TObject;
      KeyboardVisible: Boolean; const Bounds: TRect);
  private
    { Private declarations }
    permissao: T99Permissions;

    procedure TrataErroPermissao(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.fmx}

uses uPrincipal, cUsuario, uDM, uFuncoes;

procedure TfrmLogin.Timer1Timer(Sender: TObject);
var
  usu: TUsuario;
  qry: TFDQuery;
  erro: String;
begin
  Timer1.Enabled := False;

  //valida se estiver logado
  try
    usu := TUsuario.Create(DM.Connection);
    qry := TFDQuery.Create(nil);

    qry := usu.ListarUsuario(erro);

    if qry.FieldByName('IND_LOGIN').AsString <> 'S' then
      Exit;
  finally
    usu.DisposeOf;
    qry.DisposeOf;
  end;

  if not Assigned(frmPrincipal) then
    Application.CreateForm(TfrmPrincipal, frmPrincipal);

  Application.MainForm := frmPrincipal;
  frmPrincipal.Show;
  frmLogin.Close;
end;

procedure TfrmLogin.TrataErroPermissao(Sender: TObject);
begin
  ShowMessage('Você não tem permissão de acesso para esse recurso');
end;

procedure TfrmLogin.actCameraDidFinishTaking(Image: TBitmap);
begin
  cFotoEditar.Fill.Bitmap.Bitmap := Image;
  actFoto.Execute;
end;

procedure TfrmLogin.actPhotoLibraryDidFinishTaking(Image: TBitmap);
begin
  cFotoEditar.Fill.Bitmap.Bitmap := Image;
  actFoto.Execute;
end;

procedure TfrmLogin.cFotoEditarClick(Sender: TObject);
begin
  actLibrary.Execute;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmLogin := nil;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  permissao := T99Permissions.Create;
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  permissao.DisposeOf;
end;

procedure TfrmLogin.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
{$IFDEF ANDROID}
var
    FService: IFMXVirtualKeyboardService;
{$ENDIF}
begin
  {$IFDEF ANDROID}
  if (Key = vkHardwareBack) then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));

    if (FService <> nil) and
       (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      // Botao back pressionado e teclado visivel...
      // (apenas fecha o teclado)
    end
    else
    begin
      // Botao back pressionado e teclado NAO visivel...

      if TabControl.ActiveTab = tabLogin then
      begin
        Key := 0;
        actLogin.Execute;
      end
      else
      if TabControl.ActiveTab = tabFoto then
      begin
        Key := 0;
        actConta.Execute;
      end
      else
      if TabControl.ActiveTab = tabLibrary then
      begin
        Key := 0;
        actFoto.Execute;
      end;
    end;
  end;
  {$ENDIF}
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  TabControl.ActiveTab := tabMain;
  Timer1.Enabled := True;
end;

procedure TfrmLogin.FormVirtualKeyboardHidden(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TabControl.Margins.Bottom := 0;
end;

procedure TfrmLogin.FormVirtualKeyboardShown(Sender: TObject;
  KeyboardVisible: Boolean; const Bounds: TRect);
begin
  TabControl.Margins.Bottom := 170;
end;

procedure TfrmLogin.Image1Click(Sender: TObject);
begin
  actConta.Execute;
end;

procedure TfrmLogin.imgCameraClick(Sender: TObject);
begin
  permissao.Camera(actCamera, TrataErroPermissao);
end;

procedure TfrmLogin.imgEntrarClick(Sender: TObject);
begin
  actLogin.Execute;
end;

procedure TfrmLogin.imgVoltarClick(Sender: TObject);
begin
  actFoto.Execute;
end;

procedure TfrmLogin.lblAcessoClick(Sender: TObject);
begin
  //
end;

procedure TfrmLogin.lblContaCriarClick(Sender: TObject);
begin
  actLogin.Execute;
end;

procedure TfrmLogin.lblLoginContaClick(Sender: TObject);
begin
  actConta.Execute;
end;

procedure TfrmLogin.lblNextClick(Sender: TObject);
begin
  actFoto.Execute;
end;

procedure TfrmLogin.rrCriarClick(Sender: TObject);
var
  usu: TUsuario;
  erro: String;
begin
  try
    usu := TUsuario.Create(DM.Connection);
    usu.NOME := edtCadNome.Text;
    usu.EMAIL := edtCadEmail.Text;
    usu.SENHA := edtCadSenha.Text;
    usu.IND_LOGIN := 'S';
    usu.FOTO := cFotoEditar.Fill.Bitmap.Bitmap;

    if not usu.Excluir(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

    if not usu.Inserir(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

  finally
    usu.DisposeOf;
  end;

  if not Assigned(frmPrincipal) then
    Application.CreateForm(TfrmPrincipal, frmPrincipal);

  Application.MainForm := frmPrincipal;
  frmPrincipal.Show;
  frmLogin.Close;
end;

procedure TfrmLogin.rrEntrarClick(Sender: TObject);
var
  usu: TUsuario;
  erro: String;
begin
  try
    usu := TUsuario.Create(DM.Connection);
    usu.EMAIL := edtEmail.Text;
    usu.SENHA := edtSenha.Text;

    if not usu.ValidarLogin(erro) then
    begin
      ShowMessage(erro);
      Exit;
    end;

  finally
    usu.DisposeOf;
  end;

  if not Assigned(frmPrincipal) then
    Application.CreateForm(TfrmPrincipal, frmPrincipal);

  Application.MainForm := frmPrincipal;
  frmPrincipal.Show;
  frmLogin.Close;
end;

procedure TfrmLogin.imgLibraryClick(Sender: TObject);
begin
  permissao.PhotoLibrary(actPhotoLibrary, TrataErroPermissao);
end;

end.
