unit cLancamento;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
  TLancamento = class
  private
    Fconn: TFDConnection;
    FID_CATEGORIA: Integer;
    FDESCRICAO: string;
    FVALOR: double;
    FDATA: TDateTime;
    FID_LANCAMENTO: Integer;
    FDATAINI: string;
    FDATAFIN: string;
  public
    constructor Create(conn: TFDConnection);
    property ID_LANCAMENTO: Integer read FID_LANCAMENTO write FID_LANCAMENTO;
    property ID_CATEGORIA: Integer read FID_CATEGORIA write FID_CATEGORIA;
    property VALOR: double read FVALOR write FVALOR;
    property DATA: TDateTime read FDATA write FDATA;
    property DATAINI: string read FDATAINI write FDATAINI;
    property DATAFIN: string read FDATAFIN write FDATAFIN;
    property DESCRICAO: string read FDESCRICAO write FDESCRICAO;

    function ListarLancamento(qtd_result: integer; out erro: string): TFDQuery;
    function ListarResumo(out erro: string): TFDQuery;
    function Inserir(out erro: string): Boolean;
    function Alterar(out erro: string): Boolean;
    function Excluir(out erro: string): Boolean;
end;

implementation

{ TCategoria }

constructor TLancamento.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TLancamento.Inserir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if ID_CATEGORIA <= 0 then
  begin
    erro := 'Informe a categoria do lançamento';
    Result := False;
    Exit;
  end;

  if DESCRICAO = '' then
  begin
    erro := 'Informe a descrição do lançamento';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('INSERT INTO TAB_LANCAMENTO(ID_CATEGORIA, VALOR, DATA, DESCRICAO)');
      qry.SQL.Add('VALUES(:ID_CATEGORIA, :VALOR, :DATA, :DESCRICAO)');

      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
      qry.ParamByName('VALOR').Value := VALOR;
      qry.ParamByName('DATA').Value := FDATA;
      qry.ParamByName('DESCRICAO').Value := DESCRICAO;

      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao inserir lançamento: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;


function TLancamento.Alterar(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if ID_LANCAMENTO <= 0 then
  begin
    erro := 'Informe o lançamento';
    Result := False;
    Exit;
  end;

  if ID_CATEGORIA <= 0 then
  begin
    erro := 'Informe a categoria do lançamento';
    Result := False;
    Exit;
  end;

  if DESCRICAO = '' then
  begin
    erro := 'Informe a descrição do lançamento';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('UPDATE TAB_LANCAMENTO SET ID_CATEGORIA = :ID_CATEGORIA, VALOR = :VALOR, ');
      qry.SQL.Add('DATA = :DATA, DESCRICAO = :DESCRICAO ');
      qry.SQL.Add('WHERE ID_LANCAMENTO = :ID_LANCAMENTO');

      qry.ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;
      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
      qry.ParamByName('VALOR').Value := VALOR;
      qry.ParamByName('DATA').Value := FDATA;
      qry.ParamByName('DESCRICAO').Value := DESCRICAO;

      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao alterar lançamento: ' + E.Message;
      end;
    end;

  finally
      qry.DisposeOf;
  end;
end;

function TLancamento.Excluir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if ID_LANCAMENTO <= 0 then
  begin
    erro := 'Informe o lançamento';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('DELETE FROM TAB_LANCAMENTO ');
      qry.SQL.Add('WHERE ID_LANCAMENTO = :ID_LANCAMENTO');
      qry.ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;

      qry.ExecSQL;

      Result := True;
      erro := '';

    Except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao excluir o lançamento: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TLancamento.ListarLancamento(qtd_result: integer; out erro: string): TFDQuery;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    qry.Active := False;
    qry.sql.Clear;

    qry.sql.Add('SELECT L.*, C.DESCRICAO AS DESCRICAO_CATEGORIA, C.ICONE ');
    qry.sql.Add('FROM TAB_LANCAMENTO L ');
    qry.sql.Add('JOIN TAB_CATEGORIA C ON (C.ID= L.ID_CATEGORIA) ');
    qry.sql.Add('WHERE 1 = 1 ');

    if ID_LANCAMENTO > 0 then
    begin
      qry.SQL.Add('AND L.ID_LANCAMENTO = :ID_LANCAMENTO ');
      qry.ParamByName('ID_LANCAMENTO').Value := ID_LANCAMENTO;
    end;

    if ID_CATEGORIA > 0 then
    begin
      qry.SQL.Add('AND L.ID_CATEGORIA = :ID_CATEGORIA ');
      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
    end;

    if (DATAINI <> '') AND (DATAFIN <> '') then
      qry.SQL.Add('AND L.DATA BETWEEN ''' + DATAINI + ''' AND ''' + DATAFIN + '''');

    qry.sql.Add(' ORDER BY L.DATA DESC');

    if qtd_result > 0 then
      qry.sql.Add('LIMIT ' + qtd_result.ToString);

    qry.Active := True;

    Result := qry;
    erro := '';

  Except on E: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar categorias: ' + E.Message;
    end;
  end;
end;

function TLancamento.ListarResumo(out erro: String): TFDQuery;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    qry.Active := False;
    qry.sql.Clear;

    qry.sql.Add('SELECT C.ICONE, C.DESCRICAO, CAST(SUM(L.VALOR) AS REAL) AS VALOR');
    qry.sql.Add('FROM TAB_LANCAMENTO L');
    qry.sql.Add('JOIN TAB_CATEGORIA C ON (C.ID = L.ID_CATEGORIA)');
    qry.SQL.Add('WHERE L.DATA BETWEEN ''' + DATAINI + ''' AND ''' + DATAFIN + '''');
    qry.sql.Add('GROUP BY C.ICONE, C.DESCRICAO');
    qry.sql.Add('ORDER BY 3');
    qry.Active := True;

    Result := qry;
    erro := '';

  Except on E: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar categorias: ' + E.Message;
    end;
  end;
end;


end.
