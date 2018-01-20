# autohotkey.misc
all useful codes 

## HotKeyWithPrefix.ahk
A framework to allow defining hotkeys with prefix.

### HotKeyWithPrefix
define two combine keys. one is prefix, second one is trigger key.

#### example
```
runApplication(path) {
  Run %path%
}

hkwp.register("Capslock & y", "!a", Func("runApplication").Bind("https://www.google.com/"))
```

### PrefixPlusSingleKey.ahk
define one prefix key with one single key.

#### example
```
ppsk := new PrefixPlusSingleKey()
ppsk.on("Capslock & q")
ppsk.add("n", "running commands", Func("runCmd").bind("tasklist"))
```
