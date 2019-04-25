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

echo ------------------ Creating VM Scale Set
call az vmss create --resource-group %RGNAME% --name %SCALESETNAME% --image UbuntuLTS --upgrade-policy-mode automatic --authentication-type password --admin-username %ADMINUSERNAME% --admin-password %ADMINPASSWORD%
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Deploying nginx as an extension
echo {"fileUris":["https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx.sh"],"commandToExecute":"./automate_nginx.sh"} > %~dp0script.json
call az vmss extension set --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --resource-group %RGNAME% --vmss-name %SCALESETNAME% --settings @%~dp0script.json
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Deploying load balancer
call az network lb rule create --resource-group %RGNAME% --name %SCALESETNAME%-web --lb-name %SCALESETNAME%LB --backend-pool-name %SCALESETNAME%LBBEPool --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Finding load balancer public IP
for /f delims^=^"^ tokens^=1 %%g in ('az network public-ip show --resource-group %RGNAME% --name %SCALESETNAME%LBPublicIP --query "[ipAddress]" --output tsv') do set PIP=%%g
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Displaying instance list
call az vmss list-instances --resource-group %RGNAME% --name %SCALESETNAME% --output table
if ERRORLEVEL 1 goto End
time /t

echo ------------------ Launching browser to show app
start http://%PIP%

:End
echo ------------------ End of script.
time /t
