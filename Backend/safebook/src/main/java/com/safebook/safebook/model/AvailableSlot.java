package com.safebook.safebook.model;

import java.time.LocalTime;

public class AvailableSlot {

    private Long id;
    private LocalTime startTime;
    private LocalTime endTime;
    private boolean available;

    public AvailableSlot(
            Long id,
            LocalTime startTime,
            LocalTime endTime,
            boolean available) {

        this.id = id;
        this.startTime = startTime;
        this.endTime = endTime;
        this.available = available;
    }

    public Long getId() {
        return id;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public boolean isAvailable() {
        return available;
    }
}