package com.construction.client.controller;

import com.construction.client.entity.AppFunction;
import com.construction.client.service.AppFunctionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/functions")
@CrossOrigin(origins = "*") // Allow requests from any origin
public class AppFunctionController {

    @Autowired
    private AppFunctionService appFunctionService;

    @GetMapping
    public List<AppFunction> getAllFunctions() {
        return appFunctionService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppFunction> getFunctionById(@PathVariable Integer id) {
        return appFunctionService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public AppFunction createFunction(@RequestBody AppFunction function) {
        return appFunctionService.create(function);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppFunction> updateFunction(@PathVariable Integer id,
            @RequestBody AppFunction functionDetails) {
        return ResponseEntity.ok(appFunctionService.update(id, functionDetails));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteFunction(@PathVariable Integer id) {
        appFunctionService.delete(id);
        return ResponseEntity.ok().build();
    }
}
