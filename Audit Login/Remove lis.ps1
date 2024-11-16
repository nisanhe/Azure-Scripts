Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

$OutFile = ".\NoLogin.CSV"
$Users = Import-Csv $OutFile

Foreach ($User in $Users) {
    $SKU = (Get-MgUser -UserId $User.Id -Property "AssignedLicenses,LicenseDetails").AssignedLicenses.SkuId
    Set-MgUserLicense -UserId $User.Id -RemoveLicenses @($SKU) -AddLicenses @{}
}

Disconnect-Graph