#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# delete tables before to populate them
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# read data for `teams`:
# year,round,winner,opponent,winner_goals,opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != 'winner' && $OPPONENT != 'opponent' ]]
  then
    # if don't find $WINNER in `teams` add it to the table
    WINNER_IN_TEAMS="$($PSQL "SELECT name FROM teams WHERE name = '$WINNER';")"
    if [[ -z $WINNER_IN_TEAMS ]]
    then
      echo "$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER');")"
    fi
    # if don't find $OPPONENT in `teams` add it to the table
    OPPONENT_IN_TEAMS="$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT';")"
    if [[ -z $OPPONENT_IN_TEAMS ]]
    then
      echo "$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT');")"
    fi
  fi
done

# read data for `games`:
# year,round,winner,opponent,winner_goals,opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    # find id values for winner and opponent
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")"

    # fill a row with the data
    echo "$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")"
  fi
done
