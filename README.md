# InterSystems SQL の使い方：インデックスとチューニング
※ [InterSystems SQL の使い方（2日間）](https://www.intersystems.com/jp/intersystems-sql/)トレーニングのコース資料に含まれる内容です。

説明資料：[Mod05_インデックスとチューニング.pdf](/Mod05_インデックスとチューニング.pdf)

## 説明で使用するテーブル定義

従業員が持つ資格情報を人事部が管理する事を目的として、資格情報を登録する [Training.Capability](/src/Training/Capability.cls) と従業員データである [Training.Employee](/src/Training/Employee.cls) を用意しデータ登録します。

以下の手順でコースに沿った内容をお試しいただけます。

- [IRISへの定義反映方法](#irisへの定義反映方法)
- [データ作成方法](#データ作成方法)
- [テキストに沿った確認内容](#テキストに沿った確認内容)
    - [P5：自動で収集される統計情報の確認](#p5自動で収集される統計情報の確認)
    - [P15～：インデックスデータの確認](#p15インデックスデータの確認)
    - [P31：選択性](#p31選択性)
    - [P39-アダプティブモードの設定確認](#p39アダプティブモードの設定確認)
    - [P43～凍結プラン](#p43凍結プラン)

### IRISへの定義反映方法

**定義保存前にワークスペース内 [settings.json](/.vscode/settings.json) の接続情報をご確認ください。**

[Training.Employee](/src/Training/Employee.cls) テーブルには [Training.Capability](/src/Training/Capability.cls) テーブルに対する外部キー制約を設定しているため、VSCode で定義を保存＋コンパイルする場合は、Training.Capability を先に保存し、その後 Training.Employee を保存してください。


### データ作成方法

定義があるネームスペースに接続し、Training.Employee クラスの CreateData() メソッドを実行します。

IRISにログイン後、以下実行します。

※ Training.Employee を 10000件作成予定のため、カレントプロセスに対するジャーナルの書き込みを無効化しています。

```
do DISABLE^%SYS.NOJRN
do ##class(Training.Employee).CreateData(10000)
```

SQLを利用してテーブルにデータが格納できたか確認します。

- ターミナルをSQLシェルに変更して確認する例

    ```
    USER>:sql
    SQL Command Line Shell
    ----------------------------------------------------

    The command prefix is currently set to: <<nothing>>.
    Enter <command>, 'q' to quit, '?' for help.
    [SQL]USER>>select count(*) from Training.Employee
    1.      select count(*) from Training.Employee

    | Aggregate_1 |
    | -- |
    | 10000 |

    1 Rows(s) Affected
    statement prepare time(s)/globals/cmds/disk: 0.1678s/326,405/2,682,016/0ms
            execute time(s)/globals/cmds/disk: 0.0007s/17/50,445/0ms
                                    query class: %sqlcq.USER.cls11
    ---------------------------------------------------------------------------
    ```
- 管理ポータルを利用する場合

    管理ポータル > SQL > 対象ネームスペースに切り替え > クエリ実行タブ
    
    例）http://ホスト名:ポート/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER


### テキストに沿った確認内容

#### P5：自動で収集される統計情報の確認

管理ポータルのSQLのクエリ実行タブに以下入力し、実行します。

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道'
```

Nameには存在しそうな名前を指定してください。

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```

実行前に「実行」ボタン右横にある「プラン表示」ボタンを利用することでプランを参照できます。


いくつかクエリを実行したら、[SQLステートメント]タブ、または、特定のテーブルに対する[テーブルのSQL文]メニューを参照します。


#### P15～：インデックスデータの確認

インデックス定義を追加し（コメントを外し）、インデックスデータを確認します。

##### [1] インデックスを追加します。

[Training.Employee](/src/Training/Employee.cls) の24行目、26行目の以下の行のコメントを外し、保存します。

> 28行目の定義は後でコメントを外しますので、現時点ではまだコメントを外さないでください。

対象のインデック定義は以下の通りです。

```
Index LocationIdx On Location;

Index NameIdx On Name;
```


##### [2] クエリを実行します。

管理ポータルのSQL画面で事前に実行してあった以下のSELECT文を再度実行します。

前回実行したクエリ（[P5：自動で収集される統計情報の確認](#p5自動で収集される統計情報の確認)）と同じクエリを実行します。

**条件値も含めて同じクエリを実行してください。**

ヒント：管理ポータルのクエリ実行タブの「履歴を表示」ボタンを使用すると簡単です。

例1）
```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道'
```

例2）Nameの値は、実環境の値に変更して実行してください。

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```

検索結果はどうなりましたか？

> 0件の表示になっていると思います。それは何故でしょうか。

##### [3] インデックスデータの有無を確認します。

インデックス定義で指定したインデックス名のサブスクリププトが作成されているか、管理ポータル > グローバル 画面で確認します。

サンプル定義では、^Training.EmployeeI　にインデックスデータが格納されます。

例）
- ^Training.EmployeeI("LocationIdx")
- ^Training.EmployeeI("NameIdx")
    
インデックスデータ、できていたでしょうか？

##### [4] インデックスの再構築

管理ポータルのSQLメニューを利用して、作成したインデックスを再構築します。

**画面左でテーブル名をクリック >　画面右：マップ／インデックスをクリック > 対象のインデックスの「インデックス再構築」をクリック**

ターミナルで実行する場合は、以下メソッドの引数にインデックス名を$LB()で指定します。

例：$LB("インデックス名称","インデックス名称2",・・)

```
do ##class(Training.Employee).%BuildIndices($LB("LocationIdx","NameIdx"))
```

##### [5] クエリ実行＋プラン確認

再度 [**[2 クエリを実行します](#2-クエリを実行します)**] で実行したクエリを実行します。

プランがインデックスを使用するプランに変わっていることを確認します。


#### P31：選択性

管理ポータルで選択性数値を確認する方法

- フィールド表示を利用する。

    左画面でテーブルを選択 > 右画面：「カタログの詳細」 > フィールドをクリック

    計算されている場合、「選択性」の列に数値が表示されます。

- 選択性の計算

    管理ポータルのSQLメニューの以下画面を利用します。

    左画面でテーブルを選択し、アクション > テーブルチューニング情報　をクリック

    または、ターミナルで以下実行します。

    ```
    do $SYSTEM.SQL.Stats.Table.GatherTableStats("Training.Employee")
    ```

#### P39：アダプティブモードの設定確認

管理ポータル > システム管理 > 構成 > SQLとオブジェクトの設定 > SQL

「アダプティブモードをオフにして実行時間計画の選択、自動チューニング、クエリ計画の凍結/アップグレードを無効化」　にチェックが入っているかいないかを確認します。

メモ：

- 新規インストールの場合、有効化されています（チェックされていません）。
- アップグレードした環境の場合、アップグレード前バージョンの設定を引き継ぎます。
- 2021.1以前のバージョンから2023.1以降にアップグレードしている場合は、無効化に設定されます（チェックされています）。


#### P43～凍結プラン

##### [1] 凍結を試す

現在の以下クエリに対するプランを凍結します。

**※例文のNameに指定した条件は環境により異なります。クエリプランが作成されたときと同じ文字列を使用してください。**

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```
管理ポータルのSQLメニューで、左画面でTraining.Employeeを選択、右画面でカタログの詳細：「テーブルのSQL文」を選択し、対象のSQLをクリックします。（[SQL文の詳細]画面を開きます）

「プランを凍結」ボタンをクリックします。

##### [2] エクスポートを試す。

プランの凍結解除を行っても昔のプランが利用できるように、現在表示しているプランを「エクスポート」します。

##### [3] 新しいインデックス定義を追加する。

[Training.Employee](/src/Training/Employee.cls) の28行目の以下の行のコメントを外し、保存します。

```
Index NameLocationIdx On (Name, Location);
```

##### [4] 新しいインデックスを再構築します。

管理ポータル、またはターミナルから再構築を実行します。

```
do ##class(Training.Employee).%BuildIndices($LB("NameLocationIdx"))
```

##### [5] 同じクエリの「SQL文の詳細」を開きなおします。

「凍結プランが異なる」が「はい」の場合、新しいプランを試してみます。

新しいプランが「Read index map Training.Employee.NameLocationIdx」を利用するプランになっている場合は、クエリ実行画面で、[**[1 凍結を試す](#1-凍結を試す)**] で確認したクエリに **%NOFPLAN** を追加し実行します。

```
SELECT %NOFPLAN ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```

##### [6] 新プランがあるかどうかSQLで確認します。

以下SQLを実行し、FrozenDifferent に 1 が設定されているか確認します。

```
SELECT Frozen,FrozenDifferent,Timestamp,Statement
FROM INFORMATION_SCHEMA.STATEMENTS 
WHERE Frozen=1 OR Frozen=2
```

##### [7] 新しいプランに変更するため「プランを凍結解除」します。

SQL文の詳細画面で「プランを凍結解除」ボタンをクリックします。

クエリ実行画面で %NOFPLAN を消した以下のSELECT文のプランを確認します
(実行しないで「プラン表示」ボタンだけでも確認できます) 。

([[5](#5-同じクエリのsql文の詳細を開きなおします)]で確認したクエリから%NOFPLANを消します)

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```    

ここまでの流れで新しいプランに変わったことを確認できたら、前回のプランに変更するため、エクスポートファイルをインポートします。

##### [8] オプション：前回のプランに戻す

**アクション > ステートメントをインポート**　のメニューから、[[2](#2-エクスポートを試す)]でエクスポートしたファイルをインポートし、元のプランに戻るかテストします。

**NameLocationIdx の利用から、NameIdxとLocationLdxの利用に戻れば成功です。**