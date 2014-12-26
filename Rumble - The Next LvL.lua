local version = "0.01"

_G.UseUpdater = true

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("Press x2 f9")
	end
end

local UPDATE_NAME = "Rumble - The Next LvL"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/LvL29Magikarp/URFmode/master/Rumble%20-%20The%20Next%20LvL.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..UPDATE_NAME..".lua"
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<b><font color=\"#FFFF00\">"..UPDATE_NAME..":</font></b> <font color=\"#00FFFF\">"..msg..".</font>") end
if _G.UseUpdater then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

if myHero.charName ~= "Rumble" then return end

local SCRIPT_NAME = "Rumble - The Next LvL"
		require "Collision"
	require "VPrediction"
	if VIP_USER then 
	require "Prodiction"
	end

	
--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					Loading
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OnLoad()
	Menu()
	VP = VPrediction()
	Info()
	if not FileExist(LIB_PATH.."SxOrbWalk.lua") then
		LuaSocket = require("socket")
		ScriptSocket = LuaSocket.connect("sx-bol.eu", 80)
		ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script=raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
		ScriptReceive, ScriptStatus = ScriptSocket:receive('*a')
		ScriptRaw = string.sub(ScriptReceive, string.find(ScriptReceive, "<bols".."cript>")+11, string.find(ScriptReceive, "</bols".."cript>")-1)
		ScriptFileOpen = io.open(LIB_PATH.."SxOrbWalk.lua", "w+")
		ScriptFileOpen:write(ScriptRaw)
		ScriptFileOpen:close()
	end
	require "SxOrbWalk"
	SxOrb:LoadToMenu()
end

function Info()
	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1700, true)
	ts.name = "Rumble"
	Menu:addTS(ts)
	qrdy, wrdy, erdy, rrdy = false, false, false, false
	qDmg, wDmg, eDmg, rDmg= 0,0,0,0
	Recalling = false
	zhonyaslot = nil
	zhonyaready = false
	Minions = minionManager(MINION_ALL, 925, myHero)
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	EnemyMinions = minionManager(MINION_ENEMY, 850, myHero, MINION_SORT_MAXHEALTH_DEC)
	calc()
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Check
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OnTick()
		Qrange = Menu.Qsett.Qrange
	ts:update()
	Target = ts.target
	SxOrb:ForceTarget(Target)
	qrdy = myHero:CanUseSpell(_Q) == READY 
	wrdy = myHero:CanUseSpell(_W) == READY
	erdy = myHero:CanUseSpell(_E) == READY
	rrdy = myHero:CanUseSpell(_R) == READY
	zhonyaslot = GetInventorySlotItem(3157)
	zhonyaready = (zhonyaslot ~= nil and myHero:CanUseSpell(zhonyaslot) == READY)
	if ValidTarget(Target) then
		qDmg = getDmg("Q", Target, myHero)
		wDmg = getDmg("W", Target, myHero)
		eDmg = getDmg("E", Target, myHero)
		rDmg = getDmg("R", Target, myHero) 
	end
DmgCalc()

		if ValidTarget(Target) then
		
			Combo() 
		end
		if Menu.Wsett.AutoW then
			AutoW()
		end
		if Menu.Farm.Farm then
			FarmQ()
		end
		if Menu.Haras.Haras and ValidTarget(Target) then
			Haras()
		end
		if Menu.Others.Zhonya then
		Zhonya()
		end
end


