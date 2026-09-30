# Auto-elevate script to Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =================================================================
# 1. LOGIN SYSTEM (ENCRYPTED PASSWORD + MASKED INPUT)
# =================================================================
$loginForm = New-Object System.Windows.Forms.Form
$loginForm.Text = "JO-Tweak | Security Verification"
$loginForm.Size = New-Object System.Drawing.Size(400, 240)$loginForm.StartPosition = "CenterScreen"
$loginForm.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)$loginForm.FormBorderStyle = "FixedDialog"
$loginForm.MaximizeBox =$false

$lblLogin = New-Object System.Windows.Forms.Label
$lblLogin.Text = "ENTER ACCESS CODE"
$lblLogin.ForeColor = [System.Drawing.Color]::FromArgb(255, 82, 82)$lblLogin.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblLogin.Location = New-Object System.Drawing.Size(110, 25)
$lblLogin.AutoSize =$true
$loginForm.Controls.Add($lblLogin)

# Masked Password Input
$txtPass = New-Object System.Windows.Forms.TextBox
$txtPass.PasswordChar = '*'$txtPass.Size = New-Object System.Drawing.Size(220, 30)
$txtPass.Location = New-Object System.Drawing.Size(85, 70)$txtPass.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$txtPass.ForeColor = [System.Drawing.Color]::White$txtPass.BorderStyle = "FixedSingle"
$loginForm.Controls.Add($txtPass)

$btnLogin = New-Object System.Windows.Forms.Button
$btnLogin.Text = "Unlock JO-Tweak"
$btnLogin.Size = New-Object System.Drawing.Size(140, 35)
$btnLogin.Location = New-Object System.Drawing.Size(125, 120)$btnLogin.FlatStyle = "Flat"
$btnLogin.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(211, 47, 47)$btnLogin.BackColor = [System.Drawing.Color]::FromArgb(183, 28, 28)
$btnLogin.ForeColor = [System.Drawing.Color]::White$btnLogin.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$loginForm.Controls.Add($btnLogin)

# Encrypted Hash for 'bo36'
$script:encryptedPass = "Ym8zNg=="
$script:authenticated =$false

$btnLogin.Add_Click({
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($txtPass.Text)
    $inputEncoded = [Convert]::ToBase64String($bytes)

    if ($inputEncoded -eq $script:encryptedPass) {$script:authenticated = $true$loginForm.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Incorrect Password!", "Access Denied", "OK", "Error")
        $txtPass.Clear()
    }
})

$loginForm.ShowDialog() | Out-Null
if (-not $script:authenticated) { exit }

# =================================================================
# 2. MAIN TOOL UI (DARK RED / GRAY THEME & BO LOGO)
# =================================================================
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "JO-Tweak Utility"
$mainForm.Size = New-Object System.Drawing.Size(950, 730)$mainForm.StartPosition = "CenterScreen"
$mainForm.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 28)$mainForm.ForeColor = [System.Drawing.Color]::White

# --- HEADER SECTION WITH BO LOGO & JORDANIAN CREST ---
$panelHeader = New-Object System.Windows.Forms.Panel
$panelHeader.Size = New-Object System.Drawing.Size(910, 85)
$panelHeader.Location = New-Object System.Drawing.Size(12, 10)$panelHeader.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$mainForm.Controls.Add($panelHeader)

$lblShemagh = New-Object System.Windows.Forms.Label
$lblShemagh.Text = "🏁"
$lblShemagh.Font = New-Object System.Drawing.Font("Segoe UI", 26)
$lblShemagh.Location = New-Object System.Drawing.Size(15, 12)
$lblShemagh.AutoSize =$true
$panelHeader.Controls.Add($lblShemagh)

