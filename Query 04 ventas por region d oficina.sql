/*
Consulta # 4
Elabore una consulta que permita determinar las regiones con mas ventas, pero por volumen (unidades)

OFICINA, VENTAS POR VOLUMEN
*/
/* ventas por region */
SELECT office.territory as 'Region Oficina', SUM(venta_por_empleado) as 'VENTAS POR VOLUMEN'  FROM
(	SELECT customer.salesRepEmployeeNumber, SUM(volumen_venta_por_cliente) as venta_por_empleado , employee.officeCode FROM
	(
		SELECT orden.customerNumber, SUM(vol_orden.volumen_venta_orden) as volumen_venta_por_cliente FROM
		(
			SELECT ordendetail.orderNumber, sum(quantityOrdered) as volumen_venta_orden FROM ordendetail
			GROUP BY ordendetail.orderNumber
		) vol_orden
		LEFT JOIN orden ON orden.orderNumber = vol_orden.orderNumber
		WHERE orden.status = "Shipped"
		GROUP BY orden.customerNumber
	) vol_customer_orders
	LEFT JOIN customer ON customer.customerNumber = vol_customer_orders.customerNumber
    LEFT JOIN employee ON employee.employeeNumber = customer.salesRepEmployeeNumber
	GROUP BY customer.salesRepEmployeeNumber
) vol_employee_sales
LEFT JOIN office on office.officeCode = vol_employee_sales.officeCode
GROUP BY office.territory
ORDER BY 'VENTAS POR VOLUMEN' DESC
/* ventas por region */
/* ventas por (ciudad) oficina */
SELECT office.city as 'Oficina', SUM(venta_por_empleado) as 'VENTAS POR VOLUMEN'  FROM
(	SELECT customer.salesRepEmployeeNumber, SUM(volumen_venta_por_cliente) as venta_por_empleado , employee.officeCode FROM
	(
		SELECT orden.customerNumber, SUM(vol_orden.volumen_venta_orden) as volumen_venta_por_cliente FROM
		(
			SELECT ordendetail.orderNumber, sum(quantityOrdered) as volumen_venta_orden FROM ordendetail
			GROUP BY ordendetail.orderNumber
		) vol_orden
		LEFT JOIN orden ON orden.orderNumber = vol_orden.orderNumber
		WHERE orden.status = "Shipped"
		GROUP BY orden.customerNumber
	) vol_customer_orders
	LEFT JOIN customer ON customer.customerNumber = vol_customer_orders.customerNumber
    LEFT JOIN employee ON employee.employeeNumber = customer.salesRepEmployeeNumber
	GROUP BY customer.salesRepEmployeeNumber
) vol_employee_sales
LEFT JOIN office on office.officeCode = vol_employee_sales.officeCode
GROUP BY office.city
ORDER BY 'VENTAS POR VOLUMEN' DESC
/* ventas por (ciudad) oficina */