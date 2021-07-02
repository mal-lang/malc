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

get_classpath() {
  mvn \
    --batch-mode \
    --quiet \
    dependency:build-classpath \
    -DincludeScope=runtime \
    -Dmdep.outputFile=classpath.txt
  cat classpath.txt
  rm -f classpath.txt
}

main() {
  if ! command -v native-image >/dev/null 2>&1; then
    >&2 echo "native-image: command not found"
    exit 1
  fi

  echo "Getting artifact from pom.xml"
  artifact="$(get_artifact)"
  echo "artifact = $artifact"

  if [ ! -f "$artifact" ]; then
    >&2 echo "$artifact: no such file"
    exit 1
  fi

  echo "Getting classpath from pom.xml"
  classpath="$(get_classpath)"
  echo "classpath = $classpath"

  echo "Building native image"
  native-image --class-path "$classpath" -jar "$artifact" malc
}

main
