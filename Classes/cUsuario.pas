unit cUsuario;

interface

uses FireDAC.Comp.Client, FireDAC.DApt, System.SysUtils, FMX.Graphics;

type
  TUsuario = class
  private
    Fconn: TFDConnection;
    FIND_LOGIN: string;
    FEMAIL: string;
    FSENHA: string;
    FNOME: string;
    FID_USUARIO: Integer;
    FFOTO: TBitmap;
  public
    constructor Create(conn: TFDConnection);
    property ID_USUARIO: Integer read FID_USUARIO write FID_USUARIO;
    property NOME: string read FNOME write FNOME;
    property EMAIL: string read FEMAIL write FEMAIL;
    property SENHA: string read FSENHA write FSENHA;
    property IND_LOGIN: string read FIND_LOGIN write FIND_LOGIN;
    property FOTO: TBitmap read FFOTO write FFOTO;

    function ListarUsuario(out erro: string): TFDQuery;
    function Inserir(out erro: string): Boolean;
    function Alterar(out erro: string): Boolean;
    function Excluir(out erro: string): Boolean;
    function ValidarLogin(out erro: string): boolean;
    function Logout(out erro: string): boolean;
end;

implementation

{ TCategoria }

constructor TUsuario.Create(conn: TFDConnection);
begin
  Fconn := conn;
end;

function TUsuario.Inserir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if NOME = '' then
  begin
    erro := 'Informe o nome do usuário';
    Result := False;
    Exit;
  end;

  if EMAIL = '' then
  begin
    erro := 'Informe o email do usuário';
    Result := False;
    Exit;
  end;

  if SENHA = '' then
  begin
    erro := 'Informe a senha do usuário';
    Result := False;
    Exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('INSERT INTO TAB_USUARIO(NOME, EMAIL, SENHA, IND_LOGIN, FOTO)');
      qry.SQL.Add('VALUES(:NOME, :EMAIL, :SENHA, :IND_LOGIN, :FOTO)');

      qry.ParamByName('NOME').Value := NOME;
      qry.ParamByName('EMAIL').Value := EMAIL;
      qry.ParamByName('SENHA').Value := SENHA;
      qry.ParamByName('IND_LOGIN').Value := IND_LOGIN;
      qry.ParamByName('FOTO').Assign(FOTO);
      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao inserir usuário: ' + E.Message;
      end;
    end;

  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.Alterar(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if NOME = '' then
  begin
    erro := 'Informe o nome do usuário';
    Result := false;
    exit;
  end;

  if EMAIL = '' then
  begin
    erro := 'Informe o email do usuário';
    Result := false;
    exit;
  end;

  if SENHA = '' then
  begin
    erro := 'Informe a senha do usuário';
    Result := false;
    exit;
  end;

  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;

      qry.SQL.Add('UPDATE TAB_USUARIO SET NOME=:NOME, EMAIL=:EMAIL,');
      qry.SQL.Add('SENHA=:SENHA, IND_LOGIN=:IND_LOGIN, FOTO=:FOTO');
      qry.SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');

      qry.ParamByName('ID_USUARIO').Value := ID_USUARIO;
      qry.ParamByName('NOME').Value := NOME;
      qry.ParamByName('EMAIL').Value := EMAIL;
      qry.ParamByName('SENHA').Value := SENHA;
      qry.ParamByName('IND_LOGIN').Value := IND_LOGIN;
      qry.ParamByName('FOTO').Assign(FOTO);

      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao alterar usuário: ' + E.Message;
      end;
    end;

  finally
      qry.DisposeOf;
  end;
end;

function TUsuario.Excluir(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  try
    try
      qry := TFDQuery.Create(nil);
      qry.Connection := Fconn;

      qry.Active := False;
      qry.SQL.Clear;
      qry.SQL.Add('DELETE FROM TAB_USUARIO');

      if ID_USUARIO > 0 then
      begin
        qry.SQL.Add('WHERE ID_USUARIO = :ID_USUARIO');
        qry.ParamByName('ID_USUARIO').Value := ID_USUARIO;
      end;

      qry.ExecSQL;

      Result := true;
      erro := '';

    except on ex:exception do
      begin
        Result := False;
        erro := 'Erro ao excluir usuário: ' + ex.Message;
      end;
    end;

  finally
      qry.DisposeOf;
  end;
end;

function TUsuario.ListarUsuario(out erro: string): TFDQuery;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    qry.Active := False;
    qry.sql.Clear;

    qry.sql.Add('SELECT * FROM TAB_USUARIO');
    qry.SQL.Add('WHERE 1 = 1');

    if ID_USUARIO > 0 then
    begin
      qry.SQL.Add('AND ID_USUARIO = :ID_USUARIO');
      qry.ParamByName('ID_USUARIO').Value := ID_USUARIO;
    end;

    if EMAIL <> '' then
    begin
      qry.SQL.Add('AND EMAIL = :EMAIL');
      qry.ParamByName('EMAIL').Value := EMAIL;
    end;

    if SENHA <> '' then
    begin
      qry.SQL.Add('AND SENHA = :SENHA');
      qry.ParamByName('SENHA').Value := SENHA;
    end;

    qry.Active := True;

    Result := qry;
    erro := '';

  except on E: Exception do
    begin
      Result := nil;
      erro := 'Erro ao consultar usuários: ' + E.Message;
    end;
  end;
end;

function TUsuario.ValidarLogin(out erro: string): Boolean;
var
  qry: TFDQuery;
begin
  // Validacoes...
  if EMAIL = '' then
  begin
    erro := 'Informe o email do usuário';
    Result := False;
    Exit;
  end;

  if SENHA = '' then
  begin
    erro := 'Informe a senha do usuário';
    Result := False;
    Exit;
  end;

  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    try
      qry.Active := False;
      qry.sql.Clear;

      qry.sql.Add('SELECT * FROM TAB_USUARIO');
      qry.SQL.Add('WHERE EMAIL = :EMAIL');
      qry.SQL.Add('AND SENHA = :SENHA');

      qry.ParamByName('EMAIL').Value := EMAIL;
      qry.ParamByName('SENHA').Value := SENHA;
      qry.Active := True;

      if qry.RecordCount = 0 then
      begin
        Result := False;
        erro := 'Email ou senha inválidos';
        Exit;
      end;

      qry.Active := False;
      qry.sql.Clear;
      qry.sql.Add('UPDATE TAB_USUARIO');
      qry.SQL.Add('SET IND_LOGIN = ''S''');
      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao validar login: ' + E.Message;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
end;

function TUsuario.Logout(out erro: string): boolean;
var
  qry: TFDQuery;
begin
  try
    qry := TFDQuery.Create(nil);
    qry.Connection := Fconn;

    try
      qry.Active := False;
      qry.sql.Clear;
      qry.sql.Add('UPDATE TAB_USUARIO');
      qry.SQL.Add('SET IND_LOGIN = ''N''');
      qry.ExecSQL;

      Result := True;
      erro := '';

    except on E: Exception do
      begin
        Result := False;
        erro := 'Erro ao fazer logout: ' + E.Message;
      end;
    end;
  finally
    qry.DisposeOf;
  end;
end;

end.
