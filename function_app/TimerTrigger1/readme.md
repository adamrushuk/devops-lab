# TimerTrigger - PowerShell

The `TimerTrigger` makes it incredibly easy to have your functions executed on a schedule. This sample demonstrates a simple use case of calling your function every 5 minutes.

## How it works

For a `TimerTrigger` to work, you provide a schedule in the form of a [cron expression](https://en.wikipedia.org/wiki/Cron#CRON_expression)(See the link for full details). A cron expression is a string with 6 separate expressions which represent a given schedule via patterns. The pattern we use to represent every 5 minutes is `0 */5 * * * *`. This, in plain text, means: "When seconds is equal to 0, minutes is divisible by 5, for any hour, day of the month, month, day of the week, or year".

## Local Testing

Full instructions here: https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs-code?tabs=csharp#run-functions-locally

Ensure the [Azure Functions Core Tools are installed](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#install-the-azure-functions-core-tools), 

```powershell
# install prereqs
choco install dotnetcore-sdk
choco install azure-functions-core-tools-3 --params "'/x64'"
```

then follow the steps below to run and test
the code locally:

```powershell
<# set to use PowerShell 7
$env:FUNCTIONS_WORKER_RUNTIME_VERSION = '~7'
#>
# enter function directory
cd function_app

# install extensions
func extensions install

# start function
func host start
```
