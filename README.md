# Pizza-Analysis (Phân tích hoạt động kinh doanh cửa hàng Pizza) 🍕

## Introduction (Giới thiệu) 📚

Mục đích cũng chỉ để phân tích 📊 dữ liệu hoạt động kinh doanh của cửa hàng như doanh số, 💰 doanh thu từ đó dự đoán cũng như đưa ra chiến lược, kế hoạch thu hút khách hàng, 📈 tăng doanh số và lợi nhuận 💵

## Problems (Vấn đề) ⁉️

1. Tính tổng sản lượng, doanh thu bánh Pizza theo loại Pizza.
2. Tìm ra thông tin của loại Pizza có giá cao nhất.
3. Tính tổng số lượng Pizza theo kích thước bánh và sắp xếp theo thứ tự giảm dần.
4. Tìm ra Top 5 loại bánh Pizza có sản lượng bán chạy nhất.
5. Tính tổng lượng đơn Order theo từng cột mốc giờ trong ngày.
6. Tính lượng đơn Order và sản lượng Pizza trung bình trong một ngày.
7. Tìm ra Top 3 loại bánh Pizza được có lượng đơn Order nhiều nhất dựa trên doanh thu theo từng tháng
8. Tính % đóng góp doanh thu và doanh số của từng loại Pizza.
9. Tính doanh thu tích lũy theo thời gian.
10. Tìm ra TOP 5 loại Pizza có đơn Order nhiều nhất dựa trên xếp hạng doanh thu của từng theo doanh mục bánh Pizza.

## Tool I Used (Những công cụ sử dụng) 🛠️

- **SQL Server:** Dùng để truy vấn

- **Power BI:** Để trực quan hóa dữ liệu truy vấn dưới dạng bảng biểu, biểu đồ

- **Github:** Đăng những câu truy vấn, file dữ liệu có liên quan đến bài phân tích, nhằm chia sẻ cho mọi người cùng tham khảo, đánh giá

## The Analysis (Phân tích) 📈

1. Tính tổng sản lượng, doanh thu bánh Pizza theo loại Pizza
```sql
SELECT 
  pty.name Name,
  FORMAT(SUM((Quantity * price)),'C') Total_Revenue,
  FORMAT(SUM(Quantity), 'N0') Total_Quantity
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN pizza_types as pty ON pty.pizza_type_id = piz.pizza_type_id
GROUP BY Name
ORDER BY Total_Revenue DESC
```
![Hình 1](Pictures/1.png)

2. Tìm ra thông tin của loại Pizza có giá cao nhất
```sql
SELECT TOP 1
  Name, *
FROM pizzas as piz
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
ORDER BY price DESC
```
![Hình 1](Pictures/2.png)

3. Tính tổng số lượng Pizza theo kích thước bánh và sắp xếp theo thứ tự giảm dần
```sql
SELECT 
  size,
  FORMAT(SUM(quantity),'N0') Number_of_Size
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
GROUP BY size 
ORDER BY sum(quantity) DESC
```
![Hình 1](Pictures/3.png)

4. Tìm ra Top 5 loại bánh Pizza có sản lượng bán chạy nhất
```sql
SELECT TOP 5
  Name,
  FORMAT(SUM(quantity),'N0') Quantity
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id 
JOIN pizza_types as pit ON pit.pizza_type_id = piz.pizza_type_id
GROUP BY name
ORDER BY sum(quantity) DESC
```
![Hình 1](Pictures/4.png)

5. Tính tổng lượng đơn Order theo từng cột mốc giờ trong ngày
```sql
SELECT
  DATETRUNC(HOUR,time) Hour,
  FORMAT(count(order_id),'N0') Number_of_Order 
FROM orders
GROUP BY DATETRUNC(hour,time)
ORDER BY Hour ASC
```
![Hình 1](Pictures/5.png)

6. Tính lượng đơn Order và sản lượng Pizza trung bình trong một ngày
```sql
SELECT
  CAST(AVG(CAST(total_Quantity as float)) as DECIMAL(5,2)) Avg_Quantity_Per_Day,
  CAST(AVG(CAST(Total_orders as float)) as DECIMAL(5,2)) Avg_Orders_Per_Day
FROM 
  (SELECT 
    Date, SUM(quantity) Total_Quantity,
    COUNT(ord.order_id) Total_orders
  FROM orders as ord
  JOIN order_details as odt ON ord.order_id = odt.order_id
  GROUP BY date) as Test1;
```
![Hình 1](Pictures/6.png)

7. Tìm ra Top 3 loại bánh Pizza được có lượng đơn Order nhiều nhất dựa trên doanh thu theo từng tháng
```sql
WITH Table1 as
  (SELECT
  	Name, MONTH(ord.Date) Month_Num,
  	FORMAT(ord.date, 'MMM') Month_text,
  	FORMAT(sum((quantity * price)), 'C0') Total_Revenue,
  	FORMAT(COUNT(ord.order_id), 'N0') Total_Orders,
  	RANK() OVER (PARTITION BY MONTH(ord.Date) ORDER BY MONTH(ord.Date) asc, SUM((quantity * price)) DESC) Rank_Number_Orders
  FROM order_details as odt
  JOIN orders as ord ON odt.order_id = ord.order_id
  JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
  JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
  GROUP BY name, FORMAT(ord.date, 'MMM'), MONTH(ord.Date))
------
SELECT 
  Month_text, Name,
  Total_Orders, Total_Revenue
FROM Table1
WHERE Rank_Number_Orders BETWEEN 1 AND 3
```
![Hình 1](Pictures/7.png)

