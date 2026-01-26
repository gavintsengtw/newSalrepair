package com.construction.client.service;

import com.construction.client.model.User;
import com.construction.client.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String accountid) throws UsernameNotFoundException {
        User user = userRepository.findByAccountid(accountid)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with accountid: " + accountid));

        return new org.springframework.security.core.userdetails.User(user.getAccountid(), user.getPassword(),
                new ArrayList<>());
    }
}
