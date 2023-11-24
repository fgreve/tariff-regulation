set more off

*--------------------------*
*--- INFORME DE CÁLCULO ---*
*--------------------------*
*Rutas
*global ruta_bases = "C:\Anibal G\Gratuidad\Avances\MEMORIA DE CÁLCULO\1. BB. DD"
*global ruta_insumos = "C:\Anibal G\Gratuidad\Avances\MEMORIA DE CÁLCULO\2. Insumos"
global ruta_bases = "C:\Users\fgreve\Dropbox\mineduc\0. Carpeta Comisión de Expertos\1. BB. DD"
global ruta_insumos = "C:\Users\fgreve\Dropbox\mineduc\0. Carpeta Comisión de Expertos\2. Insumos"

*Establecer ruta de bases
cd "$ruta_bases"


/*
*-----------------*
*--- Preámbulo ---*
*-----------------*
preserve 
*Importar Oferta Academica 2020
import excel "Oferta_2020_OFICIAL_DFE_AREAS_26_12_2019_E.xlsx", sheet("Hoja1") firstrow case(lower) clear

*Crear codigo auxiliar de codigo unico dado el levantamiento de informacion 2020 (I+S+C+J)
split codigo_unico, p("I", "S", "C", "J", "V") 
gen aux = "I" + codigo_unico2 + "S" + codigo_unico3 + "C" + codigo_unico4 + "J" + codigo_unico5
replace codigo_unico = aux 
drop codigo_unico1 codigo_unico2 codigo_unico3 codigo_unico4 codigo_unico5 codigo_unico6 aux

*Eliminar duplicados por no considerar la V
bys codigo_unico : gen id = _n  
keep if id == 1

*Guardado
save oferta_2020.dta, replace
restore 


preserve
*Importar Matricula Historica
import delimited "Matricula_2007_AL_2019_13_08_2019_WEB.csv", delimiter(";") clear 
keep if nivelglobal == "Pregrado"

*Crear auxiliar para codigo unico
ren códigocarrera aux
split aux, p("I", "S", "C", "J", "V") 
gen codigo_unico = "I" + aux2 + "S" + aux3 + "C" + aux4 + "J" + aux5
drop aux* 

*Crear auxiliar para año
split año, p("_")
destring año2, replace
ren año2 anio
drop año*

*Mantener años relevantes 2015-2019
keep if inrange(anio, 2015,2019) 

*Resumen y guardado para matricula por carrera
collapse (sum) totalmatriculados, by(codigo_unico anio) 
save matricula.dta, replace
restore


preserve
*Importar Matricula Historica
import delimited "Matricula_2007_AL_2019_13_08_2019_WEB.csv", delimiter(";") clear 
keep if nivelglobal == "Pregrado"

*Crear auxiliar para codigo ies
ren códigocarrera aux
split aux, p("I", "S", "C", "J", "V") 
ren aux2 codigo_ies
destring codigo_ies, replace force
drop aux* 

*Crear auxiliar para año
split año, p("_")
destring año2, replace
ren año2 anio
drop año*

*Mantener años relevantes 2015-2019
keep if inrange(anio, 2015,2019) 

*Resumen y guardado para matricula por ies
collapse (sum) totalmatriculados, by(codigo_ies anio) 
ren totalmatriculados matricula_ies
save matricula_total.dta, replace
restore


preserve
*Importar JCE
import excel "JCE_sies.xlsx", sheet("BD_Académicos_JCE") firstrow case(lower) clear

*Borrado de espacios en blanco y mantener variables importantes
keep if codigo_ies != .
keep codigo_ies institucion totalmujeres totalhombres totalgeneral doctor magíster especialidadmédicauodontológi tituloprofesional ///
licenciatura técniconivelsuperior técniconivelmedio sintítulonigrado

*Guardado
save JCE_sies.dta, replace
restore


*/
*--------------------------------------------*
*--- Base de datos del informe de cálculo ---*
*--------------------------------------------*
*Union bases de UES con IP-CFT
use "output_Ues_full.dta", clear
append using "output_CFT_IP_full.dta"

