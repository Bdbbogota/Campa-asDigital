/***********CRUCE PARA VALIDACION A CARGURE**************/
/****************FLUJO PREAPROBRADOS*********************/
/*******************MULTIPRODUCTO************************/

/*Objetivo: Validar que los montos y clientes que********
genera Negocios corresponda con los aprobados por riesgo*/

/***********CRUCE PARA VALIDACION A CARGURE**************/
/****************FLUJO PREAPROBRADOS*********************/
/*******************MULTIPRODUCTO************************/
/*1. Revisar el consecutivo y nombre de la campaña en estudio para realizar la consulta en LP_CAMPANAS de SARC*/
/*1.1 Verificar el consecutivo de la campaña enviada*/
/************

AGREGAR VALIDACION DE VIGENCIA DE CAMPAÑA


***************/

Proc sql;
	create table CONSECUTIVO AS (
		SELECT 	 DISTINCT (SUBSTR(Descripcion_Campania,1,3)) AS CONSECUTIVO
			FROM	 ClientesFlujoPreaprobados);

/*1.2 Con el numero de consecutivo obtenido anteriormente validar si existe el numero y traer
el nombre de la campaña*/
proc sql;
	connect to oracle (path=PDSR &access_PDSR.);
	create table NOMBRE_LP as SELECT *
		FROM 	CONNECTION TO ORACLE (
			SELECT	DISTINCT T.CAMPANA 
				FROM 	DTAVER1.LP_CAMPANAS t
					WHERE 	T.consecutivo in (780) /*Modificar Numero Obtenido en el Query 1.1*/
						);
RUN; /*PARA AUTO JUSTIFICACIÓN DEL CODIGO*/

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
				T.LINEA_131,
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
				T.LINEA_5_EXC,
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

/*Homologación de Tipo de ID para cruce*/
/*PROC SQL;*/
/*	SELECT DISTINCT ECL_TIPO_IDENTIFICACION FROM work.ClientesFlujoPreaprobados;*/
/**/
/*data cliente;*/
/*	set work.ClientesFlujoPreaprobados;*/
/**/
/*	if ECL_TIPO_IDENTIFICACION = 'C' THEN*/
/*		TIPO_ID = 'CC';*/
/**/
/*	if ECL_TIPO_IDENTIFICACION = 'E' THEN*/
/*		TIPO_ID = 'CE';*/
/*run;*/
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
			LINEA_131,
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
			b.periodo_gracia as periodo_gracia_val,
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

/*REVISAR LOS PRODUCTOS ENVIADOS*/
PROC FREQ DATA=WORK.PROD;
	TABLE Linea_Bin;
RUN;

	/*1.Prepara incluyendo aprobación de SG y de Vehiculo*/
data ver_clie_c;
	set ver_clie_c;
	Max_Aprob_CS_VH= sum(Max_Aprob,LINEA_411,LINEA_VEH,sum(Cupo_Ant_PTO1,(-1)*Cupo_Nvo_PTO1),
		sum(Cupo_Ant_PTO2,(-1)*Cupo_Nvo_PTO2), sum(Cupo_Ant_CDS,(-1)*Cupo_Nvo_CDS));

	/*	Max_Aprob_CS_VH_EXC= sum(Max_Aprob,LINEA_411_EXC,LINEA_VEH_EXC,sum(Cupo_Ant_PTO1,(-1)*Cupo_Nvo_PTO1),*/
	/*						sum(Cupo_Ant_PTO2,(-1)*Cupo_Nvo_PTO2), sum(Cupo_Ant_CDS,(-1)*Cupo_Nvo_CDS));*/
/*		Max_Aprob_CS_VH = LINEA_900;*/
/*		Max_Aprob_CS_VH = SUM(LINEA_5,LINEA_14_5,LINEA_VEH, LINEA_67, LINEA_411,LINEA_900,LINEA_900_2TC);*/

	/**/
