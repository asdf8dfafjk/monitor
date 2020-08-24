$Script:ht = [hashtable]::Synchronized(@{})
$Script:ht.Host = $Host
$Script:ht.JobReceiveCount   = 0
$Script:ht.Job = $null

$Script:Change_count=0


function SetupRunspace()
{
	$runspace = [RunspaceFactory]::CreateRunspace();
	$runspace.open();
	$runspace.SessionStateProxy.SetVariable( "sharedHT", $Script:ht );

	$powershell= [PowerShell]::Create();
	$powershell.Runspace = $Runspace

	$powershell.AddScript( 
		{
			Start-Sleep -MilliSeconds 200
			While( $true )
			{
				if( $sharedHT.Job -ne $null )
				{
					$job_out=(receive-job ($sharedHT.job) -erroraction silentlycontinue )
					$job_out |% { $sharedHT.Host.UI.WriteLine( $_ ) }
				}

				Start-Sleep -MilliSeconds 300
			}
		}
	)

	$powershell.BeginInvoke()
}

class Jobber
{
	static [System.Management.Automation.Job] NewJob( $command, $change_count ){
		Stop-Job   -name work_job__name -ErrorAction SilentlyContinue
		Remove-Job -name work_job__name -ErrorAction SilentlyContinue

		Write-Host "starting job for change $($change_count+1)"
		$work_job = start-job -name work_job__name -scriptblock $command

		Return $work_job
	}
}


function monitorfilesandrunserver( $command )
{
	if( $command -eq $null -Or $args.Length -eq 0 )
	{
		Write-Host "Need parameter command and files "
		Exit-PsSession
	}

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

	SetupRunspace

	$Script:change_count = 0
	while ( $true )
	{
		bash -c reset
		$Script:Ht.Job = ([Jobber]::NewJob( $command, $script:Change_count ))
		$Script:change_count += 1;
		inotifywait -q -q -e modify @files 
	}

}

