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

    @SuppressWarnings("null")
    public User createUser(User user) {
        return userRepository.save(user);
    }

    @SuppressWarnings("null")
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
        return userRepository.findByAccountid(accountid)
                .filter(user -> user.getPassword().equals(password))
                .orElse(null);
    }
}
