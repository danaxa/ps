function Dir-Files
{
	dir -Recur | ? { -not $_.PSIsContainer }
}