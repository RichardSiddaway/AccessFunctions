#Requires -version 2.0
##
##  Author Richard Siddaway
##    Version 0.2 
##        Added Reset-Autonum function
##        Added Autonum option to Add-AccessColumn
##        Added fields parameter to Add-AccessRecord
##        Added external Help file  
##        Added New-AccessIndex, Remove-AccessIndex functions  
##        Added Get-AccessTableDefinition
##        Added New-StoredProcedure 
##        Added Invoke-AccessStoredProcedure  
##
##    Version 0.1 - Inital Release  December 2009
##
## Connection functions
##
function Open-AccessDatabase {
param (
    [string]$name,
    [string]$path
)     
    $file = Join-Path -Path $path -ChildPath $name 
    if (!(Test-Path $file)){Throw "File Does Not Exists"}

    $connection = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0; Data Source=$file")
    $connection.Open()
    $connection
}

function Close-AccessDatabase {
param (
    [System.Data.OleDb.OleDbConnection]$connection
)
    $connection.Close()    
}

function Test-AccessConnection {
param (
    [System.Data.OleDb.OleDbConnection]$connection
)   
    if ($connection.State -eq "Open"){$open = $true}
    else {$open = $false}
    $open    
}
##
## data definition functions
##
function New-AccessDatabase {
param (
    [string]$name,
    [string]$path,
    [switch]$acc3
)    

    if (!(Test-Path $path)){Throw "Invaild Folder"}
    $file = Join-Path -Path $path -ChildPath $name 
    if (Test-Path $file){Throw "File Already Exists"}
    
    $cat = New-Object -ComObject 'ADOX.Catalog'
    
    if ($acc3) {$cat.Create("Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$file")}
    else {$cat.Create("Provider=Microsoft.ACE.OLEDB.12.0; Data Source=$file")}

    $cat.ActiveConnection.Close()
}
##
## Tables
##
$datatype = DATA {
ConvertFrom-StringData -StringData @'
3 = Integer
7 = Date
130 = String
'@
}
function Get-AccessTableDefinition {
param (
    [string]$name,
    [string]$path,
    [string]$table = ""
)
    $file = Join-Path -Path $path -ChildPath $name 
    if (!(Test-Path $file)){Throw "File Does Not Exists"}

    $conn = New-Object -ComObject ADODB.Connection
    $conn.Open("Provider = Microsoft.JET.OLEDB.4.0; Data Source = $file")
    $cat = New-Object -ComObject ADOX.Catalog
    $cat.ActiveConnection = $conn

## view tables 
##  note user tables are of type TABLE
    if ($table) {
        $actable = $cat.Tables | where {$_.Name -eq $table}
        $actable.Columns | Format-Table Name, DefinedSize, 
        @{Name="Data Type"; Expression={$datatype["$($_.Type)"]}}  -AutoSize
    }
    else {$cat.tables | select Name, DateCreated, DateModified}
        
    $conn.Close()
}
function New-AccessTable {
## assumes database is open
## add code to check if table exists
param (
    [string]$table,
    [System.Data.OleDb.OleDbConnection]$connection
)
    $sql = " CREATE TABLE $table"
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()
}

function Remove-AccessTable {
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$table,
    [System.Data.OleDb.OleDbConnection]$connection
)
    $sql = "DROP TABLE $table "
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    
    if ($psCmdlet.ShouldProcess("$($connection.DataSource)", "$sql")){$cmd.ExecuteNonQuery()}
}

