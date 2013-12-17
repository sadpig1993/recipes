#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void handle(int s)
{
    printf("receive SIGCHLD signal\n");
    sleep(10);
    printf("end signal handle function\n");
}

main()
{
   /* register signal function */
   signal(SIGCHLD,handle);
   printf("before fork(), pid = %d\n", getpid());
   pid_t p1 = fork();

    /* child process 1  */
   if( p1 == 0 )
   {
      printf("in child 1, pid = %d\n", getpid());
      sleep(10);
      return 0;
   }

  pid_t p2 = fork();
    /* child process 2 */
  if( p2 == 0 )
  {
     printf("in child 2, pid = %d\n", getpid());
     printf("Hello world\n"); // execute 
     sleep(10);
     return 0;                //子程结束，跳回父进程
     printf("Hello\n"); // cannot execute 
  }


  int st1, st2;
  /* 等待子进程结束    */
  waitpid( p1, &st1, 0);
  waitpid( p2, &st2, 0);

  printf("in parent, child 1 pid = %d\n", p1);
  printf("in parent, child 2 pid = %d\n", p2);
  printf("in parent, pid = %d\n", getpid());
  
  printf("in parent, child 1 exited with %d\n", st1);
  printf("in parent, child 2 exited with %d\n", st2);

}
