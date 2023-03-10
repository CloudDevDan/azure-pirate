# Input bindings are passed in via param block.
param($Timer)

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) 
{
    Write-Warning "Timer is running late!"
}

# DB lookup
try 
{
    $SecureKey = ConvertTo-SecureString $env:CosmosAccountKey -AsPlainText -Force
    $cosmosDbContext = New-CosmosDbContext -Account $env:CosmosAccountName -Database $env:CosmosDBName -Key $SecureKey
    $query = "SELECT * FROM logs c"
    $record = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:CosmosCollectionName -Query $query -QueryEnableCrossPartition $True
    Write-Verbose "DB query: $($query)"
}
catch
{
    Write-Error "Could not work with Cosmos. Stopping. Error: $_"
    exit
}

if ($record)
{
    $filtered = $record | Sort-Object date -Descending | select -first 10 | select id, handle, date, url, greeting
    ForEach ($r in $filtered)
    {
        if (!$R.title -or $r.title -match "null")
        {
            Write-Host "This record has no title. Pulling it from greeting."
            if ($r.greeting -and $r.greeting -match "called:")
            {
                $newTitle = $r.greeting.Split("called")[1].Split("Check it out it here")[0].Replace(": ","").Replace("`n","")
                $r | Add-Member -Membertype NoteProperty -Name title -value $newTitle -Force
            } else {
                Write-Warning "This record has no title or usable greeting. ID: $($r.id). Skipping,"
                $filtered = $filtered | Where-Object { $_ -ne $r }
            }
        }
    }
} else {
    Write-Error "No records returned. Stopping."
    exit
}

$fileName = "posts.json"
$outPath = "/home/data/$($fileName)"
$ContainerName = "posts"

$filtered | select title, handle, date, url | ConvertTo-Json | Out-File $outPath -Force

$Context = New-AzStorageContext -ConnectionString $env:AzureWebJobsStorage

# upload a file to the default account (inferred) access tier
$Blob1HT = @{
    File             = $outPath
    Container        = $ContainerName
    Blob             = $fileName
    Context          = $Context
    StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1HT -Force

Remove-Item $outPath -Force
