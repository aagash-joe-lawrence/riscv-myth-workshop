#include<stdio.h>

extern int load(int x,int y);

int main() {
	int result=0;
	int count;

	printf("Enter the count: ");
	scanf("%d",&count);

	result= load(0x0, count+1); // executed by assembly code

	printf("\nSum of numbers from 1 to %d is %d\n",count,result);
	return 0;
}
