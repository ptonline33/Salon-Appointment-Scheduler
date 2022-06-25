#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "select * from services")
  if [[ -n $SERVICES ]]
  then
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done
  #echo -e "\nPlease choose from the selection:"
  #echo -e "\n1) Haircut\n2) Highlights\n3) Threading\n4) Exit"
  read SERVICE_SELECTION
  SERVICE=$($PSQL "select name from services where service_id=$SERVICE_SELECTION")
  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?" 
  else
    MAKE_APPOINTMENT "$SERVICE"
  fi
fi
}

MAKE_APPOINTMENT() {
  
  #echo -e "\nWhich service id was selected: "
  #read SERVICE_ID
  #SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID")
  # get phone number
  echo -e "\nPlease provide your phone number:"
  read PHONE

  # check if phone number is in customers db
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # get customer name & add to customers DB
    echo -e "\nPlease provide your name: "
    read NAME
    INSERT_CUSTOMER="$($PSQL "insert into customers(phone,name) values('$PHONE','$NAME')")"
    if [[ $INSERT_CUSTOMER="INSERT 0 1" ]]
    then
      CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$NAME' AND phone='$PHONE'")
    fi
  fi
    # ask what time they would like service?
    # get service_time
    # create record in appointments
    # send a message and back to main_menu
    NAME=$($PSQL "select name from customers where customer_id=$CUSTOMER_ID")
    echo -e "\nWhat time would you like service?"
    read SERVICE_TIME
    APPOINTMENT_RECORD="$($PSQL "insert into appointments(service_id,customer_id,time) values($SERVICE_ID,$CUSTOMER_ID,'$SERVICE_TIME')")"
    if [[ $APPOINTMENT_RECORD="INSERT 0 1" ]]
    then
      MAIN_MENU "I have put you down for a$1 at $SERVICE_TIME,$NAME."
    fi
  }

MAIN_MENU


