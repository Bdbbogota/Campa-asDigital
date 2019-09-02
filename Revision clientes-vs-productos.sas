/*clientes no repetidos*/
PROC SQL;
	SELECT COUNT(1) AS CLIENTES_NO_REPETIDOS  FROM (
		SELECT COUNT(1) FROM cliente
		GROUP BY TIPO_ID, Numero_Identificacion
			HAVING COUNT(1) = 1);

/*cliente con indentificación vacia o sin aprobacion*/
PROC SQL;
	CREATE TABLE VALIDA
	AS (
		SELECT
		*
		FROM 
		cliente
		where not ((Numero_Identificacion > 0 and TIPO_ID not = '') and NAprobacion > 0 )
	);

/*productos no repetidos*/
PROC SQL;
	SELECT COUNT(1) AS PRODUCTOS_NO_REPETIDOS  FROM (
		SELECT COUNT(1) FROM PROD
		GROUP BY ECL_Tipo_Identificacion, Numero_Identificacion
/*			HAVING COUNT(1) = 1*/
);

/*producto con identificacion vacia o sin valor aprobado*/
PROC SQL;
	CREATE TABLE VALIDA
	AS (
		SELECT
		*
		FROM 
		PROD
		WHERE NOT ((Numero_Identificacion > 0 and ECL_Tipo_Identificacion not = '') and
					Valor_Aprobado > 0)
	);

/*REGISTROS QUE NO COINCIDEN ENTRE CLIENTES Y PRODUCTOS*/
PROC SQL;
	CREATE TABLE VALIDA
	AS (
		SELECT
		c.ECL_Tipo_Identificacion, c.Numero_Identificacion, '///',
		p.ECL_Tipo_Identificacion as ECL_Tipo_Identificacion_prod, p.Numero_Identificacion as Numero_Identificacion_prod,  '///',
		c.NAprobacion, sum(Valor_Aprobado)
		FROM 
		cliente c 
		full join prod p
		on (c.ECL_Tipo_Identificacion = p.ECL_Tipo_Identificacion
			and c.Numero_Identificacion = p.Numero_Identificacion)
		where (c.ECL_Tipo_Identificacion is null or c.Numero_Identificacion is null)
			or (p.ECL_Tipo_Identificacion is null or p.Numero_Identificacion is null)
			group by p.ECL_Tipo_Identificacion, p.Numero_Identificacion
	);


/*MONTOS QUE NO COINCIDEN ENTRE CLIENTES Y PRODUCTOS*/
PROC SQL;
	CREATE TABLE MONTOS_INCONSISTENTES
	AS (
		SELECT
		c.ECL_Tipo_Identificacion, c.Numero_Identificacion,
		c.NAprobacion, sum(Valor_Aprobado) AS Valor_Aprobado
		FROM 
		cliente c 
		left join prod p
		on (c.ECL_Tipo_Identificacion = p.ECL_Tipo_Identificacion
			and c.Numero_Identificacion = p.Numero_Identificacion)
			group by p.ECL_Tipo_Identificacion, p.Numero_Identificacion
	);

DATA MONTOS_INCONSISTENTES;
	SET MONTOS_INCONSISTENTES;
	WHERE NAprobacion not= Valor_Aprobado;
RUN;

/*DATA AGREGADO;*/
/*ECL_Tipo_Identificacion = 'E';*/
/*Numero_Identificacion = 123123;*/
/*RUN;*/
/**/
/*PROC APPEND BASE=PROD DATA=AGREGADO FORCE;*/


/*DATA AGREGADO_CLI;*/
/*ECL_Tipo_Identificacion = 'E';*/
/*Numero_Identificacion = 123456;*/
/*RUN;*/
/**/
/*PROC APPEND BASE=cliente DATA=AGREGADO_CLI FORCE;*/