--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Menu
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function Menu()
	Menu = scriptConfig("Rumble - The Next LvL", "By LvL29Magikarp")
	
	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Combo:addParam("Items", "Use Items", SCRIPT_PARAM_ONOFF, false)
	Menu:addSubMenu("Haras", "Haras")
		Menu.Haras:addParam("Haras", "Haras", SCRIPT_PARAM_ONKEYDOWN, false, 67)
	Menu:addSubMenu("Lane Clear", "Farm")
		Menu.Farm:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, 88)
		Menu.Farm:addParam("FarmQ", "Farm Q(When minion is near to die)", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("Drawning", "Draw")
		Menu.Draw:addParam("DrawQ", "Draw Q", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("DrawE", "Draw E", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("DrawR", "Draw R", SCRIPT_PARAM_ONOFF, true)
		Menu.Draw:addParam("DrawDMG", "DrawDMG", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("Q Settings", "Qsett")
		Menu.Qsett:addParam("QCombo", "Q in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Qsett:addParam("Qrange", "Q range", SCRIPT_PARAM_SLICE, 0, 0, 1000, 0)
		Menu.Qsett:addParam("Blank", "I prefer set to: 600", SCRIPT_PARAM_INFO, "")
	Menu:addSubMenu("W Settings", "Wsett")
		Menu.Wsett:addParam("WCombo", "W in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Wsett:addParam("WCombo2", "Only if under", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
		Menu.Wsett:addParam("AutoW", "Auto W", SCRIPT_PARAM_ONOFF, true)
		Menu.Wsett:addParam("AutoW2", "What % to W", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	Menu:addSubMenu("E Settings", "Esett")
		Menu.Esett:addParam("ECombo", "E in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu:addSubMenu("R Settings", "Rsett")
		Menu.Rsett:addParam("RCombo", "R in Combo", SCRIPT_PARAM_ONOFF, true)
		Menu.Rsett:addParam("logic", "logic", SCRIPT_PARAM_LIST, 2, { "Logic 1", "Logic 2 VIP", "Logic 3"})
		Menu.Rsett:addParam("Blank", "Logic 1 Trying cast ult in enemy (Using VPrediction)", SCRIPT_PARAM_INFO, "")
		Menu.Rsett:addParam("Blank", "Logic 2 (VIP Using Prodiction) Trying Cast ult in center enemy", SCRIPT_PARAM_INFO, "")
		Menu.Rsett:addParam("Blank", "Logic 3 Trying cast ult in PredictedPos", SCRIPT_PARAM_INFO, "")
	Menu:addSubMenu("Others", "Others")
		Menu.Others:addParam("Zhonya", "Use Zhonya", SCRIPT_PARAM_ONOFF, true)
		Menu.Others:addParam("ZhonyaHp", "% hp to zhonya", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Combo
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function Combo()
	if Menu.Combo.Combo then
		UseItems(Target) 
			UseE()
			if Menu.Rsett.logic == 1 then
				UseR()
			end
			if Menu.Rsett.logic == 2 then
				UseR2(Target)
			end
			if Menu.Rsett.logic == 3 then
				UseR3()
			end
			
			UseQ()
			UseW()
	end
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				  Orbwalking
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

--Here should be OrbWalker but SxOrbWalk Doing this for me ^^

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			      Casting Spells
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]
function UseQ()
	if qrdy and Menu.Qsett.QCombo and GetDistance(Target) <= 600 then
		if VIP_USER then Packet("S_CAST", {spellId = _Q}):send() end
			else
			CastSpell(_Q)
	end
end

function UseE()
	if erdy and Menu.Esett.ECombo and GetDistance(Target) <= 850 then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.5, 90, 850, 1400, myHero, true)
			if HitChance >= 2 then
				if VIP_USER then Packet("S_CAST", { spellId = _E, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
				else
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
end

function UseR()
	if rrdy and GetDistance(Target) <= 1700 then
		CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(Target, 0.5, 200, 1700, 1400, myHero)
			if HitChance >= 2 then
				if VIP_USER then Packet("S_CAST", { spellId = _R, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
				else
					CastSpell(_R, CastPosition.x, CastPosition.z)
				end
			end
end

function UseR3()
	local CastPosition, HitChance = VP:GetPredictedPos(ts.target, 0.5, 1400, myHero, false)

                 if CastPosition and HitChance ~= 0 then

                   CastSpell(_R, CastPosition.x, CastPosition.z)

     end 


end

function UseR2(Target)
	if GetDistance(Target) < 1700 and rrdy then
		local pos, info, object = Prodiction.GetLineAOEPrediction(myHero, 1700, 1400, 0.1, 200, Target)
		local pos2 = pos + (Vector(unit) - pos):normalized()*(GetDistance(pos))
		Packet("S_CAST", {spellId = _R, fromX = pos2.x, fromY = pos2.z, toX = pos.x, toY = pos.z}):send()
	end
end


function UseW()
	if wrdy and Menu.Wsett.WCombo and GetDistance(Target) <= 650 and myHero.mana < (myHero.maxMana*(Menu.Wsett.WCombo2*0.01)) then
		if VIP_USER then Packet("S_CAST", {spellId = _W}):send() end
			else
			CastSpell(_W)
	end
end
--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			        Items
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				 Calculations
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function calc()
enemyCount = 0
        enemyTable = {}
 
        for i = 1, heroManager.iCount do
                local champ = heroManager:GetHero(i)
               
                if champ.team ~= player.team then
                        enemyCount = enemyCount + 1
                        enemyTable[enemyCount] = { player = champ, indicatorText = "", damageGettingText = "", ready = true}
                end
        end

end

function DmgCalc()
        for i = 1, enemyCount do
                local enemy = enemyTable[i].player
                if ValidTarget(enemy) and enemy.visible then
               
               
                        SpellQ                           = getDmg("Q", enemy, myHero)
                        SpellW                           = getDmg("W", enemy, myHero)
                        SpellE                           = getDmg("E", enemy, myHero)
                        SpellR                           = getDmg("R", enemy, myHero)
                        SpellI                           = getDmg("IGNITE", enemy, myHero)
 
                       
                        if enemy.health < SpellR then
                                enemyTable[i].indicatorText = "R Kill"
                               
                        elseif enemy.health < SpellQ then
                                enemyTable[i].indicatorText = "Q Kill"
                               
                        elseif enemy.health < SpellW then
                                enemyTable[i].indicatorText = "WKill"
                               
                        elseif enemy.health < SpellE then
                                enemyTable[i].indicatorText = "E Kill"
                       
                        elseif enemy.health < SpellQ + SpellR then
                                enemyTable[i].indicatorText = "Q + R Kill"
                       
                        elseif enemy.health < SpellW + SpellR then
                                enemyTable[i].indicatorText = "W + R Kill"
                               
                        elseif enemy.health < SpellE + SpellR then
                                enemyTable[i].indicatorText = "E + R Kill"
                       
                        elseif enemy.health < SpellQ + SpellW + SpellR then
                                enemyTable[i].indicatorText = "Q + W + R Kill"
                               
                        elseif enemy.health < SpellQ + SpellE + SpellR then
                                enemyTable[i].indicatorText = "Q + E + R Kill"
                               
                        else
                                local dmgTotal = (SpellQ + SpellW + SpellE + SpellR)
                                local hpLeft = math.round(enemy.health - dmgTotal)
                                local percentLeft = math.round(hpLeft / enemy.maxHealth * 100)
 
                                enemyTable[i].indicatorText = "Cant kill him ( " .. percentLeft .. "% )"
                        end
 
                        local myAD = getDmg("AD", enemy, myHero)
                 
                        enemyTable[i].damageGettingText = "I kill " .. enemy.charName .. " with " .. math.ceil(enemy.health / myAD) .. " hits"
                       
                end
        end
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			        Haras
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function Haras()
	if Menu.Haras.Haras and erdy and GetDistance(Target) <= 850 then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.5, 90, 850, 1400, myHero, true)
			if HitChance >= 2 then
				if VIP_USER then Packet("S_CAST", { spellId = _E, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
				else
					CastSpell(_E, CastPosition.x, CastPosition.z)
				end
			end
end



--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				     OnDraw
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OnDraw()
		if qrdy and Menu.Draw.DrawQ then
		 DrawCircle2(myHero.x, myHero.y, myHero.z, Qrange, 0xFFFF00FF)
		end
		if erdy and Menu.Draw.DrawE then
		 DrawCircle2(myHero.x, myHero.y, myHero.z, 850, 0xFFFF00FF)
		end
		if rrdy and Menu.Draw.DrawR then
		 DrawCircle2(myHero.x, myHero.y, myHero.z, 1700, 0xFFFF00FF)
		end
		if Menu.Draw.DrawDMG then
		for i = 1, enemyCount do
                                        local enemy = enemyTable[i].player
 
                                        if ValidTarget(enemy) and enemy.visible then
                                                local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                                                local pos = { X = barPos.x - 35, Y = barPos.y - 50 }
                                               
                                                --Roach
                                                DrawText(enemyTable[i].indicatorText, 15, pos.X + 20, pos.Y, (enemyTable[i].ready and ARGB(255, 0, 255, 0)) or ARGB(255, 255, 220, 0))
                                                DrawText(enemyTable[i].damageGettingText, 15, pos.X + 20, pos.Y + 15, ARGB(255, 255, 0, 0))
                                        end
               
                        end
              end        
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					OnCreateObj
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OnCreateObj(obj)
	if obj.name:find("TeleportHome") then
		Recalling = true
	end
end
 
function OnDeleteObj(obj)
	if obj.name:find("TeleportHome") or (Recalling == nil and obj.name == Recalling.name) then
		Recalling = false
	end
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				  Auto Spells
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function AutoW()
      if Menu.Wsett.AutoW and not Recalling then
                if (myHero:CanUseSpell(_W) == READY) then
                        if myHero.mana < (myHero.maxMana*(Menu.Wsett.AutoW2*0.01)) then
                                CastSpell(_W)
						end
				end
		end
end

function Zhonya()
if Menu.Others.Zhonya then
	if zhonyaready and ((myHero.health/myHero.maxHealth)*100) < Menu.Others.ZhonyaHp then
		CastSpell(zhonyaslot)
	end
end
end


--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			        Farming
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function FarmQ()
	if Menu.Farm.FarmQ and qrdy then
		for index, minion in pairs(minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC).objects) do
				local MinionHealth_ = minion.health
				local qDmg = getDmg("Q",minion,  GetMyHero()) + getDmg("AD",minion,  GetMyHero())
					if qDmg >= MinionHealth_ then
                    CastSpell(_Q, minion)
					end
		end
    end
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Lag free circles (by barasia, vadash and viseversa)
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end