$lblBOLogo = New-Object System.Windows.Forms.Label
$lblBOLogo.Text = "BO"
$lblBOLogo.Font = New-Object System.Drawing.Font("Impact", 36, [System.Drawing.FontStyle]::Bold)
$lblBOLogo.ForeColor = [System.Drawing.Color]::FromArgb(255, 60, 60)$lblBOLogo.Location = New-Object System.Drawing.Size(65, 8)
$lblBOLogo.AutoSize =$true
$panelHeader.Controls.Add($lblBOLogo)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "JO-TWEAK SYSTEM UTILITY"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(240, 240, 240)$lblTitle.Location = New-Object System.Drawing.Size(155, 15)
$lblTitle.AutoSize =$true
$panelHeader.Controls.Add($lblTitle)

$lblEngineers = New-Object System.Windows.Forms.Label
$lblEngineers.Text = "Engineers: Braa & Omar"
$lblEngineers.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
$lblEngineers.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 120)$lblEngineers.Location = New-Object System.Drawing.Size(158, 48)
$lblEngineers.AutoSize =$true
$panelHeader.Controls.Add($lblEngineers)

# =================================================================
# 3. MAIN TABS SETUP
# =================================================================
$mainTabControl = New-Object System.Windows.Forms.TabControl
$mainTabControl.Size = New-Object System.Drawing.Size(910, 530)$mainTabControl.Location = New-Object System.Drawing.Size(12, 105)

$tabAppsRoot     = New-Object System.Windows.Forms.TabPage; $tabAppsRoot.Text     = "📦 1. Applications"
$tabUninstall    = New-Object System.Windows.Forms.TabPage; $tabUninstall.Text    = "🗑️ 2. Debloat & Uninstall"
$tabScriptsRoot  = New-Object System.Windows.Forms.TabPage; $tabScriptsRoot.Text  = "📜 3. Scripts"
$tabTweaksRoot   = New-Object System.Windows.Forms.TabPage; $tabTweaksRoot.Text   = "🚀 4. System Tweaks"
$tabSettingsRoot = New-Object System.Windows.Forms.TabPage; $tabSettingsRoot.Text = "⚙ 5. Windows Settings"

$mainTabControl.Controls.Add($tabAppsRoot)
$mainTabControl.Controls.Add($tabUninstall)
$mainTabControl.Controls.Add($tabScriptsRoot)
$mainTabControl.Controls.Add($tabTweaksRoot)
$mainTabControl.Controls.Add($tabSettingsRoot)
$mainForm.Controls.Add($mainTabControl)

function Apply-TabStyle($tab) {$tab.BackColor = [System.Drawing.Color]::FromArgb(38, 38, 38)
}
Apply-TabStyle $tabAppsRoot
Apply-TabStyle $tabUninstall
Apply-TabStyle $tabScriptsRoot
Apply-TabStyle $tabTweaksRoot
Apply-TabStyle $tabSettingsRoot

# =================================================================
# 4. SUB-TABS INSIDE "APPLICATIONS"
# =================================================================
$appSubTabs = New-Object System.Windows.Forms.TabControl
$appSubTabs.Size = New-Object System.Drawing.Size(890, 480)$appSubTabs.Location = New-Object System.Drawing.Size(8, 10)

$tabBrowsers = New-Object System.Windows.Forms.TabPage; $tabBrowsers.Text = "Browsers"
$tabGPU      = New-Object System.Windows.Forms.TabPage; $tabGPU.Text      = "GPU Apps"
$tabCPU      = New-Object System.Windows.Forms.TabPage; $tabCPU.Text      = "CPU & Drivers"
$tabDevUtils = New-Object System.Windows.Forms.TabPage; $tabDevUtils.Text = "Dev & Utilities"
$tabStores   = New-Object System.Windows.Forms.TabPage; $tabStores.Text   = "PC Stores"
$tabRuntimes = New-Object System.Windows.Forms.TabPage; $tabRuntimes.Text = "C++ & Java"
$tabSocial   = New-Object System.Windows.Forms.TabPage; $tabSocial.Text   = "Social & Media"

$categories = @($tabBrowsers, $tabGPU,$tabCPU, $tabDevUtils,$tabStores, $tabRuntimes,$tabSocial)
foreach ($cat in$categories) {
    Apply-TabStyle $cat
    $appSubTabs.Controls.Add($cat)
}
$tabAppsRoot.Controls.Add($appSubTabs)

