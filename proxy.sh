#!/bin/sh

PROXY_HOST=localhost
PROXY_PORT=61111

SSHD_HOST=host.ru
SSHD_USER=root
SSHD_PORT=22

COMMAND="ssh -q -f -N -D $PROXY_PORT $SSHD_USER@$SSHD_HOST -p$SSHD_PORT"

if nc -z $PROXY_HOST $PROXY_PORT
then
    echo "Proxy on $PROXY_HOST:$PROXY_PORT up!"
	#echo "ssh -q -f -N -D $PROXY_PORT $SSHD_USER@$SSHD_HOST -p$SSHD_PORT"
else
    echo "Proxy on $PROXY_HOST:$PROXY_PORT is down"
	killall ssh 2&>1
	$COMMAND
fi

