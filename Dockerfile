FROM mcr.microsoft.com/windows/servercore:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey and PowerShell 7
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
    choco install -y --no-progress powershell-core; \
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue \
        C:\ProgramData\chocolatey\cache, \
        C:\ProgramData\chocolatey\logs, \
        'C:\ProgramData\Package Cache', \
        C:\Windows\Temp\*, \
        C:\Windows\SoftwareDistribution\Download\*, \
        C:\Users\ContainerAdministrator\AppData\Local\Temp\*, \
        C:\Users\ContainerAdministrator\AppData\Local\NuGet

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install tools
RUN choco install -y --no-progress git docker-cli docker-buildx 7zip curl; \
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue \
        C:\ProgramData\chocolatey\cache, \
        C:\ProgramData\chocolatey\logs, \
        'C:\ProgramData\Package Cache', \
        C:\Windows\Temp\*, \
        C:\Windows\SoftwareDistribution\Download\*, \
        C:\Users\ContainerAdministrator\AppData\Local\Temp\*, \
        C:\Users\ContainerAdministrator\AppData\Local\NuGet

ENTRYPOINT ["pwsh"]
