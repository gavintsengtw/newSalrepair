package com.construction.client.service;

import com.construction.client.dto.DeviceRegisterRequest;
import com.construction.client.entity.AppDevices;
import com.construction.client.repository.AppDevicesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class DeviceService {

    @Autowired
    private AppDevicesRepository appDevicesRepository;

    @Transactional
    public void registerDevice(DeviceRegisterRequest request, Long userId) {
        Optional<AppDevices> existingDeviceOpt = appDevicesRepository.findByFcmToken(request.getFcmToken());

        if (existingDeviceOpt.isPresent()) {
            AppDevices device = existingDeviceOpt.get();
            // Update UserID if changed (handling device handover)
            if (!device.getUserId().equals(userId)) {
                device.setUserId(userId);
            }
            // Update other fields
            device.setDeviceType(request.getDeviceType());
            device.setDeviceModel(request.getDeviceModel());
            device.setOsVersion(request.getOsVersion());
            device.setAppVersion(request.getAppVersion());
            device.setLastActiveTime(LocalDateTime.now());

            appDevicesRepository.save(device);
        } else {
            AppDevices newDevice = new AppDevices();
            newDevice.setUserId(userId);
            newDevice.setFcmToken(request.getFcmToken());
            newDevice.setDeviceType(request.getDeviceType());
            newDevice.setDeviceModel(request.getDeviceModel());
            newDevice.setOsVersion(request.getOsVersion());
            newDevice.setAppVersion(request.getAppVersion());

            appDevicesRepository.save(newDevice);
        }
    }

    @Transactional
    public void unregisterDevice(String fcmToken) {
        appDevicesRepository.deleteByFcmToken(fcmToken);
    }

    public java.util.List<AppDevices> findAll() {
        return appDevicesRepository.findAll();
    }

    public Optional<AppDevices> findById(Integer id) {
        return appDevicesRepository.findById(id);
    }

    public void deleteById(Integer id) {
        appDevicesRepository.deleteById(id);
    }
}
