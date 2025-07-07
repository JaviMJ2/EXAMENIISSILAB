# EXAMENIISSILAB

## CREACIÓN DE TABLAS

Añada el requisito de información Material. Un material es un activo disponible en un aula para la realización de actividades docentes. Sus atributos son: el aula en la que se encuentra el material, el nombre del material, la cantidad disponible, la fecha de adquisición (puede ser futura) y el valor total. Hay que tener en cuenta las siguientes restricciones:

- El valor total ser inferior a 20.000€.
- La cantidad debe ser de entre 1 y 50.
- Un aula no puede tener varios materiales con el mismo nombre.
- Todos los atributos son obligatorios salvo la fecha de adquisición y el valor total.

```sql
CREATE TABLE material(
	id INT PRIMARY KEY NOT NULL,
	aula INT NOT NULL,
	nombre VARCHAR(255) NOT NULL,
	cantidadDisponible INT NOT NULL CHECK(cantidadDisponible >= 1 AND cantidadDisponible <= 50),
	fechaAdquisicion DATE,
	valorTotal INT CHECK(valorTotal < 20000),
	UNIQUE (aula, nombre)
);
```

`CHAR_LENGTH()` -- sirve para saber la longitud de la palabra (uso en el check)  
`TRIM()` -- igual que en java, quitar espacios de delante y detrás de la palabra

---

## CONSULTAS QUERY: SELECT

Cree una consulta que devuelva datos que tienen tablas diferentes e inciden directamente en una misma tabla: (Empleados y Clientes son tablas diferentes pero inciden en Usuarios)

```sql
SELECT 
    uc.nombre AS nombreCliente,
    ue.nombre AS nombreEmpleado,
    p.fechaRealizacion AS fechaRealizacion
FROM Pedidos AS p
LEFT JOIN Empleados AS e ON p.empleadoId = e.id
LEFT JOIN Usuarios AS ue ON e.usuarioId = ue.id 
LEFT JOIN Clientes AS c ON p.clienteId = c.id
LEFT JOIN Usuarios AS uc ON c.usuarioId = uc.id
WHERE MONTH(p.fechaEnvio) = MONTH(CURDATE())
  AND YEAR(p.fechaEnvio) = YEAR(CURDATE());
```

---

El uso de LEFT JOIN, RIGHT JOIN, INNER JOIN, FULL JOIN es el siguiente:

- **LEFT JOIN**: para join en los que quiero todos los datos de la tabla de la izquierda  
- **RIGHT JOIN**: para join en los que quiero todos los datos de la tabla de la derecha  
- **INNER JOIN**: solo se seleccionan los datos que coinciden (no haya datos null)  
- **FULL JOIN**: se cogen absolutamente todos los datos, haya null o no

---

## Distintas funciones en QUERYS SQL:

```sql
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

-- HAVING
SELECT clienteId, COUNT(*) AS num_pedidos
FROM Pedidos
GROUP BY clienteId
HAVING COUNT(*) > 5;

-- ALL
SELECT * FROM Empleados
WHERE salario > ALL (SELECT salario FROM Empleados WHERE id <> e.id);

-- ANY
SELECT * FROM Empleados
WHERE salario > ANY (SELECT salario FROM Empleados WHERE id <> e.id);
```

---

## PROCEDURES

```sql
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

-- Llamadas
CALL pInsertarMaterial(1, 'material 1', 3, NULL, 3000);
CALL pInsertarMaterial(1, 'material 2', 1,'2020-05-05', 1000);
CALL pInsertarMaterial(2, 'material 3', 2,'2020-12-12', 5000);
```

```sql
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
```

```sql
-- BORRAR 
DELIMITER //
CREATE OR REPLACE PROCEDURE pDeleteMaterials(
	IN c INT 
)
BEGIN 
	DELETE FROM material
	WHERE material.aula = c;
END//
DELIMITER ;

CALL pDeleteMaterials(2);
```

```sql
-- Variables
SELECT _ INTO variable FROM ...;
SET @variable = _ ;
SET @ultimoIdCreado = LAST_INSERT_ID();
IFNULL(valor, valor_por_defecto);
```

---

## FUNCTIONS

```sql
DELIMITER //

CREATE OR REPLACE FUNCTION function(
	IN dato1 INT,
	IN dato2 INT
) RETURNS INT
BEGIN
	RETURN (
		-- lo que tenga que devolver
	);
END //

DELIMITER ;
```

```sql
-- Ejemplo
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

-- Llamada
SELECT u.nombre, calcular_edad_cliente(c.id) AS edad
FROM Clientes c
JOIN Usuarios u ON c.usuarioId = u.id;
```

---

## TRIGGERS

```sql
-- Validar edad mínima cliente
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
```

```sql
-- Validar edad para productos restringidos
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
```

---

## VISTAS

```sql
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
```

---

## LIKE

- `%palabra` → termina con “palabra”  
- `palabra%` → empieza con “palabra”  
- `%palabra%` → contiene “palabra”  
- `___bra` → termina en “bra” con 3 caracteres antes  
- `pal___` → empieza con “pal” y 3 caracteres más  
- `[a-f]%` → empieza con letras de la a a la f  
- `[^l]%` → empieza con cualquier cosa que no sea l  

---

## IN y NOT IN

```sql
WHERE Country IN ('Germany', 'France', 'UK');
WHERE CustomerID IN (SELECT CustomerID FROM Orders);
```

---

## INSERTS DE TABLAS CON CONSULTAS

```sql
INSERT INTO table2
SELECT * FROM table1
WHERE condition;

INSERT INTO table2 (column1, column2, column3, ...)
SELECT column1, column2, column3, ...
FROM table1
WHERE condition;

INSERT INTO Customers (CustomerName, City, Country)
SELECT SupplierName, City, Country FROM Suppliers;
```

---

## ALTER TABLE

```sql
ALTER TABLE Persons
ADD DateOfBirth date;

ALTER TABLE Persons
DROP COLUMN DateOfBirth;

ALTER TABLE Persons
ALTER COLUMN DateOfBirth year;
```
