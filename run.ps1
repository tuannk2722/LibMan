[CmdletBinding()]
param(
    [string]$TomcatHome = $env:CATALINA_HOME,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:JAVA_HOME) -or
    !(Test-Path -LiteralPath (Join-Path $env:JAVA_HOME 'bin\javac.exe') -PathType Leaf)) {
    throw 'Set JAVA_HOME to a JDK 17 or newer, for example C:\Program Files\Java\jdk-21.'
}
if ([string]::IsNullOrWhiteSpace($TomcatHome)) {
    throw 'Set CATALINA_HOME or pass -TomcatHome with the path to an extracted Tomcat 10.1 ZIP.'
}

$homePath = (Resolve-Path -LiteralPath $TomcatHome).ProviderPath
$basePath = $homePath
if ($env:CATALINA_BASE) {
    $basePath = (Resolve-Path -LiteralPath $env:CATALINA_BASE).ProviderPath
}
$catalina = Join-Path $homePath 'bin\catalina.bat'
$catalinaJar = Join-Path $homePath 'lib\catalina.jar'
$webapps = Join-Path $basePath 'webapps'
if (!(Test-Path -LiteralPath $catalina -PathType Leaf) -or !(Test-Path -LiteralPath $catalinaJar -PathType Leaf)) {
    throw "Tomcat executable or JAR not found under '$homePath'."
}
if (!(Test-Path -LiteralPath (Join-Path $basePath 'conf\server.xml') -PathType Leaf) -or
    !(Test-Path -LiteralPath $webapps -PathType Container)) {
    throw "Expected conf\server.xml and webapps under '$basePath'."
}

$java = Join-Path $env:JAVA_HOME 'bin\java.exe'
$versionInfo = & $java -cp $catalinaJar org.apache.catalina.util.ServerInfo
if ($LASTEXITCODE -ne 0 -or ($versionInfo -join "`n") -notmatch 'Apache Tomcat/10\.1\.') {
    throw "Expected Tomcat 10.1 under '$homePath'."
}

if (!$SkipBuild) {
    Push-Location -LiteralPath $PSScriptRoot
    try {
        & .\mvnw.cmd package
        if ($LASTEXITCODE -ne 0) { throw "Maven build failed (exit $LASTEXITCODE)." }
    } finally {
        Pop-Location
    }
}

$war = Join-Path $PSScriptRoot 'target\LibMan.war'
if (!(Test-Path -LiteralPath $war -PathType Leaf)) {
    throw 'target\LibMan.war is missing. Build it with .\mvnw.cmd package, or run this script without -SkipBuild.'
}
$destination = Join-Path $webapps 'LibMan.war'
if (!(Test-Path -LiteralPath $destination -PathType Leaf) -or
    (Get-FileHash -LiteralPath $war).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
    $stagedWar = Join-Path $webapps ('.LibMan-' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        Copy-Item -LiteralPath $war -Destination $stagedWar
        [IO.File]::SetLastWriteTimeUtc($stagedWar, [DateTime]::UtcNow)
        if ([IO.File]::Exists($destination)) {
            [IO.File]::Replace($stagedWar, $destination, [NullString]::Value)
        } else {
            [IO.File]::Move($stagedWar, $destination)
        }
    } finally {
        if (Test-Path -LiteralPath $stagedWar) { Remove-Item -LiteralPath $stagedWar }
    }
}

$tomcatEnvironment = @{
    CATALINA_HOME = $homePath
    CATALINA_BASE = $basePath
    JRE_HOME = $env:JAVA_HOME
    CATALINA_OPTS = $env:CATALINA_OPTS
    LIBMAN_JDBC_URL = $env:LIBMAN_JDBC_URL
    LIBMAN_DB_USER = $env:LIBMAN_DB_USER
    LIBMAN_DB_PASSWORD = $env:LIBMAN_DB_PASSWORD
}
if (!$tomcatEnvironment.LIBMAN_JDBC_URL) { $tomcatEnvironment.LIBMAN_JDBC_URL = 'jdbc:mysql://localhost:3306/LibMan' }
if (!$tomcatEnvironment.LIBMAN_DB_USER) { $tomcatEnvironment.LIBMAN_DB_USER = 'libman_app' }
if (!$tomcatEnvironment.LIBMAN_DB_PASSWORD) {
    $password = Read-Host "MySQL password for $($tomcatEnvironment.LIBMAN_DB_USER)" -AsSecureString
    $tomcatEnvironment.LIBMAN_DB_PASSWORD = [System.Net.NetworkCredential]::new('', $password).Password
}
if ($tomcatEnvironment.CATALINA_OPTS -notmatch '-Duser\.timezone=') {
    $tomcatEnvironment.CATALINA_OPTS = "$($tomcatEnvironment.CATALINA_OPTS) -Duser.timezone=Asia/Ho_Chi_Minh".Trim()
}

$previousEnvironment = @{}
try {
    foreach ($name in $tomcatEnvironment.Keys) {
        $previousEnvironment[$name] = [Environment]::GetEnvironmentVariable($name)
        [Environment]::SetEnvironmentVariable($name, $tomcatEnvironment[$name])
    }
    Write-Host 'LibMan context: /LibMan/ (default URL: http://localhost:8080/LibMan/)'
    & $catalina run
    if ($LASTEXITCODE -ne 0) { throw "Tomcat exited with code $LASTEXITCODE." }
} finally {
    foreach ($name in $previousEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previousEnvironment[$name])
    }
}
