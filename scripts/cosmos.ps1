# . env.ps1

. "$PSScriptRoot\env.ps1"

$SecureKey = ConvertTo-SecureString $env:NewCosmosAccountKey -AsPlainText -Force
$cosmosDbContext = New-CosmosDbContext -Account $env:NewCosmosAccountName -Database $env:NewCosmosDBName -Key $SecureKey
$query = "SELECT * FROM logs c"
$record = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:NewCosmosCollectionName -Query $query -QueryEnableCrossPartition $True # -MaxItemCount 5 # -ReturnJson


if ($record)
{
    $filtered = $record | Sort-Object date -Descending | select -first 10 | select handle, date, url, greeting #| ConvertTo-Json
    ForEach ($r in $filtered)
    {
        if (!$r.title)
        {
            Write-Warning "This record has no title. Pulling it from greeting."
            if ($r.greeting -and $r.greeting -match "called:")
            {
                $newTitle = $r.greeting.Split("called")[1].Split("Check it out it here")[0].Replace(": ","").Replace("`n","")
                $r | Add-Member -Membertype NoteProperty -Name title -value $newTitle -Force
            } else {
                Write-Warning "This record has no title or usable greeting. ID: $($r.id). Skipping,"
                continue
            }
        }
    }
} else {
    Write-Error "No records returned. Stopping."
    exit
}

$filtered | select handle, date, url, title | ConvertTo-Json


# $filtered = $record | Sort-Object date -Descending | select -first 10 | select handle, date, url, greeting | ConvertTo-Json
# ForEach ($r in $filtered)
# {
#     if (!$r.title)
#     {
#         if ($r.greeting)
#         {

#         }
#     }
#         $newTitle = $r.greeting.Split("called")[1].Split("Check it out it here")[0].Replace(": ","").Replace("`n","")
    
# }

# # if ($record)
# # {
# #     $filtered = $record | Sort-Object date | select handle, date, url, greeting | ConvertTo-Json
# #     ForEach ($r in $filtered)
# #     {
# #         if (!$r.title)
# #         {
# #             Write-Warning "This record has no title. Pulling it from greeting."
# #             if ($r.greeting)
# #             {
# #                 $r.greeting
# #             } else {
# #                 $r
# #                 Write-Error "This record has no title or greeting. ID: $($r.id) Pulling it from greeting."
# #             }
# #             # $r | ConvertTo-Json
# #         }
# #     }
# # } else {
# #     Write-Error "No records returned. Stopping."
# #     exit
# # }

# # $x = $record.greeting | select -last 1

# # $x.Split("called")[1].Split("Check it out it here")[0].Replace(": ","").Replace("`n","")

# # $record.greeting

# # $record | Sort-Object date | select -last 5 | select handle, date, url, greeting | ConvertTo-Json

# # $record.count


# # sort out no url
# # sort out no title

# ForEach ($r in $record)
# {
#     if ($r.greeting -match "called:" -and !$r.title)
#     {

#         # $r
#         # $r | Add-Member -Membertype NoteProperty -Name Computername -value "dd" -Force
#         # $r.Computername
#         $newTitle = $r.greeting.Split("called")[1].Split("Check it out it here")[0].Replace(": ","").Replace("`n","")
#         $newTitle

#         $r | Add-Member -Membertype NoteProperty -Name title -value $newTitle -Force
#         $r | ConvertTo-Json

#         # # $x = $r | ConvertTo-Json | ConvertFrom-Json
#         # # $r["title"] = "TEST"
#         # $r.GetType()

#         # $x = $r | ConvertFroom-Json

#         # $r.title = $newTitle
#         # $r

#         # $hash = [ordered]@{
#         #     id = $r.id
#         #     date = $r.date;
#         #     author = $r.author;
#         #     handle = $r.handle;
#         #     title = $newTitle;
#         #     titleCleaned = $r.titleCleaned;
#         #     url = $r.url;
#         #     origUrl = $r.origUrl;
#         #     greeting = $r.greeting;
#         # }

#        #  New-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:NewCosmosCollectionName -DocumentBody $r -PartitionKey $r.date

#         Set-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:NewCosmosCollectionName -Id $r.id -DocumentBody $r -PartitionKey $r.date
#         return
#     }
# }






# # called: A couple of announcements...\n\n

# # $record | Limit 2 | ConvertTo-Json
# # $record | Sort -Descending | ConvertTo-Json

# # query
# # $SecureKey = ConvertTo-SecureString $env:CosmosAccountKey -AsPlainText -Force
# # $cosmosDbContext = New-CosmosDbContext -Account $env:CosmosAccountName -Database $env:CosmosDBName -Key $SecureKey
# # $query = "SELECT * FROM c"
# # $record = Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:CosmosCollectionName -Query $query -QueryEnableCrossPartition $True
# # $record.length

# # $SecureKey = ConvertTo-SecureString $env:NewCosmosAccountKey -AsPlainText -Force
# # $cosmosDbContext = New-CosmosDbContext -Account $env:NewCosmosAccountName -Database $env:NewCosmosDBName -Key $SecureKey

# # $count = $record.length

# # ForEach ($r in $record)
# # {
# #     $postDateFmt = Get-Date $r.date -Format "yyyy-MM-dd"

# #     $newHash = [ordered]@{
# #         id = $r.id
# #         date = $postDateFmt
# #         author = $r.author
# #         handle = $r.handle
# #         title = $r.title
# #         titleCleaned = $r.titleCleaned
# #         url = $title.url
# #         greeting = $title.greeting
# #     }

# #     $message = $newHash | ConvertTo-Json -Depth 4
# #     $doc = New-CosmosDbDocument -Context $cosmosDbContext -CollectionId $env:NewCosmosCollectionName -DocumentBody $message -PartitionKey $postDateFmt

# #     # Start-Sleep 15
    
# #     $count = $count -1
# #     Write-Host "Working with $($count) items"

# # }