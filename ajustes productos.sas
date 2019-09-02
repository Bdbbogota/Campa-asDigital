DATA PROD;
	SET WORK.productospreaprobados;
	FORMAT LINEA_BIN_FIN $char7.;
	LINEA_BIN_FIN = INPUT(LINEA_BIN,$12.);
	TAM_LINEA = LENGTH(LINEA_BIN_FIN);
	PRIMER_NUMTC =  SUBSTR(LINEA_BIN_FIN,1,1);

	IF LINEA_BIN_FIN = '67' THEN
		APROB_67 = Valor_Aprobado;
	ELSE IF LINEA_BIN_FIN = '5' THEN
		APROB_5 = Valor_Aprobado;
	ELSE IF LINEA_BIN_FIN = '14' THEN
		APROB_14 = Valor_Aprobado;
	ELSE IF LINEA_BIN_FIN = '15' THEN
		APROB_15 = Valor_Aprobado;
	ELSE IF LINEA_BIN_FIN = '411' THEN
		APROB_411 = Valor_Aprobado;
	ELSE IF TAM_LINEA > 3 and PRIMER_NUMTC = '5' THEN
		/*Diferencia bin y posteriormente puede diferenciar si tiene una o dos TC*/
		APROB_900TC1 = Valor_Aprobado; 
	ELSE IF TAM_LINEA > 3 and PRIMER_NUMTC = '4' THEN
		/*Diferencia bin y posteriormente puede diferenciar si tiene una o dos TC*/
	APROB_900TC2 = Valor_Aprobado; 

	IF ECL_Tipo_Identificacion = 'C' THEN
		TID = 'CC';

	if ECL_TIPO_IDENTIFICACION = 'E' THEN
		TID = 'CE';
RUN;
