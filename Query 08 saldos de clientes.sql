/*
Consulta # 8
Elabore una consulta que muestre el saldo de la cuenta de un cliente y el % que representa ese saldo.

CLIENTE, COMPRA TOTAL, PAGOS TOTALES, SALDO, % DEL SALDO SOBRE LA COMPRA TOTAL


*/
SELECT
	(SELECT customerName FROM customer WHERE customer.customerNumber= pagos_clientes.customerNumber) AS Cliente,
    FORMAT(pagos_clientes.Compra_Total, 2) as `COMPRA TOTAL`,
    FORMAT(pagos_clientes.Pagos_Totales, 2) as `PAGOS TOTALES`,
    FORMAT( (pagos_clientes.Compra_Total - pagos_clientes.Pagos_Totales), 2) as Saldo,
    CASE WHEN pagos_clientes.Compra_Total = pagos_clientes.Pagos_Totales THEN
     '0%'
	ELSE 
		CONCAT(
			CONVERT(
				100 - ( ( pagos_clientes.Pagos_Totales * 100) / pagos_clientes.Compra_Total),
				DECIMAL(4,2)
				),
				'%'
		)
    END as `% DEL SALDO SOBRE LA COMPRA TOTAL`
    
FROM
(
/* pagos hechos por los clientes */
	SELECT 
		compras_clientes.customerNumber,
		compras_clientes.Compra_Total,
		SUM(payment.amount) as Pagos_Totales
	FROM payment
	JOIN 
	(
		/* compra total de ordenes por clientes*/
		SELECT 
			orden.customerNumber,
			SUM(ordendetail.priceEach * ordendetail.quantityOrdered) as Compra_Total
		 FROM 
		ordendetail
		LEFT JOIN orden ON orden.orderNumber = ordendetail.orderNumber
		GROUP BY 
			orden.customerNumber
		/* compra total de ordenes por clientes*/
	) compras_clientes
	ON compras_clientes.customerNumber = payment.customerNumber
	GROUP BY 
		payment.customerNumber
/* pagos hechos por los clientes */
) pagos_clientes
ORDER BY
	(pagos_clientes.Compra_Total - pagos_clientes.Pagos_Totales) DESC, Cliente ASC;