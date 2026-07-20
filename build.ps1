# Zakat & Tazkiyah Calculator - Local Build Utility
# This script handles local building and deployment for Android, Web, and Cloudflare Worker.

$ErrorActionPreference = "Stop"

# Define Output Directories
$ProjectRoot = Get-Location
$ReleaseDir = Join-Path $ProjectRoot "release"
$WebReleaseDir = Join-Path $ReleaseDir "web"
$PreviewWebDir = Join-Path $ProjectRoot "preview-web"

# Colors for output
function Write-Header ($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Success ($text) {
    Write-Host "[OK] $text" -ForegroundColor Green
}

function Write-Info ($text) {
    Write-Host "[INFO] $text" -ForegroundColor Blue
}

function Write-WarningMsg ($text) {
    Write-Host "[WARNING] $text" -ForegroundColor Yellow
}

function Write-ErrorMsg ($text) {
    Write-Host "[ERROR] $text" -ForegroundColor Red
}

# 1. Environment and Path Diagnostics
function Setup-Environment {
    # Detect Flutter
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterCmd) {
        Write-Info "Flutter not found in PATH. Scanning common directories..."
        $commonFlutterPaths = @(
            "C:\flutter\bin",
            "C:\src\flutter\bin",
            "$env:USERPROFILE\flutter\bin",
            "$env:USERPROFILE\src\flutter\bin",
            "$env:LOCALAPPDATA\Flutter\bin"
        )
        $found = $false
        foreach ($path in $commonFlutterPaths) {
            if (Test-Path (Join-Path $path "flutter.bat")) {
                $env:PATH = "$path;" + $env:PATH
                Write-Success "Found Flutter at: $path (added to temporary session PATH)"
                $found = $true
                break
            }
        }
        if (-not $found) {
            Write-WarningMsg "Could not locate Flutter automatically."
            Write-WarningMsg "Please ensure Flutter is installed and added to your system PATH, or edit this script to include its path."
        }
    }

    # Detect Java / JDK
    if (-not $env:JAVA_HOME) {
        Write-Info "JAVA_HOME is not set. Scanning common directories..."
        $commonJavaPaths = @(
            "C:\src\jdk-17\jdk-17.0.19+10",
            "C:\Program Files\Java\jdk-17",
            "C:\Program Files\Android\Android Studio\jbr",
            "C:\Program Files\Android\Android Studio\jre"
        )
        $foundJava = $false
        foreach ($path in $commonJavaPaths) {
            if (Test-Path (Join-Path $path "bin\java.exe")) {
                $env:JAVA_HOME = $path
                $env:PATH = "$(Join-Path $path 'bin');" + $env:PATH
                Write-Success "Found Java JDK at: $path (set session JAVA_HOME and added bin to PATH)"
                $foundJava = $true
                break
            }
        }
        if (-not $foundJava) {
            Write-WarningMsg "Could not locate a Java Development Kit (JDK) automatically."
            Write-WarningMsg "Please ensure JDK is installed and JAVA_HOME environment variable is set."
        }
    } else {
        # Ensure bin is in Path
        if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
            $env:PATH = "$(Join-Path $env:JAVA_HOME 'bin');" + $env:PATH
        }
    }
}

# 2. Build Actions
function Clean-Project {
    Write-Header "Cleaning Project Cache"
    Setup-Environment
    flutter clean
    Write-Success "Project clean completed."
}

function Build-Android {
    Write-Header "Building Android APK (Release)"
    Setup-Environment
    
    Write-Info "Running flutter pub get..."
    flutter pub get
    
    Write-Info "Compiling Android Release APK..."
    flutter build apk --release
    
    # Copy build artifact to release directory
    $apkSource = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $apkSource) {
        if (-not (Test-Path $ReleaseDir)) {
            New-Item -ItemType Directory -Path $ReleaseDir -Force | Out-Null
        }
        $apkDest = Join-Path $ReleaseDir "ZakahCalculator-release.apk"
        Copy-Item -Path $apkSource -Destination $apkDest -Force
        
        $apkSizeMB = [Math]::Round(((Get-Item $apkDest).Length / 1MB), 2)
        Write-Success "Android APK built successfully!"
        Write-Host "Location: $apkDest" -ForegroundColor Green
        Write-Host "Size: $apkSizeMB MB" -ForegroundColor Green
    } else {
        Write-ErrorMsg "Failed to locate generated APK at $apkSource"
    }
}

