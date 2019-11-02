/*
Consulta # 9
Elabore una consulta que muestre el saldo a 30 días, a 60 días, a 90 días, a 120 días o más, por cliente.



CLIENTE, SALDO TOTAL, SALDO A 30 DÍAS, SALDO A 60 DÍAS, SALDO A 90 DÍAS, SALDO A 120 O MAS
*/
/* Una fecha para empezar a contar 30, 60, 90 y 120+ dias */
SET @fecha_inicio = (SELECT MIN(orderDate) FROM orden);
/* _30dias */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_saldos_30dias;
CREATE TEMPORARY TABLE tbl_temp_saldos_30dias
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
	WHERE 
		orden.orderDate BETWEEN @fecha_inicio AND DATE_ADD(@fecha_inicio, INTERVAL 1 MONTH)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _30dias */
/* _60dias */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_saldos_60dias;
CREATE TEMPORARY TABLE tbl_temp_saldos_60dias
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
	WHERE 
		orden.orderDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 1 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 2 MONTH)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _60dias */
/* _90dias */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_saldos_90dias;
CREATE TEMPORARY TABLE tbl_temp_saldos_90dias
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
	WHERE 
		orden.orderDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 2 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 3 MONTH)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _90dias */
/* _120dias */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_saldos_120dias;
CREATE TEMPORARY TABLE tbl_temp_saldos_120dias
SELECT
	t1.*,
	(t1.Total_Ordenes_120dias - t1.Pagos_120dias) as `Saldo_120dias`
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
	WHERE 
		orden.orderDate BETWEEN DATE_ADD(@fecha_inicio, INTERVAL 3 MONTH) AND DATE_ADD(@fecha_inicio, INTERVAL 20 YEAR)
	GROUP BY 
		orden.customerNumber 
) t1;
/* _120dias */

/* insertar todo en una tabla */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_mora_trimestres;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_mora_trimestres(
	t_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	customerNumber INT NOT NULL,
    Saldo1 DECIMAL(10,2),
    Saldo2 DECIMAL(10,2),
    Saldo3 DECIMAL(10,2),
    Saldo4 DECIMAL(10,2)
);

/* insertar trimestre 1*/
INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo1)
SELECT customerNumber, Saldo_30dias
FROM tbl_temp_saldos_30dias
WHERE Saldo_30dias > 0;

/* actualizar los que esten del trimestre 2*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_saldos_60dias
SET tbl_temp_clientes_con_mora_trimestres.Saldo2 = tbl_temp_saldos_60dias.Saldo_60dias
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_saldos_60dias.customerNumber
     AND tbl_temp_saldos_60dias.Saldo_60dias > 0;
     
 /* actualizar los que esten del trimestre 2*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_saldos_60dias
SET tbl_temp_clientes_con_mora_trimestres.Saldo2 = tbl_temp_saldos_60dias.Saldo_60dias
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_saldos_60dias.customerNumber
     AND tbl_temp_saldos_60dias.Saldo_60dias > 0;
 DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT *
FROM tbl_temp_saldos_60dias
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres)
           AND Saldo_60dias > 0;


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo2)
SELECT customerNumber, Saldo_60dias
FROM tbl_temp_morosos_nuevos;

/* actualizar los que esten del trimestre 3*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_saldos_90dias
SET tbl_temp_clientes_con_mora_trimestres.Saldo3 = tbl_temp_saldos_90dias.Saldo_90dias
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_saldos_90dias.customerNumber
	 AND tbl_temp_saldos_90dias.Saldo_90dias > 0;

/* insertar nuevos del trimestre 3*/
DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT customerNumber, Saldo_90dias
FROM tbl_temp_saldos_90dias
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres)
           AND Saldo_90dias > 0;


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo3)
SELECT *
FROM tbl_temp_morosos_nuevos;

/* actualizar los que esten del trimestre 4*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_saldos_120dias
SET tbl_temp_clientes_con_mora_trimestres.Saldo4 = tbl_temp_saldos_120dias.Saldo_120dias
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_saldos_120dias.customerNumber
	 AND tbl_temp_saldos_120dias.Saldo_120dias > 0;

/* insertar nuevos del trimestre 4*/
DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT customerNumber, Saldo_120dias
FROM tbl_temp_saldos_120dias
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres)
           AND Saldo_120dias > 0;


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo4)
SELECT *
FROM tbl_temp_morosos_nuevos;
/* insertar todo en una tabla */

SELECT
	c.customerName as Cliente,
	FORMAT(r.saldo1, 2) as `Saldo a 30 dias`,
    FORMAT(r.saldo2, 2) as `Saldo a 60 dias`,
    FORMAT(r.saldo3, 2) as `Saldo a 90 dias`,
    FORMAT(r.saldo4, 2) as `Saldo a 120 dias o Mas`,
    FORMAT(
		IFNULL(r.saldo1, 0) + 
        IFNULL(r.saldo2, 0) + 
        IFNULL(r.saldo3, 0) + 
        IFNULL(r.saldo4, 0) 
        ,2
    ) as `Saldo Total`
FROM
	tbl_temp_clientes_con_mora_trimestres r
LEFT JOIN
	customer c USING (`customerNumber`)