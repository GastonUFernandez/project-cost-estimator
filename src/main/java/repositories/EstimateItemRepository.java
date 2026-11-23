/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package repositories;
import entities.EstimateItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author gastonfernandez
 */
public interface EstimateItemRepository extends JpaRepository<EstimateItem, Long> {
    List<EstimateItem> findByEstimateId(Long estimateId);
}