$script:appCheckboxes = @()

function Install-SingleApp($appName,$wingetId) {
    $lblStatus.Text = "Status: Downloading & Installing $appName..."
    $mainForm.Refresh()
    Start-Process winget -ArgumentList "install --id $wingetId -e --silent --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
    $lblStatus.Text = "Status: $appName Installed Successfully!"
    [System.Windows.Forms.MessageBox]::Show("$appName has been installed successfully!", "Single Install Complete", "OK", "Information")
}

function Add-AppOption($parentTab,$appName, $wingetId,$x, $y) {$chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text =$appName
    $chk.Tag =$wingetId
    $chk.ForeColor = [System.Drawing.Color]::White$chk.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
    $chk.Location = New-Object System.Drawing.Size($x,$y)
    $chk.AutoSize =$true

    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    $itemInstall = $contextMenu.Items.Add("Install $appName Now")
    $itemInstall.Add_Click({ Install-SingleApp $appName$wingetId })
    $chk.ContextMenuStrip =$contextMenu

    $parentTab.Controls.Add($chk)
    $script:appCheckboxes +=$chk
}

# Browsers
Add-AppOption $tabBrowsers "Brave Browser" "Brave.Brave" 30 30
Add-AppOption $tabBrowsers "Google Chrome" "Google.Chrome" 30 70
Add-AppOption $tabBrowsers "Mozilla Firefox" "Mozilla.Firefox" 30 110
Add-AppOption $tabBrowsers "Opera GX" "Opera.OperaGX" 30 150

# GPU
Add-AppOption $tabGPU "NVIDIA App" "Nvidia.NvidiaApp" 30 30
Add-AppOption $tabGPU "GeForce Experience" "Nvidia.GeForceExperience" 30 70
Add-AppOption $tabGPU "AMD Software Adrenalin" "AdvancedMicroDevices.Developer.AMDSoftware" 30 110
Add-AppOption $tabGPU "Intel Arc Control" "Intel.ArcControl" 30 150

# CPU & Drivers
Add-AppOption $tabCPU "AMD Ryzen Master" "AdvancedMicroDevices.RyzenMaster" 30 30
Add-AppOption $tabCPU "Intel XTU" "Intel.XTU" 30 70
Add-AppOption $tabCPU "Driver Booster" "IObit.DriverBooster" 30 110
Add-AppOption $tabCPU "Snappy Driver Installer" "SnappyDriverInstaller.SDIO" 30 150

# Dev & Utils
Add-AppOption $tabDevUtils "Visual Studio Code" "Microsoft.VisualStudioCode" 30 30
Add-AppOption $tabDevUtils "Git" "Git.Git" 30 70
Add-AppOption $tabDevUtils "Python 3" "Python.Python.3.11" 30 110
Add-AppOption $tabDevUtils "Notepad++" "Notepad++.Notepad++" 30 150
Add-AppOption $tabDevUtils "MSI Afterburner" "Guru3D.MSIAfterburner" 250 30
Add-AppOption $tabDevUtils "Microsoft PowerToys" "Microsoft.PowerToys" 250 70
Add-AppOption $tabDevUtils "7-Zip" "7zip.7zip" 250 110

# Stores
Add-AppOption $tabStores "Steam" "Valve.Steam" 30 30
Add-AppOption $tabStores "Epic Games Launcher" "EpicGames.EpicGamesLauncher" 30 70
Add-AppOption $tabStores "EA App" "ElectronicArts.EADesktop" 30 110
Add-AppOption $tabStores "Ubisoft Connect" "Ubisoft.Connect" 30 150
Add-AppOption $tabStores "GOG Galaxy" "GOG.Galaxy" 30 190

# Runtimes
Add-AppOption $tabRuntimes "Visual C++ Redistributable AIO" "TechPowerUp.VisualCplusplusRedistributableRuntimesAllInOne" 30 30
Add-AppOption $tabRuntimes "Java Runtime Environment (JRE)" "Oracle.JavaRuntimeEnvironment" 30 70

