local str = [[
.Cmd{
	pid 0 : integer
	cmd 1 : integer
	p1 2 : integer
	p2 3 : integer
	p3 4 : integer
	p4 5 : string
	p5 6 : string
}
.login{
	err 0 : integer
	pid 1 : integer
	ip 2 : string
	port 3 : string
}
.Build{
	buildId 0 : integer
	heroId 1 : integer
	heroAttrMul 2 : integer
	cityId 3 : integer
	level 4 : integer
}
.HeroInCityTbl{
	heroId 0 : integer
	status 1 : integer
	values 2 : *integer
}
.CityInfo{
	cityId 0 : integer
	level 1 : integer
	bleed 2 : integer
	mayor 3 : integer
	res 4 : *integer
	status 5 : integer
	heroInCityTblT 6 : *HeroInCityTbl(heroId)
	timeIdx 7 : integer
	workerTimestamp 8 : *integer
}
.player_info{
	level 0 : integer
	exp 1 : integer
	nickname 2 : string
	baseRes 3 : *integer  #(BASE_RES_TYPE作为index)
	pid 4 : integer
}
.HeroInfo{
	heroId 0 : integer
	lv 1 : integer
	exp 2 : integer
	star 3 : integer
	askilllv 4 : *integer
	alv 5 : integer
	aweapon 6 : integer  #bitmask   1 << (1~4)
	armyId 7 : integer
}
.hero_list{
	heroInfoT 0 : *HeroInfo(heroId)
}
.add_hero_exp{
	err 0 : integer
	level 1 : integer
	exp 2 : integer
}
.Bag{
	itemId 0 : integer
	count 1 : integer
}
.get_bag_list{
	bagT 0 : *Bag(itemId)
}

.get_city_builds{
	buildT 0 : *Build(buildId)
}
.get_citys{
	cityT 0 : *CityInfo(cityId)
}
.build_levelup{
	err 0 : integer
	workIdx 1 : integer
	timestamp 2 : integer
}
.buy_item{
	err 0 : integer
	baseResEnum 1 : integer
	baseResValue 2 : integer
}
.ErrMsg{
	err 0 : integer
}

# battle begin
.UpdateMapObjectTbl{
	moId 0 : integer
	idxMasks 1 : *integer
	values 2 : *integer
}
.BattleCommonCmd{
	err 0 : integer
	updateMapObjectTblT 1 : *UpdateMapObjectTbl(moId)
}
# battle end

]]
return str
