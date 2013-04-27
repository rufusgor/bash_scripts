#!/bin/bash
#

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
chmod -R 777 ./
chown -R www-data:www-data ./


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
echo "repo name $REPONAME" > README.md
chmod -R 777 ./
chown -R www-data:www-data ./ 

git add .
git commit -m "Импорт всех существующих файлов $REPONAME"

git remote add $REPONAME /git/$REPONAME.git
git remote show $REPONAME
git push $REPONAME master

chmod -R 777 /var/www/$REPONAME
chown -R www-data:www-data /var/www/$REPONAME
chmod -R 777 /git/$REPONAME.git
chown -R www-data:www-data /git/$REPONAME.git

fi
