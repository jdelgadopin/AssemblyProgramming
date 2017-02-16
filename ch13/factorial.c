
#include <stdio.h>
#include <stdlib.h>



struct BigInt {
  long size;
  long *num;
};



/************ functions defined in bigints.asm ***********/

void init_BigInt();
struct BigInt *convert_string_to_num(char[]);
void print_BigInt(struct BigInt *);
void free_BigInt(struct BigInt *);
struct BigInt *add_BigInt(struct BigInt *, struct BigInt *);
struct BigInt *prod_BigInt(struct BigInt *, struct BigInt *);
int equal(struct BigInt *, struct BigInt *);

/*********************************************************/



int main(int argc, char **argv) {

  struct BigInt *num = convert_string_to_num(argv[1]);

  struct BigInt *one;
  one = (struct BigInt *)malloc(sizeof(struct BigInt));
  one->size= 1;
  one->num = (long *)malloc(sizeof(long));
  *(one->num) = 1;
 
  struct BigInt *counter;
  counter = (struct BigInt *)malloc(sizeof(struct BigInt));
  counter->size= 1;
  counter->num = (long *)malloc(sizeof(long));
  *(counter->num) = 1;

  struct BigInt *result;
  result = (struct BigInt *)malloc(sizeof(struct BigInt));
  result->size= 1;
  result->num = (long *)malloc(sizeof(long));
  *(result->num) = 1;

  struct BigInt *tmp;


  init_BigInt();
  
  while (!equal(num, counter)) {

    tmp = prod_BigInt(result, counter);
    free_BigInt(result);
    result = tmp;
    
    tmp = add_BigInt(counter,one);
    free_BigInt(counter);
    counter = tmp;

  }

  tmp = prod_BigInt(counter, result);
  free_BigInt(result);
  result = tmp;

  print_BigInt(result);
  printf("\n");

  free_BigInt(num);
  free_BigInt(one);
  free_BigInt(result);
  free_BigInt(counter);
}


