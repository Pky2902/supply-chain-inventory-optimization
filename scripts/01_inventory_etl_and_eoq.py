"""
Supply Chain Inventory Optimization - Python ETL & EOQ Engine
Calculates Safety Stock, Reorder Point (ROP), Economic Order Quantity (EOQ),
and ABC Pareto Classification from raw ERP inventory data.
"""
import numpy as np
import pandas as pd

def run_inventory_optimization(input_csv: str, output_csv: str) -> None:
    df = pd.read_csv(input_csv)

    # 1. Safety Stock (accounting for both demand and supplier lead time variability)
    df["Safety_Stock_Units"] = np.ceil(
        df["Service_Level_Z"] * np.sqrt(
            (df["Lead_Time_Days"] * (df["Std_Daily_Demand"] ** 2)) +
            ((df["Avg_Daily_Demand"] * df["Std_Lead_Time_Days"]) ** 2)
        )
    ).astype(int)

    # 2. Reorder Point (ROP)
    df["Reorder_Point_Units"] = np.ceil(
        (df["Avg_Daily_Demand"] * df["Lead_Time_Days"]) + df["Safety_Stock_Units"]
    ).astype(int)

    # 3. Economic Order Quantity (EOQ)
    df["EOQ_Units"] = np.ceil(
        np.sqrt((2 * df["Annual_Demand_Units"] * df["Ordering_Cost_USD"]) / df["Holding_Cost_Per_Unit_USD"])
    ).astype(int)

    # 4. Financial Valuations & ABC Pareto Classification
    df["Annual_Consumption_Value_USD"] = np.round(df["Annual_Demand_Units"] * df["Unit_Cost_USD"], 2)
    df["Inventory_Value_USD"] = np.round(df["On_Hand_Qty"] * df["Unit_Cost_USD"], 2)
    df = df.sort_values(by="Annual_Consumption_Value_USD", ascending=False).reset_index(drop=True)
    df["Cumulative_Consumption_Pct"] = np.round(
        df["Annual_Consumption_Value_USD"].cumsum() / df["Annual_Consumption_Value_USD"].sum(), 4
    )
    df["ABC_Class"] = np.where(
        df["Cumulative_Consumption_Pct"] <= 0.70, "Class A (High Value)",
        np.where(df["Cumulative_Consumption_Pct"] <= 0.90, "Class B (Moderate Value)", "Class C (Low Value)")
    )

    # 5. Inventory Health Classification
    df["Max_Stock_Level"] = df["Reorder_Point_Units"] + df["EOQ_Units"]
    conditions = [
        (df["On_Hand_Qty"] == 0),
        (df["On_Hand_Qty"] > 0) & (df["On_Hand_Qty"] <= df["Safety_Stock_Units"]),
        (df["On_Hand_Qty"] > df["Safety_Stock_Units"]) & (df["On_Hand_Qty"] <= df["Reorder_Point_Units"]),
        (df["On_Hand_Qty"] > df["Max_Stock_Level"])
    ]
    choices = ["1. Stockout (Critical)", "2. Below Safety Stock", "3. Reorder Triggered (Below ROP)", "5. Excess / Overstock"]
    df["Stock_Health_Status"] = np.select(conditions, choices, default="4. Optimal Stock")

    df.to_csv(output_csv, index=False)
    print(f"Processed {len(df)} SKUs successfully -> {output_csv}")

if __name__ == "__main__":
    run_inventory_optimization("../data/raw_supply_chain_inventory.csv", "../data/cleaned_inventory_optimization.csv")
