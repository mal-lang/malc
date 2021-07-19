#!/bin/sh

set -eu

cd "$(dirname "$0")/../.."

main() {
  if ! command -v native-image >/dev/null 2>&1; then
    >&2 echo "native-image: command not found"
    exit 1
  fi

  artifact_file="${project.build.directory}/${project.build.finalName}.jar"

  if [ ! -f "$artifact_file" ]; then
    >&2 echo "$artifact_file: no such file"
    exit 1
  fi

  classpath="${maven.runtime.classpath}"
  echo "classpath = $classpath"

  echo "Building native image"
  cd "${project.build.directory}"
  native-image --class-path "$classpath" -jar "$artifact_file" "${project.name}"
  cd "$OLDPWD"

  echo "Creating tar archive"
  rm -fR "${project.build.directory}/${project.build.finalName}.${osName}.${os.arch}"
  cp -fpR \
    "${project.build.directory}/app-input" \
    "${project.build.directory}/${project.build.finalName}.${osName}.${os.arch}"
  cp -fp \
    "${project.build.directory}/${project.name}" \
    "${project.build.directory}/${project.build.finalName}.${osName}.${os.arch}"
  tar -cz \
    -f "${project.build.directory}/${project.build.finalName}.${osName}.${os.arch}.tar.gz" \
    -C "${project.build.directory}" \
    "${project.build.finalName}.${osName}.${os.arch}"
}

main
