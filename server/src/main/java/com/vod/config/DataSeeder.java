package com.vod.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.vod.entities.Video;
import com.vod.entities.VideoRepository;

@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initDatabase(VideoRepository videoRepository) {
        return args -> {
            if (videoRepository.count() != 0) {
                return;
            }
            videoRepository.save(new Video(null, "Video 1", "Description 1", 100, "https://example.com/thumbnail1.jpg",
                    "path/to/video1.mp4"));
            videoRepository.save(new Video(null, "Video 2", "Description 2", 200, "https://example.com/thumbnail2.jpg",
                    "path/to/video2.mp4"));
        };
    }
}
