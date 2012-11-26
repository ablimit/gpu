#include<stdio.h>
#include<string.h>

/* if poly[blockIdx.x]=',', set result[blockIdx.x]=1. The number of vertices is the number of 1 in result plus 1 */
__global__ void kernel(char *poly, int *result, int len){
        if(blockIdx.x<len){
                if(poly[blockIdx.x]==',')
                        result[blockIdx.x] = 1;
                else result[blockIdx.x] = 0;
        }
}

int countv(char *polygon)
{
        char * dev_poly;
        int * dev_result;
        int * host_result;
        int i,result;
        int len = strlen(polygon);
        cudaMalloc((void **)&dev_poly, len);
        cudaMalloc((void **)&dev_result, len*sizeof(int));

        cudaMemcpy(dev_poly, polygon, len, cudaMemcpyHostToDevice);
        kernel<<<len,1>>> (dev_poly, dev_result, len);
        host_result = (int *)malloc(len*sizeof(int));
        cudaMemcpy(host_result, dev_result, len*sizeof(int), cudaMemcpyDeviceToHost);

        //count the 1's in host_result
        result = 0;
        for(i=0;i<len;i++){
                if(host_result[i]==1)result++;
        }
        result ++;
        return result;
}

