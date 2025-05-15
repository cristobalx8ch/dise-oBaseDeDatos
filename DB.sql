-- Crear la base de datos
CREATE DATABASE tienda;
USE tienda;

DROP DATABASE tienda;

-- Crear la tabla de productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    cantidad_stock INT,
    precio DECIMAL(10, 2)
);

-- Crear la tabla de ventas
CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    cantidad INT,
    fecha_venta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Insertar algunos productos de ejemplo
INSERT INTO productos (nombre, cantidad_stock, precio)
VALUES 
('Camiseta', 100, 15.00),
('Pantalón', 50, 25.00),
('Zapatos', 30, 50.00),
('Sombrero', 20, 10.00);




/*
1.	Crear un trigger que actualice el stock de un producto después de realizar una venta.
o	Descripción: Cada vez que se registre una venta en la tabla ventas, el stock de productos en la tabla productos debe disminuir según la cantidad vendida.
o	Tipo de Trigger: AFTER INSERT

*/

--actualiza stock tras  venta disminuye stock segun cantidad vendida

DELIMITER $$

CREATE Trigger trg_ventas_insert_AFTER_stock
AFTER INSERT ON ventas
FOR EACH ROW 
BEGIN
    UPDATE productos
    set cantidad_stock = cantidad_stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END $$

DELIMITER;

INSERT INTO ventas (id_producto, cantidad) 
VALUES
(1, 3),
(2, 5),
(3, 2);



/*
2.	Crear un trigger que no permita realizar una venta si no hay suficiente stock.
o	Descripción: Si alguien intenta vender más unidades de un producto de las que están disponibles en el stock, se debe evitar que la venta se registre.
o	Tipo de Trigger: BEFORE INSERT

*/

--Evita venta si no hay stock suficiente  lanza error

DELIMITER $$
CREATE Trigger trg_ventas_insert_BEFORE
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN 
    DECLARE stock_actual INT;
    SELECT cantidad_stock INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;


    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR, no hay suficiente stock';
    END IF;
END $$
DELIMITER;

SELECT * FROM productos

SELECT * FROM productos WHERE id_producto = 1;
INSERT INTO ventas (id_producto, cantidad) VALUES (1, 10);
INSERT INTO ventas (id_producto, cantidad) VALUES (1, 200);

/*
3.	Crear un trigger que actualice el precio del producto cuando se realice una venta.
o	Descripción: Cada vez que se registre una venta, si el precio del producto es superior a $40, su precio debe aumentar un 5%.
o	Tipo de Trigger: AFTER INSERT
*/

-- aumenta en un precio 5% si precio del prodcuto actual es mayor a 40$  debe registrar una venta 
DELIMITER $$ 
CREATE TRIGGER trg_ventas_insert_AFTER
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN 
    UPDATE Productos
    SET precio = precio * 1.05
    WHERE id_producto = NEW.id_producto
    AND precio > 40;
END $$

DELIMITER;

SELECT * FROM productos WHERE id_producto = 3;
INSERT INTO ventas (id_producto, cantidad) VALUES (3,1);
SELECT * FROM productos WHERE id_producto = 3;

/*
4.	Crear un trigger que registre en una tabla de logs cada vez que se actualice el precio de un producto.
o	Descripción: Si el precio de un producto cambia, debe guardarse un registro de ese cambio en una tabla de logs llamada log_precios con la fecha del cambio y el nuevo precio.
o	Tipo de Trigger: AFTER UPDATE
*/

