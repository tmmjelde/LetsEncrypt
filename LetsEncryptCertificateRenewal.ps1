#################################################################
##This needs to run on a schedule to renew the Letsencrypt certs#
#################################################################
$Debug = "1"
$LogPath = "C:\Powershell\LetsEncrypt\LetsEncryptCertificate.log"

#Renew certificate
$PAOrder = Get-PAOrder
$RenewAfter = Get-Date ($PAOrder | Select-Object -ExpandProperty RenewAfter)
$Now = Get-Date
#If the renewaldate has passed
if ($Now -gt $RenewAfter){
	#We order a certificate renewal (Notice you don't need the API key because we use our existing Certificate to prove who we are)
    if ($debug){"Renewing certificate" >> $LogPath}
    Get-PAOrder | Submit-Renewal -Force
    
    #Verify the new certificate has been updated.
    $CheckPAOrder = Get-PAOrder
    $CheckRenewAfter = Get-Date ($CheckPAOrder | Select-Object -ExpandProperty RenewAfter)
    if ($CheckRenewAfter -eq $RenewAfter){
        if ($debug){"Renewal failed. Run for your lives." >> $LogPath}
    } else {
    $PACertificate = Get-PACertificate
    if ($debug){$PACertificate >> $LogPath}
    }

} else {
    if ($debug){"Waiting $(($renewafter - $now).days) days before renewing." >> $LogPath}
}