/*	Max_Aprob_CS_VH_EXC = LINEA_900_EXC;*/
run;

/*2.Verificación final Y*/
/*Calculo diferencias entre total de aprobaciones (Riesgo-Negocios)*/
DATA PRUEBA_NOESTA;
	SET ver_clie_C;
	DIF_APROB = SUM(Max_Aprob_CS_VH,NAprobacion*(-1));
	DIF_APROB_EXC = SUM(Max_Aprob_CS_VH_EXC,NAprobacion*(-1));

	IF Max_Aprob_CS_VH IN (.,0) THEN
		NOESTA_MP_EXC = 1;
	ELSE NOESTA_MP_EXC = 0;

	IF proc_ibruto_LP in ("inn","ftc","pre","vda","fvu") then
		proc_ibruto_LP ="flu";

	IF proc_ibruto_LP in ("in3","ft3","pr3","vd3","fv3") then
		proc_ibruto_LP ="fl3";

/*	if proc_ibruto_LP in ("crm","cif","cr3","di1","dis","flu","qua") then proc_ibruto_LP ="bas";*/
/*	if proc_ibruto_LP in ("crm","cr3","di1","fl3") then proc_ibruto_LP ="bas";*/
	if proc_ibruto_LP in ("fl3") then proc_ibruto_LP ="bas";

	DIFN= (INGRESO_NETO-INGRESO_NETO_LP);
	DIFNV= (NUMERO_VECES-NUMERO_VECES_LP);
	DIFET=(ENDEUDAMIENTO_TOTAL-ENDEUDAMIENTO_TOTAL_LP);

	IF PROC_IBRUTO_LP = Fuente_Ingreso THEN
		DIFFI = 0;
	ELSE DIFFI=1;

	if upcase(verifica_ingresos_val) not = upcase(verifica_ingresos) then
		difingresos=1;
	else difingresos=0;
RUN;

Title 'No estan = 1 - Por Cliente y Dif < 0 No cuadra';

proc freq data=PRUEBA_NOESTA;
table NOESTA_MP_EXC;

table DIF_APROB;

/*table DIF_APROB_EXC;*/

TABLE DIFN;

TABLE DIFNV;

TABLE DIFET;

TABLE DIFFI;

TABLE difingresos;
run;

Title 'Diferencias Archivo Cliente';

PROC TABULATE DATA=PRUEBA_NOESTA MISSING;
	CLASS PROC_IBRUTO_LP Fuente_Ingreso;
	TABLE PROC_IBRUTO_LP, Fuente_Ingreso;
RUN;

proc freq data=PRUEBA_NOESTA;
TABLE DIFFI;


WHERE DIFFI = 1;
run;

DATA VER_NOESTAN;
	SET PRUEBA_NOESTA;

	IF NOESTA_MP_EXC = 1 /*or DIF_APROB > 0*/
	or DIF_APROB < 0;
RUN;

/********************************************************/
/****************VERIFICACIÓN POR PRODUCTO***************/
/********************************************************/
/********************************************************/
/********************************************************/
/********************************************************/

/*Deja las aprobaciones por cliente*/
/*aprobado por inteligencia*/
PROC SQL;
	CREATE TABLE SUMA AS (
		SELECT TID, Numero_Identificacion, 
			ECL_Tipo_Identificacion,
			IdCampania,
			SUM(APROB_67) AS APROB_67_PM, 
			SUM(APROB_5) AS APROB_5_PM,
			SUM(APROB_14) AS APROB_14_PM,
			SUM(APROB_15) AS APROB_15_PM,
			SUM(APROB_411) AS APROB_411_PM,
			SUM(APROB_900TC1) AS APROB_900T1_PM,
			SUM(APROB_900TC2) AS APROB_900T2_PM,
			valor_Aprobado as aprobado_inteligencia,
			periodo_de_gracia
		FROM PROD
			GROUP BY TID, Numero_Identificacion
				);

	/*Ajuste tarjetas*/
