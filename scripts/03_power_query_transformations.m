let
    // Load Cleaned Supply Chain Inventory CSV
    Source = Csv.Document(File.Contents("C:\GitHub\Supply-Chain-Inventory-Optimization-PowerBI\data\cleaned_inventory_optimization.csv"),[Delimiter=",", Columns=24, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    ChangedTypes = Table.TransformColumnTypes(PromotedHeaders,{
        {"SKU_ID", type text},
        {"Category", type text},
        {"Warehouse", type text},
        {"Supplier", type text},
        {"Unit_Cost_USD", Currency.Type},
        {"Annual_Demand_Units", Int64.Type},
        {"Avg_Daily_Demand", type number},
        {"Std_Daily_Demand", type number},
        {"Lead_Time_Days", Int64.Type},
        {"Std_Lead_Time_Days", type number},
        {"Ordering_Cost_USD", Currency.Type},
        {"Holding_Cost_Pct", Percentage.Type},
        {"Holding_Cost_Per_Unit_USD", Currency.Type},
        {"Service_Level_Z", type number},
        {"On_Hand_Qty", Int64.Type},
        {"On_Order_Qty", Int64.Type},
        {"Annual_Consumption_Value_USD", Currency.Type},
        {"Inventory_Value_USD", Currency.Type},
        {"Safety_Stock_Units", Int64.Type},
        {"Reorder_Point_Units", Int64.Type},
        {"EOQ_Units", Int64.Type},
        {"Max_Stock_Level", Int64.Type},
        {"Days_of_Inventory_On_Hand", type number},
        {"Annual_Holding_Cost_USD", Currency.Type},
        {"Cumulative_Consumption_Pct", Percentage.Type},
        {"ABC_Class", type text},
        {"Stock_Health_Status", type text}
    }),
    // Add Custom Column for Reorder Priority Flag
    AddedReorderFlag = Table.AddColumn(ChangedTypes, "Reorder_Action_Required", each if [On_Hand_Qty] <= [Reorder_Point_Units] then "Action Required" else "Sufficient Stock", type text)
in
    AddedReorderFlag
