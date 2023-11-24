set more off
global path_reporte = "C:\Users\fgreve\Dropbox\mineduc\comision-regulacion\reporte-costos\data"


import excel "${path_reporte}/Buscador-de-instituciones_mifuturo_2020.xlsx", ///
sheet("Buscador Instituciones 2020") cellrange(A2:CR145) firstrow clear
rename ID codigo_ies
rename mconstruidosporestudiantej m2_por_alumno
*keep codigo_ies m2_por_alumno
save "${path_reporte}/Buscador-de-instituciones_mifuturo_2020.dta" , replace

import delimited "${path_reporte}/baseindices_2005-2020.csv",  encoding("utf-8") clear 
*keep if año == "2020"
rename códgosies codigo_unico
save "${path_reporte}/baseindices_2005-2020.dta" , replace

import delimited "${path_reporte}/Docentes.csv", encoding("utf-8") clear 
save "${path_reporte}/Docentes.dta", replace


import delimited "${path_reporte}/oferta-academica-2020.csv", encoding("utf-8") clear 
gen codigo_unico_8 = substr(códigoúnico,1,8)
*gen codigo_unico_2 = ltrim(codigo_unico)
keep codigo_unico_8 añosacredinst jcetotal empleabilidad1año
save "${path_reporte}/oferta-academica-2020.dta", replace

*******************************************************************************
use "${path_reporte}/output.dta" , clear
gen codigo_unico_8 = substr(codigo_unico,1,8)
merge m:m codigo_unico_8 using "${path_reporte}/oferta-academica-2020.dta", nogenerate
drop if anio == .

gen costo_docente = sub_item_1_1_1 + sub_item_1_1_2 + sub_item_1_1_3
gen costo_docente_pc = costo_docente / totalmatriculados

* defino el costo administracion como el costo no docente
gen costo_adm_pc = costo_pc - costo_docente_pc
gen costo_adm_pc_porcentage = costo_adm_pc / costo_pc *100

gen costo_docente_pc_porcentage = costo_docente_pc / costo_pc *100

*añosacredinst: años de acreditacion
*empleabilidad1año: empleabilidad

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


