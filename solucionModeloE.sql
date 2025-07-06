/* CREACION DE TABLA */

CREATE OR REPLACE TABLE Devoluciones (
    devolucionId INT PRIMARY KEY AUTO_INCREMENT,
    lineaPedidoId INT,
    fecha DATE,
    motivo TEXT,
    estado ENUM('Pendiente', 'Rechazada', 'Aceptada'),
    FOREIGN KEY (lineaPedidoId) REFERENCES LineasPedido(id),
    UNIQUE(devolucionId, lineaPedidoId)
)

-- propuesta de trigger para: 
-- Asegure que la fecha de devolución no sea anterior a la fecha de 
-- realización del pedido correspondiente.

DELIMITER // 
CREATE OR REPLACE TRIGGER fechaDevolucion_fechaRealizacion
BEFORE INSERT ON Devoluciones
FOR EACH ROW

BEGIN 
    DECLARE fechaRealizacionLineaPedido DATE;
    
    SELECT p.fechaRealizacion INTO fechaRealizacionLineaPedido
    FROM LineasPedido AS lp
    JOIN Pedidos AS p ON p.id = lp.pedidoId
    WHERE lp.id = NEW.lineaPedidoId;

    IF fechaRealizacionLineaPedido > NEW.fecha THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de realizacion de la devolucion no puede ser anterior
        a la de la fecha de realización.';
    END IF ;
END // 

DELIMITER ;

/* CONSULTAS */

SELECT DISTINCT
p.nombre AS producto,
tp.nombre AS tipoProducto,
lp.precio AS precioUnitario
FROM LineasPedido AS lp
JOIN Productos AS p ON lp.productoId = p.id
JOIN TiposProducto AS tp ON p.tipoProductoId = tp.id
WHERE lp.precio > 100.0;

-- este select no devuelve nada porque la base de datos no tiene registros
-- de estas magnitudes en 6 meses atrás
SELECT
u.nombre AS nombreEmpleado,
COUNT(p.id) AS numeroPedidos,
SUM(lp.precio) AS importeTotal
FROM LineasPedido AS lp 
JOIN Pedidos AS p ON p.id = lp.pedidoId
JOIN Empleados AS e ON e.id = p.empleadoId
JOIN Usuarios AS u ON e.usuarioId = u.id
WHERE lp.precio > 1000.0 
    AND TIMESTAMPDIFF(MONTH, p.fechaRealizacion, CURDATE()) <= 6
GROUP BY nombreEmpleado
ORDER BY importeTotal DESC;

/* PROCEDURE IGUAL QUE MODELO A CON 70%*/

/* TRIGGER IGUAL QUE MODELO A*/

/* FUNCION */
DELIMITER //  
CREATE OR REPLACE FUNCTION f_total_cliente(
    IN clienteIdIn INT
) RETURNS DECIMAL(10,2)
BEGIN
    RETURN (
        SELECT SUM(lp.precio * lp.unidades)
        FROM LineasPedido AS lp
        JOIN pedidos AS p ON p.id = lp.pedidoId
        WHERE p.fechaEnvio IS NOT NULL 
            AND p.clienteId = clienteIdIn
    );
END //

DELIMITER ;