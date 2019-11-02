/*
Consulta # 10
Elabore una consulta que permita identificar a los clientes más morosos por trimestre en el último año, por oficina.

OFICINA, CLIENTE MOROSO T1, SALDO, CLIENTE MOROSO T2, SALDO, CLIENTE MOROSO T3, SALDO, CLIENTE MOROSO T4, SALDO
*/
/* obtener la fecha de la ultima orden para poder contar donde termina el ultimo trimestre*/
SET @last_date = (SELECT orderDate FROM dbTesting.orden order by orderDate DESC LIMIT 1);
/* obtener la fecha de la ultima orden para poder contar donde termina el ultimo trimestre*/

/* primer trimestre */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_mora_t1;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_mora_t1
	SELECT
		saldos_1_trimestre.customerNumber,
		saldos_1_trimestre.Compras - saldos_1_trimestre.Pagos as Saldo
	FROM
	(
		SELECT
			compras_1_trimestre.customerNumber,
			compras_1_trimestre.Compras,
			IFNULL(
			(
				SELECT SUM(payment.amount) FROM payment
				WHERE 
					payment.paymentDate BETWEEN DATE_SUB(@last_date, INTERVAL 12 MONTH) AND DATE_SUB(@last_date, INTERVAL 9 MONTH)
					AND
					payment.customerNumber = compras_1_trimestre.customerNumber
			), 0) as Pagos
				
			
		FROM
		(
			SELECT 
				orden.customerNumber,
				SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as Compras
				
			FROM 
				dbTesting.ordendetail

			JOIN
				orden ON orden.orderNumber = ordendetail.orderNumber
			WHERE 
				orden.orderDate BETWEEN DATE_SUB(@last_date, INTERVAL 12 MONTH) AND DATE_SUB(@last_date, INTERVAL 9 MONTH)
			GROUP BY
				orden.customerNumber
		) compras_1_trimestre
	) saldos_1_trimestre	
	HAVING 
		Saldo > 0
	ORDER BY
		Saldo;
/* primer trimestre */
/* segundo trimestre */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_mora_t2;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_mora_t2
	SELECT
		saldos_2_trimestre.customerNumber,
		saldos_2_trimestre.Compras - saldos_2_trimestre.Pagos as Saldo
	FROM
	(
		SELECT
			compras_2_trimestre.customerNumber,
			compras_2_trimestre.Compras,
			IFNULL(
			(
				SELECT SUM(payment.amount) FROM payment
				WHERE 
					payment.paymentDate BETWEEN DATE_SUB(@last_date, INTERVAL 9 MONTH) AND DATE_SUB(@last_date, INTERVAL 6 MONTH)
					AND
					payment.customerNumber = compras_2_trimestre.customerNumber
			), 0) as Pagos
				
			
		FROM
		(
			SELECT 
				orden.customerNumber,
				SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as Compras
				
			FROM 
				dbTesting.ordendetail

			JOIN
				orden ON orden.orderNumber = ordendetail.orderNumber
			WHERE 
				orden.orderDate BETWEEN DATE_SUB(@last_date, INTERVAL 9 MONTH) AND DATE_SUB(@last_date, INTERVAL 6 MONTH)
			GROUP BY
				orden.customerNumber
		) compras_2_trimestre
	) saldos_2_trimestre	
	HAVING 
		Saldo > 0
	ORDER BY
		Saldo;
/* segundo trimestre */
/* tercer trimestre */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_mora_t3;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_mora_t3
	SELECT
		saldos_3_trimestre.customerNumber,
		saldos_3_trimestre.Compras - saldos_3_trimestre.Pagos as Saldo
	FROM
	(
		SELECT
			compras_3_trimestre.customerNumber,
			compras_3_trimestre.Compras,
			IFNULL(
			(
				SELECT SUM(payment.amount) FROM payment
				WHERE 
					payment.paymentDate BETWEEN DATE_SUB(@last_date, INTERVAL 6 MONTH) AND DATE_SUB(@last_date, INTERVAL 3 MONTH)
					AND
					payment.customerNumber = compras_3_trimestre.customerNumber
			), 0) as Pagos
				
			
		FROM
		(
			SELECT 
				orden.customerNumber,
				SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as Compras
				
			FROM 
				dbTesting.ordendetail

			JOIN
				orden ON orden.orderNumber = ordendetail.orderNumber
			WHERE 
				orden.orderDate BETWEEN DATE_SUB(@last_date, INTERVAL 6 MONTH) AND DATE_SUB(@last_date, INTERVAL 3 MONTH)
			GROUP BY
				orden.customerNumber
		) compras_3_trimestre
	) saldos_3_trimestre	
	HAVING 
		Saldo > 0
	ORDER BY
		Saldo;
