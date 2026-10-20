package com.safebook.safebook.dto;

import java.time.LocalDate;
import java.time.LocalTime;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateBookingRequest {

    private Long serviceId;

    private LocalDate bookingDate;

    private LocalTime startTime;
}