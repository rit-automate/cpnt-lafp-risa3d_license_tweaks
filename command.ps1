## var setup
$Risa3dHklmPath = 'HKLM:\SOFTWARE\RISA Technologies\RISA-3D'
$LicenseTypeListDesiredValue = 'Network,Cloud'
## test is RISA is even installed
if((Test-Path -Path $Risa3dHklmPath) -ne $true){
    Write-Host "Didn't find RISA-3D registry path at [$($Risa3dHklmPath)]"
    exit 1
}
## set License Type List value for LM reg
$LicenseTypeListCurrentValue = Get-ItemPropertyValue -Path $Risa3dHklmPath -Name 'License Type List'
Write-Host "Current License Type List value [$($LicenseTypeListCurrentValue)]"
if($LicenseTypeListCurrentValue -ne $LicenseTypeListDesiredValue){
    try{
        New-ItemProperty -Path $Risa3dHklmPath -Name 'License Type List' -Value $LicenseTypeListDesiredValue -Force
    }
    catch{
        Write-Host "Failed to set License Type List Desired Value"
    }
}
## set License Type List value for usr reg
## Load all users on PCs current user registry hives Source:[https://www.pdq.com/blog/modifying-the-registry-users-powershell/]
# Regex pattern for SIDs
# Get Username, SID, and location of ntuser.dat for all users
$ProfileList = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {($_.PsChildName.Length -gt 8) -And $_.PsChildName -NotMatch "_Classes"} | 
    Select-Object  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}

Write-Host "Located all user profile registry hives`n"
$ProfileList | Format-List
# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = Get-ChildItem "Registry::HKEY_USERS" | Where-Object {($_.PsChildName.Length -gt 8) -And $_.PsChildName -NotMatch "_Classes"} | Select-Object @{name="SID";expression={$_.PSChildName}}
Write-Host "`nHives currently in use`n"
$LoadedHives | Format-List
# Get all users that are not currently logged
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select-Object @{name="SID";expression={$_.InputObject}}, UserHive, Username
Write-Host "`nHives not in use`n"
# Loop through each profile on the machine
foreach ($item in $ProfileList) {
    # Load User ntuser.dat if it's not already loaded
    if ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }
    #####################################################################
    # This is where you can read/modify a users portion of the registry 
    # use this path Registry::HKEY_USERS\$($Item.SID)\
    #####################################################################
    if(Test-Path "Registry::HKEY_USERS\$($Item.SID)\SOFTWARE\RISA Technologies\RISA-3D"){
        Write-Host "Found registry entries for $($Item.Username), applying registry patches."
        New-ItemProperty -Path "Registry::HKEY_USERS\$($Item.SID)\SOFTWARE\RISA Technologies\RISA-3D" 'License Type List' -Value $LicenseTypeListDesiredValue -Force | Out-Null
    }
    else{
        Write-Host "Registry entries for $($Item.Username), NOT FOUND, skipping."
    }
    #####################################################################
    # Unload ntuser.dat        
    IF ($item.SID -in $UnloadedHives.SID) {
        ### Garbage collection and closing of ntuser.dat ###
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}
Write-Host "Patched all current user registry hives for product!"
exit 0