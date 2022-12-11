CREATE TABLE teams(
team_id serial,
team_initial varchar(10) NOT null UNIQUE,
Country varchar(100) NOT null UNIQUE,
PRIMARY KEY(team_id)
);
	
CREATE TABLE referees(
referee_id serial,
name varchar(100) NOT NULL,
country_initial varchar(10) NOT NULL, 
PRIMARY KEY(referee_id)
);

CREATE TABLE stadiums(
stadium_id serial,
Stadium varchar(50) NOT NULL,
City varchar(50) NOT NULL,
PRIMARY KEY(stadium_id)
);

CREATE TABLE worldcup(
worldcup_year int,
Country varchar(100) NOT NULL,
GoalsScored int NOT NULL,
QualifiedTeams int NOT NULL,
MatchesPlayed int NOT NULL,
Attendance int NOT NULL,
PRIMARY KEY(worldcup_year)
);

CREATE TABLE worldcup_ranking(
Year int,
team_id int,
ranking varchar(50) NOT NULL,
CONSTRAINT chk_ranking CHECK (ranking IN ('Winner','Runners_up','Third','Fourth','Not_ranked')),
PRIMARY KEY(Year,team_id),
FOREIGN KEY(Year) REFERENCES worldcup(worldcup_year),							  
FOREIGN KEY(team_id) REFERENCES teams(team_id)						  
);


CREATE TABLE matches(
MatchID int,
Year int NOT NULL,
home_team_goals int NOT NULL,
away_team_goals int NOT NULL,
half_time_home_team_goals int NOT NULL,
half_time_away_team_goals int NOT NULL,
Attendance int NOT NULL,
home_team_id int,
away_team_id int,
stadium_id int,
PRIMARY KEY(MatchID),
FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id),
FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
FOREIGN KEY (away_team_id) REFERENCES teams(team_id),
FOREIGN KEY (Year) REFERENCES worldcup(worldcup_year)
);
	

CREATE TABLE matches_referees(
MatchID int,
referee_id int,
referee_role varchar(100),
CONSTRAINT chk_referee_role CHECK (referee_role IN ('Main','Linesman')),
PRIMARY KEY(MatchID,referee_id),
FOREIGN KEY(MatchID) REFERENCES matches(MatchID),
FOREIGN KEY(referee_id) REFERENCES referees(referee_id)
);
	
CREATE TABLE players(
player_id serial,
player_name varchar(100) NOT NULL,
PRIMARY KEY(player_id)
);
	
CREATE TABLE match_players(
MatchID int,
player_id int,
team_id int,
coach_name varchar(100) NOT NULL,
line_up char(1) NOT NULL,
shirt_no int NOT NULL,
Position varchar(5),
PRIMARY KEY(MatchID,player_id),
FOREIGN KEY(MatchID) REFERENCES matches(MatchID),
FOREIGN KEY(player_id) REFERENCES players(player_id),
FOREIGN KEY(team_id) REFERENCES teams(team_id)
);

	
CREATE TABLE goals_scored(
MatchID int,
player_id int,
event varchar(10) NOT NULL,
PRIMARY KEY(MatchID,player_id,event),
FOREIGN KEY(MatchID) REFERENCES matches(MatchID),
FOREIGN KEY(player_id) REFERENCES players(player_id)
);








