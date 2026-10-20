
package com.safebook.safebook.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.safebook.safebook.model.BookingServiceType;
import com.safebook.safebook.model.User;
import com.safebook.safebook.repository.BookingRepository;
import com.safebook.safebook.repository.BookingServiceTypeRepository;
import com.safebook.safebook.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;
    private final BookingServiceTypeRepository bookingServiceTypeRepository;
    private final BookingRepository bookingRepository;

    public long getTotalUsers() {
        return userRepository.count();
    }

    public long getTotalServices() {
        return bookingServiceTypeRepository.count();
    }

    public long getTotalBookings() {
        return bookingRepository.count();
    }

    public List<User> getAllUsers() {
    return userRepository.findAll();
}


public List<BookingServiceType> getAllServices() {
    return bookingServiceTypeRepository.findAll();
}
}
