# ParallelRsync
Rsync wrapper that batches jobs through GNU Parallel.  Threading jobs on a single host or multiple hosts for optimal bandwidth.

I had the need to move millions of files from one side of the Internet to the other.  The mass was measured in terabytes with files of all sizes.  Rsync would bog down quickly, jobs consuming memory in exponentially increasing gobs.  The servers on either end would struggle, jobs would crash, and the task seemed without end.

The QoS rules encountered along the way would also nibble away at the realized bandwidth, making the task impossible to predict.  I knew a method was needed to bring more resources to bear, while utilizing them to best advantage.  Threading the task was my only real choice from the start.  So I started a journey of working with various tools to catalog the piles on either end, then split the effort into small batch jobs that could be threaded across multiple service nodes.

Home brew attempts at job control quickly gave way to Xargs and stopped when Gnu Parallel was discovered.  Rsync stayed in place as the engine of choice for moving the data.  The file indexes started as a dictionary of dictionaries to describe the attributes of each object, crafted with loving care. Only to be put aside as simpler methods became apparent.

I frequently quip that in IT, one might find a thousand ways to do anything.  One hundred of those will work every single time, and ten of those will optimal.  The exercise is to do.. for in the doing we find better ways. Systems evolve as developers grow.  And this project certainly shows this clearly.  As I sought better algorithms to handle each task, I learned of tools far more capable then my own.  Until one day I sat staring at a single line of piped together tools that handled everything in one.

Thus I stopped trying to code a better path, as well learned a great lesson in the power of refocus through process review without emotional attachment in streamlining a task.

Using fpart (http://sourceforge.net/projects/fpart/) to sort, sem (https://www.gnu.org/software/parallel/sem.html) to queue the results, and rsync (https://rsync.samba.org) as the transport.  A versatile threaded rsync tool can be created in a single command line.  One that can spread jobs across multiple servers, or stack them deep on one.  Group and spread them deep on many with the intelligence to throttle jobs if impacting.  Jobs are monitored for slow downs and network hangs, killed if they run longer then normal.  Each batch is tracked to the end, and requeued and reprocessed until all are marked with success.  Job monitoring provides clear status, with restartable master control processes that make the effort a constant movement forward.  

fpart -L -f ${FILECNT} -x '.snapshot' -x '.zfs' -Z -o ${OUTPRE} -W 'sem -j ${JOBCNT} "rsync --files-from=${FPART_PARTFILENAME} ${RSYNCOPT} ${SOURCE} ${TARGET} > ${FPART_PARTFILENAME}.rsync.log 2>&1"' . 

All that and more expressed quite simply.  Script prsync.sh is a simple filler for those variables if more example is needed.  The other scripts are examples of variants I coded along the way.

Cheers,
James Hutchinson

