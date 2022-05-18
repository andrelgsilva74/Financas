unit cCategoria;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
  TCategoria = class
    private
      Fconn: TFDConnection;
      FID_CATEGORIA: Integer;
      FDESCRICAO: String;
      FICONE: TBitmap;
      FINDICE_ICONE: Integer;
    public
      constructor Create(conn: TFDConnection);
      property ID_CATEGORIA: Integer read FID_CATEGORIA write FID_CATEGORIA;
      property DESCRICAO: String read FDESCRICAO write FDESCRICAO;
      property ICONE: TBitmap read FICONE write FICONE;
      property INDICE_ICONE: Integer read FINDICE_ICONE write FINDICE_ICONE;

      function listarCategoria(out erro: String): TFDQuery;
      function Inserir(out erro: string): Boolean;
      function Alterar(out erro: string): Boolean;
      function Excluir(out erro: string): Boolean;
  end;

implementation

{ TCategoria }

constructor TCategoria.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TCategoria.Inserir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if DESCRICAO = '' then
  begin
      erro := 'Informe a descrição da categoria';
      Result := False;
      Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;
      qry.SQL.Add('INSERT INTO TAB_CATEGORIA(DESCRICAO, ICONE, INDICE_ICONE)');
      qry.SQL.Add('VALUES(:DESCRICAO, :ICONE, :INDICE_ICONE)');
      qry.ParamByName('DESCRICAO').Value := DESCRICAO;
      qry.ParamByName('ICONE').Assign(ICONE);
      qry.ParamByName('INDICE_ICONE').Value := INDICE_ICONE;
      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao inserir categorias: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TCategoria.Alterar(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if ID_CATEGORIA <= 0 then
  begin
    erro := 'Informe o ID da categoria';
    Result := False;
    Exit;
  end;

  if DESCRICAO = '' then
  begin
    erro := 'Informe a descrição da categoria';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('UPDATE TAB_CATEGORIA SET DESCRICAO = :DESCRICAO, ICONE = :ICONE, ');
      qry.SQL.Add('INDICE_ICONE = :INDICE_ICONE');
      qry.SQL.Add('WHERE ID = :ID_CATEGORIA');

      qry.ParamByName('DESCRICAO').Value := DESCRICAO;
      qry.ParamByName('ICONE').Assign(ICONE);
      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
      qry.ParamByName('INDICE_ICONE').Value := INDICE_ICONE;

      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao alterar categorias: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TCategoria.Excluir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
    // Validacoes...
  if ID_CATEGORIA <= 0 then
  begin
    erro := 'Informe o ID da categoria';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      // Validar se categoria possui lancamentos....
      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('SELECT * FROM TAB_LANCAMENTO ');
      qry.SQL.Add('WHERE ID_CATEGORIA = :ID_CATEGORIA');

      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
      qry.Active := True;

      if qry.RecordCount > 0 then
      begin
        Result := False;
        erro := 'A categoria possui lançamentos e não pode ser excluída!';
        Exit;
      end;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('DELETE FROM TAB_CATEGORIA ');
      qry.SQL.Add('WHERE ID = :ID_CATEGORIA');

      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;

      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao excluir categorias: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TCategoria.listarCategoria(out erro: String): TFDQuery;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    qry.Active := False;
    qry.SQL.Clear;
    qry.SQL.Add('SELECT * FROM TAB_CATEGORIA ');
    qry.SQL.Add('WHERE 1 = 1');

    if ID_CATEGORIA > 0 then
    begin
      qry.SQL.Add(' AND ID = :ID_CATEGORIA');
      qry.ParamByName('ID_CATEGORIA').Value := ID_CATEGORIA;
    end;

    qry.SQL.Add('ORDER BY DESCRICAO');
    qry.Active := True;

    Result := qry;
    erro := '';
  except on E: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar categoria: ' + E.Message;
    end;
  end;
end;

end.
