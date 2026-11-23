/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package repositories;
import entities.Role;
import org.springframework.data.jpa.repository.JpaRepository;
/**
 *
 * @author gastonfernandez
 */
public interface RoleRepository extends JpaRepository<Role, Long> {
}
