
#include<stdio.h>
// following headers are required for UDF
#include<sqludf.h>
#include<sql.h>
#include<sqlda.h>
#include<sqlca.h>
#include<memory.h>

SQL_API_RC SQL_API_FN product ( SQLUDF_DOUBLE *in1,
	SQLUDF_DOUBLE *in2,
	SQLUDF_DOUBLE *outProduct,
	SQLUDF_NULLIND *in1NullInd,
	SQLUDF_NULLIND *in2NullInd,
	SQLUDF_NULLIND *productNullInd,
	SQLUDF_TRAIL_ARGS )
{

    /* Check that input parameter values are not null 
     * by checking the corresponding null indicator values
     * 0  : indicates parameter value is not NULL 
     * -1 : indicates parameter value is NULL 
     *
     * If values are not NULL, calculate the product.
     * If values are NULL, return a NULL output value. */

    if ((*in1NullInd != -1) (&& *in2NullInd != -1))
    {
	*outProduct = (*in1) * (*in2);
	*productNullInd = 0;  
    }
    else
    {
	*productNullInd = -1; 
    }
    return (0);
}


