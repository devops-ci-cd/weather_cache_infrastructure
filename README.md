
Extract connection string from Azure SQL
https://www.phillipsj.net/posts/terraform-tips-for-azure-sql-db/

$json = Get-Content $env:jsonPath | Out-String | ConvertFrom-Json

Write-Host "##vso[task.setvariable variable=MyNewIp]$($json.public_ip_address.value)"

