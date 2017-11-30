local M = {}

function M.genClassTag()
	local all = {}

	local dbBagTbl = require("game.db.dbBagTbl")
	all.BagTbl = dbBagTbl.newBagTbl(1,1)
	local dbHeroTbl = require("game.db.dbHeroTbl")
	all.HeroTbl = dbHeroTbl.newHeroTbl(10000001,0)
	local dbUserPlayerTbl = require("game.db.dbUserPlayerTbl")
	all.PlayerTbl = dbUserPlayerTbl.newPlayerInfo(0,"aa")
	all.UserTbl = dbUserPlayerTbl.newUserInfo(0,"","pwd")
	local dbShopTbl = require("game.db.dbShopTbl")
	all.ShopTbl = dbShopTbl.newShopTbl(0,0,0)
	local dbBuildTbl = require("game.db.dbBuildTbl")
	all.BuildTbl = dbBuildTbl.newBuildTbl(0,0,0,0,0,0)
	local dbCityTbl = require("game.db.dbCityTbl")
	all.CityTbl = dbCityTbl.newCityTbl(0,0,0,0,0,0,0,0)

	local enum = require("game.config.enum")
	all.enum = enum

	local wtbl = {}
	for k,v in pairs(all) do
		for kk,_ in pairs(v) do
			wtbl[#wtbl+1] = k.."."..kk
		end
	end
	local wstr = table.concat(wtbl,"\n")
	local wfn = "classtags"
	local wf = io.open(wfn,"w")
	wf:write(wstr)
	wf:close()
	print("finish")
end

return M
