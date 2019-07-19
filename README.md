# vimfiles

## neovim in windows

```dosbatch
> mkdir "%HOME%\.config"
> setx XDG_CONFIG_HOME "%HOME%\.config"
> set XDG_CONFIG_HOME="%HOME%\.config"
> mklink /D %XDG_CONFIG_HOME%\nvim %HOME%\vimfiles\
```


