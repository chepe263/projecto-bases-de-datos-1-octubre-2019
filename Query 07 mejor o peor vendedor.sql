/*
Consulta # 7
Elabore una consulta para identficar al vendedor más efectivo y al vendedor menos efectivo, con un % de diferencia entre cada uno de ellos, por oficina y por año.

AÑO, SEMESTRE, CATEGORIA, % DE VENTAS SOBRE EL TOTAL DE LA VENTA DE ESE SEMESTRE

aplicar consulta doble con join de query 5
*/
/* Crear tabla temporal para almacenar informacion de la consulta */
DROP TEMPORARY TABLE IF EXISTS tbl_ventas_ciudad_semestre;
CREATE TEMPORARY TABLE tbl_ventas_ciudad_semestre
	/* Busca el empleado con mejor y peor ventas */
	SELECT 
		customer.salesRepEmployeeNumber, 
		CONCAT(employee.firstName, " ", employee.lastName) as Nombre_Empleado,
		office.city,
		SUM(volumen_venta_por_cliente) as venta_por_empleado , 
		employee.officeCode ,
		orden_year,
		semestre,
		periodo
	FROM
		(
			SELECT 
				orden.customerNumber, 
				SUM(vol_orden.volumen_venta_orden) as volumen_venta_por_cliente, 
				YEAR(orden.orderDate) AS orden_year, 
				CEIL(MONTH(orden.orderDate) / 6) AS `semestre`,
				CONCAT(YEAR(orden.orderDate), '-', CEIL(MONTH(orden.orderDate) / 6)) AS periodo
			FROM
				(
					SELECT 
						ordendetail.orderNumber, 
						sum(quantityOrdered) as volumen_venta_orden 
					FROM 
						ordendetail
					GROUP BY 
						ordendetail.orderNumber
				) vol_orden
			LEFT JOIN 
				orden ON orden.orderNumber = vol_orden.orderNumber
			WHERE 
				orden.status = "Shipped"
			GROUP BY 
				orden.customerNumber
		) vol_customer_orders
	LEFT JOIN 
		customer ON customer.customerNumber = vol_customer_orders.customerNumber
    LEFT JOIN 
		employee ON employee.employeeNumber = customer.salesRepEmployeeNumber
	LEFT JOIN
		office on office.officeCode = employee.officeCode
	GROUP BY 
		customer.salesRepEmployeeNumber
	ORDER BY periodo, city, venta_por_empleado;
    /* Busca el empleado con mejor y peor ventas */
DROP TEMPORARY TABLE IF EXISTS tbl_ventas_ciudad_semestre_2;
CREATE TEMPORARY TABLE tbl_ventas_ciudad_semestre_2
	SELECT * FROM tbl_ventas_ciudad_semestre;
/* Crear tabla temporal para almacenar informacion de la consulta */
    
/* Crear tabla temporal para almacenar el numero de empleados en cada ciudad/oficina
	agrupado por periodo y ciudad
*/
DROP TEMPORARY TABLE IF EXISTS tbl_ventas_ciudad_semestre_conteo;
CREATE TEMPORARY TABLE tbl_ventas_ciudad_semestre_conteo
SELECT salesRepEmployeeNumber, city, periodo, venta_por_empleado, count(city) AS total_registros FROM tbl_ventas_ciudad_semestre
	GROUP BY periodo, city
    ORDER BY venta_por_empleado DESC;
    
/* unir ambas tablas temporales para saber que ciudad tiene mas de un vendedor
   la idea es que si solo tiene un vendedor, este es el mejor vendedor
   mientras que si tiene mas de un vendedor, se puede encontrar el peor y mejor vendedor
*/

/* tabla peor vendedor */
DROP TEMPORARY TABLE IF EXISTS tbl_ventas_peor_vendedor;
CREATE TEMPORARY TABLE tbl_ventas_peor_vendedor
		SELECT 
			Nombre_Empleado,
            city,
            venta_por_empleado,
            orden_year,
            semestre,
            periodo,
            total_registros
        FROM
        (
			SELECT  
				tbl_ventas_ciudad_semestre.*,
				tbl_ventas_ciudad_semestre_conteo.total_registros
				
			FROM 
				tbl_ventas_ciudad_semestre
			LEFT JOIN 
				tbl_ventas_ciudad_semestre_conteo
			ON 
				tbl_ventas_ciudad_semestre.city = tbl_ventas_ciudad_semestre_conteo.city AND tbl_ventas_ciudad_semestre.periodo = tbl_ventas_ciudad_semestre_conteo.periodo
			WHERE tbl_ventas_ciudad_semestre.venta_por_empleado IN (
				SELECT MIN(b.venta_por_empleado) from tbl_ventas_ciudad_semestre_2 b
				GROUP BY periodo, city
			)
		) d
			ORDER BY
				periodo ASC, venta_por_empleado DESC;
