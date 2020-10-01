<#Initial setup requires this:
#Enter your Fortigate admin credentials
$creds =Get-Credential
#Stores the credentials encrypted on the computer/user combination.
Export-Clixml -Path C:\Powershell\LetsEncrypt\fortigatecreds.xml -InputObject $creds
#>
$Debug = "1"
$LogPath = "C:\Powershell\LetsEncrypt\FortigateCertificate.log"

$Certificate = Get-PACertificate
$privatekey = Get-Content $Certificate.KeyFile
$certfile =Get-Content $Certificate.CertFile
$Password = Get-PAOrder | Select-Object -exp PfxPass



$FortigateIP = '10.0.0.254'
if ($debug){$FortigateIP >> $LogPath}

$port = '443'
$TcpClient = New-Object Net.Sockets.TcpClient
$TcpClient.Connect($FortigateIP, $Port)
$SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream(),
    $true,
    ([System.Net.Security.RemoteCertificateValidationCallback]{ $true })
$SslStream.ReadTimeout = 15000
$SslStream.WriteTimeout = 15000
$SslStream.AuthenticateAsClient($RetValue.Host,$null,"tls12",$false)
$Thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)).Thumbprint
$TcpClient.Dispose()
$SslStream.Dispose()




if ($Thumbprint -ne $Certificate.Thumbprint){
#>
       if ($debug){"Upgrading certificate on Fortigate from $Thumbprint to $($Certificate.Thumbprint)" >> $LogPath}
    $creds = Import-Clixml -Path C:\Powershell\LetsEncrypt\fortigatecreds.xml
    $SSH = New-SSHSession -ComputerName $FortigateIP -AcceptKey -Force -Credential $creds
    $SSHStream = New-SSHShellStream -SSHSession $SSH
    if ($debug){$creds >> $LogPath}
        if ($SSH){$creds >> $LogPath}
            if ($SSHStream){$creds >> $LogPath}
        
    $Command = "config vpn certificate local"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "edit ""letsencrypt"""
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "show"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()

    $command = "set password $Password"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()


    $Command = "set private-key '"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    start-sleep -Milliseconds 100
    foreach ($line in $privatekey){
        $Command = $line
        $SSHStream.WriteLine($Command)
        start-sleep -Milliseconds 100
        $SSHStream.read()
    }
    $Command = "'"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()


    $Command = "set certificate '"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    
    foreach ($line in $certfile){
    $Command = $line
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    }
    $Command = "'"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()

    $Command = "end"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()




    $Command = "config vpn ssl settings"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "unset servercert"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "end"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()




    $Command = "config vpn ssl settings"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "set servercert ""letsencrypt"""
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "end"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()




    $Command = "config system global"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()

    $Command = "unset admin-server-cert"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()

    $Command = "end"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()




    $Command = "config sys global"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "set admin-server-cert letsencrypt"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    $Command = "end"
    $SSHStream.WriteLine($Command)
    start-sleep -Milliseconds 100
    $SSHStream.read()
    if ($debug){"Certificate should be replaced. Checking." >> $LogPath}
    

    $port = '443'
    $TcpClient = New-Object Net.Sockets.TcpClient
    $TcpClient.Connect($FortigateIP, $Port)
    $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream(),
    $true,
    ([System.Net.Security.RemoteCertificateValidationCallback]{ $true })
    $SslStream.ReadTimeout = 15000
    $SslStream.WriteTimeout = 15000
    $SslStream.AuthenticateAsClient($RetValue.Host,$null,"tls12",$false)
    $Thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)).Thumbprint
    $TcpClient.Dispose()
    $SslStream.Dispose()
    if ($Thumbprint -eq $Certificate.thumbprint){
        if ($debug){"New certificate $Thumbprint has been installed." >> $LogPath}
    }

} else {
    if ($debug){"Existing Fortigate certificate $Thumbprint has not been replaced." >> $LogPath}
}