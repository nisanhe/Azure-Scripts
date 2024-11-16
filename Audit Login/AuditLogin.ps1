# Connect to Microsoft Graph API with the required scopes
Connect-MgGraph -NoWelcome -Scopes "User.Read.all", "AuditLog.Read.All", "Directory.Read.All"
Write-Host "after connect" # Display a message after the connection is established

# Define variables: current date and filenames for saving the results
$dt = Get-Date
$OutFile = ".\NoLogin.CSV" # Filename for saving the results
$OutFileDT = ".\NoLogin_$($dt.ToString('yyyy.MM.dd.HH.mm')).CSV" # Additional filename with the current date and time

# Import the list of users from a CSV file
$Users = Import-Csv $OutFile
$NewUsers = @() # Create an empty list to store users who have never signed in
Write-Host "start for each.." # Display a message before starting the loop
$startTime = Get-Date # Start time tracking for execution

# Loop through each user in the list
foreach ($User in $Users) {
    $Id = $User.Id # Store the user's ID in a variable
    # Check the user's sign-in history, sorted by the most recent date
    $SignedIn = @(Get-MgBetaAuditLogSignIn -Filter "UserId eq '$Id'" -Sort "createdDateTime DESC" -Top 2)
    if ($SignedIn.Count -lt 1) {
        # If there are no sign-in records
        Write-Host "$user" # Display the user's details
        $NewUsers += $User # Add the user to the list of users who have never signed in
        Write-Host ($NewUsers.count) # Display the count of users added
    }
}

# $endTime = Get-Date # End time tracking for execution
# $executionTime = New-TimeSpan -Start $startTime -End $endTime # Calculate the execution time

# Export the list of users who have never signed in to two CSV files
$NewUsers | Export-Csv -Encoding UTF8 $OutFile -NoTypeInformation
$NewUsers | Export-Csv -Encoding UTF8 $OutFileDT -NoTypeInformation
