@echo off

pushd %~dp0\..\..
  call :main
popd
exit /b %errorlevel%

:main
  setlocal
    where native-image >nul 2>&1 || (
      echo native-image: command not found 1>&2
      exit /b 1
    )

    set artifact_file=${project.build.directory}/${project.build.finalName}.jar

    if not exist "%artifact_file%" (
      echo %artifact_file%: no such file 1>&2
      exit /b 1
    )

    set classpath=${maven.runtime.classpath}
    echo classpath = %classpath%

    echo Building native image
    pushd "${project.build.directory}"
      call native-image --class-path "%classpath%" -jar "%artifact_file%" "${project.name}"
    popd
    if %errorlevel% neq 0 exit /b %errorlevel%

    echo Creating zip archive
    rd /s /q "${project.build.directory}\${project.build.finalName}.${osName}.${os.arch}" >nul 2>&1
    xcopy ^
      "${project.build.directory}\app-input" ^
      "${project.build.directory}\${project.build.finalName}.${osName}.${os.arch}" ^
      /s /e /i /q
    copy ^
      "${project.build.directory}\${project.name}.exe" ^
      "${project.build.directory}\${project.build.finalName}.${osName}.${os.arch}"
    set src=${project.build.directory}\${project.build.finalName}.${osName}.${os.arch}
    set dest=${project.build.directory}\${project.build.finalName}.${osName}.${os.arch}.zip
    powershell -Command "Compress-Archive -Path \"%src%\" -DestinationPath \"%dest%\" -Force"
  endlocal
  exit /b 0
