package com.safebook.safebook;


import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        String password = "password";
        String hash = encoder.encode(password);

        System.out.println("Password hash: " + hash);
    }
}
