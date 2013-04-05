
WITH PAISUID (A_PAIS_UID, B_PAIS_UID) AS (
		SELECT A.PAIS_UID, B.PAIS_UID
		FROM collection A, collection B
		where A.collection_uid = B.collection_uid
		and A.sequencenumber = 1
		and B.sequencenumber =2
		)
select count (*) from (
		SELECT
		A.pais_uid
		,A.tilename
		,ST_Area(ST_Intersection(A.polygon, B.polygon) )/ST_Area(ST_Union(A.polygon, b.polygon)) AS area_ratio
		FROM markup_polygon A, markup_polygon B, paisuid P
		WHERE     A.tilename = B.tilename 
		and      P.A_PAIS_UID = A.pais_uid
		and      P.B_PAIS_UID = B.pais_uid
		and      ST_Intersects(A.polygon, B.polygon) = TRUE
		--;
		) AS TEMP;

