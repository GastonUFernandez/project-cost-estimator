/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package repositories;
import entities.Estimate;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 *
 * @author Gastón Uriel Fernández
 */
public interface EstimateRepository extends JpaRepository<Estimate, Long> {
    
    
}
