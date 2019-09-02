/**************************************************************************************************\

***********************************************      
*     CONSULTA DE INFO FINANCIERA Y ESTADO     *
*  DE LAS SOLICITUDES DE INNOVA y TCREDITO     *
************************************************
*OBJ:Obtener los ingresos y costos de ventas   *
*	 de los clientes y el estado de solicitud. * 
***********************************************


PROGRAM INFORMATION
PROJ:Inteligencia de Negocios
DESC:Obtener los ingresos y costos de ventas de los clientes y el estado de solicitud.
AUTH:
DATE:

INPUTS/OUTPUTS
INs:
OUTs:

MODIFICATIONS:

PROGRAM INFORMATION
PROJ:Inteligencia de Negocios
DESC:Se crea macrovariable &Fec_Ing_Buzon.  
AUTH:Daniel Alejandro Silva Ramirez 
DATE:02-04-2019

INPUTS/OUTPUTS
INs:Fecha de ingreso Buzon.
OUTs:&Fec_Ing_Buzon.
MODIFICATIONS:

PROGRAM INFORMATION
PROJ:Inteligencia de Negocios
DESC:Se optimiza la consulta a PDTC_STBY de la tabla tc_FD_Mes_Act, en la relacion "ON c.acre_num_tarjeta=lpad(t.amed_card_nbr,23,'0')"
AUTH:Daniel Alejandro Silva Ramirez 
DATE:03-04-2019

INPUTS/OUTPUTS
INs:fd_his_attarcredito.
OUTs:tc_FD_Mes_Act.


\**************************************************************************************************/
/*Revisar el archivo
\\Bdbemcfs\Riesgocredito\PROCESOS_COMUNES\CAMPAÑAS\Información_Campañas\Información_General_Campañas\
Campañas Crédito de Consumo_Gerencia de Riesgo (ACTUAL).xlsx
de no estar alli verificar con el ejecutor de la campaña*/
%let Fec_Ing_Buzon = '12-08-2019';
%put &Fec_Ing_Buzon;

/*genera el path para dos archivos el de radicaciones y el de desembolsos que deben ser excluidos por campañas*/
/*%let archivosSalida = /sasdata/P_RIESGO/MIS/ECACER2/CAMPAÑAS/VALIDACION FLUJO PREAPROBADOS/ACTIVO 2 2019/2019-04-05_MAC_MPR;*/
%let RutaSalida= /sasdata/P_RIESGO/MIS/DSILVA5/INTELIGENCIA_NEGOCIOS/DIGITAL COMPLETO/LAN;
%let Archivo= 2019-08-26_MAC_TCR;
%let archivosSalida = &RutaSalida./&Archivo.;

data _null_;
	call symputx('dia_corrida', scan(&Fec_Ing_Buzon., 1));
	call symputx('mes_corrida', scan(&Fec_Ing_Buzon., 2));
	call symputx('anio_corrida', scan(&Fec_Ing_Buzon., 3));
run;

%put &dia_corrida.;
%put &mes_corrida.;
%put &anio_corrida.;

proc sql;
connect to oracle (path=PDODS_CCP &access_PDODS.);
create table SOLIC_INNOVA_TCR as select *
from connection to oracle (
SELECT bpm_tipo_identificacion,
       bpm_numero_identificacion,
       bpm_id_solicitud,
       bpm_fecha_radicacion,
       bpm_estado_solicitud,
       bpm_tipo_cliente,
       bpm_ingresos_totales_motor,       
       bpm_oficina_radicadora,
       bpm_subfuente,
       bpm_razon_rechazo, 
       bpm_tipo_cliente_cubo,
       bpm_sector_economico,
	   BPM_NUMERO_SOLICITANTES
FROM ods_stag.ods_bpm_solicitudes
where	(bpm_subfuente IN ('INNOVA','TCREDITO') OR
					(bpm_subfuente IN ('VIVIENDA') 
					and bpm_estado_solicitud not in ('Finalizada','Rechazada')))
					and bpm_fecha_radicacion > to_date(&Fec_Ing_Buzon., 'dd-mm-yyyy'))	;
RUN;

Data SOLIC_INNOVA_TCR;
set SOLIC_INNOVA_TCR;

     clie_codigo=BPM_NUMERO_IDENTIFICACION+0;
     format  fecha_corrida ddmmyy10.;
     format FECHA_RADICACION ddmmyy10.;

     FECHA_RADICACION = BPM_FECHA_RADICACION/(60*60*24);
     fecha_corrida=MDY(&mes_corrida.,&dia_corrida., &anio_corrida.);     
     Dias_radicacion=intck("day",fecha_corrida,FECHA_RADICACION );

     length btiid_codigo $3;
     if BPM_TIPO_IDENTIFICACION='C' then btiid_codigo='CC'; 
     else if BPM_TIPO_IDENTIFICACION='E' then btiid_codigo = 'CE';
     else if BPM_TIPO_IDENTIFICACION = 'P' then btiid_codigo = 'PAS';
     else if BPM_TIPO_IDENTIFICACION = 'R' then btiid_codigo = 'RC';

	radicacion_flujo=1;
