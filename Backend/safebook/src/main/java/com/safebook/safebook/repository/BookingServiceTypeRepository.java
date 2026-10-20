package com.safebook.safebook.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.safebook.safebook.model.BookingServiceType;

public interface BookingServiceTypeRepository
        extends JpaRepository<BookingServiceType, Long> {

    List<BookingServiceType> findByActiveTrue();

    List<BookingServiceType> findByCreatedBy_EmailIgnoreCase(String email);
}