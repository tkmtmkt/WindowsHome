#
# モジュール 'SSH' のモジュール マニフェスト
#
# 生成者: TAKAMATSU Makoto
#
# 生成日: 2012/12/27
#

@{

# このマニフェストに関連付けられているスクリプト モジュール ファイルまたはバイナリ モジュール ファイル。
ModuleToProcess = ''

# このモジュールのバージョン番号です。
ModuleVersion = '1.0'

# このモジュールを一意に識別するために使用される ID
GUID = 'c2ada9f0-2855-45d7-b340-d1883bbd5e91'

# このモジュールの作成者
Author = 'TAKAMATSU Makoto'

# このモジュールの会社またはベンダー
CompanyName = 'MyHome'

# このモジュールの著作権情報
Copyright = '(c) 2012 takamatu. All rights reserved.'

# このモジュールの機能の説明
Description = ''

# このモジュールに必要な Windows PowerShell エンジンの最小バージョン
PowerShellVersion = ''

# このモジュールに必要な Windows PowerShell ホストの名前
PowerShellHostName = ''

# このモジュールに必要な Windows PowerShell ホストの最小バージョン
PowerShellHostVersion = ''

# このモジュールに必要な .NET Framework の最小バージョン
DotNetFrameworkVersion = ''

# このモジュールに必要な共通言語ランタイム (CLR) の最小バージョン
CLRVersion = ''

# このモジュールに必要なプロセッサ アーキテクチャ (なし、X86、Amd64)
ProcessorArchitecture = ''

# このモジュールをインポートする前にグローバル環境にインポートされている必要があるモジュール
RequiredModules = @()

# このモジュールをインポートする前に読み込まれている必要があるアセンブリ
RequiredAssemblies = @('Renci.SshNet.dll')

# このモジュールをインポートする前に呼び出し元の環境で実行されるスクリプト ファイル (.ps1)。
ScriptsToProcess = @()

# このモジュールをインポートするときに読み込まれる型ファイル (.ps1xml)
TypesToProcess = @()

# このモジュールをインポートするときに読み込まれる書式ファイル (.ps1xml)
FormatsToProcess = @()

# ModuleToProcess に指定されているモジュールの入れ子になったモジュールとしてインポートするモジュール
NestedModules = @('SSH.psm1')

# このモジュールからエクスポートする関数
FunctionsToExport = '*'

# このモジュールからエクスポートするコマンドレット
CmdletsToExport = '*'

# このモジュールからエクスポートする変数
VariablesToExport = '*'

# このモジュールからエクスポートするエイリアス
AliasesToExport = '*'

# このモジュールに同梱されているすべてのモジュールのリスト。
ModuleList = @()

# このモジュールに同梱されているすべてのファイルのリスト
FileList = @()

# ModuleToProcess に指定されているモジュールに渡すプライベート データ
PrivateData = ''

}

