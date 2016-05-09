$address = 'https://hail2u.net/pub/vim-tango-icon.zip'
$currentPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$fileName = $(join-path $currentPath 'vim-tango-icon.zip')
$extractPath = $(join-path $currentPath 'vim-tango-icon')
$src = $(join-path $extractPath 'ico\vim2.ico')
$dest = $(join-path $currentPath 'vim.ico')

$wc = new-object System.Net.WebClient
$proxy = [System.Net.WebRequest]::GetSystemWebProxy()
$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$wc.Proxy = $proxy
try {
    $wc.DownloadFile($address, $fileName)
} catch [System.Net.WebException] {
    if ($_.Exception -match ".*\(407\).*") {
        # ダイアログを表示してログイン情報を取得
        $cred = get-credential
        $wc.Proxy.Credentials = $cred.GetNetworkCredential()
        # 再度ダウンロード
        $wc.DownloadFile($address, $fileName)
    } else {
        throw
    }
}

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.Zipfile]::ExtractToDirectory($fileName, $extractPath);

Copy-Item $src $dest

