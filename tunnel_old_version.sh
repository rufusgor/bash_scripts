#!/bin/bash

LISTENING_HOST=127.0.0.1
LISTENING_TOPORT=22
LISTENING_ONPORT=23

SSHD_HOST=host.ru
SSHD_USER=root
SSHD_PORT=22

# $COMMAND is the command used to create the reverse ssh tunnel
COMMAND="ssh -c aes256-ctr -f -N -R $LISTENING_ONPORT:$LISTENING_HOST:$LISTENING_TOPORT $SSHD_USER@$SSHD_HOST"
# Is the tunnel up? Perform two tests:

# 1. Check for relevant process ($COMMAND)
pgrep -f -x "$COMMAND" > /dev/null 2>&1 || $COMMAND

# 2. Test tunnel by looking at "netstat" output on $REMOTE_HOST
ssh $SSHD_USER@$SSHD_HOST -p $SSHD_PORT netstat -an 2>/dev/null | egrep "tcp.*:$LISTENING_PORT.*LISTEN" \
   > /dev/null 2>&1
if [ $? -ne 0 ] ; then
   pkill -f -x "$COMMAND"
   $COMMAND
fi
