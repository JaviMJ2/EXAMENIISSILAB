/* CREACION DE LA TABLA */

CREATE OR REPLACE TABLE Pagos (
    idPago INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId INT,
    fechaPago DATE, 
    cantidad DECIMAL(10,2) CHECK(cantidad > 0.0),
    revisado BOOLEAN DEFAULT false,
    FOREIGN KEY (pedidoId) REFERENCES Pedidos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

-- no es necesario usar unique ya que no se tienen que hacer combinaciones de dato unicas

/* CONSULTA SQL */

/*
usar:
- LEFT JOIN: para join en los que quiero todos los datos de la tabla de la izquierda
- RIGHT JOIN: para join en los que quiero todos los datos de la tabla de la derecha

FROM (tabla izquierda) JOIN (tabla derecha)

- INNER JOIN: solo se seleccionen los datos que coincida (no haya datos null)
- FULL JOIN: se cogen absolutamente todos los datos haya null o no
*/


/* IMPORTANTE EJERCICIO (se hacen dos joins de dos tablas a una misma tabla)*/
SELECT 
uc.nombre AS nombreCliente,
ue.nombre AS nombreEmpleado,
p.fechaRealizacion AS fechaRealizacion
FROM Pedidos AS p
LEFT JOIN Empleados AS e ON p.empleadoId = e.id
LEFT JOIN Usuarios AS ue ON e.usuarioId = ue.id
LEFT JOIN Clientes AS c ON p.clienteId = c.id
LEFT JOIN Usuarios AS uc ON c.usuarioId = uc.id
WHERE MONTH(p.fechaEnvio) = MONTH('2024-09-01')
    AND YEAR(p.fechaEnvio) = YEAR('2024-09-01');

SELECT
u.nombre AS nombreCliente,
SUM(lp.unidades) AS unidades,
SUM(lp.precio * lp.unidades) AS importeGastado
FROM LineasPedido AS lp
JOIN Pedidos AS p ON lp.pedidoId = p.id
JOIN Clientes AS c ON p.clienteId = c.id
JOIN Usuarios AS u ON c.usuarioId = u.id
WHERE (
	SELECT COUNT(p.id)
	FROM Pedidos AS p
	WHERE TIMESTAMPDIFF(YEAR, p.fechaRealizacion, CURDATE()) <= 1
		AND p.clienteId = c.id
	) > 5
GROUP BY nombreCliente;

/* PROCEDURE */
DELIMITER //
CREATE OR REPLACE PROCEDURE ejercicio3(
    IN nombreIn INT,
    IN descripciónIn TEXT,
    IN precioIn DECIMAL(10, 2),
    IN tipoProductoIdIn INT,
    IN puedeVenderseAMenoresIn BOOLEAN,
    IN regaloIn BOOLEAN
)

BEGIN

    DECLARE clienteMasAntiguoId INT;
    DECLARE direccionEntregaCliente VARCHAR(255);
    DECLARE productoIdCreado INT;
    DECLARE pedidoIdCreado INT; -- en algun momento se ponen los DECLARE dentro?

    START TRANSACTION ;

        IF regaloIn AND precioIn > 50.0 THEN
            ROLLBACK ;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede hacer un regalo de mas de 50€.';
        END IF;

        INSERT INTO Productos (nombre, descripción, precio, tipoProductoId, puedeVenderseAMenores)
            VALUES (nombreIn, descripciónIn, precioIn, tipoProductoIdIn, puedeVenderseAMenoresIn);

        SET @productoNuevoId = LAST_INSERT_ID(); -- para seleccionar el id que acabamos de seleccionar

        IF regaloIn THEN
            SELECT c.id INTO clienteMasAntiguoId
            FROM Clientes AS c
            ORDER BY c.fechaNacimiento DESC
            LIMIT 1;

            SELECT c.direccionEnvio INTO direccionEntregaCliente
            FROM Clientes AS c
            WHERE c.id = clienteMasAntiguoId;

            INSERT INTO Pedidos (fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
                VALUES (CURDATE(), NULL, direccionEntregaCliente, NULL, clienteMasAntiguoId, NULL); -- preguntar que hay que hacer en el caso de que no se nos den datos como el empleado

            SET @pedidoIdCreado = LAST_INSERT_ID(); -- en qué parte del temario esta esto?

            INSERT INTO LineasPedido (pedidoId, productoId, unidades, precio) 
                VALUES (pedidoIdCreado, productoIdCreado, 1, 0.0);
        END IF ;

    COMMIT ;

END //

/* CREATE TRIGGER */
CREATE OR REPLACE TRIGGER t_limitar_importe_pedidos_de_menores
BEFORE INSERT ON LineasPedido
FOR EACH ROW

BEGIN
    DECLARE edadUsuario INT;
    DECLARE precioPedido DECIMAL(10, 2);

    SELECT TIMESTAMPDIFF(YEAR, c.fechaNacimiento, CURDATE()) INTO edadUsuario
    FROM Pedidos AS p
    JOIN Clientes AS c ON p.clienteId = c.id
    WHERE p.id = NEW.pedidoId;

    SELECT SUM(lp.precio * lp.unidades) INTO precioPedido
    FROM LineasPedido AS lp 
    WHERE lp.pedidoId = NEW.pedidoId;

    IF edadUsuario < 18 AND (precioPedido + (NEW.precio * NEW.unidades)) > 500 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden hacer compras de más de 500€ siendo menor de edad.';
    END IF ;
END //

DELIMITER ;