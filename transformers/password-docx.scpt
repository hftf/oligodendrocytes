on run argv
    if (count of argv) is not 3 then
    	return "Need 3 arguments"
    end if

	set thePassword             to item 1 of argv
	set theDocxFilename         to item 2 of argv
	set thePasswordDocxFilename to item 3 of argv

	tell application "Microsoft Word"
		activate
		open file (theDocxFilename as POSIX file)

	end tell
end run