run;
  
/* Ordenar por fecha de radicacion de la solicitud y eliminar clientes repetidos*/
proc sort data = SOLIC_INNOVA_TCR; by descending FECHA_RADICACION;run;
proc sort data = SOLIC_INNOVA_TCR nodupkey; by btiid_codigo clie_codigo;run;

/*VALIDACION VEHICULO*/

proc sql;
	connect to oracle (path=PDBPM &access_PDBPM.);
	create table SOLIC_FLUJO_VH as select *
		from connection to oracle (
			SELECT a.*,b.cod_solicitud, b.tipo_identificacion, b.numero_identificacion,
				c.fecha_radicacion as BPM_FECHA_RADICACION, c.cod_estadosolicitud,
				d.DSC_SOLICIAUTOMOV as Estado_VH			
			FROM usrbpm.bpm_inform_financiera a left join usrbpm.bpm_participante b
				on a.cod_participante=b.cod_participante
			left join usrbpm.bpm_solicitud c 
				on b.cod_solicitud=c.cod_solicitud
			left join usrbpm.prm_estado_soliciautomov d
				on c.cod_estadosolicitud = d.cod_soliciautomov
			where b.tipo_participante= 'T' and c.fecha_radicacion > to_date(&Fec_Ing_Buzon., 'dd-mm-yyyy'));

Data SOLIC_FLUJO_VH;
set SOLIC_FLUJO_VH;

     clie_codigo=numero_identificacion+0;
     format  fecha_corrida ddmmyy10.;
     format FECHA_RADICACION ddmmyy10.;

     FECHA_RADICACION = BPM_FECHA_RADICACION/(60*60*24);
     fecha_corrida=MDY(&mes_corrida.,&dia_corrida., &anio_corrida.);     
     Dias_radicacion=intck("day",fecha_corrida,FECHA_RADICACION );

     length btiid_codigo $3;
     if tipo_identificacion='C' then btiid_codigo='CC'; 
     else if tipo_identificacion='E' then btiid_codigo = 'CE';
     else if tipo_identificacion = 'P' then btiid_codigo = 'PAS';
     else if tipo_identificacion = 'R' then btiid_codigo = 'RC';

	radicacion_flujo_vh=1;
run;
/* UNIR INFORMACION DE ESTADOS Y FINANCIERA(INGRESOS,FECHA SOLICITUD) DE INNOVA*/
proc sort data = SOLIC_FLUJO_VH; by descending FECHA_RADICACION;run;
proc sort data = SOLIC_FLUJO_VH nodupkey; by btiid_codigo clie_codigo;run;


/********************************************************
*********************************************************
SE VUELVE A CORRER LUEGO DE QUE CAMPAÑAS HAGA EXCLUSIÓN
*********************************************************
*********************************************************/
/*EMPLEADOS MARCA*/
/*Revisión de Clientes Contra La Base de Empleados del Banco*/
/**************************************************************      
*           OBTENER Informacion de Empleados                  *
***************************************************************
* Revisión de Clientes Contra La Base de Empleados del Banco  * 
***************************************************************/
LIBNAME C_NOMINA "/sasdata/C_NOMINA";

data total_empleados;
set C_NOMINA.NOMINA;
 IF ESTADO_EMPLEADO ~= "RETIRADO";
     empleadoBB = 1;
     KEEP CEDULA empleadoBB;
run;

/* UNIR INFORMACION DE EMPLEADOS BB PARA VALIDACION*/
/*proc sql;*/
/*create table CLIENTES_EMPLEADOS as select a.*, b.empleadoBB*/
/*	from  CLIENTE as a */
/*		left join TOTAL_EMPLEADOS as b */
/*			  on A.Numero_Identificacion = B.CEDULA;*/
/**/
/*data CLIENTES_EMPLEADOS;*/
/*set CLIENTES_EMPLEADOS;*/
/*where empleadoBB = 1;*/
/*run;*/
/**/
/**/
/*Title 'Empleado = 1 - No Empleado = 0';*/
/**/
/*proc freq data=CLIENTES_EMPLEADOS;*/
/*	table empleadoBB;*/
/*run;*/

