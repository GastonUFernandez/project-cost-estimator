/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

/**
 *
 * @author Gastón Uriel Fernández
 */

@Entity
@Table(name = "estimate_items")
public class EstimateItem {
     @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "estimate_id", nullable = false)
    private Estimate estimate;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(name = "task_description", length = 255, nullable = false)
    private String taskDescription;

    @Column(name = "estimated_hours", precision = 7, scale = 2, nullable = false)
    private BigDecimal estimatedHours;

    // Verificá el nombre exacto de estas dos columnas DECIMAL(10,2) en MySQL
    @Column(name = "applied_hourly_cost", precision = 10, scale = 2, nullable = false)
    private BigDecimal appliedHourlyCost;

    @Column(name = "applied_hourly_rate", precision = 10, scale = 2, nullable = false)
    private BigDecimal appliedHourlyRate;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Estimate getEstimate() {
        return estimate;
    }

    public void setEstimate(Estimate estimate) {
        this.estimate = estimate;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getTaskDescription() {
        return taskDescription;
    }

    public void setTaskDescription(String taskDescription) {
        this.taskDescription = taskDescription;
    }

    public BigDecimal getEstimatedHours() {
        return estimatedHours;
    }

    public void setEstimatedHours(BigDecimal estimatedHours) {
        this.estimatedHours = estimatedHours;
    }

    public BigDecimal getAppliedHourlyCost() {
        return appliedHourlyCost;
    }

    public void setAppliedHourlyCost(BigDecimal appliedHourlyCost) {
        this.appliedHourlyCost = appliedHourlyCost;
    }

    public BigDecimal getAppliedHourlyRate() {
        return appliedHourlyRate;
    }

    public void setAppliedHourlyRate(BigDecimal appliedHourlyRate) {
        this.appliedHourlyRate = appliedHourlyRate;
    }
}   

