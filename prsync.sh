#!/usr/bin/ksh
#
# Test script to try fpart with rsync and parallels.  
# Will walk the SOURCE, and trigger an rsync job to TARGET, 
#  for every set of FILECNT files
#
WORKDIR="$1/.prsync.work"
OUTPRE="${WORKDIR}/GS.rsync.que"
LOGFILE="${WORKDIR}/do.fpart.log"
FILECNT="10000"
JOBCNT="6"
RSYNCOPT="--stats --perms --links -avzhtogue ssh"

SOURCE="$1"
#TARGET="user@host.name:/remote/path/"
TARGET="$2"

export OUTPRE LOGFILE FILECNT JOBCNT RSYNCOPT SOURCE TARGET

echo "do.fpart starting in ${SOURCE} at `date`" > ${LOGFILE}
cd ${SOURCE}

time fpart -L -f ${FILECNT} -x '.snapshot' -x '.zfs' -Z -o ${OUTPRE} -W 'sem -j ${JOBCNT} "rsync --files-from=${FPART_PARTFILENAME} ${RSYNCOPT} ${SOURCE} ${TARGET} > ${FPART_PARTFILENAME}.rsync.log 2>&1"' . >> ${LOGFILE} 2>&1

echo "do.fpart finished at `date`" >> ${LOGFILE}
