
package com.safebook.safebook.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.safebook.safebook.model.Booking;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByBookingDate(LocalDate bookingDate);

    List<Booking> findByUser_EmailOrderByBookingDateDescStartTimeDesc(
            String email
    );

    List<Booking> findByUser_EmailAndId(String email, Long id);

    boolean existsByBookingDateAndStatusAndStartTimeLessThanAndEndTimeGreaterThan(
            LocalDate bookingDate,
            String status,
            LocalTime endTime,
            LocalTime startTime
    );

    boolean existsByUser_EmailAndService_IdAndBookingDateAndStatus(
            String email,
            Long serviceId,
            LocalDate bookingDate,
            String status
    );

    List<Booking> findByService_Id(Long serviceId);

    void deleteByService_Id(Long serviceId);

    boolean existsByService_Id(Long serviceId);
}
