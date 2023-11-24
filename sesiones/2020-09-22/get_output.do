set more off
global path_reporte = "C:\Users\fgreve\Dropbox\mineduc\comision-regulacion\carpeta-compartida\sesiones\2020-09-22\data"

use "${path_reporte}/output.dta" , clear
set more off
gen codigo_unico_8 = substr(codigo_unico,1,8)
merge m:m codigo_unico_8 using "${path_reporte}/oferta-academica-2020.dta", nogenerate
drop if anio == .

gen Docentes = (sub_item_1_1_1 + sub_item_1_1_2 + sub_item_1_1_3)/totalmatriculados

gen Otros = (item_1_2 + item_2_1 + item_2_3)/totalmatriculados

gen Infraestructura = item_2_2/totalmatriculados + sub_item_c_3_1/matricula_ies

gen Equipamiento = (item_2_4 + item_2_5)/totalmatriculados

gen Indirectos = (item_3_1 + item_3_3 + item_3_6)/totalmatriculados

gen Tecnologia = item_3_2/totalmatriculados + sub_item_c_3_2/matricula_ies

gen Marketing = (item_3_4 + item_3_5)/totalmatriculados + sub_item_c_3_3/matricula_ies
 
gen Titulacion = (item_4_1 + item_4_2)/totalmatriculados

gen Matricula = (item_m_2 + item_m_3 + item_m_4)/matricula_ies

gen Centrales = (sub_item_c_2_1 + sub_item_c_2_2 + sub_item_c_3_4)/matricula_ies

gen costos_carrera = Docentes + Otros + Infraestructura + Equipamiento + Indirectos + Tecnologia + Marketing + Titulacion + Matricula + Centrales


gen IES = institucion
replace IES = "IP Inacap" if IES == "IP INACAP"
replace IES = "IP Duoc UC" if IES == "IP DUOC UC"
replace IES = "IP Arcos" if IES == "IP DE ARTE Y COMUNICACION ARCOS"
replace IES = "CFT Enac" if IES == "CFT DE ENAC"
replace IES = "U. Autónoma" if IES == "UNIVERSIDAD AUTONOMA DE CHILE"
replace IES = "CFT San Agustín" if IES == "CFT SAN AGUSTIN"
replace IES = "UDP" if IES == "UNIVERSIDAD DIEGO PORTALES"
replace IES = "U. Cardenal Raul Silva H." if IES == "UNIVERSIDAD CATOLICA CARDENAL RAUL SILVA HENRIQUEZ"
replace IES = "CFT Inacap" if IES == "CFT INACAP"
replace IES = "CFT Ceduc - UCN" if IES == "CFT CEDUC - UCN"
replace IES = "CFT PUCV" if IES == "CFT PUCV"
replace IES = "U. Alberto Hurtado" if IES == "UNIVERSIDAD ALBERTO HURTADO"
replace IES = "U. de Chile" if IES == "UNIVERSIDAD DE CHILE"
replace IES = "USACH" if IES == "UNIVERSIDAD DE SANTIAGO DE CHILE"
replace IES = "U. de Valparaiso" if IES == "UNIVERSIDAD DE VALPARAISO"
replace IES = "U. de Atofagasta" if IES == "UNIVERSIDAD DE ANTOFAGASTA"
replace IES = "U. de La Serena" if IES == "UNIVERSIDAD DE LA SERENA"
replace IES = "U. del Bio-Bio" if IES == "UNIVERSIDAD DEL BIO-BIO"
replace IES = "U. de la Frontera" if IES == "UNIVERSIDAD DE LA FRONTERA"
replace IES = "U. de Magallanes" if IES == "UNIVERSIDAD DE MAGALLANES"
replace IES = "U. de Talca" if IES == "UNIVERSIDAD DE TALCA"
replace IES = "U. de Atacama" if IES == "UNIVERSIDAD DE ATACAMA"
replace IES = "U. de Tarapaca" if IES == "UNIVERSIDAD DE TARAPACA"
replace IES = "U. Arturo Prat" if IES == "UNIVERSIDAD ARTURO PRAT"
replace IES = "UMCE" if IES == "UNIVERSIDAD METROPOLITANA DE CIENCIAS DE LA EDUCACION"
replace IES = "U. de Playa Ancha" if IES == "UNIVERSIDAD DE PLAYA ANCHA DE CIENCIAS DE LA EDUCACION"
replace IES = "U. de Los Lagos" if IES == "UNIVERSIDAD DE LOS LAGOS"
replace IES = "UTEM" if IES == "UNIVERSIDAD TECNOLOGICA METROPOLITANA"
replace IES = "PUC" if IES == "PONTIFICIA UNIVERSIDAD CATOLICA DE CHILE"
replace IES = "U. de Concepción" if IES == "UNIVERSIDAD DE CONCEPCION"
replace IES = "PUCV" if IES == "PONTIFICIA UNIVERSIDAD CATOLICA DE VALPARAISO"
replace IES = "U. Austral" if IES == "UNIVERSIDAD AUSTRAL DE CHILE"
replace IES = "CFT Maule" if IES == "CFT DE LA REGION DEL MAULE"
replace IES = "UC Norte" if IES == "UNIVERSIDAD CATOLICA DEL NORTE"
replace IES = "UC Maule" if IES == "UNIVERSIDAD CATOLICA DEL MAULE"
replace IES = "UC Santísima Concepción" if IES == "UNIVERSIDAD CATOLICA DE LA SANTISIMA CONCEPCION"
replace IES = "UC Temuco" if IES == "UNIVERSIDAD CATOLICA DE TEMUCO"

