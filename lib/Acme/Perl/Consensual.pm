
# http://upload.wikimedia.org/wikipedia/commons/4/4e/Age_of_Consent_-_Global.svg
my %age_map = (
	bo => { puberty => 1 },
	ao => { age => 12 },
	(map { $_ => { age => 13 } } qw(
		ar bf es jp km kr ne
	)),
	(map { $_ => { age => 14 } } qw(
		al at ba bd bg br cl cn co de 
		ec ee hr hu it li me mg mk mm 
		mo mw pt py rs sl sm td va
	)),
	(map { $_ => { age => 15 } } qw(
		aw cr cw cz dk fo fr gf gl gn 
		gp gr hn is kh ki kp la mc mf 
		mq pf pl re ro sb se si sk sx 
		sy tf th tv uy vc wf
	)),
	(map { $_ => { age => 16 } } qw(
		ad ag am as ax az bb be bh bm 
		bn bq bs bw by bz ca cc ch ck 
		cm cu dm dz fi fj gb ge gh gi 
		gu gw gy hk il im in je jm jo 
		ke kg kn ky kz lc lk ls lt lu 
		lv md mh mn mr ms mu my mz na 
		nf nl no np nz pg pn pr pw ru 
		sg sj sn sr sz tj tm to tt tw 
		ua um uz ve vu ws za zm zw
	)),
	(map { $_ => { age => 17 } } qw(
		cy ie nr
	)),
	(map { $_ => { age => 18 } } qw(
		bi bj bt cd dj do eg er et ga 
		gm gq gt ht lb lr ma ml mt ng 
		ni pa pe ph ss rw sc sd so sv 
		tr tz ug vi vn
	)),
	id => { age => 19 },
	tn => { age => 20 },
	(map { $_ => { married => 1 } } qw(
		ae af ir kw mv om pk qa sa ye
	)),
	(map { $_ => undef } qw(
		ai bl bv cf cg ci cv cx eh fk 
		fm gd gg hm io iq ly mp nc nu 
		pm ps sh st tc tg tl vg
	)),
	# XXX: Here we need to drop down to state level.
	(map { $_ => undef } qw(
		au mx us
	)),
);