/*******************************************************************************
*       OBTENER DESEMBOLSO DE LOS ULTIMOS n DIAS (&dias_ult_desembolso)        *
********************************************************************************
*OBJ:Obtener la linea y los clientes a los cuales se les                       *
*    realizo un desembolso en los ultimos n dias                               *
*******************************************************************************/

	PROC SQL ;
	connect to oracle (path=CRTO &access_CRTO.);
	CREATE TABLE consulta_desm AS SELECT *
	from connection to oracle (
	select t.cli_tipo_identificacion as btiid_codigo,
	t.identificacion as clie_codigo,
	t.credito,
	t.linea AS BLICR_CODIGO,
	t.clase_car,
	t.fecha_inicial as FECHA_APERTURA
	from consulta.jf_general_cartera t
	where (t.linea < 900 and t.linea not in (410,411,110) and t.fecha_inicial >= to_date(&Fec_Ing_Buzon.,'dd-mm-yyyy'))
	);

	PROC SQL;
	connect to oracle (path=PDTC &access_PDTC.);
	create table tc_FD_Mes_Act as select *from connection to oracle
	(select clie_codigo,btiid_codigo,900 as credito,900 as BLICR_CODIGO,clase_car,max(FECHA_APERTURA) as FECHA_APERTURA 
		from (
			  select distinct TO_NUMBER(LTRIM(c.ACRE_NUM_IDEN,'0')) AS clie_codigo,
			          DECODE(c.ACRE_TIP_IDEN,'01','CC','02','CE','03','NIT','04','TI','05','PAS','06','CE','07','SES','08','L','09','RC','10','NEX','11','NIT')
			            AS btiid_codigo,
						case when c.acre_modalidad_credito ='P' then 'O'
			                 when c.acre_modalidad_credito ='C' then 'C'
			                 else c.acre_modalidad_credito
			            end clase_car,
			          R.REDAMBS_FIRST_CARD_ACTV_DATE as FECHA_APERTURA
			      from ods_stag.fd_his_attarcredito C LEFT JOIN ods_stag.fd_amed_plasticos t 
/*			        ON substr(trim(c.acre_num_tarjeta),8,23)=substr(TRIM(t.amed_card_nbr),4,16) */
				  	ON c.acre_num_tarjeta=lpad(t.amed_card_nbr,23,'0')
			      LEFT JOIN ods_stag.fd_ambs_cuentas r 
			        ON TRIM(t.amed_post_to_acct)=trim(r.ambs_acct)
			      where TRIM(c.acre_tipo_cuenta) in ('P')
			        and R.REDAMBS_FIRST_CARD_ACTV_DATE >= to_date(&Fec_Ing_Buzon.,'dd-mm-yyyy')
        )
        group by clie_codigo,btiid_codigo,clase_car
       
	);

	PROC SQL;
	connect to oracle (path=PDTC &access_PDTC.);
	create table tc_FD_Mes_Ant as select *from connection to oracle
	(select clie_codigo,btiid_codigo,900 as credito,900 as BLICR_CODIGO,clase_car,max(FECHA_APERTURA) as FECHA_APERTURA,bin 
		from (
				select distinct TO_NUMBER(LTRIM(c.ACRE_NUM_IDEN,'0')) AS clie_codigo,
						DECODE(c.ACRE_TIP_IDEN,'01','CC','02','CE','03','NIT','04','TI','05','PAS','06','CE','07','SES','08','L','09','RC','10','NEX','11','NIT')
							AS btiid_codigo,
						trim(c.acre_cod_interno_tarjeta) as credito,					
						trim(c.acre_bin) as bin,
						case when c.acre_modalidad_credito ='P' then 'O'
			                 when c.acre_modalidad_credito ='C' then 'C'
			                 else c.acre_modalidad_credito
			            end clase_car,
						R.REDAMBS_FIRST_CARD_ACTV_DATE as FECHA_APERTURA
					from ods_stag.fd_acu_attarcredito C LEFT JOIN ods_stag.fd_amed_plasticos t 
/*						ON substr(trim(c.acre_num_tarjeta),8,23)=substr(TRIM(t.amed_card_nbr),4,16) */
						ON c.acre_num_tarjeta=lpad(t.amed_card_nbr,23,'0')
					LEFT JOIN ods_stag.fd_ambs_cuentas r 
						ON TRIM(t.amed_post_to_acct)=trim(r.ambs_acct)
					where TRIM(c.acre_tipo_cuenta) in ('P')
						and R.REDAMBS_FIRST_CARD_ACTV_DATE >= to_date(&Fec_Ing_Buzon.,'dd-mm-yyyy')
        )
        group by clie_codigo,btiid_codigo,clase_car,bin
	);


	PROC SQL;
	connect to oracle (path=PDODS_CCP &access_PDODS.);
	create table tc_Open_Mes_Act as select *from connection to oracle
	(select clie_codigo,btiid_codigo,900 as credito,900 as BLICR_CODIGO,clase_car,max(FECHA_APERTURA) as FECHA_APERTURA 
		from (
			  select distinct TO_NUMBER(LTRIM(c.ACRE_NUM_IDEN,'0')) AS clie_codigo,
					DECODE(c.ACRE_TIP_IDEN,'1','CC','2','CE','3','PAS','4','N','5','TI','6','CE','7','I','8','L','9','RC')
						AS btiid_codigo,
					trim(c.acre_cod_interno_tarjeta) as credito,
					case when c.acre_modalidad_credito ='C' then 'O'
		                 when c.acre_modalidad_credito ='O' then 'C'
		                 else c.acre_modalidad_credito
		            end clase_car,
					c.ACRE_FEC_ENTGA_CLITE as FECHA_APERTURA
			from ods_stag.vw_ods_his_attarcredito C 
			WHERE TRIM(ACRE_TIPO_TARJETA) IN ('P')
				and c.ACRE_FEC_ENTGA_CLITE >= to_date(&Fec_Ing_Buzon.,'dd-mm-yyyy')
        )
        group by clie_codigo,btiid_codigo,clase_car
	);


	PROC SQL;
	connect to oracle (path=PDODS_CCP &access_PDODS.);
	create table tc_Open_Mes_Ant as select *from connection to oracle
	(select clie_codigo,btiid_codigo,900 as credito,900 as BLICR_CODIGO,clase_car,max(FECHA_APERTURA) as FECHA_APERTURA 
		from (
			  select distinct TO_NUMBER(LTRIM(c.ACRE_NUM_IDEN,'0')) AS clie_codigo,
					DECODE(c.ACRE_TIP_IDEN,'1','CC','2','CE','3','PAS','4','N','5','TI','6','CE','7','I','8','L','9','RC')
						AS btiid_codigo,
					trim(c.acre_cod_interno_tarjeta) as credito,
					case when c.acre_modalidad_credito ='C' then 'O'
		                 when c.acre_modalidad_credito ='O' then 'C'
		                 else c.acre_modalidad_credito
		            end clase_car,
					c.ACRE_FEC_ENTGA_CLITE as FECHA_APERTURA
			from ods_stag.VW_ODS_acu_ATTARCREDITO C 
			WHERE TRIM(ACRE_TIPO_TARJETA) IN ('P')
				and c.ACRE_FEC_ENTGA_CLITE >= to_date(&Fec_Ing_Buzon.,'dd-mm-yyyy')
        )
        group by clie_codigo,btiid_codigo,clase_car
	);

	proc append base=tc_Open_Mes_Act 	data= tc_Open_Mes_Ant 	force;
	proc append base=tc_Open_Mes_Act 	data= tc_FD_Mes_Ant 	force;
	proc append base=tc_Open_Mes_Act 	data= tc_FD_Mes_Act 	force;
	proc append base=consulta_desm 		data= tc_Open_Mes_Act 	force;

	data desembolsos;
	set consulta_desm;
	format FECHA_APERTURA_uXm DDMMYY10.;
	informat FECHA_APERTURA_uXm DDMMYY10.; 
	FECHA_APERTURA_uXm = FECHA_APERTURA/(24*60*60);
	run;

	/* Ordenar clientes por fecha mas reciente y elminar los repetidos*/
	proc sort data = desembolsos; by descending FECHA_APERTURA;run;
	proc sort data = desembolsos nodupkey; by btiid_codigo clie_codigo;run;


	data desem;
	set work.desembolsos;
	des=1;
	run;

