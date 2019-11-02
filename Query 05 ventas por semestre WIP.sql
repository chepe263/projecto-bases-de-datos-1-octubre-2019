/*
Consulta # 5
Elabore una consulta que muestre el producto más vendido versus el producto menos vendido, % del diferencial, por semestre.

AÑO, SEMESTRE,  PRODUCTO MAS VENDIDO, CANTIDAD VENDIDA, PRODUCTO MENOS VENDIDO, CANTIDAD VENDIDA, % VARIACION ENTRE CANTIDADES
*/
SELECT
	AÑO,
    SEMESTRE,
    `PRODUCTO MAS VENDIDO`,
    FORMAT(`CANTIDAD VENDIDA (MAYOR)`, 2) as "CANTIDAD VENDIDA (MAYOR)",
    `PRODUCTO MENOS VENDIDO`,
    FORMAT(`CANTIDAD VENDIDA (MENOR)`, 2) as "CANTIDAD VENDIDA (MENOR)",
	CONCAT(
			CONVERT(
				( ( (`CANTIDAD VENDIDA (MAYOR)` - `CANTIDAD VENDIDA (MENOR)`) / `CANTIDAD VENDIDA (MAYOR)`) * 100),
				decimal(4,2))
		,'%') as `% VARIACION ENTRE CANTIDADES`
FROM
	(
		SELECT 
			min_sales.orden_year AS "AÑO",
			min_sales.semestre AS "SEMESTRE", 
			max_sales.producto AS "PRODUCTO MAS VENDIDO", 
			max_sales.most_sales AS "CANTIDAD VENDIDA (MAYOR)",
			min_sales.producto AS "PRODUCTO MENOS VENDIDO", 
			least_sales AS "CANTIDAD VENDIDA (MENOR)"
		FROM 
			(
				SELECT 
					orden_year, 
					semestre, 
					periodo, 
					product.productName as producto, 
					MIN(volumen_venta_orden) AS least_sales
				FROM
				(
					SELECT 
						YEAR(orden.orderDate) AS orden_year, 
						CEIL(MONTH(orden.orderDate) / 6) AS `semestre`,
						CONCAT(YEAR(orden.orderDate), '-', CEIL(MONTH(orden.orderDate) / 6)) AS periodo,
						ordendetail.productCode,
						SUM(quantityOrdered * priceEach) AS volumen_venta_orden 
					FROM 
						ordendetail
					LEFT JOIN 
						orden ON orden.orderNumber = ordendetail.orderNumber 
					WHERE 
						orden.status = 'Shipped'
					GROUP BY 
						ordendetail.productCode, 
						periodo
					ORDER BY 
						periodo ASC, 
						volumen_venta_orden ASC
				) min_ventas_por_semestre
				LEFT JOIN
					product ON product.productCode = min_ventas_por_semestre.productCode
				GROUP BY 
					periodo
			) min_sales
		LEFT JOIN 
			(
				SELECT  
					orden_year, 
					semestre,
					periodo,
					product.productName as producto, 
					MAX(volumen_venta_orden) AS most_sales
				FROM
				(
					SELECT 
						YEAR(orden.orderDate) AS orden_year, 
						CEIL(MONTH(orden.orderDate) / 6) AS `semestre`,
						CONCAT(YEAR(orden.orderDate), '-', CEIL(MONTH(orden.orderDate) / 6)) AS periodo,
						ordendetail.productCode,
						SUM(quantityOrdered * priceEach) AS volumen_venta_orden 
					FROM 
						ordendetail
					LEFT JOIN 
						orden ON orden.orderNumber = ordendetail.orderNumber  
					WHERE 
						orden.status = 'Shipped'
					GROUP BY 
						ordendetail.productCode, 
						periodo
					ORDER BY 
						periodo ASC, 
						volumen_venta_orden DESC
				) max_ventas_por_semestre
				LEFT JOIN
					product ON product.productCode = max_ventas_por_semestre.productCode
				GROUP BY 
					periodo
			) AS max_sales
		ON min_sales.periodo = max_sales.periodo
	) comparacion