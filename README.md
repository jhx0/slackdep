# slackdep
**slackdep.sh** goes over all binaries found on the system (For example: /usr/bin) and checks each of them for missing **shared libraries**.   
When the search phase is completed, **slackdep.sh** uses **slackpkg** to search for the missing packages in the repository.

## Usage
1. Clone/download this repository
2. Unpack/cd into the directory
3. Make sure slackdep.sh is executable
```
$ chmod +x slackdep.sh
```
4. Run slackdep
```
$ ./slackdep.sh
```

## Sample output
![image](https://user-images.githubusercontent.com/37046652/216820804-41ffb9ef-47d4-41da-9ff2-dfa4e52d19d3.png)

## Note:
Running **slackdep.sh** takes some time since there are many binaries shipped with **Slackware** in the default install. (In general, it is not long at all - just keep this in mind)   

**slackdep.sh** will work on pretty much any **Slackware** system. There is not dependency except the availability of **slackpkg** - which itself ships in the default install (**AP** set).
