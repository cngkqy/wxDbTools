object Form2: TForm2
  Left = 0
  Top = 0
  Caption = #24494#20449#25968#25454#24211#24037#20855
  ClientHeight = 360
  ClientWidth = 993
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object Memo1: TMemo
    Left = 233
    Top = 0
    Width = 394
    Height = 360
    Align = alLeft
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 233
    Height = 360
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 1
    object ListBox1: TListBox
      Left = 1
      Top = 25
      Width = 231
      Height = 334
      Align = alClient
      TabOrder = 0
      OnDblClick = ListBox1DblClick
    end
    object ComboBox1: TComboBox
      Left = 1
      Top = 1
      Width = 231
      Height = 24
      Align = alTop
      TabOrder = 1
      Text = #30331#24405#20043#21069#21551#21160
      OnChange = ComboBox1Change
    end
  end
  object Panel2: TPanel
    Left = 627
    Top = 0
    Width = 366
    Height = 360
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 2
    object Edit1: TEdit
      Left = 1
      Top = 1
      Width = 364
      Height = 24
      Align = alTop
      TabOrder = 0
      Text = 'SELECT * FROM tablexx   LIMIT 5'
    end
    object Button1: TButton
      Left = 1
      Top = 25
      Width = 364
      Height = 25
      Align = alTop
      Caption = #25191#34892
      TabOrder = 1
      OnClick = Button1Click
    end
    object Memo2: TMemo
      Left = 1
      Top = 50
      Width = 364
      Height = 309
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 2
    end
  end
end
