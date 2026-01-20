FROM mcr.microsoft.com/windows/server:ltsc2022

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
RUN choco install -y --no-progress powershell-core git docker-cli docker-compose 7zip curl openssl; \
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

ENTRYPOINT ["pwsh"]
