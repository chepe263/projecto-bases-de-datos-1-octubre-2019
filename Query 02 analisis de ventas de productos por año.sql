/*
Consulta # 2
Elabore una consulta que permita mostrar un analisis comparativo entre las ventas de un producto interanual.



PRODUCTO, VENTA AÑO 1, VENTA AÑO2, % DE VARIACION ENTRE AÑO 1 Y 2, VENTA AÑO 3, % DE VARIACION ENTRE AÑO 2 Y 3
*/
SET @ultimo_año = (SELECT MAX(YEAR(orden.orderDate)) FROM orden ORDER BY orden.orderDate DESC LIMIT 1);
/*SELECT @ultimo_año ; */
SELECT 
	product.productName as PRODUCTO,
    VENTA_AÑO1,
    VENTA_AÑO2,
    CONCAT(
		CONVERT(
			CASE 
				WHEN VENTA_AÑO1 = VENTA_AÑO2 THEN 0
				WHEN VENTA_AÑO1 > VENTA_AÑO2 THEN ( ( (VENTA_AÑO1 - VENTA_AÑO2) / VENTA_AÑO1) * -100)
				ELSE ( ( (VENTA_AÑO2 - VENTA_AÑO1) / VENTA_AÑO2) * 100)
			END,
        decimal(4,2)
        )
    ,'%') as PORCENTAJE_DE_VARIACION_ENTRE_AÑO1_Y_AÑO2,
    VENTA_AÑO3
,
    CONCAT(
		CONVERT(
			CASE 
				WHEN VENTA_AÑO2 = VENTA_AÑO3 THEN 0
				WHEN VENTA_AÑO2 > VENTA_AÑO3 THEN ( ( (VENTA_AÑO2 - VENTA_AÑO3) / VENTA_AÑO2) * -100)
				ELSE ( ( (VENTA_AÑO3 - VENTA_AÑO2) / VENTA_AÑO3) * 100)
			END,
        decimal(4,2)
        )
    ,'%') as PORCENTAJE_DE_VARIACION_ENTRE_AÑO2_Y_AÑO3
    FROM
	(
		SELECT 
			ventas_anuales.productCode,
			
			MAX(CASE WHEN año = @ultimo_año - 2 THEN total_venta_anual END) as VENTA_AÑO1,
			MAX(CASE WHEN año = @ultimo_año - 1 THEN total_venta_anual END) as VENTA_AÑO2,
			MAX(CASE WHEN año = @ultimo_año     THEN total_venta_anual END) as VENTA_AÑO3
		FROM 
			(
				/*seleccionar volumen de ventas por los ultimos tres años, "año actual" es 2021 */
				SELECT 
					ordendetail.productCode,
					concat(YEAR(orden.orderDate),'') as año,
					SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as total_venta_anual
				FROM ordendetail
				LEFT JOIN orden ON orden.orderNumber = ordendetail.orderNumber
				GROUP BY ordendetail.productCode, año
				HAVING año > @ultimo_año - 3
				/* fin seleccionar volumen de ventas por los ultimos tres años */
			) ventas_anuales
		GROUP BY ventas_anuales.productCode
	) transpuesta
LEFT JOIN product ON product.productCode = transpuesta.productCode