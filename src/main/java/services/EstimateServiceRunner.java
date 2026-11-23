/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package services;

import entities.Estimate;
import entities.EstimateItem;
import java.lang.reflect.Proxy;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import repositories.EstimateItemRepository;
import repositories.EstimateRepository;

/**
 * Prueba manual rápida de {@link EstimateService} usando proxies para repositorios Spring Data.
 *
 * @author Gastón Uriel Fernández
 */
public class EstimateServiceRunner {

    public static void main(String[] args) {
        testRecalculateWithItemsMarginAndDiscount();
        testEstimateNotFoundThrowsException();
        testNegativeMarginThrowsException();
        testEmptyItemsSetsZeroTotals();

        System.out.println("========================================");
        System.out.println("Todas las pruebas manuales pasaron OK.");
    }

    private static void testRecalculateWithItemsMarginAndDiscount() {
        Map<Long, Estimate> store = new HashMap<>();
        Estimate estimate = new Estimate();
        estimate.setMargin_porcentage(new BigDecimal("20.00"));
        estimate.setApplied_discount(new BigDecimal("10.00"));
        store.put(1L, estimate);

        List<EstimateItem> items = List.of(
                buildItem(new BigDecimal("10.00"), new BigDecimal("25.00")), // 250.00
                buildItem(new BigDecimal("5.00"), new BigDecimal("40.00"))   // 200.00
        );

        EstimateService service = new EstimateService(
                createEstimateRepoProxy(store),
                createItemRepoProxy(items)
        );

        Estimate result = service.recalculateEstimate(1L);

        assertBigDecimalEquals(new BigDecimal("15.00"), result.getTotalHours(), "totalHours");
        assertBigDecimalEquals(new BigDecimal("450.00"), result.getTotalCost(), "totalCost");
        assertBigDecimalEquals(new BigDecimal("486.00"), result.getFinal_price(), "final_price");

        System.out.println("[PASS] Flujo normal -> horas: " + result.getTotalHours()
                + " | costo: " + result.getTotalCost()
                + " | precio final: " + result.getFinal_price());
    }

    private static void testEstimateNotFoundThrowsException() {
        EstimateService service = new EstimateService(
                createEstimateRepoProxy(new HashMap<>()),
                createItemRepoProxy(List.of())
        );

        try {
            service.recalculateEstimate(999L);
            throw new AssertionError("Se esperaba IllegalArgumentException por estimación inexistente");
        } catch (IllegalArgumentException ex) {
            System.out.println("[PASS] Estimación inexistente lanzó excepción: " + ex.getMessage());
        }
    }

    private static void testNegativeMarginThrowsException() {
        Map<Long, Estimate> store = new HashMap<>();
        Estimate estimate = new Estimate();
        estimate.setMargin_porcentage(new BigDecimal("-10.00"));
        estimate.setApplied_discount(BigDecimal.ZERO);
        store.put(2L, estimate);

        EstimateService service = new EstimateService(
                createEstimateRepoProxy(store),
                createItemRepoProxy(List.of())
        );

        try {
            service.recalculateEstimate(2L);
            throw new AssertionError("Se esperaba IllegalArgumentException por margen negativo");
        } catch (IllegalArgumentException ex) {
            System.out.println("[PASS] Margen negativo lanzó excepción: " + ex.getMessage());
        }
    }

    private static void testEmptyItemsSetsZeroTotals() {
        Map<Long, Estimate> store = new HashMap<>();
        Estimate estimate = new Estimate();
        estimate.setMargin_porcentage(new BigDecimal("15.00"));
        estimate.setApplied_discount(BigDecimal.ZERO);
        store.put(3L, estimate);

        EstimateService service = new EstimateService(
                createEstimateRepoProxy(store),
                createItemRepoProxy(List.of())
        );

        Estimate result = service.recalculateEstimate(3L);

        assertBigDecimalEquals(new BigDecimal("0.00"), result.getTotalHours(), "totalHours vacío");
        assertBigDecimalEquals(new BigDecimal("0.00"), result.getTotalCost(), "totalCost vacío");
        assertBigDecimalEquals(new BigDecimal("0.00"), result.getFinal_price(), "final_price vacío");

        System.out.println("[PASS] Sin ítems -> totales en 0.00");
    }

    private static EstimateItem buildItem(BigDecimal hours, BigDecimal hourlyCost) {
        EstimateItem item = new EstimateItem();
        item.setEstimatedHours(hours);
        item.setAppliedHourlyCost(hourlyCost);
        return item;
    }

    private static void assertBigDecimalEquals(BigDecimal expected, BigDecimal actual, String fieldName) {
        if (actual == null || expected.compareTo(actual) != 0) {
            throw new AssertionError("Fallo en " + fieldName + " -> esperado: " + expected + ", obtenido: " + actual);
        }
    }

    private static EstimateRepository createEstimateRepoProxy(Map<Long, Estimate> store) {
        return (EstimateRepository) Proxy.newProxyInstance(
                EstimateRepository.class.getClassLoader(),
                new Class<?>[]{EstimateRepository.class},
                (proxy, method, args) -> {
                    String name = method.getName();
                    if ("findById".equals(name) && args != null && args.length == 1) {
                        return Optional.ofNullable(store.get(args[0]));
                    }
                    if ("save".equals(name) && args != null && args.length == 1) {
                        Estimate entity = (Estimate) args[0];
                        store.putIfAbsent(1L, entity);
                        return entity;
                    }
                    return null;
                }
        );
    }

    private static EstimateItemRepository createItemRepoProxy(List<EstimateItem> items) {
        return (EstimateItemRepository) Proxy.newProxyInstance(
                EstimateItemRepository.class.getClassLoader(),
                new Class<?>[]{EstimateItemRepository.class},
                (proxy, method, args) -> {
                    if ("findByEstimateId".equals(method.getName())) {
                        return items;
                    }
                    return List.of();
                }
        );
    }
}
