package com.safebook.safebook.repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

import com.safebook.safebook.model.ServiceSlot;

public interface ServiceSlotRepository extends JpaRepository<ServiceSlot, Long> {

    List<ServiceSlot> findByService_IdAndSlotDateOrderByStartTimeAsc(
            Long serviceId,
            LocalDate slotDate
    );

    List<ServiceSlot> findByService_IdAndSlotDateAndTakenFalseOrderByStartTimeAsc(
            Long serviceId,
            LocalDate slotDate
    );

    Optional<ServiceSlot> findByService_IdAndSlotDateAndStartTimeAndTakenFalse(
            Long serviceId,
            LocalDate slotDate,
            LocalTime startTime
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT s FROM ServiceSlot s
            WHERE s.service.id = :serviceId
              AND s.slotDate = :slotDate
              AND s.startTime = :startTime
              AND s.taken = false
            """)
    Optional<ServiceSlot> findAvailableSlotForUpdate(
            @Param("serviceId") Long serviceId,
            @Param("slotDate") LocalDate slotDate,
            @Param("startTime") LocalTime startTime
    );

    Optional<ServiceSlot> findByService_IdAndSlotDateAndStartTime(
            Long serviceId,
            LocalDate slotDate,
            LocalTime startTime
    );

    
boolean existsByService_Id(Long serviceId);

}