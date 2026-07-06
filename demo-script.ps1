#!/usr/bin/env pwsh
# =============================================================
# demo-script.ps1
# Script demo CI/CD trước lớp - chạy từng bước theo thứ tự
# =============================================================

$PROJECT_DIR = "C:\Users\a\.gemini\antigravity\scratch\devops-cicd-lectures\sample-code"
$GITHUB_URL  = "https://github.com/TEN_BAN/user-service/actions"  # ← Sửa lại

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEMO CI/CD - [BE-105] DevOps Course  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ─────────────────────────────────────────
# DEMO 1: Chạy ứng dụng local
# ─────────────────────────────────────────
function Demo-RunLocal {
    Write-Host "`n[DEMO 1] Chạy ứng dụng Spring Boot local..." -ForegroundColor Yellow
    Set-Location $PROJECT_DIR
    Write-Host "Lệnh: mvn spring-boot:run" -ForegroundColor Gray
    Write-Host "→ Mở trình duyệt: http://localhost:8080/api/v1/users" -ForegroundColor Green
    Write-Host "→ Mở H2 Console:  http://localhost:8080/h2-console" -ForegroundColor Green
    Start-Process "mvn" "spring-boot:run" -NoNewWindow
}

# ─────────────────────────────────────────
# DEMO 2: Chạy test local
# ─────────────────────────────────────────
function Demo-RunTests {
    Write-Host "`n[DEMO 2] Chạy toàn bộ Unit Tests..." -ForegroundColor Yellow
    Set-Location $PROJECT_DIR
    mvn test --file pom.xml
    Write-Host "`n→ Báo cáo test tại: target/surefire-reports/" -ForegroundColor Green
}

# ─────────────────────────────────────────
# DEMO 3: Push code → kích hoạt pipeline
# ─────────────────────────────────────────
function Demo-TriggerPipeline {
    Write-Host "`n[DEMO 3] Push code → kích hoạt GitHub Actions..." -ForegroundColor Yellow
    Set-Location $PROJECT_DIR
    git add .
    git commit -m "demo: trigger CI/CD pipeline"
    git push origin main
    Write-Host "`n→ Vào xem pipeline đang chạy tại:" -ForegroundColor Green
    Write-Host "  $GITHUB_URL" -ForegroundColor Cyan
    Start-Process $GITHUB_URL   # Mở trình duyệt tự động
}

# ─────────────────────────────────────────
# DEMO 4: Phá test để thấy pipeline đỏ ❌
# ─────────────────────────────────────────
function Demo-BreakTest {
    Write-Host "`n[DEMO 4] Sửa test để FAIL → pipeline sẽ đỏ..." -ForegroundColor Red
    $testFile = "$PROJECT_DIR\src\test\java\com\devops\demo\userservice\service\UserServiceTest.java"

    # Sửa hasSize(1) thành hasSize(999) - sai cố ý
    (Get-Content $testFile) -replace "hasSize\(1\)", "hasSize(999)" | Set-Content $testFile

    Write-Host "Đã sửa: assertThat(result).hasSize(999)  ← SAI CỐ Ý!" -ForegroundColor Red
    Set-Location $PROJECT_DIR
    git add .
    git commit -m "bug: broken test - pipeline should fail"
    git push origin main
    Write-Host "`n→ Pipeline sẽ đỏ ❌ tại:" -ForegroundColor Red
    Write-Host "  $GITHUB_URL" -ForegroundColor Cyan
    Start-Process $GITHUB_URL
}

# ─────────────────────────────────────────
# DEMO 5: Fix lại → pipeline xanh ✅
# ─────────────────────────────────────────
function Demo-FixTest {
    Write-Host "`n[DEMO 5] Fix lại test → pipeline xanh trở lại..." -ForegroundColor Green
    $testFile = "$PROJECT_DIR\src\test\java\com\devops\demo\userservice\service\UserServiceTest.java"

    # Sửa lại về đúng
    (Get-Content $testFile) -replace "hasSize\(999\)", "hasSize(1)" | Set-Content $testFile

    Write-Host "Đã sửa lại: assertThat(result).hasSize(1)  ← ĐÚNG!" -ForegroundColor Green
    Set-Location $PROJECT_DIR
    git add .
    git commit -m "fix: restore correct test assertion"
    git push origin main
    Write-Host "`n→ Pipeline xanh ✅ tại:" -ForegroundColor Green
    Write-Host "  $GITHUB_URL" -ForegroundColor Cyan
    Start-Process $GITHUB_URL
}

# ─────────────────────────────────────────
# DEMO 6: Build Docker image thủ công
# ─────────────────────────────────────────
function Demo-Docker {
    Write-Host "`n[DEMO 6] Build Docker image (Multi-stage)..." -ForegroundColor Yellow
    Set-Location $PROJECT_DIR
    docker build -t user-service:demo .
    Write-Host "`n→ So sánh kích thước image:" -ForegroundColor Yellow
    docker images user-service
    Write-Host "`n→ Chạy bằng Docker:" -ForegroundColor Green
    Write-Host "  docker run -p 8080:8080 user-service:demo" -ForegroundColor Gray
}

# ─────────────────────────────────────────
# MENU chọn demo
# ─────────────────────────────────────────
Write-Host "`nChọn demo muốn chạy:" -ForegroundColor White
Write-Host "  1. Chạy ứng dụng local"        -ForegroundColor Gray
Write-Host "  2. Chạy Unit Tests"             -ForegroundColor Gray
Write-Host "  3. Push code → kích hoạt pipeline" -ForegroundColor Gray
Write-Host "  4. Phá test → pipeline ❌ đỏ"  -ForegroundColor Gray
Write-Host "  5. Fix test  → pipeline ✅ xanh" -ForegroundColor Gray
Write-Host "  6. Build Docker image"          -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Nhập số (1-6)"
switch ($choice) {
    "1" { Demo-RunLocal }
    "2" { Demo-RunTests }
    "3" { Demo-TriggerPipeline }
    "4" { Demo-BreakTest }
    "5" { Demo-FixTest }
    "6" { Demo-Docker }
    default { Write-Host "Không hợp lệ!" -ForegroundColor Red }
}
