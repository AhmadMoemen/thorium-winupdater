﻿If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process
  $User = [Environment]::UserName
  $Script = $MyInvocation.MyCommand.Path
  Start-Process powershell.exe -Verb RunAs "-ExecutionPolicy RemoteSigned -File `"$PSCommandPath`" `"${User}`""
  Exit
}

$Action   = New-ScheduledTaskAction -Execute "$PSScriptRoot\LibreWolf-WinUpdater.exe" -Argument "/Scheduled"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable
$4Hours   = New-ScheduledTaskTrigger -Once -At (Get-Date -Minute 0 -Second 0).AddHours(1) -RepetitionInterval (New-TimeSpan -Hours 4)
$AtLogon  = New-ScheduledTaskTrigger -AtLogOn
$AtLogon.Delay = 'PT1M'
$User     = If ($Args[0]) {$Args[0]} Else {[Environment]::UserName}

Register-ScheduledTask -TaskName "LibreWolf WinUpdater ($User)" -Action $Action -Settings $Settings -Trigger $4Hours,$AtLogon -User $User -RunLevel Highest –Force
Write-Output Done.
[Console]::ReadKey()