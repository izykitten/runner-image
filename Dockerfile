FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
    if (Test-Path C:\\ProgramData\\chocolatey\\cache) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\cache -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\ProgramData\\chocolatey\\logs) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\logs -ErrorAction SilentlyContinue }; \
    if (Test-Path 'C:\\ProgramData\\Package Cache') { Remove-Item -Force -Recurse 'C:\\ProgramData\\Package Cache' -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\Temp) { Remove-Item -Force -Recurse C:\\Windows\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\SoftwareDistribution\\Download) { Remove-Item -Force -Recurse C:\\Windows\\SoftwareDistribution\\Download\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\Administrator\\AppData\\Local\\Temp) { Remove-Item -Force -Recurse C:\\Users\\Administrator\\AppData\\Local\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\Administrator\\AppData\\Local\\NuGet) { Remove-Item -Force -Recurse C:\\Users\\Administrator\\AppData\\Local\\NuGet -ErrorAction SilentlyContinue }; \
    $true

# Install PowerShell 7, Git, Docker CLI, Docker Compose, and common CI tools
RUN choco install -y --no-progress powershell-core git docker-cli docker-compose 7zip curl; \
    if (Test-Path C:\\ProgramData\\chocolatey\\cache) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\cache -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\ProgramData\\chocolatey\\logs) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\logs -ErrorAction SilentlyContinue }; \
    if (Test-Path 'C:\\ProgramData\\Package Cache') { Remove-Item -Force -Recurse 'C:\\ProgramData\\Package Cache' -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\Temp) { Remove-Item -Force -Recurse C:\\Windows\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\SoftwareDistribution\\Download) { Remove-Item -Force -Recurse C:\\Windows\\SoftwareDistribution\\Download\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\Administrator\\AppData\\Local\\Temp) { Remove-Item -Force -Recurse C:\\Users\\Administrator\\AppData\\Local\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\Administrator\\AppData\\Local\\NuGet) { Remove-Item -Force -Recurse C:\\Users\\Administrator\\AppData\\Local\\NuGet -ErrorAction SilentlyContinue }; \
    $true

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN git config --system credential.helper ''

# Install and configure OpenSSH server using Windows capability
RUN Add-WindowsCapability -Online -Name OpenSSH.Server; \
    Set-Service -Name sshd -StartupType Automatic; \
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Program Files\PowerShell\7\pwsh.exe' -PropertyType String -Force; \
    $pwd = ConvertTo-SecureString -String 'runner' -AsPlainText -Force; \
    New-LocalUser -Name 'runner' -Password $pwd -PasswordNeverExpires -AccountNeverExpires; \
    Add-LocalGroupMember -Group 'Administrators' -Member 'runner'; \
    $true

# Copy SSH Configuration and host keys
COPY ssh/* /ProgramData/ssh/

# Fix Permission denied: explicitly grant sshd access to the config
RUN $ssh = 'C:\ProgramData\ssh'; \
    $config = Join-Path $ssh 'sshd_config'; \
    if (-not (Test-Path $config)) { throw "Missing sshd_config: $config" }; \
    \
    & icacls $ssh /inheritance:r | Out-Null; \
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    & icacls $ssh /grant:r 'SYSTEM:(OI)(CI)F' 'BUILTIN\Administrators:(OI)(CI)F' | Out-Null; \
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    \
    & icacls $config /inheritance:r | Out-Null; \
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    & icacls $config /grant:r 'SYSTEM:F' 'BUILTIN\Administrators:F' | Out-Null; \
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    \
    $adminKeys = Join-Path $ssh 'administrators_authorized_keys'; \
    if (Test-Path $adminKeys) { \
        & icacls $adminKeys /inheritance:r | Out-Null; \
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
        & icacls $adminKeys /grant:r 'SYSTEM:F' 'BUILTIN\Administrators:F' | Out-Null; \
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    } \
    \
    Get-ChildItem -LiteralPath $ssh -Filter 'ssh_host_*_key' -File | ForEach-Object { \
        & icacls $_.FullName /inheritance:r | Out-Null; \
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
        & icacls $_.FullName /grant:r 'SYSTEM:F' 'BUILTIN\Administrators:F' | Out-Null; \
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    }; \
    \
    & 'C:\Windows\System32\OpenSSH\sshd.exe' -t; \
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }; \
    $true


EXPOSE 22

ENTRYPOINT ["pwsh", "-Command"]
CMD ["Start-Service sshd; while ($true) { Start-Sleep -Seconds 3600 }"]
