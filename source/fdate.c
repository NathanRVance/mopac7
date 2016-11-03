#include<time.h>
void fdate_(utime)
char utime[24];
{
int i;
time_t t;
t=time (NULL);
for (i=0; i<24; i++)
 utime[i]= *(ctime(&t)+i);
}


