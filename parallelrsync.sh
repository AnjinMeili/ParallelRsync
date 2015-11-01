#!/usr/bin/ksh
#
# Script to send the contents of one filesystem to another.
# Source directory is scanned for contents, producing two files.  The first is
# an audit source, with fully pathed filenames, date, permissions, etc.  The
# second is a list of all files to send.
#
# Second list is split into tasks of JOBSIZE entries.  These are then grouped
# into jobs, and a control file created to allow all batches to run in parallel.
#
JOBSIZE="50000"
WDIR="/prod_Sybase_statmon/$1"
mkdir $WDIR
cd $2

echo "Checking for existing ls data."

if [ ! -f ${WDIR}/${1}.ls ]
then
    echo "Building a work list from $2 and saving to queue $1"
    time ls -1laR > ${WDIR}/${1}.ls
fi

echo "Splitting list into jobs..."

gawk 'BEGIN{
    linecnt = "'$JOBSIZE'" ;
    FileName = "'$1'" ;
    WDIR="'$WDIR'" ;
    dirout = sprintf("%s/%s.dirs",WDIR,FileName) ;
    fileout = sprintf("%s/%s.files",WDIR,FileName) ;
    allout = sprintf("%s/%s.all",WDIR,FileName) ;
    printf "Type|Name|Size|FileCnt|Date|MASK|UID|GID\n" > allout ;
    ridx = 0 ;
    rfile = sprintf("%s/rsync.%s.ls.%s",WDIR,FileName,ridx) ;
    }
{
    if( substr($0,1,1)=="." && substr($0,length($0),1) == ":" ) {
        dirname = substr($0,1,length($0)-1) ;
        }
    if( $1 == "total" ) {
        dirfcnt = $2 ;
        }
    if( $9 == "." ) {
        dirdate = sprintf("%s %s %s",$6,$7,$8) ;
        dirsize = $5 ; dirmask = $1 ; diruid = $3 ; dirgid = $4 ;
        printf "D|%s|%s|%s|%s|%s|%s|%s\n",dirname,dirsize,dirfcnt,dirdate,dirmask,diruid,dirgid >> allout
        }
    if( substr($1,1,1) == "-" ) {
        filename = sprintf("%s/%s",dirname,$9) ;
        if( NF > 9 ) {
            for( i=10 ; i<=NF ; i++ ) {
                filename = sprintf("%s %s",filename,$i) ;
                }
            }
        filesize = $5 ; filemask = $1 ; fileuid = $3 ; filegid = $4 ;
        filedate = sprintf("%s %s %s",$6,$7,$8) ;
        printf "F|%s|%s||%s|%s|%s|%s\n",filename,filesize,filedate,filemask,fileuid,filegid >> allout
        printf "%s\n",filename >> rfile ;
        nline = nline + 1 ;
        if ( nline == linecnt ) {
            close(rfile) ; ridx = ridx + 1 ; nline = 0 ;
            rfile = sprintf("%s/rsync.%s.ls.%s",WDIR,FileName,ridx) ;
            }
        }
    }' ${WDIR}/${1}.ls
   
echo "Building rsync job queues..."
cd $WDIR
rm -f rsync_jobs.list

for file in `ls rsync.*.ls.*`
do
    echo "/opt/csw/bin/rsync --stats --links --perms --files-from=${WDIR}/${file} -avzhtogue ssh ${2} root@
scc-prd-nbu01:/Archives/${1} > ${WDIR}/${file}.log 2>&1" >> $WDIR/rsync_jobs.list
done

rm -f rsync.que.* run.rsync.queue
gawk '{
        que = que + 1 ;
        if( que > 16 ) que = 1 ;
        fname = sprintf("'${WDIR}'/rsync.que.%s",que) ;
        print $0 >> fname ;
        close(fname);
        }
    END {
        for(i=1;i<=16;i++){
            printf "nohup time ksh '${WDIR}'/rsync.que.%s > '${WDIR}'/rsync.que.%s.out 2>&1 &\n",i,i >> "ru
n.rsync.queue" ;
            }
        }' ${WDIR}/rsync_jobs.list
   
echo "Assuming everything went well, just kick off the job ${WDIR}/run.rsync.queue"
