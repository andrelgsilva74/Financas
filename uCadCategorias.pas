unit uCadCategorias;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit, FMX.ListBox,
  FireDAC.Comp.Client, FireDAC.DApt, Data.DB, FMX.DialogService;

type
  TfrmCadCategorias = class(TForm)
    lytTop: TLayout;
    lblRotulo: TLabel;
    imgVoltar: TImage;
    imgSave: TImage;
    lytDescricao: TLayout;
    lblNovaCategoria: TLabel;
    edtDescricao: TEdit;
    lineNovaCategoria: TLine;
    lblIcone: TLabel;
    lbxIcone: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    imgSelecao: TImage;
    rect_delete: TRectangle;
    img_delete: TImage;
    procedure imgVoltarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgSaveClick(Sender: TObject);
    procedure img_deleteClick(Sender: TObject);
  private
    { Private declarations }
    iconeSelecionado: TBitmap;
    indiceSelecionado: Integer;
    procedure SelecionaIcone(img: TImage);
  public
    { Public declarations }
    modo: String; //I - Inclusão A - Alteração
    id_Cat: Integer;
  end;

var
  frmCadCategorias: TfrmCadCategorias;

implementation

{$R *.fmx}

uses uPrincipal, uFuncoes, cCategoria, uDM, uCategorias;

procedure TfrmCadCategorias.SelecionaIcone(img: TImage);
begin
  // Salvar ícone selecionado
  iconeSelecionado := img.Bitmap;
  indiceSelecionado := TListBoxItem(img.Parent).Index;
  imgSelecao.Parent := img.Parent;
end;

procedure TfrmCadCategorias.FormResize(Sender: TObject);
begin
  lbxIcone.Columns := Trunc(lbxIcone.Width / 80);
end;

procedure TfrmCadCategorias.FormShow(Sender: TObject);
var
  cat: TCategoria;
  qry: TFDQuery;
  erro: String;
  item: TListBoxItem;
  img: TImage;
begin
  if modo = 'I' then
  begin
    rect_delete.Visible := False;
    edtDescricao.Text := '';
    SelecionaIcone(Image1);
  end
  else
  begin
    try
      rect_delete.Visible := True;
      cat := TCategoria.Create(DM.Connection);
      cat.ID_CATEGORIA := id_cat;

      qry := cat.listarCategoria(erro);

      edtDescricao.Text := qry.FieldByName('DESCRICAO').AsString;

      //icone
      item := lbxIcone.ItemByIndex(qry.FieldByName('INDICE_ICONE').AsInteger);
      imgSelecao.Parent := item;

      img := frmCadCategorias.FindComponent('Image' + Succ(item.Index).ToString) as TImage;
      SelecionaIcone(img);
    finally
      qry.DisposeOf;
      cat.DisposeOf;
    end;
  end;
end;

procedure TfrmCadCategorias.Image1Click(Sender: TObject);
begin
  SelecionaIcone(TImage(Sender));
end;

procedure TfrmCadCategorias.imgSaveClick(Sender: TObject);
var
  cat: TCategoria;
  erro: String;
begin
  try
    cat := TCategoria.Create(DM.Connection);

    cat.DESCRICAO := edtDescricao.Text;
    cat.ICONE := iconeSelecionado;
    cat.INDICE_ICONE := indiceSelecionado;

    if modo = 'I' then
    begin
      edtDescricao.SetFocus;
      cat.Inserir(erro)
    end
    else
    if modo = 'A' then
    begin
      cat.ID_CATEGORIA := id_cat;
      cat.Alterar(erro);
    end;

    if erro <> '' then
    begin
      ShowMessage(erro);
      Exit;
    end;

    frmCategorias.listarCategorias;
    Close;
  finally
    cat.DisposeOf;
  end;
end;

procedure TfrmCadCategorias.imgVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadCategorias.img_deleteClick(Sender: TObject);
var
  cat: TCategoria;
  erro: String;
begin
  TDialogService.MessageDialog('Confirma exclusão da categoria?',
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
        cat := TCategoria.Create(dm.Connection);
        cat.ID_CATEGORIA := id_cat;

        if not cat.Excluir(erro) then
        begin
          ShowMessage(erro);
          Exit;
        end;

        FrmCategorias.ListarCategorias;
        Close;

      finally
        cat.DisposeOf;
      end;
    end;
  end);
end;

end.
