
package com.safebook.safebook.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendEmailVerification(
            String email,
            String verificationCode) {

        SimpleMailMessage message = new SimpleMailMessage();

        message.setTo(email);
        message.setSubject("SafeBook Email Verification");
        message.setText(
                "Welcome to SafeBook!\n\n"
                + "Your verification code is: " + verificationCode
                + "\n\nThis code expires in 10 minutes."
                + "\n\nIf you did not create this account, "
                + "you can ignore this email."
        );

        mailSender.send(message);
    }
}
