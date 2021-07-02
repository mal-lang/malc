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

:patch_icu4j
  setlocal
    set main_class=com.ibm.icu.util.VersionInfo
    set module_dir=%dependency_dir%\com.ibm.icu
    set module_file=%module_dir%\module-info.java
    for %%f in ("%dependency_dir%"\icu4j-*.jar) do set jar_file=%%f
    set jar_dir=%jar_file:~0,-4%
    for %%f in ("%jar_file%") do set jar_version=%%~nf
    set jar_version=%jar_version:~6%

    call jdeps --generate-module-info "%dependency_dir%" "%jar_file%" || exit /b %errorlevel%
    for %%f in ("%module_file%") do set old_module_file=%%~nxf
    set old_module_file=%old_module_file%.old
    ren "%module_file%" "%old_module_file%"
    set old_module_file=%module_file%.old
    findstr /v impl "%old_module_file%" > "%module_file%"
    del "%old_module_file%"

    md "%jar_dir%"
    pushd "%jar_dir%"
      call jar -xf "%jar_file%"
    popd
    if %errorlevel% neq 0 exit /b %errorlevel%
    call javac -d "%jar_dir%" "%module_file%" || exit /b %errorlevel%

    call jar ^
      --update ^
      --file "%jar_file%" ^
      --main-class "%main_class%" ^
      --module-version "%jar_version%" ^
      -C "%jar_dir%" ^
      module-info.class || exit /b %errorlevel%

    rd /s /q "%module_dir%" "%jar_dir%"
  endlocal
  exit /b 0

:patch_jansi
  setlocal
    set main_class=org.fusesource.jansi.AnsiMain
    set module_dir=%dependency_dir%\org.fusesource.jansi
    set module_file=%module_dir%\module-info.java
    for %%f in ("%dependency_dir%"\jansi-*.jar) do set jar_file=%%f
    set jar_dir=%jar_file:~0,-4%
    for %%f in ("%jar_file%") do set jar_version=%%~nf
    set jar_version=%jar_version:~6%

    call jdeps --generate-module-info "%dependency_dir%" "%jar_file%" || exit /b %errorlevel%
    for %%f in ("%module_file%") do set old_module_file=%%~nxf
    set old_module_file=%old_module_file%.old
    ren "%module_file%" "%old_module_file%"
    set old_module_file=%module_file%.old
    findstr /v internal "%old_module_file%" > "%module_file%"
    del "%old_module_file%"
    for %%f in ("%module_file%") do set old_module_file=%%~nxf
    set old_module_file=%old_module_file%.old
    ren "%module_file%" "%old_module_file%"
    set old_module_file=%module_file%.old
    findstr /v io "%old_module_file%" > "%module_file%"
    del "%old_module_file%"

    md "%jar_dir%"
    pushd "%jar_dir%"
      call jar -xf "%jar_file%"
    popd
    if %errorlevel% neq 0 exit /b %errorlevel%
    call javac -d "%jar_dir%" "%module_file%" || exit /b %errorlevel%

    call jar ^
      --update ^
      --file "%jar_file%" ^
      --main-class "%main_class%" ^
      --module-version "%jar_version%" ^
      -C "%jar_dir%" ^
      module-info.class || exit /b %errorlevel%

    rd /s /q "%module_dir%" "%jar_dir%"
  endlocal
  exit /b 0

:main
  setlocal EnableDelayedExpansion
    where jpackage >nul 2>&1 || (
      echo jpackage: command not found 1>&2
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

    echo Copying dependencies
    for %%f in ("%artifact%") do set dependency_dir=%%~dpf
    set dependency_dir=%dependency_dir%dependency
    rd /s /q "%dependency_dir%" >nul 2>&1
    call mvn ^
      --batch-mode ^
      --quiet ^
      dependency:copy-dependencies ^
      -DincludeScope=runtime || exit /b %errorlevel%

    echo Patching icu4j
    call :patch_icu4j || exit /b %errorlevel%
    echo Patching jansi
    call :patch_jansi || exit /b %errorlevel%
    set modulepath=%artifact%
    for %%f in ("%dependency_dir%"\*.jar) do set modulepath=!modulepath!;%%f
    echo modulepath = %modulepath%

    echo Getting project.name from pom.xml
    call :get_property project.name > property.txt || exit /b %errorlevel%
    set /p project_name=<property.txt
    del property.txt
    echo project_name = %project_name%

    echo Getting project.version from pom.xml
    call :get_property project.version > property.txt || exit /b %errorlevel%
    set /p project_version=<property.txt
    set project_version=%project_version:-SNAPSHOT=%
    del property.txt
    echo project_version = %project_version%

    echo Getting project.description from pom.xml
    call :get_property project.description > property.txt || exit /b %errorlevel%
    set /p project_description=<property.txt
    del property.txt
    echo project_description = %project_description%

    echo Getting project.organization.name from pom.xml
    call :get_property project.organization.name > property.txt || exit /b %errorlevel%
    set /p project_organization=<property.txt
    del property.txt
    echo project_organization = %project_organization%

    for %%t in (exe msi) do (
      echo Building %%t
      call jpackage ^
        --type %%t ^
        --app-version "%project_version%" ^
        --copyright "Copyright 2019-2021 Foreseeti AB <https://foreseeti.com>" ^
        --description "%project_description%" ^
        --name "%project_name%" ^
        --vendor "%project_organization%" ^
        --add-modules "org.leadpony.joy.classic" ^
        --module-path "%modulepath%" ^
        --module "org.mal_lang.compiler/org.mal_lang.compiler.MalCompiler" ^
        --win-console ^
        --license-file "LICENSE" ^
        --resource-dir "jpackage-resources\win" ^
        --win-dir-chooser || exit /b %errorlevel%
    )
  endlocal
  exit /b 0
