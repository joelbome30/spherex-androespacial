$raiz = [IO.Path]::GetFullPath($PSScriptRoot)
$servidor = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$servidor.Start()
$puerto = $servidor.LocalEndpoint.Port
$direccion = "http://127.0.0.1:$puerto/"

Write-Host "Pagina disponible en $direccion"
Write-Host "Cierra esta ventana o pulsa Ctrl+C para detener el servidor."
Start-Process $direccion

$tipos = @{
    '.html' = 'text/html; charset=utf-8'
    '.css' = 'text/css; charset=utf-8'
    '.js' = 'text/javascript; charset=utf-8'
    '.jpg' = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.png' = 'image/png'
    '.svg' = 'image/svg+xml'
    '.webp' = 'image/webp'
    '.woff2' = 'font/woff2'
    '.ico' = 'image/x-icon'
}

try {
    while ($true) {
        $cliente = $servidor.AcceptTcpClient()

        try {
            $flujo = $cliente.GetStream()
            $lector = [IO.StreamReader]::new($flujo, [Text.Encoding]::ASCII)
            $peticion = $lector.ReadLine()

            if ([string]::IsNullOrEmpty($peticion)) {
                continue
            }

            do {
                $linea = $lector.ReadLine()
            } while (-not [string]::IsNullOrEmpty($linea))

            $partes = $peticion.Split(' ')
            $metodo = $partes[0]
            $ruta = [Uri]::UnescapeDataString($partes[1].Split('?')[0])

            if ($ruta -eq '/') {
                $ruta = '/pagina-base.html'
            }

            $archivo = [IO.Path]::GetFullPath([IO.Path]::Combine($raiz, $ruta.TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)))
            $dentro = $archivo.StartsWith($raiz + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)

            if ($metodo -ne 'GET' -and $metodo -ne 'HEAD') {
                $estado = '405 Method Not Allowed'
                $contenido = [byte[]]@()
            } elseif (-not $dentro) {
                $estado = '403 Forbidden'
                $contenido = [byte[]]@()
            } elseif (-not [IO.File]::Exists($archivo)) {
                $estado = '404 Not Found'
                $contenido = [byte[]]@()
            } else {
                $estado = '200 OK'
                $contenido = [IO.File]::ReadAllBytes($archivo)
            }

            $extension = [IO.Path]::GetExtension($archivo).ToLowerInvariant()
            $tipo = $tipos[$extension]
            if (-not $tipo) {
                $tipo = 'application/octet-stream'
            }

            $cabecera = "HTTP/1.1 $estado`r`nContent-Type: $tipo`r`nContent-Length: $($contenido.Length)`r`nConnection: close`r`n`r`n"
            $bytesCabecera = [Text.Encoding]::ASCII.GetBytes($cabecera)
            $flujo.Write($bytesCabecera, 0, $bytesCabecera.Length)

            if ($metodo -ne 'HEAD' -and $contenido.Length -gt 0) {
                $flujo.Write($contenido, 0, $contenido.Length)
            }
        } finally {
            $cliente.Close()
        }
    }
} finally {
    $servidor.Stop()
}