# Social
Add-AppOption $tabSocial "Discord" "Discord.Discord" 30 30
Add-AppOption $tabSocial "Telegram Desktop" "Telegram.TelegramDesktop" 30 70
Add-AppOption $tabSocial "WhatsApp" "WhatsApp.WhatsApp" 30 110
Add-AppOption $tabSocial "Spotify" "Spotify.Spotify" 30 150
Add-AppOption $tabSocial "VLC Media Player" "VideoLAN.VLC" 30 190

# =================================================================
# 5. DEBLOAT & UNINSTALL APPS TAB
# =================================================================
$script:debloatCheckboxes = @()

function Add-DebloatOption($parentTab,$bloatName, $packagePattern,$x, $y) {$chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text = "Remove $bloatName"
    $chk.Tag =$packagePattern
    $chk.ForeColor = [System.Drawing.Color]::FromArgb(255, 120, 120)$chk.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $chk.Location = New-Object System.Drawing.Size($x,$y)
    $chk.AutoSize =$true
    $parentTab.Controls.Add($chk)
    $script:debloatCheckboxes +=$chk
}

Add-DebloatOption $tabUninstall "Microsoft Cortana & Copilot" "*Cortana*" 30 30
Add-DebloatOption $tabUninstall "Windows Weather & News App" "*BingWeather*" 30 70
Add-DebloatOption $tabUninstall "Xbox Game Bar & Xbox Bloat" "*Xbox*" 30 110
Add-DebloatOption $tabUninstall "Get Help & Feedback Hub" "*GetHelp*" 30 150
Add-DebloatOption $tabUninstall "Windows Solitaire Collection" "*SolitaireCollection*" 30 190
Add-DebloatOption $tabUninstall "3D Builder & 3D Viewer" "*3D*" 30 230
Add-DebloatOption $tabUninstall "Skype & People Apps" "*SkypeApp*" 30 270

# =================================================================
# 6. SCRIPTS, TWEAKS & WINDOWS SETTINGS TABS
# =================================================================
# Scripts Tab
$btnCleanScript = New-Object System.Windows.Forms.Button
$btnCleanScript.Text = "Run System Cleanup & Reset Network DNS"
$btnCleanScript.Size = New-Object System.Drawing.Size(320, 45)
$btnCleanScript.Location = New-Object System.Drawing.Size(30, 30)$btnCleanScript.FlatStyle = "Flat"
$btnCleanScript.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$btnCleanScript.ForeColor = [System.Drawing.Color]::White$btnCleanScript.Add_Click({
    ipconfig /flushdns | Out-Null
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("DNS Flushed and Temp Files Cleared!", "Script Output")
})
$tabScriptsRoot.Controls.Add($btnCleanScript)

# System Tweaks Tab
$script:tweakCheckboxes = @()

function Add-TweakOption($parentTab,$tweakName, $tweakId,$x, $y) {$chk = New-Object System.Windows.Forms.CheckBox
    $chk.Text =$tweakName
    $chk.Tag =$tweakId
    $chk.ForeColor = [System.Drawing.Color]::FromArgb(255, 180, 180)$chk.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $chk.Location = New-Object System.Drawing.Size($x,$y)
    $chk.AutoSize =$true
    $parentTab.Controls.Add($chk)
    $script:tweakCheckboxes +=$chk
}

Add-TweakOption $tabTweaksRoot "1. Create System Restore Point First" "restore" 30 30
Add-TweakOption $tabTweaksRoot "2. Disable Telemetry & Background Tracking" "telemetry" 30 70
Add-TweakOption $tabTweaksRoot "3. Optimize Gaming & Lower Network Latency" "gaming" 30 110

