# Importa a função 'LogonUser' da API do Windows
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Security.Principal;

public class LogonHelper {
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool LogonUser(string userName, string domainName, string password,
        int logonType, int logonProvider, out IntPtr tokenHandle);
    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
    public extern static bool CloseHandle(IntPtr handle);
}
"@

# Credenciais do usuário
$UserName = "Dominio\\Usuario"
$Password = "SenhaSegura"
$DomainName = "Dominio"

# Configuração para logon de rede
$LOGON32_LOGON_NETWORK = 3
$LOGON32_PROVIDER_DEFAULT = 0

# Criação do token para o logon
$tokenHandle = New-Object IntPtr
$success = [LogonHelper]::LogonUser($UserName, $DomainName, $Password, $LOGON32_LOGON_NETWORK, $LOGON32_PROVIDER_DEFAULT, [ref]$tokenHandle)

if ($success) {
    try {
        Write-Host "Logon realizado com sucesso para: $UserName"

        # Criação do contexto de WindowsIdentity com o token
        $windowsIdentity = [System.Security.Principal.WindowsIdentity]::New($tokenHandle)

        # Uso do método RunImpersonated
        [System.Security.Principal.WindowsIdentity]::RunImpersonated(
            $windowsIdentity.AccessToken,
            { 
                # Código executado no contexto do usuário impersonado
                Write-Host "Executando código no contexto do usuário impersonado..."
                # Exemplo: Conexão com banco de dados, execução de comandos, etc.
                Invoke-Command -ScriptBlock { 
                    Write-Host "Código dentro do bloco impersonado."
                }
            }
        )
    } finally {
        # Fecha o handle do token
        [LogonHelper]::CloseHandle($tokenHandle)
    }
} else {
    $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "Falha ao realizar logon. Código de erro: $errorCode"
}