/* tabla mejor vendedor */

DROP TEMPORARY TABLE IF EXISTS tbl_ventas_mejor_vendedor;
CREATE TEMPORARY TABLE tbl_ventas_mejor_vendedor
		SELECT 
			Nombre_Empleado,
            city,
            venta_por_empleado,
            /*orden_year,
            semestre,
            
            total_registros*/
            periodo
        FROM
        (
			SELECT  
				tbl_ventas_ciudad_semestre.*,
				tbl_ventas_ciudad_semestre_conteo.total_registros
				
			FROM 
				tbl_ventas_ciudad_semestre
			LEFT JOIN 
				tbl_ventas_ciudad_semestre_conteo
			ON 
				tbl_ventas_ciudad_semestre.city = tbl_ventas_ciudad_semestre_conteo.city AND tbl_ventas_ciudad_semestre.periodo = tbl_ventas_ciudad_semestre_conteo.periodo
			WHERE tbl_ventas_ciudad_semestre.venta_por_empleado IN (
				SELECT MAX(b.venta_por_empleado) from tbl_ventas_ciudad_semestre_2 b
				GROUP BY periodo, city
			)                
                
			ORDER BY 
				city,
                periodo,
				venta_por_empleado DESC
		) dd
			ORDER BY
				periodo ASC, venta_por_empleado DESC;
                
/* FINAL FINAL FINAL */
 DROP TEMPORARY TABLE IF EXISTS tbl_resultado_ventas;
 CREATE TEMPORARY TABLE tbl_resultado_ventas
	SELECT 
		tbl_ventas_peor_vendedor.city as `Oficina`,
		tbl_ventas_peor_vendedor.orden_year as `Año`,
		tbl_ventas_peor_vendedor.semestre as `Semestre`,
		CASE WHEN tbl_ventas_peor_vendedor.total_registros = 1 THEN
			null
		ELSE
			tbl_ventas_peor_vendedor.`Nombre_Empleado`
		END  as `Peor Vendedor`,
		CASE WHEN tbl_ventas_peor_vendedor.total_registros = 1 THEN
			null
		ELSE
			tbl_ventas_peor_vendedor.`venta_por_empleado`
		END  as `Peor Ventas`,
		
		CASE WHEN tbl_ventas_peor_vendedor.total_registros = 1 THEN
			tbl_ventas_peor_vendedor.`Nombre_Empleado`
		ELSE
			tbl_ventas_mejor_vendedor.`Nombre_Empleado`
		END  as `Mejor Vendedor`,
		CASE WHEN tbl_ventas_peor_vendedor.total_registros = 1 THEN
			tbl_ventas_peor_vendedor.`venta_por_empleado`
		ELSE
			tbl_ventas_mejor_vendedor.`venta_por_empleado`
		END  as `Mejor Ventas`
	FROM
		tbl_ventas_peor_vendedor
	RIGHT JOIN
		tbl_ventas_mejor_vendedor 
	ON 
		tbl_ventas_mejor_vendedor.periodo = tbl_ventas_peor_vendedor.periodo AND
		tbl_ventas_mejor_vendedor.city = tbl_ventas_peor_vendedor.city;

SELECT 
	Oficina,
    Año,
    Semestre,
    `Peor Vendedor`,
    FORMAT(`Peor Ventas`, 2) as `Peor Ventas`,
    `Mejor Vendedor`,
    FORMAT(`Mejor Ventas`, 2) as `Mejor Ventas`,
    CASE WHEN `Peor Vendedor` IS NULL THEN
		"0 %"
	ELSE 
	CONCAT(
		CONVERT(
			( (`Mejor Ventas` - `Peor Ventas`) / `Mejor Ventas`) * 100,
			decimal(4, 2)
		)
	,'%')
    END as `% Diferencia`
FROM
	tbl_resultado_ventas