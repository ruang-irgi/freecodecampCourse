#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  echo -e "\nList of services:"
  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  SELECT_SERVICE
}
SELECT_SERVICE(){
  #select service
  echo -e "\nSelect a service(1/2/3):"
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #jika tidak ada
  if [[ -z $SERVICE_ID_RESULT ]]
  then MAIN_MENU
  else
    #input phone 
    echo -e "\nInput your phone:"
    read CUSTOMER_PHONE
    PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #jika tidak ada 
    if [[ -z $PHONE_RESULT ]]
    then
      #input name
      echo -e "\nInput your name:"
      read CUSTOMER_NAME
      INSERT_TO_CUSTOMERS=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #tambahkan customer id, service id dan waktu ke appointments
    echo -e "\nInput your appointment's time:"
    read SERVICE_TIME
    INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $(echo $SERVICE_ID_RESULT | sed -E 's/^ +| +$//g') at $(echo $SERVICE_TIME | sed -E 's/^ +| +$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  fi
}
MAIN_MENU