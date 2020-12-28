#!/bin/sh
argv0=$(echo "$0"|sed -e 's,\\,/,g');basename=$(basename $0);basedir=$(dirname "$(readlink "$0"||echo "$argv0")");osname="$(uname -s)";if [[ $osname = Darwin* ]];then basedir="$(cd "$(dirname "$argv0")"&&pwd)";elif [[ $osname = Linux* ]];then basedir=$(dirname "$(readlink -f "$0"||echo "$argv0")");elif [[ osname = *CYGWIN* ]];then basedir=`cygpath -w "$basedir"`;elif [[ osname = *MSYS* ]];then basedir=`cygpath -w "$basedir"`;fi
cd "${basedir}"
SELF=$(basename "$0")

printf "\n\e[40;90m░\e[49;39m\e[46;96m░\e[49;39m\e[44;94m░\e[49;39m\e[42;92m░\e[49;39m\e[43;93m░\e[49;39m\e[45;95m░\e[49;39m\e[41;91m░\e[49;39m \e[96mbkahlert\e[39m/\e[36mLIBGUESTFS\e[39m\n"

printf "\n"
printf "\e[02mBuildin \e[1;36mbkahlert/libguestfs:latest\e[m\n"
docker build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t bkahlert/libguestfs:latest "${basedir}/.."
printf "\n"
printf "\e[02mCleanin \e[1;36mbkahlert/libguestfs:latest\e[m\n"
docker rmi -f bkahlert/libguestfs:latest
printf "\n"

for SCRIPT in *
do
  case "${SCRIPT}" in
  *~|*.bak|*${SELF})
    printf "\n"
    printf "\e[02mSkippin \e[0;36m${SCRIPT}\e[m\n"
    continue
  ;;
  *)
    printf "\n"
    printf "\e[02mCopying \e[1;36m${SCRIPT}\e[m ➜ \e[1;36m${HOME}/bin/${SCRIPT}\e[m\n"
    cp -f "./${SCRIPT}" "${HOME}/bin/${SCRIPT}"
    printf "\e[02mChmod+x \e[1;36m${HOME}/bin/${SCRIPT}\e[m\n"
    chmod +x "${HOME}/bin/${SCRIPT}"
  ;;
  esac
done

printf "\n"
printf "(〜￣△￣)〜o/￣￣￣<゜)))彡 Done.\n"