/* tercer trimestre */
/* cuarto trimestre */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_mora_t4;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_mora_t4
	SELECT
		saldos_4_trimestre.customerNumber,
		saldos_4_trimestre.Compras - saldos_4_trimestre.Pagos as Saldo
	FROM
	(
		SELECT
			compras_4_trimestre.customerNumber,
			compras_4_trimestre.Compras,
			IFNULL(
			(
				SELECT SUM(payment.amount) FROM payment
				WHERE 
					payment.paymentDate BETWEEN DATE_SUB(@last_date, INTERVAL 3 MONTH) AND @last_date
					AND
					payment.customerNumber = compras_4_trimestre.customerNumber
			), 0) as Pagos
				
			
		FROM
		(
			SELECT 
				orden.customerNumber,
				SUM(ordendetail.quantityOrdered * ordendetail.priceEach) as Compras
				
			FROM 
				dbTesting.ordendetail

			JOIN
				orden ON orden.orderNumber = ordendetail.orderNumber
			WHERE 
				orden.orderDate BETWEEN DATE_SUB(@last_date, INTERVAL 3 MONTH) AND @last_date
			GROUP BY
				orden.customerNumber
		) compras_4_trimestre
	) saldos_4_trimestre	
	HAVING 
		Saldo > 0
	ORDER BY
		Saldo;
/* cuarto trimestre */

/* Combinar trimestres */
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
SELECT *
FROM tbl_temp_clientes_con_mora_t1;

/* actualizar los que esten del trimestre 2*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_clientes_con_mora_t2
SET tbl_temp_clientes_con_mora_trimestres.Saldo2 = tbl_temp_clientes_con_mora_t2.Saldo
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_clientes_con_mora_t2.customerNumber;

/* insertar nuevos del trimestre 2*/
DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT *
FROM tbl_temp_clientes_con_mora_t2
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres);


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo2)
SELECT *
FROM tbl_temp_morosos_nuevos;

/* actualizar los que esten del trimestre 3*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_clientes_con_mora_t3
SET tbl_temp_clientes_con_mora_trimestres.Saldo3 = tbl_temp_clientes_con_mora_t3.Saldo
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_clientes_con_mora_t3.customerNumber;

/* insertar nuevos del trimestre 3*/
DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT *
FROM tbl_temp_clientes_con_mora_t3
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres);


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo3)
SELECT *
FROM tbl_temp_morosos_nuevos;

/* actualizar los que esten del trimestre 4*/
UPDATE tbl_temp_clientes_con_mora_trimestres,
       tbl_temp_clientes_con_mora_t4
SET tbl_temp_clientes_con_mora_trimestres.Saldo4 = tbl_temp_clientes_con_mora_t4.Saldo
WHERE tbl_temp_clientes_con_mora_trimestres.t_id > 0
     AND tbl_temp_clientes_con_mora_trimestres.customerNumber = tbl_temp_clientes_con_mora_t4.customerNumber;

/* insertar nuevos del trimestre 4*/
DROP
TEMPORARY TABLE IF EXISTS tbl_temp_morosos_nuevos;


CREATE
TEMPORARY TABLE tbl_temp_morosos_nuevos
SELECT *
FROM tbl_temp_clientes_con_mora_t4
WHERE customerNumber NOT IN
          (SELECT customerNumber
           FROM tbl_temp_clientes_con_mora_trimestres);


INSERT INTO tbl_temp_clientes_con_mora_trimestres (customerNumber, Saldo4)
SELECT *
FROM tbl_temp_morosos_nuevos;
/* Combinar trimestres */


    
    
/* almacenar clientes que han hecho ordenes */
DROP TEMPORARY TABLE IF EXISTS tbl_temp_clientes_con_ordenes;
CREATE TEMPORARY TABLE tbl_temp_clientes_con_ordenes
	SELECT 
		customerNumber, 
        customerName, 
        salesRepEmployeeNumber, 
        employee.officeCode, 
        office.city, 
        office.country 
	FROM 
		customer
	LEFT JOIN 
		employee ON employee.employeeNumber = salesRepEmployeeNumber
	LEFT JOIN 
		office ON employee.officeCode = office.officeCode
	WHERE customerNumber in
	(
		SELECT customerNumber FROM tbl_temp_clientes_con_mora_trimestres group by customerNumber
	);
/* almacenar clientes que han hecho ordenes */

/* Final Touches */
SELECT 
	CONCAT(tbl_temp_clientes_con_ordenes.city, ', ', tbl_temp_clientes_con_ordenes.country) as Oficina,
    tbl_temp_clientes_con_ordenes.customerName as `Cliente`,
    FORMAT(tbl_temp_clientes_con_mora_trimestres.Saldo1, 2) as `Saldo con Mora Trimestre 1`,
    FORMAT(tbl_temp_clientes_con_mora_trimestres.Saldo2, 2) as `Saldo con Mora Trimestre 2`,
    FORMAT(tbl_temp_clientes_con_mora_trimestres.Saldo3, 2) as `Saldo con Mora Trimestre 3`,
    FORMAT(tbl_temp_clientes_con_mora_trimestres.Saldo4, 2) as `Saldo con Mora Trimestre 4`
	
FROM
	tbl_temp_clientes_con_mora_trimestres
LEFT JOIN 
	tbl_temp_clientes_con_ordenes ON tbl_temp_clientes_con_ordenes.customerNumber = tbl_temp_clientes_con_mora_trimestres.customerNumber 
ORDER BY
	Oficina, Cliente