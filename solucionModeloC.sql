CREATE OR REPLACE TABLE Valoraciones (
    valoracionId INT PRIMARY KEY AUTO_INCREMENT,
    puntuacion INT CHECK(puntuacion <= 5 AND puntuacion >= 0),
    productoId INT,
    clienteId INT,
    FOREIGN KEY (productoId) REFERENCES Productos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE(valoracionId, clienteId)
)

SELECT
pr.nombre AS nombreProducto,
lp.precio AS fechaRealizacion,
lp.unidades AS unidadesCompradas
FROM LineasPedido AS lp
JOIN Productos AS pr ON lp.productoId = pr.id
ORDER BY unidadesCompradas DESC
LIMIT 5;

SELECT
u.nombre AS nombreEmpleado,
p.fechaRealizacion AS fechaRealizacion,
SUM(lp.precio * lp.unidades) AS precioTotal,
SUM(lp.unidades) AS unidadesTotales
FROM LineasPedido AS lp
JOIN Pedidos AS p ON lp.pedidoId = p.id
JOIN Clientes AS c ON p.clienteId = c.id
JOIN Usuarios AS u ON c.usuarioId = u.id
WHERE TIMESTAMPDIFF(DAY, p.fechaRealizacion, CURDATE()) >= 7
GROUP BY p.id;

DELIMITER //

CREATE OR REPLACE PROCEDURE ejercicio3 (
    IN pedidoIdIn INT,
    IN empleadoIdIn INT
)

BEGIN
    DECLARE empleadoIdAntiguo INT; -- todas las declaraciones fuera del transaction

    START TRANSACTION ;
        SELECT p.empleadoId INTO empleadoIdAntiguo
        FROM Pedidos AS p
        WHERE p.id = pedidoIdIn;

        IF empleadoIdAntiguo IS NULL THEN
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El pedido no tiene gestor.';
        END IF ; 

        UPDATE Pedidos AS p
        SET empleadoId = empleadoIdIn
        WHERE p.id = pedidoIdIn;

        UPDATE LineasPedido AS lp
        SET precio = precio * 0.8 -- OLD.precio solo cuando usamos triggers
        WHERE lp.pedidoId = pedidoIdIn;
    COMMIT ; 

END //

CREATE OR REPLACE TRIGGER p_limitar_unidades_mensuales_de_productos_fisicos
BEFORE INSERT ON LineasPedido
FOR EACH ROW

BEGIN 

    DECLARE tipoProducto VARCHAR(255);
    DECLARE sumaProductos INT;

    SELECT tp.nombre INTO tipoProducto
    FROM Productos AS p
    JOIN TiposProducto AS tp ON p.tipoProductoId = tp.id
    WHERE p.id = NEW.productoId;

    IF tipoProducto = "Físicos" THEN
        SELECT IFNULL(SUM(lp.unidades), 0) INTO sumaProductos -- en caso de que sea NULL poner a 0
        FROM LineasPedido AS lp
        JOIN Pedidos AS pe ON lp.pedidoId = pe.id
        JOIN Productos AS p ON lp.productoId = p.id 
        JOIN TiposProducto AS tp ON p.tipoProductoId = tp.id 
        WHERE lp.productoId = NEW.productoId
            AND (
                MONTH(CURDATE()) = MONTH(pe.fechaRealizacion)
                AND 
                YEAR(CURDATE()) = YEAR(pe.fechaRealizacion)
            );

        IF (sumaProductos + NEW.unidades) > 1000 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede realizar el proceso ya que hay más de 1000 unidades vendidas este mes.';
        END IF ;
    END IF ;

END //


DELIMITER ;