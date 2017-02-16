#include <stdio.h>
#include <stdlib.h>

int main () {
  char s1[30];
  char s2[10];
  
  printf("Primera string: ");
  scanf("%29s",s1);
  printf("Segona string: ");
  scanf("%9s",s2);

  printf("\n\n%s -- %s\n\n", s1,s2);
  
  return 0;
}
