/* find all the gk who played in the world cup and their team */

SELECT table5.player_name, teams.country
FROM
(
SELECT p.player_name, table4.team_id
FROM 
(
	SELECT player_id, max(team_id) AS team_id
	FROM match_players
	WHERE position = 'GK'
	GROUP BY player_id
) table4 
JOIN players p ON p.player_id = table4.player_id
) table5 
JOIN teams ON teams.team_id = table5.team_id

/* most goals scored ranked by players during the world cup from */
SELECT table1.player_id,p.player_name,table1.goals
FROM 
(
	SELECT player_id, count(event) AS goals
	FROM goals_scored
	GROUP BY player_id
) AS table1
JOIN players p ON p.player_id = table1.player_id
ORDER BY goals DESC


/* Find the top four countries(including ties) that has won the most world cup championship*/
SELECT *
FROM
(SELECT t.country, table2.count,rank() OVER (ORDER BY table2.count DESC) as s_rank
FROM
(
SELECT team_id, count(ranking)
FROM worldcup_ranking
WHERE ranking = 'Winner'
GROUP BY team_id
) AS table2
JOIN teams t ON t.team_id = table2.team_id
) table10
WHERE s_rank <=4






/* find which world cup year's final has the most attendance*/

SELECT year, MAX(attendance) AS attendance
FROM matches
WHERE stage = 'Final'
GROUP BY year
ORDER BY attendance DESC


/* find average attendance for each country*/

SELECT t.country,table8.average_attendance
FROM 
(
SELECT table7.away_team_id, (table7.sumx+table7.sumy)/(table7.countx+table7.county) AS average_attendance
FROM(
SELECT*
FROM(
SELECT away_team_id, SUM(attendance) AS sumx, COUNT(attendance) AS countx
FROM matches
GROUP BY away_team_id 
) AS away
FULL JOIN (SELECT home_team_id, SUM(attendance) AS sumy, COUNT(attendance) AS county
FROM matches
GROUP BY home_team_id) AS home on home.home_team_id = away.away_team_id
) table7
) table8
JOIN teams t ON t.team_id = table8.away_team_id
WHERE table8.average_attendance IS NOT NULL
ORDER BY table8.average_attendance DESC


/* find how many times each ref havve been the main ref and linesman*/
SELECT referees.name,table12.main,table12.linesman
FROM(
SELECT linesman.referee_id, main.main, linesman.linesman
FROM(
SELECT referee_id, count(referee_role) AS main
FROM matches_referees
WHERE referee_role = 'Main'
GROUP BY referee_id) main
FULL JOIN(
SELECT referee_id, count(referee_role) AS linesman
FROM matches_referees
WHERE referee_role = 'Linesman'
GROUP BY referee_id
) linesman ON linesman.referee_id= main.referee_id
) table12
JOIN referees ON referees.referee_id = table12.referee_id
WHERE table12.main IS NOT NULL
ORDER BY table12.main DESC


/*
Query 4
The final four teams in each world cup and their toal goals scored in the world cup and goals scored as a percent of total goals by the final four
*/

with team_base as
(
    select
        year,
        home_team_id as team_id,
        home_team_goals as goals
    from matches
    union
    select 
        year,
        away_team_id as team_id,
        away_team_goals as goals
    from matches
),
target_team as
(
    select
        year,
        team_id
    from worldcup_ranking
    where ranking in ('Winner','Runners_up','Third','Fourth')
),
stat as(
    select
        team_base.year,
        team_base.team_id,
        sum(goals) as goal_total
    from team_base
    join target_team 
        on team_base.year = target_team.year 
        and team_base.team_id = target_team.team_id
    group by team_base.year,team_base.team_id
)
select
    year,
    team_initial,
    goal_total,
    annualGoalsScored,
    ROUND(goal_total/annualGoalsScored,4) as goal_contribution
 from 
 (
     select 
         *, 
         sum(goal_total) over(partition by year) as annualGoalsScored
     from stat
  ) A
 join teams on a.team_id = teams.team_id
 ORDER BY year DESC,goal_contribution DESC
 
 
/*
Query 7
Home teams win by stadium 
*/
SELECT stadiums.stadium,table11.home_win_times
FROM(
select
    stadium_id,
    sum(
            case when home_team_goals > away_team_goals then 1 
            else 0 
          end
        ) as home_win_times
from matches
group by stadium_id
)table11
JOIN stadiums ON stadiums.stadium_id = table11.stadium_id
ORDER BY table11.home_win_times DESC

/*
Query 8
 Find highest attendence for a single match by each worldcup year
*/

with 
base as
(
    select
        matches.year,
        matchID,
        stage,
        home_team_id,
        away_team_id,
        matches.stadium_id,
        matches.Attendance,
        City,
        Country,
        rank() over(partition by year order by matches.Attendance desc) as r
    from matches
    join stadiums on stadiums.stadium_id = matches.stadium_id
    join worldcup on worldcup.worldcup_year = matches.year
)
select
    year,
    Country,
    City,
    stadium_id,
    stage,
    matchID,
    home_team_id,
    away_team_id,
    Attendance
from base
where r = 1

/* Find how many times countries have hosted world cup*/

SELECT country, count(country) AS hosted_times
FROM worldcup
GROUP BY country
ORDER BY hosted_times DESC


