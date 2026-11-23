/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package entities;

import jakarta.persistence.*;
import java.time.LocalDate;

/**
 *
 * @author Gastón Uriel Fernández
 */
@Entity
@Table(name = "employees")
public class Employee {
        @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(name = "full_name", length = 120, nullable = false)
    private String fullName;

    @Column(name = "email", length = 120, nullable = false, unique = true)
    private String email;

    @Column(name = "active", nullable = false)
    private Boolean active = true;

    @Column(name = "hired_at", nullable = false)
    private LocalDate hiredAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public LocalDate getHiredAt() {
        return hiredAt;
    }

    public void setHiredAt(LocalDate hiredAt) {
        this.hiredAt = hiredAt;
    }
}
