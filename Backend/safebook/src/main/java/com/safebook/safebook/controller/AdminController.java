
package com.safebook.safebook.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.safebook.safebook.dto.AdminServiceResponse;
import com.safebook.safebook.service.AdminService;
import com.safebook.safebook.service.BookingServiceTypeService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
public class AdminController {

    private final AdminService adminService;
    private final BookingServiceTypeService bookingServiceTypeService;

    @GetMapping("/users/count")
    public long getTotalUsers() {
        return adminService.getTotalUsers();
    }

    @GetMapping("/services/count")
    public long getTotalServices() {
        return adminService.getTotalServices();
    }

    @GetMapping("/bookings/count")
    public long getTotalBookings() {
        return adminService.getTotalBookings();
    }

    
@GetMapping("/services")
public List<AdminServiceResponse> getAllServices() {
    return adminService.getAllServices()
            .stream()
            .map(AdminServiceResponse::from)
            .toList();
}



@DeleteMapping("/services/{serviceId}")
public ResponseEntity<String> deleteService(
        @PathVariable Long serviceId) {

    String message = bookingServiceTypeService.deleteService(serviceId);
    return ResponseEntity.ok(message);
}


}
