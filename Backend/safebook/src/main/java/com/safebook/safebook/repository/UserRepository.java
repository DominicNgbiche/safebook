
package com.safebook.safebook.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.safebook.safebook.model.User;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    
void deleteByEmailVerifiedFalseAndEmailVerificationCodeExpiresAtBefore(
        java.time.LocalDateTime time
);

}
