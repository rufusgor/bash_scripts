#!/bin/bash
HOST=yandex.ru
PORT=80
if nc -z $HOST $PORT
then
        echo "Port ${PORT} is up"
else    
        echo "Port ${PORT} is down"
fi