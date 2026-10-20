
package com.safebook.safebook.controller;

import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.safebook.safebook.dto.BookingResponse;
import com.safebook.safebook.dto.CreateBookingRequest;
import com.safebook.safebook.model.AvailableSlot;
import com.safebook.safebook.model.Booking;
import com.safebook.safebook.model.BookingServiceType;
import com.safebook.safebook.model.User;
import com.safebook.safebook.repository.BookingServiceTypeRepository;
import com.safebook.safebook.repository.UserRepository;
import com.safebook.safebook.service.BookingService;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    private final BookingService bookingService;
    private final BookingServiceTypeRepository bookingServiceTypeRepository;
    private final UserRepository userRepository;

    public BookingController(
        BookingService bookingService,
        BookingServiceTypeRepository bookingServiceTypeRepository,
        UserRepository userRepository) {
    this.bookingService = bookingService;
    this.bookingServiceTypeRepository = bookingServiceTypeRepository;
    this.userRepository = userRepository;
}

    @GetMapping("/available")
    public List<AvailableSlot> getAvailableSlots(
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date,
            @RequestParam Long serviceId) {

        return bookingService.getAvailableSlots(date, serviceId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Booking createBooking(
            @RequestBody CreateBookingRequest request,
            Authentication authentication) {

        String email = authentication.getName();

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException(
                        "User account does not exist"));

        BookingServiceType service = bookingServiceTypeRepository
                .findById(request.getServiceId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Service does not exist"));

        Booking booking = new Booking();
        booking.setUser(user);
        booking.setService(service);
        booking.setBookingDate(request.getBookingDate());
        booking.setStartTime(request.getStartTime());

        return bookingService.createBooking(booking);
    }


    
@GetMapping("/my")
public List<BookingResponse> getMyBookings(Authentication authentication) {
    return bookingService.getBookingsForUser(authentication.getName())
            .stream()
            .map(booking -> new BookingResponse(
                    booking.getId(),
                    booking.getService().getName(),
                    booking.getBookingDate(),
                    booking.getStartTime(),
                    booking.getEndTime(),
                    booking.getStatus()
            ))
            .toList();
}


@org.springframework.web.bind.annotation.DeleteMapping("/{id}/cancel")
@ResponseStatus(HttpStatus.NO_CONTENT)
public void cancelBooking(
        @PathVariable Long id,
        Authentication authentication) {

    bookingService.cancelBooking(id, authentication.getName());
}


}
