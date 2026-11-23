/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package entities;
import jakarta.persistence.*;
import projectEstimator.enums.EstimateEstatus;
import java.math.BigDecimal;
/**
 *
 * @author Gastón Uriel Fernández
 */
    @Entity
    @Table(name = "project_estimates")
    public class Estimate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "project_id", nullable = false)
    private Project project;
    

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Project getProject() {
        return project;
    }

    public void setProject(Project project) {
        this.project = project;
    }

    public EstimateEstatus getStatus() {
        return status;
    }

    public void setStatus(EstimateEstatus status) {
        this.status = status;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EstimateEstatus status;
    
    @Column(name = "total_cost", precision = 12, scale = 2, nullable = false)
    private BigDecimal totalCost;
    
    @Column(name = "total_hours", precision = 8, scale = 2, nullable = false)
    private BigDecimal totalHours;
    
    @Column(name = "margin_porcentage", precision = 5, scale = 2, nullable = false)
    private BigDecimal margin_porcentage;
    
    @Column(name = "applied_discount", precision = 5, scale = 2, nullable = false)
    private BigDecimal applied_discount;
    
    @Column(name = "final_price", precision = 12, scale = 2, nullable = false)
    private BigDecimal final_price;
    
    

    public BigDecimal getTotalHours() {
        return totalHours;
    }

    public void setTotalHours(BigDecimal totalHours) {
        this.totalHours = totalHours;
    }

    public BigDecimal getMargin_porcentage() {
        return margin_porcentage;
    }

    public void setMargin_porcentage(BigDecimal margin_porcentage) {
        this.margin_porcentage = margin_porcentage;
    }

    public BigDecimal getApplied_discount() {
        return applied_discount;
    }

    public void setApplied_discount(BigDecimal applied_discount) {
        this.applied_discount = applied_discount;
    }

    public BigDecimal getFinal_price() {
        return final_price;
    }

    public void setFinal_price(BigDecimal final_price) {
        this.final_price = final_price;
    }
    

}
