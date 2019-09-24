Function Connect-EXOnline {
    Write-Output "Getting the Exchange Online cmdlets"
    Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse).FullName | ?{ $_ -notmatch "_none_" } | select -First 1)
    $EXOSession = New-ExoPSSession -UserPrincipalName $UPN
    Import-PSSession $EXOSession -AllowClobber
}
 
Connect-EXOnline
$domains = Get-AcceptedDomain
$mailboxes = Get-Mailbox -ResultSize Unlimited
Write-Host "Rules are written to C:\externalautofowarding.csv"
 
foreach ($mailbox in $mailboxes) {
 
    $forwardingRules = $null
    Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)" -foregroundColor Green
    $rules = get-inboxrule -Mailbox $mailbox.primarysmtpaddress
     
    $forwardingRules = $rules | Where-Object {$_.forwardto -or $_.forwardasattachmentto -or $_.redirectto}
 
    foreach ($rule in $forwardingRules) {
        $recipients = @()
        $recipients = $rule.ForwardTo | Where-Object {$_ -match "SMTP"}
        $recipients += $rule.ForwardAsAttachmentTo | Where-Object {$_ -match "SMTP"}
        $recipients += $rule.RedirectTo | Where-Object {$_ -match "SMTP"}
     
        $externalRecipients = @()
 
        foreach ($recipient in $recipients) {
            $email = ($recipient -split "SMTP:")[1].Trim("]")
            $domain = ($email -split "@")[1]
 
            if ($domains.DomainName -notcontains $domain) {
                $externalRecipients += $email
            }    
        }
 
        if ($externalRecipients) {
            $extRecString = $externalRecipients -join ", "
            Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow
 
            $ruleHash = $null
            $ruleHash = [ordered]@{
                PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                DisplayName        = $mailbox.DisplayName
                RuleId             = $rule.Identity
                RuleName           = $rule.Name
                RuleDescription    = $rule.Description
                ExternalRecipients = $extRecString
            }
            $ruleObject = New-Object PSObject -Property $ruleHash
            $ruleObject | Export-Csv C:\externalautofowarding.csv -NoTypeInformation -Append
        }
    }
}
