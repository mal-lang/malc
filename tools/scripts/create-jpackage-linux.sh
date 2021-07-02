#!/bin/sh

set -eu

cd "$(dirname "$0")/../.."

get_property() {
  mvn \
    --batch-mode \
    --quiet \
    help:evaluate \
    -Dexpression="$1" \
    -DforceStdout=true
}

get_artifact() {
  directory="$(get_property "project.build.directory")"
  final_name="$(get_property "project.build.finalName")"
  echo "$directory/$final_name.jar"
}

patch_icu4j() {
  main_class="com.ibm.icu.util.VersionInfo"
  module_dir="$dependency_dir/com.ibm.icu"
  module_file="$module_dir/module-info.java"
  jar_file="$(echo "$dependency_dir"/icu4j-*.jar)"
  jar_dir="${jar_file%.jar}"

  jdeps --generate-module-info "$dependency_dir" "$jar_file"
  printf "g/impl/d\nwq\n" | ed -s "$module_file"

  mkdir -p "$jar_dir"
  cd "$jar_dir"
  jar -xf "$jar_file"
  cd "$OLDPWD"
  javac -d "$jar_dir" "$module_file"

  jar \
    --update \
    --file "$jar_file" \
    --main-class "$main_class" \
    --module-version "$(basename "$jar_dir" | sed "s/^icu4j-//")" \
    -C "$jar_dir" \
    module-info.class

  rm -fR "$module_dir" "$jar_dir"
}

patch_jansi() {
  main_class="org.fusesource.jansi.AnsiMain"
  module_dir="$dependency_dir/org.fusesource.jansi"
  module_file="$module_dir/module-info.java"
  jar_file="$(echo "$dependency_dir"/jansi-*.jar)"
  jar_dir="${jar_file%.jar}"

  jdeps --generate-module-info "$dependency_dir" "$jar_file"
  printf "g/internal/d\ng/io/d\nwq\n" | ed -s "$module_file"

  mkdir -p "$jar_dir"
  cd "$jar_dir"
  jar -xf "$jar_file"
  cd "$OLDPWD"
  javac -d "$jar_dir" "$module_file"

  jar \
    --update \
    --file "$jar_file" \
    --main-class "$main_class" \
    --module-version "$(basename "$jar_dir" | sed "s/^jansi-//")" \
    -C "$jar_dir" \
    module-info.class

  rm -fR "$module_dir" "$jar_dir"
}

main() {
  if ! command -v jpackage >/dev/null 2>&1; then
    >&2 echo "jpackage: command not found"
    exit 1
  fi

  echo "Getting artifact from pom.xml"
  artifact="$(get_artifact)"
  echo "artifact = $artifact"

  if [ ! -f "$artifact" ]; then
    >&2 echo "$artifact: no such file"
    exit 1
  fi

  echo "Copying dependencies"
  dependency_dir="$(dirname "$artifact")/dependency"
  rm -fR "$dependency_dir"
  mvn \
    --batch-mode \
    --quiet \
    dependency:copy-dependencies \
    -DincludeScope=runtime

  echo "Patching icu4j"
  patch_icu4j
  echo "Patching jansi"
  patch_jansi
  modulepath="$artifact$(printf ":%s" "$dependency_dir"/*.jar)"
  echo "modulepath = $modulepath"

  echo "Getting project.name from pom.xml"
  project_name="$(get_property "project.name")"
  echo "project_name = $project_name"

  echo "Getting project.version from pom.xml"
  project_version="$(
    get_property "project.version" |
    cut -d - -f 1 |
    cut -d + -f 1
  )"
  echo "project_version = $project_version"

  echo "Getting project.description from pom.xml"
  project_description="$(get_property "project.description")"
  echo "project_description = $project_description"

  echo "Getting project.organization.name from pom.xml"
  project_organization="$(get_property "project.organization.name")"
  echo "project_organization = $project_organization"

  for type in rpm deb; do
    echo "Building $type"
    jpackage \
      --type "$type" \
      --app-version "$project_version" \
      --copyright "Copyright 2019-2021 Foreseeti AB <https://foreseeti.com>" \
      --description "$project_description" \
      --name "$project_name" \
      --vendor "$project_organization" \
      --add-modules "org.leadpony.joy.classic" \
      --module-path "$modulepath" \
      --module "org.mal_lang.compiler/org.mal_lang.compiler.MalCompiler" \
      --license-file "LICENSE" \
      --linux-rpm-license-type "Apache-2.0" \
      --linux-app-release 1 \
      --linux-app-category devel
  done
}

main
