/*
EJERCICIO 0

Para asegurar que todo es correcto ejecute la consulta SELECT count(*) FROM Students; y comprueba que el resultado que devuelve es 21.
*/

SELECT count(*) FROM Students; 

/*
EJERCICIO 1

Añada el requisito de información Alumno Interno. Un alumno interno es un estudiante que colabora con un Departamento en actividades docentes o de investigación. Sus atributos son: el departamento en el que el estudiante participa como alumno interno, el estudiante involucrado, el año académico en el que se hace la colaboración y el número de meses que dura la colaboración. Hay que tener en cuenta las siguientes restricciones:
-	Los estudiantes sólo pueden ser alumnos internos una vez en un único curso académico.
-	El número de meses de la colaboración debe ser como máximo de 9 meses y como mínimo de 3.
-	Todos los atributos son obligatorios, menos el número de meses de la colaboración.

*/

DELETE TABLE IF EXISTS InternalAlum;
CREATE TABLE InternalAlum(
	internalAlum INT PRIMARY KEY AUTO_INCREMENT
	academicYear INT NOT NULL,
	duration INT CHECK(duration >= 3 && duration <= 9),
	departmentId INT NOT NULL,
	studentId INT NOT NULL,
	FOREIGN KEY (departmentId) REFERENCES departments(departments.departmentId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (studentId) REFERENCES students(students.studentId)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	UNIQUE(student, academicYear)
);

/*
EJERCICIO 2

Cree un procedimiento almacenado llamado pInsertInterns () que cree los siguientes alumnos internos:
-	Alumno interno del estudiante con ID=1, en el departamento con ID=1, en el año académico 2019, con una duración de 3 meses.
-	Alumno interno del estudiante con ID=1, en el departamento con ID=1, en el año académico 2020, con una duración de 6 meses.
-	Alumno interno del estudiante con ID=2, en el departamento con ID=1, en el año académico 2019.


*/

DELIMITER //

CREATE PROCEDURE pInsertInterns(studentId INT, deparmentId INT, academicYear INT, duration INT)
BEGIN 
	INSERT INTO internalalum(studentId, departmentId, academicYear, duration)
	VALUES (studentId, deparmentId, academicYear, duration);
END //

DELIMITER ;

/*TEST EJERCICIO 2*/
CALL pInsertInterns(1, 1, 2019, 3);
CALL pInsertInterns(1, 1, 2020, 6);
CALL pInsertInterns(2, 1, 2019);

/*
EJERCICIO 3

Cree un procedimiento almacenado llamado pUpdateInterns(s, d) que actualiza la duración de los alumnos internos correspondientes al estudiante con ID=s con el valor d. Ejecute la llamada a pUpdateInterns(1,9)
Cree un procedimiento almacenado llamado pDeleteInterns(s) que elimina los alumnos internos correspondientes al estudiante con ID=s. Ejecute la llamada pDeleteInterns(2)
*/

DELIMITER //
CREATE PROCEDURE pUpdateInterns(s INT, d INT)
BEGIN

	UPDATE internalalum
	SET internalalum.duration = d
	WHERE internalalum.studentId = s;

END //

CREATE PROCEDURE pDeleteInterns(s INT)
BEGIN

	DELETE FROM internalalum WHERE internalalum.studentId = s;

END //

DELIMITER ;

/*TEST EJERCICIO 3*/
CALL pUpdateInterns(1, 5);
CALL pDeleteInterns(1);

/*
EJERCICIO 4

Cree una consulta que devuelva el nombre del profesor, el nombre del grupo, y los créditos que imparte en él para todas las imparticiones de asignaturas por profesores. Un ejemplo de resultado de esta consulta es el siguiente:
*/

SELECT professors.firstName, groups.`name`, teachingLoads.credits FROM teachingloads
JOIN professors ON teachingloads.professorId = professors.professorId
JOIN groups ON teachingloads.groupId = groups.groupId;

/*
EJERCICIO 5

Cree una consulta que devuelva las tutorías con al menos una cita. Un ejemplo de resultado de la consulta anterior es el siguiente:
*/

SELECT appointments.tutoringHoursId FROM appointments;

/*
EJERCICIO 6

Cree una consulta que devuelva el nombre y apellidos de los profesores con un despacho en la planta 0. Un ejemplo de resultado de la consulta anterior es el siguiente:
*/

SELECT professors.firstName, professors.surname FROM professors
JOIN offices ON professors.officeId = offices.officeId
WHERE offices.floor = 0;

/*
EJERCICIO 7

Cree una consulta que devuelva, por cada método de acceso, la media de las notas suspensas, ordenados por esta última de menor a mayor (no tienen que aparecer los métodos de acceso que no se den en ningún alumno o nota). Un ejemplo de resultado de la consulta anterior es el siguiente:
*/

SELECT students.accessMethod, AVG(grades.value) AS avgGrade FROM grades
JOIN students ON grades.studentId = students.studentId
WHERE grades.value < 5
GROUP BY students.accessMethod
ORDER BY avgGrade ASC;

/*
EJERCICIO 8

Cree una consulta que devuelva el nombre y los apellidos de los dos estudiantes con mayor nota media, sus notas medias, y sus notas más baja. Un ejemplo de resultado de la consulta anterior es el siguiente:
*/

SELECT students.firstName, students.surname, AVG(grades.value) AS avgGrade, MIN(grades.value) 
FROM grades
JOIN students ON grades.studentId = students.studentId
GROUP BY grades.studentId;