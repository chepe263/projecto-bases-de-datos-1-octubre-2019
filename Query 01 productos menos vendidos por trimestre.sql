/*
Consulta # 1
Consultar los productos que menos se han vendido en los últimos 3 trimestres, indicando un % de variación entre trimestre.


PRODUCTO, TRIMESTRE 1, TRIMESTRE 2, % DE VARIACION ENTRE TRIMESTRE1 Y TRIMESTRE2, TRIMESTRE 3, % DE VARIACION ENTRE TRIMESTRE 2 Y TRIMESTRE 3, TOTAL DE LOS TRES TRIMESTRES
*/
SELECT 
	product.productName as PRODUCTO,
    FORMAT(TRIMESTRE1, 2) as TRIMESTRE1,
    FORMAT(TRIMESTRE2, 2) as TRIMESTRE2,
    CONCAT(
		CONVERT(
			CASE 
				WHEN TRIMESTRE1 = TRIMESTRE2 THEN 0
				WHEN TRIMESTRE1 > TRIMESTRE2 THEN ( ( (TRIMESTRE1 - TRIMESTRE2) / TRIMESTRE1) * -100)
				ELSE ( ( (TRIMESTRE2 - TRIMESTRE1) / TRIMESTRE2) * 100)
			END,
        decimal(4,2))
    ,'%') as PORCENTAJE_DE_VARIACION_ENTRE_TRIMESTRE1_Y_TRIMESTRE2,
    FORMAT(TRIMESTRE3, 2) as TRIMESTRE3,
    CONCAT(
		CONVERT(
			CASE 
				WHEN TRIMESTRE2 = TRIMESTRE3 THEN 0
				WHEN TRIMESTRE2 > TRIMESTRE3 THEN ( ( (TRIMESTRE2 - TRIMESTRE3) / TRIMESTRE2) * -100)
				ELSE ( ( (TRIMESTRE3 - TRIMESTRE2) / TRIMESTRE3) * 100)
			END,
		decimal(4,2))
    ,'%') as PORCENTAJE_DE_VARIACION_ENTRE_TRIMESTRE2_Y_TRIMESTRE3,
    FORMAT(TRIMESTRE1 + TRIMESTRE2 + TRIMESTRE3, 2) as TOTAL_DE_LOS_TRES_TRIMESTRES
FROM 

(
	SELECT 
		productCode,
		
		MAX(CASE WHEN TRIMESTRE = 'T1' THEN total_venta_trimestre END) as TRIMESTRE1,
		MAX(CASE WHEN TRIMESTRE = 'T2' THEN total_venta_trimestre END) as TRIMESTRE2,
		MAX(CASE WHEN TRIMESTRE = 'T3' THEN total_venta_trimestre END) as TRIMESTRE3
	FROM 
	(
		SELECT 
			ordendetail.productCode,
			CASE 
				WHEN orden.orderDate BETWEEN '2020-10-01' AND '2020-12-31' THEN  'T1'
				WHEN orden.orderDate BETWEEN '2021-01-01' AND '2021-03-31' THEN  'T2'
				WHEN orden.orderDate BETWEEN '2021-04-01' AND '2021-06-30' THEN  'T3'
			END as TRIMESTRE,
			SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as total_venta_trimestre
		FROM ordendetail
		RIGHT JOIN orden ON orden.orderNumber = ordendetail.orderNumber
		WHERE orden.orderDate BETWEEN '2020-10-01' AND '2021-06-30'
		GROUP BY ordendetail.productCode, TRIMESTRE
		) t

		GROUP BY productCode
) t2
LEFT JOIN product ON product.productCode = t2.productCode