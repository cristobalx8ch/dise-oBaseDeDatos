## Funcionalidades con Triggers

1. **Actualizar stock después de una venta**  
   Disminuye automáticamente el stock del producto vendido.
   ![Actualizar stock después de una venta](img/PrimerTrigger.png)  
   ![Consulta](img/PrimerTriggerSELECT.png)
   ![Verificación](img/PrimerTriggerVerificar.png)  

2. **Bloquear ventas sin suficiente stock**  
   Impide registrar ventas si la cantidad solicitada supera el stock disponible.
   ![Bloquear ventas sin suficiente stock](img/SegundoTrigger.png)  
   ![Consulta](img/SegundoTriggerSELECT.png)
   ![Verificación](img/SegundoTriggerVerificar.png)  
3. **Aumentar el precio si supera $40**  
   Incrementa el precio del producto en un 5% si vale más de $40 al venderlo.
   ![Aumentar el precio si supera 40](img/TercerTrigger.png)  
   ![Consulta](img/TercerTriggerSELECT.png)
   ![Verificación](img/TercerTriggerVerificar.png)  
4. **Registrar cambios de precio en log_precios**  
   Guarda un historial con cada actualización de precio.
   ![Registrar cambios de precio](img/CuartoTrigger.png)  
   ![Consulta](img/CuartoTriggerSELECT.png)  
   ![Verificación](img/CuartoTriggerVerificar.png)
5. **Aumentar stock al eliminar una venta**  
   Restaura el stock si se elimina una venta.
   ![Aumentar stock al eliminar venta](img/QuintoTrigger.png)  
   ![Consulta](img/QuintoTriggerSELECT.png)  
   ![Verificación](img/QuintoTriggerVerificar.png)
6. **Bloquear eliminación de productos con stock**  
   No permite eliminar productos si aún tienen unidades en stock.
   ![Bloquear eliminación con stock](img/SextoTrigger.png)  
   ![Consulta](img/SextoTriggerSELECT.png)  
   ![Verificación](img/SextoTriggerVerificar.png)
7. **Advertencia por producto sin stock (venta prohibida)**  
   Bloquea ventas si el producto está totalmente agotado.
   ![Advertencia por sin stock](img/SeptimoTrigger.png)  
   ![Consulta](img/SeptimoTriggerSELECT.png)  
   ![Verificación](img/SeptimoTriggerVerificar.png)
8. **Mensaje si un producto se agota tras una venta**  
   Muestra advertencia si el stock llega a 0 tras venderlo.
   ![Mensaje producto agotado](img/OctavoTrigger.png)  
   ![Verificación](img/OctavoTriggerVerificar.png)
9. **Marcar productos en promoción**  
   Activa una bandera `en_promocion` si el precio baja de $5.
   ![Marcar productos en promoción](img/NovenoTrigger.png)  
   ![Consulta](img/NovenoTriggerSELECT.png)
10. **Registrar total de la venta**  
    Calcula y guarda el total de cada venta en la tabla `total_ventas`.
   ![Registrar total de la venta](img/DecimoTrigger.png)  
   ![Verificación](img/DecimoTriggerVerificar.png)