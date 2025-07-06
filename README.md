# EXAMENIISSILAB

# CREACIÓN DE TABLAS
Añada el requisito de información Material. Un material es un activo disponible en un aula para la realización de actividades docentes. Sus atributos son: el aula en el que se encuentra el material, el nombre del material, la cantidad disponible, la fecha de adquisición (puede ser futura) y el valor total. Hay que tener en cuenta las siguientes restricciones:
-	El valor total ser inferior a 20.000€.
-	La cantidad debe ser de entre 1 y 50.
-	Un aula no puede tener varios materiales con el mismo nombre.
-	Todos los atributos son obligatorios salvo la fecha de adquisición y el valor total.*/

sql
CREATE TABLE material(
	id INT PRIMARY KEY NOT NULL,
	aula INT NOT NULL,
	nombre VARCHAR (255) NOT NULL,
	cantidadDisponible INT NOT NULL CHECK(cantidadDisponible <= 1 AND cantidadDisponible >= 50),
	fechaAdquisicion DATE,
	valorTotal INT CHECK(valorTotal < 20000),
	UNIQUE (aula, nombre)
);

CHAR_LENGTH() -- sirve para saber la longitud de la palabra (uso en el check)
TRIM() -- igual que en java, quitar espacios de delante y detrás de la palabra

# CONSULTAS QUERY: SELECT
Cree una consulta que devuelva datos que tienen tablas diferentes e inciden directamente en una misma tabla: (Empleados y Clientes son tablas diferentes pero inciden en Usuarios)

sql
SELECT 
uc.nombre AS nombreCliente,
ue.nombre AS nombreEmpleado,
p.fechaRealizacion AS fechaRealizacion
FROM Pedidos AS p
LEFT JOIN Empleados AS e ON p.empleadoId = e.id
-- se usan acronimos diferentes como ue
LEFT JOIN Usuarios AS ue ON e.usuarioId = ue.id 
LEFT JOIN Clientes AS c ON p.clienteId = c.id
-- y en la otra tabla ponemos uno diferente al ue
-- como puede ser uc
LEFT JOIN Usuarios AS uc ON c.usuarioId = uc.id
WHERE MONTH(p.fechaEnvio) = MONTH(CURDATE())
    AND YEAR(p.fechaEnvio) = YEAR(CURDATE());


<div style="margin-top: 3rem; margin-bottom: 3rem;>

El uso de LEFT JOIN, RIGTH JOIN, INNER JOIN, FULL JOIN es el siguiente:
<div style="margin: 1rem">

- LEFT JOIN: para join en los que quiero todos los datos de la tabla de la izquierda
- RIGHT JOIN: para join en los que quiero todos los datos de la tabla de la derecha

FROM (tabla izquierda) JOIN (tabla derecha)

- INNER JOIN: solo se seleccionen los datos que coincida (no haya datos null)
- FULL JOIN: se cogen absolutamente todos los datos haya null o no
</div>
</div>

Distintas funciones en QUERYS SQL:

sql
-- COUNT
SELECT COUNT(*) FROM professors 
JOIN offices ON professors.officeId = offices.officeId
GROUP BY offices.officeId;

-- AVG
SELECT departmentId, AVG(salary) AS avg_salary
FROM professors
GROUP BY departmentId;

-- MIN y MAX
SELECT departmentId, MIN(salary) AS min_salary, MAX(salary) AS max_salary
FROM professors
GROUP BY departmentId;

-- SUM
SELECT professorId, SUM(hours) AS total_hours
FROM courses
GROUP BY professorId;

-- AVG con COUNT dentro de otro SELECT
-- notese que se pueden hacer referencias entre SELECT en este caso con num_professors
SELECT AVG(num_professors) AS avg_professors_per_office
FROM (
    SELECT officeId, COUNT(*) AS num_professors
    FROM professors
    GROUP BY officeId
) AS office_counts;

-- LIMIT
SELECT departmentId, AVG(salary) AS avg_salary
FROM professors
GROUP BY departmentId
ORDER BY avg_salary DESC
LIMIT 3;

-- DISTINCT
SELECT professorId, COUNT(DISTINCT courseId) AS num_courses
FROM courses
GROUP BY professorId;

-- HAVING: la diferencia con WHERE es que WHERE se hace antes de hacer un GROUP BY y el HAVING después
SELECT clienteId, COUNT(*) AS num_pedidos
FROM Pedidos
GROUP BY clienteId
HAVING COUNT(*) > 5;

--ALL
SELECT * FROM Empleados
WHERE salario > ALL (SELECT salario FROM Empleados WHERE id <> e.id);
-- si el salario es mayor que el mayor

