// A Dynamic Programming solution for subset sum problem
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Given a table computed in the subset sum algorithm, find a solution
void find_solution(int rows, int cols, int subset[rows][cols],
		   int set[], int n,
		   int neg, int pos, int sum,
		   int *solution) {

  for (int i=0; i < n; ++i) solution[i] = 0;

  // search for the first position where the sum has been found
  // Since the table has been built iterating thru the set, I can
  // go thru the set in reverse.
  int partial = sum-neg;
  int tmp = 0;
  int i = n-1;
  do {
    while ((i >= 0) && (subset[i][partial])) --i;
    ++i;
    // subset[i-1][partial] == false and subset[i][partial] == true
    // or
    // i == 0
    solution[i] = set[i];
    partial -= set[i];
    tmp += set[i];
  } while ((i>0) && (tmp != sum));  
}


// Returns a solution if there is a subset of set[] with sum equal to given sum (else NULL)
int *isSubsetSum(int set[], int n, int sum)
{
  int neg = 0;
  int pos = 0;
  for (int i = 0; i < n; ++i)
    if (set[i] < 0) neg += set[i];
    else pos += set[i];

  if  ((sum < neg) || (sum > pos)) return (int *)NULL;
  
  int rows = n;
  int cols = pos - neg + 1;
    
  // The value of subset[i][j] will be true if there is a 
  // subset of set[0..i] with sum equal to j+neg
  int subset[rows][cols];
    
  // If sum is not 0 and set is empty, then answer is false
  for (int j = 0; j < cols; ++j)
    subset[0][j] = (set[0] == (j+neg)) ? 1 : 0;
  
  // Fill the subset table in botton up manner, according to wikipedia
  for (int i = 1; i < rows; ++i) 
      for (int j = 0; j < cols; ++j) {
	int b1 = subset[i-1][j];
	int b2 = (set[i] == (j+neg)) ? 1 : 0;
	int b3 = 0;
	if ((neg <= (j+neg-set[i])) && ((j+neg-set[i]) <= pos))
	  b3 = subset[i-1][j-set[i]];
	subset[i][j] = (b1+b2+b3 > 0) ? 1 : 0;
      }
 
  // uncomment this code to print table
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++)
      printf ("%4d", subset[i][j]);
    printf("\n");
  }

  int *solution = (int *)malloc(n*sizeof(int));

  if (subset[n-1][sum-neg]==1) {
    find_solution(rows, cols, subset, set, n, neg, pos, sum, solution);
    return solution;
  } else return (int *)NULL; 

  // return subset[n-1][sum-neg]
}

// Driver program to test above function
int main()
{
  int set[] = {2, 10, 9, -3, 8, 7, 9};
  int n = 7;
  int sum = -1;
  int *solution = isSubsetSum(set, n, sum);
  if (solution != (int *)NULL) {
    printf("Found a subset with given sum\nThe sum of ");
    for(int i=0; i < n; ++i)
      if (solution[i] != 0) printf("%d ", solution[i]);
    printf("is %d\n", sum);
  }
  else
    printf("No subset with given sum\n");
  return 0;
}
