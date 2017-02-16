#include <stdio.h>
#include <stdlib.h>

/* Search a string for matching parentheses.  If the parentheses match, returns a
 * pointer that addresses the nul terminator at the end of the string.  If they
 * don't match, the pointer addresses the first character that doesn't match.
 */
const char *match(const char *str) {
  if( *str == '\0' || *str == ')' ) { return str; }
  const char *closer = match(++str);
  if( *closer == ')' ) 
    return match(++closer);    
  return str - 1;
}


int main () {
  int index;
  const char *test[] = {
    "()", "(", ")", "", "(()))", "(((())))", "()()(()())",
    "(()()))(())()(((())))", "(()(()(()))"
  };
  
  for( index = 0; index < sizeof(test) / sizeof(test[0]); ++index ) {
    const char *result = match(test[index]);
    
    printf("%s:\t", test[index]);
    *result == '\0' ? printf("Good!\n") :
      printf("Bad @ char %ld\n", result - test[index] + 1);
  }

  return 0;
}
