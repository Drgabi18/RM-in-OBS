--inspired by undefinist / www.undefinist.com Factory.lua file
--because I didn't know what commands were necesary to generate it

function ins(StringsToRead, Index, TableWhereNeeded)
	
	-- StringsToRead	= table,	e.g. `{"Meter=String", "String=Num%d"}`
	-- Index			= any,		e.g. string/number put into the %d replacement
	-- TableWhereNeeded	= table,	e.g. the one where the results need to be inserted
	
	-- For a simple explanation, for a table string like `{"Meter=String", "String=Num%d"}`, this
	-- function just gets every element from the table and does table.insert to where you need it to;
	-- it seraches if a string has %d and uses string.format to replace all the places where %d appears,
	-- but because you can't specify only a single argument for that function and beacuse I didn't wanna
	-- use string.sub (idk why), `unpackinator()` does the job of repeating the same value over and over
	-- God I hate Lua and myself

	local trouble = {}

	local function unpackinator(stingy, searchString, insertNumber)
		--stingy		= table,	e.g. string which is read, will always have a pattern
		--searchString	= pattern,	e.g. `%%d`
		--insertNumber	= any,		e.g. string/number to be repeated
		for j = 1, select(2, string.gsub(stingy, searchString, "")) do
			table.insert(trouble, insertNumber)
		end
		return unpack(trouble)
	end

	for i = 1, #StringsToRead do
		if Index ~= nil then
			table.insert( TableWhereNeeded,
				string.format(StringsToRead[i], unpackinator(StringsToRead[i], "%%d", Index))
			)
		else
			table.insert(TableWhereNeeded, StringsToRead[i])
		end
	end
end

function Initialize()
	Nr=SELF:GetOption("NrOfLoadedSkins")
	GenerateConfigs(Nr)
	
	--if GenerateConfig fails, this next line never gets executed, making it easier to know it's a LUA error
	SKIN:Bang("!HideMeter ErrorString")
end

function GenerateConfigs(n)
	local file = io.open(SKIN:MakePathAbsolute(SELF:GetOption("IncFile")), "w")
	
	local t = {}

	for i = 1, n do

	ins({"[Config%d]",
		"Measure=Plugin",
		"Plugin=ConfigActive",
		"Type=Config",
		"Index=%d",
		"UpdateDivider=-1"}, i, t)

	ins({"[Skin%d]",
		"Measure=Plugin",
		"Plugin=ConfigActive",
		"Type=Skin",
		"Index=%d",
		"UpdateDivider=-1"}, i, t)

	ins({"[String%d]",
		"Meter=String",
		"MeasureName=Config%d",
		"MeasureName2=Skin%d",
		"MeterStyle=Texty",
		'LeftMouseUpAction=["#@#ExStyleRemove.exe" "#SkinsPath#'..'[&Config%d]\\[&Skin%d]"][!SetOption String%d SolidColor "#ColorSet#"][!UpdateMeter String%d][!Redraw]\n'}, i, t)

	end

	file:write(table.concat(t, "\n"))
	file:close()

end

function GetWidth(n)

	-- This is stupidly complex, all it does is make a {{"String1", 231},{"String2", 554}} table out of
	-- some meters I chose to be in the list and just gets the meter that has the longest width so 
	-- the invisible hacking padding meter can be positioined at the X position that is the longest
	-- I did it mostly to learn tables and always wanted to do this

	-- day 1 of wishing Rainmeter had an array implementation

	local b = {}

	table.insert(b, "ReadIniPlease")

	if SKIN:GetVariable("HideJunk", 0) ~= 0 then
		table.insert(b, "ReadIniJunk")
	end

	for i = 1, n do
		table.insert(b, "String" .. i)
	end

	-- can also be done using __index and __newindex but would need a proxy table, eh
	for i = 1, #b do
		b[i] = {b[i], SKIN:ReplaceVariables("[" .. b[i] .. ":XW]")}
	end

	table.sort( b,
		function(a, c) return a[2] < c[2] end
	)

	--print(b[#b][1],b[#b][2])

	SKIN:Bang("!SetOption", "HackyPadding", "X", "[" .. b[#b][1] .. ":XW]")
end
