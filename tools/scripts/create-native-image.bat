@echo off

pushd %~dp0\..\..
  call :main
popd
exit /b %errorlevel%

:get_property
  call mvn ^
    --batch-mode ^
    --quiet ^
    help:evaluate ^
    -Dexpression=%~1 ^
    -DforceStdout=true
  exit /b %errorlevel%

:get_artifact
  setlocal
    call :get_property project.build.directory > property.txt || exit /b %errorlevel%
    set /p directory=<property.txt
    del property.txt

    call :get_property project.build.finalName > property.txt || exit /b %errorlevel%
    set /p final_name=<property.txt
    del property.txt

    echo %directory%\%final_name%.jar
  endlocal
  exit /b 0

:get_classpath
  call mvn ^
    --batch-mode ^
    --quiet ^
    dependency:build-classpath ^
    -DincludeScope=runtime ^
    -Dmdep.outputFile=classpath.txt
  exit /b %errorlevel%

:main
  setlocal
    where native-image >nul 2>&1 || (
      echo native-image: command not found 1>&2
      exit /b 1
    )

    echo Getting artifact from pom.xml
    call :get_artifact > artifact.txt || exit /b %errorlevel%
    set /p artifact=<artifact.txt
    del artifact.txt
    echo artifact = %artifact%

    if not exist "%artifact%" (
      echo %artifact%: no such file 1>&2
      exit /b 1
    )

    echo Getting classpath from pom.xml
    call :get_classpath || exit /b %errorlevel%
    set /p classpath=<classpath.txt
    del classpath.txt
    echo classpath = %classpath%

    echo Building native image
    call native-image --class-path "%classpath%" -jar "%artifact%" malc || exit /b %errorlevel%
  endlocal
  exit /b 0
