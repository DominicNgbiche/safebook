
package com.safebook.safebook.dto;

import com.safebook.safebook.model.BookingServiceType;

public record AdminServiceResponse(
        Long id,
        String name,
        String description,
        Integer durationMinutes,
        boolean active
) {
    public static AdminServiceResponse from(BookingServiceType service) {
        return new AdminServiceResponse(
                service.getId(),
                service.getName(),
                service.getDescription(),
                service.getDurationMinutes(),
                service.isActive()
        );
    }
}
