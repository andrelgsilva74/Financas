unit uCategorias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TfrmCategorias = class(TForm)
    lytTop: TLayout;
    lblRotulo: TLabel;
    imgVoltar: TImage;
    rectBottom: TRectangle;
    imgAdd: TImage;
    lblNumCategorias: TLabel;
    lvCategorias: TListView;
    procedure imgVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lvCategoriasUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure cadCategoria(id_cad: String);
    procedure imgAddClick(Sender: TObject);
    procedure lvCategoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure listarCategorias;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCategorias: TfrmCategorias;

implementation

{$R *.fmx}

uses uPrincipal, uFuncoes, uCadCategorias, cCategoria, uDM;

procedure TfrmCategorias.listarCategorias;
var
  cat: TCategoria;
  qry: TFDQuery;
  erro, vCategoria: String;
  icone: TStream;
begin
  try
    lvCategorias.Items.Clear;
    cat := TCategoria.Create(DM.Connection);
    qry := cat.listarCategoria(erro);

    while not qry.Eof do
    begin
      //Icone
      if qry.FieldByName('ICONE').AsString <> '' then
        icone := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead)
      else
        icone := nil;

      AddCategoria(lvCategorias , qry.FieldByName('ID').AsString
                                , qry.FieldByName('DESCRICAO').AsString, icone);

      if icone <> nil then
        icone.DisposeOf;

      qry.Next;
    end;

    if lvCategorias.Items.Count > 1 then
      vCategoria := ' categoria'
    else
      vCategoria := ' categorias';

    lblNumCategorias.Text := lvCategorias.Items.Count.ToString + vCategoria;
  finally
    qry.DisposeOf;
    cat.DisposeOf;
  end;
end;

procedure TfrmCategorias.cadCategoria(id_cad: String);
begin
  if not Assigned(frmCadCategorias) then
    Application.CreateForm(TfrmCadCategorias, frmCadCategorias);

  if id_cad = '' then
  begin
    frmCadCategorias.id_cat := 0;
    frmCadCategorias.modo := 'I';
    frmCadCategorias.lblRotulo.Text := 'Nova Categoria';
  end
  else
  begin
    frmCadCategorias.id_Cat := id_cad.ToInteger;
    frmCadCategorias.modo := 'A';
    frmCadCategorias.lblRotulo.Text := 'Editar Categoria';
  end;

  frmCadCategorias.Show;
end;

procedure TfrmCategorias.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmCategorias := nil;
end;

procedure TfrmCategorias.FormShow(Sender: TObject);
begin
  listarCategorias;
end;

procedure TfrmCategorias.imgAddClick(Sender: TObject);
begin
  cadCategoria('');
end;

procedure TfrmCategorias.imgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCategorias.lvCategoriasItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  cadCategoria(AItem.TagString);
end;

procedure TfrmCategorias.lvCategoriasUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  setupLancamento(lvCategorias, AItem, 'txtCategoria', 50);
end;

end.