##
## Columns
##
function New-AccessColumn {
[CmdletBinding()]
param (
    [System.Data.OleDb.OleDbConnection]$connection,
    [string]$table,
    [switch]$notnull,

    [parameter(ParameterSetName="datetime")]  
    [string]$dtname,

    [parameter(ParameterSetName="unique")]  
    [string]$uniquename,

    [parameter(ParameterSetName="binary")]  
    [string]$binname,

    [parameter(ParameterSetName="bit")]  
    [string]$bitname,

    [parameter(ParameterSetName="tinyinteger")]  
    [string]$tnyintname,

    [parameter(ParameterSetName="smallinteger")]  
    [string]$smlintname,
   
    [parameter(ParameterSetName="integer")]  
    [string]$intname,

    [parameter(ParameterSetName="double")]   
    [string]$dblname,

    [parameter(ParameterSetName="real")]  
    [string]$realname,

    [parameter(ParameterSetName="float")]  
    [string]$floatname,
    
    [parameter(ParameterSetName="decimal")]  
    [string]$decname,
    
    [parameter(ParameterSetName="money")]  
    [string]$mnyname,
	
	[parameter(ParameterSetName="autonum")]  
    [string]$autoname,
    
    [parameter(ParameterSetName="char")]  
    [string]$charname,
    
    [parameter(ParameterSetName="text")]  
    [string]$textname,

    [parameter(ParameterSetName="image")]  
    [string]$imgname,
    
    [parameter(ParameterSetName="char")]
    [parameter(ParameterSetName="text")] 
    [int]$size = 10
)    
    switch ($psCmdlet.ParameterSetName){
        datetime     {$sql = "ALTER TABLE $table ADD COLUMN $dtname DATETIME" } 

        autonum		 {$sql = "ALTER TABLE $table ADD COLUMN $autoname COUNTER(1,1)"}
		
		binary       {$sql = "ALTER TABLE $table ADD COLUMN $binname BINARY" } 
        bit          {$sql = "ALTER TABLE $table ADD COLUMN $bitname BIT" } 
        
        unique       {$sql = "ALTER TABLE $table ADD COLUMN $uniquename UNIQUEIDENTIFIER" } 

        tinyinteger  {$sql = "ALTER TABLE $table ADD COLUMN $tnyintname TINYINT" } 
        smallinteger {$sql = "ALTER TABLE $table ADD COLUMN $smlintname SMALLINT" } 
        integer      {$sql = "ALTER TABLE $table ADD COLUMN $intname INTEGER" } 

        double       {$sql = "ALTER TABLE $table ADD COLUMN $dblname DOUBLE" } 
        float        {$sql = "ALTER TABLE $table ADD COLUMN $floatname FLOAT" } 
        real         {$sql = "ALTER TABLE $table ADD COLUMN $realname REAL" } 
        decimal      {$sql = "ALTER TABLE $table ADD COLUMN $decname DECIMAL" } 
        money        {$sql = "ALTER TABLE $table ADD COLUMN $mnyname MONEY" } 
        
        char         {$sql = "ALTER TABLE $table ADD COLUMN $charname CHARACTER($size)" }
        text         {$sql = "ALTER TABLE $table ADD COLUMN $textname TEXT($size)" }
        image        {$sql = "ALTER TABLE $table ADD COLUMN $imgname IMAGE" }                 
                
    }
    if ($notnull) {$sql = $sql + " NOT NULL"}
    
    Write-Debug $sql
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()
}

function Remove-AccessColumn {
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$table,
    [string]$column,
    [System.Data.OleDb.OleDbConnection]$connection
)
    $sql = "ALTER TABLE $table DROP COLUMN $column"
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    
    if ($psCmdlet.ShouldProcess("$($connection.DataSource)", "$sql")){$cmd.ExecuteNonQuery()}
}

##
##  Data manipulation functions
##
function Add-AccessRecord {
#  .ExternalHelp   Maml-AccessFunctions.XML  
[CmdletBinding()]
param (
    [parameter(ParameterSetName="sql")]
    [string]$sql,
    
    [System.Data.OleDb.OleDbConnection]$connection,
    
    [parameter(ParameterSetName="field")]
    [parameter(ParameterSetName="value")]
    [string]$table,

    [parameter(ParameterSetName="field")]
    [string]$fields,
    
    [parameter(ParameterSetName="field")]
    [parameter(ParameterSetName="value")]
    [string]$values       
)

    switch ($psCmdlet.ParameterSetName){
        value    {$sql = "INSERT INTO $table VALUES ($values)" } 
        field    {$sql = "INSERT INTO $table ($fields) VALUES ($values)" } 
    }
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()
}

function Get-AccessData {
param (
    [string]$sql,
    [System.Data.OleDb.OleDbConnection]$connection,
    [switch]$grid
)
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $reader = $cmd.ExecuteReader()
    
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    if ($grid) {$dt | Out-GridView -Title "$sql" }
    else {$dt}

}

