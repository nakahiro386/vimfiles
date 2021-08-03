# vimfiles

## chocolateyでのインストール

### 自作packageのアンインストール

```ps1
> choco uninstall -y vim-kaoriya
```

### vimのインストール
```ps1
> choco install vim --params "'/NoDefaultVimrc /NoContextmenu /NoDesktopShortcuts'"
```

### python3インタフェース

* `Windows embeddable package`をダウンロード
    * [Python Releases for Windows | Python.org](https://www.python.org/downloads/windows/)
* ダウンロードしたzipを展開
* 展開先でbashを開いて、以下を実行する
    ```sh
    $ sed -i -e 's/#import site/import site/' python*._pth
    $ wget https://bootstrap.pypa.io/get-pip.py
    $ ./python.exe get-pip.py
    $ ./python.exe -m pip install -U pynvim send2trash
    ```
* `$VIMFILES/vimrc_init_local.vim`で`'pythonthreedll'`と`g:python3_host_prog`を設定する。

### luaインタフェース

* `Windows x64 Executables `をダウンロード
    * [Lua Binaries Download](http://luabinaries.sourceforge.net/download.html)
* ダウンロードしたzipを展開
* `$VIMFILES/vimrc_init_local.vim`で`'luadll'`を設定する。

## neovim in windows

```dosbatch
> mkdir "%HOME%\.config"
> setx XDG_CONFIG_HOME "%HOME%\.config"
> set XDG_CONFIG_HOME="%HOME%\.config"
> mklink /D %XDG_CONFIG_HOME%\nvim %HOME%\vimfiles\
```


