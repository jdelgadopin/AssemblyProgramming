import java.util.*;

public class Bitonic {
    public static void main (String[] args) {
	System.out.print("Enter a list of number: ");
	Scanner chopper = new Scanner(new Scanner(System.in).nextLine());
	int[] sequence = new int[100];
	int size;
	int i=0;
	while (chopper.hasNextInt()) {
	    sequence[i] = chopper.nextInt();
	    i++;
	}
	size = i;
	System.out.print("The sequence ");
	for (i=0; i < size; i++) {
	    System.out.print(sequence[i] + " ");
	}
	System.out.print("is ");
	if (!bitonic(sequence,size)) {
	    	System.out.print("not ");
	}
	System.out.println("bitonic");
    }
    
    public static boolean bitonic(int[] array, int size) {
	if (array == null) return false;
	if (size < 4) return true;

	// false is decreasing, true is increasing
	Boolean dir;
	
	int pos = 0;
	while (pos < array.length) {
	    if (array[pos] != array[size - 1])
		break;
	    pos++;
	}
	if (pos == array.length) return true;

	//pos here is the first element that differs from the last
	int switches = 0;
	dir = array[pos] > array[size - 1];
	while (pos < size - 1 && switches <= 2) {
	    if ((array[pos + 1] != array[pos]) &&
		((array[pos + 1] <= array[pos]) == dir)) {
		dir ^= true;
		switches++;
	    }
	    pos++;
	}

	return switches <= 2;
    }

}
