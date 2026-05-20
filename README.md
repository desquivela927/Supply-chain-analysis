# Supply Chain — Sales Performance Analysis

## Descripción
Análisis de rendimiento de ventas y operaciones logísticas sobre un dataset de 7.991 órdenes de ventas regionales en Estados Unidos. Se respondieron 8 preguntas de negocio usando SQL y se construyó un dashboard ejecutivo en Power BI.

## Herramientas
- SQL (DB Browser for SQLite)
- Power BI Desktop (visualización y DAX)
- Dataset: US Regional Sales Data (Kaggle)

## Preguntas de negocio respondidas
1. Resumen financiero global — ingresos, costos y ganancia
2. Rentabilidad y eficiencia por canal de ventas
3. Volumen e ingresos por bodega
4. Tiempo promedio de entrega por canal
5. Top 10 productos por margen de ganancia
6. Clasificación de órdenes por tamaño
7. Costo operativo por bodega
8. Ranking de productos más rentables por canal

## Principales hallazgos
- Margen de ganancia global del **37.3%** — operación muy saludable
- **Wholesale** es el canal más eficiente — mejor margen y entrega más rápida
- **WARE-NMK1003** concentra el 31.56% del costo operativo total
- **100%** de las órdenes son de tamaño Small — oportunidad de aumentar ticket promedio
- Productos **23 y 4** aparecen en el top 3 de múltiples canales

## Técnicas SQL utilizadas
- CTE + REPLACE + CAST para limpieza de datos
- JULIANDAY para cálculo de días entre fechas
- CASE WHEN para clasificación de órdenes
- Subconsultas para porcentajes del total
- CTEs encadenados + RANK() + PARTITION BY

## Dashboard Power BI
- 4 KPIs ejecutivos (Revenue, Cost, Profit, Margin)
- Análisis por canal de ventas y bodega
- Tabla de rentabilidad por producto
- Filtros interactivos por Sales Channel y Warehouse
- Medidas DAX con SUMX y DIVIDE

## Conexión con experiencia operativa
Este proyecto fue seleccionado por su conexión directa con mi experiencia como Director de Operaciones — analizando volúmenes de órdenes, costos logísticos y eficiencia por canal, conceptos que apliqué en el mundo real gestionando 3.000+ órdenes mensuales en el sector de servicios públicos.

## Autor
Daniel Esquivel — Ingeniero Industrial | Data Analytics  
Bogotá, Colombia — 2026
