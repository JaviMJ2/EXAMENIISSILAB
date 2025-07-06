/*
Queremos realizar un seguimiento del historial de cambios de precios de los productos. 
Para ello, cree una tabla llamada HistorialPrecios. Cada registro debe almacenar el 
identificador del producto, la fecha del cambio, el precio anterior y el precio nuevo. 
Un producto puede tener múltiples cambios de precio a lo largo del tiempo.
*/

CREATE TABLE HistorialPrecios (
    idHistorialPrecio INT PRIMARY KEY AUTO_INCREMENT,
    productoId INT,
    fechaCambio DATE,
    pAntiguo DECIMAL(10, 2) CHECK(pAntiguo >= 0),
    pNuevo DECIMAL(10, 2) CHECK(pNuevo >= 0),
    FOREIGN KEY (productoId) REFERENCES Productos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
)

/*
2.1. Devuelva el nombre del producto, el precio medio al que ha sido vendido, y la 
cantidad total vendida. Solo para productos que han sido comprados más de 10 veces.
*/

SELECT
p.nombre AS nombreProducto,
AVG(lp.precio) AS precioMedio,
COUNT(lp.id) AS cantidadVecesVendida
FROM LineasPedido lp 
JOIN Productos p ON lp.productoId = p.id
GROUP BY p.id
HAVING cantidadVecesVendida > 10;

/*
2.2. Devuelva el nombre del cliente, la cantidad total de productos que ha comprado, 
y el importe total que ha gastado en productos digitales. Los clientes que no hayan 
comprado productos digitales también deben aparecer.
*/

SELECT
u.nombre AS nombreCliente,
COUNT(DISTINCT lp.productoId) AS productosComprados,
SUM(lp.precio * lp.unidades) AS importeTotal
FROM LineasPedido lp
LEFT JOIN Pedidos p ON lp.pedidoId = p.id
LEFT JOIN Clientes c ON p.clienteId = c.id
LEFT JOIN Usuarios u ON c.usuarioId = u.id
LEFT JOIN Productos pr ON lp.productoId = pr.id
LEFT JOIN TiposProducto tp ON pr.tipoProductoId = tp.id
WHERE tp.nombre = "Digitales"
GROUP BY p.clienteId;

/*
Cree un procedimiento que permita cancelar un pedido. El procedimiento recibirá un
identificador de pedido, establecerá su fecha de envío a NULL, y pondrá la cantidad
de todas sus líneas de pedido a 0. (1,5 puntos)

Si el pedido ya fue enviado (es decir, su fecha de envío no es NULL), se debe 
lanzar una excepción con el mensaje:

No se puede cancelar un pedido ya enviado.

Garantice que o bien se realizan todas las operaciones o ninguna. (2 puntos)
*/

DELIMITER //

CREATE OR REPLACE PROCEDURE ejercicio3 (
    IN pedidoIdIn INT
)

BEGIN
    DECLARE fechaEnvio DATE;

    START TRANSACTION ; 
        SELECT p.fechaEnvio INTO fechaEnvio
        FROM Pedidos p
        WHERE p.id = pedidoIdIn;
        
        IF fechaEnvio IS NOT NULL THEN 
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede cancelar un pedido ya enviado.';
        END IF ;

        UPDATE Pedidos p
        SET fechaEnvio = NULL
        WHERE p.id = pedidoIdIn;

        UPDATE LineasPedido lp
        SET lp.precio = 0.0
        WHERE lp.pedidoId = pedidoIdIn;
    COMMIT ;

END //

/*
Cree un trigger llamado p_prevenir_precios_irrealistas que evite que se inserten 
o actualicen productos con un precio menor a 0.01 o mayor a 10,000.

Lanza una excepción con el mensaje: Precio no válido: debe estar entre 0.01 y 10,000
*/

CREATE OR REPLACE TRIGGER p_prevenir_precios_irrealistas
BEFORE INSERT ON Productos
FOR EACH ROW

BEGIN 
    IF NEW.precio < 0.01 OR NEW.precio > 10000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Precio no válido: debe estar entre 0.01 y 10,000';
    END IF ;
END //

CREATE OR REPLACE TRIGGER p_prevenir_precios_irrealistas
BEFORE UPDATE ON Productos
FOR EACH ROW

BEGIN 
    IF NEW.precio < 0.01 OR NEW.precio > 10000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Precio no válido: debe estar entre 0.01 y 10,000';
    END IF ;
END //

DELIMITER ; 