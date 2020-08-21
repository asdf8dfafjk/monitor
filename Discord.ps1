$Global:StartTime      = (Get-Date)
$Script:LastTimerFired = (Get-Date)
$Script:TimerCount     = 0 ;
$Script:Interval       = [timespan]::FromMilliSeconds(300);

$timer = [System.Timers.Timer]::new( 300 );
$timer.Enabled = $true;

$timer.Add_Elapsed( {
	param( $sender, $eventArgs )
	
	write-host 'hihi'
	(get-date) | Out-File -Append hi
	write-host $eventArgs.signalTime
	$script:LastTimerFired = $eventArgs.SignalTime
	if( 
		$eventArgs.SignalTime - $script:LastTimerFired -ge $Script:Interval 
	)
	{
		$Script:TimerCount += 1 ;
		$current_time=(Get-Date)

		write-host hi
		write-host "timer fired for the $($Script:TimerCount) occassion, at $( ($current_time-$global:StartTime).TotalMilliseconds )"
	}
	
} )

$timer.start()
write-host "setup complete"

