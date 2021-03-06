Param (
[string]$url,
[string]$pat,
[string]$pool,
[string]$agentName,
[string]$serviceAccount,
[string]$servicePassword,
[string]$deploymentgroup,
[string]$projectname,
[string]$mediaDirectory
)
$scriptName = 'installAgent.ps1'

# Common expression logging and error handling function, copied, not referenced to ensure atomic process
function executeExpression ($expression) {
	$error.clear()
	Write-Host "$expression"
	try {
		$output = Invoke-Expression $expression
	    if(!$?) { Write-Host "[$scriptName] `$? = $?"; exit 1 }
	} catch { echo $_.Exception|format-list -force; exit 2 }
    if (( $LASTEXITCODE ) -and ( $LASTEXITCODE -ne 0 )) { Write-Host "[$scriptName] `$LASTEXITCODE = $LASTEXITCODE "; exit $LASTEXITCODE }
    if ( $error[0] ) { Write-Host "[$scriptName] `$error[0] = $error"; exit 3 }
    return $output
}

Write-Host "[$scriptName] ---------- start ----------"
if ( $url ) {
	Write-Host "[$scriptName] url             : $url"
} else {
	Write-Host "[$scriptName] url             : (not supplied, will just extract the agent software)"
}
if ( $pat ) {
	Write-Host "[$scriptName] pat             : `$pat"
} else {
	Write-Host "[$scriptName] pat             : (not supplied)"
}
if ( $pool ) {
	Write-Host "[$scriptName] pool            : $pool"
} else {
	$pool = 'default'
	Write-Host "[$scriptName] pool            : $pool (not supplied, set to default, if Deployment Group is used, this will be ignored)"
}
if ( $agentName ) {
	Write-Host "[$scriptName] agentName       : $agentName"
} else {
	$agentName = "$env:COMPUTERNAME" 
	Write-Host "[$scriptName] agentName       : $agentName (not supplied, set to default)"
}

if ( $serviceAccount ) {
	Write-Host "[$scriptName] serviceAccount  : $serviceAccount"
} else {
	Write-Host "[$scriptName] serviceAccount  : (not supplied)"
}
if ( $servicePassword ) {
	Write-Host "[$scriptName] servicePassword : `$servicePassword"
} else {
	Write-Host "[$scriptName] servicePassword : (not supplied)"
}
if ( $deploymentgroup ) {
	Write-Host "[$scriptName] deploymentgroup : $deploymentgroup"
} else {
	Write-Host "[$scriptName] deploymentgroup : (not supplied)"
}
if ( $projectname ) {
	Write-Host "[$scriptName] projectname     : $projectname"
} else {
	if ( $deploymentgroup ) {
		Write-Host "[$scriptName] deploymentgroup ($deploymentgroup) supplied, therefore projectname required but not supplied, exit with `$LASTEXITCODE = 3"; exit 3
	} else {
		Write-Host "[$scriptName] projectname     : (not supplied)"
	}
}
if ( $mediaDirectory ) {
	Write-Host "[$scriptName] mediaDirectory  : $mediaDirectory"
} else {
	$mediaDirectory = 'C:\.provision'
	Write-Host "[$scriptName] mediaDirectory  : $mediaDirectory (not supplied, set to default)"
}

$version = '2.136.1'
Write-Host "[$scriptName] version         : $version"

$fullpath = 'C:\agent\config.cmd'
$workspace = $(pwd)

executeExpression 'Add-Type -AssemblyName System.IO.Compression.FileSystem'
$mediaFileName = "vsts-agent-win-x64-${version}.zip"

if (Test-Path "${mediaDirectory}\${mediaFileName}") {
	Write-Host "[$scriptName] Media ${mediaDirectory}\${mediaFileName} exists"
} else {
	Write-Host "[$scriptName] Download VSTS Agent (using TLS 1.1 or 1.2)"
	if (Test-Path $mediaDirectory) {
		Write-Host "[$scriptName] Media Directory $mediaDirectory exists"
	} else {
		$result = executeExpression "mkdir $mediaDirectory"
	}
	
	# As per guidance here https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
	$AllProtocols = [System.Net.SecurityProtocolType]'Tls11,Tls12'
	[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
	$mediaURL = "https://vstsagentpackage.azureedge.net/agent/${version}/${mediaFileName}"
	executeExpression "(New-Object System.Net.WebClient).DownloadFile('$mediaURL', '${mediaDirectory}\${mediaFileName}')"
}

Write-Host "`nExtract using default instructions from Microsoft"
if (Test-Path "C:\agent") {
	executeExpression "Remove-Item `"C:\agent`" -Recurse -Force"
}
$result = executeExpression "mkdir C:\agent"
Write-Host "`nCreated directory $result"
executeExpression "[System.IO.Compression.ZipFile]::ExtractToDirectory(`"$mediaDirectory\$mediaFileName`", `"C:\agent`")"

if ( $url ) {
	$argList = "--unattended --url $url --auth PAT"
	if ( $deploymentgroup ) {
		$argList += " --deploymentgroup --deploymentgroupname `"$deploymentgroup`" --projectname `"$projectname`""
	}
	
	Write-Host "`nUnattend configuration for VSTS with PAT authentication"
	if ( $serviceAccount.StartsWith('.\')) { 
		$serviceAccount = $serviceAccount.Substring(2) # Remove the .\ prefix
	}
	
	if ( $serviceAccount ) {
		$printList = "$argList --token `$pat --pool $pool --agent $agentName --replace --runasservice --windowslogonaccount $serviceAccount --windowslogonpassword `$servicePassword"
		$argList += " --token $pat --pool $pool --agent $agentName --replace --runasservice --windowslogonaccount $serviceAccount --windowslogonpassword $servicePassword"
	} else {
		$printList = "$argList --token `$pat --pool $pool --agent $agentName --replace"
		$argList += " --token $pat --pool $pool --agent $agentName --replace"
	}
	
	executeExpression "cd C:\agent"
	Write-Host "[$scriptName] Start-Process $fullpath -ArgumentList $printList -PassThru -Wait"
	$proc = Start-Process $fullpath -ArgumentList $argList -PassThru -Wait -NoNewWindow
	if ( $proc.ExitCode -ne 0 ) {
		Write-Host "`n[$scriptName] Error occured, listing last 40 lines of log $((Get-ChildItem C:\agent\_diag)[0].FullName)`n"
		Get-Content (Get-ChildItem C:\agent\_diag)[0].FullName -tail 40
		Write-Host "`n[$scriptName] Install Failed! Exit with `$LASTEXITCODE $($proc.ExitCode)`n"
	    exit $proc.ExitCode
	}

	if ( $serviceAccount ) {
        $agentService = get-service vstsagent*
        if ( $agentService ) {
        	Write-Host "[$scriptName] Set the service to delayed start"
        	executeExpression "sc.exe config $($agentService.name) start= delayed-auto"
        	executeExpression "Start-Service $($agentService.name)"
        } else {
        	Write-Host "[$scriptName] Service not found! Exiting with exit code 3345"
        	exit 3345
    	}
    } else {
    	Write-Host "`n[$scriptName] Service Account not supplied will not attempt to start`n"
    }

} else {
	Write-Host "`n[$scriptName] URL not supplied. Agent software extracted to C:\agent`n"
}

executeExpression "cd $workspace"
Write-Host "`n[$scriptName] ---------- stop -----------`n"
exit 0