GuildLog = {}

--this will run on start
function GuildLog.OnInitialize()
GuildLog.TextArray = {[26]=L"Deposit Money: ",[25]=L"Deposit Item: ",[27]=L"Withdrew Item: ",[28]=L"Withdrew Money: "}
GuildLog.Filter = {[26]=666,[25]=666,[27]=667,[28]=667}

ror_PacketHandling.Register("GUILD_VAULT_S",GuildLog.ShowWindow)
ror_PacketHandling.Register("GUILD_VAULT",GuildLog.Packet)

CreateWindow("GuildLogWindow",false)
GuildLog.LogNumber = 666
	
	TextLogCreate("GuildLogWindowLog", 666)
	TextLogClear("GuildLogWindowLog")
	TextLogAddFilterType("GuildLogWindowLog", 666, L"") -- add Log
	TextLogAddFilterType("GuildLogWindowLog", 667, L"")	-- remove Log
	LogDisplayAddLog("GuildLogWindowLogDisplay","GuildLogWindowLog", true)
	LogDisplaySetShowTimestamp("GuildLogWindowLogDisplay", false)
	LogDisplaySetShowLogName("GuildLogWindowLogDisplay", false)
    TextLogDisplayShowScrollbar("GuildLogWindowLogDisplay", true)
	LogDisplaySetFilterColor("GuildLogWindowLogDisplay","GuildLogWindowLog",666, 75,255,75 )
	LogDisplaySetFilterColor("GuildLogWindowLogDisplay","GuildLogWindowLog",667, 255,75,75 )

end

function GuildLog.ShowWindow(text)
    WindowSetShowing( "GuildLogWindow", true )
	TextLogClear("GuildLogWindowLog")
	LabelSetText( "GuildLogWindowTitleBarText", GameData.Guild.m_GuildName..L"'s Vault Log")
end

function GuildLog.Packet(text)	
	if string.find(text,"GUILD_VAULT:") then
	local text = string.gsub(text,"GUILD_VAULT:","")
	local Gtable = json.decode(text)
	GuildLog.AddLog(Gtable)
	end
end

function GuildLog.AddLog(GTable)
for k,v in pairs(GTable) do
	local Table = GTable[k]
	local Data =  L"PLAYER:"..towstring(Table.Text)
	local Player = towstring(CreateHyperLink(towstring(Data),towstring(Table.Text), {225,225,225}, {} ))..L" "

	local Type = Table.Type
	local Action = towstring(GuildLog.TextArray[Table.Type])..L" "
	local Item = towstring(Table.Text2)..L" "
	local Ammount = towstring(Table.Value + Table.Value2)..L" "
	local Time_Y,Time_M,Time_D,Time_h,Time_m,Time_s = GuildLog.GetTime(Table.Time)
	local Filter = GuildLog.Filter[Table.Type]

	if Type == 26 or Type == 28 then
	local g,s,b = MoneyFrame.ConvertBrassToCurrency(Table.Value + Table.Value2)
	Ammount = towstring(g)..L" Gold, "..towstring(s)..L" Silver, "..towstring(b)..L" Brass"
	end
	local Date = L"["..towstring(Time_Y)..L"-"..towstring(Time_M)..L"-"..towstring(Time_D)..L" "..towstring(Time_h)..L":"..towstring(Time_m)..L":"..towstring(Time_s)..L"] "
	TextLogAddEntry("GuildLogWindowLog",Filter,Date..Player..Action..Ammount..Item)	
end

end

function GuildLog.OnLButtonUpClose()
    WindowSetShowing( "GuildLogWindow", false )
end

--this will run on exit
function GuildLog.OnShutdown()	

end

function GuildLog.GetTime(t)
local floor=math.floor

local DSEC=24*60*60 -- secs in a day
local YSEC=365*DSEC -- secs in a year
local LSEC=YSEC+DSEC    -- secs in a leap year
local FSEC=4*YSEC+DSEC  -- secs in a 4-year interval
local BASE_DOW=4    -- 1970-01-01 was a Thursday
local BASE_YEAR=1970    -- 1970 is the base year

local _days={
    -1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333, 364
}
local _lpdays={}
for i=1,2  do _lpdays[i]=_days[i]   end
for i=3,13 do _lpdays[i]=_days[i]+1 end


    local y,j,m,d,w,h,n,s
    local mdays=_days
    s=t
    y=floor(s/FSEC)
    s=s-y*FSEC
    y=y*4+BASE_YEAR         -- 1970, 1974, 1978, ...
    if s>=YSEC then
        y=y+1           -- 1971, 1975, 1979,...
        s=s-YSEC
        if s>=YSEC then
            y=y+1       -- 1972, 1976, 1980,... (leap years!)
            s=s-YSEC
            if s>=LSEC then
                y=y+1   -- 1971, 1975, 1979,...
                s=s-LSEC
            else        -- leap year
                mdays=_lpdays
            end
        end
    end
    j=floor(s/DSEC)
    s=s-j*DSEC
    local m=1
    while mdays[m]<j do m=m+1 end
    m=m-1
    local d=j-mdays[m]
    -- Calculate day of week. Sunday is 0
    w=(floor(t/DSEC)+BASE_DOW)%7
    -- Calculate the time of day from the remaining seconds
    h=floor(s/3600)
    s=s-h*3600
    n=floor(s/60)
    s=s-n*60

if m < 10 then m = "0"..m end
if d < 10 then d = "0"..d end
if h < 10 then h = "0"..h end
if n < 10 then n = "0"..n end
if s < 10 then s = "0"..s end

    return y,m,d,h,n,s
end