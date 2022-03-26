$pattern = "version: (.*?) \#"
$string = Get-Content pubspec.yaml
$second_ssh_version = [regex]::match($string, $pattern).Groups[1].Value
Copy-Item ./windows-dlls/* ./build/windows/runner/Release
Compress-Archive -Path ./build/windows/runner/Release/* -DestinationPath .\second_ssh_-v$second_ssh_version.zip
Write-Output 'gh release create v$second_ssh_version ./build/windows/runner/Release/second_ssh_-v$second_ssh_version.zip --notes "This is an automated release."'
