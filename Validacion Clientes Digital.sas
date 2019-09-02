/***********CRUCE PARA VALIDACION A CARGURE**************/
/****************FLUJO DIGITAL*********************/
/*******************MULTIPRODUCTO************************/

/*Objetivo: Validar que los montos y clientes que********
genera Negocios corresponda con los aprobados por riesgo*/
/***********CRUCE PARA VALIDACION A CARGURE**************/
/****************FLUJO PREAPROBRADOS*********************/
/*******************MULTIPRODUCTO************************/
/*1. Revisar el consecutivo y nombre de la campaña en estudio para realizar la consulta en LP_CAMPANAS de SARC*/
	/*1.1 Verificar el consecutivo de la campaña enviada*/
/*	Proc sql;*/
/*	create table CONSECUTIVO AS (*/
/*	SELECT 	 DISTINCT (SUBSTR(Descripcion_Campania,1,3)) AS CONSECUTIVO*/
/*	FROM	 ClientesFlujoDigital);*/

	/*1.2 Con el numero de consecutivo obtenido anteriormente validar si existe el numero y traer
	  el nombre de la campaña*/
	proc sql;
	connect to oracle (path=PDSR &access_PDSR.);
	create table NOMBRE_LP as SELECT *
		FROM 	CONNECTION TO ORACLE (
			SELECT	DISTINCT T.CAMPANA 
				FROM 	DTAVER1.LP_CAMPANAS t
					WHERE 	T.consecutivo in (780) /*Numero Obtenido en el Query 1.1*/
						);
/***************************************************************************************************/
/*2. Una vez verificada la información de la campaña*/
		%let Abr_Camp =  MONO_TC;
		%put &Abr_Camp;
		%let Nom_Camp = 'Activo III - 2019'; /*Nombres obtenidos del Query 1.2*/
/*Objetivo: Validar que los montos y clientes que********
genera Negocios corresponda con los aprobados por riesgo*/

proc sql;
	connect to oracle (path=PDSR &access_PDSR.);
	create table campa_&Abr_Camp. as SELECT *
		FROM CONNECTION TO ORACLE (
			SELECT 
				T.TID,
				T.ID,
				T.CONSECUTIVO,
				T.CAMPANA,
				T.FEC_INI_C,
				T.FEC_FIN_C,
				T.LINEA_411,
				T.LINEA_900,
				T.LINEA_900_2TC,
				T.LINEA_5,
				t.LINEA_5_36,
				t.LINEA_5_48,
				t.LINEA_5_60,
				T.LINEA_14_5,
				T.LINEA_67,
				T.LINEA_VEH,
				T.linea_110,
				T.LINEA_411_EXC,
				T.LINEA_900_EXC,
				T.LINEA_900_2TC_EXC,
				T.LINEA_5_EXC AS LINEA_5_EXC,
				t.LINEA_5_36_EXC,
				t.LINEA_5_48_EXC,
				t.LINEA_5_60_EXC,
				T.LINEA_14_5_EXC,
				T.LINEA_67_EXC,
				T.LINEA_VEH_EXC,
				T.Cupo_Ant_PTO1,
				T.Cupo_Nvo_PTO1,
				T.Cupo_Ant_PTO2,
				T.Cupo_Nvo_PTO2,
				T.Cupo_Ant_CDS,
				T.Cupo_Nvo_CDS,
				T.MAX_APROB AS Max_Aprob,
				T.PROC_IBRUTO,    
				T.INGRESO_NETO,
				T.NUMERO_VECES,
				T.ENDEUDAMIENTO_TOTAL,
				T.TRANSFER_CS_LD,
				T.verifica_ingresos,
				T.periodo_gracia
			FROM DTAVER1.LP_CAMPANAS t
				WHERE T.CAMPANA IN (&Nom_Camp.)
					);

proc sort data= campa_&Abr_Camp.;
	by TID ID;
run;


/*Cruce de Archivo por CLIENTE con consolidado de aprobaciones por en Riesgo*/
proc sql;
	create table ver_clie_C as (
		select a.*, 
			LINEA_411,
			LINEA_900,
			LINEA_900_2TC,
			LINEA_5,
			LINEA_5_36,
			LINEA_5_48,
			LINEA_5_60,
			LINEA_14_5,
			LINEA_67,
			LINEA_VEH,
			LINEA_411_EXC,
			LINEA_900_EXC,
			LINEA_900_2TC_EXC,
			LINEA_5_EXC,
			LINEA_5_36_EXC,
			LINEA_5_48_EXC,
			LINEA_5_60_EXC,
			LINEA_14_5_EXC,
			LINEA_67_EXC,
			LINEA_VEH_EXC,
			Cupo_Ant_PTO1,
			Cupo_Nvo_PTO1,
			Cupo_Ant_PTO2,
			Cupo_Nvo_PTO2,
			Cupo_Ant_CDS,
			Cupo_Nvo_CDS,
			Max_Aprob,
			b.verifica_ingresos as verifica_ingresos_val,
			b.periodo_gracia as periodo_de_gracia_val,
			b.PROC_IBRUTO AS PROC_IBRUTO_LP,
			B.INGRESO_NETO AS INGRESO_NETO_LP, 
			B.NUMERO_VECES AS NUMERO_VECES_LP, 
			B.ENDEUDAMIENTO_TOTAL AS ENDEUDAMIENTO_TOTAL_LP
		from work.CLIENTE as a left join work.campa_&Abr_Camp. as b
			on A.TIPO_ID = B.TID
			AND A.Numero_Identificacion = B.ID
			/*AND A.NAprobacion = B.SUM_APROB*/
			);

	/*Verifica si los clientes enviados tienen monto aprobadas en Riesgo
	en esas campañas*/

	/*1.Prepara incluyendo aprobación de SG y de Vehiculo*/
