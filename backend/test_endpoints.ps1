# Configuration
$baseUrl = "https://repair.fong-yi.com.tw/api"
$userId = "i00104"
$password = "000000"

# 1. Authentication
try {
    Write-Host "1. Authenticating (登入)..." -ForegroundColor Cyan
    $loginUrl = "$baseUrl/users/login"
    $loginBody = @{
        accountid = $userId
        password  = $password
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token

    if ([string]::IsNullOrEmpty($token)) {
        Write-Host "Login failed: No token received." -ForegroundColor Red
        exit
    }

    $headers = @{
        Authorization = "Bearer $token"
    }
    Write-Host "Login successful! Token received." -ForegroundColor Green
    
}
catch {
    Write-Host "Login failed: $_" -ForegroundColor Red
    exit
}

# 2. Run Tests
try {
    Write-Host "`n2. Testing Home API (首頁)..." -ForegroundColor Cyan
    $homeData = Invoke-RestMethod -Uri "$baseUrl/home/$userId" -Method Get -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($homeData | ConvertTo-Json -Depth 2)

    Write-Host "`n3. Testing Progress API (工程進度)..." -ForegroundColor Cyan
    $progress = Invoke-RestMethod -Uri "$baseUrl/progress/$userId" -Method Get -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($progress | ConvertTo-Json -Depth 2)

    Write-Host "`n4. Testing Payment API (繳款查詢)..." -ForegroundColor Cyan
    $payment = Invoke-RestMethod -Uri "$baseUrl/payment/$userId" -Method Get -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($payment | ConvertTo-Json -Depth 2)

    Write-Host "`n5. Testing Profile API (會員中心)..." -ForegroundColor Cyan
    $userProfile = Invoke-RestMethod -Uri "$baseUrl/profile/$userId" -Method Get -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($userProfile | ConvertTo-Json -Depth 2)

    Write-Host "`n6. Testing Repair API - History (報修紀錄)..." -ForegroundColor Cyan
    $repairs = Invoke-RestMethod -Uri "$baseUrl/repair/$userId" -Method Get -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($repairs | ConvertTo-Json -Depth 2)

    Write-Host "`n7. Testing Repair API - Create (新增報修)..." -ForegroundColor Cyan
    
    # Simulating a repair request
    # Note: These fields should match what the backend expects in RepairRequestDTO
    $body = @{
        issueDescription = "Test Issue from PowerShell Script (Automated Test) - 測試報修"
        custname         = "Test User"
        custphone        = "0912345678"
        pjnoid           = "19A" # Example project ID, adjust if necessary based on user data
        unoid            = "E06"  # Example unit ID
        addrs            = "Test Address 123"
        custtype         = "01" # Assuming '01' is a valid customer type
    } | ConvertTo-Json

    # Using the same headers which includes the Authorization token
    $newRepair = Invoke-RestMethod -Uri "$baseUrl/repair/$userId" -Method Post -Body $body -ContentType "application/json" -Headers $headers
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ($newRepair | ConvertTo-Json -Depth 2)

}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    # Improved error handling to show response body for debugging
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        if ($stream) {
            $reader = New-Object IO.StreamReader $stream
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
        }
    }
}
