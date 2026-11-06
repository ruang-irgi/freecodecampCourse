#!/bin/bash
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
  if [[ ! $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1' OR symbol ='$1'")
  else
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
  fi
  if [[ $ATOMIC_NUMBER_RESULT ]]
  then 
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER_RESULT")
    ATOMIC_DATA=$($PSQL "SELECT * FROM properties WHERE atomic_number = $ATOMIC_NUMBER_RESULT")
    echo "$ATOMIC_DATA" | while IFS='|' read AN AM MPC BPC TYPE_ID
    do
      ANAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER_RESULT")
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
      echo "The element with atomic number $AN is $ANAME ($SYMBOL). It's a $TYPE, with a mass of $AM amu. $ANAME has a melting point of $MPC celsius and a boiling point of $BPC celsius."
    done
  else
    echo "I could not find that element in the database."
  fi
fi
