#include<iostream>
#include<fstream>
#include<time.h>
using namespace std;

typedef struct{
                int *x;
                int *y;
                int nr_vertice;
                int mbr[4];
                int *boxes;
}polygon;
void parsePoly(char *line,polygon *poly){
                int i;
                sscanf(line, "%d, %d %d %d %d", &poly->nr_vertice, &poly->mbr[0], &poly->mbr[1], &poly->mbr[2], &poly->mbr[3]);
printf("%d, %d %d %d %d\n", poly->nr_vertice, poly->mbr[0], poly->mbr[1], poly->mbr[2], poly->mbr[3]);

                poly->x = (int *)malloc(poly->nr_vertice*sizeof(int));
                poly->y = (int *)malloc(poly->nr_vertice*sizeof(int));
                for(i=0;i<poly->nr_vertice;i++){
                        sscanf(line+26+11*i, "%d %d", &poly->x[i], &poly->y[i]);
                }

}

int PtInPolygon(int x,int y, polygon *poly){
        int nCross=0,i;
        int x1,x2,y1,y2;
        double ix;
        for(i=0;i<poly->nr_vertice-1;i++){
                x1=poly->x[i];
                y1=poly->y[i];
                x2=poly->x[i+1];
                y2=poly->y[i+1];
                if(y1==y2)continue;
                if(y<min(y1,y2))continue;
                if(y>=max(y1,y2))continue;
                ix=(double)(y-y1)*(double)(x2-x1)/(double)(y2-y1)+x1;
                if(ix>x)nCross++;
        }
        return(nCross%2==1);
}


int filter(polygon *poly1, polygon *poly2){
                /* Check whether the mbr of poly1 contains in poly2 */
		if(poly2->mbr[0]<=poly1->mbr[0] && poly2->mbr[1]>=poly1->mbr[1] && poly2->mbr[2]<=poly1->mbr[2] && poly2->mbr[3]>=poly1->mbr[3])
                                return 0;
                else return 1;
}
int main()
{
        static const int read_bufsize=65536;
        char polygon1[read_bufsize], polygon2[read_bufsize];
        const char *filename = "polygon";
        fstream polyfile;
        polyfile.open(filename,fstream::in | fstream::binary);
        polyfile.getline(polygon1,read_bufsize);
        polyfile.getline(polygon2,read_bufsize);
        polygon poly1,poly2;
        parsePoly(polygon1, &poly1);
        parsePoly(polygon2, &poly2);
	clock_t start, end;
	start = clock();	
        if(filter(&poly1,&poly2)){
              cout<<"NO!\n";
              return 1;
        }
	int i,j;
	for(j=poly1.mbr[2];j<=poly1.mbr[3];j++){
		for(i=poly1.mbr[0];i<=poly1.mbr[1];i++){
//		cout<<i<<" "<<j<<", ";
		if(PtInPolygon(i, j, &poly1) == 1 && PtInPolygon(i, j, &poly2) == 0){
			end = clock();
			cout<<"NO! Time used: "<<end-start<<endl;
			return 1;
			}
		}
	}
	end = clock();
	cout<<"YES! Time used: "<<end-start<<endl;
	return 0;
}


