unit uComboCategoria;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB;

type
  TfrmComboCategoria = class(TForm)
    lytTop: TLayout;
    lblRotulo: TLabel;
    imgVoltar: TImage;
    lvCategorias: TListView;
    procedure imgVoltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvCategoriasItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    procedure listarCategorias;
    { Private declarations }
  public
    { Public declarations }

    CategoriaSelecao: String;
    idCategoriaSelecao: Integer;
  end;

var
  frmComboCategoria: TfrmComboCategoria;

implementation

{$R *.fmx}

uses u99Permissions, uDM, uFuncoes, uPrincipal, cCategoria;

procedure TfrmComboCategoria.listarCategorias;
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

  finally
    qry.DisposeOf;
    cat.DisposeOf;
  end;
end;

procedure TfrmComboCategoria.lvCategoriasItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  idCategoriaSelecao := AItem.TagString.ToInteger;;
  CategoriaSelecao := TListItemText(AItem.Objects.FindDrawable('txtCategoria')).Text;
  Close;
end;

procedure TfrmComboCategoria.FormShow(Sender: TObject);
begin
  ListarCategorias;
end;

procedure TfrmComboCategoria.imgVoltarClick(Sender: TObject);
begin
  CategoriaSelecao := '';
  idCategoriaSelecao := 0;
  Close;
end;

end.
