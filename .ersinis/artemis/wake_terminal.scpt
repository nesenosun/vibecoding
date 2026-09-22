on run argv
	set msg to item 1 of argv
	tell application "System Events"
		-- Uygulamanın adını kontrol et (Ersinis veya Runner)
		set isRunning to (exists (processes where name is "ersinis"))
		if isRunning then
			tell process "ersinis"
				set frontmost to true
				delay 1
				-- Mesajı yaz ve Enter'a bas
				keystroke msg
				key code 36 -- Return/Enter tuşu
			end tell
		else
			-- Eğer isim farklıysa Runner olarak dene (Flutter varsayılanı)
			set isRunningRunner to (exists (processes where name is "Runner"))
			if isRunningRunner then
				tell process "Runner"
					set frontmost to true
					delay 1
					keystroke msg
					key code 36
				end tell
			end if
		end if
	end tell
end run
