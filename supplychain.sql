

Drop database logistics;
CREATE DATABASE supplychain;

USE supplychain;

SELECT * 
FROM logiscale_clean_data 
LIMIT 10;
SELECT 
    `Delivery Status`, 
    COUNT(`Order Id`) AS Total_Orders,
    ROUND(COUNT(`Order Id`) * 100.0 / SUM(COUNT(`Order Id`)) OVER(), 2) AS Percentage
FROM logiscale_clean_data
GROUP BY `Delivery Status`
ORDER BY Total_Orders DESC;
SELECT 
    `Product Name`, 
    `Category Name`,
    SUM(`Order Item Quantity`) AS Total_Quantity_Dispatched,
    COUNT(DISTINCT `Order Id`) AS Unique_Orders
FROM logiscale_clean_data
WHERE `Order Status` != 'CANCELED'
GROUP BY `Product Name`, `Category Name`
ORDER BY Total_Quantity_Dispatched DESC;
SELECT 
    `Order Id`,
    `Order City`,
    `Order Country`,
    `Shipping Mode`,
    `Days for shipping (real)` AS ATA,
    `Days for shipment (scheduled)` AS ETA,
    (`Days for shipping (real)` - `Days for shipment (scheduled)`) AS Delivery_Variance,
    CASE 
        WHEN `Days for shipping (real)` > `Days for shipment (scheduled)` THEN 'Late'
        WHEN `Days for shipping (real)` < `Days for shipment (scheduled)` THEN 'Early'
        ELSE 'On-Time'
    END AS Efficiency_Label
FROM logiscale_clean_data
WHERE `Delivery Status` != 'Shipping canceled'
ORDER BY Delivery_Variance DESC;
SELECT 
    `Order Region`,
    AVG(`Days for shipping (real)` - `Days for shipment (scheduled)`) AS Avg_Delay
FROM logiscale_clean_data
GROUP BY `Order Region`
ORDER BY Avg_Delay DESC;
SELECT 
    `Shipping Mode`,
    COUNT(*) AS Total_Orders,
    AVG(`Days for shipping (real)` - `Days for shipment (scheduled)`) AS Avg_Delay
FROM logiscale_clean_data
GROUP BY `Shipping Mode`;
CREATE VIEW clean_supplychain AS
SELECT 
    *,
    (`Days for shipping (real)` - `Days for shipment (scheduled)`) AS Delay
FROM logiscale_clean_data
WHERE `Delivery Status` != 'Shipping canceled';