#!/bin/sh

set -eu

cd "$(dirname "$0")/../.."

main() {
  if ! command -v jpackage >/dev/null 2>&1; then
    >&2 echo "jpackage: command not found"
    exit 1
  fi

  artifact_file="${project.build.directory}/${project.build.finalName}.jar"

  if [ ! -f "$artifact_file" ]; then
    >&2 echo "$artifact_file: no such file"
    exit 1
  fi

  dependency_dir="${project.build.directory}/dependency"

  if [ ! -d "$dependency_dir" ]; then
    >&2 echo "$dependency_dir: no such directory"
    exit 1
  fi

  modulepath="$artifact_file$(printf ":%s" "$dependency_dir"/*.jar)"
  echo "modulepath = $modulepath"

  for type in pkg dmg; do
    echo "Building $type"
    jpackage \
      --type "$type" \
      --app-version "$(
        echo "${project.version}" |
          cut -d - -f 1 |
          cut -d + -f 1 |
          sed "s/^00*\.//"
      )" \
      --copyright "Copyright 2019-2021 Foreseeti AB &lt;https://foreseeti.com&gt;" \
      --description "${project.description}" \
      --name "${project.name}" \
      --dest "${project.build.directory}" \
      --vendor "${project.organization.name}" \
      --add-modules "org.leadpony.joy.classic" \
      --module-path "$modulepath" \
      --input "${project.build.directory}/app-input" \
      --module "${moduleName}/${mainClass}" \
      --mac-package-identifier "${project.groupId}.${project.artifactId}" \
      --mac-package-name "${project.name}" \
      --license-file "${project.basedir}/LICENSE" \
      --resource-dir "${project.basedir}/jpackage-resources"
  done
}

main
