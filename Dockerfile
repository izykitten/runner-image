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
    if (Test-Path C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp) { Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet) { Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet -ErrorAction SilentlyContinue }; \
    $true

# Install PowerShell 7, Git, Docker CLI, and common CI tools
RUN choco install -y --no-progress powershell-core git docker-cli 7zip curl; \
    if (Test-Path C:\\ProgramData\\chocolatey\\cache) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\cache -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\ProgramData\\chocolatey\\logs) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\logs -ErrorAction SilentlyContinue }; \
    if (Test-Path 'C:\\ProgramData\\Package Cache') { Remove-Item -Force -Recurse 'C:\\ProgramData\\Package Cache' -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\Temp) { Remove-Item -Force -Recurse C:\\Windows\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Windows\\SoftwareDistribution\\Download) { Remove-Item -Force -Recurse C:\\Windows\\SoftwareDistribution\\Download\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp) { Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\* -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet) { Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet -ErrorAction SilentlyContinue }; \
    $true

# Install and configure OpenSSH server using Windows capability
RUN Add-WindowsCapability -Online -Name OpenSSH.Server; \
    Set-Service -Name sshd -StartupType Automatic; \
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Program Files\PowerShell\7\pwsh.exe' -PropertyType String -Force; \
    if (Test-Path C:\\ProgramData\\ssh\\sshd_config) { \
        (Get-Content C:\\ProgramData\\ssh\\sshd_config) -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes' | Set-Content C:\\ProgramData\\ssh\\sshd_config \
    }; \
    $true

# Copy authorized keys for ContainerAdministrator
COPY authorized_keys C:\\ProgramData\\ssh\\administrators_authorized_keys

# Set proper permissions on authorized_keys file
RUN icacls C:\\ProgramData\\ssh\\administrators_authorized_keys /inheritance:r; \
    icacls C:\\ProgramData\\ssh\\administrators_authorized_keys /grant "SYSTEM:(F)"; \
    icacls C:\\ProgramData\\ssh\\administrators_authorized_keys /grant "BUILTIN\\Administrators:(F)"; \
    $true

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

EXPOSE 22

ENTRYPOINT ["pwsh", "-Command"]
CMD ["Start-Service sshd; while ($true) { Start-Sleep -Seconds 3600 }"]
