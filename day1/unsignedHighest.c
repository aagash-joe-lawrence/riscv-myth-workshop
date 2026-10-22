#include<stdio.h>
#include<math.h>

int main(){

	long long int signed_max = (int)( pow(2,63)-1 );
	long long int signed_min = (int)( pow(2,63)*-1 );
        

	printf("Highest no represented by signed long long int is %lld\n",signed_max);
	printf("Lowest no represented by signed long long int is %lld\n",signed_min);
   
	return 0;
}