** Cruces de datos necesarios **
*Oferta Academica 2020
merge m:1 codigo_unico using oferta_2020.dta, keep(1 3) keepusing(tipoinst1 tipoinst2 tipoinst3 regionsede provincia comunasede areaconocimiento oecdarea oecdsubarea /// 
areacarreragenerica tipo_institucion tipo_carrera caracteristica_plan_especial duracion_total grado_academico nivel_carrera acreditada puntaje_corte elegibilidad_beca_pedagogia ///
 pedagogia_medicina_otro vacantes_semestre1 vacantes_semestre2 arancel_matricula valor_titulacion costo_certificado_diploma arancel_anual)

*Control por nivel de carrera
gen subsistema = .
replace subsistema = 1 if inlist(nivel_carrera, 1, 2)  
replace subsistema = 2 if inlist(nivel_carrera, 0, 3, 4) 
 
*Mantener carreras a regular
keep if inlist(oecdsubarea, "Servicios Personales", "Formación de Personal Docente", "Derecho")
drop _merge


*Matrícula por carrera - Necesaria para obtener el costo per cápita de las carreras
merge 1:1 codigo_unico anio using matricula.dta, keep(1 3) keepusing(totalmatriculados) 
gen aux_matricula = 0
replace aux_matricula = 1 if _merge == 3
drop _merge

*Auxiliares para datos vacios codigo unico
bys codigo_unico : egen max_matricula = max(aux_matricula) 
bys codigo_unico : egen mean_matricula = mean(totalmatriculados)
replace totalmatriculados = mean_matricula if totalmatriculados == . & mean_matricula != .

*Auxiliar para codigo ies y auxiliar para datos vacios IES y carrera
split codigo_unico, p("I", "S", "C", "J", "V")  
bys codigo_unico2 codigo_unico4 : egen mean_matricula2 = mean(totalmatriculados)   
ren codigo_unico2 codigo_ies 
ren codigo_unico3 codigo_sede
ren codigo_unico4 codigo_carrera
destring codigo_ies codigo_sede codigo_carrera, replace
replace totalmatriculados = mean_matricula2 if totalmatriculados == . 
drop codigo_unico1 codigo_unico5

*Auxiliar para datos vacios area carrera generica
bys areacarreragenerica : egen mean_matricula3 = mean(totalmatriculados) 
replace totalmatriculados = mean_matricula3 if totalmatriculados == .

*Matricula por IES 
merge m:1 codigo_ies anio using matricula_total.dta, keep(1 3) keepusing(matricula_ies) nogen

*keep if areacarreragenerica == "Derecho"

*-----------------------*
*--- Costo Razonable ---*
*-----------------------*
** Correcciones **
*CFT PUCV escribio en millones
foreach x of varlist sub_item_c_2_1 sub_item_c_3_1 sub_item_c_3_2 sub_item_c_3_3 sub_item_c_3_4 item_m_2 item_m_3 item_m_4 {
replace `x' = `x' * 1000 if codigo_ies == 629 
}
*
*PUCV, UANTO, UTALCA escribio en pesos
foreach x of varlist sub_item_c_2_1 sub_item_c_2_2 sub_item_c_3_1 sub_item_c_3_2 sub_item_c_3_3 sub_item_c_3_4 item_m_2 item_m_3 item_m_4 /// 
sub_item_1_1_1 sub_item_1_1_2 sub_item_1_1_3 item_1_2 item_2_1 item_2_2 item_2_3 item_2_4 item_2_5 /// 
item_3_1 item_3_2 item_3_3 item_3_4 item_3_5 item_3_6 item_4_1 item_4_2 {
replace `x' = `x' / 1000 if inlist(codigo_ies,73,78,89)
}
*
*UOHiggins escribio en pesos
foreach x of varlist sub_item_c_2_1 sub_item_c_2_2 sub_item_c_3_1 sub_item_c_3_2 sub_item_c_3_3 sub_item_c_3_4{
replace `x' = `x' / 1000 if codigo_ies == 895
}
*
*Valores negativos a positivo
foreach x of varlist sub_item_c_2_1 sub_item_c_2_2 sub_item_c_3_1 sub_item_c_3_2 sub_item_c_3_3 sub_item_c_3_4 item_m_2 item_m_3 item_m_4 /// 
sub_item_1_1_1 sub_item_1_1_2 sub_item_1_1_3 item_1_2 item_2_1 item_2_2 item_2_3 item_2_4 item_2_5 /// 
item_3_1 item_3_2 item_3_3 item_3_4 item_3_5 item_3_6 item_4_1 item_4_2 {
replace `x' = -`x' if `x' < 0
}
*

