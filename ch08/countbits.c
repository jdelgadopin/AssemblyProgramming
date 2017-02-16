#include <stdio.h>

long data = 0xfedcba9876543210;
long sum;

int main ( int argc, char **argv )
{
    int i;
    i = 0;
    sum = 0;
    while ( i < 64 ) {
         sum += data & 1;
         data >>= 1;
         i++;
    }
    printf("sum = %ld\n", sum );
    return 0;
}
