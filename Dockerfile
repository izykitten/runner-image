FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install PowerShell 7, Git, Docker CLI, and common CI tools
RUN choco install -y --no-progress powershell-core git docker-cli 7zip curl; \
    git config --system credential.helper manager; \
    choco clean --yes --all; \
    Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\cache\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\logs\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\ProgramData\\Package` Cache\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Windows\\Temp\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Windows\\SoftwareDistribution\\Download\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet\\Cache\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet\\v3-cache\\* -ErrorAction SilentlyContinue; \
    Remove-Item -Force -Recurse C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet\\plugins-cache\\* -ErrorAction SilentlyContinue

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

CMD ["pwsh"]
