function SetupTimer()
{
	$timer = new-object timers.timer;
	$timer.interval = 100;
	$timer_count=0;
	$global:start_time=(Get-Date)


	register-objectevent -inputobject $timer -eventname elapsed -action{
		$timer_count +=1;
		$current_time=(Get-Date)
		write-host "timer fired for the $timer_count occassion, at $( ($current_time-$global:start_time).TotalMilliseconds )"
		$job_out=(receive-job -name work_job__name -erroraction silentlycontinue )
		$job_out |% { write-host $_ }
		$job_out |% { $_ | Out-File -Append /tmp/output }
	}
	
	$timer.start()
}


function NewJob( $command, $change_count )
{
	stop-job   -name work_job__name -erroraction silentlycontinue
	remove-job -name work_job__name -erroraction silentlycontinue

	write-host "starting job for change $($change_count+1)"
	$work_job = start-job -name work_job__name -scriptblock $command
}

function monitorfilesandrunserver( $command )
{
	# https://stackoverflow.com/q/33701898
	# title: how-can-i-pass-through-parameters-in-a-powershell-function
	# Files to wait for
	if( $args.Length -eq 1 )
	{
		$files=( (get-item $args[0]).fullname  )
		$files=@($files)
	}
	else 
	{
		$files=($args |% { (get-item $_).fullname } )
	}

	SetupTimer
	Start-Sleep -MilliSeconds 200

	$change_count = 0

	while ( $true )
	{
		NewJob $command $change_count
		$change_count += 1;
		inotifywait -q -q -e modify @files 
	}
}
