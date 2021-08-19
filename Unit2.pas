unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, tlhelp32,
  PsAPI, Vcl.StdCtrls, Vcl.ExtCtrls, u_debug, Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    Panel1: TPanel;
    Button1: TButton;
    Edit1: TEdit;
    Panel2: TPanel;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  public
  end;

type
  TDbObj = class
    DBHandler: dword;
    DBName: string;
  end;

type
  TSQLiteExecCallback = function(UserData: Pointer; NumCols: integer; ColValues: PPCharArray; ColNames: PPCharArray): integer; cdecl;

  SQLite3_Exec = function(db: dword; SQLStatement: PansiChar; CallbackPtr: TSQLiteExecCallback; UserData: Pointer; var ErrMsg: PChar): integer; cdecl;

var
  Form2: TForm2;
  HookAddress: dword;

  JumpBackAddressExt: dword;
  g_dbHwnd: dword;
  g_dbAddress: dword;
  g_baseaddr: Nativeuint;
  SQLiteExecCallback: TSQLiteExecCallback;
  g_globalDb: TDbObj;

implementation
{$R *.dfm}

uses
  Method1;

function outTableFields(UserData: Pointer; NumCols: integer; ColValues: PPCharArray; ColNames: PPCharArray): integer; cdecl
begin
  form2.memo1.Lines.Clear;
  var i: Integer;
  for i := 0 to NumCols - 1 do
    form2.memo1.Lines.Add(pansichar(ColValues[i]));

  result := 0;
end;

function outTables(UserData: Pointer; NumCols: integer; ColValues: PPCharArray; ColNames: PPCharArray): integer; cdecl
var
  ig: Integer;
begin

  for ig := 0 to NumCols - 1 do
  begin
    Form2.ListBox1.Items.Add(pansichar(ColValues[ig]));    //pansichar
  end;
  result := 0;
end;

function outTablesData(UserData: Pointer; NumCols: integer; ColValues: PPCharArray; ColNames: PPCharArray): integer; cdecl
var
  NewDest: PChar;
  info: string;
begin

  var i: Integer;
  for i := 0 to NumCols - 1 do
  begin

    GetMem(NewDest, 254);
    var qm_ := PansiChar(ColValues[i]);

    Utf8toUnicode(NewDest, qm_, 254);
    info := info + PansiChar(ColNames[i]) + ':' + WideCharToString(NewDest) + #13#10;

    freemem(NewDest);

  end;
  Form2.memo2.Lines.Add(info);
  Form2.memo2.Lines.Add('--------------------------------------------');
  result := 0;
end;

procedure OutData();
var
  db: TDbObj;
begin
  db := TDbObj.Create();
  db.DBHandler := g_dbHwnd;
  db.DBName := PChar(Pointer((@g_dbAddress)^)^);

  Form2.ComboBox1.AddItem(db.DBName, db);
  Form2.ComboBox1.ItemIndex := 0;
end;

procedure new_addr();
asm
        mov     esi, dword ptr ss:[ebp - $14];
        add     esp, $8
        pushad
        mov     g_dbHwnd, esi
        mov     g_dbAddress, edi
        call    OutData
        popad
        jmp     JumpBackAddressExt
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  sqlite3_execV: Sqlite3_exec;
  sql: AnsiString;
  errmsg: pchar;
begin
  if g_globalDb = nil then
    exit;
  Memo2.Lines.Clear;

  sql := trim(Edit1.Text);

  sqlite3_execV := pointer(g_baseaddr + $77F6C0);

  sqlite3_execV(g_globalDb.DBHandler, PansiChar(sql), outTablesData, nil, errmsg);

end;

procedure TForm2.ComboBox1Change(Sender: TObject);
var
  sqlite3_execV: Sqlite3_exec;
  errmsg: pchar;
  sql: AnsiString;
begin
  if ComboBox1.ItemIndex >= 0 then
  begin
    ListBox1.Clear;
    g_globalDb := TDbObj(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
    sql := 'SELECT tbl_name FROM sqlite_master WHERE type = ''table''';

    sqlite3_execV := pointer(g_baseaddr + $77F6C0);

    sqlite3_execV(g_globalDb.DBHandler, PansiChar(sql), outTables, nil, errmsg);

  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  g_baseaddr := GetModuleHandle('WeChatWin.dll');
  HookAddress := $430FA3;

  JumpBackAddressExt := g_baseaddr + HookAddress + 5 + 1;

  HookAddress := g_baseaddr + HookAddress;

  F1Ext(@new_addr, pointer(HookAddress));
end;

procedure TForm2.ListBox1DblClick(Sender: TObject);
var
  Sql: ansistring;
var
  sqlite3_execV: Sqlite3_exec;
  errmsg: pchar;
begin
  if g_globalDb = nil then
    exit;
  TThread.CreateAnonymousThread(
    procedure
    begin

      Sql := 'sELECT sql FROM sqlite_master WHERE type = ''table'' AND tbl_name = ''' + form2.listbox1.items[form2.listbox1.ItemIndex] + '''';

      sqlite3_execV := pointer(g_baseaddr + $77F6C0);

      sqlite3_execV(g_globalDb.DBHandler, PansiChar(Sql), outTableFields, nil, errmsg);

    end).Start;

  TThread.CreateAnonymousThread(
    procedure
    begin
      edit1.Text := 'select * from ' + form2.listbox1.items[form2.listbox1.ItemIndex] + ' limit 10';
      Button1Click(Self);
    end).Start;
end;

end.

