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

__device__ int PtInPolygon(int x,int y, int *poly_x, int *poly_y, int nCount){
        int nCross=0,i;
        int x1,x2,y1,y2;
        double ix;
        for(i=0;i<nCount-1;i++){
                x1=poly_x[i];
                y1=poly_y[i];
                x2=poly_x[i+1];
                y2=poly_y[i+1];
                if(y1==y2)continue;
                if(y<min(y1,y2))continue;
                if(y>=max(y1,y2))continue;
                ix=(double)(y-y1)*(double)(x2-x1)/(double)(y2-y1)+x1;
                if(ix>x)nCross++;
        }
        return(nCross%2==1);
}


__global__ void kernel(int nr_v1, int *poly1_x, int *poly1_y, int nr_v2, int *poly2_x, int *poly2_y, int left, int top, int *result){
	int tid = threadIdx.x+blockIdx.x*blockDim.x+blockIdx.y*gridDim.x*blockDim.x;
        int x = blockIdx.x + left,y = blockIdx.y + top;
        int *poly_x, *poly_y, nr_v;
        poly_x = (tid%2 == 0) ? poly1_x:poly2_x;
	poly_y = (tid%2 == 0) ? poly1_y:poly2_y;
        nr_v = (tid%2 == 0) ? nr_v1:nr_v2;
        if(PtInPolygon(x, y, poly_x, poly_y, nr_v) == 1)
                result[tid] = 1;
        else result[tid] = 0;

}

void parsePoly(char *line,polygon *poly){
		int i, offset = 0;
		sscanf(line, "%d, %d %d %d %d", &poly->nr_vertice, &poly->mbr[0], &poly->mbr[1], &poly->mbr[2], &poly->mbr[3]);
		//printf("%d, %d %d %d %d\n", poly->nr_vertice, poly->mbr[0], poly->mbr[1], poly->mbr[2], poly->mbr[3]);
		while(line[offset++] != ',');
		while(line[offset++] != ',');
		poly->x = (int *)malloc(poly->nr_vertice*sizeof(int));
		poly->y = (int *)malloc(poly->nr_vertice*sizeof(int));
		for(i=0;i<poly->nr_vertice;i++){
			sscanf(line+offset, "%d %d", &poly->x[i], &poly->y[i]);
			while(line[offset++] != ',');
		}
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

	polygon *poly1,*poly2;
	poly1 = (polygon *)malloc(sizeof(polygon));
	poly2 = (polygon *)malloc(sizeof(polygon));
	parsePoly(polygon1, poly1);
	parsePoly(polygon2, poly2);
	if(filter(poly1,poly2)){
		cout<<"NO!"<<endl;
		return 1;
	}
	int *dev_poly1_x, *dev_poly1_y, *dev_poly2_x, *dev_poly2_y;
	int *host_result, *dev_result;
	int boxsize = (poly1->mbr[1]-poly1->mbr[0]+1)*(poly1->mbr[3]-poly1->mbr[2]+1);
	cudaMalloc((void **)&dev_poly1_x, poly1->nr_vertice*sizeof(int));
	cudaMalloc((void **)&dev_poly1_y, poly1->nr_vertice*sizeof(int));
	cudaMalloc((void **)&dev_poly2_x, poly2->nr_vertice*sizeof(int));
	cudaMalloc((void **)&dev_poly2_y, poly2->nr_vertice*sizeof(int));
	cudaMalloc((void **)&dev_result, 2*boxsize*sizeof(int));

	cudaMemcpy(dev_poly1_x, poly1->x, poly1->nr_vertice*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_poly1_y, poly1->y, poly1->nr_vertice*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_poly2_x, poly2->x, poly2->nr_vertice*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_poly2_y, poly2->y, poly2->nr_vertice*sizeof(int), cudaMemcpyHostToDevice);

	clock_t start, end;
	start = clock();
	dim3 grids(poly1->mbr[1]-poly1->mbr[0],poly1->mbr[3]-poly1->mbr[2]);
	kernel<<<grids, 2>>>(poly1->nr_vertice, dev_poly1_x, dev_poly1_y, poly2->nr_vertice, dev_poly2_x, dev_poly2_y, poly1->mbr[0], poly1->mbr[2], dev_result);

	host_result = (int *)malloc(2*boxsize*sizeof(int));
	cudaMemcpy(host_result, dev_result, 2*boxsize*sizeof(int), cudaMemcpyDeviceToHost);
	for(int i=0;i<boxsize;i++){
	//	cout<<i % (poly1->mbr[1]-poly1->mbr[0])+poly1->mbr[0]<<" "<<i/(poly1->mbr[1]-poly1->mbr[0])+poly1->mbr[2]<<endl;
		if(host_result[2*i] == 1 && host_result[2*i+1] == 0){
			end = clock();
			cout<<"NO! Time used: "<<end-start<<endl;
			return 1;
		}
	}
	end = clock();
	cout<<"YES! Time used: "<<end-start<<endl;
	return 0;
}