-- ANY
SELECT * FROM Empleados
WHERE salario > ANY (SELECT salario FROM Empleados WHERE id <> e.id);
-- si el salario es mayor que al menos uno de ellos

-- NINGUNO DE LOS DOS SON MAX O MIN SON OPERADORES LÓGICOS
-- lo cogeremos si su salario es mayor QUE ALGUNO, o si es MAYOR QUE TODOS,
-- no buscamos min o max, buscamos en referencia a todos o a alguno

# PROCEDURES

Cree un procedimiento almacenado llamado pInsertMaterials() que cree los siguientes contratos:
-	Material llamado “material 1” en el aula con ID=1, con cantidad de 3 y valor total de 3000€.
-	Material llamado “material 2” en el aula con ID=1, con cantidad de 1, valor total de 1000€, con fecha de adquisición 2020-05-05.
-	Material llamado “material 3· en el aula con ID=2, con cantidad de 2, valor total de 5000€, con fecha de adquisición 2020-12-12.

sql
DELIMITER //
 CREATE OR REPLACE PROCEDURE pInsertarMaterial(
	IN aula VARCHAR(255), 
	IN nombre VARCHAR(255), 
	IN cantidadDisponible INT , 
	IN fechaAdquisicion DATE , 
	IN valorTotal INT 
)
BEGIN
	INSERT INTO Material (aula, nombre, cantidadDisponible, fechaAdquisicion, valorTotal) 
		VALUES (aula, nombre, cantidadDisponible, fechaAdquisicion, valorTotal);
END//

DELIMITER ;
-- Llamada a procedimiento
CALL pInsertarMaterial(1, 'material 1', 3, NULL, 3000);
CALL pInsertarMaterial(1, 'material 2', 1,'2020-05-05', 1000);
CALL pInsertarMaterial(2, 'material 3', 2,'2020-12-12', 5000);
 

Cree un procedimiento almacenado llamado pUpdateMaterials(c, a) que actualiza la cantidad de los materiales del aula con ID=c con el valor a. Ejecute la llamada a pUpdateMaterials(1,2).
Cree un procedimiento almacenado llamado pDeleteMaterials(c) que elimina los materiales del aula con ID=c. Ejecute la llamada pDeleteMaterials(2)

sql
-- ACTUALIZAR
DELIMITER //
CREATE OR REPLACE PROCEDURE pUpdateMaterials(
	IN c INT, 
	IN a INT
) 
BEGIN
	UPDATE material
	SET cantidadDisponible = a
	WHERE material.aula = c;
END//
DELIMITER ;

CALL pUpdateMaterials(1,2);


-- BORRAR 
DELIMITER //
CREATE OR REPLACE PROCEDURE pDeleteMaterials(
	IN c INT 
	)
BEGIN 
	DELETE FROM material
	WHERE material.aula= c;
END//
DELIMITER ;

CALL pDeleteMaterials(2);

-- Para poner una variable con un valor podemos usar el: 
SELECT _ INTO variable
FROM ...

-- O  si no usamos un select
SET @variable = _ ;

-- Para mirar el último ID creado:
SET @ultimoIdCreado = LAST_INSERT_ID();

-- En caso de que valor sea NULL, sustituimos el valor por valor_por_defecto
IFNULL(valor, valor_por_defecto)


# FUNCTIONS
Estructura básica de las functions

sql
DELIMITER //

CREATE OR REPLACE FUNCTION function(
	IN dato1 INT,
	IN dato2 INT
) RETURNS INT
BEGIN

-- codigo que sea necesario

	RETURN (
		-- lo que tenga que devolver
	);

END //

DELIMITER ;


Ejemplo de uso:
sql
CREATE FUNCTION calcular_edad_cliente(
	IN cliente_id INT
)
RETURNS INT
BEGIN
    DECLARE edad INT;

    SELECT TIMESTAMPDIFF(YEAR, fechaNacimiento, CURDATE())
    INTO edad
    FROM Clientes
    WHERE id = cliente_id;

    RETURN edad;
END //

DELIMITER ;

-- LLAMAR A UNA FUNCION
SELECT u.nombre, calcular_edad_cliente(c.id) AS edad
FROM Clientes c
JOIN Usuarios u ON c.usuarioId = u.id;



# TRIGGERS
Un trigger es un procedimiento almacenado que se ejecuta automáticamente ante eventos como INSERT, UPDATE o DELETE en una tabla. SOLO AQUI SE USAN LOS NEW Y LOS OLD.

Estructura básica:
sql
CREATE TRIGGER nombre_trigger
{ BEFORE | AFTER } { INSERT | UPDATE | DELETE }
ON nombre_tabla
FOR EACH ROW
BEGIN
código SQL
END;


