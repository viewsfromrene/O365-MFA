Function Connect-EXOnline {
    Write-Output "Getting the Exchange Online cmdlets"
    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse).FullName | ?{ $_ -notmatch "_none_" } | select -First 1)
    $EXOSession = New-ExoPSSession -UserPrincipalName $UPN
    Import-PSSession $EXOSession -AllowClobber
}

Connect-EXOnline
$userfilter = Read-Host -Prompt "Enter user to find (leave blank for all)"

$user = @{}
if([string]::IsNullOrEmpty($userfilter) -eq $false)
{$user = @{Identity = $userfilter}
}

$UserMailboxStats = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited @user | Get-MailboxStatistics
$UserMailboxStats | Add-Member -MemberType ScriptProperty -Name TotalItemSizeInBytes -Value {$this.TotalItemSize -replace "(.*\()|,| [a-z]*\)", ""}
$output = $UserMailboxStats | Select-Object DisplayName, TotalItemSizeInBytes,@{Name="TotalItemSize (GB)"; Expression={[math]::Round($_.TotalItemSizeInBytes/1GB,2)}}
$output | Export-Csv C:\Mailboxstats.csv -NoTypeInformation -Append -Force
