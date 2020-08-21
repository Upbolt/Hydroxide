<p align="center">
  <img src="https://camo.githubusercontent.com/96f209b7bb27dce3f8b7da5d6d216e601eebb25b/68747470733a2f2f63646e2e646973636f72646170702e636f6d2f6174746163686d656e74732f3633333437323432393931373939353033382f3732323134333733303530303530313533342f487964726f786964655f4c6f676f2e706e67">
  <br><br>
  <b>Hydroxide - General purpose pen-testing tool for games on the Roblox Engine.</b>
  
  ```lua
local owner = "Upbolt"
local branch = "revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
```
</p>

---

### *Taking ROBLOX exploiting to the next level...*

![alt text](https://camo.githubusercontent.com/4cdcb3f0756ded1323150d6807ea9d507799ca60/68747470733a2f2f63646e2e646973636f72646170702e636f6d2f6174746163686d656e74732f3639343732363633363133383030343539332f3734323430383534363333343933333030322f756e6b6e6f776e2e706e67 "In-game screenshot of UI")

Hydroxide is a project by **hush**, exploiting community expert, dedicated to expanding this open-sourced project and many others.                       
The purpose of this project is to create an all-in-one multi use pentesting tool, universal to all games on the Roblox Platform.                                  

### *Power in simplicity*...

With an extremely smooth user interface, Hydroxide is easy to navigate and utilise as you familiarise yourself with the layout.                                      
**Example of Upvalue Modification:** https://i.gyazo.com/63afdd764cdca533af5ebca843217a7e.gif                                                                      
**Example of Remote Spy:** https://i.gyazo.com/aed8690c3161468ca9a3156dfdb665e2.gif

### Current Features (v = c.1)

* Upvalue Scanner
    * View/Modify Upvalues
    * View first-level values in table upvalues
    * View information of closure
* Constant Scanner
    * View/Modify Constants
    * View information of closure
* Script Scanner
    * View general information of scripts (source, protos, constants, etc.)
    * Retrieve all protos found in GC
* Module Scanner
    * View general information of modules (return value, source, protos, constants, etc.)
    * Retrieve all protos found in GC
* RemoteSpy
    * Log calls of remote objects (RemoteEvent, RemoteFunction, BindableEvent, BindableFunction)
    * Ignore/Block calls based on parameters passed
    * Traceback calling function/closure
* ClosureSpy
    * Log calls of closures
    * View general information of closures (location, protos, constants, etc.)
    


Join the community discord server [here](https://discord.gg/DJxBwAX).
    
:warning: **This is not the finished product, bugs are to be expected.**
