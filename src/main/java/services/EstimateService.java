/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package services;
import entities.Estimate;
import entities.EstimateItem;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import repositories.EstimateItemRepository;
import repositories.EstimateRepository;
/**
 *
 * @author Gastón Uriel Fernández
 */
@Service
public class EstimateService {
    private final EstimateRepository estimateRepository;
    private final EstimateItemRepository estimateItemRepository;
    
public EstimateService(
            EstimateRepository estimateRepository,
            EstimateItemRepository estimateItemRepository) {
        this.estimateRepository = estimateRepository;
        this.estimateItemRepository = estimateItemRepository;
    }
    @Transactional
    public Estimate recalculateEstimate(Long estimateId) {
        Estimate estimate = estimateRepository.findById(estimateId)
                .orElseThrow(() -> new IllegalArgumentException("No existe la estimación con id: " + estimateId));

        // TODO 1: Obtener los ítems de esta estimación desde estimateItemRepository
        List<EstimateItem> items = estimateItemRepository.findByEstimateId(estimateId);

        BigDecimal totalHours = BigDecimal.ZERO;
        BigDecimal totalCost = BigDecimal.ZERO;
        BigDecimal marginPercentage = estimate.getMargin_porcentage() != null
        ? estimate.getMargin_porcentage()
        : BigDecimal.ZERO;
        BigDecimal appliedDiscount = estimate.getApplied_discount() != null
        ? estimate.getApplied_discount()
        : BigDecimal.ZERO;
        BigDecimal finalPrice = BigDecimal.ZERO;
        
        for (EstimateItem item : items) {
            BigDecimal hours = item.getEstimatedHours() != null ? item.getEstimatedHours() : BigDecimal.ZERO;
            BigDecimal hourlyCost = item.getAppliedHourlyCost() != null ? item.getAppliedHourlyCost() : BigDecimal.ZERO;
            totalHours = totalHours.add(hours);
            totalCost = totalCost.add(hours.multiply(hourlyCost));
            
        }
        if (marginPercentage.compareTo(BigDecimal.ZERO) < 0 || appliedDiscount.compareTo(BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Error.");
        else{
            BigDecimal conMargen1 = BigDecimal.ONE.add(marginPercentage.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
            BigDecimal conMargen2 = BigDecimal.ONE.subtract(appliedDiscount.divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
            finalPrice = totalCost.multiply(conMargen1).multiply(conMargen2);
        }
        estimate.setTotalHours(totalHours.setScale(2, RoundingMode.HALF_UP));
        estimate.setTotalCost(totalCost.setScale(2, RoundingMode.HALF_UP));
        estimate.setFinal_price(finalPrice.setScale(2, RoundingMode.HALF_UP));

        return estimateRepository.save(estimate);
        
        }
}