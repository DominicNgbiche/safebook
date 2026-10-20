
package com.safebook.safebook.service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.safebook.safebook.dto.CreateServiceRequest;
import com.safebook.safebook.dto.CreateServiceRequest.SlotRequest;
import com.safebook.safebook.model.BookingServiceType;
import com.safebook.safebook.model.ServiceSlot;
import com.safebook.safebook.model.User;
import com.safebook.safebook.repository.BookingRepository;
import com.safebook.safebook.repository.BookingServiceTypeRepository;
import com.safebook.safebook.repository.ServiceSlotRepository;
import com.safebook.safebook.repository.UserRepository;

@Service
public class BookingServiceTypeService {

    private final BookingServiceTypeRepository bookingServiceTypeRepository;
    private final ServiceSlotRepository serviceSlotRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;

    public BookingServiceTypeService(
        BookingServiceTypeRepository bookingServiceTypeRepository,
        ServiceSlotRepository serviceSlotRepository,
        UserRepository userRepository,
        BookingRepository bookingRepository) {
    this.bookingServiceTypeRepository = bookingServiceTypeRepository;
    this.serviceSlotRepository = serviceSlotRepository;
    this.userRepository = userRepository;
    this.bookingRepository = bookingRepository;
}

    public List<BookingServiceType> getActiveServices() {
        return bookingServiceTypeRepository.findByActiveTrue();
    }

    public List<BookingServiceType> getServicesCreatedBy(String email) {
    return bookingServiceTypeRepository
            .findByCreatedBy_EmailIgnoreCase(email);
}

    @Transactional
    public BookingServiceType createService(CreateServiceRequest request, String creatorEmail) {

        if (request.getName() == null || request.getName().isBlank()) {
            throw new IllegalArgumentException("Service name is required");
        }

        if (request.getDurationMinutes() == null
                || request.getDurationMinutes() <= 0) {
            throw new IllegalArgumentException(
                    "Service duration must be positive");
        }

        if (request.getStartTime() == null
                || request.getEndTime() == null
                || !request.getEndTime().isAfter(request.getStartTime())) {
            throw new IllegalArgumentException(
                    "Valid service working hours are required");
        }

        if (request.getSlots() == null || request.getSlots().isEmpty()) {
            throw new IllegalArgumentException(
                    "At least one appointment slot is required");
        }

        User creator = userRepository.findByEmail(
        creatorEmail.trim().toLowerCase())
        .orElseThrow(() -> new IllegalArgumentException(
                "User not found"));

        BookingServiceType service = new BookingServiceType();
service.setCreatedBy(creator);
service.setName(request.getName().trim());
service.setDescription(request.getDescription());
service.setDurationMinutes(request.getDurationMinutes());
service.setStartTime(request.getStartTime());
service.setEndTime(request.getEndTime());
service.setActive(true);

        List<ServiceSlot> slots = new ArrayList<>();

        for (SlotRequest slotRequest : request.getSlots()) {

            LocalDate slotDate = slotRequest.getSlotDate();
            LocalTime slotStart = slotRequest.getStartTime();
            LocalTime slotEnd = slotRequest.getEndTime();

            if (slotDate == null || slotStart == null || slotEnd == null) {
                throw new IllegalArgumentException(
                        "Every slot must have a date, start time and end time");
            }

            if (slotDate.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException(
                        "Appointment slots cannot be in the past");
            }

            if (!slotEnd.isAfter(slotStart)) {
                throw new IllegalArgumentException(
                        "Slot end time must be after its start time");
            }

            if (slotStart.isBefore(service.getStartTime())
                    || slotEnd.isAfter(service.getEndTime())) {
                throw new IllegalArgumentException(
                        "Slots must fall within the service working hours");
            }

            long slotDuration = java.time.Duration.between(
                    slotStart, slotEnd).toMinutes();

            if (slotDuration != service.getDurationMinutes()) {
                throw new IllegalArgumentException(
                        "Every slot must match the service duration");
            }

            ServiceSlot slot = new ServiceSlot();
            slot.setService(service);
            slot.setSlotDate(slotDate);
            slot.setStartTime(slotStart);
            slot.setEndTime(slotEnd);
            slot.setTaken(false);

            slots.add(slot);
        }

        for (int i = 0; i < slots.size(); i++) {
            for (int j = i + 1; j < slots.size(); j++) {

                ServiceSlot first = slots.get(i);
                ServiceSlot second = slots.get(j);

                boolean sameDate = first.getSlotDate()
                        .equals(second.getSlotDate());

                boolean overlaps = first.getStartTime()
                        .isBefore(second.getEndTime())
                        && first.getEndTime()
                        .isAfter(second.getStartTime());

                if (sameDate && overlaps) {
                    throw new IllegalArgumentException(
                            "Appointment slots cannot overlap");
                }
            }
        }

        service.setSlots(slots);

        return bookingServiceTypeRepository.save(service);
    }

    
public List<BookingServiceType> getAllServices() {
    return bookingServiceTypeRepository.findAll();
}



@Transactional
public String deleteService(Long serviceId) {

    BookingServiceType service = bookingServiceTypeRepository
            .findById(serviceId)
            .orElseThrow(() -> new IllegalArgumentException(
                    "Service not found"
            ));

    if (bookingRepository.existsByService_Id(serviceId)) {
        service.setActive(false);
        bookingServiceTypeRepository.save(service);

        return "Service has existing bookings and has been deactivated instead.";
    }

    bookingServiceTypeRepository.delete(service);

    return "Service deleted successfully.";
}


}
