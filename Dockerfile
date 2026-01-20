FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install PowerShell 7 with Windows PowerShell (no && yet)
RUN choco install -y --no-progress powershell-core; \
    if (Test-Path C:\\ProgramData\\chocolatey\\cache) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\cache -ErrorAction SilentlyContinue }; \
    if (Test-Path C:\\ProgramData\\chocolatey\\logs) { Remove-Item -Force -Recurse C:\\ProgramData\\chocolatey\\logs -ErrorAction SilentlyContinue }

# Switch remaining layers to PowerShell 7 so && is available
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install remaining tools and clean
RUN $cleanup = { \
        $paths = @( \
            'C:\\ProgramData\\chocolatey\\cache', \
            'C:\\ProgramData\\chocolatey\\logs', \
            'C:\\ProgramData\\Package Cache', \
            'C:\\Windows\\Temp', \
            'C:\\Windows\\SoftwareDistribution\\Download', \
            'C:\\Users\\ContainerAdministrator\\AppData\\Local\\Temp', \
            'C:\\Users\\ContainerAdministrator\\AppData\\Local\\NuGet' \
        ); \
        foreach ($p in $paths) { if (Test-Path $p) { Remove-Item -Force -Recurse $p -ErrorAction SilentlyContinue } } \
    }; \
    choco install -y --no-progress git docker-cli docker-buildx 7zip curl; \
    & $cleanup

ENTRYPOINT ["pwsh"]
