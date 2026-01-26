package com.construction.client.controller;

import com.construction.client.model.User;
import com.construction.client.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.lang.NonNull;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable @NonNull Long id) {
        return userService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable @NonNull Long id, @RequestBody User userDetails) {
        try {
            return ResponseEntity.ok(userService.updateUser(id, userDetails));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable @NonNull Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<User> login(@RequestBody User loginRequest) {
        User user = userService.login(loginRequest.getAccountid(), loginRequest.getPassword());
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.status(401).build();
        }
    }
}
