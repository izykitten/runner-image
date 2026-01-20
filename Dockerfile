FROM mcr.microsoft.com/windows/server:ltsc2025

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PowerShell 7
RUN Invoke-WebRequest -UseBasicParsing -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.4.7/PowerShell-7.4.7-win-x64.zip -OutFile pwsh.zip; \
    Expand-Archive pwsh.zip -DestinationPath 'C:\Program Files\PowerShell\7'; \
    Remove-Item pwsh.zip; \
    setx /M PATH \"C:\Program Files\PowerShell\7;$env:PATH\"

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Docker CLI
RUN Invoke-WebRequest -UseBasicParsing -Uri https://download.docker.com/win/static/stable/x86_64/docker-29.1.4.zip -OutFile docker.zip; \
    Expand-Archive docker.zip -DestinationPath C:\; \
    Remove-Item docker.zip

# Git
RUN Invoke-WebRequest -UseBasicParsing -Uri https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.2/MinGit-2.47.1.2-64-bit.zip -OutFile git.zip; \
    Expand-Archive git.zip -DestinationPath 'C:\Program Files\Git'; \
    Remove-Item git.zip

RUN setx /M PATH \"C:\docker;C:\Program Files\Git\cmd;$env:PATH\"
