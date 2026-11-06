#!/bin/bash
echo "Enter your username:"
read USERNAME
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PLAYER=$($PSQL "SELECT * FROM games WHERE username = '$USERNAME'")
if [[ -z $PLAYER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    IFS='|' read USERNAME GAMES_PLAYED BEST_GAME <<< "$PLAYER"
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
if [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then NUMBER_OF_GUESSES=1
  else NUMBER_OF_GUESSES=0
fi
until [[ $GUESS_NUMBER = $SECRET_NUMBER ]]
do
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then echo "That is not an integer, guess again:"
  elif (( GUESS_NUMBER > SECRET_NUMBER ))
  then 
    (( NUMBER_OF_GUESSES++ ))
    echo "It's higher than that, guess again:"
  elif (( GUESS_NUMBER < SECRET_NUMBER ))
  then
    (( NUMBER_OF_GUESSES++ ))
    echo "It's lower than that, guess again:"
  fi
  read GUESS_NUMBER
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

if [[ -z $PLAYER ]]
then 
  ADD_PLAYER=$($PSQL "INSERT INTO games(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
else
  if (( BEST_GAME < NUMBER_OF_GUESSES ))
    then BEST_GAME=$NUMBER_OF_GUESSES
  fi
  (( GAME_PLAYED++ ))
  UPDATE_PLAYER=$($PSQL "UPDATE games set games_played = $GAME_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
fi