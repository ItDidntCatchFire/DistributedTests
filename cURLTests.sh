#!/bin/bash
host=""
local=0
UserOneAPIKey=""
UserTwoAPIKey=""
Expected=""
codeForServer=8285836 # Put your code for test server here

if [ $# -eq 0 ]
 then
	host="http://distsysacw.azurewebsites.net/${codeForServer}/api/"
		printf "Clearing\n"
	if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}'other/clear' ) == 200 ]] 
	 then
		printf "Cleared"
	 else
		printf "Can't clear"
		exit
	fi
	
  else
	host="https://localhost:5001/api/"
	local=1
    
    # go to project route and build it
	cd ..
	dotnet build
	
    # go to the database and reset it
	cd Data
	export PATH="$PATH:$HOME/.dotnet/tools/" 
	dotnet ef database drop -f 
	dotnet ef database update
    
    #Go to the server and run it
	cd ../DistSysACW
	dotnet run --no-build > /dev/null &
	PROC_ID=$!
	sleep 2
	printf "process ID: "$PROC_ID"\n"
	
	#Go back to the test folder so the results are written there
	cd ../DistributedTests
fi

clear
set -e
trap error SIGHUP

function error()
{
	if [[ $local == 1 ]] 
	 then
		kill $PROC_ID
	 fi
	
	printf "ERROR\n"
	printf "What actually came back\n"
	cat results.txt
	exit 1
}

printf "Task 1 \n"
printf "\tHello World\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}talkback/hello) == 200 ]]
then 
    var=$(<results.txt)
    if [[ "Hello World" != $var ]] && [[ "hello world" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tSort working\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}'talkback/sort?integers=8&integers=2&integers=5' ) == 200 ]]
then 
    var=$(<results.txt)
    if [ "[2,5,8]" != $var ]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tSort empty\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}'talkback/sort?' ) == 200 ]] 
then 
    var=$(<results.txt)
    if [ "[]" != $var ]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tSort NaN\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}'talkback/sort?integers=8&integers=2&integers=a' ) == 400 ]]
then 
    var=$(<results.txt)
    if [[ $var != "Bad Request" ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "Task 4 \n"
printf "\tNo username Passed\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}user/new?username=) == 200 ]]
then 
    var=$(<results.txt)
    if [[ "\"False - User Does Not Exist! Did you mean to do a POST to create a new user?\"" != "$var" ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tUser that does not Exist\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}user/new?username=UserOne) == 200 ]]
then 
    var=$(<results.txt)
    if [[ "\"False - User Does Not Exist! Did you mean to do a POST to create a new user?\"" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tAdding 'UserOne'\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d '"UserOne"') == 200 ]]
then 
	var=$(<results.txt)
	UserOneAPIKey=$var
	printf "\t\t User One APIKEY: $UserOneAPIKey\n" 
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tUser that does Exist\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}user/new?username=UserOne) == 200 ]]
then 
    var=$(<results.txt)
    if [[ "\"True - User Does Exist! Did you mean to do a POST to create a new user?\"" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tAdding Existing username 'UserOne'\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d '"UserOne"') == 403 ]]
then 
	var=$(<results.txt)
	if [[ "\"Oops. This username is already in use. Please try again with a new username.\"" != $var ]] && [[ "Oops. This username is already in use. Please try again with a new username." != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tAdding no username\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d '') == 400 ]]
