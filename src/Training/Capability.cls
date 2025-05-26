Class Training.Capability Extends %Persistent
{

Property CapabilityName As %String;

Property Grade As %String;

ClassMethod Init()
{
	&sql(truncate table Training.Capability)
	&sql(insert into Training.Capability (CapabilityName,Grade) values('英検','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('英検','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('英検','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('英検','4級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('漢検','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('漢検','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('漢検','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('漢検','4級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('情報処理技術者能力認定試験','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('情報処理技術者能力認定試験','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Excel表計算処理技能認定試験','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Excel表計算処理技能認定試験','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Excel表計算処理技能認定試験','3級'))
	&sql(insert into Training.Capability (CapabilityName) values('Webクリエイター能力認定試験'))
	&sql(insert into Training.Capability (CapabilityName) values('ネットマーケティング検定'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('C言語プログラミング能力認定試験','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('C言語プログラミング能力認定試験','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('C言語プログラミング能力認定試験','3級'))
	&sql(insert into Training.Capability (CapabilityName) values('Word文書処理技能認定試験'))
	&sql(insert into Training.Capability (CapabilityName) values('Accessビジネスデータベース技能認定試験'))
	&sql(insert into Training.Capability (CapabilityName) values('PowerPointプレゼンテーション技能認定試験'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('ペン字検定','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('ペン字検定','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('ペン字検定','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('ペン字検定','4級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('コンピュータサービス技能評価試験','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('コンピュータサービス技能評価試験','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('コンピュータサービス技能評価試験','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Linux技術者認定試験 (LPIC)','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Linux技術者認定試験 (LPIC)','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('Linux技術者認定試験 (LPIC)','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('HTML5プロフェッショナル認定資格','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('HTML5プロフェッショナル認定資格','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('情報検定 (J検)','1級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('情報検定 (J検)','2級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('情報検定 (J検)','3級'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('シスコ技術者認定','エントリー'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('シスコ技術者認定','アソシエイト'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('シスコ技術者認定','プロフェッショナル'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('シスコ技術者認定','エキスパート'))
	&sql(insert into Training.Capability (CapabilityName,Grade) values('シスコ技術者認定','アーキテクト'))
}

Storage Default
{
<Data name="CapabilityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CapabilityName</Value>
</Value>
<Value name="3">
<Value>Grade</Value>
</Value>
</Data>
<DataLocation>^Training.CapabilityD</DataLocation>
<DefaultData>CapabilityDefaultData</DefaultData>
<IdLocation>^Training.CapabilityD</IdLocation>
<IndexLocation>^Training.CapabilityI</IndexLocation>
<StreamLocation>^Training.CapabilityS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
