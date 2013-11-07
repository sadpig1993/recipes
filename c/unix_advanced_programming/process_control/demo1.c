#include <sys/types.h>
#include "ourhdr.h"

int glob = 6 ;  /* external variable in initialized data */
char buf[] = "a write to stdout\n" ;

int main(void)
{
    int     var ;
    pid_t   pid;

    var = 88 ;

    if ( write(STDOUT_FILENO, buf, sizeof(buf)-1) != sizeof(buf) - 1 ) {
        err_sys("write error") ;
    }

    printf("before fork\n") ;       /* we don't flush stdout */

    if ( ( pid = fork() ) < 0 ) {
        err_sys("fork error") ;
    }
    else if ( pid == 0 ) {
        glob ++;
        var ++;
    }
    else {
        sleep(2) ;
    }

    printf("pid = %d, glob = %d, var = %d\n", getpid(), glob, var) ;
    exit(0);

}
