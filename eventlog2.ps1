## Powershell Log Monitor Script ## 
## Contributing authors - mck74,mjolinor, 
# Adapted from https://gallery.technet.microsoft.com/scriptcenter/ed188912-1a20-4be9-ae4f-8ac46cf2aae4
##

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)][string]$computername,    # computername is required
  [Parameter(Mandatory=$True)][string]$source,
  [Parameter(Mandatory=$True)][string]$eventid
)

#param([switch]$ShowEvents = $false,[switch]$NoEmail = $false,[switch]
$useinstanceid = $false
 
 
$log = "Application" 
# History is saved in a xml file with latest point in eventlog
$hist_file = $computername + "_" + $log + "_" + $source + "_" + $eventid +   "_loghist.xml" 
$seed_depth = 200 
 
#see if we have a history file to use, if not create an empty $histlog 
if (Test-Path $hist_file){$loghist = Import-Clixml $hist_file} 
 else {$loghist = @{}} 
 
 
function write_alerts { 
    Write-Host $alertbody 
} 
#START OF RUN PASS 
$run_pass = { 
 
    $alertbody = "Log monitor found monitored events. `n" 
    Write-Host "Started processing $($computername)" 
     
    #Get the index number of the last log entry 
    $index = (Get-EventLog -ComputerName $computername -LogName $log -newest 1).index 
     
    #if we have a history entry calculate number of events to retrieve 
    #   if we don't have an event history, use the $seed_depth to do initial seeding 
    if ($loghist[$computername]){
        $n = $index - $loghist[$computername]
    } 
    else {
        $n = $seed_depth
    } 
      
    if ($n -lt 0){ 
     Write-Host "Log index changed since last run. The log may have been cleared. Re-seeding index." 
     $events_found = $true 
     $alertbody += "`n Possible Log Reset $($_)`nEvent Index reset detected by Log Monitor`n" 
     $n = $seed_depth 
     } 
      
    Write-Host "Processing $($n) events." 
     
    #get the log entries 
     
    if ($useinstanceid){ 
        $log_hits = Get-EventLog -ComputerName $computername -LogName $log -Newest $n | 
        
        ? {($_.source -eq $source) -and ($_.instanceid -eq $instanceid)} 
    } 
     
    else {$log_hits = Get-EventLog -ComputerName $computername -LogName $log -Newest $n | 
        ? {($_.source -eq $source) -and ($_.eventid -eq $eventid)} 
        
    } 
     
    #save the current index to $loghist for the next pass 
    Write-Host "Index is $($index)`n"
    $loghist[$computername] = $index 
     
    #report number of alert events found and how long it took to do it 
    if ($log_hits){ 
     $events_found = $true 
     $hits = $log_hits.count 
     $alertbody += "`n Alert Events on server $($_)`n" 
     $log_hits |%{ 
      
      $alertbody += $_ | select MachineName,EventID,Message 
        $alertbody += "`n"
     } 
     } 
     else {$hits = 0} 
    $duration = ($timer.elapsed).totalseconds 
    write-host "Found $($hits) alert events in $($duration) seconds." 
    "-"*60 
    " " 
    if ($ShowEvents){$log_hits | fl | Out-String |? {$_}} 

 
#save the history file to disk for next script run  
$loghist | export-clixml $hist_file 
 
    #Write to host if alerts are found 
    if ($events_found){
        write_alerts
    } 
 
} 
#END OF RUN PASS 
 
Write-Host "Log monitor started at $(get-date)" 
 
#run the first pass 
$start_pass = Get-Date 
&$run_pass 
 
#if $run_interval is set, calculate how long to sleep before the next pass 