/********************************************************
*********************************************************
SE VUELVE A CORRER LUEGO DE QUE CAMPAÑAS HAGA EXCLUSIÓN
*********************************************************
*********************************************************/
/*	proc sql;*/
/*     create table Valida_Desembolso as (*/
/*		select a.*,*/
/*	      b.des,*/
/*		  b.FECHA_APERTURA as FECHAS,*/
/*		  b.FECHA_APERTURA_uXm,*/
/*		  b.BLICR_CODIGO*/
/*     from cliente as a */
/*     left join desem as b*/
/*         ON A.TIPO_ID = B.btiid_codigo*/
/*         and A.Numero_Identificacion = B.clie_codigo);*/
/*run;*/
/**/
/**/
/*data dsembolsos_salida;*/
/* set Valida_Desembolso;*/
/* where BLICR_CODIGO not in (117,119) and des in (1);*/
/*run; */
/**/
/**/
/*data dsembolsos_salida;*/
/*	set dsembolsos_salida;*/
/*	keep Numero_Identificacion tipo_id blicr_codigo FECHA_APERTURA_uXm;*/
/*run;	*/
/**/
/*/*EXPORT*/*/
/*proc freq data=work.dsembolsos_salida;*/
/*	table FECHA_APERTURA_uXm;*/
/*run;*/
/**/
/*proc export*/
/*	data=work.dsembolsos_salida */
/*	dbms=csv*/
/*	outfile= "&archivosSalida._DES.csv"*/
/*	replace;*/
/*run;*/
