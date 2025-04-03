# Importa a função MessageBeep da user32.dll
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class WinUser {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool MessageBeep(uint uType);
}
"@

# Define o tipo de som (MB_OK, MB_ICONHAND, etc.)
# Consulte a documentação para outros tipos de som: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-messagebeep
$MB_OK = 0x00000000
$MB_ICONHAND = 0x00000010

# Chama a função MessageBeep com o tipo desejado
[WinUser]::MessageBeep($MB_OK)   # Som de "OK"
[WinUser]::MessageBeep($MB_ICONHAND)   # Som de erro (ícone de mão)
