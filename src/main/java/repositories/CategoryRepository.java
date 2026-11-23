/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package repositories;
import entities.Categories;
import org.springframework.data.jpa.repository.JpaRepository;
/**
 *
 * @author gastonfernandez
 */
public interface CategoryRepository extends JpaRepository<Categories, Long> {
}