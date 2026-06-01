-- ================================================
-- PROYECTO SUPPLY CHAIN — Análisis de Operaciones
-- Daniel Esquivel — 2026
-- Herramienta: DB Browser for SQLite
-- Dataset: US Regional Sales Data (Kaggle)
-- ================================================

-- PREGUNTA 1: Resumen financiero global

WITH datos_limpios AS (
    SELECT [Order Quantity],
           CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL) AS Unit_Cost,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price
    FROM US_Regional_Sales_data
                       )
SELECT ROUND(SUM([Order Quantity] * Unit_Price), 2) AS Ingreso_total,
       ROUND(SUM([Order Quantity] * Unit_Cost), 2) AS Costo_total,
       ROUND(SUM([Order Quantity] * Unit_Price) - SUM([Order Quantity] * Unit_Cost), 2) AS Ganancia
FROM datos_limpios

-- Ingreso: $82.6M | Costo: $51.8M | Ganancia: $30.8M
-- Margen de ganancia: 37.3%
-- Técnica: CTE + REPLACE para limpiar columnas de texto


-- PREGUNTA 2: Ingresos y rentabilidad por canal de ventas

WITH datos_limpios AS (
    SELECT [Order Quantity],
	   [Sales Channel],
           CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL) AS Unit_Cost,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price
    FROM US_Regional_Sales_data
                       )
SELECT [Sales Channel],
       ROUND(SUM([Order Quantity] * Unit_Price), 2) AS Ingreso_total,
       ROUND(SUM([Order Quantity] * Unit_Cost), 2) AS Costo_total,
       ROUND(SUM([Order Quantity] * Unit_Price) - SUM([Order Quantity] * Unit_Cost), 2) AS Ganancia,
       ROUND((SUM([Order Quantity] * Unit_Price) - SUM([Order Quantity] * Unit_Cost)) * 100 / SUM([Order Quantity] * Unit_Price),2) AS Margen_ganancia
FROM datos_limpios
GROUP BY [Sales Channel]
ORDER BY Ingreso_total DESC

-- Resultado: In-Store lidera en ingresos ($34M)
-- Wholesale tiene el mejor margen (38.13%) con menores ingresos
-- Insight: mayor volumen no siempre significa mayor rentabilidad
-- Conclusión: Wholesale es el canal más eficiente por unidad vendida
-- Recomendación: analizar si escalar Wholesale aumentaría la rentabilidad global sin aumentar costos proporcionalmente


-- PREGUNTA 3: Volumen e ingresos por bodega

WITH datos_limpios AS (
    SELECT WarehouseCode,
	   [Order Quantity],
	   OrderNumber,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price
    FROM US_Regional_Sales_data
                      )
SELECT WarehouseCode,
       COUNT(OrderNumber) AS Total_ordenes,
       SUM([Order Quantity]) AS Total_unidades,
       ROUND(SUM([Order Quantity] * Unit_Price), 2) AS Ingreso_total
FROM datos_limpios
GROUP BY WarehouseCode
ORDER BY Total_ordenes DESC

-- Resultado: WARE-NMK1003 lidera con 2505 órdenes y $26M
-- Insight: relación directamente proporcional entre órdenes e ingresos - bodegas con mix de productos similar
-- Conclusión: WARE-NMK1003 es la operación más crítica
-- Recomendación: priorizar capacidad y eficiencia en NMK1003


-- PREGUNTA 4: Tiempo promedio de entrega por canal

SELECT [Sales Channel],
       ROUND(AVG(
           JULIANDAY(
               SUBSTR(DeliveryDate, -4) || '-' ||
               PRINTF('%02d', CAST(SUBSTR(DeliveryDate, INSTR(DeliveryDate,'/')+1, 
                      INSTR(SUBSTR(DeliveryDate, INSTR(DeliveryDate,'/')+1),'/') -1) AS INTEGER)) || '-' ||
               PRINTF('%02d', CAST(SUBSTR(DeliveryDate, 1, INSTR(DeliveryDate,'/')-1) AS INTEGER))
           ) -
           JULIANDAY(
               SUBSTR(OrderDate, -4) || '-' ||
               PRINTF('%02d', CAST(SUBSTR(OrderDate, INSTR(OrderDate,'/')+1,
                      INSTR(SUBSTR(OrderDate, INSTR(OrderDate,'/')+1),'/') -1) AS INTEGER)) || '-' ||
               PRINTF('%02d', CAST(SUBSTR(OrderDate, 1, INSTR(OrderDate,'/')-1) AS INTEGER))
           )
       ), 2) AS Promedio_dias_entrega
FROM US_Regional_Sales_data
GROUP BY [Sales Channel]
ORDER BY Promedio_dias_entrega ASC

-- Resultado: Wholesale 25 días | Online 25.76 | In-Store 25.91 | Distributor 26.06
-- Insight: Wholesale es el canal más rápido Y más rentable
-- Conclusión: Wholesale es el canal más eficiente del negocio
-- Recomendación: estudiar las prácticas de Wholesale para replicarlas en otros canales


