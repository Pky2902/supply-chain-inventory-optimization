# Power BI Setup & Build Guide

This folder includes:
1. **`SupplyChain_Dark_Theme.json`**: Import directly into Power BI Desktop via **View -> Themes -> Browse for themes** to apply the exact dark slate executive styling (`#0F172A` canvas, `#1E293B` cards, and status colors).
2. **`Supply_Chain_Inventory_Optimization.pbip` & `SemanticModel/`**: Power BI Project source files containing the TMDL table and DAX definitions for Git version control.

## Quick 3-Minute Setup in Power BI Desktop
1. Open **Power BI Desktop** -> Click **Get Data** -> **Text/CSV** -> Select `data/cleaned_inventory_optimization.csv` and click **Load** (rename the table to `Inventory`).
2. Go to **View** -> **Themes** -> **Browse for themes** and load `powerbi/SupplyChain_Dark_Theme.json`.
3. Copy the measures from `scripts/04_dax_measures.dax` into your `Inventory` table (or use the Tabular Editor / TMDL view).
4. Add visuals matching the 3 pages shown in `assets/`:
   - **Page 1**: Executive Inventory Overview (KPI Cards, Stock Health Bar Chart, Stacked Bar by Warehouse & ABC Tier).
   - **Page 2**: Stockout & Reorder Alerts (Scatter plot of `Lead_Time_Days` vs `Days_of_Inventory_On_Hand`, Stacked Bar of Capital by Category).
   - **Page 3**: Supplier Lead Time Performance (Average Lead Time by Supplier, Annual Holding Cost by Category).