-- registrar en una  tabla de log cada vez que cambie el precio de un producto 
CREATE TABLE log_precios (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    nuevo_precio DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$
CREATE TRIGGER trg_productos_update_AFTER
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN 
    IF OLD.precio != NEW.precio THEN
    INSERT INTO log_precios (id_producto, nuevo_precio)
    VALUES (NEW.id_producto, NEW.precio);
    END IF;
END $$
DELIMITER ;

SELECT * FROM productos WHERE id_producto = 1;

UPDATE productos SET precio = 20.50 WHERE id_producto = 1;

SELECT * FROM log_precios;


/*
5.	Crear un trigger que actualice el stock después de eliminar una venta.
o	Descripción: Si una venta es eliminada de la tabla ventas, el stock del producto debe incrementarse en la cantidad de productos que se habían vendido en esa transacción.
o	Tipo de Trigger: AFTER DELETE
*/

--aumenta el stock del producto cuando se elimina una venta 

DELIMITER $$

CREATE TRIGGER trg_ventas_delete_AFTER
AFTER DELETE ON ventas
FOR EACH ROW
BEGIN 
    UPDATE productos
    SET cantidad_stock = cantidad_stock + OLD.cantidad
    WHERE id_producto = OLD.id_producto;
END $$
DELIMITER;

--Ver stock antes 
SELECT * FROM productos WHERE id_producto = 1;

--Eliminar una venta 
DELETE FROM ventas WHERE id_venta = 1;

--Verificar que el stock aumento 
SELECT * FROM productos WHERE id_producto = 1;


/*
6.	Crear un trigger que no permita eliminar productos si el stock es mayor a cero.
o	Descripción: Si el stock de un producto es mayor que cero, no se debe permitir eliminar ese producto de la tabla productos.
o	Tipo de Trigger: BEFORE DELETE
*/
-- evita eliminar un producto  si su stack  es mayor  a cero 

DELIMITER $$
CREATE TRIGGER trg_productos_delete_BEFORE
BEFORE DELETE ON productos
FOR EACH ROW
BEGIN
    IF OLD.cantidad_stock > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: no se puede eliminar un producto con un stock distinto';
    END IF;
END $$

DELIMITER;

--verifica el producto que quieres borrar 
SELECT * FROM productos WHERE id_producto = 2;

--intentar eliminarlo
DELETE FROM productos WHERE id_producto = 2;

/*
7.	Crear un trigger que registre un mensaje en la consola cuando se intente realizar una venta de un producto que no está en stock.
o	Descripción: Si un producto no tiene stock y se intenta registrar una venta, se debe imprimir un mensaje de advertencia.
o	Tipo de Trigger: BEFORE INSERT

*/
-- impide  registrar ventas de productos  que no tiene stock disponible 
DELIMITER $$
CREATE TRIGGER trg_ventas_sin_stock_BEFORE
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT cantidad_stock INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;
    IF stock_actual = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ADVERTENCIA: El producto no tiene stock';
    END IF;
END $$

DELIMITER;

--producto que quiero probar 
SELECT * FROM productos WHERE id_producto = 4;
--registrar una venta  con este producto 
INSERT INTO ventas (id_producto, cantidad) VALUES (4,20);


/*
8.	Crear un trigger que registre un mensaje cuando el stock de un producto alcance cero.
o	Descripción: Si el stock de un producto llega a cero después de una venta, se debe imprimir un mensaje indicando que el producto está agotado.
o	Tipo de Trigger: AFTER INSERT
*/


-- muestra un mensaje si tras una venta el producto queda sin stock 

USE tienda;
DELIMITER $$
CREATE TRIGGER rg_ventas_insert_AFTER_agotado
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    SELECT cantidad_stock INTO stock_actual
    FROM productos
    WHERE id_producto = new.id_producto;
    IF stock_actual = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ATENCION: EL producto esta agotado';
    END IF;
END $$
DELIMITER;

UPDATE productos SET cantidad_stock = 1 WHERE id_producto = 2;

INSERT INTO ventas (id_producto, cantidad) VALUES (2,1);

/*
9.	Crear un trigger que, si el precio de un producto baja por debajo de $5, lo marque como "en promoción".
o	Descripción: Si el precio de un producto se reduce por debajo de $5, debe añadirse un campo "en_promocion" en la tabla productos y actualizarlo a TRUE.
o	Tipo de Trigger: AFTER UPDATE
*/

-- marca un producto como promocion  si su precio baja por debajo de $5
ALTER TABLE productos
ADD COLUMN en_promocion BOOLEAN DEFAULT FALSE;
DROP TRIGGER trg_productos_update_AFTER_promocion

DELIMITER $$
CREATE TRIGGER trg_productos_update_AFTER_promocion
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    IF NEW.precio < 5 THEN
        UPDATE productos
        SET en_promocion = TRUE
        WHERE id_producto = NEW.id_producto;
    END IF;
END $$
DELIMITER;

--ver estado antes
SELECT * FROM productos WHERE id_producto = 2;





/*
10.	 Crear un trigger que, después de insertar una venta, calcule el total de la venta y lo registre en una tabla total_ventas.
o	Descripción: Después de insertar una venta, se debe calcular el total de la venta (cantidad * precio) y registrar esa información en una nueva tabla llamada total_ventas con la fecha de la venta.
o	Tipo de Trigger: AFTER INSERT
*/


-- calcula el total de una venta despues de insertarla y lo guarda en la tabla total_ventas  
CREATE TABLE total_ventas (
    id_total_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    total DECIMAL (10,2),
    fecha_venta DATETIME
);

DELIMITER $$
CREATE TRIGGER trg_ventas_after_insert_total
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    DECLARE precio_producto DECIMAL(10,2);
    DECLARE total_venta DECIMAL(10,2);

    SELECT precio INTO precio_producto
    FROM productos
    WHERE id_producto = NEW.id_producto;
    SET total_venta = NEW.cantidad * precio_producto;
    INSERT INTO total_ventas (id_venta, total, fecha_venta)
    VALUES (NEW.id_venta, total_venta, NEW.fecha_venta);
END$$
DELIMITER;

--Inserta venta que activa  el trigger 
INSERT INTO ventas (id_producto, cantidad) VALUES (1, 2);

-- muestra  los totales  calculados de ventas 
SELECT * FROM total_ventas;