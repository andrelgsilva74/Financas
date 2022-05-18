object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 388
  Width = 405
  object Connection: TFDConnection
    Params.Strings = (
      'Database=E:\Projetos\Curso Delphi Mobile\DB\SistemaFinanceiro.db'
      'OpenMode=ReadWrite'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 32
  end
end
