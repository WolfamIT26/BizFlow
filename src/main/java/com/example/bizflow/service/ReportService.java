package com.example.bizflow.service;

import com.example.bizflow.dto.LowStockAlertDTO;
import com.example.bizflow.dto.RevenueReportDTO;
import com.example.bizflow.dto.TopProductDTO;
import com.example.bizflow.entity.Order;
import com.example.bizflow.entity.OrderItem;
import com.example.bizflow.entity.Product;
import com.example.bizflow.entity.ProductCost;
import com.example.bizflow.entity.InventoryStock;
import com.example.bizflow.entity.InventoryTransaction;
import com.example.bizflow.entity.InventoryTransactionType;
import com.example.bizflow.repository.OrderRepository;
import com.example.bizflow.repository.ProductRepository;
import com.example.bizflow.repository.ProductCostRepository;
import com.example.bizflow.repository.InventoryStockRepository;
import com.example.bizflow.repository.InventoryTransactionRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ReportService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ProductCostRepository productCostRepository;
    private final InventoryStockRepository inventoryStockRepository;
    private final InventoryTransactionRepository inventoryTransactionRepository;

    private static final int DEFAULT_LOW_STOCK_THRESHOLD = 10;
    private static final int CRITICAL_STOCK_THRESHOLD = 5;

    // Cache giá vốn để tránh query nhiều lần
    private Map<Long, BigDecimal> costPriceCache = new HashMap<>();

    public ReportService(OrderRepository orderRepository,
            ProductRepository productRepository,
            ProductCostRepository productCostRepository,
            InventoryStockRepository inventoryStockRepository,
            InventoryTransactionRepository inventoryTransactionRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.productCostRepository = productCostRepository;
        this.inventoryStockRepository = inventoryStockRepository;
        this.inventoryTransactionRepository = inventoryTransactionRepository;
    }

    /**
     * Lấy giá vốn của sản phẩm - ưu tiên từ product_costs, fallback về products
     */
    private BigDecimal getCostPrice(Long productId, Product product) {
        // Kiểm tra cache trước
        if (costPriceCache.containsKey(productId)) {
            return costPriceCache.get(productId);
        }

        // Ưu tiên lấy từ bảng product_costs
        BigDecimal costPrice = productCostRepository.findByProductId(productId)
                .map(ProductCost::getCostPrice)
                .orElse(null);

        // Fallback về bảng products nếu không có trong product_costs
        if (costPrice == null && product != null) {
            costPrice = product.getCostPrice();
        }

        // Cache kết quả
        if (costPrice != null) {
            costPriceCache.put(productId, costPrice);
        }

        return costPrice != null ? costPrice : BigDecimal.ZERO;
    }

    /**
     * Xóa cache giá vốn (gọi khi cần refresh)
     */
    public void clearCostPriceCache() {
        costPriceCache.clear();
    }

    /**
     * Báo cáo doanh thu theo khoảng thời gian
     */
    public RevenueReportDTO getRevenueReport(LocalDate startDate, LocalDate endDate, String period) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);

        List<Order> orders = orderRepository.searchOrders(null, startDateTime, endDateTime);

        // Chỉ tính các đơn PAID
        List<Order> paidOrders = orders.stream()
                .filter(o -> "PAID".equalsIgnoreCase(o.getStatus()))
                .filter(o -> !Boolean.TRUE.equals(o.getReturnOrder()))
                .collect(Collectors.toList());

        RevenueReportDTO report = new RevenueReportDTO();
        report.setPeriod(period);
        report.setStartDate(startDate.format(DateTimeFormatter.ISO_DATE));
        report.setEndDate(endDate.format(DateTimeFormatter.ISO_DATE));
        report.setTotalOrders(paidOrders.size());

        BigDecimal totalRevenue = BigDecimal.ZERO;
        BigDecimal totalCost = BigDecimal.ZERO;
        long totalItemsSold = 0;

        // Group by date for breakdown
        Map<LocalDate, List<Order>> ordersByDate = paidOrders.stream()
                .filter(o -> o.getCreatedAt() != null)
                .collect(Collectors.groupingBy(o -> o.getCreatedAt().toLocalDate()));

        List<RevenueReportDTO.DailyRevenueItem> dailyBreakdown = new ArrayList<>();

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            List<Order> dayOrders = ordersByDate.getOrDefault(date, Collections.emptyList());

            BigDecimal dayRevenue = BigDecimal.ZERO;
            BigDecimal dayCost = BigDecimal.ZERO;

            for (Order order : dayOrders) {
                dayRevenue = dayRevenue.add(order.getTotalAmount() != null ? order.getTotalAmount() : BigDecimal.ZERO);

                // Tính cost từ order items - lấy giá vốn từ product_costs
                if (order.getItems() != null) {
                    for (OrderItem item : order.getItems()) {
                        totalItemsSold += item.getQuantity();
                        if (item.getProduct() != null) {
                            Long productId = item.getProduct().getId();
                            BigDecimal costPrice = getCostPrice(productId, item.getProduct());
                            BigDecimal itemCost = costPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                            dayCost = dayCost.add(itemCost);
                        }
                    }
                }
            }

            totalRevenue = totalRevenue.add(dayRevenue);
            totalCost = totalCost.add(dayCost);

            BigDecimal dayProfit = dayRevenue.subtract(dayCost);
            
            // Tính biên lợi nhuận cho ngày
            BigDecimal dayMargin = BigDecimal.ZERO;
            if (dayRevenue.compareTo(BigDecimal.ZERO) > 0) {
                dayMargin = dayProfit.multiply(BigDecimal.valueOf(100))
                        .divide(dayRevenue, 2, RoundingMode.HALF_UP);
            }
            
            dailyBreakdown.add(new RevenueReportDTO.DailyRevenueItem(
                    date.format(DateTimeFormatter.ISO_DATE),
                    dayRevenue,
                    dayCost,
                    dayProfit,
                    dayMargin,
                    dayOrders.size()
            ));
        }

        report.setTotalRevenue(totalRevenue);
        report.setTotalCost(totalCost);
        report.setGrossProfit(totalRevenue.subtract(totalCost));
        report.setTotalItemsSold(totalItemsSold);
        report.setDailyBreakdown(dailyBreakdown);

        // Tính profit margin
        if (totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal margin = report.getGrossProfit()
                    .multiply(BigDecimal.valueOf(100))
                    .divide(totalRevenue, 2, RoundingMode.HALF_UP);
            report.setProfitMargin(margin);
        } else {
            report.setProfitMargin(BigDecimal.ZERO);
        }

        return report;
    }

    /**
     * Báo cáo doanh thu hôm nay
     */
    public RevenueReportDTO getTodayRevenue() {
        LocalDate today = LocalDate.now();
        return getRevenueReport(today, today, "daily");
    }

    /**
     * Báo cáo doanh thu tuần này
     */
    public RevenueReportDTO getWeeklyRevenue() {
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.minusDays(today.getDayOfWeek().getValue() - 1);
        return getRevenueReport(startOfWeek, today, "weekly");
    }

    /**
     * Báo cáo doanh thu tháng này
     */
    public RevenueReportDTO getMonthlyRevenue() {
        LocalDate today = LocalDate.now();
        LocalDate startOfMonth = today.withDayOfMonth(1);
        return getRevenueReport(startOfMonth, today, "monthly");
    }

    /**
     * So sánh doanh thu với kỳ trước
     * Trả về % thay đổi: (current - previous) / previous * 100
     */
    public Map<String, Object> getRevenueComparison() {
        Map<String, Object> comparison = new HashMap<>();
        
        // === HÔM NAY vs HÔM QUA ===
        LocalDate today = LocalDate.now();
        LocalDate yesterday = today.minusDays(1);
        
        RevenueReportDTO todayReport = getRevenueReport(today, today, "daily");
        RevenueReportDTO yesterdayReport = getRevenueReport(yesterday, yesterday, "daily");
        
        comparison.put("todayRevenue", todayReport.getTotalRevenue());
        comparison.put("todayOrders", todayReport.getTotalOrders());
        comparison.put("todayProfit", todayReport.getGrossProfit());
        comparison.put("todayMargin", todayReport.getProfitMargin());
        comparison.put("todayChange", calculatePercentChange(
                yesterdayReport.getTotalRevenue(), todayReport.getTotalRevenue()));
        
        // === TUẦN NÀY vs TUẦN TRƯỚC ===
        LocalDate startOfWeek = today.minusDays(today.getDayOfWeek().getValue() - 1);
        LocalDate endOfLastWeek = startOfWeek.minusDays(1);
        LocalDate startOfLastWeek = endOfLastWeek.minusDays(6);
        
        RevenueReportDTO thisWeekReport = getRevenueReport(startOfWeek, today, "weekly");
        RevenueReportDTO lastWeekReport = getRevenueReport(startOfLastWeek, endOfLastWeek, "weekly");
        
        comparison.put("weeklyRevenue", thisWeekReport.getTotalRevenue());
        comparison.put("weeklyOrders", thisWeekReport.getTotalOrders());
        comparison.put("weeklyProfit", thisWeekReport.getGrossProfit());
        comparison.put("weeklyMargin", thisWeekReport.getProfitMargin());
        comparison.put("weeklyChange", calculatePercentChange(
                lastWeekReport.getTotalRevenue(), thisWeekReport.getTotalRevenue()));
        
        // === THÁNG NÀY vs THÁNG TRƯỚC (CÙNG SỐ NGÀY) ===
        LocalDate startOfMonth = today.withDayOfMonth(1);
        int daysInCurrentPeriod = today.getDayOfMonth();
        LocalDate startOfLastMonth = startOfMonth.minusMonths(1);
        LocalDate endOfLastMonthPeriod = startOfLastMonth.plusDays(daysInCurrentPeriod - 1);
        
        RevenueReportDTO thisMonthReport = getRevenueReport(startOfMonth, today, "monthly");
        RevenueReportDTO lastMonthReport = getRevenueReport(startOfLastMonth, endOfLastMonthPeriod, "monthly");
        
        comparison.put("monthlyRevenue", thisMonthReport.getTotalRevenue());
        comparison.put("monthlyOrders", thisMonthReport.getTotalOrders());
        comparison.put("monthlyProfit", thisMonthReport.getGrossProfit());
        comparison.put("monthlyMargin", thisMonthReport.getProfitMargin());
        comparison.put("monthlyChange", calculatePercentChange(
                lastMonthReport.getTotalRevenue(), thisMonthReport.getTotalRevenue()));
        
        // Margin change
        comparison.put("marginChange", calculateMarginChange(
                lastMonthReport.getProfitMargin(), thisMonthReport.getProfitMargin()));
        
        return comparison;
    }
    
    private BigDecimal calculatePercentChange(BigDecimal previous, BigDecimal current) {
        if (previous == null || previous.compareTo(BigDecimal.ZERO) == 0) {
            if (current != null && current.compareTo(BigDecimal.ZERO) > 0) {
                return BigDecimal.valueOf(100); // 100% increase from 0
            }
            return BigDecimal.ZERO;
        }
        return current.subtract(previous)
                .multiply(BigDecimal.valueOf(100))
                .divide(previous, 1, RoundingMode.HALF_UP);
    }
    
    private BigDecimal calculateMarginChange(BigDecimal previousMargin, BigDecimal currentMargin) {
        if (previousMargin == null) previousMargin = BigDecimal.ZERO;
        if (currentMargin == null) currentMargin = BigDecimal.ZERO;
        return currentMargin.subtract(previousMargin).setScale(1, RoundingMode.HALF_UP);
    }

    /**
     * Top sản phẩm bán chạy
     */
    public List<TopProductDTO> getTopSellingProducts(LocalDate startDate, LocalDate endDate, int limit) {
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);

        List<Order> orders = orderRepository.searchOrders(null, startDateTime, endDateTime);
        List<Order> paidOrders = orders.stream()
                .filter(o -> "PAID".equalsIgnoreCase(o.getStatus()))
                .filter(o -> !Boolean.TRUE.equals(o.getReturnOrder()))
                .collect(Collectors.toList());

        // Aggregate by product
        Map<Long, ProductSalesData> productSales = new HashMap<>();

        for (Order order : paidOrders) {
            if (order.getItems() == null) {
                continue;
            }

            for (OrderItem item : order.getItems()) {
                if (item.getProduct() == null) {
                    continue;
                }

                Product product = item.getProduct();
                Long productId = product.getId();

                ProductSalesData data = productSales.computeIfAbsent(productId,
                        k -> new ProductSalesData(product));

                data.quantitySold += item.getQuantity();
                data.totalRevenue = data.totalRevenue.add(
                        item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));

                // Lấy giá vốn từ product_costs
                BigDecimal costPrice = getCostPrice(productId, product);
                data.totalCost = data.totalCost.add(
                        costPrice.multiply(BigDecimal.valueOf(item.getQuantity())));
            }
        }

        // Convert to DTO and sort by quantity sold
        return productSales.values().stream()
                .map(data -> {
                    Integer currentStock = inventoryStockRepository.findByProductId(data.product.getId())
                            .map(InventoryStock::getStock)
                            .orElse(0);

                    return new TopProductDTO(
                            data.product.getId(),
                            data.product.getName(),
                            data.product.getCode(),
                            data.product.getCategoryId(),
                            data.quantitySold,
                            data.totalRevenue,
                            data.totalCost,
                            data.totalRevenue.subtract(data.totalCost),
                            currentStock
                    );
                })
                .sorted((a, b) -> Long.compare(b.getQuantitySold(), a.getQuantitySold()))
                .limit(limit)
                .collect(Collectors.toList());
    }

    /**
     * Cảnh báo tồn kho thấp
     */
    public List<LowStockAlertDTO> getLowStockAlerts(Integer threshold) {
        int minThreshold = threshold != null ? threshold : DEFAULT_LOW_STOCK_THRESHOLD;

        List<Product> activeProducts = productRepository.findByStatus("active");
        List<LowStockAlertDTO> alerts = new ArrayList<>();

        for (Product product : activeProducts) {
            Integer stock = inventoryStockRepository.findByProductId(product.getId())
                    .map(InventoryStock::getStock)
                    .orElse(0);

            if (stock <= minThreshold) {
                String alertLevel;
                if (stock <= 0) {
                    alertLevel = "CRITICAL";
                } else if (stock <= CRITICAL_STOCK_THRESHOLD) {
                    alertLevel = "CRITICAL";
                } else {
                    alertLevel = "WARNING";
                }

                LowStockAlertDTO alert = new LowStockAlertDTO(
                        product.getId(),
                        product.getName(),
                        product.getCode(),
                        product.getCategoryId(),
                        stock,
                        minThreshold,
                        alertLevel
                );

                // Tìm ngày nhập kho cuối
                List<InventoryTransaction> recentImports = inventoryTransactionRepository
                        .findTop50ByProductIdOrderByCreatedAtDesc(product.getId());
                recentImports.stream()
                        .filter(tx -> tx.getTransactionType() == InventoryTransactionType.IN)
                        .findFirst()
                        .ifPresent(tx -> alert.setLastRestockDate(
                        tx.getCreatedAt().format(DateTimeFormatter.ISO_DATE)));

                alerts.add(alert);
            }
        }

        // Sort by alert level (CRITICAL first) then by stock
        alerts.sort((a, b) -> {
            int levelCompare = getAlertPriority(a.getAlertLevel()) - getAlertPriority(b.getAlertLevel());
            if (levelCompare != 0) {
                return levelCompare;
            }
            return Integer.compare(a.getCurrentStock(), b.getCurrentStock());
        });

        return alerts;
    }

    /**
     * Đếm số sản phẩm cần cảnh báo
     */
    public Map<String, Long> getLowStockSummary(Integer threshold) {
        List<LowStockAlertDTO> alerts = getLowStockAlerts(threshold);

        Map<String, Long> summary = new HashMap<>();
        summary.put("total", (long) alerts.size());
        summary.put("critical", alerts.stream().filter(a -> "CRITICAL".equals(a.getAlertLevel())).count());
        summary.put("warning", alerts.stream().filter(a -> "WARNING".equals(a.getAlertLevel())).count());

        return summary;
    }

    private int getAlertPriority(String level) {
        return switch (level) {
            case "CRITICAL" ->
                0;
            case "WARNING" ->
                1;
            case "LOW" ->
                2;
            default ->
                3;
        };
    }

    private static class ProductSalesData {

        Product product;
        long quantitySold = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;
        BigDecimal totalCost = BigDecimal.ZERO;

        ProductSalesData(Product product) {
            this.product = product;
        }
    }
}
