rem chcp 932
echo off
setlocal
SET STR_Version=v2.48_150628r0
echo H.264�Ԅӥ��󥳩`��?��Ļ����z�ߌg�ХХå� %STR_Version%
rem v2.47to2.48:������Ԥ�����á��ɰ汾720pת����720pa��BS / CS��.FHD�ֱ�������720pת����720p��
rem v2.45to2.47:����Caption2Ass��ִ�з�������΢����ִ��ʱ�䡣���Ĳ����Զ�Ӧ�ڹ淶���ġ�
rem    ��ȷ�ϣ�Win8.1, HandBrake 0.10.2, mkvtoolnix 8.8.0 (����64λ�汾)
echo �����÷���"�����ե�����ѥ�" [�ץꥻ�å��� [mkv/mp4]]
echo ����������"���M�����ȥ�.ts" 480p mp4
echo Ĭ���趨��720p mkv
rem δָ��ʱ�����ΪMKV��MKVת����ҪMKVToolNix��
SET PATH_HandBrakeCLI="C:\Users\Administrator\Desktop\Caption2Ass-master\HandBrakeCLI.exe"
SET PATH_Caption2Ass="C:\Users\Administrator\Desktop\Caption2Ass-master\bin\Caption2AssC_x64.exe"
SET PATH_mkvmerge=C:\Users\Administrator\Desktop\Caption2Ass-master\MKVToolNix\mkvmerge.exe
SET PATH_OutputDir="D:\DTV"
SET PATH_LogFile="D:\DTV\HB_Batch.log"
set retnum=127

set inputFilePath=%~1
rem �ж��������ļ��л����ļ�
if not exist "%inputFilePath%" goto nofile
for %%a in ( %inputFilePath% ) do set "b=%%~aa"
if defined b (
if %b:~0,1%==d (set inputIsDir=1 ) else ( set inputIsDir=0) )

if %inputIsDir%==1 (
	rem ����ΪĿ¼
	for /r %inputFilePath% %%i in (*.ts) do (
		set inputFile=%%i
		call :run_convert_file %inputFile%
	)
) else (
	rem ����Ϊ�ļ�
	set inputFile=%inputFilePath%
	call :run_convert_file %inputFile%
)
pause
exit %retnum%

:run_convert_file
FOR %%i IN ("%inputFile%") DO (
	set infiledir=%%~dpi
	set infiledrive=%%~di
	set infile=%%~i
	set infilename=%%~ni
)

if not exist "%infiledir%" goto nofiledir
%infiledrive%
cd "%infiledir%"
if not exist "%PATH_LogFile%" (
call :echo H.264�Զ�������ĻǶ�����нű�
call :echo ��־�ļ�HB_Batch.log�����Զ�ɾ�����붨������
)
>>"%PATH_LogFile%" date /t
>>"%PATH_LogFile%" time /t
>>"%PATH_LogFile%" echo %STR_Version%
call :echo dir:%infiledir%
call :echo args:%0 %*
if not exist "%PATH_HandBrakeCLI%" goto error_noexefile
if not exist "%PATH_Caption2Ass%" goto error_noexefile
call :echo ���������С�

:fpath_repeat
if exist "%infile%" goto file_found
if "%~2"=="" goto nofile
goto nofile
shift
set infilename=%infile%��%~n1
set infile=%infile%��%~1
goto fpath_repeat

:file_found
rem shift
set enc_type=%~2
rem Ĭ�ϵ�enc_type
if "%~2"=="" set enc_type=1080p
rem shift
set file_type=%~3
rem Ĭ�ϵ�file_type
if "%~3"=="" set file_type=mkv
call :echo infile:%infile%
call :echo enc_type:%enc_type%
call :echo file_type:%file_type%

rem file_type�����å�
if "%file_type%"=="mp4" (
rem
) else if "%file_type%"=="mkv" (
rem
) else if "%file_type%"=="mp4_nosub" (
rem
) else if "%file_type%"=="mkv_nosub" (
rem
) else (
goto error_sel_ftype
)

rem ��������ϲ������HandBrake CLI�Ĳ���
set PARAM_VideoOptions=-e x264 -q 24 -r 23.976 --cfr --h264-level=4.0 --h264-profile=high
set PARAM_AudioOptions=-a 1,2,3,4,5 -E faac -6 stereo -D 0 --gain 0
if "%enc_type%"=="720pa" (
set PARAM_FileDesc=720p x264 AAC
set PARAM_PictureOptions=-Y 720 --crop 0:0:0:0 --modulus 8 --loose-anamorphic
set PARAM_FilterOptions=--deinterlace=slower
set PARAM_Cap2AssOptions=-asstype 960x720
) else if "%enc_type%"=="720p" (
set PARAM_FileDesc=720p x264 AAC
set PARAM_PictureOptions=-Y 720 --crop 0:0:0:0
set PARAM_FilterOptions=--deinterlace=slower
set PARAM_Cap2AssOptions=
) else if "%enc_type%"=="720i" (
set PARAM_FileDesc=720i x264 AAC
set PARAM_PictureOptions=-Y 720 --crop 0:0:0:0
set PARAM_FilterOptions=
set PARAM_Cap2AssOptions=
) else if "%enc_type%"=="480p" (
set PARAM_FileDesc=480p x264 AAC
set PARAM_PictureOptions=-Y 480 --crop 0:0:0:0
set PARAM_FilterOptions=--deinterlace=slower
set PARAM_Cap2AssOptions=-asstype 852x480
)  else if "%enc_type%"=="360p" (
set PARAM_FileDesc=360p x264 AAC
set PARAM_PictureOptions=-Y 360 --crop 0:0:0:0
set PARAM_FilterOptions=
set PARAM_Cap2AssOptions=-asstype 480x360
) else if "%enc_type%"=="1080p" (
set PARAM_FileDesc=1080p x264 AAC
set PARAM_PictureOptions=-Y 1080 --crop 0:0:0:0
set PARAM_FilterOptions=--deinterlace=slower
set PARAM_Cap2AssOptions=
) else (
goto end_err
)
rem MKV�½�Ƕ��ass��srt��Ļ
rem MP4�½�Ƕ��srt��Ļ
if "%file_type%"=="mkv" goto exportass
if "%file_type%"=="mp4" goto exportass
goto end_exportsrt

:exportass
call :echo ���У�%PATH_Caption2Ass% %PARAM_Cap2AssOptions% -format dual "%infile%"
start "Caption2Ass dual" /WAIT /I /BELOWNORMAL /MIN %PATH_Caption2Ass% %PARAM_Cap2AssOptions% -format dual "%infile%"
set exitcode=%errorlevel%
call :echo �˳����� %exitcode% .
if %exitcode% GEQ 1 goto failed_getcaption

:end_exportsrt
if not exist "%infilename%.srt" (
set fileSize=-1
) else (
call :getFilesize "%infilename%.srt"
)

call :echo ��Ļ���ݴ�С:%fileSize% bytes
if %fileSize% LEQ 3 (
call :echo û���ҵ���Ļ�ļ�
if "%file_type%"=="mp4" set file_type=mp4_nosub
if "%file_type%"=="mkv" set file_type=mkv_nosub
) else (
rem ��Ļ�ļ�����
)
goto end_getcaption

:failed_getcaption
call :echo ��ȡ��Ļ����ʧ��
if "%file_type%"=="mp4" set file_type=mp4_nosub
if "%file_type%"=="mkv" set file_type=mkv_nosub
:end_getcaption
rem ����ļ���չ������
if "%file_type%"=="mp4" ( 
set outftypename=mp4
set PARAM_SubtitleOptions=-N jpn --srt-file "%infilename%.srt" --srt-codeset UTF-8 --srt-lang jpn
) else if "%file_type%"=="mkv" (
set outftypename=mkv
set PARAM_SubtitleOptions=
) else if "%file_type%"=="mp4_nosub" (
set outftypename=mp4
set PARAM_SubtitleOptions=
) else if "%file_type%"=="mkv_nosub" (
set outftypename=mkv
set PARAM_SubtitleOptions=
) else (
goto error_sel_ftype
)
rem ����ļ�������ͻ
if exist "%infilename% (%PARAM_FileDesc%).%file_type%" goto error_samefileexist
if exist "%PATH_OutputDir%\%infilename% (%PARAM_FileDesc%).%file_type%" goto error_samefileexist
call :echo HandBrakeCLI %file_type% %PARAM_FileDesc%
call :echo ִ��:"%PATH_HandBrakeCLI%" -i "%infile%" -o "%infilename% (%PARAM_FileDesc%).temp.%outftypename%" -f %outftypename% %PARAM_FilterOptions% %PARAM_VideoOptions% %PARAM_AudioOptions% %PARAM_PictureOptions% --verbose=1 %PARAM_SubtitleOptions%"
start "HandBrakeCLI %file_type% %PARAM_FileDesc% %infilename%" /WAIT /I /BELOWNORMAL /MIN "%SystemRoot%\System32\cmd.exe" /c "1>"%infilename% (%PARAM_FileDesc%).%outftypename%.log" 2>&1 3>&1 "%PATH_HandBrakeCLI%" -i "%infile%" -o "%infilename% (%PARAM_FileDesc%).temp.%outftypename%" -f %outftypename% %PARAM_FilterOptions% %PARAM_VideoOptions% %PARAM_AudioOptions% %PARAM_PictureOptions% --verbose=1 %PARAM_SubtitleOptions%"
set exitcode=%errorlevel%
call :echo �˳����� %exitcode% .
if %exitcode% NEQ 0 goto hb_err

if "%file_type%"=="mkv" goto mergesub
goto hb_success
:mergesub
ren "%infilename% (%PARAM_FileDesc%).%outftypename%" "%infilename% (%PARAM_FileDesc%).temp.%outftypename%"
call :echo mkvmergeִ��
call :echo ִ��:"%PATH_mkvmerge%" --default-language jpn -o "%infilename% (%PARAM_FileDesc%).%outftypename%" "%infilename% (%PARAM_FileDesc%).temp.%outftypename%" "%infilename%.ass" "%infilename%.srt"
start "mkvmerge %file_type% %PARAM_FileDesc% %infilename%" /WAIT /I /BELOWNORMAL /MIN "%SystemRoot%\System32\cmd.exe" /c "1>>"%infilename% (%PARAM_FileDesc%).%outftypename%.log" 2>>&1 3>>&1 "%PATH_mkvmerge%" --default-language jpn -o "%infilename% (%PARAM_FileDesc%).%outftypename%" "%infilename% (%PARAM_FileDesc%).temp.%outftypename%" "%infilename%.ass" "%infilename%.srt""
set exitcode=%errorlevel%
call :echo �˳����� %exitcode% .
if %exitcode% NEQ 0 goto hb_err

:hb_success
call :echo --- ִ����� ---
set retnum=0
call :echo ����ļ�:%infilename% (%PARAM_FileDesc%).%outftypename%
rem �ļ��ƶ�
IF DEFINED PATH_OutputDir (
IF NOT EXIST "%PATH_OutputDir%" goto error_outdirnotexist
MOVE /Y "%infilename% (%PARAM_FileDesc%).%outftypename%" "%PATH_OutputDir%"
MOVE /Y "%infilename%.ass" "%PATH_OutputDir%"
MOVE /Y "%infilename%.srt" "%PATH_OutputDir%"
call :echo �ļ��ƶ�:%PATH_OutputDir%
) else (
call :echo ��������PATH_OutputDirδ���壬�޷��ƶ��ļ���
)
rem if not exist "%infiledir%converted" mkdir "%infiledir%converted"
rem MOVE /Y "%infilename% (%PARAM_FileDesc%).%outftypename%.log" "%infiledir%converted"
rem call :echo �����ļ��ƶ�:%infiledir%converted
rem MOVE /Y "%infile%" "%infiledir%converted"

rem ���Ҫͨ��������ɾ�������ļ��������������еĿ�ͷ���REM�����������еĿ�ͷɾ��REM��
rem call :echo �����ļ�ɾ��
rem del "%infile%"
goto end_cleanup
rem --- ���ܺ��� ---
:getFilesize
set filesize=%~z1
exit /b
:echo
set msg_output=%*
echo. %msg_output%
>>"%PATH_LogFile%" echo. %msg_output%
exit /b
rem --- ������ ---
:hb_err
set errmsg=�ⲿ�����쳣��ֹ
goto end_err
:nofiledir
set errmsg=�����ļ�Ŀ¼ %~1 ������
goto end_err
:nofile
set errmsg=�����ļ� %~1 ������
goto end_err
:error_sel_ftype
set errmsg=��������file_type����ȷ��ת����ֹ
goto end_err
:error_noexefile
set errmsg=�Ҳ�������������ļ���Ŀ¼�����������ļ�Ŀ¼���������ļ���������·����
goto end_err
:error_samefileexist
set errmsg=����ļ�������ת����ֹ
goto end_err
:error_outdirnotexist
set errmsg=���Ŀ¼ %PATH_OutputDir% �����ڣ�ת����ֹ
goto end_err
:end_err
if not defined errmsg goto end
call :echo *** �쳣���� ***
call :echo errmsg:%errmsg%
set retnum=1
:end_cleanup
rem ��ҵ�ļ�ɾ������
rem if exist "%infilename%.ass" del "%infilename%.ass"
rem if exist "%infilename%.srt" del "%infilename%.srt"
if exist "%infilename% (%PARAM_FileDesc%).temp.%outftypename%" del "%infilename% (%PARAM_FileDesc%).temp.%outftypename%"
:end
call :echo ----------------------------------------
rem pause
rem exit %retnum%