; a framework to define hotkey with prefix hotkey
; hkwp = new HotKeyWithPrefix()
; hkwp.register("#a", "!a", functor1)
; hkwp.register("#a", "!b", functor2)
; hkwp.register("#b", "!a", functor3)
; hkwp.register("#b", "!b", functor4)

class HotKeyWithPrefix
{
	__New()
	{
		this.statusMap := {}
		this.handleMap := {}
		
		return this
	}
	
	updatePrefixState(prefix)
	{
		sm := {}
		if (this.statusMap.HasKey(prefix)) {
			sm := this.statusMap[prefix]
		}
		
		sm.down := 1
		sm.timestamp := A_TickCount
		
		this.statusMap[prefix] := sm
	}
	
	enrollKeyHandler(wkey, functor)
	{
		this.handleMap[wkey] := functor
	}
	
	handlePrefix()
	{
		prefix := A_ThisHotkey
		this.updatePrefixState(prefix)
	}
	
	handleKey()
	{
		key := A_ThisHotkey
		isTriggered := false
		for prefix, sm in this.statusMap {
			if !sm.down {
				continue
			}
			
			elspsedTime := A_TickCount - sm.timestamp
			
			if (elspsedTime > 2000) {
				sm.down := 0
				sm.timestamp := 0
				continue
			}
		
			wholekey = %prefix%%key%
			if !this.handleMap.HasKey(wholekey) {
				continue
			}
			
			fn := this.handleMap[wholekey]
			fn.Call()
			isTriggered := true
		}
		
		if (!isTriggered) {
			Send %key%
		}
	}
	
	register(prefix, key, functor)
	{
		wholekey = %prefix%%key%
		
		this.updatePrefixState(prefix)
		this.enrollKeyHandler(wholekey, functor)
		
		fn1 := ObjBindMethod(this, "handlePrefix")
		fn2 := ObjBindMethod(this, "handleKey")
		Hotkey, %prefix%, %fn1%
		Hotkey, %key%, %fn2%
	}
}

; framework to support hotkeys like ctrl + shift + a, x
; ppsk := new PrefixPlusSingleKey()
; ppsk.on("^+a")
; ppsk.add("a", "open a network driver", functor1)
class PrefixPlusSingleKey {
	__New()
	{
		this.prefix := ""
		this.handles := []
		this.lastActiveWin := 0
		
		return this
	}
	
	handlePrefix()
	{
		if (this.handles.Length() <= 0) {
			return
		}
		
		WinGet, active_ID, ID, A
		this.lastActiveWin := active_ID
		
		Factor := ObjBindMethod(this, "handleGuiEvent")
		Gui , Add, ListView,r20 w300 HwndMyListViewH AltSubmit, Key|Description
		GuiControl +g, %MyListViewH%, % Factor

		Loop % this.handles.Length()
			LV_Add("", this.handles[A_Index][1], this.handles[A_Index][2])

		LV_ModifyCol() 
		Gui, Show
		return
	}
	
	handleGuiEvent() {
		if A_GuiEvent = K
		{
			key := A_EventInfo
			
			if (key < 32 || key > 127) {
				return
			}
			
			if (key == 32) {
				Gui Destroy
				return
			}
			
			key := GetKeyName(Format("vk{:x}", key))
			Loop % this.handles.Length()
			{
				item := this.handles[A_Index]
				if (item[1] == key) {
					fn := item[3]
					fn.Call(this.lastActiveWin)
				}
			}
			Gui Destroy
		}
		return
	}

	on(prefix)
	{
		this.prefix := ""
		fn1 := ObjBindMethod(this, "handlePrefix")
		Hotkey, %prefix%, %fn1%
	}
	
	add(k, desc, factor)
	{
		this.handles.push([k, desc, factor])
	}
}
