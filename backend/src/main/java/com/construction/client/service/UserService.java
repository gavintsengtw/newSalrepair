package com.construction.client.service;

import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import org.springframework.lang.NonNull;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(@NonNull Long id) {
        return userRepository.findById(id);
    }

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public User updateUser(Long id, User userDetails) {
        return userRepository.findById(id).map(user -> {
            user.setAccountid(userDetails.getAccountid());
            user.setPassword(userDetails.getPassword());
            return userRepository.save(user);
        }).orElseThrow(() -> new RuntimeException("User not found with id " + id));
    }

    public void deleteUser(@NonNull Long id) {
        userRepository.deleteById(id);
    }

    public User login(String accountid, String password) {
        System.out.println("Attempting login for accountid: [" + accountid + "]");
        Optional<User> userOpt = userRepository.findByAccountid(accountid);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            System.out.println("User found in DB: [" + user.getAccountid() + "]");
            System.out.println("DB Password: [" + user.getPassword() + "]");
            System.out.println("Input Password: [" + password + "]");

            // Use trim() in case of trailing spaces in DB
            boolean match = user.getPassword().trim().equals(password.trim());
            System.out.println("Password match: " + match);

            if (match)
                return user;
        } else {
            System.out.println("User NOT found in DB for accountid: [" + accountid + "]");
        }
        return null;
    }
    public boolean changePassword(String accountid, String oldPassword, String newPassword) {
        Optional<User> userOpt = userRepository.findByAccountid(accountid);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Verify old password
            if (user.getPassword().trim().equals(oldPassword.trim())) {
                user.setPassword(newPassword);
                user.setIsDefaultPassword(false); // Reset default password flag
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }
}
