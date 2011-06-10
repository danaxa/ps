function guess-path($url = $null)
{
	Resolve-Path $(
		if (-not ($url -eq $null))
		{
			return $url
		}
		$url = Get-Clipboard
		if ([System.IO.File]::Exists($url))
		{
			return $url
		}
		"."
	)
}

function show-log($url = $null)
{
	git log -n 10 --format='%cn%n'
}