@echo off
echo ------------------ Start of script.
time /t

echo ------------------ Loading parameters
call %~dp0parameters.cmd

echo ------------------ Checking parameters
if "%ICHANGEDTHINGS%"=="No" goto End

echo ------------------ Creating resource group
call az group create --name %RGNAME% --location %LOCATION%
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Creating managed SQL Server instance
call az sql server create --name %SQLSERVERNAME% --resource-group %RGNAME% --location %LOCATION% --admin-user %SQLADMIN% --admin-password %SQLPASSWORD%
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Creating SQL firewall rule
call az sql server firewall-rule create --resource-group %RGNAME% --server %SQLSERVERNAME% --name AllowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Creating SQL database
call az sql db create --resource-group %RGNAME% --server %SQLSERVERNAME% --name %DATABASENAME% --service-objective S0
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Creating connection string
set CONNECTIONSTRING=Server=tcp:%SQLSERVERNAME%.database.windows.net,1433;Initial Catalog=%DATABASENAME%;User ID=%SQLADMIN%;Password=%SQLPASSWORD%;Encrypt=true;Connection Timeout=30;
time /t

echo ------------------ Configuring GIT user for deployment
call az webapp deployment user set --user-name %GITUSERNAME% --password %GITPASSWORD%
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Creating app service plan
call az appservice plan create --name %APPSERVICEPLAN% --resource-group %RGNAME% --sku B1 --is-linux
if ERRORLEVEL 1 goto End
time /t

echo ------------------ (Re)creating front end web app
call az webapp delete --resource-group %RGNAME% --name %FEWEBAPP%
call az webapp create --resource-group %RGNAME% --plan %APPSERVICEPLAN% --name %FEWEBAPP% --runtime "DOTNETCORE|2.1" --deployment-local-git
if ERRORLEVEL 1 goto End
time /t

echo ------------------ (Re)creating back end web app
call az webapp delete --resource-group %RGNAME% --name %BEWEBAPP%
call az webapp create --resource-group %RGNAME% --plan %APPSERVICEPLAN% --name %BEWEBAPP% --runtime "DOTNETCORE|2.1" --deployment-local-git
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring front end connection string
call az webapp config connection-string set --resource-group %RGNAME% --name %FEWEBAPP% --settings MyDbConnection="%CONNECTIONSTRING%" --connection-string-type SQLServer
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring back end connection string
call az webapp config connection-string set --resource-group %RGNAME% --name %BEWEBAPP% --settings MyDbConnection="%CONNECTIONSTRING%" --connection-string-type SQLServer
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring front end app as "Production"
call az webapp config appsettings set --name %FEWEBAPP% --resource-group %RGNAME% --settings ASPNETCORE_ENVIRONMENT="Production"
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring back end app as "Production"
call az webapp config appsettings set --name %BEWEBAPP% --resource-group %RGNAME% --settings ASPNETCORE_ENVIRONMENT="Production"
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Resetting local GIT configuration
rmdir /s /q .git
rmdir /s /q .github

git init
git add .
git commit -m "Initial commit"
time /t

echo ------------------ Restoring local libraries and database configuration
dotnet restore
dotnet ef database update
time /t

echo ------------------ Adding front end to local GIT configuration
git remote add frontend https://%GITUSERNAME%:%GITPASSWORD%@%FEWEBAPP%.scm.azurewebsites.net/%FEWEBAPP%.git
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Adding back end to local GIT configuration
git remote add backend https://%GITUSERNAME%:%GITPASSWORD%@%BEWEBAPP%.scm.azurewebsites.net/%BEWEBAPP%.git
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Deploying code to front end
git push frontend master
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Deploying code to back end
git push backend master
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring front end web app logging
call az webapp log config --name %FEWEBAPP% --resource-group %RGNAME% --docker-container-logging filesystem
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Configuring back end web app logging
call az webapp log config --name %BEWEBAPP% --resource-group %RGNAME% --docker-container-logging filesystem
if ERRORLEVEL 1 goto End
time /t

Rem Sample logging output commands
Rem call az webapp log tail --name %FEWEBAPP% --resource-group %RGNAME%
Rem call az webapp log tail --name %BEWEBAPP% --resource-group %RGNAME%

echo ------------------ Checking for existing Azure AD application for front end
Set FEAPPID=None
for /f delims^=^"^ tokens^=1 %%g in ('az ad app list --display-name %FEWEBAPP% --query "[0].appId" --output tsv') do set FEAPPID=%%g
time /t

if "%FEAPPID%"=="None" (
    echo ------------------ Creating new Azure AD application for front end
    call az ad app create --display-name %FEWEBAPP% --required-resource-accesses @manifest.json --reply-urls https://%FEWEBAPP%.azurewebsites.net/.auth/login/aad/callback http://%FEWEBAPP%.azurewebsites.net/.auth/login/aad/callback
    for /f delims^=^"^ tokens^=1 %%g in ('az ad app list --display-name %FEWEBAPP% --query "[0].appId" --output tsv') do set FEAPPID=%%g
    if ERRORLEVEL 1 goto End
    time /t
)

echo ------------------ Configuring Azure AD authentication for front end
call az webapp auth update -g %RGNAME% -n %FEWEBAPP% --enabled true --action LoginWithAzureActiveDirectory --aad-allowed-token-audiences https://%FEWEBAPP%.azurewebsites.net/.auth/login/aad/callback --aad-client-id %FEAPPID%
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Launching browser to show app
start http://%FEWEBAPP%.azurewebsites.net

:End
echo ------------------ End of script.
time /t

