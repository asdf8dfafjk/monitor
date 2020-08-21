$global:start_time=(Get-Date)

function SetupTimer()
{
	$timer = new-object timers.timer;

	$timer.interval = 100;
	$timer.enabled=true;
	$timer_count=0;

	register-objectevent -inputobject $timer -eventname elapsed -action{
		$timer_count +=1;
		$current_time=(Get-Date)
		write-host "timer fired for the $timer_count occassion, at $( ($current_time-$global:start_time).TotalMilliseconds )"
	}

	
	$timer.start()
}

function monitorfilesandrunserver( $command )
{
	SetupTimer
	start-sleep -seconds 1000000
}