Ejemplo 1: Validar que un cliente sea mayor de 14 años al insertar
sql
DELIMITER //

CREATE TRIGGER cliente_edad_minima
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.fechaNacimiento, CURDATE()) <= 14 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener más de 14 años.';
    END IF;
END //

DELIMITER ;

Ejemplo 2: Validar que un cliente tenga al menos 18 años para comprar productos restringidos
sql
DELIMITER //

CREATE TRIGGER check_edad_minorista
BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE clienteEdad INT;
    DECLARE ventaPermitida BOOLEAN;

    SELECT TIMESTAMPDIFF(YEAR, fechaNacimiento, CURDATE())
    INTO clienteEdad
    FROM Clientes
    INNER JOIN Pedidos ON Clientes.id = Pedidos.clienteId
    WHERE Pedidos.id = NEW.pedidoId;

    SELECT puedeVenderseAMenores
    INTO ventaPermitida
    FROM Productos
    WHERE id = NEW.productoId;

    IF ventaPermitida = FALSE AND clienteEdad < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener al menos 18 años para comprar este producto.';
    END IF;
END //

DELIMITER ;


# VISTAS

Una vista es una tabla virtual basada en el resultado de una consulta SQL.  
Permite simplificar consultas complejas, reutilizar lógica y controlar el acceso a datos.

Estructura básica para crear una vista
sql
CREATE VIEW nombre_vista AS
SELECT columnas
FROM tablas
WHERE condiciones;


Ejemplo de uso: vista para mostrar los pedidos con el nombre del cliente y empleado

sql
CREATE VIEW vista_pedidos_con_nombres AS
SELECT 
    p.id AS pedidoId,
    u_cliente.nombre AS nombreCliente,
    u_empleado.nombre AS nombreEmpleado,
    p.fechaRealizacion,
    p.fechaEnvio,
    p.direccionEntrega
FROM Pedidos p
LEFT JOIN Clientes c ON p.clienteId = c.id
LEFT JOIN Usuarios u_cliente ON c.usuarioId = u_cliente.id
LEFT JOIN Empleados e ON p.empleadoId = e.id
LEFT JOIN Usuarios u_empleado ON e.usuarioId = u_empleado.id;

# LIKE
% para indicar que queremos buscar una palabra o carácter que: 
- %palabra, este al final de la frase
- palabra%, este al principio de la frase
- %palabra%, este dentro de la frase o en cualquier lugar

_ para indicar que queremos buscar una palabra o carácter que: (cada guion bajo es un carater)
- ___bra, termine con 'bra' como puede ser palabra
- pal___, que comience con 'pal'

[] para indicar los caracteres que estamos buscando:
- [a-f]  de la 'a' a la 'f'
- [aeiou] dentro de un conjunto

[^] para buscar caracteres o grupos, que no tengan los caracteres señalados entre corchetes:
- 'de[^l]%' busca todos los apellidos de autores que empiecen por de y en los que la letra siguiente no sea l.

COMBINACIONES DE ELLOS
[a-f]%
a__%
_r%
 

*	Represents zero or more characters				bl* finds bl, black, blue, and blob
?	Represents a single character					h?t finds hot, hat, and hit
[]	Represents any single character within the brackets		h[oa]t finds hot and hat, but not hit
!	Represents any character not in the brackets			h[!oa]t finds hit, but not hot and hat
-	Represents any single character within the specified range	c[a-b]t finds cat and cbt
#	Represents any single numeric character				2#5 finds 205, 215, 225, 235, 245, 255, 265, 275, 285, and 295

# IN y NOT IN
Para indicar en el WHERE si un dato en especifico esta en una lista de datos: WHERE Country IN ('Germany', 'France', 'UK');

se puede hacer con selects:
WHERE CustomerID IN (SELECT CustomerID FROM Orders);

## INSERTS DE TABLAS CON CONSULTAS
INSERT INTO table2
SELECT * FROM table1
WHERE condition;

INSERT INTO table2 (column1, column2, column3, ...)
SELECT column1, column2, column3, ...
FROM table1
WHERE condition;

INSERT INTO Customers (CustomerName, City, Country)
SELECT SupplierName, City, Country FROM Suppliers;

# ALTER TABLE

añadir columna a tabla:
ALTER TABLE Persons
ADD DateOfBirth date;

eliminar columna de una tabla:
ALTER TABLE Persons
DROP COLUMN DateOfBirth;

modificar una columna de la tabla:
ALTER TABLE Persons
ALTER COLUMN DateOfBirth year;
