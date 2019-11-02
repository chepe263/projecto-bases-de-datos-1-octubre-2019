/* Una fecha para empezar a contar 30, 60, 90 y 120+ dias */
SET @fecha_inicio = (SELECT MIN(orderDate) FROM orden);
/* _30dias */
SELECT
	t1.*,
	(t1.Total_Ordenes_30dias - t1.Pagos_30dias) as Saldo_30dias
FROM
(
	SELECT 
		orden.customerNumber,
		SUM(ordendetail.priceEach * ordendetail.quantityOrdered) as Total_Ordenes_30dias,
				IFNULL(
				(
					SELECT SUM(payment.amount) FROM payment
					WHERE 
						payment.paymentDate BETWEEN @fecha_inicio AND DATE_ADD(@fecha_inicio, INTERVAL 1 MONTH)
						AND
						payment.customerNumber = orden.customerNumber
				), 0) as Pagos_30dias
	FROM 
		ordendetail
	LEFT JOIN 
		orden USING (`orderNumber`)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _30dias */
/* _60dias */
SELECT
	t1.*,
	(t1.Total_Ordenes_60dias - t1.Pagos_60dias) as Saldo_60dias
FROM
(
	SELECT 
		orden.customerNumber,
		SUM(ordendetail.priceEach * ordendetail.quantityOrdered) as Total_Ordenes_60dias,
				IFNULL(
				(
					SELECT SUM(payment.amount) FROM payment
					WHERE 
						payment.paymentDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 1 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 2 MONTH)
						AND
						payment.customerNumber = orden.customerNumber
				), 0) as Pagos_60dias
	FROM 
		ordendetail
	LEFT JOIN 
		orden USING (`orderNumber`)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _60dias */
/* _90dias */
SELECT
	t1.*,
	(t1.Total_Ordenes_90dias - t1.Pagos_90dias) as Saldo_90dias
FROM
(
	SELECT 
		orden.customerNumber,
		SUM(ordendetail.priceEach * ordendetail.quantityOrdered) as Total_Ordenes_90dias,
				IFNULL(
				(
					SELECT SUM(payment.amount) FROM payment
					WHERE 
						payment.paymentDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 2 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 3 MONTH)
						AND
						payment.customerNumber = orden.customerNumber
				), 0) as Pagos_90dias
	FROM 
		ordendetail
	LEFT JOIN 
		orden USING (`orderNumber`)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _90dias */
/* _120dias */
SELECT
	t1.*,
	(t1.Total_Ordenes_120dias - t1.Pagos_120dias) as `Saldo_120dias+`
FROM
(
	SELECT 
		orden.customerNumber,
		SUM(ordendetail.priceEach * ordendetail.quantityOrdered) as Total_Ordenes_120dias,
				IFNULL(
				(
					SELECT SUM(payment.amount) FROM payment
					WHERE 
						payment.paymentDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 3 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 20 YEAR)
						AND
						payment.customerNumber = orden.customerNumber
				), 0) as Pagos_120dias
	FROM 
		ordendetail
	LEFT JOIN 
		orden USING (`orderNumber`)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _120dias */