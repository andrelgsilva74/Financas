unit uFuncoes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.TabControl, FMX.ListBox, FMX.Layouts,
  FMX.VirtualKeyboard, System.MaskUtils, DateUtils,

  {$IFDEF ANDROID}
  AndroidAPI.Jni.Net, AndroidAPI.Jni.JavaTypes, AndroidAPI.Jni, AndroidAPI.JNIBridge,
  AndroidAPI.Helpers, FMX.Helpers.Android, AndroidAPI.Jni.GraphicsContentViewText,
  {$ENDIF ANDROID}

  {$IFDEF IOS}
  Macapi.Helpers, iOSAPI.Foundation, FMX.Helpers.iOS,
  {$ENDIF IOS}
  FMX.Platform, FMX.Objects, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView;

type
    TFormato = (CNPJ, CPF, InscricaoEstadual, CNPJorCPF, TelefoneFixo, Celular, Personalizado,
                Valor, Money, CEP, Dt, Peso);

procedure Formatar(Obj: TObject; Formato : TFormato; Extra : string = '');
procedure AddLancamento(listView: TListView; idLancamento, descricao, categoria: String;
  dtData: TDateTime; valor: Double; foto: TStream);
procedure AddCategoria(listView: TListView; idCategoria, categoria: String; foto: TStream);
procedure AddCategoriaResumo(listView: TListView; Categoria: String; Valor: Double; foto: TStream);
procedure setupLancamento(listView: TListView; item: TListViewItem; Texto: String; Margem: Integer);
function nomeMes(mes: TDateTime): String;

implementation

function nomeMes(mes: TDateTime): String;
begin
  case MonthOf(mes) of
    1: Result := 'Janeiro';
    2: Result := 'Fevereiro';
    3: Result := 'Março';
    4: Result := 'Abril';
    5: Result := 'Maio';
    6: Result := 'Junho';
    7: Result := 'Julho';
    8: Result := 'Agosto';
    9: Result := 'Setembro';
    10: Result := 'Outubro';
    11: Result := 'Novembro';
    12: Result := 'Dezembro';
  end;

  Result := Result + '/' + YearOf(mes).ToString;
end;

procedure AddLancamento(listView: TListView; idLancamento, descricao, categoria: String;
  dtData: TDateTime; valor: Double; foto: TStream);
var
  bmp: TBitmap;
begin
  with listView.Items.Add do
  begin
    TagString := idLancamento;

    TListItemText(Objects.FindDrawable('txtDescricao')).Text := descricao;
    TListItemText(Objects.FindDrawable('txtCategoria')).Text := categoria;
    TListItemText(Objects.FindDrawable('txtValor')).Text     := FormatFloat('#,##0.00', valor);
    TListItemText(Objects.FindDrawable('txtData')).Text      := FormatDateTime('dd/mm', dtData);

    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      TListItemImage(Objects.FindDrawable('imgIcone')).OwnsBitmap := True;
      TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap := bmp;
    end;
  end;
end;

procedure AddCategoria(listView: TListView; idCategoria, categoria: String; foto: TStream);
var // Insere os itens na listView
  bmp: TBitmap;
begin
  with listView.Items.Add do
  begin
    TagString := idCategoria;

    TListItemText(Objects.FindDrawable('txtCategoria')).Text := categoria;

    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      TListItemImage(Objects.FindDrawable('imgIcone')).OwnsBitmap := True;
      TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap := bmp;
    end;
  end;
end;

procedure AddCategoriaResumo(listView: TListView; Categoria: String; Valor: Double; foto: TStream);
var // Insere os itens na listView
  bmp: TBitmap;
begin
  with listView.Items.Add do
  begin
    TListItemText(Objects.FindDrawable('txtCategoria')).Text := categoria;
    TListItemText(Objects.FindDrawable('txtValor')).Text := FormatFloat('#,##0.00', Valor);

    if foto <> nil then
    begin
      bmp := TBitmap.Create;
      bmp.LoadFromStream(foto);
      TListItemImage(Objects.FindDrawable('imgIcone')).OwnsBitmap := True;
      TListItemImage(Objects.FindDrawable('imgIcone')).Bitmap := bmp;
    end;
  end;
end;

function SomenteNumero(str : string) : string;
var
  x: integer;
begin
  Result := '';
  for x := 0 to Length(str) - 1 do
    if (str.Chars[x] In ['0'..'9']) then
      Result := Result + str.Chars[x];
end;

function FormataValor(str : string) : string;
begin
  if Str = '' then
    Str := '0';

  try
    Result := FormatFloat('#,##0.00', strtofloat(str) / 100);
  except
    Result := FormatFloat('#,##0.00', 0);
  end;
end;

function FormataPeso(str : string) : string;
begin
  if Str.IsEmpty then
    Str := '0';

  try
    Result := FormatFloat('#,##0.000', strtofloat(str) / 1000);
  except
    Result := FormatFloat('#,##0.000', 0);
  end;
end;

