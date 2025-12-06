#!/usr/bin/env bash
set -eu

[ -z "$SCALA_VERSIONS" ] && { echo "SCALA_VERSIONS is empty" ; exit 1; }
[ -z "$ALMOND_VERSION" ] && { echo "ALMOND_VERSION is empty" ; exit 1; }

# 1. DEFINE THE JAVA OPTIONS
JAVA_OPTS_ARRAY=(
  "--add-opens=java.base/java.lang=ALL-UNNAMED"
  "--add-opens=java.base/java.lang.invoke=ALL-UNNAMED"
  "--add-opens=java.base/java.lang.reflect=ALL-UNNAMED"
  "--add-opens=java.base/java.io=ALL-UNNAMED"
  "--add-opens=java.base/java.net=ALL-UNNAMED"
  "--add-opens=java.base/java.nio=ALL-UNNAMED"
  "--add-opens=java.base/java.util=ALL-UNNAMED"
  "--add-opens=java.base/java.util.concurrent=ALL-UNNAMED"
  "--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED"
  "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED"
  "--add-exports=java.base/sun.nio.ch=ALL-UNNAMED"
  "--add-opens=java.base/sun.nio.cs=ALL-UNNAMED"
  "--add-opens=java.base/sun.security.action=ALL-UNNAMED"
  "--add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
)

# 2. FORMAT FOR COURSIER BOOTSTRAP
BOOTSTRAP_OPTS=()
for opt in "${JAVA_OPTS_ARRAY[@]}"; do
  BOOTSTRAP_OPTS+=("-J$opt")
done

for SCALA_FULL_VERSION in ${SCALA_VERSIONS}; do
  SCALA_MAJOR_VERSION=${SCALA_FULL_VERSION%.*}
  SCALA_MAJOR_VERSION_TRIMMED=$(echo ${SCALA_MAJOR_VERSION} | tr -d .)
  echo Installing almond ${ALMOND_VERSION} for Scala ${SCALA_FULL_VERSION}
  
  EXTRA_ARGS=()
  if [[ ${ALMOND_VERSION} == *-SNAPSHOT ]]; then
    EXTRA_ARGS+=('--standalone')
  fi
  
  coursier bootstrap \
      -r jitpack \
      -n 1 \
      -i user -I user:sh.almond:scala-kernel-api_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      sh.almond:scala-kernel_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      --default=true --sources \
      "${BOOTSTRAP_OPTS[@]}" \
      -o almond ${EXTRA_ARGS[@]}

  ./almond --install \
      --log info \
      --metabrowse \
      --id scala${SCALA_MAJOR_VERSION_TRIMMED} \
      --display-name "Scala ${SCALA_MAJOR_VERSION}"
  
  # Add JVM options to kernel.json
  KERNEL_DIR="${HOME}/.local/share/jupyter/kernels/scala${SCALA_MAJOR_VERSION_TRIMMED}"
  if [ -f "${KERNEL_DIR}/kernel.json" ]; then
    python3 -c "
import json
import sys
kernel_file = '${KERNEL_DIR}/kernel.json'
with open(kernel_file, 'r') as f:
    kernel = json.load(f)
# Insert JVM options after 'java' command
if 'argv' in kernel and len(kernel['argv']) > 0:
    java_opts = [
        '--add-opens=java.base/java.lang=ALL-UNNAMED',
        '--add-opens=java.base/java.lang.invoke=ALL-UNNAMED',
        '--add-opens=java.base/java.lang.reflect=ALL-UNNAMED',
        '--add-opens=java.base/java.io=ALL-UNNAMED',
        '--add-opens=java.base/java.net=ALL-UNNAMED',
        '--add-opens=java.base/java.nio=ALL-UNNAMED',
        '--add-opens=java.base/java.util=ALL-UNNAMED',
        '--add-opens=java.base/java.util.concurrent=ALL-UNNAMED',
        '--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED',
        '--add-opens=java.base/sun.nio.ch=ALL-UNNAMED',
        '--add-exports=java.base/sun.nio.ch=ALL-UNNAMED',
        '--add-opens=java.base/sun.nio.cs=ALL-UNNAMED',
        '--add-opens=java.base/sun.security.action=ALL-UNNAMED',
        '--add-opens=java.base/sun.util.calendar=ALL-UNNAMED'
    ]
    kernel['argv'] = kernel['argv'][:1] + java_opts + kernel['argv'][1:]
with open(kernel_file, 'w') as f:
    json.dump(kernel, f, indent=2)
"
  fi
      
  rm -f almond
done
echo Installation was successful