function Build-Web {
    Write-Header "Building Web App (Release)"
    Setup-Environment
    
    Write-Info "Running flutter pub get..."
    flutter pub get
    
    Write-Info "Compiling Web Build (using flat base-href '/' for local hosting)..."
    flutter build web --release --base-href "/"
    
    $webBuildSource = Join-Path $ProjectRoot "build\web"
    if (Test-Path $webBuildSource) {
        # Deploy to local release folder
        Write-Info "Copying files to $WebReleaseDir..."
        if (Test-Path $WebReleaseDir) {
            Remove-Item -Path $WebReleaseDir -Recurse -Force | Out-Null
        }
        New-Item -ItemType Directory -Path $WebReleaseDir -Force | Out-Null
        Copy-Item -Path "$webBuildSource\*" -Destination $WebReleaseDir -Recurse -Force
        
        # Deploy/Update local preview folder
        Write-Info "Updating local $PreviewWebDir folder..."
        if (Test-Path $PreviewWebDir) {
            # Delete files, but handle locked/active folders gently
            Get-ChildItem -Path $PreviewWebDir | Remove-Item -Recurse -Force
        } else {
            New-Item -ItemType Directory -Path $PreviewWebDir -Force | Out-Null
        }
        Copy-Item -Path "$webBuildSource\*" -Destination $PreviewWebDir -Recurse -Force
        
        # Add .nojekyll file to preview-web for static hosting compat
        New-Item -ItemType File -Path (Join-Path $PreviewWebDir ".nojekyll") -Force | Out-Null
        
        Write-Success "Web production bundle generated successfully!"
        Write-Host "Local Preview Build: $PreviewWebDir" -ForegroundColor Green
        Write-Host "Web Release Build: $WebReleaseDir" -ForegroundColor Green
    } else {
        Write-ErrorMsg "Failed to locate Web build output at $webBuildSource"
    }
}

function Deploy-Worker {
    Write-Header "Deploying Cloudflare Worker Backend"
    
    # Try deploying using wrangler
    $wranglerCmd = Get-Command wrangler -ErrorAction SilentlyContinue
    if (-not $wranglerCmd) {
        Write-Info "Wrangler is not in global PATH. Checking local node_modules..."
        if (Test-Path "node_modules\.bin\wrangler.cmd") {
            $wranglerPath = "node_modules\.bin\wrangler.cmd"
        } else {
            $wranglerPath = "npx wrangler"
        }
    } else {
        $wranglerPath = "wrangler"
    }
    
    Write-Info "Executing deployment command: $wranglerPath deploy..."
    try {
        if ($wranglerPath -eq "npx wrangler") {
            npx wrangler deploy
        } elseif ($wranglerPath -eq "node_modules\.bin\wrangler.cmd") {
            & "node_modules\.bin\wrangler.cmd" deploy
        } else {
            wrangler deploy
        }
        Write-Success "Cloudflare Worker deployed successfully!"
    } catch {
        Write-ErrorMsg "Failed to deploy Cloudflare Worker. Please check that Node.js is installed and you are logged into Wrangler ('npx wrangler login')."
    }
}

function Preview-Web-Locally {
    Write-Header "Previewing Web App Locally"
    
    if (-not (Test-Path $WebReleaseDir)) {
        Write-WarningMsg "Web build not found in $WebReleaseDir. Building Web now..."
        Build-Web
    }
    
    Write-Info "Checking for available local web servers..."
    
    # Option 1: Python
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Write-Success "Starting Python local web server on http://localhost:8080..."
        Write-Info "Press Ctrl+C to stop the server."
        python -m http.server 8080 --directory $WebReleaseDir
        return
    }
    
    # Option 2: Node.js http-server
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCmd) {
        Write-Success "Starting http-server via npx on http://localhost:8080..."
        Write-Info "Press Ctrl+C to stop the server."
        npx http-server $WebReleaseDir -p 8080
        return
    }
    
    # Option 3: Fallback instructions
    Write-WarningMsg "Neither Python nor Node.js was found in PATH to serve the files."
    Write-Info "To preview the app locally:"
    Write-Info "1. Open a terminal and run: flutter run -d chrome"
    Write-Info "2. Or host the files in '$WebReleaseDir' using any web server."
}

# 3. Argument Parsing & CLI Loop
$Action = $args[0]

if ($Action) {
    switch ($Action) {
        "apk"     { Build-Android; break }
        "web"     { Build-Web; break }
        "worker"  { Deploy-Worker; break }
        "preview" { Preview-Web-Locally; break }
        "clean"   { Clean-Project; break }
        default {
            Write-ErrorMsg "Unknown command: $Action"
            Write-Host "Available arguments: apk, web, worker, preview, clean"
            exit 1
        }
    }
} else {
    # Interactive CLI Menu
    do {
        Clear-Host
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host "       Zakat & Tazkiyah Build System         " -ForegroundColor Cyan
        Write-Host "=============================================" -ForegroundColor Cyan
        Write-Host " 1. Build Android APK (Release)"
        Write-Host " 2. Build Web App (Release)"
        Write-Host " 3. Deploy Cloudflare Worker"
        Write-Host " 4. Preview Web App Locally"
        Write-Host " 5. Clean Project Cache"
        Write-Host " 6. Exit"
        Write-Host "=============================================" -ForegroundColor Cyan
        
        $choice = Read-Host "Select an option [1-6]"
        
        switch ($choice) {
            "1" { Build-Android; Read-Host "`nPress Enter to return to menu..." }
            "2" { Build-Web; Read-Host "`nPress Enter to return to menu..." }
            "3" { Deploy-Worker; Read-Host "`nPress Enter to return to menu..." }
            "4" { Preview-Web-Locally; Read-Host "`nPress Enter to return to menu..." }
            "5" { Clean-Project; Read-Host "`nPress Enter to return to menu..." }
            "6" { Write-Host "`nExiting build system. Goodbye!" -ForegroundColor Green }
            default { Write-WarningMsg "`nInvalid choice. Please select 1 to 6."; Start-Sleep -Seconds 1 }
        }
    } while ($choice -ne "6")
}
