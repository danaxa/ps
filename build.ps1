Function rake-build()
{
    svn up
    rake build:release
}

Function rake-full()
{
    svn up
    rake
}

Function build($target = $(throw "Please supply a project or solution to build"), $flags = "", $verbosity = "minimal")
{
	$buildCommand = '"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat" && MSBuild.exe '  + $target + " /verbosity:$verbosity " + $flags
	cmd /c $buildCommand 
}
