@@echo off
if "%1" == "" goto error
rem - process each of the named files

echo.

if "%1" == "ip" goto ip




:ip
	C:\Xilinx\Vivado\2014.4\bin\vivado.bat -mode batch -source build.tcl
	goto end
:error
echo missing argument!
echo usage  pro for bd project or ip for edit ip block project

:end
echo.
echo Done.
