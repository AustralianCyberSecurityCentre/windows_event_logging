##########################################
# Enable auditing of WMI activity.
# Query ACLs with (Invoke-WmiMethod -EnableAllPrivileges -Namespace "root\cimv2" -Path __SystemSecurity -Name GetSecurityDescriptor).Descriptor.SACL
##########################################

$Err = ""
$ErrBool = $false
$Namespaces = @(("root\cimv2","262146","64", "S-1-1-0"), #Successful Execute, Edit Security. Everyone, not incl. sub-namespaces.
                ("root\cimv2","1","64", "S-1-5-4"), #Successful Read. Interactive, not incl. sub-namespaces.
                ("root\cimv2","1","64", "S-1-5-2"), #Successful Read. Network, not incl. sub-namespaces.
                ("root\cimv2","1","64", "S-1-5-3"), #Successful Read. Batch, not incl. sub-namespaces.
                ("root\SecurityCenter","262145", "66", "S-1-1-0"), #Successful Read, Edit Security. Everyone, incl. sub-namespaces.
                ("root\SecurityCenter2", "262145", "66", "S-1-1-0"), #Successful Read, Edit Security. Everyone, incl. sub-namespaces.
                ("root\subscription","262174", "66", "S-1-1-0"), #Successful Full Write, Parial Write, Provider Write, Edit Security. Everyone, incl. sub-namespaces.
                ("root\default","262175", "66", "S-1-1-0")) #Successful Read, Execute, Full Write, Parial Write, Provider Write, Edit Security. Everyone, incl. sub-namespace.

ForEach($Item in $Namespaces){
    Try{
        $Err = ""
        #Get the Security Descriptor for the Namespace
        $return = Invoke-WmiMethod -Namespace $Item[0] -Path __SystemSecurity -Name GetSecurityDescriptor -EV Err -EA SilentlyContinue
        If($Err){
            "Error performing query of Namespace (" + $Item[0] + ") Security Descriptor." | Write-Debug
            $ErrBool = $true
            continue
        }
        #Get descriptor object
        $Descriptor = $return.Descriptor
        #Get ACE information
        $ACE = ([WMIClass]"Win32_ACE").CreateInstance()
        $ACE.AccessMask=[int]$Item[1]
        $ACE.AceFlags=[int]$Item[2]
        #Audit System and configure changes
        $ACE.AceType=0x2
        $Trustee = ([WMIClass]"Win32_Trustee").CreateInstance()
        $Trustee.SidString = $Item[3]
        $ACE.Trustee = $Trustee
        $Descriptor.SACL += $ACE.psobject.immediateBaseObject
        #Apply changes
        $return = Invoke-WmiMethod -EnableAllPrivileges -Namespace $Item[0] -Path __SystemSecurity -Name SetSecurityDescriptor -ArgumentList $Descriptor.psobject.immediateBaseObject -EV Err -EA SilentlyContinue
        If($Err){
            "Error encountered when updating permissions for Namespace (" + $Item[0] + ")." | Write-Debug
            $ErrBool = $true
            continue
        }
    } Catch {
        $_.Exception.Message | Write-Debug
        $ErrBool = $true
        continue
    }
}

If($ErrBool){
    "Complete (with errors)." | Write-Debug
    return 1
} Else {
    "Complete." | Write-Debug
    return 0
}