-- PREGUNTA 5: Top 10 productos por margen de ganancia

WITH datos_limpios AS (
    SELECT [Order Quantity],
	       _ProductID,
           CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL) AS Unit_Cost,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price
    FROM US_Regional_Sales_data
                       )
SELECT _ProductID,
       ROUND(SUM([Order Quantity] * Unit_Price), 2) AS Ingreso_total,
       ROUND(SUM([Order Quantity] * Unit_Cost), 2) AS Costo_total,
       ROUND(SUM([Order Quantity] * Unit_Price) - SUM([Order Quantity] * Unit_Cost), 2) AS Ganancia,
       ROUND((SUM([Order Quantity] * Unit_Price) - SUM([Order Quantity] * Unit_Cost)) * 100 / SUM([Order Quantity] * Unit_Price),2) AS Margen_ganancia
FROM datos_limpios
GROUP BY _ProductID
ORDER BY Margen_ganancia DESC
LIMIT 10;

-- Resultado: Producto ID 8 tiene el mayor margen
-- Técnica: CTE + cálculo de margen por producto
-- Conclusión: identificar los productos más rentables permite priorizar inventario y estrategia comercial


-- PREGUNTA 6: Clasificación de órdenes por tamaño

WITH datos_limpios AS (
    SELECT [Order Quantity],
	   OrderNumber,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price
    FROM US_Regional_Sales_data
                      )
SELECT CASE WHEN [Order Quantity] < 20 THEN 'Small'
       WHEN [Order Quantity] BETWEEN 20 AND 50 THEN 'Medium'
                                               ELSE 'Large'
       END AS Clasificacion,
       COUNT(OrderNumber) AS Total_ordenes,
       SUM([Order Quantity]) AS Total_unidades,
       ROUND(SUM([Order Quantity] * Unit_Price), 2) AS Ingreso_total
FROM datos_limpios
GROUP BY Clasificacion
ORDER BY Ingreso_total DESC

-- Resultado: 100% de las órdenes son Small (< 20 unidades)
-- Promedio por orden: 36162 / 7991 = ~4.5 unidades por orden
-- Insight: el negocio opera con órdenes pequeñas y frecuentes
-- Conclusión: estrategia de alto volumen con pedidos pequeños
-- Recomendación: evaluar incentivos para aumentar el tamaño promedio de orden y reducir costos logísticos por unidad


-- PREGUNTA 7: Costo operativo por bodega

WITH datos_limpios AS (
    SELECT [Order Quantity],
	       WarehouseCode,
           CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL) AS Unit_Cost
    FROM US_Regional_Sales_data
                       )
SELECT WarehouseCode,
       ROUND(SUM([Order Quantity] * Unit_Cost), 2) AS Costo_total,
       ROUND((SUM([Order Quantity] * Unit_Cost)) * 100 / (SELECT SUM([Order Quantity] * Unit_Cost)FROM datos_limpios),2) AS Porcentaje_costo_global
FROM datos_limpios
GROUP BY WarehouseCode
ORDER BY Costo_total DESC

-- Resultado: WARE-NMK1003 lidera con $16.3M (31.56% del total)
-- Insight: relación directamente proporcional entre costo e ingresos por bodega
-- Conclusión: NMK1003 es la operación más crítica del negocio
-- Recomendación: optimizar eficiencia en NMK1003 tiene el mayor impacto potencial en la rentabilidad global


-- PREGUNTA 8: Top 3 productos más rentables por canal

WITH datos_limpios AS (
    SELECT [Order Quantity],
	       _ProductID,
		   [Sales Channel],
           CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL) AS Unit_Cost,
           CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL) AS Unit_Price,
           ROUND(SUM([Order Quantity] * CAST(REPLACE(REPLACE([Unit Price], '$', ''), ',', '') AS REAL)) - 
                 SUM([Order Quantity] * CAST(REPLACE(REPLACE([Unit Cost], '$', ''), ',', '') AS REAL)), 2) AS Ganancia
    FROM US_Regional_Sales_data
    GROUP BY [Sales Channel], _ProductID
                       ),
 Ranking_productos AS (
   	 SELECT [Sales Channel],
                _ProductID,
		Ganancia,
		RANK() OVER(PARTITION BY [Sales Channel]
			    ORDER BY Ganancia DESC) AS Ranking
	 FROM datos_limpios
                       )
SELECT *
FROM Ranking_productos
WHERE Ranking <= 3
ORDER BY [Sales Channel], Ranking

-- Técnica: CTEs encadenados + RANK() + PARTITION BY
-- Resultado: Distributor: productos 41, 35, 25
              In-Store: productos 23, 4, 40
              Online: productos 12, 18, 23
              Wholesale: productos 26, 4, 14
-- Insight: Producto 23 aparece en top 3 de In-Store y Online
            Producto 4 aparece en top 3 de In-Store y Wholesale
-- Conclusión: productos 23 y 4 son los más versátiles y rentables del portafolio, priorizar su disponibilidad