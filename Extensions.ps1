# Import-Module Pscx # PowerShell Community Extensions, see http://pscx.codeplex.com

& {
	function get-color-from-principal()
	{
		$prp = new-object System.Security.Principal.WindowsPrincipal(
			[System.Security.Principal.WindowsIdentity]::GetCurrent())
		if ($prp.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
		{
			return "Black"
		}
		return (get-host).UI.RawUI.Backgroundcolor
	}
	(get-host).UI.RawUI.Backgroundcolor = get-color-from-principal
}

function prompt {
    Write-Host(“”)
    $status_string = “”
    # check to see if this is a directory containing a symbolic reference,
    # fails (gracefully) on non-git repos.
    $symbolicref = git symbolic-ref HEAD
    if($symbolicref -ne $NULL) {
       
        # if a symbolic reference exists, snag the last bit as our
        # branch name. eg “[master]“
        $status_string += “GIT [" + `
            $symbolicref.substring($symbolicref.LastIndexOf("/") +1) + "] “
       
        # grab the differences in this branch   
        $differences = (git diff-index –name-status HEAD)
       
        # use a regular expression to count up the differences.
        # M`t, A`t, and D`t refer to M {tab}, etc.
        $git_update_count = [regex]::matches($differences, “M`t”).count
        $git_create_count = [regex]::matches($differences, “A`t”).count
        $git_delete_count = [regex]::matches($differences, “D`t”).count
       
        # place those variables into our string.
        $status_string += “c:” + $git_create_count + `
            ” u:” + $git_update_count + `
            ” d:” + $git_delete_count + ” | “
    }
    else {
        # Not in a Git environment, must be PowerShell!
        $status_string = “PS “
    }
   
    # write out the status_string with the approprate color.
    # prompt is done!
    if ($status_string.StartsWith(“GIT”)) {
        Write-Host ($status_string + $(get-location) + “>”) `
            -nonewline -foregroundcolor yellow
    }
    else {
        Write-Host ($status_string + $(get-location) + “>”) `
            -nonewline -foregroundcolor green
    }
    return ” “
 }

Set-Alias -Name edit -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe'
Set-Alias -Name time -Value Measure-Command

$trunkRoot = "C:\g\main"

function cdt
{
	cd $trunkRoot
}

function show-log 
{
    git log -n 10
}

function Kill-All($processNamePattern = $(throw "Please provide a pattern"))
{
	$processes = Get-Process | ? { $_.ProcessName -like "*$processNamePattern*" }
	if (-not $processes)
	{
		return
	}
	
	$processes
	if ($(Read-Host -Prompt "Really kill? (y)") -like "y")
	{
		$processes | Stop-Process
	}
}

$env:path += ";C:\g\ps"
$env:path += ";C:\bin"
$env:path += ";C:\g\main\tools\nunit"
$env:path += ";C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\"

. VersionControl.ps1
. build.ps1
. FindFiles.ps1
. ssh-agent-utils.ps1

function Set-TestTargetEnvironment($env)
{
    $env > $(join-path -Path $trunkRoot -ChildPath "Build\bin\TestTargetEnvironment")
}

function Get-TestTargetEnvironment
{
    cat $(join-path -Path $trunkRoot -ChildPath "Build\bin\TestTargetEnvironment")
}
