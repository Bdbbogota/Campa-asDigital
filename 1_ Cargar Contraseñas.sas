/*Ruta con claves y accesos a BD;*/

/*%let Ruta_Key = %STR(/sasdata/P_RIESGO/MIS/DSILVA5/CAMPA�AS/KEY);*/
/*%let Ruta_Key = %STR(/sasdata/P_RIESGO/MIS/OGONZA9/CAMPA�AS/KEY);*/
%let Ruta_Key = %STR(/sasdata/P_RIESGO/MIS/DSILVA5/CAMPA�AS/KEY);

%include "&Ruta_Key./AccessBD.sas"; *Macro para asignacion de usuario y constrase�a para acceso a BD;
%put &access_PDSR.;
%put &access_PDODS.;
%put &access_crto.; 



proc sql;
	connect to oracle (path = PDSR &access_PDSR.);

proc sql;
	connect to oracle (path = PDODS_CCP &access_PDODS.);

proc sql;
	connect to oracle (path = crto &access_crto.);




