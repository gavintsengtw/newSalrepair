$baseUrl = "http://localhost:8080/api"
$userId = "user123"

try {
    Write-Host "1. Testing Home API (首頁)..." -ForegroundColor Cyan
    $home = Invoke-RestMethod -Uri "$baseUrl/home/$userId" -Method Get
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($home | ConvertTo-Json -Depth 2)

    Write-Host "`n2. Testing Progress API (工程進度)..." -ForegroundColor Cyan
    $progress = Invoke-RestMethod -Uri "$baseUrl/progress/$userId" -Method Get
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($progress | ConvertTo-Json -Depth 2)

    Write-Host "`n3. Testing Payment API (繳款查詢)..." -ForegroundColor Cyan
    $payment = Invoke-RestMethod -Uri "$baseUrl/payment/$userId" -Method Get
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($payment | ConvertTo-Json -Depth 2)

    Write-Host "`n4. Testing Profile API (會員中心)..." -ForegroundColor Cyan
    $profile = Invoke-RestMethod -Uri "$baseUrl/profile/$userId" -Method Get
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($profile | ConvertTo-Json -Depth 2)

    Write-Host "`n5. Testing Repair API - History (報修紀錄)..." -ForegroundColor Cyan
    $repairs = Invoke-RestMethod -Uri "$baseUrl/repair/$userId" -Method Get
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($repairs | ConvertTo-Json -Depth 2)

    Write-Host "`n6. Testing Repair API - Create (新增報修)..." -ForegroundColor Cyan
    $body = @{
        issueDescription = "Test Issue from PowerShell Script"
    } | ConvertTo-Json
    $newRepair = Invoke-RestMethod -Uri "$baseUrl/repair/$userId" -Method Post -Body $body -ContentType "application/json"
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($newRepair | ConvertTo-Json -Depth 2)

} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host "Please make sure the Spring Boot application is running on port 8080." -ForegroundColor Yellow
}
