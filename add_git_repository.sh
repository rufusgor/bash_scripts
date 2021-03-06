#!/bin/bash
# Скрипт для создания bare и обычного git репозитория
ID=`id -un`
HOST=`hostname -d`

if [ $# -eq 0 ]; then
        echo "usage : $0 name_of_repository"
    else
        echo "repository name: $1"

REPONAME=$1

#создание bare репозитория
mkdir /git/$REPONAME.git
cd /git/$REPONAME.git
git --bare init

# start - добавляем хуки # > hooks/post-update
echo "
#!/bin/bash
echo '**** Внесение изменений в $REPONAME [$REPONAME post-update hook]'
echo
cd /var/www/$REPONAME || exit
unset GIT_DIR
git pull $REPONAME master
exec git-update-server-info"
# end ###########

chmod +x hooks/post-update

#создание обычного репозитория
mkdir /var/www/$REPONAME
cd /var/www/$REPONAME
git init
git config receive.denyCurrentBranch ignore

# start - добавляем хуки # > .git/hooks/post-commit
echo "
#!/bin/sh
echo '**** Внесение изменений в $REPONAME.GIT [$REPONAME post-commit hook]'
echo
git push $REPONAME"
# end ###################

chmod +x .git/hooks/post-commit

#добавляем README файл
echo "repo name $REPONAME" > README.md


git add .
git commit -m "Импорт всех существующих файлов $REPONAME"

#синхронизация репозиториев
git remote add $REPONAME /git/$REPONAME.git
git remote show $REPONAME
git push $REPONAME master

chmod -R 777 /var/www/$REPONAME
chown -R www-data:www-data /var/www/$REPONAME
chmod -R 777 /git/$REPONAME.git
chown -R www-data:www-data /git/$REPONAME.git

echo "репозиторий доступен по: git clone $ID@$HOST:/git/$REPONAME.git"
fi
