/*
Consulta # 6
Elabore una consulta de % de ventas por categoría, por semestre.


AÑO, SEMESTRE, CATEGORIA, % DE VENTAS SOBRE EL TOTAL DE LA VENTA DE ESE SEMESTRE
*/
SELECT 
	comparacion.orden_year as AÑO,
    comparacion.semestre as SEMESTRE,
    comparacion.productLine as CATEGORIA,
	CONCAT(
		CONVERT(
			(volumen_venta_categoria * 100) / volumen_venta_semestre,
			decimal(4, 2)
		)
	,'%') as `% DE VENTAS SOBRE EL TOTAL DE LA VENTA DE ESE SEMESTRE`
FROM
	(
		SELECT 
			total_ventas_semestre_categoria.*, 
			total_ventas_semestre.volumen_venta_semestre 
		FROM 
			(
				SELECT 
					YEAR(orden.orderDate) AS orden_year, 
					CEIL(MONTH(orden.orderDate) / 6) AS `semestre`,
					CONCAT(YEAR(orden.orderDate), '-', CEIL(MONTH(orden.orderDate) / 6)) AS periodo,
					product.productLine,
					SUM(quantityOrdered * priceEach) AS volumen_venta_categoria 
				FROM 
					ordendetail
				LEFT JOIN 
					orden ON orden.orderNumber = ordendetail.orderNumber 
				LEFT JOIN 
					product ON product.productCode = ordendetail.productCode
				WHERE 
					orden.status = 'Shipped'
				GROUP BY 
					product.productLine,
					periodo
				ORDER BY 
					periodo ASC, 
					volumen_venta_categoria ASC
			) total_ventas_semestre_categoria

		LEFT JOIN 

		(
			SELECT 
				CONCAT(YEAR(orden.orderDate), '-', CEIL(MONTH(orden.orderDate) / 6)) AS periodo,
				SUM(quantityOrdered * priceEach) AS volumen_venta_semestre
			FROM 
				ordendetail
			LEFT JOIN 
				orden ON orden.orderNumber = ordendetail.orderNumber 
			LEFT JOIN 
				product ON product.productCode = ordendetail.productCode
			WHERE 
				orden.status = 'Shipped'
			GROUP BY 
				periodo
			ORDER BY 
				periodo ASC, 
				volumen_venta_semestre ASC
		) total_ventas_semestre ON total_ventas_semestre_categoria.periodo = total_ventas_semestre.periodo
	) comparacion