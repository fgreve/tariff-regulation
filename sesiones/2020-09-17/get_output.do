set more off
global path_reporte = "C:\Users\fgreve\Dropbox\mineduc\comision-regulacion\carpeta-compartida\sesiones\2020-09-22\data"

use "${path_reporte}/output.dta" , clear
set more off
gen codigo_unico_8 = substr(codigo_unico,1,8)
merge m:m codigo_unico_8 using "${path_reporte}/oferta-academica-2020.dta", nogenerate
drop if anio == .

gen costo_1 = sub_item_1_1_1 + sub_item_1_1_2 + sub_item_1_1_3 + item_1_2

gen costo_2 = item_2_1 + item_2_2 + item_2_3 + item_2_4 + item_2_5

gen costo_3 = item_3_1 + item_3_2 + item_3_3 + item_3_4 + item_3_5 + item_3_6
gen costo_4 = item_4_1 + item_4_2

gen costo_1_pc = costo_1 / totalmatriculados

gen costo_2_pc = costo_2 / totalmatriculados
gen item_2_1_pc = item_2_1 / totalmatriculados
gen item_2_2_pc = item_2_2 / totalmatriculados
gen item_2_3_pc = item_2_3 / totalmatriculados
gen item_2_4_pc = item_2_4 / totalmatriculados
gen item_2_5_pc = item_2_5 / totalmatriculados

gen costo_3_pc = costo_3 / totalmatriculados
gen costo_4_pc = costo_4 / totalmatriculados

gen costos_carrera_pc = costo_1_pc + costo_2_pc + costo_3_pc + costo_4_pc

gen costo_1_100 = costo_1 / totalmatriculados *100

gen costo_2_100 = costo_2 / totalmatriculados *100
gen item_2_1_100 = item_2_1 / totalmatriculados *100
gen item_2_2_100 = item_2_2 / totalmatriculados *100
gen item_2_3_100 = item_2_3 / totalmatriculados *100
gen item_2_4_100 = item_2_4 / totalmatriculados *100
gen item_2_5_100 = item_2_5 / totalmatriculados *100

gen costo_3_100 = costo_3 / totalmatriculados *100
gen costo_4_100 = costo_4 / totalmatriculados *100


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

set more off
*levelsof areacarreragenerica, local(AREA)
local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbar (mean) costo_1_pc costo_2_pc costo_3_pc costo_4_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("costos por alumno (%)") subtitle("(`x')") ///
over(IES, sort(costos_carrera_pc) descending) stack ///
ysize(7) ///
legend(col(1) ///
lab(1 "Seccion 1") ///
lab(2 "Seccion 2") ///
lab(3 "Seccion 3") ///
lab(4 "Seccion 4")) 
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
graph hbar (mean) costo_1_pc costo_2_pc costo_3_pc costo_4_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("costos por alumno (%)") subtitle("(`x')") ///
over(IES, sort(costos_carrera_pc) descending) stack percent ///
ysize(7) ///
legend(col(1) ///
lab(1 "Seccion 1") ///
lab(2 "Seccion 2") ///
lab(3 "Seccion 3") ///
lab(4 "Seccion 4")) 
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
graph hbar (mean) item_2_1_pc item_2_2_pc item_2_3_pc item_2_4_pc item_2_5_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("Seccion 2 ($)") subtitle("(`x')") ///
over(IES, sort(costo_2_pc) descending) stack ///
ysize(7) ///
legend(col(1) ///
lab(1 "item_2_1") ///
lab(2 "item_2_2") ///
lab(3 "item_2_3") ///
lab(4 "item_2_4") ///
lab(5 "item_2_5")) 
graph export "${path_reporte}/images/`i'_plot3.png", as(png) replace
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
graph hbar (mean) item_2_1_pc item_2_2_pc item_2_3_pc item_2_4_pc item_2_5_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("Seccion 2 (%)") subtitle("(`x')") ///
over(IES, sort(costo_2_pc) descending) stack percent ///
ysize(7) ///
legend(col(1) ///
lab(1 "item_2_1") ///
lab(2 "item_2_2") ///
lab(3 "item_2_3") ///
lab(4 "item_2_4") ///
lab(5 "item_2_5")) 
graph export "${path_reporte}/images/`i'_plot4.png", as(png) replace
local i = `i' + 1
}
*

**** COSTOS CENTRALES
set more off
*levelsof areacarreragenerica, local(AREA)
local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbar (mean) cc_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("Costos Centrales ($)") subtitle("(`x')") ///
over(IES, sort(cc_pc) descending) stack ///
ysize(7) ///
legend(col(1)) 
graph export "${path_reporte}/images/`i'_plot3.png", as(png) replace
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
graph hbar (mean) cc_pc costos_carrera_pc [pweight=totalmatriculados] if areacarreragenerica == "`x'", ///
title("Costos ($)") subtitle("(`x')") ///
over(IES, sort(cc_pc) descending) stack ///
ysize(7) ///
legend(col(1) ///
lab(1 "Costos centrales") ///
lab(2 "costos carrera")) 
graph export "${path_reporte}/images/`i'_plot3.png", as(png) replace
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
graph hbox costo_1_pc if areacarreragenerica == "`x'", /// 
over(IES, sort(costos_carrera_pc) descending) /// 
title("Costo docencia ($)") subtitle("(`x')") ///
ysize(7)
graph export "${path_reporte}/images/`i'_plot3.png", as(png) replace
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
graph hbox costo_2_pc if areacarreragenerica == "`x'", /// 
over(IES, sort(costos_carrera_pc) descending) /// 
title("Infraestructura ($)") subtitle("(`x')") ///
ysize(7)
graph export "${path_reporte}/images/`i'_plot4.png", as(png) replace
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
graph hbox costo_3_pc if areacarreragenerica == "`x'", /// 
over(IES, sort(costos_carrera_pc) descending) ///  
title("No academico ($)") subtitle("(`x')") ///
ysize(7)
graph export "${path_reporte}/images/`i'_plot5.png", as(png) replace
local i = `i' + 1
}
*






