/* CREACION DE TABLA GARANTIAS */
CREATE OR REPLACE TABLE Garantias (
    garantiasId INT PRIMARY KEY AUTO_INCREMENT,
    fechaInicio DATE,
    fechaFin DATE,
    extendida BOOLEAN
    productoId INT,
    FOREIGN KEY productoId REFERENCES Productos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE(garantiasId, productoId),
    CONSTRAINT fecha CHECK(fechaFin > fechaInicio)
)

/* CONSULTAS */

SELECT 
p.nombre AS "Nombre Producto",
tp.nombre AS "Tipo Producto",
lp.precio AS "Precio Unitario"
FROM LineasPedido AS lp
JOIN Productos AS p ON p.id = lp.productoId
JOIN TiposProducto AS tp ON tp.id = p.tipoProductoId
WHERE tp.nombre = "Digitales";

SELECT
u.nombre AS "Empleado",
COUNT(p.id) AS "Numero Pedidos",
SUM(lp.precio) AS "Cantidad"
FROM LineasPedido AS lp
JOIN Pedidos AS p ON lp.pedidoId = p.id
JOIN Empleados AS e ON p.empleadoId = e.id
JOIN Usuarios AS u ON e.usuarioId = u.id
WHERE lp.precio > 500 AND YEAR(p.fechaRealizacion) < YEAR(CURDATE()) 
ORDER BY 3 DESC;

/* PROCEDIMIENTO */
DELILMITER //
CREATE OR REPLACE PROCEDURE ejercicio3 (
    IN productoId INT,
    IN nuevoPrecio INT
)

BEGIN

    DECLARE precioAntiguo DECIMAL(10, 2);

    START TRANSACTION ;

    IF NOT EXISTS (SELECT * FROM Productos AS p WHERE p.id = productoId) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe un producto con ese ID.';
    END IF ;

    SELECT p.precio FROM Productos 
    INTO precioAntiguo
    WHERE p.id = productoId;

    IF precioAntiguo * 0.5 > precioNuevo THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite rebajar el precio más del 50%.';
    END IF ;

    UPDATE Productos AS p
    SET p.precio = nuevoPrecio
    WHERE p.id = productoId;

    UPDATE LineasPedido AS lp
    JOIN Pedidos AS p ON p.id = lp.pedidoId
    SET lp.precio = nuevoPrecio
    WHERE p.fechaEnvio IS NULL AND lp.productoId = productoId;

    COMMIT ;

END //

DELIMITER ;

/* TRIGGER */
DELIMITER //
CREATE OR REPLACE TRIGGER t_asegurar_mismo_tipo_producto_en_pedidos
BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE tipoProductoPedidos INT;
    DECLARE existe BOOLEAN;

    SELECT p.tipoProductoId INTO tipoProductoPedidos
    FROM Productos AS p
    WHERE p.id = NEW.productoId;

    SELECT EXISTS (
        SELECT * FROM LineasPedido AS lp 
        JOIN Productos AS p ON p.id = lp.productoId
        WHERE lp.pedidoId = NEW.pedidoId 
            AND tipoProductoPedidos <> p.tipoProductoId
        ) INTO existe;

    IF existe THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden juntar productos digitales con físicos.';
    END IF ;

END //

DELIMITER ;