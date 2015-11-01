#!/usr/bin/ksh
# Quick reporter on status of finished rsync jobs.
#
        gawk '  
                /Number of files/ {
                        gsub(",","",$6) ;
                        files = files + $6 ;
                        dirs = dirs + substr($8,1,length($8)-1) ;
                        }
                /Number of regular files/ {
                        sentfiles = sentfiles + $6 ;
                        }
                /Total file size/ {
                        sizescale = substr($4,length($4)) ;
                        filesize  = substr($4,1,length($4)-1) ;
                        if( sizescale == "M" ){
                                filesize = filesize * 1024 ;
                                }
                        if( sizescale == "G" ){
                                filesize = filesize * 1024 * 1024 ;
                                }
                        totalsize = totalsize + filesize ;
                        }
                /Total bytes sent/ {
                        sizescale = substr($4,length($4)) ;
                        filesize  = substr($4,1,length($4)-1) ;
                        if( sizescale == "M" ){
                                filesize = filesize * 1024 ;
                                }
                        if( sizescale == "G" ){
                                filesize = filesize * 1024 * 1024 ;
                                }
                        totalsent = totalsent + filesize ;
                        }
                END {   
                        printf "Compared %s files & %s dirs, Scanned %sGB sent %sGB, Matched %s files.\n",
                                files, dirs, totalsize/1024/1024, totalsent/1024/1024,sentfiles ;
                        }' rsync.*.ls.*.log