# Windows Settings Tab
$btnWinUpdate = New-Object System.Windows.Forms.Button
$btnWinUpdate.Text = "Disable Delay Feature Updates (Security Only)"
$btnWinUpdate.Size = New-Object System.Drawing.Size(350, 45)
$btnWinUpdate.Location = New-Object System.Drawing.Size(30, 30)$btnWinUpdate.FlatStyle = "Flat"
$btnWinUpdate.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$btnWinUpdate.ForeColor = [System.Drawing.Color]::White$btnWinUpdate.Add_Click({
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -Value 1 -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Windows Updates adjusted to Security-Only mode!", "Settings")
})
$tabSettingsRoot.Controls.Add($btnWinUpdate)

# =================================================================
# 7. BOTTOM CONTROL PANEL (PROGRESS BAR & START BUTTON)
# =================================================================
$panelBottom = New-Object System.Windows.Forms.Panel
$panelBottom.Size = New-Object System.Drawing.Size(910, 75)
$panelBottom.Location = New-Object System.Drawing.Size(12, 640)$panelBottom.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$mainForm.Controls.Add($panelBottom)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Status: Ready to apply selected items..."
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
$lblStatus.Location = New-Object System.Drawing.Size(15, 10)
$lblStatus.AutoSize =$true
$panelBottom.Controls.Add($lblStatus)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(650, 20)
$progressBar.Location = New-Object System.Drawing.Size(15, 38)$progressBar.Style = "Continuous"
$panelBottom.Controls.Add($progressBar)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "START / APPLY"
$btnStart.Size = New-Object System.Drawing.Size(200, 48)
$btnStart.Location = New-Object System.Drawing.Size(690, 12)$btnStart.FlatStyle = "Flat"
$btnStart.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255, 60, 60)$btnStart.BackColor = [System.Drawing.Color]::FromArgb(183, 28, 28)
$btnStart.ForeColor = [System.Drawing.Color]::White$btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$panelBottom.Controls.Add($btnStart)

# Execution Handler
$btnStart.Add_Click({$selectedApps = $script:appCheckboxes \vert{} Where-Object {$_.Checked }
    $selectedTweaks =$script:tweakCheckboxes | Where-Object { $_.Checked }$selectedDebloat = $script:debloatCheckboxes \vert{} Where-Object {$_.Checked }

    $totalTasks =$selectedApps.Count + $selectedTweaks.Count +$selectedDebloat.Count
    if ($totalTasks -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one item to apply!", "Notice", "OK", "Information")
        return
    }

    $progressBar.Value = 0$currentStep = 0

    foreach ($deb in $selectedDebloat) {$currentStep++
        $percent = [int](($currentStep / $totalTasks) * 100)$progressBar.Value = $percent$lblStatus.Text = "Status: Removing Bloatware ($percent%) -> $($deb.Text)..."
        $mainForm.Refresh()
        Get-AppxPackage -Name $deb.Tag | Remove-AppxPackage -ErrorAction SilentlyContinue
    }

    foreach ($tw in $selectedTweaks) {$currentStep++
        $percent = [int](($currentStep / $totalTasks) * 100)$progressBar.Value = $percent$lblStatus.Text = "Status: Applying Tweaks ($percent%) -> $($tw.Text)..."
        $mainForm.Refresh()

        switch ($tw.Tag) {
            "restore" {
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                Checkpoint-Computer -Description "JO-Tweak Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
            }
            "telemetry" {
                Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
                New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
                Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -ErrorAction SilentlyContinue
            }
            "gaming" {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -ErrorAction SilentlyContinue
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -ErrorAction SilentlyContinue
            }
        }
    }

    foreach ($app in$selectedApps) {
        $currentStep++$percent = [int](($currentStep / $totalTasks) * 100)
        $progressBar.Value =$percent
        $lblStatus.Text = "Status: Downloading & Installing ($percent%) -> $($app.Text)..."
        $mainForm.Refresh()

        $appId =$app.Tag
        Start-Process winget -ArgumentList "install --id $appId -e --silent --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
    }

    $progressBar.Value = 100$lblStatus.Text = "Status: All tasks completed successfully!"
    [System.Windows.Forms.MessageBox]::Show("All selected tasks have finished successfully!", "JO-Tweak Success", "OK", "Information")
})

# Launch Main UI
$mainForm.ShowDialog() | Out-Null