then 
	var=$(<results.txt)
	if [[ "Oops. Make sure your body contains a string with your username and your Content-Type is Content-Type:application/json" != $var ]] && [[ "\"Oops. Make sure your body contains a string with your username and your Content-Type is Content-Type:application/json\"" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

# printf "\e[31m\tAdding [SPACE] as username\n\e[m"
# if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d ' ') == 200 ]]
# then 
# 	var=$(<results.txt)
#     printf "\t\t APIKEY: $var\n" 
# else
#     printf "  http code Fail\n"
# 	kill -1 $$
# fi;

printf "Task 7 \n"
printf "\tDeleting a user (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -X DELETE -w '%{http_code}' ${host}user/RemoveUser?username=UserOne -H 'ApiKey: '$UserOneAPIKey'h') == 401 ]]
then 
	var=$(<results.txt)
	if [[ "\"Unauthorized. Check ApiKey in Header is correct."\" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tDeleting a non-existant user (UserZero)\n"
if [[ $(curl -s -k -o results.txt -X DELETE -w '%{http_code}' ${host}user/RemoveUser?username=UserZero -H 'ApiKey: '$UserOneAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "false" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;


printf "\tDeleting a user Authorized (User)\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d '"UserTwo"') != 200 ]]
then
    printf "\tUserTwo failed\n"
    kill -1 $$
else
    var=$(<results.txt)
	UserTwoAPIKey=$var
    printf "\t\t User Two APIKEY: $UserTwoAPIKey\n"
    if [[ $(curl -s -k -o results.txt -X DELETE -w '%{http_code}' ${host}user/RemoveUser?username=UserTwo -H 'ApiKey: '$UserTwoAPIKey) == 200 ]]
    then 
    	var=$(<results.txt)
    	if [[ "true" != $var ]]
    	then
            printf "Failed \n"
    		kill -1 $$
        fi;  
    else
        printf "  http code Fail\n"
    	kill -1 $$
    fi;
fi;

printf "Task 8 \n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/new -H 'Content-Type: application/json' -d '"UserTwo"') != 200 ]]
then
    printf "\tUserTwo failed\n"
    kill -1 $$
else
    var=$(<results.txt)
    UserTwoAPIKey=$var
    printf "\t\t User Two APIKEY: $UserTwoAPIKey\n"
fi;

printf "\tChanging UserTwo to Admin\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d '{"username": "UserTwo","role": "Admin"}') == 200 ]]
then 
	var=$(<results.txt)
	if [[ "DONE" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tChanging UserTwo to User\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d '{"username": "UserTwo","role": "User"}') == 200 ]]
then 
	var=$(<results.txt)
	if [[ "DONE" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tChanging UserTwo to User (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey'h' -H 'Content-Type: application/json' -d '{"username": "UserTwo","role": "User"}') == 401 ]]
then 
    var=$(<results.txt)
    if [[ "\"Unauthorized. Admin access only."\" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tChanging UserTwo to Admin (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey'h' -H 'Content-Type: application/json' -d '{"username": "UserTwo","role": "Admin"}') == 401 ]]
then 
    var=$(<results.txt)
    if [[ "\"Unauthorized. Admin access only."\" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tChanging non-existent (UserZero) to User\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d '{"username": "UserZero","role": "User"}') == 400 ]]
then 
	var=$(<results.txt)
	if [[ "NOT DONE: Username does not exist" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tChanging non-existant (UserZero) to Admin\n"
if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d '{"username": "UserZero","role": "Admin"}') == 400 ]]
then 
	var=$(<results.txt)
	if [[ "NOT DONE: Username does not exist" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

# printf "\e[31m\tChanging role non JSON\n\e[m"
# if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d 'HELLO') == 400 ]]
# then 
# 	var=$(<results.txt)
# 	if [[ "NOT DONE: An error occured" != $var ]]
# 	then
#         printf "Failed \n"
# 		kill -1 $$
#     fi;  
# else
#     printf "  http code Fail\n"
# 	kill -1 $$
# fi;

printf "\tChanging role to King\n"
 if [[ $(curl -s -k -o results.txt -X POST -w '%{http_code}' ${host}user/ChangeRole -H 'ApiKey: '$UserOneAPIKey -H 'Content-Type: application/json' -d '{"username": "UserTwo","role": "King"}') == 400 ]]
 then 
    var=$(<results.txt)
 	if [[ "NOT DONE: Role does not exist" != $var ]]
 	then
         printf "Failed \n"
 		kill -1 $$
    fi;  
    else
        printf "  http code Fail\n"
        kill -1 $$
fi;


printf "Task 9 \n"
printf "\tProtected Hello (Admin)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/hello -H 'ApiKey: '$UserOneAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "Hello UserOne" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected Hello (User)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/hello -H 'ApiKey: '$UserTwoAPIKey) == 200 ]]
then 
	var=$(<results.txt)
    if [[ "Hello UserTwo" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected Hello (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/hello -H 'ApiKey: '$UserOneAPIKey'h') == 401 ]]
then 
	var=$(<results.txt)
    if [[ "\"Unauthorized. Check ApiKey in Header is correct."\" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected sha1 hello (Admin)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha1?message=hello -H 'ApiKey: '$UserOneAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "AAF4C61DDCC5E8A2DABEDE0F3B482CD9AEA9434D" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected sha1 hello (User)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha1?message=hello -H 'ApiKey: '$UserTwoAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "AAF4C61DDCC5E8A2DABEDE0F3B482CD9AEA9434D" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;


printf "\tProtected sha1 hello (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha1?message=hello -H 'ApiKey: '$APIKey'h') == 401 ]]
then 
	var=$(<results.txt)
    if [[ "\"Unauthorized. Check ApiKey in Header is correct."\" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected sha256 hello (Admin)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha256?message=hello -H 'ApiKey: '$UserOneAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected sha256 hello (User)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha256?message=hello -H 'ApiKey: '$UserTwoAPIKey) == 200 ]]
then 
	var=$(<results.txt)
	if [[ "2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824" != $var ]]
	then
        printf "Failed \n"
		kill -1 $$
    fi;  
else
    printf "  http code Fail\n"
	kill -1 $$
fi;


printf "\tProtected sha256 hello (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/sha256?message=hello -H 'ApiKey: '$APIKey'h') == 401 ]]
then 
	var=$(<results.txt)
    if [[ "\"Unauthorized. Check ApiKey in Header is correct."\" != $var ]]
    then
        printf "Failed \n"
        kill -1 $$
    fi;    
else
    printf "  http code Fail\n"
	kill -1 $$
fi;
printf "Task 11 \n"
printf "\tProtected Get Public Key (Admin)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/getpublickey?message=hello -H 'ApiKey: '$UserOneAPIKey) == 200 ]]
then 
    :
    # No idea what should go here
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected Get Public Key (User)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/getpublickey?message=hello -H 'ApiKey: '$UserTwoAPIKey) == 200 ]]
then
    :
    # No idea what should go here
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

printf "\tProtected Get Public Key (Unauthorized)\n"
if [[ $(curl -s -k -o results.txt -w '%{http_code}' ${host}protected/getpublickey?message=hello -H 'ApiKey: '$UserTwoAPIKey'h') == 401 ]]
then
    :
    # No idea what should go here
else
    printf "  http code Fail\n"
	kill -1 $$
fi;

if [[ $local == 1 ]] 
then
	kill $PROC_ID
else
	./$(basename $0) 1 && exit
fi

printf "Tests passed\n"

#$(curl -k -i -X OPTIONS http://distsysacw.azurewebsites.net/8285836/Api/protected/hello -H 'ApiKey: 1414aab0-fb56-4371-9686-6bd74238524d')
