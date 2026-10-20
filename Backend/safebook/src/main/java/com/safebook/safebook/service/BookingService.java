package com.safebook.safebook.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.safebook.safebook.model.AvailableSlot;
import com.safebook.safebook.model.Booking;
import com.safebook.safebook.model.BookingServiceType;
import com.safebook.safebook.model.ServiceSlot;
import com.safebook.safebook.repository.BookingRepository;
import com.safebook.safebook.repository.BookingServiceTypeRepository;
import com.safebook.safebook.repository.ServiceSlotRepository;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final BookingServiceTypeRepository bookingServiceTypeRepository;
    private final ServiceSlotRepository serviceSlotRepository;

    public BookingService(
        BookingRepository bookingRepository,
        BookingServiceTypeRepository bookingServiceTypeRepository,
        ServiceSlotRepository serviceSlotRepository) {

    this.bookingRepository = bookingRepository;
    this.bookingServiceTypeRepository = bookingServiceTypeRepository;
    this.serviceSlotRepository = serviceSlotRepository;
}

    @Transactional
    public Booking createBooking(Booking booking) {

        if (booking.getBookingDate() == null
                || booking.getBookingDate().isBefore(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Please select a valid booking date");
        }

        if (booking.getService() == null
                || booking.getService().getId() == null) {
            throw new IllegalArgumentException(
                    "Please select a valid service");
        }

        if (booking.getUser() == null
                || booking.getUser().getEmail() == null) {
            throw new IllegalArgumentException(
                    "Please sign in before booking");
        }

        if (booking.getStartTime() == null) {
            throw new IllegalArgumentException(
                    "Please select an appointment slot");
        }

        BookingServiceType service = bookingServiceTypeRepository
                .findById(booking.getService().getId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Selected service does not exist"));

        if (!service.isActive()) {
            throw new IllegalArgumentException(
                    "This service is currently unavailable");
        }

        String email = booking.getUser().getEmail();
        Long serviceId = service.getId();
        LocalDate bookingDate = booking.getBookingDate();

        boolean alreadyBooked = bookingRepository
                .existsByUser_EmailAndService_IdAndBookingDateAndStatus(
                        email, serviceId, bookingDate, "CONFIRMED");

        if (alreadyBooked) {
            throw new IllegalArgumentException(
                    "You have already booked this service for that day");
        }

        ServiceSlot slot = serviceSlotRepository
                .findAvailableSlotForUpdate(
                        serviceId, bookingDate, booking.getStartTime())
                .orElseThrow(() -> new IllegalArgumentException(
                        "This appointment slot is unavailable or already taken"));

        booking.setService(service);
        booking.setStartTime(slot.getStartTime());
        booking.setEndTime(slot.getEndTime());
        booking.setStatus("CONFIRMED");

        try {
            Booking savedBooking = bookingRepository.saveAndFlush(booking);

            slot.setTaken(true);
            serviceSlotRepository.saveAndFlush(slot);

            return savedBooking;

        } catch (DataIntegrityViolationException e) {
            throw new IllegalArgumentException(
                    "This appointment could not be booked. It may have just been taken.");
        }
    }

    @Transactional(readOnly = true)
    public List<AvailableSlot> getAvailableSlots(
            LocalDate bookingDate,
            Long serviceId) {

        if (bookingDate == null || bookingDate.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Please select a valid booking date");
        }

        BookingServiceType service = bookingServiceTypeRepository
                .findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Service does not exist"));

        if (!service.isActive()) {
            throw new IllegalArgumentException(
                    "This service is currently unavailable");
        }

        
return serviceSlotRepository
        .findByService_IdAndSlotDateOrderByStartTimeAsc(
                serviceId, bookingDate)
        .stream()
        .map(slot -> new AvailableSlot(
                slot.getId(),
                slot.getStartTime(),
                slot.getEndTime(),
                !slot.isTaken()
        ))
        .toList();

    }

    public List<Booking> getBookingsForUser(String email) {
        return bookingRepository
                .findByUser_EmailOrderByBookingDateDescStartTimeDesc(email);
    }

@Transactional
public void cancelBooking(Long bookingId, String email) {

    Booking booking = bookingRepository
            .findByUser_EmailAndId(email, bookingId)
            .stream()
            .findFirst()
            .orElseThrow(() -> new IllegalArgumentException(
                    "Booking not found"));

    if ("CANCELLED".equals(booking.getStatus())) {
        throw new IllegalArgumentException(
                "This booking has already been cancelled");
    }

    LocalDate today = LocalDate.now();
    LocalTime now = LocalTime.now();

    if (booking.getBookingDate().isBefore(today)
            || (booking.getBookingDate().equals(today)
                && !now.isBefore(booking.getStartTime()))) {
        throw new IllegalArgumentException(
                "You can only cancel a booking before its appointment start time");
    }

    ServiceSlot slot = serviceSlotRepository
            .findByService_IdAndSlotDateAndStartTime(
                    booking.getService().getId(),
                    booking.getBookingDate(),
                    booking.getStartTime())
            .orElse(null);

    booking.setStatus("CANCELLED");
    bookingRepository.save(booking);

    if (slot != null) {
        slot.setTaken(false);
        serviceSlotRepository.save(slot);
    }
}


@Transactional
public void deleteService(
        Long serviceId,
        String requesterEmail,
        boolean canDeleteAnyService) {

    BookingServiceType service = bookingServiceTypeRepository
            .findById(serviceId)
            .orElseThrow(() -> new IllegalArgumentException(
                    "Service not found"));

    if (!canDeleteAnyService) {
        if (service.getCreatedBy() == null
                || !service.getCreatedBy().getEmail()
                        .equalsIgnoreCase(requesterEmail)) {
            throw new org.springframework.security.access.AccessDeniedException(
                    "You can only delete services you created");
        }
    }

    bookingRepository.deleteByService_Id(serviceId);

    bookingServiceTypeRepository.delete(service);
}
}