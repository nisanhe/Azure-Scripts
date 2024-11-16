Write-Host "Fetching Azure Active Directory Accounts..."
try {
    # Fetch all non-guest Azure AD users
    $users = Get-MsolUser -All | Where-Object { $_.UserType -ne "Guest" }
    Write-Host "Processing" $users.Count "accounts..."

    # Initialize the report list
    $report = [System.Collections.Generic.List[Object]]::new()

    foreach ($user in $users) {
        # Get MFA details
        $mfaState = $user.StrongAuthenticationRequirements.State
        $mfaPhone = $user.StrongAuthenticationUserDetails.PhoneNumber
        $defaultMfaMethod = ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true }).MethodType

        # Determine MFA status and method
        if ($mfaState -in @("Enforced", "Enabled")) {
            $methodUsed = switch ($defaultMfaMethod) {
                "OneWaySMS" { "One-way SMS" }
                "TwoWayVoiceMobile" { "Phone call verification" }
                "PhoneAppOTP" { "Hardware token or authenticator app" }
                "PhoneAppNotification" { "Authenticator app" }
                default { "Unknown method" }
            }
        }
        else {
            $mfaState = "Not Enabled"
            $methodUsed = "MFA Not Used"
        }

        # Add user details to the report
        $report.Add([PSCustomObject]@{
                User        = $user.UserPrincipalName
                Name        = $user.DisplayName
                MFAUsed     = $mfaState
                MFAMethod   = $methodUsed
                PhoneNumber = $mfaPhone
            })
    }

    # Output and save the report
    $reportFilePath = "c:\temp\MFAUsers.csv"
    $report
    | Sort-Object -Property Name
    | Export-Csv -Path $reportFilePath -NoTypeInformation -Encoding UTF8

    Write-Host "Report has been saved to $reportFilePath" -ForegroundColor Green
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
