/*Añada el requisito de información Material. Un material es un activo disponible en un aula para la realización de actividades docentes. Sus atributos son: el aula en el que se encuentra el material, el nombre del material, la cantidad disponible, la fecha de adquisición (puede ser futura) y el valor total. Hay que tener en cuenta las siguientes restricciones:
-	El valor total ser inferior a 20.000€.
-	La cantidad debe ser de entre 1 y 50.
-	Un aula no puede tener varios materiales con el mismo nombre.
-	Todos los atributos son obligatorios salvo la fecha de adquisición y el valor total.*/

CREATE TABLE material(
	id INT PRIMARY KEY NOT NULL ,
	aula INT NOT NULL ,
	nombre VARCHAR (255) NOT NULL ,
	cantidadDisponible INT NOT NULL CHECK(cantidadDisponible<=1 AND cantidadDisponible >= 50) ,
	fechaAdquisicion DATE,
	valorTotal INT CHECK(valorTotal<20000),
	UNIQUE (aula, nombre)
	);

/*Cree un procedimiento almacenado llamado pInsertMaterials() que cree los siguientes contratos:
-	Material llamado “material 1” en el aula con ID=1, con cantidad de 3 y valor total de 3000€.
-	Material llamado “material 2” en el aula con ID=1, con cantidad de 1, valor total de 1000€, con fecha de adquisición 2020-05-05.
-	Material llamado “material 3· en el aula con ID=2, con cantidad de 2, valor total de 5000€, con fecha de adquisición 2020-12-12.*/

DELIMITER //
 CREATE OR REPLACE PROCEDURE pInsertarMaterial(aula VARCHAR(255), nombre VARCHAR(255), cantidadDisponible INT , fechaAdquisicion DATE , valorTotal INT )
 BEGIN
  INSERT INTO Material (aula, nombre, cantidadDisponible, fechaAdquisicion, valorTotal) 
  VALUES (aula, nombre, cantidadDisponible, fechaAdquisicion, valorTotal);
 END//
 DELIMITER ;
 -- Llamada a procedimiento
 CALL pInsertarMaterial(1, 'material 1',3,NULL, 3000);
 CALL pInsertarMaterial(1, 'material 2',1,'2020-05-05', 1000);
 CALL pInsertarMaterial(2, 'material 3',2,'2020-12-12', 5000);

/* Cree un procedimiento almacenado llamado pUpdateMaterials(c, a) que actualiza la cantidad de los materiales del aula con ID=c con el valor a. Ejecute la llamada a pUpdateMaterials(1,2).
Cree un procedimiento almacenado llamado pDeleteMaterials(c) que elimina los materiales del aula con ID=c. Ejecute la llamada pDeleteMaterials(2)*/


DELIMITER //
 CREATE OR REPLACE PROCEDURE pUpdateMaterials(c INT , a INT ) 
 BEGIN
 	UPDATE material
 	SET cantidadDisponible = a
 	WHERE material.aula = c;
 END//
 DELIMITER ;
 
CALL pUpdateMaterials(1,2);


DELIMITER //
 CREATE OR REPLACE PROCEDURE pDeleteMaterials(c INT )
 BEGIN 
 
 DELETE FROM material
 WHERE material.aula= c;
 END//
 DELIMITER ;
 
 CALL pDeleteMaterials(2);

/* Cree una consulta que devuelva por cada profesor: el id del profesor, su nombre y apellidos, y el nombre de su despacho, ordenados por el nombre del despacho. Un ejemplo de resultado de esta consulta es el siguiente:*/

SELECT professors.professorId,professors.firstName,professors.surname, offices.`name` FROM professors
JOIN offices ON professors.officeId = offices.officeId
ORDER BY offices.`name`;

/*Cree una consulta que devuelva los créditos por asignatura medios impartidos por profesores que pertenecen al departamento cuyo ID=1. Un ejemplo del resultado de esta consulta es el siguiente:*/

SELECT AVG(subjects.credits) FROM subjects
JOIN departments ON subjects.departmentId = departments.departmentId
JOIN professors ON departments.departmentId = professors.departmentId
WHERE departments.departmentId = 1;


Cree una consulta que devuelva el número de profesores de cada despacho. Un ejemplo de resultado de esta consulta es el siguiente:
 

SELECT COUNT(*) FROM professors 
JOIN offices ON professors.officeId = offices.officeId
GROUP BY offices.officeId; 


Cree una consulta que devuelva el nombre y los apellidos de cada alumno, junto con el número de grupos a los que pertenece, ordenados (los alumnos) por el número de grupos de mayor a menor. Un ejemplo de resultado de esta consulta es el siguiente:
 

SELECT students.firstName, students.surname, COUNT(groupsstudents.groupStudentId) AS numeroGrupos FROM groupsstudents
JOIN students ON groupsstudents.studentId = students.studentId
GROUP BY students.firstName, students.surname
ORDER BY numeroGrupos DESC;

hola


