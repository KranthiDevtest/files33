#!/bin/sh
# 
#
username=KranthiDevtest
repo_name=Sites3

if [ "$username" = "-h" ]; then
echo "USAGE:"
echo "1 argument - your username in gitlab"
echo "2 argument - name of the repo you want to create"
exit 1
fi

if [ "$username" = "" ]; then
echo "Could not find username, please provide it."
exit 1
fi

dir_name=`basename $(pwd)`

if [ "$repo_name" = "" ]; then
read -p "Repo name (hit enter to use '$dir_name')? " repo_name
fi

if [ "$repo_name" = "" ]; then
repo_name=$dir_name
fi

# ask user for password
read -s -p "Enter Password: " password

request=`curl --request POST "https://api.github.com/session?login=$username&password=$password"`

if [ "$request" = '{"message":"401 Unauthorized"}' ]; then
echo "Username or password incorrect."
exit 1
fi

token=`echo $request | cut -d , -f 28 | cut -d : -f 2 | cut -d '"' -f 2`

echo -n "Creating GitLab repository '$repo_name' ..."
curl -H "$username"https://api.github.com/user/repos -d '{"name":"'$repo_name'"}' > /dev/null 2>&1
echo " done."

# 2>$1 means that we want redirect stderr to stdout

echo -n "Pushing local code to remote ..."
git init
echo "gitlab-init-remote.sh" > .gitignore
echo ".gitignore" >> .gitignore
git config --global core.excudefiles ~/.gitignore_global
git config --global user.name=$username
git add .
git commit -m "first commit"
git remote add origin https://api.github.com/$username/$repo_name.git > /dev/null 2>&1
git push -u origin master > /dev/null 2>&1
echo " done."



