#20001
.LoginR{
	pid 0 : integer
}


#21001 
.MatchR{
	type 0 : integer
}


#30001
.ErrorR{
	code 0 :integer
}

#1001
.MatchPlayer{
	pid 0: integer
	name 1 : string
	headIcon 2: string
}


#31001 
.MatchP{
	team1 0 : *MatchPlayer
	team2 1 : *MatchPlayer
}

#31002
.MatchAckP{
}
