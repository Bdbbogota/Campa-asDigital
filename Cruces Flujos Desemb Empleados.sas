proc sql;
     create table SOLIC_FLUJO as (
		select a.Numero_Identificacion,
	      a.TIPO_ID,
          b.FECHA_RADICACION,
          b.BPM_ID_SOLICITUD, 
          b.Dias_radicacion, 
          b.Bpm_Ingresos_Totales_Motor,
          b.Bpm_Subfuente,
          b.bpm_estado_solicitud,
		  b.BPM_NUMERO_SOLICITANTES,
          b.radicacion_flujo
     from cliente as a 
     left join SOLIC_INNOVA_TCR as b
         ON A.TIPO_ID =B.btiid_codigo
         and A.Numero_Identificacion=B.clie_codigo);
run;

proc sql;
     create table SOLIC_FLUJO as (
		select a.*,
	      b.radicacion_flujo_vh,
		  b.FECHA_RADICACION as FECHA_RADICACION_VH,
		  b.Estado_VH	
     from SOLIC_FLUJO as a 
     left join SOLIC_FLUJO_VH as b
         ON A.TIPO_ID =B.btiid_codigo
         and A.Numero_Identificacion=B.clie_codigo);
run;


data SOLIC_FLUJO;
	set SOLIC_FLUJO;
	if FECHA_RADICACION in (.) and radicacion_flujo_vh = 1 then
		DO;
			FECHA_RADICACION=FECHA_RADICACION_VH;
			bpm_estado_solicitud = Estado_VH;
			Bpm_Subfuente = 'VEHICULO';
		END;
run;

proc freq data=SOLIC_FLUJO;
table radicacion_flujo;
table Bpm_Subfuente;
table FECHA_RADICACION;
TABLE radicacion_flujo_vh;
table bpm_estado_solicitud; 
run;

proc tabulate data = SOLIC_FLUJO;
class bpm_estado_solicitud Bpm_Subfuente;
table bpm_estado_solicitud, Bpm_Subfuente;
run;

data excluir_rad_flujos;
set SOLIC_FLUJO;
where ((radicacion_flujo = 1  and bpm_subfuente IN ('INNOVA','TCREDITO', 'VIVIENDA')) OR
		radicacion_flujo_vh = 1);
keep TID ID TIPO_ID Numero_Identificacion FECHA_RADICACION bpm_estado_solicitud Bpm_Subfuente;
run;


proc export
data=work.excluir_rad_flujos 
dbms=csv
outfile="&archivosSalida..csv"
replace;
run;

/***************CRUCES CONTRA DESEMBOLSOS*************************/
	proc sql;
     create table Valida_Desembolso as (
		select a.*,
	      b.des,
		  b.FECHA_APERTURA as FECHAS,
		  b.FECHA_APERTURA_uXm,
		  b.BLICR_CODIGO
     from cliente as a 
     left join desem as b
         ON A.TIPO_ID = B.btiid_codigo
         and A.Numero_Identificacion = B.clie_codigo);
run;


data excluir_desembolsos;
 set Valida_Desembolso;
 where BLICR_CODIGO not in (117,119) and des in (1);
run; 


data excluir_desembolsos;
	set excluir_desembolsos;
	keep Numero_Identificacion tipo_id blicr_codigo FECHA_APERTURA_uXm;
run;	

/*EXPORT*/
proc freq data=work.excluir_desembolsos;
	table FECHA_APERTURA_uXm;
run;

proc export
	data=work.excluir_desembolsos 
	dbms=csv
	outfile= "&archivosSalida._DES.csv"
	replace;
run;

/***************CRUCES CONTRA NOMINA*************************/
proc sql;
create table CLIENTES_EMPLEADOS as select a.*, b.empleadoBB
	from  CLIENTE as a 
		left join TOTAL_EMPLEADOS as b 
			  on A.Numero_Identificacion = B.CEDULA;

data EXCLUIR_EMPLEADOS;
set CLIENTES_EMPLEADOS;
where empleadoBB = 1;
run;


Title 'Empleado = 1 - No Empleado = 0';

proc freq data=EXCLUIR_EMPLEADOS;
	table empleadoBB;
run;

/*******REVISIÓN DE CANTIDAD DE CLIENTES QUE DEBEN RECIBIRSE LUEGO DE LAS EXCLUSIONES*******/
PROC SQL;
	CREATE TABLE CLIENTES_FILTROS
		AS (
			SELECT
				c.TIPO_ID,
				c.Numero_Identificacion,
				f.radicacion_flujo,
				f.bpm_subfuente,
				fv.radicacion_flujo_vh,
				d.des,
				d.BLICR_CODIGO,
				e.empleadoBB
			FROM 
				cliente c 
			left join SOLIC_INNOVA_TCR as f
				ON (c.TIPO_ID =f.btiid_codigo
				and c.Numero_Identificacion=f.clie_codigo)
			left join SOLIC_FLUJO_VH as fv
				ON (c.TIPO_ID =fv.btiid_codigo
				and c.Numero_Identificacion=fv.clie_codigo)
			left join desem as d
				ON (c.TIPO_ID = d.btiid_codigo
				and c.Numero_Identificacion = d.clie_codigo)
			left join TOTAL_EMPLEADOS as e
				ON (c.Numero_Identificacion = e.CEDULA)
				);

DATA CLIENTES_OK;
	SET CLIENTES_FILTROS;
	WHERE (radicacion_flujo NOT = 1 AND radicacion_flujo_vh NOT = 1 AND
		  NOT(des = 1  and BLICR_CODIGO not in (117,119)) AND 
		empleadoBB NOT = 1);
RUN;

PROC SQL;
	SELECT COUNT(1) AS CANTIDAD_CLIENTES_VIABLES FROM CLIENTES_OK;