function Mask(Mascara, Str : string) : string;
var
  x, p : integer;
begin
  p := 0;
  Result := '';

  if Str.IsEmpty then
    exit;

  for x := 0 to Length(Mascara) - 1 do
  begin
    if Mascara.Chars[x] = '#' then
    begin
      Result := Result + Str.Chars[p];
      inc(p);
    end
    else
      Result := Result + Mascara.Chars[x];

    if p = Length(Str) then
      break;
  end;
end;

function FormataIE(Num, UF: string): string;
var
  Mascara: string;
begin
  Mascara := '';

  if UF = 'AC' then Mascara := '##.###.###/###-##';
  if UF = 'AL' then Mascara := '#########';
  if UF = 'AP' then Mascara := '#########';
  if UF = 'AM' then Mascara := '##.###.###-#';
  if UF = 'BA' then Mascara := '######-##';
  if UF = 'CE' then Mascara := '########-#';
  if UF = 'DF' then Mascara := '###########-##';
  if UF = 'ES' then Mascara := '#########';
  if UF = 'GO' then Mascara := '##.###.###-#';
  if UF = 'MA' then Mascara := '#########';
  if UF = 'MT' then Mascara := '##########-#';
  if UF = 'MS' then Mascara := '#########';
  if UF = 'MG' then Mascara := '###.###.###/####';
  if UF = 'PA' then Mascara := '##-######-#';
  if UF = 'PB' then Mascara := '########-#';
  if UF = 'PR' then Mascara := '########-##';
  if UF = 'PE' then Mascara := '##.#.###.#######-#';
  if UF = 'PI' then Mascara := '#########';
  if UF = 'RJ' then Mascara := '##.###.##-#';
  if UF = 'RN' then Mascara := '##.###.###-#';
  if UF = 'RS' then Mascara := '###/#######';
  if UF = 'RO' then Mascara := '###.#####-#';
  if UF = 'RR' then Mascara := '########-#';
  if UF = 'SC' then Mascara := '###.###.###';
  if UF = 'SP' then Mascara := '###.###.###.###';
  if UF = 'SE' then Mascara := '#########-#';
  if UF = 'TO' then Mascara := '###########';

  Result := Mask(mascara, Num);
end;

function FormataData(str : string): string;
begin
  str := Copy(str, 1, 8);

  if Length(str) < 8 then
    Result := Mask('##/##/####', str)
  else
  begin
    try
      str := Mask('##/##/####', str);
      strtodate(str);
      Result := str;
    except
      Result := '';
    end;
  end;
end;

procedure setupLancamento(listView: TListView; item: TListViewItem; Texto: String; Margem: Integer);
var  // Organiza os objetos dentro da listView
  txt: TListItemText;
begin
  txt := TListItemText(Item.Objects.FindDrawable(Texto));
  txt.Width := listView.Width - txt.PlaceOffset.X - Margem;
end;

procedure Formatar(Obj: TObject; Formato : TFormato; Extra : string = '');
var
  texto : string;
begin
  TThread.Queue(Nil, procedure
  begin
    if obj is TEdit then
      texto := TEdit(obj).Text;

    // Telefone Fixo...
    if formato = TelefoneFixo then
      texto := Mask('(##) ####-####', SomenteNumero(texto));

    // Celular...
    if formato = Celular then
      texto := Mask('(##) #####-####', SomenteNumero(texto));

    // CNPJ...
    if formato = CNPJ then
      texto := Mask('##.###.###/####-##', SomenteNumero(texto));

    // CPF...
    if formato = CPF then
      texto := Mask('###.###.###-##', SomenteNumero(texto));

    // Inscricao Estadual (IE)...
    if formato = InscricaoEstadual then
      texto := FormataIE(SomenteNumero(texto), Extra);

    // CNPJ ou CPF...
    if formato = CNPJorCPF then
      if Length(SomenteNumero(texto)) <= 11 then
        texto := Mask('###.###.###-##', SomenteNumero(texto))
      else
        texto := Mask('##.###.###/####-##', SomenteNumero(texto));

    // Personalizado...
    if formato = Personalizado then
      texto := Mask(Extra, SomenteNumero(texto));

    // Valor...
    if Formato = Valor then
      texto := FormataValor(SomenteNumero(texto));

    // Money (com simbolo da moeda)...
    if Formato = Money then
    begin
      if Extra = '' then
        Extra := 'R$';

      texto := Extra + ' ' + FormataValor(SomenteNumero(texto));
    end;

    // CEP...
    if Formato = CEP then
      texto := Mask('##.###-###', SomenteNumero(texto));

    // Data...
    if formato = Dt then
      texto := FormataData(SomenteNumero(texto));

    // Peso...
    if Formato = Peso then
      texto := FormataPeso(SomenteNumero(texto));

    if obj is TEdit then
    begin
      TEdit(obj).Text := texto;
      TEdit(obj).CaretPosition := TEdit(obj).Text.Length;
    end;
  end);
end;

end.
