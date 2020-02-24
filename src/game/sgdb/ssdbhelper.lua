--local skynet = require "skynet"
--local M = {}

--------------------------------db name conf ---------------------- begin
--local name = require("game.db.keyNameCfg")

--local function getArmyKey(pid)
	--return "p"..pid.."_"..name.army
--end

--local function getEnemyKey(pid)
	--return "p"..pid.."_"..name.enemy
--end

--------------------------------db name conf ----------------------end

---------------------------------db oper -----------------------begin
--local function setTable(key,t)
	--local ssdbutils = require("utils.db.ssdbutils")
	--ssdbutils.sendExecute("hsetalls",key,t)
--end


----function M.setEnemyArr(pid,enemyTblT)
	----local key = getEnemyKey(pid)
	----return setTable(key,enemyTblT)
----end

------army begin
----function M.getArmyTbl(pid,armyId)
	----local ssdbutils = require("utils.db.ssdbutils")
	----local key = getArmyKey(pid)
	----local t = ssdbutils.execute("hgets",key,armyId)
	----return t
----end

----function M.setArmyTbl(pid,armyTbl)
	----local ssdbutils = require("utils.db.ssdbutils")
	----local key = getArmyKey(pid)
	----return ssdbutils.setendExecute("hsets",key,armyTbl.armyId,armyTbl)
----end

----function M.getArmyTblT(pid)
	----local ssdbutils = require("utils.db.ssdbutils")
	----local key = getArmyKey(pid)
	----local t = ssdbutils.execute("hgetalls",key)
	----return t
----end

----function M.setArmyTblT(pid,armyTblT)
	----local key = getArmyKey(pid)
	----return setTable(key,armyTblT)
----end
----army end

---------------------------------db oper -----------------------end


--return M