DATA FINAL_SUMA;
	set suma;

	if APROB_900T1_PM in (.,0) and APROB_900T2_PM not in (.,0) then
		do;
			APROB_900T1_PM = APROB_900T2_PM;
			APROB_900T2_PM = .;
		end;
run;

/*Elimina repetidos dada la agrupación por cliente de las aprobaciones*/
proc sort data = work.FINAL_SUMA nodupkey;
	by ECL_Tipo_Identificacion Numero_Identificacion;
run;

PROC SQL;
	CREATE TABLE VER_PRODU_ AS (
		SELECT A.*,
			b.periodo_gracia as periodo_gracia_val,
			b.LINEA_411,
			b.LINEA_900,
			b.LINEA_900_2TC,
			b.LINEA_5,
			b.LINEA_5_36,
			b.LINEA_5_48,
			b.LINEA_5_60,
			b.linea_110,
			A.APROB_15_PM,
			LINEA_14_5,
			LINEA_67,
			LINEA_VEH,
			b.LINEA_411_EXC,
			b.LINEA_900_EXC,
			b.LINEA_900_2TC_EXC,
			b.LINEA_5_EXC,
			b.LINEA_5_36_EXC,
			b.LINEA_5_48_EXC,
			b.LINEA_5_60_EXC,		
			LINEA_14_5_EXC,
			LINEA_67_EXC,
			LINEA_VEH_EXC,
			Max_Aprob
		FROM FINAL_SUMA AS A LEFT JOIN campa_&Abr_Camp. AS B
			ON A.TID = B.TID
			AND A.Numero_Identificacion = B.ID
			);

	/*Calculo diferencias en productos*/
DATA VER_PRODU;
	SET VER_PRODU_;
	DIF_411 = SUM(LINEA_411,APROB_411_PM*(-1));

	IF (LINEA_900 ~= APROB_900T1_PM AND LINEA_900 ~= APROB_900T2_PM) THEN
		DIF_900 = SUM(LINEA_900,APROB_900T1_PM*(-1));
	ELSE DIF_900 = 0;

	IF (LINEA_900_2TC ~= APROB_900T2_PM AND LINEA_900_2TC ~= APROB_900T1_PM) THEN
		DIF_900_2TC = SUM(LINEA_900_2TC,APROB_900T2_PM*(-1));
	ELSE DIF_900_2TC = 0;

	/**ESTO PARA CUANDO INTELIGENCIA DECIDE NO ASIGNAR CUPO A LD SINO A CDS O VICEVERSA CUANDO RIESGO LO HABÍA ASIGNADO*/
	/*******************************************************************************************************************/

	/*Asignación de cupo de Libredestino (5) aprobado por Riesgo a Aprobado Crediservice (14) 
	por Inteligencia de Negocios en Riesgo*/
	if LINEA_5 not in (.,0) and LINEA_14_5 in (.,0) and APROB_5_PM in (.,0) and APROB_14_PM not in (.,0) then
		do;
			LINEA_14_5 = LINEA_5;
			LINEA_5 = 0;
			LD_CDS=1;
		end;

	/*Asignación de cupo de Crediservice (14) aprobado por Riesgo a Aprobado Libredestino (5)
		por Inteligencia de Negocios en Riesgo*/
	if LINEA_14_5 not in (.,0) and LINEA_5 in (.,0) and APROB_14_PM in (.,0) and APROB_5_PM not in (.,0) then
		do;
			LINEA_5 = LINEA_14_5;
			LINEA_14_5 = 0;
			CDS_LD=1;
		end;

	DIF_5 = SUM(LINEA_5,LINEA_5_36,LINEA_5_48,LINEA_5_60,APROB_5_PM*(-1));
	DIF_14_5 = SUM(LINEA_14_5,APROB_14_PM*(-1));
	DIF_67 = SUM(LINEA_67,APROB_67_PM*(-1));
	DIF_VEH = SUM(LINEA_VEH,APROB_15_PM*(-1));

	/*VALIDAR PRODUCTOS EXCLUYENTE*/
	DIF_411_EXC = SUM(LINEA_411_EXC,APROB_411_PM*(-1));

	IF (LINEA_900_EXC ~= APROB_900T1_PM AND LINEA_900_EXC ~= APROB_900T2_PM) THEN
		DIF_900_EXC = SUM(LINEA_900_EXC,APROB_900T1_PM*(-1));
	ELSE DIF_900_EXC = 0;

	IF (LINEA_900_2TC_EXC ~= APROB_900T2_PM AND LINEA_900_2TC_EXC ~= APROB_900T1_PM) THEN
		DIF_900_2TC_EXC = SUM(LINEA_900_2TC_EXC,APROB_900T2_PM*(-1));
	ELSE DIF_900_2TC_EXC = 0;
	DIF_5_EXC = SUM(LINEA_5_EXC,LINEA_5_36_EXC,LINEA_5_48_EXC,LINEA_5_60_EXC,APROB_5_PM*(-1));
	DIF_14_5_EXC = SUM(LINEA_14_5_EXC,APROB_14_PM*(-1));
	DIF_67_EXC = SUM(LINEA_67_EXC,APROB_67_PM*(-1));
	DIF_VEH_EXC = SUM(LINEA_VEH_EXC,APROB_15_PM*(-1));

	/*PERIDOD DE GRACIA*/
	if periodo_gracia_val not = periodo_de_gracia then
		difperiodo=1;
	else difperiodo=0;

	/*ADN CAMPAÑA ESPECIAL*/
	DIF_adn= sum (linea_110,aprobado_inteligencia*(-1));
