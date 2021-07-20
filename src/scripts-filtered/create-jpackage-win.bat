@echo off

pushd %~dp0\..\..
  call :main
popd
exit /b %errorlevel%

:main
  setlocal EnableDelayedExpansion
    where jpackage >nul 2>&1 || (
      echo jpackage: command not found 1>&2
      exit /b 1
    )

    set artifact_file=${project.build.directory}\${project.build.finalName}.jar

    if not exist "%artifact_file%" (
      echo %artifact_file%: no such file 1>&2
      exit /b 1
    )

    set dependency_dir=${project.build.directory}\dependency

    if not exist "%dependency_dir%" (
      echo %dependency_dir%: no such directory
      exit /b 1
    )

    set modulepath=%artifact_file%
    for %%f in ("%dependency_dir%"\*.jar) do set modulepath=!modulepath!;%%f
    echo modulepath = %modulepath%

    set project_version=${project.version}

    for %%t in (exe msi) do (
      echo Building %%t
      call jpackage ^
        --type "%%t" ^
        --app-version "%project_version:-SNAPSHOT=%" ^
        --copyright "Copyright 2019-2021 Foreseeti AB <https://foreseeti.com>" ^
        --description "${project.description}" ^
        --name "${project.name}" ^
        --dest "${project.build.directory}" ^
        --vendor "${project.organization.name}" ^
        --add-modules "org.leadpony.joy.classic" ^
        --module-path "%modulepath%" ^
        --input "${project.build.directory}\app-input" ^
        --module "${moduleName}/${mainClass}" ^
        --win-console ^
        --license-file "${project.basedir}\LICENSE" ^
        --resource-dir "${project.basedir}\jpackage-resources" ^
        --win-dir-chooser || exit /b %errorlevel%
    )
  endlocal
  exit /b 0
