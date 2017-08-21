# pstools
Some Powershell tools for Monitors in Dynatrace, and other usage.

# eventlog2.ps1
This script will check for events based on the parameters given below, it will write the last searched position into an xml file, and will continue from there on the next run.

powershell -file \<location of script\> -computername \<computername\> -source \<source\> -eventid \<eventid\> -folder \<folder\> -log \<log\> -seed_depth \<max number of log entries\> -instanceid \<instance id\> -message \<message\>

### Example:
```
powershell -file "c:\scripts\eventlog2.ps1" -source "Outlook" -eventid "63" -folder "c:\scripts\xmllog" -log "Application" -seed_depth 400 -message "*Exchange*" -computername "tarjei-2"
Found no historyfile
Log monitor started at 08/16/2017 16:25:43
Started processing tarjei-2
Processing 400 events.
Index is 1137573

Evaluating message *Exchange*
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found message: The Exchange web service request GetAppManifests succeeded.
Found 18 alert events in  seconds for eventid 63
------------------------------------------------------------

```

### Mandatory:

-eventid

### Defaults:

-log "Application" (Application, System or something else)

-path "c:\scripts\xmllog"

-seed_depth 200

# Generic Powershell Tips
![Image of Generic Execution configuration](/images/generic_execution_01.png?raw=true "Optional Title")

These tips are for using the Generic Execution Plugin and monitoring services in that way. 

### Checking if a W3SVC Service is running
Command:
```
powershell -command "get-service -computername ${HOST} W3SVC"
```
Regular Expression:
```
(.*)Stopped|Paused|Running_Pending|Pause_Pending|Stop_Pending|Continue_Pending(.*)
```
Success Definition:
```
on no match
```

### Checking if a one or more MSSQL Services are running
Command:
```
powershell -command "get-service -computername ${HOST} -displayname 'MSSQL*'"
```
Regular Expression:
```
(.*)Stopped|Paused|Running_Pending|Pause_Pending|Stop_Pending|Continue_Pending(.*)
```
Success Definition:
```
on no match
```


### Checking available space on the D-disk of a computer
Command:
```
powershell -command "Get-Counter -computername ${HOST} -Counter '\LogicalDisk(d:)\% Free Space'"
```

### Checking the number of running processes for a W3SVC
Command:
```
powershell -command "@(get-process -computername ${HOST} -ea silentlycontinue W3SVC).count"
```