/*	DROP TID;*/
RUN;

proc sql;
	create table revisar_casos as (
		select *
			from	VER_PRODU
				where 	DIF_411 not in (0,.));
	Title 'Conteo de asignacion de LD a CDS y de CDS a LD';

	/*Los siguientes datos también han de ser informados*/
proc freq data=work.VER_PRODU;
	TABLE LD_CDS;
	TABLE CDS_LD;
run;

Title 'Diferencias Archivo Producto';

proc freq data=work.VER_PRODU;
/*TABLE DIF_411;*/
/*TABLE DIF_900;*/
/*TABLE DIF_900_2TC;*/
/*TABLE DIF_5;*/
/*TABLE DIF_14_5;*/
/*TABLE DIF_67;*/
/*TABLE DIF_VEH;*/
/*TABLE DIF_411_EXC;*/
TABLE DIF_900_EXC;
/*TABLE DIF_900_2TC_EXC;*/
/*TABLE DIF_5_EXC;*/
/*TABLE DIF_14_5_EXC;*/
/*TABLE DIF_67_EXC;*/
/*TABLE DIF_VEH_EXC;*/
TABLE difperiodo;
/*table DIF_adn;*/
run;

proc sql;
	create table revisar_dif as (
		select *
			from	VER_PRODU
				where DIF_VEH not in (0,.));

	/*VALIDAR LINEA BIN CON TIPO DE LINEA*/
data Bin_Tip_Linea;
	set work.'ClientesFlujoPreaprobados'n;

	if Linea_Bin = 67 then
		Val_tipo_Pto = 2;
	else if Linea_Bin in (5,14,15,411) then
		Val_tipo_Pto = 3;

	if Linea_Bin in (5,14,15,411) and Plazo_CProd not in (.) then
		Val_tipo_Pto = 1;

	if Val_tipo_Pto not= Tipo_CProd then
		NO_COINCIDE_TIPO_PDTO = 1;
	else NO_COINCIDE_TIPO_PDTO = 0;
run;

proc freq data= Bin_Tip_Linea;
	table NO_COINCIDE_TIPO_PDTO;
run;