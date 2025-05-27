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
    - [P62～ インデックス再構築手順を確認](#p62-インデックス再構築手順を確認)

## IRISへの定義反映方法

**定義保存前にワークスペース内 [settings.json](/.vscode/settings.json) の接続情報をご確認ください。**

[Training.Employee](/src/Training/Employee.cls) テーブルには [Training.Capability](/src/Training/Capability.cls) テーブルに対する外部キー制約を設定しているため、VSCode で定義を保存＋コンパイルする場合は、Training.Capability を先に保存し、その後 Training.Employee を保存してください。


## データ作成方法

定義があるネームスペースに接続し、Training.Employee クラスの CreateData() メソッドを実行します。

IRISにログイン後、以下実行します。

※ Training.Employee を 10000件作成予定のため、カレントプロセスに対するジャーナルの書き込みを無効化しています。

```
do DISABLE^%SYS.NOJRN
do ##class(Training.Employee).CreateData(10000)
```

SQLを利用してテーブルにデータが格納できたか確認します。

```
select count(*) from Training.Employee
```
- ターミナルをSQLシェルに変更して確認する例

    IRISターミナルに戻る時は、Quitを入力してください。

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
    [SQL]USER>>quit

    USER>
    ```
- 管理ポータルを利用する場合

    管理ポータル > SQL > 対象ネームスペースに切り替え > クエリ実行タブ
    
    例）http://ホスト名:ポート/csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER


## テキストに沿った確認内容

### P5：自動で収集される統計情報の確認

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

次に、[SQLステートメント]タブ、または、特定のテーブルに対する[テーブルのSQL文]メニューを参照します。

[ステートメント]列に記載されているSQL文を確認し、先ほど実行したSQL文のリンクをクリックし「SQL文の詳細」画面を開きます。

ステートメント例）
```
DECLARE QRS CURSOR FOR SELECT ID , DEPT , EMPID , LOCATION , NAME , TEL FROM TRAINING . EMPLOYEE WHERE LOCATION = ? AND NAME = ? /*#OPTIONS {"DynamicSQLTypeList":"1,1"} */
```
```
DECLARE QRS CURSOR FOR SELECT ID , DEPT , EMPID , LOCATION , NAME , TEL FROM TRAINING . EMPLOYEE WHERE LOCATION = ? /*#OPTIONS {"DynamicSQLTypeList":1} */
```

画面の内容を確認したら「閉じる」ボタンをクリックします。

現時点では、クエリに合うインデックス定義がないため
```
 Read master map Training.Employee.IDKEY, looping on ID.
```
から始まるプランが作成されていることが確認できます（レコード全件ループしながら結果を表示しています）。

### P15～：インデックスデータの確認

インデックス定義を追加し（コメントを外し）、インデックスデータを確認します。

#### [1] インデックスを追加します。

[Training.Employee](/src/Training/Employee.cls) の24行目、26行目の以下の行のコメントを外し、保存します。

> 28行目の定義は後でコメントを外しますので、現時点ではまだコメントを外さないでください。

対象のインデック定義は以下の通りです。

```
Index LocationIdx On Location;

Index NameIdx On Name;
```


#### [2] クエリを実行します。

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

#### [3] インデックスデータの有無を確認します。

インデックス定義で指定したインデックス名のサブスクリププトが作成されているか、管理ポータル > グローバル 画面で確認します。

サンプル定義では、^Training.EmployeeI　にインデックスデータが格納されます。

例）
- ^Training.EmployeeI("LocationIdx")
- ^Training.EmployeeI("NameIdx")
    
上記インデックスデータ、できていたでしょうか？

#### [4] インデックスの再構築

管理ポータルのSQLメニューを利用して、作成したインデックスを再構築します。

**画面左でテーブル名をクリック >　画面右：「カタログの詳細」タブを選択 > マップ／インデックスをクリック > 対象のインデックスの「インデックス再構築」をクリック**

ターミナルで実行する場合は、以下メソッドの引数にインデックス名を$LB()で指定します。

例：$LB("インデックス名称","インデックス名称2",・・)

```
do ##class(Training.Employee).%BuildIndices($LB("LocationIdx","NameIdx"))
```
インデックス再構築後、インデックス用グローバル変数が作成されていることを管理ポータルのグローバルメニューを利用して確認してください。

#### [5] クエリ実行＋プラン確認

再度 [**[2 クエリを実行します](#2-クエリを実行します)**] で実行したクエリを実行します。

クエリプランを参照し、インデックスを使用するプランに変わっていることを確認します。

例）WHERE Location='北海道 のクエリに対するプラン例は以下の通りです（Read index map Training.Employee.LocationIdxから始まるプランに変わっています）。
```
• Read index map Training.Employee.LocationIdx, using the given %SQLUPPER(Location), and looping on ID.
• For each row:
    - Read master map Training.Employee.IDKEY, using the given idkey value.
    - Output the row.
```

WHERE Location='北海道' AND Name='xxx' のプラン例は以下の通りです（2つのインデックスが利用されていることを確認できます）。
```
• Generate a stream of idkey values using the multi-index combination:
    ((index map Training.Employee.NameIdx) INTERSECT (index map Training.Employee.LocationIdx))
• For each idkey value:
    - Read master map Training.Employee.IDKEY, using the given idkey value.
    - Output the row.
```

### P31：選択性

現時点での選択性数値についての確認します。管理ポータルで選択整数値を確認しながら回答してください。

- Training.Employeeテーブルは、選択整数値が設定されていると思いますが、それは何故でしょうか。

- Training.Capabilityテーブルは、選択性数値が未設定になっていると思いますが、それは何故でしょうか。

> **ヒント：** バージョン2022.1以降、一度も実行したことがないテーブルに対して最初のクエリを実行する際、自動実行されます（テキストP32に記載があります）。Training.Employeeについては、データ作成後にデータ件数を確認するクエリを1度発行しています。



管理ポータルで選択性数値を確認する方法は以下の通りです。

- フィールド表示を利用する。

    左画面でテーブルを選択 > 右画面：「カタログの詳細」 > フィールドをクリック

    計算されている場合、「選択性」の列に数値が表示されます。

- 選択性の計算も一緒に行う場合

    管理ポータルのSQLメニューの以下画面を利用します。

    左画面でテーブルを選択し、アクション > テーブルチューニング情報　をクリック

    または、ターミナルで以下実行します。

    ```
    do $SYSTEM.SQL.Stats.Table.GatherTableStats("Training.Employee")
    ```


### P39：アダプティブモードの設定確認

**※この設定は2023.1以降のバージョンで追加されました。2023.1未満のバージョンをお使いの場合は設定確認をスキップしてください。**

管理ポータル > システム管理 > 構成 > SQLとオブジェクトの設定 > SQL

「アダプティブモードをオフにして実行時間計画の選択、自動チューニング、クエリ計画の凍結/アップグレードを無効化」　にチェックが入っているかいないかを確認します。

メモ：

- 新規インストールの場合、有効化されています（チェックされていません）。
- アップグレードした環境の場合、アップグレード前バージョンの設定を引き継ぎます。
- 2021.1以前のバージョンから2023.1以降にアップグレードしている場合は、無効化に設定されます（チェックされています）。


### P43～凍結プラン

#### [1] 凍結を試す

現在の以下クエリに対するプランを凍結します。

**※例文のNameに指定した条件は環境により異なります。演習の流れで実行したクエリをご利用ください。**

例）
```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```

管理ポータルのSQLメニューで、左画面でTraining.Employeeを選択、右画面でカタログの詳細：「テーブルのSQL文」を選択し、対象のSQLをクリックします。（[SQL文の詳細]画面を開きます）

ステートメント例）
```
DECLARE QRS CURSOR FOR SELECT ID , DEPT , EMPID , LOCATION , NAME , TEL FROM TRAINING . EMPLOYEE WHERE LOCATION = ? AND NAME = ? /*#OPTIONS {"DynamicSQLTypeList":"1,1"} */
```

「プランを凍結」ボタンをクリックします。

#### [2] エクスポートを試す。

プランの凍結解除を行っても昔のプランが利用できるように、現在表示しているプランを「エクスポート」します。

エクスポートが完了したら「閉じる」ボタンで画面を一旦閉じます。

#### [3] 新しいインデックス定義を追加する。

[Training.Employee](/src/Training/Employee.cls) の28行目の以下の行のコメントを外し、保存します。

```
Index NameLocationIdx On (Name, Location);
```

#### [4] 新しいインデックスを再構築します。

管理ポータル、またはターミナルから再構築を実行します。

```
do ##class(Training.Employee).%BuildIndices($LB("NameLocationIdx"))
```

#### [5] 同じクエリの「SQL文の詳細」を開きなおします。

「凍結プランが異なる」が「はい」の場合、新しいプランを試してみます。

新しいプランが「Read index map Training.Employee.NameLocationIdx」を利用するプランになっている場合は、クエリ実行画面で、[**[1 凍結を試す](#1-凍結を試す)**] で確認したクエリに **%NOFPLAN** を追加し実行します。

例）
```
SELECT %NOFPLAN ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道' AND Name ='高木'
```

`Read index map Training.Employee.NameLocationIdx` から始まる新しいプランに変わったことを確認します。

#### [6] 新プランがあるかどうかSQLで確認します。

以下SQLを実行し、FrozenDifferent に 1 が設定されているか確認します。

```
SELECT Frozen,FrozenDifferent,Timestamp,Statement
FROM INFORMATION_SCHEMA.STATEMENTS 
WHERE Frozen=1 OR Frozen=2
```

#### [7] 新しいプランに変更するため「プランを凍結解除」します。

管理ポータルのSQLメニューで、左画面でTraining.Employeeを選択、右画面でカタログの詳細：「テーブルのSQL文」を選択し、対象のSQLをクリックします。（[SQL文の詳細]画面を開きます）

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

#### [8] オプション：前回のプランに戻します。

**アクション > ステートメントをインポート**　のメニューから、[[2](#2-エクスポートを試す)]でエクスポートしたファイルをインポートし、元のプランに戻るかテストします。

再度、同じSQL文のプラン表示を行い、**NameLocationIdx の利用から、NameIdxとLocationLdxの利用に戻れば成功です。**


### P62～ インデックス再構築手順を確認

バージョン別で確認方法を記載します。ご利用中環境のバージョンに合わせてご利用ください。

ここまでの演習の流れで、インデックス：LocationIdx が作成済の状態です。

以下の流れでは、インデックスがない状態からインデックス追加～インデックス再構築の流れを確認いただきたいので、一旦、LocationIdx のインデックスデータと定義を削除してから試します。

#### [1] LocationIdxのインデックデータを削除

%PurgeIndices($LB("インデックス名")) を使用します。戻り値：%Statusを変数に設定し、実行後にエラーがないかどうかも確認してください。

実行例)
```
USER>set status=##class(Training.Employee).%PurgeIndices($LB("LocationIdx"))

USER>write status
1
USER>zwrite ^Training.EmployeeI("LocationIdx")

USER>
```
※グローバル変数の確認は管理ポータルのグローバルメニューでも確認できます（その他のインデックス対して作成したデータが残っていることも確認できます）。

> もしメソッドの実行結果が1以外の場合は、`do $system.OBJ.DisplayError(ステータスをセットした変数)` の出力内容もご確認ください。

#### [2] インデックス定義削除

[Training.Employee](/src/Training/Employee.cls) の24行目のインデックス定義にコメントを付け保存します。

例）
```
// Index LocationIdx On Location;
```

#### [3] クエリ実行とプランの確認

以下のSQL文を実行し、検索結果が返ることを確認します。

```
SELECT ID, Dept, EmpID, Location, Name, Tel
FROM Training.Employee
where Location='北海道'
```
次にクエリプランを参照し`• Read master map Training.Employee.IDKEY, looping on ID.` からはじまるプランに変わったことを確認します。
（インデックス未使用のプランに変わったことを確認します）

---

以上で事前準備は完了です。

次の操作は、バージョンごとに異なります。ご利用中バージョンに合わせて演習をお試しください。

- [2024.1以降](#20241以降)
- [2022.1～2023.1までの方法](#2022120231までの方法)

#### 2024.1以降

※テキストP64～66の内容です。

1) クラス定義に対してDDL文を実行できるようにClass定義文「DdlAllowed」を追加します。

    例）
    ```
    Class Training.Employee Extends %Persistent [ DdlAllowed ]
    ```
2) インデックス定義を追加

    管理ポータル、またはSQLシェルを利用して、以下の CREATE INDEX 文を実行します。

    ```
    CREATE INDEX LocationIdx On Training.Employee (Location) DEFER
    ```

    管理ポータルのSQL画面で、左画面：Training.Employeeを選択 > 右画面：カタログの詳細を選択 > マップ/インデックス をチェックします。

    「ステータス」列を確認すると、追加した LocationIdx は「選択不可能」と表示されています。（このインデックスはオプティマイザに使用されません）


3) この時点で検索を実行します。まだインデック用プランに変わってないことを確認します。

    ```
    SELECT ID, Dept, EmpID, Location, Name, Tel
    FROM Training.Employee
    where Location='北海道'
    ```

4) インデックス再構築を行います。

    管理ポータル、またはSQLシェルを利用して、以下の BUILD INDEX 文を実行します。

    ```
    BUILD INDEX FOR TABLE Training.Employee INDEX LocationIdx 
    ```

5) クエリを再実行＋プラン確認

    BUILD INDEX の実行が完了したら、再度同じクエリを実行しプランを確認します。

    （LocationIdxを使用するプランに変わったことを確認します。）

    管理ポータルを再表示し、管理ポータルのSQL画面の左画面：Training.Employeeを選択 > 右画面：カタログの詳細を選択 > マップ/インデックス をチェックします。

    「ステータス」列を確認し、追加した LocationIdx が「選択可能」に変わっていることを確認します。
    
#### 2022.1～2023.1までの方法

※テキストP67の内容です。

1) 作成予定のインデックス名をオプティマイザに使用させないよう設定します。

    ターミナルで以下実行します。

    引数はこれから定義予定のインデックス名で大文字小文字を区別します。

    第3引数はオプティマイザに使用させないように 0 を指定します。

    戻り値は %Status で戻ります。
    ```
    write $system.SQL.Util.SetMapSelectability("Training.Employee","LocationIdx",0)
    ```

    1が戻れば正しく設定できています。

2) インデックス定義します。

    [Training.Employee](/src/Training/Employee.cls) の24行目のインデックス定義にコメントを外し保存します。

    例）
    ```
    Index LocationIdx On Location;
    ```

3) この時点で検索を実行します。まだインデック用プランに変わってないことを確認します。

    ```
    SELECT ID, Dept, EmpID, Location, Name, Tel
    FROM Training.Employee
    where Location='北海道'
    ```

    管理ポータルのSQL画面で、左画面：Training.Employeeを選択 > 右画面：カタログの詳細を選択 > マップ/インデックス をチェックします。

    「マップ選択可能？」列を確認すると、追加した LocationIdx は「いいえ」と表示されています。（このインデックスはオプティマイザに使用されません）

4) インデックスを再構築します。
    
    管理ポータル、またはターミナルから再構築を実行します。

    ```
    do ##class(Training.Employee).%BuildIndices($LB("LocationIdx"))
    ```

5) オプティマイザにインデックスを公開します。

    追加したインデックス（LocationIdx）をオプティマイザに公開します。

    第 3 引数は 1 を指定します。
    ```
    write $system.SQL.Util.SetMapSelectability("Training.Employee","LocationIdx",1)
    ```

    1 が戻れば正しく設定できています。


6) クエリを再実行＋プラン確認

    インデックス再構築が完了したら、クエリキャッシュを削除し、再度同じクエリを実行しプランを確認します。

    クエリキャッシュの削除例：
    管理ポータルのSQLメニュー > アクション > クエリキャッシュ削除 > このネームスペースの全てのクエリを削除　で行います。

    （LocationIdxを使用するプランに変わったことを確認します。）

    管理ポータルを再表示し、管理ポータルのSQL画面の左画面：Training.Employeeを選択 > 右画面：カタログの詳細を選択 > マップ/インデックス をチェックします。

    「マップ選択可能？」列を確認し、追加した LocationIdx が「はい」に変わっていることを確認します（＝オプティマイザが利用できるインデックスに変わりました）。


以上で演習終了です。

お疲れ様でした！