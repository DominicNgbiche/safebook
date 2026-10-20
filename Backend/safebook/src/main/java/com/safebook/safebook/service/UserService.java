
package com.safebook.safebook.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Locale;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.safebook.safebook.dto.LoginRequest;
import com.safebook.safebook.dto.LoginResponse;
import com.safebook.safebook.dto.RegisterRequest;
import com.safebook.safebook.dto.VerifyEmailRequest;
import com.safebook.safebook.model.User;
import com.safebook.safebook.repository.UserRepository;
import com.safebook.safebook.security.JwtService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final EmailService emailService;

private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    @Transactional
    public void register(RegisterRequest request) {

        String email = normalizeEmail(request.getEmail());

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }

        String code = String.format(
                "%06d",
                SECURE_RANDOM.nextInt(1_000_000)
        );

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("USER");
        user.setEmailVerified(false);
        user.setEmailVerificationCode(code);
        user.setEmailVerificationCodeExpiresAt(
                LocalDateTime.now().plusMinutes(10)
        );

        userRepository.save(user);

        emailService.sendEmailVerification(email, code);
    }

    @Transactional
    public void verifyEmail(VerifyEmailRequest request) {

        String email = normalizeEmail(request.getEmail());
        String code = request.getCode().trim();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Invalid email or verification code."
                ));

        if (user.isEmailVerified()) {
            throw new IllegalArgumentException(
                    "This email has already been verified."
            );
        }

        if (user.getEmailVerificationCode() == null
                || !user.getEmailVerificationCode().equals(code)) {
            throw new IllegalArgumentException(
                    "Invalid email or verification code."
            );
        }

        LocalDateTime expiry =
                user.getEmailVerificationCodeExpiresAt();

        if (expiry == null || LocalDateTime.now().isAfter(expiry)) {
            throw new IllegalArgumentException(
                    "Verification code has expired."
            );
        }

        user.setEmailVerified(true);
        user.setEmailVerificationCode(null);
        user.setEmailVerificationCodeExpiresAt(null);

        userRepository.save(user);
    }

    public LoginResponse login(LoginRequest request) {

        String email = normalizeEmail(request.getEmail());

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Invalid email or password."
                ));

        if (!user.isEmailVerified()) {
            throw new IllegalArgumentException(
                    "Please verify your email before logging in."
            );
        }

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        email,
                        request.getPassword()
                )
        );

        var userDetails =
                org.springframework.security.core.userdetails.User
                        .withUsername(user.getEmail())
                        .password(user.getPassword())
                        .roles(user.getRole())
                        .build();

        String token = jwtService.generateToken(userDetails);

        return new LoginResponse(token, "Bearer", user.getRole());
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
