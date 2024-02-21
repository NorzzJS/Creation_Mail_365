####################################################################################
#                                                                                  #
#  Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force                  #
#  Import-Module Microsoft.Graph                                                   #
#  Connect-MgAccount -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"       #
#                                                                                  #
####################################################################################

####################################################################################
#                                                                                  #
#  Connect-MsolService                                                             #
#  Connect-MgGraph                                                                 #
#  94763226-9b3c-4e75-a931-5c89701abe66 = SkuId licences A1                        #
#                                                                                  #
####################################################################################


$users = Import-Csv -Path #"C:...\.csv"
foreach ($user in $users) {
    try {
        if ($user.UsageLocation.Length -ne 2) {
            Write-Host "UsageLocation invalide pour l'utilisateur $($user.UserPrincipalName)."
            continue
        }

        $newUser = New-MsolUser -UserPrincipalName $user.UserPrincipalName `
                                -DisplayName $user.DisplayName `
                                -FirstName $user.FirstName `
                                -LastName $user.LastName `
                                -Password $user.Password `
                                -ForceChangePassword $false `
                                -UsageLocation $user.UsageLocation `
                                -Office $user.Office

        # Temps de création des comptes
        Start-Sleep -Seconds 20

        # Définir le SkuId /\ Get-MsolAccountSku
        $skuId = "94763226-9b3c-4e75-a931-5c89701abe66"
        Set-MgUserLicense -UserId $newUser.UserPrincipalName -AddLicenses @{SkuId = $skuId} -RemoveLicenses @()
        Set-MsolUser -UserPrincipalName $newUser.UserPrincipalName -PasswordNeverExpires $true
    }
    catch {
        Write-Host "Erreur lors de la création ou de l'attribution de la licence pour l'utilisateur $($user.UserPrincipalName): $_"
    }
}   
