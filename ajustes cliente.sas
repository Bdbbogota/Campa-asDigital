PROC SQL;
	SELECT DISTINCT ECL_TIPO_IDENTIFICACION FROM work.ClientesFlujoPreaprobados;

data cliente;
	set work.ClientesFlujoPreaprobados;;

	if ECL_TIPO_IDENTIFICACION = 'C' THEN
		TIPO_ID = 'CC';

	if ECL_TIPO_IDENTIFICACION = 'E' THEN
		TIPO_ID = 'CE';
run;