*Porcentaje de actividades de pregrado y postgrado
replace sub_item_c_1_2 = 1 if sub_item_c_1_1 == 0 & sub_item_c_1_2 == 0 // codigo_ies == 73
// Faltaria corregir por todos los que tengan 0 en ambas partes (sub_item_c_1_1 y sub_item_c_1_2)

*Arreglos
replace sub_item_c_1_1 = 1 if sub_item_c_1_1 > 1 & sub_item_c_1_1 != . 
replace sub_item_c_1_2 = 1 if sub_item_c_1_2 == . 
replace sub_item_c_2_2 = 0 if sub_item_c_2_2 == . 

*Costo central per cápita
gen aux_cc = sub_item_c_2_1 + sub_item_c_3_1 + sub_item_c_3_2 + sub_item_c_3_3 +  (sub_item_c_2_2 * sub_item_c_1_2) + (sub_item_c_3_4 * sub_item_c_1_2)

* christian bate
*gen aux_cc = sub_item_c_2_1 + sub_item_c_3_1 + sub_item_c_3_2 + sub_item_c_3_3 +  sub_item_c_2_2  + sub_item_c_3_4 
*gen aux_cc = sub_item_c_2_1 + sub_item_c_3_1 + sub_item_c_3_2 + sub_item_c_3_3 

gen cc_pc = aux_cc / matricula_ies
keep if cc_pc != . & cc_pc != 0 /// Eliminar observaciones sin costo central, esto ocurre por IES que comenzaron su funcionamiento en los últimos años




*Costo de la carrera per cápita 
egen aux_ccarr = rsum(sub_item_1_1_1 sub_item_1_1_2 sub_item_1_1_3 item_1_2 item_2_1 item_2_2 item_2_3 item_2_4 item_2_5 item_3_1 item_3_2 item_3_3 item_3_4 item_3_5 item_3_6)
gen ccarr_pc = aux_ccarr / totalmatriculados

*Costo total de la carrera per capita
gen costo_pc = ccarr_pc + cc_pc

*Costo Matricula per capita
egen aux_cmat = rsum(item_m_2 item_m_3 item_m_4)
gen costo_mat = aux_cmat / matricula_ies

*Costo de Titulacion y Graduciacion per capita
egen aux_cctg = rsum(item_4_1 item_4_2)
gen costo_ctg = aux_cctg / totalmatriculados

*Actualizar por IPC
foreach x of varlist costo_pc costo_mat costo_ctg{
replace `x' = `x' * 1.157 if anio == 2015
replace `x' = `x' * 1.104 if anio == 2016
replace `x' = `x' * 1.075 if anio == 2017
replace `x' = `x' * 1.052 if anio == 2018
replace `x' = `x' * 1.029 if anio == 2019
}
*
*Filtro para no haber problemas
drop if ccarr_pc == 0
*keep if ccarr_pc == 0


*Generar percentiles
*Eliminar P5 inferior y 95 superior
*bys areacarreragenerica : summ costo_pc, d
sum costo_pc , d
keep if inrange(costo_pc, r(p5), r(p95))
*drop if inrange(costo_pc, r(p5), r(p95))

replace areacarreragenerica = "Grupo Especial 2" if inlist(areacarreragenerica, "Pedagogía en Artes y Música", "Pedagogía en Educación Tecnológica") 
replace areacarreragenerica = "Grupo Especial 1" if inlist(areacarreragenerica,"Pedagogía en Educación Básica", "Pedagogía en Educación Media")
replace areacarreragenerica = "Grupo Especial 3" if areacarreragenerica == "Administración Turística y Hotelera" & subsistema == 2


