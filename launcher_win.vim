explorer /n, %:h	call Start(expand('$WINDIR/explorer.exe') . ' /n, ' . expand('%:p:h:gs?/?\?'))
リモートデスクトップ - mstsc	call Start(expand('$SYSTEMROOT/System32/mstsc.exe'))
システムの詳細設定 - SystemPropertiesAdvanced	call Open(expand('$SYSTEMROOT/System32/SystemPropertiesAdvanced.exe'))
IE - Internet Explorer	call Open(expand('$ProgramFiles/Internet Explorer/iexplore.exe'))
