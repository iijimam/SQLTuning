Class Training.Employee Extends %Persistent
{

Property EmpID As %String [ SqlComputeCode = {	set {*}="EMP"_$TR($J({%%ID},4)," ","0")
}, SqlComputed, SqlComputeOnChange = %%INSERT ];

Property Name As %String;

Property Dept As %String;

Property Location As %String;

Property Tel As %String;

/// 取得資格
Property Capability As %Integer;

ForeignKey CapabilitiesFK(Capability) References Training.Capability();

Index CapabilityIdx On Capability;

Index EmpIDIdx On EmpID [ Unique ];

// Index LocationIdx On Location;

// Index NameIdx On Name;

// Index NameLocationIdx On (Name, Location);

ClassMethod DeleteAll()
{
	do ##class(Training.Capability).%KillExtent()
	do ..%KillExtent()
}

ClassMethod CreateData(cn As %Integer = 20)
{
	#dim ex As %Exception.AbstractException
	set st=$$$OK
	 Set namelist= $LB( 
 "相原","青木","秋山","浅野","天野","新井","荒井","荒木","安藤",
 "飯島","飯田","飯塚","五十嵐","池田","石井","石川","石塚","石原","石渡","市川","伊藤","伊東","井上","今井","岩崎","岩田","岩本",
 "上田","上野","上原","内田","内山",
 "榎本","遠藤",
 "大川","大久保","大島","太田","大谷","大塚","大野","大橋","大森","岡田","岡本","小川","小沢","小澤","落合","小野","小野寺",
 "加藤","金井","金子","川上","川口","川崎","川島","川村","菅野",
 "菊地","岸","北村","木下","木村",
 "工藤","久保","久保田","熊谷","栗原",
 "小池","小泉","河野","小島","小林","小松","小山","近藤","後藤",
 "斉藤","斎藤","齋藤","酒井","坂本","佐久間","桜井","佐々木","佐藤","佐野",
 "柴田","渋谷","島田","清水","志村","白井",
 "菅原","杉本","杉山","鈴木","須藤",
 "関","関口","瀬戸",
 "高木","高野","高橋","田口","竹内","田代","田中","田辺","谷口","田村",
 "千葉","土屋","角田",
 "内藤","中川","中島","中野","中村","中山","永井","成田",	
 "西村","西山",
 "根本",
 "野口","野村",
 "萩原","橋本","長谷川","服部","浜田","早川","林","原","原田","馬場",
 "樋口","平井","平田","平野","広瀬",
 "福島","福田","藤井","藤田","藤本","古川",
 "星野","本田","本間",
 "前田","増田","松井","松尾","松岡","松下","松田","松本","丸山",
 "三浦","水野","宮崎","宮田","宮本",
 "武藤","村上","村田",
 "望月","森","森田",
 "八木","安田","矢野","山内","山口","山崎","山下","山田","山中","山本",
 "横田","横山","吉川","吉田",
 "渡辺","渡部","和田") 

		Set JpPref(1)="三重県"
		Set JpPref(2)="京都府"
		Set JpPref(3)="佐賀県"
		Set JpPref(4)="兵庫県"
		Set JpPref(5)="北海道"
		Set JpPref(6)="千葉県"
		Set JpPref(7)="和歌山県"
		Set JpPref(8)="埼玉県"
		Set JpPref(9)="大分県"
		Set JpPref(10)="大阪府"
		Set JpPref(11)="奈良県"
		Set JpPref(12)="宮城県"
		Set JpPref(13)="宮崎県"
		Set JpPref(14)="富山県"
		Set JpPref(15)="山口県"
		Set JpPref(16)="山形県"
		Set JpPref(17)="山梨県"
		Set JpPref(18)="岐阜県"
		Set JpPref(19)="岡山県"
		Set JpPref(20)="岩手県"
		Set JpPref(21)="島根県"
		Set JpPref(22)="広島県"
		Set JpPref(23)="徳島県"
		Set JpPref(24)="愛媛県"
		Set JpPref(25)="愛知県"
		Set JpPref(26)="新潟県"
		Set JpPref(27)="東京都"
		Set JpPref(28)="栃木県"
		Set JpPref(29)="沖縄県"
		Set JpPref(30)="滋賀県"
		Set JpPref(31)="熊本県"
		Set JpPref(32)="石川県"
		Set JpPref(33)="神奈川県"
		Set JpPref(34)="福井県"
		Set JpPref(35)="福岡県"
		Set JpPref(36)="福島県"
		Set JpPref(37)="秋田県"
		Set JpPref(38)="群馬県"
		Set JpPref(39)="茨城県"
		Set JpPref(40)="長崎県"
		Set JpPref(41)="長野県"
		Set JpPref(42)="青森県"
		Set JpPref(43)="静岡県"
		Set JpPref(44)="香川県"
		Set JpPref(45)="高知県"
		Set JpPref(46)="鳥取県"
		Set JpPref(47)="鹿児島県"

		set dept=$LB("","営業部","カスタマーサポート部","教育部","マーケティング部","総務部","人事部","広報部")
		
	try {
		&sql(select Count(*) into :capcn from Training.Capability)
		if capcn=0 {
			do ##class(Training.Capability).Init()
			// 再度カウント
			&sql(select Count(*) into :capcn from Training.Capability)
		}

		for i=1:1:cn {
			// Capability
			set val(2)=$Random(capcn)+1

			// Dept
			set val(3)=$listGet(dept,$random($listlength(dept))+1)
			// Location
			set val(5)=JpPref($random(47)+1)
			// Name
			set val(6)=$list(namelist,$random($listlength(namelist))+1)
			// Tel
			if $Random(2)=1 { set val(7)=0_($Random(9)+1)_"-"_($Random(8999)+1000)_"-"_($Random(8999)+1000) }
			else {set val(7)=0_($Random(799)+200)_"-"_($Random(89)+10)_"-"_($Random(8999)+1000)}

			&sql(insert into Training.Employee values :val())
			if SQLCODE<0 {
				throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
			}
		}
	}
	catch ex {
		set st=ex.AsStatus()
		write $system.Status.GetErrorText(st)
	}
	quit st
}

Storage Default
{
<Data name="EmployeeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EmpID</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Dept</Value>
</Value>
<Value name="5">
<Value>Location</Value>
</Value>
<Value name="6">
<Value>Tel</Value>
</Value>
<Value name="7">
<Value>Capability</Value>
</Value>
</Data>
<DataLocation>^Training.EmployeeD</DataLocation>
<DefaultData>EmployeeDefaultData</DefaultData>
<IdLocation>^Training.EmployeeD</IdLocation>
<IndexLocation>^Training.EmployeeI</IndexLocation>
<StreamLocation>^Training.EmployeeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
