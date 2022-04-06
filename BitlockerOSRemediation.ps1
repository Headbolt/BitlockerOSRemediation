###############################################################################################################
#
# ABOUT THIS PROGRAM
#
#   BitlockerOSRemediation.ps1
#   https://github.com/Headbolt/BitlockerOSRemediation
#
#   This script was designed to Enforce Bitlocker Encryption of a Machine's OS Disk 
#	and attempt to Back-Up the Keys Azure AD and the AD DS machine Object.
#
#	Intended use is in Microsoft Endpoint Manager, as the "Remediate" half of a Proactive Remediation Script
#
###############################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 06/04/2022
#
#   - 06/04/2022 - V1.0 - Created by Headbolt, with assistance from CS 
#
$WarningPreference = 'SilentlyContinue'
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
$osVolMountPoint=( (Get-BitlockerVolume | where-object {$_.VolumeType -eq 'OperatingSystem'}).MountPoint )
$osVolRecPassKeyProtectorIDcurrent=( (Get-BitlockerVolume | where-object {$_.VolumeType -eq 'OperatingSystem'}).KeyProtector | select -ExpandProperty KeyProtectorID )
Write-Host "Removing Pre-Existing Key Protectors for Volume $osVolMountPoint"
Write-Host "Running Command"
Write-Host ""
Write-Host "$osVolRecPassKeyProtectorIDcurrent | Remove-BitLockerKeyProtector -MountPoint $osVolMountPoint | OUT-NULL"
$osVolRecPassKeyProtectorIDcurrent | Remove-BitLockerKeyProtector -MountPoint $osVolMountPoint | OUT-NULL
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
Write-Host "Adding Recovery Password Key Protector for Volume $osVolMountPoint"
Write-Host "Running Command"
Write-Host ""
Write-Host "Add-BitLockerKeyProtector -MountPoint $osVolMountPoint -RecoveryPasswordProtector -WarningAction SilentlyContinue | OUT-NULL"
Write-Host ""
Add-BitLockerKeyProtector -MountPoint $osVolMountPoint -RecoveryPasswordProtector -WarningAction SilentlyContinue | OUT-NULL
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
$osVolRecPassKeyProtectorIDnew=( (Get-BitlockerVolume | where-object {$_.VolumeType -eq 'OperatingSystem'}).KeyProtector | select -ExpandProperty KeyProtectorID )
Write-Host "Backing Up Key Protector to Azure AD"
Write-Host "Running Command"
Write-Host ""
Write-Host "BackupToAAD-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorIDnew | OUT-NULL"
#
BackupToAAD-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorIDnew | OUT-NULL
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
Write-Host "Testing Secure Channel"
Write-Host ""
#
if (Test-ComputerSecureChannel)
{
	Write-Host "Secure Channel Verified"
	#
	Write-Host "Backing Up Key Protector to AD DS"
	Write-Host "Running Command"
	Write-Host ""
	Write-Host "Backup-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorIDnew | OUT-NULL"
	#
	Backup-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorIDnew | OUT-NULL
}
else
{
	Write-Host "Secure Channel Verification Failed, Cannot Write to AD DS"
}
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
Write-Host "Enabling Bitlocker on Volume $osVolMountPoint"
Write-Host "Running Command"
Write-Host ""
Write-Host "Enable-Bitlocker -MountPoint $osVolMountPoint -EncryptionMethod Aes128 -TpmProtector -SkipHardwareTest -WarningAction SilentlyContinue | OUT-NULL"
#
Enable-Bitlocker -MountPoint $osVolMountPoint -EncryptionMethod Aes128 -TpmProtector -SkipHardwareTest -WarningAction SilentlyContinue | OUT-NULL
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
Write-Host "END"
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
