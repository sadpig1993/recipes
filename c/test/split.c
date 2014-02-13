#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define ARR_LEN (20)

char * split(char *, char *);

int main (int argc, char **argv)
{
    char s[]="120214240|2013-12-22|10000609151|10012126282|31|900.00|1.17|0.00|0.00";
    char *delim = "|";

    char **result = split(s, delim);
    int j = 0;
    while(result[j]) {
        printf("%s\n", result[j]);
        j++;
    }

    return 0;
}

/*
input:
    p  传入的字符串
    delim 分隔符
output:
    拆分后的数组
*/

char * split(char *s, char *delim)
{
    char *ret[ARR_LEN];
    int i = 0;
    if(NULL == s) {
        perror("s is null");
    }
    char *p = strtok(s, delim);
    if(NULL == p) {
        perror("data error");
    }

    ret[i] = p;

    while(p = strtok(NULL, delim) ) {
        i++;
        ret[i] = p;
    }

    return ret;

}
