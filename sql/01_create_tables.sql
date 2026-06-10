create type round_type as enum ('semi-final', 'semi-final-1', 'semi-final-2', 'final');

create table bookmakers (
	year integer,
	round round_type,
	country varchar(10),
	bookmaker varchar(100),
	odds numeric
);

create table contestants (
	year integer,
	country varchar(10),
	composers text,
	lyricists text,
	lyrics text,
	song varchar(200),
	performer varchar(100),
	youtube_url text,
	semifinal_number integer,
	semifinal_running_order integer,
	semifinal_jury_points integer,
	semifinal_televoting_points integer,
	semifinal_total_points integer,
	semifinal_place integer,
	final_running_order integer,
	final_jury_points integer,
	final_televoting_points integer
);

create table countries (
	country varchar(10) primary key,
	country_name varchar(100), 
	region varchar(100)
);

create table jurors (
	year integer,
	round round_type,
	from_country varchar(10),
	A integer,
	B integer,
	C integer,
	D integer,
	E integer,
	to_country varchar(10)
);

create table votes (
	year integer,
	round round_type,
	from_country varchar(10),
	to_country varchar(10),
	total_points integer,
	televoting_points integer,
	jury_points integer
);