levelsof areacarreragenerica, local(AREA)
foreach x in `AREA' {
display "`x'"
}
*

local VARS Docentes Otros Infraestructura Equipamiento Indirectos Tecnologia Marketing Titulacion Matricula Centrales
foreach y of local VARS {
display "`y'"
}
*


set more off
*levelsof areacarreragenerica, local(AREA)
local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbar (mean) Docentes Otros Infraestructura Equipamiento Indirectos Tecnologia Marketing Titulacion Matricula Centrales [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("costos por alumno ($)") subtitle("(`x')") ///
over(IES, sort(costos_carrera) descending) stack ///
ysize(8) ///
legend(col(2) ///
lab(1 "Docentes") ///
lab(2 "Otros D.") ///
lab(3 "Infr.") ///
lab(4 "Equip.") ///
lab(5 "Indir.") ///
lab(6 "Tecn.") ///
lab(7 "Marketing") ///
lab(8 "Titulación") ///
lab(9 "Matrícula") ///
lab(10 "Centrales") ///
size(small)) 
graph export "${path_reporte}/images/`i'_plot1.png", as(png) replace
local i = `i' + 1
}
*

set more off
*levelsof areacarreragenerica, local(AREA)
local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbar (mean) Docentes Otros Infraestructura Equipamiento Indirectos Tecnologia Marketing Titulacion Matricula Centrales [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("costos por alumno (%)") subtitle("(`x')") ///
over(IES, sort(costos_carrera) descending) stack percent ///
ysize(8) ///
legend(col(2) ///
lab(1 "Docentes") ///
lab(2 "Otros D.") ///
lab(3 "Infr.") ///
lab(4 "Equip.") ///
lab(5 "Indir.") ///
lab(6 "Tecn.") ///
lab(7 "Marketing") ///
lab(8 "Titulación") ///
lab(9 "Matrícula") ///
lab(10 "Centrales") ///
size(small)) 
graph export "${path_reporte}/images/`i'_plot2.png", as(png) replace
local i = `i' + 1
}
*





set more off
*levelsof areacarreragenerica, local(AREA)
local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"

local VARS Docentes Otros Infraestructura Equipamiento Indirectos Tecnologia Marketing Titulacion Matricula Centrales
foreach y of local VARS {
display "`y'"

graph hbar (mean) `y' [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("C. `y' por alumno ($)") subtitle("(`x')") ///
over(IES, sort(`y') descending)  ///
ysize(8) ///
nolabel ///
b1title("Miles de pesos")
graph export "${path_reporte}/images/`i'_plot_`y'.png", as(png) replace
}
local i = `i' + 1
}
*




