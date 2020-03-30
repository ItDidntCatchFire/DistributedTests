# DistributedTests
A test script for Hull Uni Distributed systems coursework 2020
This currently only tests the servers functionality but the client might be added eventually.

**This will drop and rebuild your database whenever it is run!!**
**Passing these tests does not guarantee anything**

**John is cool with you using it :)**

![Test folder location](https://cdn.discordapp.com/attachments/690586605064552459/694020432009101312/unknown.png)

## What will you need
- [Git bash](https://gitforwindows.org/) if you are using Windows as this is a shell script 
- dotnet-ef this can be installed with `dotnet tool install --global dotnet-ef`
## How to install
### SVN
Git pull or unzip the repo to the project route

### git
If you are using git then you will need to add this repo as a submodule with `git submodule add https://github.com/ItDidntCatchFire/DistributedTests`

It should look like this when you have finished
![Test folder location](https://cdn.discordapp.com/attachments/690586605064552459/693999547378171945/unknown.png)

## How to use
- Go to the DistributedTests Folder
- Open CodeForServer.txt and put your number in there 
- Put `./curlTests.sh` in into the command line
- This will run the test script against the test server and then your own server
- If you want to run it only aginst your own server then put `./curlTests.sh 1` to run the test script instead
- The test script will tell you what your server returned and what it was expecting
- If you run into any problems raise them as an issue on this repo don't @ me in the discord