data ver_clie_c;
	set ver_clie_c;
/*	Max_Aprob_CS_VH= sum(Max_Aprob,LINEA_411,LINEA_VEH,sum(Cupo_Ant_PTO1,(-1)*Cupo_Nvo_PTO1),*/
/*						sum(Cupo_Ant_PTO2,(-1)*Cupo_Nvo_PTO2), sum(Cupo_Ant_CDS,(-1)*Cupo_Nvo_CDS));*/
/**/
/*	Max_Aprob_CS_VH_EXC= sum(Max_Aprob,LINEA_411_EXC,LINEA_VEH_EXC,sum(Cupo_Ant_PTO1,(-1)*Cupo_Nvo_PTO1),*/
/*						sum(Cupo_Ant_PTO2,(-1)*Cupo_Nvo_PTO2), sum(Cupo_Ant_CDS,(-1)*Cupo_Nvo_CDS));*/
/*	Max_Aprob_CS_VH = sum(LINEA_5);*/
	Max_Aprob_CS_VH_EXC = LINEA_900_EXC;

	/*MODIFICAR DE ACUERDO A LO SOLICITADO POR DIGITAL*/
	IF Max_Aprob_CS_VH > 10000000 THEN	Max_Aprob_CS_VH = 10000000;
	IF Max_Aprob_CS_VH_EXC > 10000000 THEN	Max_Aprob_CS_VH_EXC = 10000000;
run;

/*2.Verificación final Y*/
/*Calculo diferencias entre total de aprobaciones (Riesgo-Negocios)*/
DATA DIF_CLIENTES_DIGITAL;
	SET ver_clie_C;

	DIF_APROB = SUM(Max_Aprob_CS_VH, AMOUNT*(-1));
	DIF_APROB_EXC = SUM(Max_Aprob_CS_VH_EXC, AMOUNT*(-1));

	IF Max_Aprob_CS_VH_EXC IN (.,0) THEN
		NOESTA_MP_EXC = 1;
	ELSE NOESTA_MP_EXC = 0;
/*	IF proc_ibruto_LP in ("inn","ftc","pre","vda","fvu") then proc_ibruto_LP ="flu" ;*/
/*    IF proc_ibruto_LP in ("in3","ft3","pr3","vd3","fv3") then proc_ibruto_LP ="fl3" ;  */
	*if proc_ibruto_LP in ("crm","cif","cr3","di1","dis","flu","qua") then proc_ibruto_LP ="bas" ;

DIFN= (INGRESO_NETO-INGRESO_NETO_LP);
DIFNV= (NUMERO_VECES-NUMERO_VECES_LP); 
DIFET=(ENDEUDAMIENTO_TOTAL-ENDEUDAMIENTO_TOTAL_LP);
/*IF PROC_IBRUTO_LP = Fuente_Ingreso THEN DIFFI = 0;*/
/*ELSE DIFFI=1;*/
/**/
if upcase(verifica_ingresos_val) not= 'NO' then dif_Firme_Firme = 1;
else dif_Firme_Firme=0;
RUN;

Title 'No estan = 1 - Por Cliente y Dif < 0 No cuadra';

proc freq data=DIF_CLIENTES_DIGITAL;
	table NOESTA_MP_EXC;
/*	table DIF_APROB;*/
	table DIF_APROB_EXC;
	TABLE DIFN;
	TABLE DIFNV;
	TABLE DIFET;
/*	TABLE DIFFI;*/
	TABLE dif_Firme_Firme;
run;

Title 'Diferencias Archivo Cliente';
/*proc freq data=DIF_CLIENTES_DIGITAL;*/
/*	*/
/*	TABLE DIFFI;*/
/*	TABLE PROC_IBRUTO_LP;*/
/*	TABLE Fuente_Ingreso;*/
/**/
/*WHERE DIFFI = 1;*/
/*run;*/

Title 'Descriptiva Ingresos Archivo Cliente';
/*proc freq data=DIF_CLIENTES_DIGITAL;*/
/*	 */
/*	TABLE PROC_IBRUTO_LP;*/
/*	TABLE Fuente_Ingreso; */
/*run;*/

DATA VER_NOESTAN;
	SET DIF_CLIENTES_DIGITAL;

	IF NOESTA_MP_EXC = 1 /*or DIF_APROB > 0*/ or DIF_APROB < 0;
RUN;
