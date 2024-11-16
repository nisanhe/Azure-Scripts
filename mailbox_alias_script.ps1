# Import the Exchange Online PowerShell module
Import-Module ExchangeOnlineManagement

# Connect to your Microsoft 365 account
Connect-ExchangeOnline

try {
    # Get all mailboxes in the organization and their aliases
    $mailboxes = Get-EXOMailbox -ResultSize Unlimited | Select-Object UserPrincipalName, DisplayName, EmailAddresses

    # Get all aliases, UserPrincipalName, and DisplayName
    $aliases = foreach ($mailbox in $mailboxes) {
        $mailbox.EmailAddresses | Where-Object { $_ -like "smtp:*" } | ForEach-Object {
            [PSCustomObject]@{
                UserPrincipalName = $mailbox.UserPrincipalName
                DisplayName       = $mailbox.DisplayName -replace '\?', ''
                Alias             = $_ -replace "smtp:", ""
            }
        }
    }

    # Set the path to save the CSV file
    $csvFilePath = "C:\temp\alias.csv"

    # Export the results to a CSV file with UTF-8 encoding
    $aliases | Sort-Object UserPrincipalName | Export-Csv -Path $csvFilePath -NoTypeInformation -Encoding UTF8

    Write-Host "Aliases exported to $csvFilePath successfully."
}
catch {
    Write-Warning "An error occurred: $($_.Exception.Message)"
}