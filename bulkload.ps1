Import-Module AccessFunctions
$db = Open-AccessDatabase -name test03.mdb -path c:\test
Import-Csv -Path c:\test\names.csv | foreach {
    $value = " ""$($_.FirstName)"", ""$($_.LastName)"", ""$($_.DOB)"" "
    $value
    Add-AccessRecord -connection $db -table test1 -values $value
}

Get-AccessData -sql "select * from test1" -connection $db -grid
Close-AccessDatabase $db
Remove-Module AccessFunctions