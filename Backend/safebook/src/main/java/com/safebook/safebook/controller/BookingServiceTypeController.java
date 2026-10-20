
package com.safebook.safebook.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.safebook.safebook.dto.CreateServiceRequest;
import com.safebook.safebook.model.BookingServiceType;
import com.safebook.safebook.service.BookingService;
import com.safebook.safebook.service.BookingServiceTypeService;

@RestController
@RequestMapping("/api/services")
public class BookingServiceTypeController {

    private final BookingServiceTypeService bookingServiceTypeService;
    private final BookingService bookingService;

    public BookingServiceTypeController(
        BookingServiceTypeService bookingServiceTypeService,
        BookingService bookingService) {
    this.bookingServiceTypeService = bookingServiceTypeService;
    this.bookingService = bookingService;
}

    @GetMapping
    public List<BookingServiceType> getAvailableServices() {
        return bookingServiceTypeService.getActiveServices();
    }

    @GetMapping("/my")
public List<BookingServiceType> getMyServices(
        Authentication authentication) {
    return bookingServiceTypeService.getServicesCreatedBy(
            authentication.getName());
}


    @PostMapping
@ResponseStatus(HttpStatus.CREATED)
public BookingServiceType createService(
        @RequestBody CreateServiceRequest request,
        Authentication authentication) {
    return bookingServiceTypeService.createService(
            request, authentication.getName());
}

    @DeleteMapping("/{id}")
@PreAuthorize("isAuthenticated()")
@ResponseStatus(HttpStatus.NO_CONTENT)
public void deleteService(
        @PathVariable Long id,
        Authentication authentication) {

    boolean canDeleteAnyService = authentication.getAuthorities()
            .stream()
            .map(GrantedAuthority::getAuthority)
            .anyMatch(role ->
                    role.equals("ROLE_ADMIN")
                    || role.equals("ROLE_SUPER_ADMIN"));

    bookingService.deleteService(
            id,
            authentication.getName(),
            canDeleteAnyService);
}
}
