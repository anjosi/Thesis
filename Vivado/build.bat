@@echo off
if "%1" == "" goto error
rem - process each of the named files

echo.
if "%1" == "pro" goto build
if "%1" == "ip" goto ip



:build

	C:\Xilinx\Vivado\2014.4\bin\vivado.bat -mode batch -source build.tcl
	goto end
:ip
	C:\Xilinx\Vivado\2014.4\bin\vivado.bat -mode batch -source ecg_unit_v1_4.tcl
	goto end
:error
echo missing argument!
echo usage  pro for bd project or ip for edit ip block project

:end
echo.
echo Done.
