program prjMobile;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uLogin in 'uLogin.pas' {frmLogin},
  u99Permissions in 'Units\u99Permissions.pas',
  uLancamentos in 'uLancamentos.pas' {frmLancamentos},
  uFuncoes in 'Units\uFuncoes.pas',
  uCadDespesas in 'uCadDespesas.pas' {frmCadDespesas},
  uCategorias in 'uCategorias.pas' {frmCategorias},
  uCadCategorias in 'uCadCategorias.pas' {frmCadCategorias},
  uDM in 'uDM.pas' {DM: TDataModule},
  cCategoria in 'Classes\cCategoria.pas',
  cLancamento in 'Classes\cLancamento.pas',
  cUsuario in 'Classes\cUsuario.pas',
  uComboCategoria in 'uComboCategoria.pas' {frmComboCategoria},
  uLancamentosResumo in 'uLancamentosResumo.pas' {frmLancamentosResumo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmComboCategoria, frmComboCategoria);
  Application.CreateForm(TfrmLancamentosResumo, frmLancamentosResumo);
  Application.Run;
end.
