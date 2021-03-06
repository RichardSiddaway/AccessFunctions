Import-Module accessfunctions -Force
$db = Open-AccessDatabase -name test03.mdb -path c:\test

$table = "NewTable2"
New-AccessTable -table $table -connection $db

New-AccessColumn -connection $db -table $table -dtname Mydate
New-AccessColumn -connection $db -table $table -dtname Mydate2 -notnull 

New-AccessColumn -connection $db -table $table -uniquename MyUnique
New-AccessColumn -connection $db -table $table -uniquename MyUnique2 -notnull

New-AccessColumn -connection $db -table $table -binname MyBinary
New-AccessColumn -connection $db -table $table -bitname MyBit
New-AccessColumn -connection $db -table $table -binname MyBinary2 -notnull
New-AccessColumn -connection $db -table $table -bitname MyBit2 -notnull

New-AccessColumn -connection $db -table $table -tnyintname MyTiny
New-AccessColumn -connection $db -table $table -smlintname MySmall
New-AccessColumn -connection $db -table $table -intname MyInt

New-AccessColumn -connection $db -table $table -tnyintname MyTiny2 -notnull
New-AccessColumn -connection $db -table $table -smlintname MySmall2 -notnull
New-AccessColumn -connection $db -table $table -intname MyInt2 -notnull

New-AccessColumn -connection $db -table $table -dblname MyDouble
New-AccessColumn -connection $db -table $table -realname MyReal
New-AccessColumn -connection $db -table $table -floatname MyFloat
New-AccessColumn -connection $db -table $table -decname MyDecimal
New-AccessColumn -connection $db -table $table -mnyname MyMoney

New-AccessColumn -connection $db -table $table -dblname MyDouble2 -notnull
New-AccessColumn -connection $db -table $table -realname MyReal2 -notnull
New-AccessColumn -connection $db -table $table -floatname MyFloat2 -notnull
New-AccessColumn -connection $db -table $table -decname MyDecimal2 -notnull
New-AccessColumn -connection $db -table $table -mnyname MyMoney2 -notnull

New-AccessColumn -connection $db -table $table -charname MyChar
New-AccessColumn -connection $db -table $table -charname MyChar2 -size 20
New-AccessColumn -connection $db -table $table -charname MyChar3 -size 20 -notnull

New-AccessColumn -connection $db -table $table -textname MyText
New-AccessColumn -connection $db -table $table -textname MyText2 -size 20
New-AccessColumn -connection $db -table $table -textname MyText3 -size 20 -notnull

New-AccessColumn -connection $db -table $table -imgname MyImg 
New-AccessColumn -connection $db -table $table -imgname MyImg2  -notnull

Close-AccessDatabase $db