8. Tính % đóng góp doanh thu và doanh số của từng loại Pizza
```sql
WITH table1 as 
  (SELECT
      SUM( (quantity * price) ) Total_Revenue,
      SUM( Quantity) Total_quantity
  FROM order_details as odt 
  JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id)
SELECT 
  Name, 
  FORMAT(SUM (quantity * price), 'C') Revenue,
  FORMAT((SUM(quantity * price) / (SELECT Total_Revenue FROM table1 )), '#,#.00%') '% Contribution of Revenue',
  FORMAT(SUM(quantity), 'N0') Quantity,
  FORMAT(SUM (CAST (quantity AS float)) / (SELECT Total_quantity FROM Table1), 'P2') '% Contribution of Quantity'
FROM order_details as odt 
JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
JOIN pizza_types as pit ON piz.pizza_type_id = pit.pizza_type_id
GROUP BY name
ORDER BY SUM (quantity * price) DESC, SUM(Quantity) DESC
```
![Hình 1](Pictures/8.png)

9. Tính doanh thu tích lũy theo thời gian
```sql
SELECT 
  Date, Revenue,
  FORMAT(running_total,'C') Running_Total
FROM 
  (SELECT
  	Date, FORMAT(Revenue, 'C') Revenue,
    SUM(revenue) OVER (ORDER BY date ASC) Running_Total
  FROM
    (SELECT
      DATE,
      SUM((quantity * price)) Revenue
    FROM order_details as odt 
    JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
    JOIN orders as ord ON ord.order_id = odt.order_id
    GROUP BY date) as test1
  GROUP BY date, Revenue) as test2
```
![Hình 1](Pictures/9.png)

13. Tìm ra TOP 3 loại Pizza có đơn Order nhiều nhất dựa trên xếp hạng doanh thu của từng theo doanh mục bánh Pizza
```sql
SELECT
  Category, Name,
  FORMAT(Total_Revenue,'C2') Total_Revenue
FROM 
  (SELECT
    Category, Name, Total_Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY Total_revenue desc) Rank
  FROM
    (SELECT 
      Category, Name,
      SUM((quantity * price)) Total_Revenue
    FROM order_details as odt
    JOIN pizzas as piz ON odt.pizza_id = piz.pizza_id
    JOIN orders as ord ON ord.order_id = odt.order_id
    JOIN pizza_types as pit ON pit.pizza_type_id = piz.pizza_type_id
    GROUP BY category, name) as table1
  ) table2
WHERE Rank BETWEEN 1 AND 3
```
![Hình 1](Pictures/10.png)

## Conclusion (Kết luận) 📝

### **Tổng quan**

Trong năm 2015, tổng doanh thu bán pizza mà cửa hàng thu được đạt khoảng 817.86 nghìn USD. Ước tính doanh thu trung bình đạt khoảng 68.16 nghìn USD/tháng.
Tổng Doanh số (sản lượng pizza) bán được ước đạt sấp xỉ khoảng 50 nghìn chiếc bánh pizza (49,574 cái)
Số lượng đơn đặt hàng (số lượng orders) đạt khoảng 21 nghìn đơn (21,350 đơn), qua đó có thể ước tính được trung có khoảng 60 đơn/ngày. Mặt khác, trung bình trên 1 đơn hàng thì gồm 2 chiếc bánh pizza (với mỗi lần khách hàng order thì trung bình khách hàng kêu 2 chiếc bánh pizza/1 lần order)

### **Doanh số**

**- Theo thời gian:** 

Phần lớn biến động doanh trong năm vửa rồi là tương đối biến động không lớn (phần lớn đi ngang) nếu xét theo quý. Khi xét theo tháng thì có sự biến động tăng giảm xen kẻ lẫn nhau trong vòng 2 quý đầu (từ tháng 1 đến tháng 7). Biên động tăng dao động trong khoảng từ 3.5% - 8.5%, còn biên độ giảm dao động trong biên độ khoảng 2.0% - 7.0%. Các tháng tiếp sau đo ghi nhân sự sút giảm liên tục trong quý 3 và có hồi phục khoảng 9.95% trong tháng 11 nhưng lại quay đầu giảm tháng tiếp đó 8.09%

**- Theo dòng sản phẩm và sản phẩm:** 

+ Dòng sản phẩm: 
Dòng bánh Pizza đóng góp doanh thu lớn nhất là loại Classic ghi nhận đạt 220.05 nghìn USD (chiếm 26.91%), tiếp đến là loại Supreme đạt 208.20 nghìn USD (chiếm 25.46%), xếp thứ 3 là loại Chicken đạt 195.92 nghìn USD (chiếm 23.96%) và cuối cùng là loại Veggie đóng góp 193.69 nghìn USD (chiếm 23.68%).
+ Loại sản phẩm:
Có rất nhiều loại sản phẩm pizza khác nhau nhưng chỉ liệt kê 5 loại pizza được bán chạy nhất nhưng được sắp xếp theo doanh thu đóng góp. Doanh thu đóng lớn nhất, đạt khoảng 43.43 nghìn USD (chiếm 21.65%) của The Thei Chicken Pizza, thứ 2 là loại pizza The Barbecue Chicken Pizza đạt khoảng 42.77 nghìn USD (chiếm khoảng 21.32%), xếp thứ 3 là The California Chicken Pizza đạt 41.41 nghìn USD (chiếm 20.64%) và 2 vị trí tiếp theo là The Classic Deluxe Pizza và The Spicy Italian Pizza lần lượng đạt 31.18 nghìn USD (chiếm 19.03%) và 34.83 nghìn USD (chiếm 17.36%).

## Hình ảnh từ file Power BI 📊

![Dashboard](Pictures/Dashboard.png)

![Overview](Pictures/Overview.png)

