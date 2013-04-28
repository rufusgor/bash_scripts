#!/bin/bash
# Скрипт для создания bare и обычного git репозитория
ID=`id -un`
HOST=`hostname`

if [ $# -eq 0 ]; then
        echo "usage : $0 name_of_repository";
    else
        echo "repository name: $1"

REPONAME=$1

#создание bare репозитория
mkdir /git/$REPONAME.git
cd /git/$REPONAME.git
git --bare init

# start - добавляем хуки # > hooks/post-update
echo "
echo '**** Внесение изменения в $REPONAME [$REPONAME post-update hook]'
echo

cd /var/www/$REPONAME || exit
unset GIT_DIR
git pull $REPONAME master

exec git-update-server-info" > hooks/post-update
# end ###########

chmod +x hooks/post-update

#создание обычного репозитория
mkdir /var/www/$REPONAME
cd /var/www/$REPONAME
git init

# start - добавляем хуки # > .git/hooks/post-commit
echo "
#!/bin/sh

echo
echo '**** Внесение изменения в $REPONAME.GIT [$REPONAME's post-commit hook]'
echo

git push $REPONAME" > .git/hooks/post-commit
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

echo "репозиторий доступен по пути: $ID@$HOST:/git/$REPONAME.git"
fi
