
package com.safebook.safebook.dto;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateServiceRequest {

    private String name;

    private String description;

    private Integer durationMinutes;

    private LocalTime startTime;

    private LocalTime endTime;

    private List<SlotRequest> slots;

    @Getter
    @Setter
    public static class SlotRequest {

        private LocalDate slotDate;

        private LocalTime startTime;

        private LocalTime endTime;
    }
}
