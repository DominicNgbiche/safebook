package com.safebook.safebook.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public record BookingResponse(
    Long id,
    String serviceName,
    LocalDate bookingDate,
    LocalTime startTime,
    LocalTime endTime,
    String status
) {
}