function Remove-AccessData {
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$table,
    [string]$filter,
    [System.Data.OleDb.OleDbConnection]$connection
)
    $sql = "DELETE FROM $table WHERE $filter"
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    
    if ($psCmdlet.ShouldProcess("$($connection.DataSource)", "$sql")){$cmd.ExecuteNonQuery()}
}

function Set-AccessData {
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$table,
    [string]$filter,
    [string]$value,
    [System.Data.OleDb.OleDbConnection]$connection
)
    $sql = "UPDATE $table SET $value WHERE $filter"
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    
    if ($psCmdlet.ShouldProcess("$($connection.DataSource)", "$sql")){$cmd.ExecuteNonQuery()}
}
## reset the Autonumber function to a different 
##  start value
function Reset-Autonum {
[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$table,
    [string]$column,
	[int]$newstart,
    [System.Data.OleDb.OleDbConnection]$connection
)
	$sql = "INSERT INTO $table ($column) VALUES ($newstart)"
	$cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
	if ($psCmdlet.ShouldProcess("$($connection.DataSource)", "$sql")){$cmd.ExecuteNonQuery()}
}
##
## Index functions
##
function New-AccessIndex {
#  .ExternalHelp   Maml-AccessFunctions.XML
[CmdletBinding()]
param (
    [string]$table,
    [string]$index,
    [string]$field,
    [System.Data.OleDb.OleDbConnection]$connection,
    [switch]$unique,
    [switch]$descend
)
    if ($unique) {$sql = " CREATE UNIQUE INDEX $index ON $table"}
    else {$sql = " CREATE INDEX $index ON $table"}
    
    if ($descend){$sql += " ($field DESC)"}
    else {$sql += " ($field)"}
    
    Write-Debug $sql
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()
}
function Remove-AccessIndex {
#  .ExternalHelp   Maml-AccessFunctions.XML
[CmdletBinding()]
param (
    [string]$table,
    [string]$index,
    [System.Data.OleDb.OleDbConnection]$connection
)

    $sql = "DROP INDEX $index ON $table"
    Write-Debug $sql
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()
}
##
## Stored procedure functions
##
function Get-AccessStoredProcedure {
param (
    [string]$name,
    [string]$path,
    [string]$proc = ""
)
    $file = Join-Path -Path $path -ChildPath $name 
    if (!(Test-Path $file)){Throw "File Does Not Exists"}

    $conn = New-Object -ComObject ADODB.Connection
    $conn.Open("Provider = Microsoft.JET.OLEDB.4.0; Data Source = $file")
    $cat = New-Object -ComObject ADOX.Catalog
    $cat.ActiveConnection = $conn

## view procedures
<#
    if ($table) {
        $actable = $cat.Tables | where {$_.Name -eq $table}
        $actable.Columns | Format-Table Name, DefinedSize, 
        @{Name="Data Type"; Expression={$datatype["$($_.Type)"]}}  -AutoSize
    }
    else {$cat.tables | select Name, DateCreated, DateModified}
#>

        
    $conn.Close()
}
function New-AccessStoredProcedure {
#  .ExternalHelp   Maml-AccessFunctions.XML
[CmdletBinding()]
param (
    [System.Data.OleDb.OleDbConnection]$connection,
    [string]$name,
    [string]$proc
)
    $sql = "CREATE PROCEDURE $name AS $proc"
    Write-Debug $sql
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()    
}
function Invoke-AccessStoredProcedure {
#  .ExternalHelp   Maml-AccessFunctions.XML
[CmdletBinding()]
param (
    [System.Data.OleDb.OleDbConnection]$connection,
    [string]$name,
    [switch]$grid
)
    $sql = "EXECUTE $name "
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $reader = $cmd.ExecuteReader()
    
    $dt = New-Object System.Data.DataTable
    $dt.Load($reader)
    
    if ($grid) {$dt | Out-GridView -Title "$sql" }
    else {$dt}
}
function Remove-AccessStoredProcedure {
#  .ExternalHelp   Maml-AccessFunctions.XML
[CmdletBinding()]
param (
    [System.Data.OleDb.OleDbConnection]$connection,
    [string]$name
)
    $sql = "DROP PROCEDURE $name"
    Write-Debug $sql
    
    $cmd = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $cmd.ExecuteNonQuery()    
}