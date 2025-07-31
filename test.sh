#!/usr/bin/env bash

SERVER=${1:-"SERVER"}
NOW_DATE=$(date +"%d_%m_%Y")
WORK_DIR="/tmp"
FILE_LIST="list.out"
FILE_FAIL="${SERVER}_${NOW_DATE}_failed.out"
FILE_RUNNING="${SERVER}_${NOW_DATE}_running.out"
FILE_REPORT="${SERVER}_${NOW_DATE}_report.out"

wget -q https://raw.githubusercontent.com/GreatMedivack/files/master/list.out \
-O ${WORK_DIR}/${FILE_LIST}

if [[ ! -e ${WORK_DIR}/${FILE_FAIL} ]]; then touch ${WORK_DIR}/${FILE_FAIL}; fi
if [[ ! -e ${WORK_DIR}/${FILE_RUNNING} ]]; then touch ${WORK_DIR}/${FILE_RUNNING}; fi

grep -wE '(Error|CrashLoopBackOff)'  ${WORK_DIR}/${FILE_LIST} | \
awk '{ print $1 }' | \
sed 's/-.\{1,10\}-.\{1,5\}$//' > ${WORK_DIR}/${FILE_FAIL}

grep -wE 'Running'  ${WORK_DIR}/${FILE_LIST} | \
awk '{ print $1 }' | \
sed 's/-.\{1,10\}-.\{1,5\}$//' > ${WORK_DIR}/${FILE_RUNNING}

if [[ ! -e ${WORK_DIR}/${FILE_REPORT} ]]; then 
touch ${WORK_DIR}/${FILE_REPORT} && chmod a+r ${WORK_DIR}/${FILE_REPORT}
fi

cat << _EOF_ > ${WORK_DIR}/${FILE_REPORT}
count runnig service: $(cat ${WORK_DIR}/${FILE_RUNNING} | wc -l)

count failed service: $(cat ${WORK_DIR}/${FILE_FAIL} | wc -l)

Name user: $(echo ${LOGNAME})

Date: $(date +"%d/%m/%y")
_EOF_

mkdir -p ${WORK_DIR}/archives && \
if [[ ! -e ${WORK_DIR}/archives/${SERVER}_${NOW_DATE} ]]; then
tar -cPf ${WORK_DIR}/archives/${SERVER}_${NOW_DATE}.tar --add-file=\
"${WORK_DIR}/${FILE_LIST}" \
"${WORK_DIR}/${FILE_FAIL}" \
"${WORK_DIR}/${FILE_RUNNING}" \
"${WORK_DIR}/${FILE_REPORT}"
rm -f \
"${WORK_DIR}/${FILE_LIST}" \
"${WORK_DIR}/${FILE_FAIL}" \
"${WORK_DIR}/${FILE_RUNNING}" \
"${WORK_DIR}/${FILE_REPORT}"
else 
    echo "archive exists"
    exit 0
fi

tar -xOPf ${WORK_DIR}/archives/${SERVER}_${NOW_DATE}.tar > /dev/null
if [[ $? == 0 ]]; then
    echo "OK"
else
    echo "archive break"
fi
