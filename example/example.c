
#include<stdio.h>
// following headers are required for UDF
#include<sqludf.h>
#include<sql.h>
#include<sqlda.h>
#include<sqlca.h>
#include<memory.h>


void SQL_API_FN example(
	SQLUDF_VARCHAR *poly,
	SQLUDF_INTEGER *out,
	SQLUDF_NULLIND *inNullInd,
	SQLUDF_NULLIND *outNullInd,
	SQLUDF_TRAIL_ARGS)
{
	sscanf(poly, "%d", out);
	*outNullInd = 0;
	return;
}
