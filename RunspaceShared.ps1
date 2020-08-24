

$hash = [hashtable]::Synchronized(@{})
$hash.Host = $host
$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()
$runspace.SessionStateProxy.SetVariable('H',$hash)
$powershell = [powershell]::Create()
$powershell.Runspace = $runspace
$powershell.AddScript({
        $H.host.ui.WriteVerboseLine( "hi" )
    }
) 
$handle = $powershell.BeginInvoke()


