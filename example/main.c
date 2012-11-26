#include<stdio.h>
extern int countv(char *);
int main(){
	int a;
	a = countv("2 3, 4 5, 6 7");
	printf("%d\n",a);
	return 0;
}