* COSTO TOTAL
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
histogram costo_pc if areacarreragenerica == "`x'", freq normal ///
title("Costo total carrera por estudiante ($)") subtitle("(`x')") ///
note("Nota: El costo total carrera por estudiante corresponde a los costos docentes," ///
"         directos, centrales y matrícula.") ///
xtitle("Miles de pesos")  xlabel(0(1000)8000, grid labsize(small)) ///
ytitle("Frecuencia") ylabel(, grid labsize(small))
graph export "${path_reporte}/images/`i'_plot1.png", as(png) replace
local i = `i' + 1
}
*

* COSTO DOCENTE %
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
histogram costo_docente_pc if areacarreragenerica == "`x'", freq normal ///
title("Costo docente por estudiante ($)") subtitle("(`x')") ///
note("Nota: El costo docente por estudiante es la suma de JCE con contrato indefinido," ///
"         contrato a plazo fijo y contrato a honorarios.") ///
xtitle("costo docente / costo total carrera")  xlabel(, grid labsize(small)) ///
ytitle("Frecuencia") ylabel(, grid)
graph export "${path_reporte}/images/`i'_plot2.png", as(png) replace
local i = `i' + 1
}
*

* COSTO DOCENTE %
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
histogram costo_docente_pc_porcentage if areacarreragenerica == "`x'", freq normal ///
title("Costo docente por estudiante (%)") subtitle("(`x')") ///
note("Nota: El costo docente por estudiante es la suma de JCE con contrato indefinido," ///
"         contrato a plazo fijo y contrato a honorarios.") ///
xtitle("costo docente / costo total carrera (%)")  xlabel(0(10)100, grid labsize(small)) ///
ytitle("Frecuencia") ylabel(, grid)
graph export "${path_reporte}/images/`i'_plot3.png", as(png) replace
local i = `i' + 1
}
*

* COSTO administrativo %
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
histogram costo_adm_pc_porcentage if areacarreragenerica == "`x'", freq normal ///
title("Costo Administrativo por estudiante (%)") subtitle("(`x')") ///
note("Nota: El costo administrativo incluye todo lo que no es costo docente.") ///
xtitle("costo docente / costo total carrera (%)")  xlabel(0(10)100, grid labsize(small)) ///
ytitle("Frecuencia") ylabel(, grid)
graph export "${path_reporte}/images/`i'_plot4.png", as(png) replace
local i = `i' + 1
}
*

* COSTO administrativo %
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbox costo_pc if areacarreragenerica == "`x'", /// 
over(IES, sort(1)) /// 
title("Costo total carrera ($)") subtitle("(`x')") ///
ytitle("Costo carrera") ///
ysize(7)
graph export "${path_reporte}/images/`i'_plot5.png", as(png) replace
local i = `i' + 1
}
*

* COSTO administrativo %
levelsof areacarreragenerica, local(AREA)
*local AREA "Derecho"
local i = 1
foreach x in `AREA' {
display "`x'"
display "`i'"
graph hbox costo_docente_pc if areacarreragenerica == "Grupo Especial 1", ///  
over(IES, sort(1)) ///
title("Costo docente ($)") subtitle("(`x')") ///
ytitle("Costo docente ($)") ///
ysize(7)
graph export "${path_reporte}/images/`i'_plot6.png", as(png) replace
local i = `i' + 1
}
*














graph hbox costo_pc if areacarreragenerica == "Grupo Especial 1", over(IES, sort(1)) title("Grupo Especial 1") ytitle("Costo carrera")
graph export "${path_reporte}/Grupo Especial 1.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Grupo Especial 2", over(IES, sort(1)) title("Grupo Especial 2") ytitle("Costo carrera")
graph export "${path_reporte}/Grupo Especial 2.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Grupo Especial 3", over(IES, sort(1)) title("Grupo Especial 3") ytitle("Costo carrera")
graph export "${path_reporte}/Grupo Especial 3.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Administración Gastronómica", over(IES, sort(1)) title("Administración Gastronómica") ytitle("Costo carrera")
graph export "${path_reporte}/Administración Gastronómica.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Administración Turística y Hotelera", over(IES, sort(1)) title("Administración Turística y Hotelera") ytitle("Costo carrera")
graph export "${path_reporte}/Administración Turística y Hotelera.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Derecho", over(IES, sort(1)) title("Derecho") ytitle("Costo carrera")
graph export "${path_reporte}/Derecho.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Otros Profesionales de Educación", over(IES, sort(1)) title("Otros Profesionales de Educación") ytitle("Costo carrera")
graph export "${path_reporte}/Otros Profesionales de Educación.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Otros Técnicos de Educación", over(IES, sort(1)) title("Otros Técnicos de Educación") ytitle("Costo carrera")
graph export "${path_reporte}/Otros Técnicos de Educación.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Ciencias", over(IES, sort(1)) title("Pedagogía en Ciencias") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Ciencias.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Educación Diferencial", over(IES, sort(1)) title("Pedagogía en Educación Diferencial") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Educación Diferencial.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Educación Física", over(IES, sort(1)) title("Pedagogía en Educación Física") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Educación Física.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Educación Técnico Profesional", over(IES, sort(1)) title("Pedagogía en Educación Técnico Profesional") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Educación Técnico Profesional.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Educación de Párvulos", over(IES, sort(1)) title("Pedagogía en Educación de Párvulos") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Educación de Párvulos.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Filosofía y Religión", over(IES, sort(1)) title("Pedagogía en Filosofía y Religión") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Filosofía y Religión.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Historia, Geografía y Ciencias Sociales", over(IES, sort(1)) title("Pedagogía en Historia. Geografía y Ciencias Sociales") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Historia, Geografía y Ciencias Sociales.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Idiomas", over(IES, sort(1)) title("Pedagogía en Idiomas") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Idiomas.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Lenguaje, Comunicación y/o Castellano", over(IES, sort(1)) title("Pedagogía en Lenguaje. Comunicación y/o Castellano") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Lenguaje, Comunicación yo Castellano.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Pedagogía en Matemáticas y Computación", over(IES, sort(1)) title("Pedagogía en Matemáticas y Computación") ytitle("Costo carrera")
graph export "${path_reporte}/Pedagogía en Matemáticas y Computación.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Programas de Formación Pedagógica", over(IES, sort(1)) title("Programas de Formación Pedagógica") ytitle("Costo carrera")
graph export "${path_reporte}/Programas de Formación Pedagógica.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico Asistente del Educador Diferencial", over(IES, sort(1)) title("Técnico Asistente del Educador Diferencial") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico Asistente del Educador Diferencial.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico Asistente del Educador de Párvulos", over(IES, sort(1)) title("Técnico Asistente del Educador de Párvulos") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico Asistente del Educador de Párvulos.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico Jurídico", over(IES, sort(1)) title("Técnico Jurídico") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico Jurídico.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico en Deporte, Recreación y Preparación Física", over(IES, sort(1)) title("Técnico en Deporte. Recreación y Preparación Física") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico en Deporte, Recreación y Preparación Física.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico en Gastronomía y Cocina", over(IES, sort(1)) title("Técnico en Gastronomía y Cocina") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico en Gastronomía y Cocina.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico en Peluquería y Estética", over(IES, sort(1)) title("Técnico en Peluquería y Estética") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico en Peluquería y Estética.png", as(png) replace

graph hbox costo_pc if areacarreragenerica == "Técnico en Turismo y Hotelería", over(IES, sort(1)) title("Técnico en Turismo y Hotelería") ytitle("Costo carrera")
graph export "${path_reporte}/Técnico en Turismo y Hotelería.png", as(png) replace


* costo_docente_pc
graph hbox costo_docente_pc if areacarreragenerica == "Grupo Especial 1", over(IES, sort(1)) title("Grupo Especial 1") ytitle("Costo docente")
graph export "${path_reporte}/Grupo Especial 1 costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Grupo Especial 2", over(IES, sort(1)) title("Grupo Especial 2") ytitle("Costo docente")
graph export "${path_reporte}/Grupo Especial 2 costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Grupo Especial 3", over(IES, sort(1)) title("Grupo Especial 3") ytitle("Costo docente")
graph export "${path_reporte}/Grupo Especial 3 costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Administración Gastronómica", over(IES, sort(1)) title("Administración Gastronómica") ytitle("Costo docente")
graph export "${path_reporte}/Administración Gastronómica costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Administración Turística y Hotelera", over(IES, sort(1)) title("Administración Turística y Hotelera") ytitle("Costo docente")
graph export "${path_reporte}/Administración Turística y Hotelera costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Derecho", over(IES, sort(1)) title("Derecho") ytitle("Costo docente")
graph export "${path_reporte}/Derecho costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Otros Profesionales de Educación", over(IES, sort(1)) title("Otros Profesionales de Educación") ytitle("Costo docente")
graph export "${path_reporte}/Otros Profesionales de Educación costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Otros Técnicos de Educación", over(IES, sort(1)) title("Otros Técnicos de Educación") ytitle("Costo docente")
graph export "${path_reporte}/Otros Técnicos de Educación costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Ciencias", over(IES, sort(1)) title("Pedagogía en Ciencias") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Ciencias costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Educación Diferencial", over(IES, sort(1)) title("Pedagogía en Educación Diferencial") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Educación Diferencial costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Educación Física", over(IES, sort(1)) title("Pedagogía en Educación Física") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Educación Física costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Educación Técnico Profesional", over(IES, sort(1)) title("Pedagogía en Educación Técnico Profesional") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Educación Técnico Profesional costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Educación de Párvulos", over(IES, sort(1)) title("Pedagogía en Educación de Párvulos") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Educación de Párvulos costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Filosofía y Religión", over(IES, sort(1)) title("Pedagogía en Filosofía y Religión") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Filosofía y Religión costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Historia, Geografía y Ciencias Sociales", over(IES, sort(1)) title("Pedagogía en Historia. Geografía y Ciencias Sociales") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Historia, Geografía y Ciencias Sociales costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Idiomas", over(IES, sort(1)) title("Pedagogía en Idiomas") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Idiomas costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Lenguaje, Comunicación y/o Castellano", over(IES, sort(1)) title("Pedagogía en Lenguaje. Comunicación y/o Castellano") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Lenguaje, Comunicación yo Castellano costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Pedagogía en Matemáticas y Computación", over(IES, sort(1)) title("Pedagogía en Matemáticas y Computación") ytitle("Costo docente")
graph export "${path_reporte}/Pedagogía en Matemáticas y Computación costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Programas de Formación Pedagógica", over(IES, sort(1)) title("Programas de Formación Pedagógica") ytitle("Costo docente")
graph export "${path_reporte}/Programas de Formación Pedagógica costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico Asistente del Educador Diferencial", over(IES, sort(1)) title("Técnico Asistente del Educador Diferencial") ytitle("Costo docente")
graph export "${path_reporte}/Técnico Asistente del Educador Diferencial costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico Asistente del Educador de Párvulos", over(IES, sort(1)) title("Técnico Asistente del Educador de Párvulos") ytitle("Costo docente")
graph export "${path_reporte}/Técnico Asistente del Educador de Párvulos costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico Jurídico", over(IES, sort(1)) title("Técnico Jurídico") ytitle("Costo docente")
graph export "${path_reporte}/Técnico Jurídico costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico en Deporte, Recreación y Preparación Física", over(IES, sort(1)) title("Técnico en Deporte. Recreación y Preparación Física") ytitle("Costo docente")
graph export "${path_reporte}/Técnico en Deporte, Recreación y Preparación Física costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico en Gastronomía y Cocina", over(IES, sort(1)) title("Técnico en Gastronomía y Cocina") ytitle("Costo docente")
graph export "${path_reporte}/Técnico en Gastronomía y Cocina costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico en Peluquería y Estética", over(IES, sort(1)) title("Técnico en Peluquería y Estética") ytitle("Costo docente")
graph export "${path_reporte}/Técnico en Peluquería y Estética costo_docente_pc.png", as(png) replace

graph hbox costo_docente_pc if areacarreragenerica == "Técnico en Turismo y Hotelería", over(IES, sort(1)) title("Técnico en Turismo y Hotelería") ytitle("Costo docente")
graph export "${path_reporte}/Técnico en Turismo y Hotelería costo_docente_pc.png", as(png) replace












use "${path_reporte}/min_ccarr_pc.dta" , clear
merge m:m codigo_unico_8 using "${path_reporte}/p25_ccarr_pc.dta", nogenerate
merge m:m codigo_unico_8 using "${path_reporte}/p50_ccarr_pc.dta", nogenerate
merge m:m codigo_unico_8 using "${path_reporte}/p75_ccarr_pc.dta", nogenerate
merge m:m codigo_unico_8 using "${path_reporte}/max_ccarr_pc.dta", nogenerate
merge m:m codigo_unico_8 using "${path_reporte}/sd_ccarr_pc.dta", nogenerate
merge m:m codigo_unico_8 using "${path_reporte}/count_ccarr_pc.dta", nogenerate


graph box bp_before bp_after, over(agegrp)


