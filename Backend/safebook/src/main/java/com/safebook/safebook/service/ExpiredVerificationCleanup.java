
package com.safebook.safebook.service;

import java.time.LocalDateTime;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.safebook.safebook.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class ExpiredVerificationCleanup {

    private final UserRepository userRepository;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void deleteExpiredUnverifiedUsers() {
        userRepository
                .deleteByEmailVerifiedFalseAndEmailVerificationCodeExpiresAtBefore(
                        LocalDateTime.now()
                );
    }
}
