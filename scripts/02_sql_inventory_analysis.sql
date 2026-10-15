-- ============================================================================
-- SUPPLY CHAIN INVENTORY OPTIMIZATION - SQL ANALYTICAL QUERIES
-- ============================================================================

-- 1. Executive Warehouse Summary: Inventory Valuation, Carrying Cost & Stockout Risk
SELECT 
    Warehouse,
    COUNT(SKU_ID) AS Total_SKUs,
    ROUND(SUM(Inventory_Value_USD), 2) AS Total_Inventory_Value_USD,
    ROUND(SUM(Annual_Holding_Cost_USD), 2) AS Annual_Carrying_Cost_USD,
    SUM(CASE WHEN On_Hand_Qty = 0 THEN 1 ELSE 0 END) AS Stockout_SKUs,
    SUM(CASE WHEN On_Hand_Qty <= Reorder_Point_Units THEN 1 ELSE 0 END) AS SKUs_Needing_Reorder
FROM cleaned_inventory_optimization
GROUP BY Warehouse
ORDER BY Total_Inventory_Value_USD DESC;

-- 2. ABC Pareto Classification Breakdown
SELECT 
    ABC_Class,
    COUNT(SKU_ID) AS SKU_Count,
    ROUND(COUNT(SKU_ID) * 100.0 / (SELECT COUNT(*) FROM cleaned_inventory_optimization), 2) AS Pct_of_Total_SKUs,
    ROUND(SUM(Annual_Consumption_Value_USD), 2) AS Total_Annual_Consumption_USD,
    ROUND(SUM(Inventory_Value_USD), 2) AS Current_On_Hand_Value_USD
FROM cleaned_inventory_optimization
GROUP BY ABC_Class
ORDER BY ABC_Class;

-- 3. Critical Reorder Alert List (Class A Items Below Safety Stock)
SELECT 
    SKU_ID,
    Category,
    Warehouse,
    Supplier,
    On_Hand_Qty,
    Safety_Stock_Units,
    Reorder_Point_Units,
    EOQ_Units AS Recommended_Order_Qty,
    Lead_Time_Days
FROM cleaned_inventory_optimization
WHERE ABC_Class = 'Class A (High Value)'
  AND On_Hand_Qty <= Safety_Stock_Units
ORDER BY Annual_Consumption_Value_USD DESC;

-- 4. Working Capital Trapped in Excess / Overstock Inventory
SELECT 
    Category,
    COUNT(SKU_ID) AS Overstocked_SKUs,
    SUM(On_Hand_Qty - Max_Stock_Level) AS Excess_Units,
    ROUND(SUM((On_Hand_Qty - Max_Stock_Level) * Unit_Cost_USD), 2) AS Trapped_Working_Capital_USD
FROM cleaned_inventory_optimization
WHERE On_Hand_Qty > Max_Stock_Level
GROUP BY Category
ORDER BY Trapped_Working_Capital_USD DESC;
