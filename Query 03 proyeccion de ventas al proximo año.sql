/*
Consulta # 3
Elabore una consulta que permita proyectar las ventas del siguiente año considerando un incremento del 10% por categoría de producto.

CATEGORIA, VENTAS ULTIMO AÑO, VENTAS PROYECTADAS SIGUIENTE AÑO
*/
SET @ultimo_año = (SELECT MAX(YEAR(orden.orderDate)) FROM orden ORDER BY orden.orderDate DESC LIMIT 1);
/*SELECT @ultimo_año;*/
SELECT
	CATEGORIA,
    FORMAT(VENTAS_ULTIMO_AÑO, 2) as VENTAS_ULTIMO_AÑO,
    FORMAT(CEIL(VENTAS_ULTIMO_AÑO * 1.1), 2) as VENTAS_PROYECTADAS_SIGUIENTE_AÑO
FROM
(
	SELECT 
		product.productLine as CATEGORIA,
		SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as VENTAS_ULTIMO_AÑO
	FROM 
		ordendetail
	LEFT JOIN 
		product ON product.productCode = ordendetail.productCode
	LEFT JOIN 
		orden ON orden.orderNumber = ordendetail.orderNumber
	WHERE
		YEAR(orden.orderDate) = @ultimo_año 
	GROUP BY
		product.productLine
	ORDER BY
		VENTAS_ULTIMO_AÑO
) ventas_anuales