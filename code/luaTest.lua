UPGRADE = 1 	// upgrade sprites or levels data







        if UPGRADE

        lua ;ALLPASS

        function fileList(path)
        	return io.popen("dir \""..path.."\" /a /b", "r"):lines()
        end

        function save(data)
        	local file,err = io.open("sprites/storage.asm",'w')
		if file then
			file:write(tostring(data))
			file:close()
		else
			print("error:", err) -- not so hard?
    		end
        end 
-- 		.PBM to asm
	local path = "sprites/bmp/"
	local data = ""
	--// read path for names
	for fileName in io.popen("dir \""..path.."\" /a /b", "r"):lines() do
	    local lines = {}
	    local file = assert(io.open(path..fileName, "rb"))
	    --// read lines from file.pbm 'PBM' format
	    for line in io.lines(path..fileName) do
	    	--// [1] format
	    	--// [2] width
	    	--// [3] height
	    	--// [4] sprite data
	    	lines[#lines + 1] = line 
	    end
	    --// reformat name for asm label
	    uppercaseName = string.upper(fileName)
	    dotUnderscore = string.gsub(string.upper(fileName),"%.", "_")
	    local strData = ""
	    for c in  (lines[4] or ''):gmatch'.' do
	    	strData = strData..c:byte()..","
	    end
	    data = data..dotUnderscore..':\tdb '..string.sub(strData, 1, #strData-1).."\n"
	    file:close()
	end
	save(data)

--		Tiled to asm
	local mapsPath = "maps/"
	for levelName in fileList(mapsPath) do
		local file = assert(io.open(mapsPath..levelName, "r"))
		local t = file:read("*a")
		print(t)
		file:close()
	end


        endlua

        endif