/*Si hay diferencias en aprobaciones (Si no tienen y nososotros si)*/
/****Estas diferencias pueden ser pasadas por alto, dado que *******/
/*****filtraron la aprobación del producto por filtros posteriores**/ 

/*Si hay diferencias en aprobaciones (Entre lo que ellos registran y lo aprobado por Riesgo)
Estas diferencias han de ser informadas dado que significa que lo cargado por ellos
/*********************no corresponde al monto aprobado por Riesgo****************************/

/*1.Ver diferencias especificas de LD y CDS*/

data DIFERENCIAS_411_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_411 Aprobado_411 APROB_411_PM) 
	DIFERENCIAS_900_F  		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_900 Aprobado_900 Aprobado_900_2TC APROB_900T1_PM APROB_900T2_PM)
	DIFERENCIAS_900_2TC_F 	(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_900_2TC Aprobado_900 Aprobado_900_2TC APROB_900T1_PM APROB_900T2_PM)
	DIFERENCIAS_5_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_5  DIF_14_5 Aprobado_14_5 APROB_14_PM Aprobado_5 APROB_5_PM) 
	DIFERENCIAS_14_5_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_5  DIF_14_5 Aprobado_14_5 APROB_14_PM Aprobado_5 APROB_5_PM)
	DIFERENCIAS_67_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_67 Aprobado_67 APROB_67_PM)
	DIFERENCIAS_VEH_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_VEH Aprobado_VEH APROB_15_PM)
	DIFERENCIAS_ADN_F 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_adn linea_110 Aprobado_inteligencia) 
	;		
	SET VER_PRODU;
	
	IF DIF_411 > 0 and (DIF_411 ~= Aprobado_411) THEN
		OUTPUT DIFERENCIAS_411_F;

	IF DIF_900  > 0 and (DIF_900 ~= Aprobado_900) THEN
		OUTPUT DIFERENCIAS_900_F;
	
	IF DIF_900_2TC  > 0 and (DIF_900_2TC ~= Aprobado_900_2TC) THEN
		OUTPUT DIFERENCIAS_900_2TC_F;

	IF DIF_5  > 0 and (DIF_5 ~= Aprobado_5)  THEN
		OUTPUT DIFERENCIAS_5_F;

	IF DIF_14_5  > 0 and (DIF_14_5 ~= Aprobado_14_5) THEN
		OUTPUT DIFERENCIAS_14_5_F;

	IF DIF_67  > 0   and (DIF_67 ~= Aprobado_67)  THEN
		OUTPUT DIFERENCIAS_67_F;

	IF DIF_VEH  > 0  and (DIF_VEH ~= Aprobado_VEH)  THEN
	OUTPUT DIFERENCIAS_VEH_F;

	IF DIF_adn < 0  and (linea_110 ~= Aprobado_inteligencia) THEN
	OUTPUT DIFERENCIAS_ADN_F;

RUN;

/*2.Ver diferencias en producto y la no asignación para informarlos*/
data DIFERENCIAS_411_ 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_411 Aprobado_411 APROB_411_PM) 
	DIFERENCIAS_900_  		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_900 Aprobado_900 Aprobado_900_2TC APROB_900T1_PM APROB_900T2_PM)
	DIFERENCIAS_900_2TC_ 	(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_900_2TC Aprobado_900 Aprobado_900_2TC APROB_900T1_PM APROB_900T2_PM)
	DIFERENCIAS_5_ 			(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_5  DIF_14_5 Aprobado_14_5 APROB_14_PM Aprobado_5 APROB_5_PM) 
	DIFERENCIAS_14_5_ 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_5  DIF_14_5 Aprobado_14_5 APROB_14_PM Aprobado_5 APROB_5_PM)
	DIFERENCIAS_67_ 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_67 Aprobado_67 APROB_67_PM)
	DIFERENCIAS_VEH_ 		(keep= ECL_Tipo_Identificacion Numero_Identificacion DIF_VEH Aprobado_VEH APROB_15_PM)
	DIFERENCIAS_TODAS_;		
	SET VER_PRODU;

	IF DIF_411 > 0  THEN
		OUTPUT DIFERENCIAS_411_;

	IF DIF_900  > 0 THEN
		OUTPUT DIFERENCIAS_900_;
	
	IF DIF_900_2TC  > 0  THEN
		OUTPUT DIFERENCIAS_900_2TC_;

	IF DIF_5  > 0 THEN
		OUTPUT DIFERENCIAS_5_;

	IF DIF_14_5  > 0  THEN
		OUTPUT DIFERENCIAS_14_5_;

	IF DIF_67  > 0  THEN
		OUTPUT DIFERENCIAS_67_;

	IF DIF_VEH  > 0  THEN
	OUTPUT DIFERENCIAS_VEH_;

	if DIF_411 > 0 OR DIF_900  > 0 OR DIF_900_2TC  > 0 OR DIF_5  > 0 OR DIF_14_5  > 0 OR DIF_67  > 0 OR  DIF_VEH  > 0 THEN 
	OUTPUT DIFERENCIAS_TODAS_;
RUN;
