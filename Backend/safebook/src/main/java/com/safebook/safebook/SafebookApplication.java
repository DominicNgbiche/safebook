package com.safebook.safebook;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling 
public class SafebookApplication {

	public static void main(String[] args) {
		SpringApplication.run(SafebookApplication.class, args);
	}

}
