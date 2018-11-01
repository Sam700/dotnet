$scriptName = 'SysPrep.ps1'

Write-Host
Write-Host "[$scriptName] System Preparation (sets SID)"
Write-Host
Write-Host "[$scriptName] ---------- start ----------"

$completeAction = $args[0]
if ($completeAction) {
    Write-Host "[$scriptName] completeAction : $completeAction (choices shutdown, quit or reboot)"
} else {
	$completeAction = 'reboot'
    Write-Host "[$scriptName] completeAction : $completeAction (default, choices shutdown, quit or reboot)"
}

$unattendFile = [Environment]::GetEnvironmentVariable('TEMP', 'user') + '\SysPrepUnattend.xml'
$EncodedText = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjx1bmF0dGVuZCB4bWxucz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTp1bmF0dGVuZCINCiAgICAgICAgeG1sbnM6d2NtPSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL1dNSUNvbmZpZy8yMDAyL1N0YXRlIg0KICAgICAgICB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIj4NCiAgICA8c2V0dGluZ3MgcGFzcz0iZ2VuZXJhbGl6ZSI+DQogICAgICAgIDxjb21wb25lbnQgbmFtZT0iTWljcm9zb2Z0LVdpbmRvd3MtUG5wU3lzcHJlcCINCiAgICAgICAgICAgICAgICBwcm9jZXNzb3JBcmNoaXRlY3R1cmU9ImFtZDY0Ig0KICAgICAgICAgICAgICAgIHB1YmxpY0tleVRva2VuPSIzMWJmMzg1NmFkMzY0ZTM1Ig0KICAgICAgICAgICAgICAgIGxhbmd1YWdlPSJuZXV0cmFsIiB2ZXJzaW9uU2NvcGU9Im5vblN4UyI+DQogICAgICAgICAgICA8UGVyc2lzdEFsbERldmljZUluc3RhbGxzPnRydWU8L1BlcnNpc3RBbGxEZXZpY2VJbnN0YWxscz4NCiAgICAgICAgPC9jb21wb25lbnQ+DQogICAgPC9zZXR0aW5ncz4NCiAgICA8c2V0dGluZ3MgcGFzcz0ic3BlY2lhbGl6ZSI+DQogICAgICAgIDxjb21wb25lbnQgbmFtZT0iTWljcm9zb2Z0LVdpbmRvd3MtRGVwbG95bWVudCINCiAgICAgICAgICAgICAgICBwcm9jZXNzb3JBcmNoaXRlY3R1cmU9ImFtZDY0Ig0KICAgICAgICAgICAgICAgIHB1YmxpY0tleVRva2VuPSIzMWJmMzg1NmFkMzY0ZTM1Ig0KICAgICAgICAgICAgICAgIGxhbmd1YWdlPSJuZXV0cmFsIiB2ZXJzaW9uU2NvcGU9Im5vblN4UyI+DQogICAgICAgICAgICA8UnVuU3luY2hyb25vdXM+DQogICAgICAgICAgICAgICAgPFJ1blN5bmNocm9ub3VzQ29tbWFuZCB3Y206YWN0aW9uPSJhZGQiPg0KICAgICAgICAgICAgICAgICAgICA8RGVzY3JpcHRpb24+RGlzYWJsZSBjcmVhdGUgdXNlciBhY2NvdW50PC9EZXNjcmlwdGlvbj4NCiAgICAgICAgICAgICAgICAgICAgPFBhdGg+cmVnIGFkZCBIS0xNXFNvZnR3YXJlXE1pY3Jvc29mdFxXaW5kb3dzXEN1cnJlbnRWZXJzaW9uXFNldHVwXE9PQkUgL3YgVW5hdHRlbmRDcmVhdGVkVXNlciAvdCBSRUdfRFdPUkQgL2QgMSAvZjwvUGF0aD4NCiAgICAgICAgICAgICAgICAgICAgPE9yZGVyPjE8L09yZGVyPg0KICAgICAgICAgICAgICAgIDwvUnVuU3luY2hyb25vdXNDb21tYW5kPg0KICAgICAgICAgICAgICAgIDxSdW5TeW5jaHJvbm91c0NvbW1hbmQgd2NtOmFjdGlvbj0iYWRkIj4NCiAgICAgICAgICAgICAgICAgICAgPERlc2NyaXB0aW9uPkVuYWJsZSBXaW5STTwvRGVzY3JpcHRpb24+DQoJCQkJICAgIDxDcmVkZW50aWFscz4NCgkJCQkJCTxVc2VybmFtZT52YWdyYW50PC9Vc2VybmFtZT4NCgkJCQkJCTxQYXNzd29yZD52YWdyYW50PC9QYXNzd29yZD4NCgkJCQkgICAgPC9DcmVkZW50aWFscz4NCiAgICAgICAgICAgICAgICAgICAgPE9yZGVyPjE8L09yZGVyPg0KICAgICAgICAgICAgICAgICAgICA8UGF0aD5jbWQgL2Mgd2lucm0gcXVpY2tjb25maWcgLXEgLXRyYW5zcG9ydDpodHRwPC9QYXRoPg0KICAgICAgICAgICAgICAgIDwvUnVuU3luY2hyb25vdXNDb21tYW5kPiAgICAgICAgICAgIA0KCQkJPC9SdW5TeW5jaHJvbm91cz4NCiAgICAgICAgPC9jb21wb25lbnQ+DQogICAgICAgIDxjb21wb25lbnQgbmFtZT0iTWljcm9zb2Z0LVdpbmRvd3MtU2hlbGwtU2V0dXAiDQogICAgICAgICAgICAgICAgcHJvY2Vzc29yQXJjaGl0ZWN0dXJlPSJhbWQ2NCINCiAgICAgICAgICAgICAgICBwdWJsaWNLZXlUb2tlbj0iMzFiZjM4NTZhZDM2NGUzNSINCiAgICAgICAgICAgICAgICBsYW5ndWFnZT0ibmV1dHJhbCIgdmVyc2lvblNjb3BlPSJub25TeFMiPg0KICAgICAgICAgICAgPFJlZ2lzdGVyZWRPd25lcj5XMks4UjI8L1JlZ2lzdGVyZWRPd25lcj4NCiAgICAgICAgICAgIDxSZWdpc3RlcmVkT3JnYW5pemF0aW9uPkFDTUUgQ29ycC48L1JlZ2lzdGVyZWRPcmdhbml6YXRpb24+DQogICAgICAgICAgICA8VGltZVpvbmU+TmV3IFplYWxhbmQgU3RhbmRhcmQgVGltZTwvVGltZVpvbmU+DQogICAgICAgICAgICA8Q29tcHV0ZXJuYW1lPio8L0NvbXB1dGVybmFtZT4NCiAgICAgICAgICAgIDxPT0JFPg0KICAgICAgICAgICAgICAgIDxIaWRlRVVMQVBhZ2U+dHJ1ZTwvSGlkZUVVTEFQYWdlPg0KICAgICAgICAgICAgICAgIDxOZXR3b3JrTG9jYXRpb24+T3RoZXI8L05ldHdvcmtMb2NhdGlvbj4NCiAgICAgICAgICAgICAgICA8UHJvdGVjdFlvdXJQQz4yPC9Qcm90ZWN0WW91clBDPg0KICAgICAgICAgICAgICAgIDxTa2lwVXNlck9PQkU+dHJ1ZTwvU2tpcFVzZXJPT0JFPg0KICAgICAgICAgICAgPC9PT0JFPg0KICAgICAgICA8L2NvbXBvbmVudD4NCiAgICA8L3NldHRpbmdzPg0KICAgIDxzZXR0aW5ncyBwYXNzPSJvb2JlU3lzdGVtIj4NCiAgICAgICAgPGNvbXBvbmVudCBuYW1lPSJNaWNyb3NvZnQtV2luZG93cy1JbnRlcm5hdGlvbmFsLUNvcmUiDQogICAgICAgICAgICAgICAgcHJvY2Vzc29yQXJjaGl0ZWN0dXJlPSJhbWQ2NCINCiAgICAgICAgICAgICAgICBwdWJsaWNLZXlUb2tlbj0iMzFiZjM4NTZhZDM2NGUzNSINCiAgICAgICAgICAgICAgICBsYW5ndWFnZT0ibmV1dHJhbCIgdmVyc2lvblNjb3BlPSJub25TeFMiPg0KICAgICAgICAgICAgPElucHV0TG9jYWxlPmVuLU5aPC9JbnB1dExvY2FsZT4NCiAgICAgICAgICAgIDxTeXN0ZW1Mb2NhbGU+ZW4tTlo8L1N5c3RlbUxvY2FsZT4NCiAgICAgICAgICAgIDxVSUxhbmd1YWdlPmVuLU5aPC9VSUxhbmd1YWdlPg0KICAgICAgICAgICAgPFVzZXJMb2NhbGU+ZW4tTlo8L1VzZXJMb2NhbGU+DQogICAgICAgIDwvY29tcG9uZW50Pg0KICAgIDwvc2V0dGluZ3M+DQo8L3VuYXR0ZW5kPg=='
$ByteArray = [System.Convert]::FromBase64String($EncodedText)
[System.IO.File]::WriteAllBytes("$unattendFile", $ByteArray)

Write-Host "[$scriptName] Asynchronous Sysem Preparation ..."
Write-Host "[$scriptName] C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /quiet /unattend:$unattendFile /$completeAction"
$process = Start-Process -FilePath 'C:\Windows\System32\Sysprep\Sysprep.exe' -ArgumentList "/generalize /oobe /quiet /unattend:$unattendFile /$completeAction" -PassThru

sleep 15

Write-Host "[$scriptName] ---------- stop -----------"
Write-Host