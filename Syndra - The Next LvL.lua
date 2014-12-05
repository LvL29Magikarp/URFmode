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

local UPDATE_NAME = "Syndra - The Next LvL"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/LvL29Magikarp/URFmode/master/Syndra%20-%20The%20Next%20LvL.lua" .. "?rand=" .. math.random(1, 10000)
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


if myHero.charName ~= "Syndra" then return end

local SCRIPT_NAME = "Syndra - The Next LvL"

	require "VPrediction"
	
--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					Loading
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]
function OnLoad()
	Menu()
	VP = VPrediction()
	Info()
	Balls = {}
	BallCount = 0
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
	
	rrange = 675
	BallTable = 24
	havetarget = false
	for i=1, BallTable do
		Balls[i] = { pos = nil, time = nil, stunball = false, wball = false}
	end
	Minions = minionManager(MINION_ALL, 925, myHero)
end

function Info()
ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 950, true)
ts.name = "Syndra"
Menu:addTS(ts)
lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0

	qrdy, wrdy, erdy, rrdy = false, false, false, false
	
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Check
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OnTick()

	ts:update()
	Minions:update()
	
	qrdy = myHero:CanUseSpell(_Q) == READY 
	wrdy = myHero:CanUseSpell(_W) == READY
	erdy = myHero:CanUseSpell(_E) == READY
	rrdy = myHero:CanUseSpell(_R) == READY
	
	
	Target = ts.target

		if ValidTarget(Target) then
			Combo()
		end
		
		if Menu.Combo.Combo then 
			if Menu.Combo.OrbWalk then
				OrbWalk()
			end
		end

end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Menu
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]


function Menu()
	Menu = scriptConfig("Syndra - The Next LvL", "By LvL29Magikarp")
		
	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Menu.Combo:addParam("OrbWalk", "Orbwalking", SCRIPT_PARAM_ONOFF, false)
		
				
		
		
end

--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					  Combo
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]


function Combo()
if Menu.Combo.Combo then
UseItems(Target)
	UseW()
	UseR()
	UseQ()
	UseE()
end
end



--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			      Casting Spells
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function UseQ()
if qrdy and GetDistance(Target) <= 800 then
	CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.01, 200, 800, 1750, myHero)
		if HitChance >= 2 then
			if VIP_USER then Packet("S_CAST", { spellId = _Q, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
			else
			CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
end

function UseE()
if erdy and GetDistance(Target) <= 700 then
	CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.01, 50*math.pi/180, 700, 902, myHero)
		if HitChance >= 2 then
			if VIP_USER then Packet("S_CAST", { spellId = _E, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
			else
			CastSpell(_E, CastPosition.x, CastPosition.z)
			end
		end
end

function UseW()
if wrdy and GetDistance(Target) <= 925 then
	GrabObject()
		end
	if havetarget then
	CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.01, 200, 925, 1450, myHero)
		if HitChance >= 2 then
			if VIP_USER then Packet("S_CAST", { spellId = _W, toX = CastPosition.x, toY = CastPosition.z, fromX = CastPosition.x, fromY = CastPosition.z }):send() end
			else
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
		end
end

function UseR()
if rrdy and GetDistance(Target) <= 675 then
			CastSpell(_R, Target)
		end
end

function GrabObject()
	local Grab = nil
	if GetWObject() == nil then 
		return false
	else
		Grab = GetWObject() 
	end
	
	if Grab ~= nil and not havetarget then
		CastSpell(_W, Grab.x, Grab.z)
		return true
	end
	
end

function GetWObject()
	local crnobj = nil

	local crnbal = nil
	local ballnr = nil
	
	for i=1, BallTable do
		if Balls[i].pos ~= nil and GetDistance(Balls[i].pos) < 925  then
			crnbal = Balls[i]
			if crnobj == nil then crnobj = crnbal end
			if crnbal.time < crnobj.time then
				crnobj.wBall = false
				crnobj = crnbal
				crnobj.wBall = true

			end
					
		end

	end
	if crnobj ~= nil then
	
		return crnobj.pos
	else
	
	
		for i, AvaibleMinion in pairs(Minions.objects) do
			if AvaibleMinion ~= nil and AvaibleMinion.valid and AvaibleMinion.team == TEAM_ENEMY then 
				crnobj = AvaibleMinion 
			end
		end
		return crnobj

	end
	return nil
end

function OnCreateObj(obj)
	if BallCount < 0 then BallCount = 0 end
	
	if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
		elseif obj.name == "Worm12.1.1" then Nashor = obj
		elseif obj.name == "Dragon6.1.1" then Dragon = obj
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj end
	end
	
		if obj.name:find("Syndra_DarkSphere_idle") or obj.name:find("Syndra_DarkSphere5_idle") or obj.name:find("Seed") then
		
		BallCount = BallCount+1
			for i=1, BallTable do
				if Balls[i].pos == nil then
					Balls[i] = { pos = obj, time=os.clock() }
					return 
				end
			end
		end
end

function OnDeleteObj(obj)

	if obj ~= nil and obj.name ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = nil
		elseif obj.name == "Worm12.1.1" then Nashor = nil
		elseif obj.name == "Dragon6.1.1" then Dragon = nil
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = nil
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = nil
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = nil
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = nil end
	end

		if obj.name:find("Syndra_DarkSphere_idle") or obj.name:find("Syndra_DarkSphere5_idle") then
			for i=1, BallTable do
				if obj == Balls[i].pos then
					Balls[i].pos = nil
					Balls[i].time = nil
					Balls[i].stunball = false
					Balls[i].wball = false

				break end
			end
				BallCount = BallCount -1

		end
end

function Dfg()
	if dfgReady and ValidTarget(Target) and GetDistance(Target) < rrange then
	CastSpell(dfgSlot, Target)
	end
	if BRKReady and ValidTarget(Target) and GetDistance(Target) < rrange then
	CastSpell(BRKSlot, Target)
	end
end
--[[
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
			      Orbwalking
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
--]]

function OrbWalk()
	if ValidTarget(Target) and GetDistance(Target) <= 550 then
		if timeToShoot() then
			myHero:Attack(Target)
		elseif heroCanMove()  then
			moveToCursor()
		end
	else
		moveToCursor()
		
	end
end

function trueRange()
	return myHero.range + GetDistance(myHero.minBBox)
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function timeToShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function moveToCursor()
	if GetDistance(mousePos) > 1 or lastAnimation == "Idle1" then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end	
end

function getHitBoxRadius(unit)
	if unit ~= nil then 
		return GetDistance(unit.minBBox, unit.maxBBox)/2
	else
		return 0
	end
end

function OnProcessSpell(object,spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000		
		end
	end
	if spell.name:find("SyndraW") then
			havetarget = true
	end
end

function OnLoseBuff(unit, buff)

	if unit.isMe then
		if buff.name:find("syndrawtooltip") then
			havetarget = false
		end
	end

end

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
