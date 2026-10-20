
package com.safebook.safebook.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.safebook.safebook.dto.LoginRequest;
import com.safebook.safebook.dto.LoginResponse;
import com.safebook.safebook.dto.RegisterRequest;
import com.safebook.safebook.dto.VerifyEmailRequest;
import com.safebook.safebook.service.UserService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/signup")
    @ResponseStatus(HttpStatus.CREATED)
    public String register(
            @Valid @RequestBody RegisterRequest request) {

        userService.register(request);
        return "Registration successful. Check your email for the verification code.";
    }

    @PostMapping("/login")
    public LoginResponse login(
            @Valid @RequestBody LoginRequest request) {

        return userService.login(request);
    }

    @PostMapping("/verify")
    @ResponseStatus(HttpStatus.OK)
    public String verifyEmail(
            @Valid @RequestBody VerifyEmailRequest request) {

        userService.verifyEmail(request);
        return "Email verified successfully. You can now log in.";
    }
}
